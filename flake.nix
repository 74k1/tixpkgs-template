{
  description = "packages & modules for myself";

  nixConfig = {
    extra-substituters = [ "https://tixpkgs.cachix.org" ];
    extra-trusted-public-keys = [ "tixpkgs.cachix.org-1:Q52x6PMD7ZuTC7oRihwp5lP9YaEaYtrfxYkwzEpjSRI=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = lib.genAttrs systems;

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          config.allowUnfree = true;
        };

      mkPackages = import ./modules/flake/packages.nix { inherit lib; };
      mkModules = import ./modules/flake/modules.nix { inherit self inputs lib; };

      nixosModules = mkModules ./modules/nixos;
      homeManagerModules = mkModules ./modules/home-manager;
    in
    {
      packages = forAllSystems (system: mkPackages (pkgsFor system));

      overlays.default = final: prev: mkPackages final;

      nixosModules = nixosModules.flat;
      nixosModules' = nixosModules.nested;
      homeManagerModules = homeManagerModules.flat;
      homeManagerModules' = homeManagerModules.nested;

      # Module tests only run on the platform the modules/packages target.
      checks.x86_64-linux = import ./modules/flake/checks.nix {
        inherit self inputs lib;
        system = "x86_64-linux";
        pkgs = pkgsFor "x86_64-linux";
      };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rs);
    };
}
