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
      pkgs = pkgs;
      lib = pkgs.lib;
      vim = vim.packages.${system}.default;
      inherit inputs system;
    };
    zsh = pkgs.writeShellScriptBin "zsh" ''
      ZDOTDIR=${zshConf} ${pkgs.zsh}/bin/zsh
    '';
  in {
    packages = {
      x86_64-linux = rec {
        inherit zsh;
        default = zsh;
      };
    };
  };
}
