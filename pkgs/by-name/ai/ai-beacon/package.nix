{
  lib,
  stdenvNoCC,
  fetchurl,
}: let
  # Upstream publishes no source, only binaries on the rolling `snapshot`
  # pre-release. Every upstream build replaces those assets in place, so these
  # hashes break whenever it rebuilds: bump version + hashes from
  #   gh api repos/manusa/ai-beacon/releases --jq '.[].assets[] | .name+" "+.digest'
  # and `ai-beacon version` on the new binary.
  hashes = {
    x86_64-linux = "sha256-6ZlUQiXRDTOhqEirnlkKmu2oDpjiwmpBnZZz2K6Nuno=";
    aarch64-linux = "sha256-M/2KZj4MIws4YajzezqsTqFrmSYNnuVoZQyxrqZUqnY=";
    x86_64-darwin = "sha256-CEcoyBX+THN1g8A6d49J7eOqv+WL4UHk9+y3XabAROI=";
    aarch64-darwin = "sha256-e6d75gRANATWnjLe4G+KpFhnwF7RypJgoyU64htBuF8=";
  };
  platform = stdenvNoCC.hostPlatform;
  goos = platform.parsed.kernel.name;
  goarch =
    if platform.isx86_64
    then "amd64"
    else "arm64";
in
  stdenvNoCC.mkDerivation {
    pname = "ai-beacon";
    version = "0.0.0-snapshot.20261126163312";

    src = fetchurl {
      url = "https://github.com/manusa/ai-beacon/releases/download/snapshot/ai-beacon-${goos}-${goarch}";
      hash = hashes.${platform.system};
    };

    dontUnpack = true;

    # Only a download and a copy, so there is nothing worth caching. ci.nix
    # also skips preferLocalBuild packages, which keeps the scheduled CI run
    # from failing every time upstream replaces the snapshot assets.
    preferLocalBuild = true;

    # Go binaries: static on Linux, only system frameworks on darwin.
    installPhase = ''
      runHook preInstall
      install -Dm755 "$src" "$out/bin/ai-beacon"
      runHook postInstall
    '';

    meta = with lib; {
      description = "Web dashboard for monitoring and orchestrating AI coding agents across devices";
      homepage = "https://github.com/manusa/ai-beacon";
      license = licenses.asl20;
      sourceProvenance = [sourceTypes.binaryNativeCode];
      mainProgram = "ai-beacon";
      platforms = builtins.attrNames hashes;
    };
  }
