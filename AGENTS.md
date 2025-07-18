# AGENTS.md - Nix Configuration Repository

## Build Commands
- **Build NixOS**: `sudo nixos-rebuild switch --flake .#<hostname>` (e.g., `sudo nixos-rebuild switch --flake .#framework`)
- **Build Home Manager**: `home-manager switch --flake .#<config>` (e.g., `home-manager switch --flake .#linux-x86`)
- **Check flake**: `nix flake check`

## Code Style Guidelines
- **Nix**: 2-space indentation, no trailing whitespace, use `with pkgs;` for package lists
- **Lua**: 2-space indentation, snake_case for variables, use `vim.keymap.set` over `vim.api.nvim_set_keymap`
- **Shell scripts**: Use `#!/bin/bash`, quote variables, use `read -p` for prompts
- **Imports**: Group by type (nixpkgs, home-manager, custom modules), alphabetize within groups
- **Naming**: kebab-case for hostnames/configs, snake_case for scripts, camelCase for Lua functions
- **Error handling**: Use `set -e` in bash scripts, check for required tools/paths

## Repository Structure
- `flake.nix`: Main entry point defining nixosConfigurations and homeConfigurations
- `nixos/`: NixOS system configurations per machine
- `home/`: Home Manager configurations and dotfiles
- `home/scripts/`: Custom shell scripts packaged as derivations
