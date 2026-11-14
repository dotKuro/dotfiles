{ pkgs, ... }:

{
  # Device access is granted to the logged-in user via systemd uaccess rules
  # (systemd >= 258), so no adbusers group or udev rules are needed.
  environment.systemPackages = [ pkgs.android-tools ];
}
