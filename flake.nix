{
  description = "My customized zsh executable";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    atuinToFc = {
      url = "github:mbish/atuin-to-fc";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    zsh-notify = {
      url = "github:marzocchi/zsh-notify";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    systems = ["x86_64-linux" "armv7l-linux" "aarch64-linux"];
    build = system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
        ];
      };
      zsh-notify = pkgs.stdenv.mkDerivation {
        name = "zsh-notify";
        src = inputs.zsh-notify;
        nativeBuildInputs = [pkgs.zsh pkgs.xdotool pkgs.wmctrl];
        installPhase = ''
          mkdir -p $out/share/zsh-notify
          cp -r $src/* $out/share/zsh-notify
        '';
      };
      zshConf = import ./zsh.nix {
        inherit pkgs inputs system;
        inherit (pkgs) lib;
        inherit zsh-notify;
        extraConfig = pkgs.lib.strings.concatStrings [
          (import ./atuin.nix {
            inherit (pkgs) lib;
            inherit pkgs system inputs;
          })
        ];
      };
      zshMinimal = import ./zsh.nix {
        inherit pkgs inputs system;
        inherit (pkgs) lib;
      };

      mkZsh = config:
        pkgs.stdenv.mkDerivation {
          name = "zsh-custom";

          nativeBuildInputs = [pkgs.makeWrapper];
          phases = ["installPhase"];
          installPhase = ''
            mkdir -p $out/share
            mkdir -p $out/bin
            cp ${config}/.zshrc $out/share/.zshrc
            ln -s $out/share/.zshrc $out/share/zshrc
            cp ${pkgs.zsh}/bin/zsh $out/bin
            wrapProgram $out/bin/zsh \
              --set LOCALE_ARCHIVE ${pkgs.glibcLocales}/lib/locale/locale-archive \
              --set ZDOTDIR $out/share
          '';
        };
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
