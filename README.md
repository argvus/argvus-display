# argvus-display

Display and monitor integration for the ARGVUS desktop.

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
