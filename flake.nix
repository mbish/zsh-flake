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
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = {
    self,
    vim,
    st,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    systems = ["x86_64-linux" "armv7l-linux"];
    build = system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
        ];
      };
      zshConf = import ./zsh.nix {
        inherit pkgs inputs system;
        inherit (pkgs) lib;
        vim = vim.packages.${system}.default;
        browser = "${pkgs.firefox}/bin/firefox";
        extraConfig = pkgs.lib.strings.concatStrings [
          (import ./atuin.nix {
            inherit (pkgs) lib;
            inherit pkgs system inputs;
          })
          (import ./term.nix {
            inherit (pkgs) lib;
            inherit system inputs;
          })
        ];
      };
      zshMinimal = import ./zsh.nix {
        inherit pkgs inputs system;
        inherit (pkgs) lib vim;
        browser = "${pkgs.qutebrowser}/bin/qutebrowser";
      };

      mkZsh = conf:
        pkgs.writeShellScriptBin "zsh" ''
          ZDOTDIR=${conf} ${pkgs.zsh}/bin/zsh
        '';
    in {
      packages = rec {
        zsh = mkZsh zshConf;
        default = zsh;
        minimal = mkZsh zshMinimal;
      };
    };
  in
    flake-utils.lib.eachSystem systems build;
}
