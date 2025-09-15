{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    keyMode = "vi";
    historyLimit = 100000; # Set scrollback to 100k lines
    extraConfig = ''
            # Window switching with Alt+j/k (no prefix)
            bind -n M-j previous-window
            bind -n M-k next-window

            # Enable mouse support
            set -g mouse on

            # Don't do anything when a 'bell' rings
            set -g visual-activity off
            set -g visual-bell off
            set -g visual-silence off
            setw -g monitor-activity off
            set -g bell-action none

            # Clock mode
            setw -g clock-mode-colour "yellow"

            # Copy mode
            setw - g mode-style "fg=black,bold"


            # Panes
            set - g pane-border-style "default"

            set -g pane-active-border-style "fg=yellow"

            # Statusbar
            set -g status-position bottom
            set -g status-justify left
            set - g status-style "bg=black"


            set -g status-left ""
            set -g status-left-length 10

            set -g status-right "#[fg=black,bg=yellow] %Y-%m-%d %I:%M %p "
            set -g status-right-length 50

            set-option - g window-status-current-style "fg=black"

            set-option -g window-status-current-format " #I #W #F "

            set-option - g window-status-style "bg=black"

            set-option -g window-status-format " #I #W #F "

            set-option - g window-status-bell-style "fg=yellow,bold"


            # Messages
            set - g message-style "fg=yellow,bold"
    '';
  };
}
