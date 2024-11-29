{
  description = "Nix packages build with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    clj-nix = {
      url = "github:jlesquembre/clj-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, clj-nix, ... }@inputs:

    let
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      eachSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs
          {
            inherit system;
            overlays = [ ];
          };
        inherit system;
      });
    in
    {
      packages = eachSystem ({ pkgs, system }:
        let
          mkBabashkaDerivation = clj-nix.outputs.packages.${system}.babashkaEnv {
            inherit system pkgs;
            bb-pkgs = self.outputs.packages.${system};
          };
        in
        {

          hello = mkBabashkaDerivation {
            pkg = ./pkgs/hello;
          };
          hello-override = mkBabashkaDerivation {
            pkg = ./pkgs/hello;
            override = ./pkgs/hello_override;
          };
          simple = mkBabashkaDerivation {
            pkg = ./pkgs/simple;
          };

        });

    };
}
