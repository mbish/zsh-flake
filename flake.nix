{
  description = "My customized zsh executable";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    vim = {
      url = "github:mbish/neovim-flake";
      flake = true;
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    atuinToFc = {
      url = "github:mbish/atuin-to-fc";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    st = {
      url = "github:mbish/st-flake";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    vim,
    st,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
      ];
    };
    zshConf = import ./zsh.nix {
      inherit pkgs inputs system;
      inherit (pkgs) lib;
      vim = vim.packages.${system}.default;
    };
    zshMinimal = import ./zsh.nix {
      inherit pkgs inputs system;
      inherit (pkgs) lib vim;
    };

    mkZsh = conf:
      pkgs.writeShellScriptBin "zsh" ''
        ZDOTDIR=${conf} ${pkgs.zsh}/bin/zsh
      '';
  in {
    packages = {
      x86_64-linux = rec {
        zsh = mkZsh zshConf;
        default = zsh;
        minimal = mkZsh zshMinimal;
      };
    };
  };
}
