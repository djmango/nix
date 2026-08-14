{ pkgs, ... }:
let
  # Prefer Nix over Homebrew /usr/bin. fish_add_path is a no-op when a dir is
  # already on PATH, so drop then prepend explicitly.
  preferNixPath = ''
    for _nixbin in ${pkgs.ruby_3_3}/bin ${pkgs.nodejs_24}/bin $HOME/.nix-profile/bin /nix/var/nix/profiles/default/bin
      set -gx PATH $_nixbin (string match -v -- $_nixbin $PATH)
    end
    set -e _nixbin
  '';
  # Append so Nix bun stays ahead of the leftover ~/.bun/bin/bun binary.
  bunGlobalBin = ''
    fish_add_path -aP $HOME/.bun/bin
  '';
in
{
  programs.fish = {
    enable = true;

    # Runs for interactive and non-interactive fish (scripts, Cursor terminals).
    shellInit = ''
      source '/nix/var/nix/profiles/default/etc/profile.d/nix.fish'
      ${preferNixPath}
      ${bunGlobalBin}
    '';

    interactiveShellInit = ''
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

      set -gx PATH $HOME/.npm-global/bin $HOME/.local/bin $HOME/.cargo/bin $HOME/.bun/bin $PATH

      # Ruby: use the Home Manager toolchain and neutralize leaked rvm/system gem
      # env (rvm sourced from ~/.bash_profile pollutes GEM_HOME while /usr/bin's
      # Ruby 2.6 shadows it on PATH). Keep gems in a writable per-user dir.
      set -e GEM_PATH RUBY_VERSION MY_RUBY_HOME IRBRC GEM_ROOT rvm_ruby_string rvm_ruby_file rvm_path rvm_bin_path
      set -gx GEM_HOME $HOME/.gem
      fish_add_path -p ${pkgs.ruby_3_3}/bin $HOME/.gem/bin

      # brew shellenv prepends Homebrew; put Nix back in front.
      ${preferNixPath}
      ${bunGlobalBin}

      fish_vi_key_bindings
      bind -M insert \t accept-autosuggestion or complete
      # Option+h / Option+H: kill back one word (vim b) / WORD (vim B)
      bind -M insert \eh backward-kill-word
      bind -M insert \eH backward-kill-bigword
      # Option+l / Option+L: accept one autosuggestion word (vim w) / whole suggestion
      bind -M insert \el forward-word
      bind -M insert \eL accept-autosuggestion
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
