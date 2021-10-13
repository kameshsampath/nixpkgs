{
  description = "My custom nix package collection";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    packages.x86_64-linux.kameshsampath =
      (import ./pkgs) { inherit (self) pkgs; };
    packages.x86_64-darwin.kameshsampath =
      (import ./pkgs) { inherit (self) pkgs; };
  };
}
