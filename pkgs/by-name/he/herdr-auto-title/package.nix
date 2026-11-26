{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "herdr-auto-title";
  version = "0.25.0";

  meta = with lib; {
    description = "Herdr plugin that automatically generates contextual tab titles";
    homepage = "https://github.com/kryptamine/herdr-auto-title";
    license = licenses.mit;
    platforms = platforms.unix;
  };

  src = fetchFromGitHub {
    owner = "kryptamine";
    repo = "herdr-auto-title";
    rev = "v${version}";
    hash = "sha256-PCvFaDeQa96C+nB40kKdWOjvvRRSV9JyR4gAmGfG560=";
  };

  vendorHash = "sha256-UfIpYaA2eIRl29fhi7ESEoHEsyiXmEZ4MO78T0Q6OCs=";

  subPackages = ["cmd/herdr-auto-title"];

  # Herdr runs `[[startup]]` commands with plugin_root as cwd, so the manifest
  # and binary must live side by side, exactly as `herdr plugin install` lays
  # them out. $out is the plugin_root.
  postInstall = ''
    mv "$out/bin/herdr-auto-title" "$out/herdr-auto-title"
    rmdir "$out/bin"
    cp "$src/herdr-plugin.toml" "$out/herdr-plugin.toml"
  '';

  # Consumed by users/features/herdr.nix to generate herdr's plugins.json.
  passthru.herdrPlugin = {
    id = "herdr.auto-title";
    name = "Auto Title";
  };
}
