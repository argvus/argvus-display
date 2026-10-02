---
title: Displays
description: Configure monitors and layouts.
---

`argvus-display` provides `argvus-displayctl` and integrates saved layouts with Hyprland. Inspect state with:

```sh
argvus-displayctl --status
argvus-displayctl --list-modes <monitor>
argvus-displayctl --apply
argvus-displayctl --settings
```

The helper also supports `--set <monitor> <key> <value>` and `--apply-nwg`. Generated monitor overrides are part of the ARGVUS configuration state; see [configuration files](../../reference/configuration-files/).

In the Control Center, open **Displays** or search for a monitor. The available settings are capability-dependent and can include resolution, refresh rate, scale, position, orientation, primary display, VRR and HDR. A setting is not shown as supported merely because the monitor model exists in a generic list; the active compositor and monitor backend must report it.

Applying a display layout changes the running Hyprland monitor configuration and saves the supported layout state for later sessions. Use the page's apply/revert flow when available. If a monitor becomes unusable, return to the display page or use `argvus-displayctl --apply` with the saved state rather than editing generated files.

## Command-line display management

Use `argvus-displayctl` to query and change display settings without the graphical interface:

```sh
# Show monitor status and names
argvus-displayctl --status

# List available modes for a monitor
argvus-displayctl --list-modes <monitor>

# Set a specific property
argvus-displayctl --set <monitor> scale 1.25
argvus-displayctl --set <monitor> dpi 120
argvus-displayctl --set <monitor> power off
argvus-displayctl --set <monitor> power on

# Apply saved layout
argvus-displayctl --apply

# Open the graphical display settings
argvus-displayctl --settings
```

Monitor names are shown by `--status` (typically `HDMI-1`, `DP-2`, `eDP-1` for laptops, etc.). After using `--settings` to make changes with the GUI, the session automatically reloads to apply them.
