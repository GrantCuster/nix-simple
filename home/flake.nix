{
  description = "Home Manager configuration of ubuntu";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zsh-fzf_tab = {
      url = "github:aloxaf/fzf-tab";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, zsh-fzf_tab, ... } @ inputs:
  {
    homeConfigurations = {
      "aws-ubuntu" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          zsh-fzf_tab = zsh-fzf_tab;
        };
        modules = [ 
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
          ./linux-x86.nix
          ./home.nix 
        ];
      };
    };
    homeConfigurations = {
      "linux-x86" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          zsh-fzf_tab = zsh-fzf_tab;
        };
        modules = [ 
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
          ./work-mac.nix
          ./home.nix 
        ];
      };
    };
  };
}
