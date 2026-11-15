{ config, lib, ... }:

let
  keys = import ./tiling-keys.nix;
  tmuxKey = key: if key == "Return" then "Enter" else key;
  shiftedDigits = [
    "!"
    "@"
    "#"
    "$"
    "%"
    "^"
    "&"
    "*"
    "("
  ];
  bindShifted =
    key: shifted: command:
    lib.concatMapStrings (name: "bind -n '${name}' ${command}\n") [
      "M-${shifted}"
      "M-S-${key}"
      "M-S-${shifted}"
    ];
  workspaceBindings = lib.concatStrings (
    lib.imap1 (
      index: shifted:
      let
        ws = toString index;
      in
      ''
        bind -n 'M-${ws}' if-shell "tmux select-window -t :${ws}" "" "new-window -t :${ws}"
      ''
      +
        bindShifted ws shifted
          ''if-shell "tmux join-pane -d -t :${ws}" "select-layout -t :${ws} main-vertical" "break-pane -d -t :${ws}"''
    ) shiftedDigits
  );
in
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    mouse = true;
    terminal = "tmux-256color";
    extraConfig = ''
      set -as terminal-features ",xterm-256color:RGB"
      set -as terminal-features ",xterm*:extkeys"
      set -s extended-keys on
      set -g status-style "bg=#313131,fg=#ffffff"
      set -g window-status-format " #I:#W "
      set -g window-status-current-format " #I:#W "
      set -g window-status-style "bg=#545454"
      set -g window-status-current-style "bg=#000000,bold"
      set -g message-style "bg=#2a2a6a,fg=#f0f0f0"
      set -g mode-style "bg=#5a5a5a,fg=#ffffff"
      set -g pane-border-lines heavy
      set -g pane-border-indicators both
      set -g pane-border-style "fg=#646464"
      set -g pane-active-border-style "fg=#2fafff"
      set -g window-style "bg=#191919"
      set -g window-active-style "bg=#000000"

      set -g main-pane-width 55%
      set-hook -g after-split-window "select-layout main-vertical"
      set-hook -g after-kill-pane "select-layout main-vertical"
      set-hook -g pane-exited "select-layout main-vertical"

      bind -n 'M-${keys.spawn}' split-window -c "#{pane_current_path}"
      bind -n 'M-${keys.launcher}' command-prompt -p "run:" "split-window -c '#{pane_current_path}' '%%'"
      bind -n 'M-${keys.close}' kill-pane
      bind -n 'M-${keys.focusNext}' select-pane -Z -t :.+
      bind -n 'M-${keys.focusPrev}' select-pane -Z -t :.-
      bind -n 'M-${keys.toggleLayout}' resize-pane -Z
      bind -n 'M-${tmuxKey keys.master}' select-pane -Z -t :.1
      bind -n 'M-S-${tmuxKey keys.master}' swap-pane -t :.1 \; select-pane -t :.1
    ''
    + bindShifted keys.focusNext (lib.toUpper keys.focusNext) "swap-pane -D"
    + bindShifted keys.focusPrev (lib.toUpper keys.focusPrev) "swap-pane -U"
    + workspaceBindings;
  };

  xdg.configFile."tmux/tmux.conf".onChange = ''
    (
      export TMUX_TMPDIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
      if ${config.programs.tmux.package}/bin/tmux has-session 2>/dev/null; then
        ${config.programs.tmux.package}/bin/tmux source-file ${config.xdg.configHome}/tmux/tmux.conf \
          || echo "tmux: reloading the config failed"
      fi
    )
  '';
}
