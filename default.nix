{pkgs ? import <nixpkgs> {}}: let
  byName = ./pkgs/by-name;
  shard = s:
    builtins.mapAttrs (name: _: pkgs.callPackage (byName + "/${s}/${name}/package.nix") {})
    (builtins.readDir (byName + "/${s}"));
in
  builtins.foldl' (acc: s: acc // shard s) {}
  (builtins.attrNames (builtins.readDir byName))
