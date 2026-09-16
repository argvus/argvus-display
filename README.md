# argvus-display

Display and monitor integration for the ARGVUS desktop.

[![CI](https://github.com/argvus/argvus-display/actions/workflows/ci.yml/badge.svg)](https://github.com/argvus/argvus-display/actions/workflows/ci.yml)
[![Release](https://github.com/argvus/argvus-display/actions/workflows/release.yml/badge.svg)](https://github.com/argvus/argvus-display/actions/workflows/release.yml)

This package owns:

- `argvus-displayctl`, the public display control command.
- `/usr/share/argvus/display/sh/monitor-switch.sh`, the compatibility path used by the current ARGVUS shell and session preparation scripts.
- Persisted monitor scale/DPI/power state in `~/.config/argvus/.monitors`.
- Generated Hyprland monitor overrides in `~/.config/argvus/hypr/monitors.lua`.
- Runtime application of `nwg-displays` output from `~/.config/hypr/monitors.conf`.

The session manager remains the runtime owner. Current `argvus-sessionctl prepare`
and `argvus-sessionctl reload` flows reach this package through the existing
`hypr-init.sh` calls in the ARGVUS configuration package:

- prepare: `argvus-displayctl --session-prepare`
- reload: `argvus-displayctl --session-reload`

For direct use:

```sh
argvus-displayctl --status
argvus-displayctl --set eDP-1 scale 1.25
argvus-displayctl --set eDP-1 dpi 120
argvus-displayctl --set eDP-1 power off
argvus-displayctl --settings
```

`--settings` launches `nwg-displays`; after it exits, display state is reapplied
through `argvus-sessionctl reload` when available.

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
- [CONTRIBUTING.md](CONTRIBUTING.md) — contribution workflow
- [SECURITY.md](SECURITY.md) — private vulnerability reports

## License

SPDX: `GPL-3.0-only`. See [LICENSE](LICENSE).
