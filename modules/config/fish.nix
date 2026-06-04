{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      source '/nix/var/nix/profiles/default/etc/profile.d/nix.fish'

      ${pkgs.starship}/bin/starship init fish | source
      
      set fish_greeting "Welcome home, $USER"
      
      # Source fish.local if it exists
      if test -f ~/.config/fish/fish.local
        source ~/.config/fish/fish.local
      end
      
      # On darwin, and if homebrew is installed, setup homebrew path
      if test (uname) = "Darwin"
        if test -d /opt/homebrew/bin
          eval "$(/opt/homebrew/bin/brew shellenv)"
        end
      end

      # Prefer the Home Manager Node/npm toolchain over Homebrew.
      fish_add_path -p ${pkgs.nodejs_25}/bin
      
      set -gx PATH $HOME/.npm-global/bin $HOME/.local/bin $HOME/.cargo/bin $PATH

      # Ruby: use the Home Manager toolchain and neutralize leaked rvm/system gem
      # env (rvm sourced from ~/.bash_profile pollutes GEM_HOME while /usr/bin's
      # Ruby 2.6 shadows it on PATH). Keep gems in a writable per-user dir.
      set -e GEM_PATH RUBY_VERSION MY_RUBY_HOME IRBRC GEM_ROOT rvm_ruby_string rvm_ruby_file rvm_path rvm_bin_path
      set -gx GEM_HOME $HOME/.gem
      fish_add_path -p ${pkgs.ruby_3_3}/bin $HOME/.gem/bin

      fish_vi_key_bindings
      bind -M insert \t accept-autosuggestion or complete
      bind -M insert \el accept-autosuggestion
      bind -M insert \e\; complete
      bind \cx\ce edit_command_buffer
      bind -M insert \cx\ce edit_command_buffer
      bind -M default \cx\ce edit_command_buffer
      
      alias npkg "nix search nixpkgs"
      alias gw "gh repo view -w"
      alias x "explorer"
      alias k "kubectl"
      alias ls "eza"
      alias p "pnpm"
    '';

    plugins = [
      { name = "bass"; src = pkgs.fishPlugins.bass; }
    ];
  };

  # Install required packages for fish
  home.packages = with pkgs; [
    nerd-fonts.meslo-lg
    fishPlugins.bass
  ];
}
