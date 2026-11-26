# nur-packages

Nix packages that aren't in nixpkgs (yet).

| Package | What it is |
|---|---|
| `agon-compression` | TurboVega-style file compressor/decompressor for Agon |
| `ez80asm` | eZ80 assembler from the Agon platform |
| `fab-agon-emulator` | Emulator for the Agon Light, Light 2 and Console8 |
| `herdr-auto-title`, `herdr-navigator`, `herdr-radar`, `herdr-worktreeinclude-local` | herdr plugins; `$out` is the plugin root |
| `agentrun` | Control plane around agent harnesses |
| `ai-beacon` | Dashboard for AI coding agents across devices (upstream binaries) |
| `foot-terminfo` | foot's terminfo, for hosts without foot (e.g. macOS) |
| `romarr` | The *arr for games. Pass `withUnfreeRar = true` for 7-Zip's unfree RAR codecs instead of unar |

## Using it

As a flake input, with the overlay, so the packages build against your
nixpkgs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur-packages.url = "github:coat/nur-packages";
    nur-packages.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {nixpkgs, nur-packages, ...}: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [nur-packages.overlays.default];
    };
  in {
    devShells.x86_64-linux.default = pkgs.mkShell {
      packages = [pkgs.ez80asm pkgs.fab-agon-emulator];
    };
  };
}
```

The only input is nixpkgs. Without flakes: `nix-build -A ez80asm`, or
`import ./overlay.nix` as an overlay.

## Layout

Packages live in `pkgs/by-name/<first two letters>/<name>/package.nix`, the
same layout as nixpkgs' `pkgs/by-name`, and `default.nix` discovers them.
Adding a package means adding a directory; nothing else has to be listed.

## CI

`.github/workflows/build.yml`, from the NUR template, evaluates the repo the
way NUR does (restricted eval) and builds every free package against
nixpkgs-unstable, nixos-unstable and nixos-26.05. To cache builds, create a
Cachix cache, set `cachixName` and add `CACHIX_AUTH_TOKEN` as a repo secret.
After the repo is registered in NUR's `repos.json`, set `nurRepo` so CI
tells NUR about each push.
