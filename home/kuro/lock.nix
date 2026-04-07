{ pkgs, ... }:

{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
      };

      background = [
        { path = "$HOME/Pictures/Wallpapers/Quasar.png"; }
      ];
      
      input-field = [
        { 
          monitor = "DP-1";
          outline_thickness = 3;
          outer_color = "rgb(00ffff)";
          inner_color = "rgb(000000)";
          font_color = "rgb(00ffff)";
          rounding = 0;
          fade_on_empty = false;
          size = "400, 90";
          position = "0, -65";
        }
      ];
      shape = [
        { 
          monitor = "DP-1";
          border_size = 3;
          border_color = "rgb(00ffff)";
          color = "rgb(000000)";
          rounding = 0;
          size = "400, 90";
          position = "0, 65";
        }
      ];
      label = [
        { 
          monitor = "DP-1";
          text = "cmd[update:0] echo '<i>$USER</i>'";
          color = "rgb(00ffff)";
          position = "0, 65";
	  font_size = 24;
          z_index = 1;
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 900;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 120;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
