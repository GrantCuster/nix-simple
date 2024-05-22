{
  description = "Home Manager configuration of ubuntu";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
  {
    homeConfigurations = {
      "aws-ubuntu" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ 
          ./aws-ubuntu.nix
          ./home.nix 
        ];
      };
    };
    homeConfigurations = {
      "linux-x86" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
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
        modules = [ 
          ./rpi-deck.nix
          ./home.nix 
        ];
      };
    };
    homeConfigurations = {
      "work-mac" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ 
          ./work-mac.nix
          ./home.nix 
        ];
      };
    };
  };
}
