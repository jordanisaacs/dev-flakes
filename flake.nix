{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
    in
    {
      # For 15-150, functional programming
      func_prog = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [ rlwrap smlnj ];
      };

      # For 15-213, computer systems
      comp_sys = pkgs.mkShell {
        nativeBuildInputs = [ pkgs.gnumake pkgs.bear pkgs.clang ];
      };

      # RStudio with tex wrapper for econometrics
      apps."x86_64-linux".econ_rstudio = {
        type = "app";
        program =
          let
            # Wrap the rstudioWrapper with tex and pandoc included in runtime path
            rstudioTexWrapper = pkgs.runCommand "rstudioTexWrapper"
              {
                buildInputs = [ pkgs.makeWrapper ];
              }
              (
                ''
                  mkdir -p $out/bin
                  makeWrapper ${pkgs.rstudioWrapper.override {
                    packages = with (pkgs.rPackages); [ markdown tidyverse ];
                  }}/bin/rstudio $out/bin/rstudio --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.texlive.combined.scheme-full pkgs.pandoc]}
                ''
              );
          in
          "${rstudioTexWrapper}/bin/rstudio";
      };
    };
}




