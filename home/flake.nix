{
  description = "Home Manager configuration of ubuntu";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zsh-fzf_tab = {
      url = "github:aloxaf/fzf-tab";
      flake = false;
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, home-manager, zsh-fzf_tab, ... } @ inputs:
  let
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
      ];
  in {
    homeConfigurations = {
      "aws-ubuntu" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          zsh-fzf_tab = zsh-fzf_tab;
        };
        modules = [ 
        {
          nixpkgs.overlays = overlays;
          }
          ./aws-ubuntu.nix
          ./home.nix 
        ];
      };
    };
    homeConfigurations = {
      "linux-basic" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          zsh-fzf_tab = zsh-fzf_tab;
        };
        modules = [ 
        {
          nixpkgs.overlays = overlays;
          }
 
          ./linux-x86.nix
          ./home.nix 
        ];
      };
    };
    homeConfigurations = {
      "linux-x86" = home-manager.lib.homeManagerConfiguration {
pkgs = import nixpkgs { system = "x86_64-linux"; config = { allowUnfree = true;}; };
        extraSpecialArgs = {
          zsh-fzf_tab = zsh-fzf_tab;
        };
        modules = [ 
        {
          nixpkgs.overlays = overlays;
          }
 
          ./linux-x86.nix
          ./home.nix 
          ./linux-gui.nix
        ];
      };
    };
    homeConfigurations = {
      "rpi-deck" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = {
          zsh-fzf_tab = zsh-fzf_tab;
        };
       modules = [ 
        {
          nixpkgs.overlays = overlays;
          }
 
          ./rpi-deck.nix
          ./home.nix 
        ];
      };
    };
    homeConfigurations = {
      "work-mac" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {
          zsh-fzf_tab = zsh-fzf_tab;
        };
 
        modules = [ 
        {
          nixpkgs.overlays = overlays;
          }
          ./work-mac.nix
          ./home.nix 
        ];
      };
    };
  };
}
