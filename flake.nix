{
  description = "dwm flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = nixpkgs.lib.genAttrs systems;

      overlayList = [ self.overlays.default ];

      pkgsBySystem = forEachSystem (
        system:
        import nixpkgs {
          inherit system;
          overlays = overlayList;
        }
      );

    in
    {

      overlays.default = (
        final: prev: {
          stPatched = prev.st.overrideAttrs (oldAttrs: {
            version = "master";
            src = ./.;
          });
        }
      );
      packages = forEachSystem (system: {
        stPatched = pkgsBySystem.${system}.stPatched;
        default = pkgsBySystem.${system}.stPatched;
      });

      nixosModules.overlays = overlayList;

    };
}
