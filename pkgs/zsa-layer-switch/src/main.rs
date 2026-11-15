#![windows_subsystem = "windows"]

use std::ffi::OsString;
use std::os::windows::ffi::OsStringExt;
use std::path::Path;
use std::ptr;
use std::thread::sleep;
use std::time::{Duration, Instant};

use hidapi::{HidApi, HidDevice};
use windows_sys::Win32::Foundation::{CloseHandle, HWND};
use windows_sys::Win32::System::Threading::{
    OpenProcess, QueryFullProcessImageNameW, PROCESS_QUERY_LIMITED_INFORMATION,
};
use windows_sys::Win32::UI::WindowsAndMessaging::{GetForegroundWindow, GetWindowThreadProcessId};

const TILING_PROGRAMS: &[&str] = &["WindowsTerminal.exe"];
const TILING_LAYER: u8 = 1;

const VENDOR_ID: u16 = 0x3297;
const USAGE_PAGE: u16 = 0xFF60;
const USAGE: u16 = 0x61;
const PACKET_SIZE: usize = 32;

const CMD_PAIRING_INIT: u8 = 0x01;
const CMD_SET_LAYER: u8 = 0x04;
const CMD_GET_PROTOCOL_VERSION: u8 = 0xFE;

const POLL_INTERVAL: Duration = Duration::from_millis(50);
const KEYBOARD_CHECK_INTERVAL: Duration = Duration::from_secs(1);

fn program_of(window: HWND) -> Option<String> {
    let mut buffer = [0u16; 1024];
    let mut length = buffer.len() as u32;
    unsafe {
        let mut process_id = 0;
        GetWindowThreadProcessId(window, &mut process_id);
        let process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, 0, process_id);
        if process.is_null() {
            return None;
        }
        let found = QueryFullProcessImageNameW(process, 0, buffer.as_mut_ptr(), &mut length);
        CloseHandle(process);
        if found == 0 {
            return None;
        }
    }
    let path = OsString::from_wide(&buffer[..length as usize]);
    Some(Path::new(&path).file_name()?.to_string_lossy().into_owned())
}

fn is_tiling_program(program: &str) -> bool {
    TILING_PROGRAMS
        .iter()
        .any(|tiling| tiling.eq_ignore_ascii_case(program))
}

fn connect(api: &mut HidApi) -> Option<HidDevice> {
    api.reset_devices().ok()?;
    api.add_devices(VENDOR_ID, 0).ok()?;
    api.device_list()
        .find(|device| device.usage_page() == USAGE_PAGE && device.usage() == USAGE)?
        .open_device(api)
        .ok()
}

fn send(keyboard: &HidDevice, command: u8, params: &[u8]) -> bool {
    let mut report = [0u8; PACKET_SIZE + 1];
    report[1] = command;
    report[2..2 + params.len()].copy_from_slice(params);
    keyboard.write(&report).is_ok()
}

fn set_tiling_layer(keyboard: &HidDevice, on: bool) -> bool {
    send(keyboard, CMD_PAIRING_INIT, &[]) && send(keyboard, CMD_SET_LAYER, &[on as u8, TILING_LAYER])
}

fn main() {
    HidApi::disable_device_discovery();
    let mut api = HidApi::new().expect("HID access failed");
    let mut keyboard: Option<HidDevice> = None;
    let mut last_check: Option<Instant> = None;
    let mut window: HWND = ptr::null_mut();
    let mut tiling = false;
    let mut pending = false;

    loop {
        let foreground = unsafe { GetForegroundWindow() };
        if !foreground.is_null() && foreground != window {
            window = foreground;
            let program = program_of(window).unwrap_or_default();
            tiling = is_tiling_program(&program);
            pending = true;
            println!("focus: {program}");
        }

        if last_check.is_none_or(|check| check.elapsed() >= KEYBOARD_CHECK_INTERVAL) {
            last_check = Some(Instant::now());
            match &keyboard {
                Some(connected) => {
                    if !send(connected, CMD_GET_PROTOCOL_VERSION, &[]) {
                        keyboard = None;
                        println!("keyboard disconnected");
                    }
                }
                None => {
                    keyboard = connect(&mut api);
                    if keyboard.is_some() {
                        pending = true;
                        println!("keyboard connected");
                    }
                }
            }
        }

        if pending {
            if let Some(connected) = &keyboard {
                if set_tiling_layer(connected, tiling) {
                    pending = false;
                    println!("tiling layer {}", if tiling { "on" } else { "off" });
                } else {
                    keyboard = None;
                    println!("keyboard disconnected");
                }
            }
        }

        sleep(POLL_INTERVAL);
    }
}
