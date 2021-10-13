{
  description = "My custom nix package collection";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; };

  outputs = { self, nixpkgs }:

    {
      packages.x86_64-linux =
        import ./pkgs { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
      packages.x86_64-darwin =
        import ./pkgs { pkgs = nixpkgs.legacyPackages.x86_64-darwin; };
    };
}
