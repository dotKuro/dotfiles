{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    settings = {
      "$mod" = "SUPER";
      general = {
        layout = "master";
        border_size = "2";
        "col.active_border" = "rgb(00ffff)";
	gaps_in = "10";
        gaps_out = "15";
      };
      animations.enabled = true;
      exec-once = "waybar";
      monitor = [
        "DP-1, 3840x2160, 0x0, 1"
        "DP-2, 3840x2160, -3840x0, 1"
      ];
      input = {
        kb_layout = "eu";
      };
      env = [
        "HYPRCURSOR_THEME,rose-pine-hyercursor"
        "HYPRCURSOR_SIZE,36"
      ];
      cursor.enable_hyprcursor = true;
      bind = [
        "$mod, W, exec, kitty"
        "$mod, E, exec, rofi -show drun"
        "$mod, Q, killactive"
        "$mod, J, cyclenext, tiled"
        "$mod, K, cyclenext, prev tiled"
        "$mod, L, exec, hyprlock"
        "$mod SHIFT, J, swapnext"
        "$mod SHIFT, K, swapnext, prev"
        "$mod, TAB, focusmonitor, +1"
        "$mod SHIFT, TAB, movewindow, mon:+1"
        "$mod, F, exec, toggle-layouts"
      ] ++ (
        builtins.concatLists (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mod, code:1${toString i}, focusworkspaceoncurrentmonitor, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspacesilent, ${toString ws}"
          ]
        ) 9)
      );
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = ""; 
          path = "$HOME/Pictures/Wallpapers/Quasar.png";
          fit_mode = "cover";
        }
      ];
    };
  };
  
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.waybar = {
    enable = true;
    settings = {
      statusBar = {
        layer = "top";
        position = "top";
        
        modules-center = [ "hyprland/workspaces" ];
        modules-right = [ "idle_inhibitor" "pulseaudio" "network" "tray" ];
        modules-left = [ "clock" ];
        
	"hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "";
            default = "";
          };
          move-to-monitor = true;
          persistent-workspaces = {
            "*" = [ 1 2 3 4 5 ];
          };
        };
        
        tray = {
          font-size = 18;
          spacing = 10;
        };
        
        network = {
          format-wifi = "󰤢";
          format-ethernet = "󰈀 ";
          format-disconnected = "󰤠 ";
          interval = 5;
          tooltip-format-ethernet = "connected - {ipaddr}";
          tooltip-format-wifi = "connected - {essid} ({signalStrength}%)";
        };
        
        pulseaudio = {
          format = "{icon:2}  {volume:3}%";
          format-muted = "<span color='#ff00ff'>  muted</span>";
          format-icons = [ "" "" " " ];
          on-click = "pamixer --toggle-mute";
          on-scroll-up = "pamixer --increase 5";
          on-scroll-down = "pamixer --decrease 5";
        };
        
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "<span color='#ff00ff'>󰈈</span>";
            deactivated = "󰈈";
          };
          tooltip-format-activated = "<span color='#ff00ff'>prevent idle</span>";
          tooltip-format-deactivated = "idle like normal";
        };

        clock = {
          format = "{:%H:%M:%S - %A %d.%b}";
          interval = 1;
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            format = {
              today = "<span color='#ff00ff'><b>{}</b></span>";
            };
          };
        };
      };
    };
    style = ''
      * {
        font-weight: 600;
        font-size: 18px;
      }
      
      #waybar {
        background: transparent;
      }
      
      .modules-center,
      .modules-right,
      .modules-left {
        background-color: #000000;
        border-radius: 6px;
        margin: 0 15px;
      }

      .modules-right,
      .modules-left {
        color: #00ffff;
      }
 
      #workspaces button {
        color: #333333;
        background: none;
      }

      #workspaces button:hover {
        background: inherit;
        box-shadow: inherit;
        text-shadow: inherit;
        outline: inherit;
        border: inherit;
      }
 
      #workspaces button.active {
        color: #00ffff;
      }

      #tray,
      #clock,
      #network,
      #pulseaudio,
      #idle_inhibitor {
        padding: 0 10px;
      }
 
      #workspaces button,
      #network,
      #idle_inhibitor {
        font-family: "Font Awesome 7 Free";
      }
 
      #pulseaudio,
      #clock {
        font-family: "Hack Nerd Font";
      }

    '';
  };
  
}
