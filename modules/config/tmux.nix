{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    keyMode = "vi";
    extraConfig = ''
      # Set Ctrl+a as prefix (standard tmux default)
      set -g prefix C-a
      unbind C-b
      bind C-a send-prefix

      # Window switching
      bind -n C-h previous-window
      bind -n C-l next-window

      # Enable mouse support
      set -g mouse on

      # don't do anything when a 'bell' rings
      set -g visual-activity off
      set -g visual-bell off
      set -g visual-silence off
      setw -g monitor-activity off
      set -g bell-action none

      # clock mode
      setw -g clock-mode-colour "yellow"

      # copy mode
      setw -g mode-style "fg=black,bg=red,bold"

      # panes
      set -g pane-border-style "fg=red"
      set -g pane-active-border-style "fg=yellow"

      # statusbar
      set -g status-position bottom
      set -g status-justify left
      set -g status-style "fg=red,bg=black"

      set -g status-left ""
      set -g status-left-length 10

      set -g status-right "#[fg=black,bg=yellow] %Y-%m-%d %H:%M "
      set -g status-right-length 50

      set-option -g window-status-current-style "fg=black,bg=red"
      set-option -g window-status-current-format " #I #W #F "

      set-option -g window-status-style "fg=red,bg=black"
      set-option -g window-status-format " #I #W #F "

      set-option -g window-status-bell-style "fg=yellow,bg=red,bold"

      # messages
      set -g message-style "fg=yellow,bg=red,bold"
    '';
  };
}
