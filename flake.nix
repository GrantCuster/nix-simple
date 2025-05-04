{
  description = "Nix os and home manager config";

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
 };

  outputs = { self, nixpkgs, home-manager, zsh-fzf_tab, ... } @ inputs:
{
    nixosConfigurations = {
	    "mele" = nixpkgs.lib.nixosSystem {
	      specialArgs = {inherit inputs;};
	      modules = [
		./nixos/skybax.nix
		./nixos/configuration.nix
	      ];
	    };

	    "gram" = nixpkgs.lib.nixosSystem {
	      specialArgs = {inherit inputs;};
	      modules = [
		./nixos/bix.nix
		./nixos/configuration.nix
	      ];
	    };

	    "nuc" = nixpkgs.lib.nixosSystem {
	      specialArgs = {inherit inputs;};
	      modules = [
		./nixos/brokenhorn.nix
		./nixos/configuration.nix
	      ];
	    };


	    "bosgame" = nixpkgs.lib.nixosSystem {
	      specialArgs = {inherit inputs;};
	      modules = [
		./nixos/bosgame.nix
		./nixos/configuration.nix
		./nixos/jellyfin.nix
	      ];
	    };

    };
 
    homeConfigurations = {
      "aws-ubuntu" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          zsh-fzf_tab = zsh-fzf_tab;
        };
        modules = [ 
         ./home/aws-ubuntu.nix
          ./home/home.nix 
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

          ./home/linux-x86.nix
          ./home/home.nix 
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
          ./home/linux-x86.nix
          ./home/home.nix 
          ./home/linux-gui.nix
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

          ./home/rpi-deck.nix
          ./home/home.nix 
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
         ./home/work-mac.nix
          ./home/home.nix 
        ];
      };
    };
  };
}
