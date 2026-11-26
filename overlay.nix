# Adds this repo's packages at the top level of pkgs, built against the
# consumer's nixpkgs.
final: _prev: import ./default.nix {pkgs = final;}
