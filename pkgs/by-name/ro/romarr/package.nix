{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  python3,
  libarchive,
  unar,
  _7zz-rar,
  withUnfreeRar ? false,
}:
stdenv.mkDerivation rec {
  pname = "romarr";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "BlizzHacker";
    repo = "romarr";
    rev = "v${version}";
    hash = "sha256-clFCA99p+fiq2GH/KvStNavP1BOl/BP6ylBVNdoX+1g=";
  };

  nativeBuildInputs = [makeWrapper];

  installPhase = let
    # requests is ROMarr's one hard dependency (stdlib otherwise; playwright,
    # cryptography, rom_hub and pyseccomp are all optional lazy imports). The
    # buildEnv from `withPackages` symlinks requests and its transitive deps
    # into a single site-packages tree.
    py = python3.withPackages (ps: [ps.requests]);
  in ''
    runHook preInstall
    mkdir -p "$out/lib"
    cp -r romarr "$out/lib/romarr"

    # Bake the version: romarr/version.py reads romarr/_version.py (exactly
    # what the upstream Dockerfile does) so the update check reports a real
    # number instead of "unknown".
    printf '__version__ = "%s"\n' "${version}" > "$out/lib/romarr/_version.py"

    # bsdtar (libarchive) reads 7z/rar/zip but only one RAR volume at a time.
    # For RAR, romarr/library.py::rar_tools prefers a `7zz` whose `7zz i`
    # lists the Rar2/Rar3/Rar5 codecs, then falls back to `unar` + `lsar`;
    # both read split sets. nixpkgs' plain `_7zz` has only the Rar5 format,
    # not the decoders; `_7zz-rar` (unfree unRAR licence) has them, matching
    # the official 7-Zip build the upstream Dockerfile installs. unar (LGPL)
    # is what upstream's browser image ships.
    makeWrapper "${py}/bin/python" "$out/bin/romarr" \
      --set PYTHONPATH "$out/lib:${py}/${python3.sitePackages}" \
      --set PYTHONDONTWRITEBYTECODE 1 \
      --prefix PATH : "${lib.makeBinPath [
      libarchive
      (
        if withUnfreeRar
        then _7zz-rar
        else unar
      )
    ]}" \
      --add-flags "-m romarr"
    runHook postInstall
  '';

  meta = with lib; {
    description = "The *arr for games: find, verify and organize your game library";
    homepage = "https://github.com/BlizzHacker/romarr";
    license = licenses.mit;
    mainProgram = "romarr";
    platforms = platforms.linux;
  };
}
