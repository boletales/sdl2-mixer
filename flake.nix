{
  description = "sdl2-mixer";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    lint-utils.url = "git+https://gitlab.homotopic.tech/nix/lint-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    haskellNix.url = "github:input-output-hk/haskell.nix";
  };
  outputs = { self, nixpkgs, flake-utils, lint-utils, haskellNix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        deferPluginErrors = true;
        overlays = [
          haskellNix.overlay
          (final: prev: {
            sdl2-mixer =
              final.haskell-nix.project' {
                src = ./.;
                compiler-nix-name = "ghc922";
                projectFileName = "stack.yaml";
                modules = [{
                  reinstallableLibGhc = true;
                }];
              };
          })
        ];
        pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
        flake = pkgs.sdl2-mixer.flake { };
      in
      flake // {
        defaultPackage = flake.packages."sdl2-mixer:lib:sdl2-mixer";
        checks = {
          hlint = lint-utils.linters.${system}.hlint ./.;
          hpack = lint-utils.linters.${system}.hpack ./.;
          stylish-haskell = lint-utils.linters.${system}.stylish-haskell ./.;
        };
      });
}
