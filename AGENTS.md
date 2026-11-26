# AGENTS.md

Guide for coding agents working in this repo. Claude Code reads it via
`@AGENTS.md` in `CLAUDE.md`. Procedures live in `.agents/skills/` (symlinked
as `.claude/skills/`).

## Layout

- `pkgs/by-name/<shard>/<name>/package.nix`: one package each, laid out like
  nixpkgs' `pkgs/by-name` (`<shard>` is the first two letters of the name).
  `default.nix` discovers them; there is no index to update.
- `default.nix` is the NUR entry point and must not import `<nixpkgs>` itself.
  `overlay.nix` and the flake's `overlays.default` wrap it.
- The main consumer is `~/projects/nix-config` (github:coat/nix-config),
  which takes `overlays.default` through its `nur-packages` input. Config-only
  packages (e.g. `pair-invite`) stay in nix-config's `pkgs/`.

## Rules

- Write packages the way nixpkgs wants them, since they are meant to be
  upstreamed: callPackage arguments only, no flake inputs, no
  `<nixpkgs>`, no unfree dependencies by default (put them behind an option,
  as romarr's `withUnfreeRar` does). NUR evaluates without `allowUnfree`, and
  a package that throws drops out of NUR silently.
- `git add -N` new files before any `nix eval`/`nix build`; flakes only see
  tracked files.
- Comments describe what the code does when that isn't obvious (a
  workaround, an upstream quirk). The reasoning behind a choice goes in the
  commit message.
- Build-verify before saying something works.

## Commands

```sh
nix flake check                     # evaluates every package (current system)
nix fmt .                           # alejandra
nix build .#<pkg>
# NUR's restricted evaluation, as in .github/workflows/build.yml:
nix-env -f . -qa '*' --drv-path --option restrict-eval true \
  -I nixpkgs="$(nix flake archive --json | jq -r .inputs.nixpkgs.path)" -I "$PWD"
```

Check a change against nix-config without pushing:

```sh
cd ~/projects/nix-config
nix flake check --no-write-lock-file --override-input nur-packages "path:$HOME/projects/nur-packages"
```

## Procedures (skills)

- Update / audit packages (incl. herdr plugins) → `.agents/skills/updating-packages/SKILL.md`
