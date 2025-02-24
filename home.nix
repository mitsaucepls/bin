{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "coder";
  home.homeDirectory = "/home/coder";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    neovim
    tmux
    fzf
    jq
    helm
    gnupg
    lua
    ripgrep
    unzip
    zip
    python3
    gcc
    xclip
    wget
    curl
    gzip
    bash
    zsh
    nodejs
    wget
    go
    openssl

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  programs.zsh.enable = true;
  programs.zsh.initExtra = ''
    # Source your custom configuration
    if [ -f ~/.zshrc-custom ]; then
      source ~/.zshrc-custom
    fi
  '';

  # Clone git repositories on activation.
  # This activation hook creates a "projects" directory in your home
  # directory and clones the repo if it does not already exist.
  home.activation.cloneRepos = ''
    if [ ! -d ${config.home.homeDirectory}/.config/tmux ]; then
      /usr/bin/git clone https://github.com/mitsaucepls/tmux.git ${config.home.homeDirectory}/.config/tmux
    fi
    if [ ! -d ${config.home.homeDirectory}/.config/nvim ]; then
      /usr/bin/git clone https://github.com/mitsaucepls/nvim.git ${config.home.homeDirectory}/.config/nvim
    fi
    if [ ! -d ${config.home.homeDirectory}/.config/bin ]; then
      /usr/bin/git clone https://github.com/mitsaucepls/bin.git ${config.home.homeDirectory}/.config/bin
    fi
  '';

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file.".bash_profile".text = ''
    #!/bin/sh
    # If not already in zsh, execute it
    if [ -z "$ZSH_VERSION" ]; then
      exec ${pkgs.zsh}/bin/zsh -l
    fi
  '';

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
