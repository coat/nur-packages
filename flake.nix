{
  description = "coat's NUR repository";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    inherit (nixpkgs) lib;
    forAllSystems = f:
      lib.genAttrs ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"] (system:
        f (import nixpkgs {
          inherit system;
          # romarr needs the unfree _7zz-rar.
          config.allowUnfree = true;
        }));
  in {
    overlays.default = import ./overlay.nix;

    legacyPackages = forAllSystems (pkgs: import ./default.nix {inherit pkgs;});

    # Only packages whose meta.platforms include the system, so `nix flake
    # check` doesn't trip over Linux-only packages on darwin.
    packages = forAllSystems (pkgs:
      lib.filterAttrs (_: lib.meta.availableOn pkgs.stdenv.hostPlatform)
      self.legacyPackages.${pkgs.stdenv.hostPlatform.system});

    formatter = forAllSystems (pkgs: pkgs.alejandra);
  };
}
