{
  description = "A flake for my home configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    nvim-config.url = "github:mitsaucepls/nvim";
    nvim-config.flake = false;

    tmux-config.url = "github:mitsaucepls/tmux";
    tmux-config.flake = false;

    bin-config.url = "github:mitsaucepls/bin";
    bin-config.flake = false;
  };
  # Outputs function: Defines what your flake provides. This includes packages,
  # home-manager configurations, and default packages.
  outputs = { self, nixpkgs, flake-utils, nvim-config, tmux-config, bin-config, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Import nixpkgs for the current system (e.g., x86_64-linux)
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Define Nix packages provided by the flake.
        packages = {
          myConfigs = pkgs.runCommandNoCC "my-configs" {} ''
            # Create directories to store configurations for nvim, tmux, and binaries.
            mkdir -p $out/nvim $out/tmux $out/bin

            # Copy the entire contents of each repository to the respective directories.
            cp -r ${nvim-config}/* $out/nvim
            cp -r ${tmux-config}/* $out/tmux
            cp -r ${bin-config}/* $out/bin
          '';
        };

        # Define home-manager configurations, used to manage user environment and dotfiles.
        homeConfigurations = {
          my-user = pkgs.home-manager.lib.homeManagerConfiguration {
            system = system;
            modules = [
              ({ config, pkgs, ... }: {
                # Define which packages to include in the user's environment.
                home.packages = with pkgs; [
                  neovim
                  tmux
                  fzf
                  jq
                  helm
                  gpg
                  lua
                  rg
                  unzip
                  zip
                  python3
                  gcc
                  xclip
                  wget
                  curl
                  gzip
                  tar
                  bash
                  zsh
                  nodejs
                ];

                # Set zsh as the default shell
                programs.zsh.enable = true;
                programs.zsh.zshrcExtra = ''
                  source ${self.packages.${system}.myConfigs}/bin/.zshrc
                '';

                # Map configuration files to the appropriate locations in the user's home directory.
                home.file = {
                  ".config/nvim".source = "${self.packages.${system}.myConfigs}/nvim";
                  ".config/bin".source = "${self.packages.${system}.myConfigs}/bin";
                  ".config/tmux".source = "${self.packages.${system}.myConfigs}/tmux";
                  ".zshrc".source = "${self.packages.${system}.myConfigs}/bin/.zshrc";
                };
              })
            ];
          };
        };

        # Specify the default package when no specific package is requested.
        defaultPackage = self.packages.${system}.myConfigs;
      }
    );
}
