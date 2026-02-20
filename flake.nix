{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    hashcards-upstream = {
      url = "github:eudoxia0/hashcards/v0.2.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      hashcards-upstream,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        katex = pkgs.fetchzip {
          url = "https://github.com/KaTeX/KaTeX/releases/download/v0.16.27/katex.zip";
          hash = "sha256-Ydjf9shRmFc8ZzmgzG7no155QXNysksh4ayaJpgXELQ=";
        };
        hashcards = hashcards-upstream.packages.${system}.default.overrideAttrs {
          preBuild = ''
            mkdir -p vendor/katex
            cp -r ${katex}/* vendor/katex/
          '';
        };
      in
      {
        devShells.default = pkgs.mkShell {

          packages = [
            # formatters/linters
            pkgs.nixfmt-rfc-style
            pkgs.prettierd

            # other
            pkgs.pre-commit
            hashcards
          ];
        };
      }
    );
}
