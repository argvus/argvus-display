# argvus-display

Display and monitor integration for the ARGVUS desktop.

[![CI](https://github.com/argvus/argvus-display/actions/workflows/ci.yml/badge.svg)](https://github.com/argvus/argvus-display/actions/workflows/ci.yml)
[![Release](https://github.com/argvus/argvus-display/actions/workflows/release.yml/badge.svg)](https://github.com/argvus/argvus-display/actions/workflows/release.yml)

This package owns:

- `argvus displayctl`, the public display control command.
- `argvus-displayctl` maps the older flags to the `argvus config display` command (`argvus config display status|list-modes|set|apply|apply-nwg|migrate-nwg`). The nwg-displays editor (`--settings`) stays a shell adapter.
- Legacy monitor state in `~/.config/argvus/data/.monitors`, read only to migrate an installation that predates `/displays`. It is no longer written.
- Canonical monitor layout in `/displays` of `config.json`. `argvus-config` projects the Hyprland overrides in `~/.config/argvus/data/generated/hypr/monitors.lua` from it; this package does not write that file.
- Runtime application of `nwg-displays` output from `~/.config/hypr/monitors.conf`.

The session manager remains the runtime owner. Current `argvus sessionctl prepare`
and `argvus sessionctl reload` flows reach this package through
`argvus config session-prepare` and `argvus config session-reload-config`:

- prepare: `argvus displayctl --session-prepare`
- reload: `argvus displayctl --session-reload`

For direct use:

```sh
argvus displayctl --status
argvus displayctl --set eDP-1 scale 1.25
argvus displayctl --set eDP-1 dpi 120
argvus displayctl --set eDP-1 power off
argvus displayctl --settings
```

`--settings` launches `nwg-displays`; after it exits, display state is reapplied
through `argvus sessionctl reload` when available.

## Build and install

On Arch Linux or a compatible distribution:

```sh
make validate
make build
make install
```

`make build` creates the source archive in `build/artifacts/` and the package
in `build/dist/`. See [packaging/arch/README.md](packaging/arch/README.md) for
local and release packaging details.

## Documentation

- [DEVELOPMENT.md](DEVELOPMENT.md) — layout, checks, and releases
- [CONTRIBUTING.md](https://github.com/argvus/.github/blob/main/CONTRIBUTING.md) — contribution workflow
- [SECURITY.md](https://github.com/argvus/.github/blob/main/SECURITY.md) — private vulnerability reports
- [Code of Conduct](https://github.com/argvus/.github/blob/main/policies/CODE_OF_CONDUCT.md) — community standards
- [AI usage policy](https://github.com/argvus/.github/blob/main/policies/IA_USAGE.md) — rules for AI-assisted contributions

## License

SPDX: `GPL-3.0-only`. See [LICENSE](LICENSE).
