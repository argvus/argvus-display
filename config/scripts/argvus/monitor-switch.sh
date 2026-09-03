#!/usr/bin/env sh
# monitor-switch - manage monitor layout, scale and power via hyprctl.
# Usage: monitor-switch.sh [--status|--list-modes <monitor>|--set <monitor> <key> <value>|--apply|--apply-nwg]
# Keys: scale, dpi, power (on/off)
# shellcheck disable=SC1090,SC1091,SC2034

set -u

: "${HOME:?HOME is not set}"

ARGVUS_SYSTEM_CONFIG="${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}"
ARGVUS_CONFIG_HOME="${ARGVUS_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}}"
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-$ARGVUS_SYSTEM_CONFIG/scripts/argvus/bootstrap.sh}"
ARGVUS_MUTABLE_CONFIG=1

if [ -r "$ARGVUS_BOOTSTRAP" ]; then
  . "$ARGVUS_BOOTSTRAP"
else
  paths_config() {
    _relative_path="$1"
    case "$_relative_path" in
      scripts/*|*/scripts/*|docs/*|*/docs/*)
        if [ -e "$ARGVUS_CONFIG_HOME/$_relative_path" ]; then
          printf '%s\n' "$ARGVUS_CONFIG_HOME/$_relative_path"
        elif [ -e "$ARGVUS_CONFIG_HOME/argvus/$_relative_path" ]; then
          printf '%s\n' "$ARGVUS_CONFIG_HOME/argvus/$_relative_path"
        else
          printf '%s\n' "$ARGVUS_SYSTEM_CONFIG/$_relative_path"
        fi
        ;;
      *)
        printf '%s\n' "$ARGVUS_CONFIG_HOME/argvus/$_relative_path"
        ;;
    esac
  }

  notify_send() {
    command -v notify-send >/dev/null 2>&1 || return 0
    notify-send "$1" "$2" >/dev/null 2>&1 || true
  }
fi

STATE_DIR="${ARGVUS_CONFIG_HOME}/argvus"
STATE_FILE="${ARGVUS_DISPLAY_STATE_FILE:-$STATE_DIR/.monitors}"
MONITORS_LUA="${ARGVUS_DISPLAY_MONITORS_LUA:-$(paths_config hypr/monitors.lua)}"
NWG_MONITORS_CONF="${ARGVUS_NWG_MONITORS_CONF:-$HOME/.config/hypr/monitors.conf}"

have() {
  command -v "$1" >/dev/null 2>&1
}

require_hyprctl() {
  have hyprctl || {
    printf 'hyprctl not found\n' >&2
    return 127
  }
}

require_python() {
  have python3 || have python || {
    printf 'python not found\n' >&2
    return 127
  }
}

python_cmd() {
  if have python3; then
    printf '%s\n' python3
  else
    printf '%s\n' python
  fi
}

monitor_exists() {
  _needle="$1"
  require_hyprctl || return $?
  require_python || return $?
  hyprctl monitors -j 2>/dev/null | "$(python_cmd)" -c '
import json
import sys

needle = sys.argv[1]
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(1)

sys.exit(0 if any(m.get("name") == needle for m in data) else 1)
' "$_needle"
}

print_status() {
  require_hyprctl || return $?
  require_python || return $?
  hyprctl monitors -j 2>/dev/null | "$(python_cmd)" -c '
import json
import sys

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

for m in data:
    name = m.get("name", "")
    res = "%dx%d@%d" % (m.get("width", 0), m.get("height", 0), m.get("refreshRate", 0))
    pos = "%d,%d" % (m.get("x", 0), m.get("y", 0))
    scale = m.get("scale", 1)
    dpi = m.get("dpi", 96)
    power = "off" if m.get("dpmsStatus", False) is False else "on"
    print("name=%s" % name)
    print("res=%s" % res)
    print("pos=%s" % pos)
    print("scale=%s" % scale)
    print("dpi=%s" % dpi)
    print("power=%s" % power)
'
}

is_number_in_range() {
  _value="$1"
  _min="$2"
  _max="$3"
  require_python || return $?
  "$(python_cmd)" -c '
import sys

try:
    value = float(sys.argv[1])
    lower = float(sys.argv[2])
    upper = float(sys.argv[3])
except Exception:
    sys.exit(1)

sys.exit(0 if lower <= value <= upper else 1)
' "$_value" "$_min" "$_max"
}

lua_string() {
  require_python || return $?
  "$(python_cmd)" -c '
import sys

value = sys.argv[1].replace("\\", "\\\\").replace("\"", "\\\"")
print("\"%s\"" % value)
' "$1"
}

set_key() {
  _monitor="$1"
  _key="$2"
  _value="$3"

  monitor_exists "$_monitor" || {
    printf 'Monitor not found: %s\n' "$_monitor" >&2
    return 1
  }

  case "$_key" in
    scale)
      is_number_in_range "$_value" 0.5 3.0 || {
        printf 'Invalid scale: %s (use 0.5-3.0)\n' "$_value" >&2
        return 1
      }
      hyprctl keyword monitor "$_monitor",preferred,auto,"$_value" >/dev/null 2>&1
      persist_setting "$_monitor" "scale" "$_value"
      write_lua
      ;;
    dpi)
      is_number_in_range "$_value" 32 300 || {
        printf 'Invalid dpi: %s (use 32-300)\n' "$_value" >&2
        return 1
      }
      hyprctl keyword monitor "$_monitor",preferred,auto,1,"$_value" >/dev/null 2>&1
      persist_setting "$_monitor" "dpi" "$_value"
      write_lua
      ;;
    power)
      case "$_value" in
        on|off) ;;
        *)
          printf 'Invalid power: %s (use on|off)\n' "$_value" >&2
          return 1
          ;;
      esac
      hyprctl dispatch dpms "$_value" "$_monitor" >/dev/null 2>&1
      persist_setting "$_monitor" "power" "$_value"
      ;;
    *)
      printf 'Invalid key: %s (scale|dpi|power)\n' "$_key" >&2
      return 1
      ;;
  esac

  printf 'Applied %s=%s on %s\n' "$_key" "$_value" "$_monitor"
}

persist_setting() {
  _monitor="$1"
  _key="$2"
  _value="$3"
  mkdir -p "$STATE_DIR"
  _tmp="${STATE_FILE}.tmp"
  rm -f "$_tmp"
  : > "$_tmp"

  if [ -f "$STATE_FILE" ]; then
    while IFS= read -r _line; do
      case "$_line" in
        "$_monitor.$_key="*) continue ;;
        *) printf '%s\n' "$_line" ;;
      esac
    done < "$STATE_FILE" > "$_tmp"
  fi

  printf '%s.%s=%s\n' "$_monitor" "$_key" "$_value" >> "$_tmp"
  mv "$_tmp" "$STATE_FILE"
}

write_lua() {
  _dir="${MONITORS_LUA%/*}"
  mkdir -p "$_dir"
  {
    printf '%s\n' '-- Generated by argvus-display/monitor-switch.sh -- persisted monitor settings.'
    printf '%s\n' '-- Loaded by ARGVUS Hyprland user override: ~/.config/argvus/hypr/monitors.lua.'
    [ -f "$STATE_FILE" ] &&
      while IFS= read -r _line; do
        [ -n "$_line" ] || continue
        _monitor="${_line%%.*}"
        _rest="${_line#*.}"
        _key="${_rest%%=*}"
        _val="${_rest#*=}"
        _lua_monitor="$(lua_string "$_monitor")" || continue
        case "$_key" in
          scale)
            is_number_in_range "$_val" 0.5 3.0 &&
              printf 'hl.monitor({ output = %s, scale = %s })\n' "$_lua_monitor" "$_val"
            ;;
          dpi)
            is_number_in_range "$_val" 32 300 &&
              printf 'hl.monitor({ output = %s, dpi = %s })\n' "$_lua_monitor" "$_val"
            ;;
        esac
      done < "$STATE_FILE"
    printf '%s\n' '-- End generated.'
  } > "$MONITORS_LUA"
}

apply_state() {
  [ -f "$STATE_FILE" ] || return 0

  write_lua

  while IFS= read -r _line; do
    [ -n "$_line" ] || continue
    _monitor="${_line%%.*}"
    _rest="${_line#*.}"
    _key="${_rest%%=*}"
    _val="${_rest#*=}"
    if [ "$_key" = "power" ] && [ "$_val" = "off" ]; then
      hyprctl dispatch dpms off "$_monitor" >/dev/null 2>&1 || true
    fi
  done < "$STATE_FILE"

  hyprctl reload >/dev/null 2>&1 || true
}

apply_session_prepare() {
  apply_state
  apply_nwg_conf
}

apply_nwg_conf() {
  [ -f "$NWG_MONITORS_CONF" ] || return 0
  require_hyprctl || return $?

  while IFS= read -r _line; do
    _line="$(printf '%s' "$_line" | sed 's/^[[:space:]]*//; s/#.*//')"
    [ -n "$_line" ] || continue
    case "$_line" in
      monitor=*)
        _arg="${_line#monitor=}"
        _arg="$(printf '%s' "$_arg" | sed 's/[[:space:]]*$//')"
        [ -n "$_arg" ] || continue
        hyprctl keyword monitor "$_arg" >/dev/null 2>&1 || true
        ;;
    esac
  done < "$NWG_MONITORS_CONF"

  notify_send "Displays" "Layout from nwg-displays applied" 2>/dev/null || true
}

open_settings() {
  have nwg-displays || {
    printf 'nwg-displays not found\n' >&2
    return 127
  }

  nwg-displays "$@"
  _status=$?

  if have argvus-sessionctl; then
    argvus-sessionctl reload >/dev/null 2>&1 || true
  else
    apply_nwg_conf || true
  fi

  return "$_status"
}

case "${1:-}" in
  --status)
    print_status
    ;;
  --list-modes)
    [ -n "${2:-}" ] || {
      printf 'Missing monitor\n' >&2
      exit 1
    }
    require_hyprctl || exit $?
    require_python || exit $?
    hyprctl monitors -j 2>/dev/null | "$(python_cmd)" -c '
import json
import sys

needle = sys.argv[1]
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

for m in data:
    if m.get("name") == needle:
        for mode in m.get("modes", []):
            w = mode.get("width")
            h = mode.get("height")
            r = mode.get("refreshRate")
            if w and h and r:
                print("%dx%d@%d" % (w, h, r))
        break
' "$2"
    ;;
  --set)
    [ -n "${2:-}" ] && [ -n "${3:-}" ] && [ -n "${4:-}" ] || {
      printf 'Missing monitor/key/value\n' >&2
      exit 1
    }
    set_key "$2" "$3" "$4"
    ;;
  --apply)
    apply_state
    ;;
  --session-prepare)
    apply_session_prepare
    ;;
  --apply-nwg|--session-reload)
    apply_nwg_conf
    ;;
  --settings)
    shift
    open_settings "$@"
    ;;
  *)
    printf 'Usage: monitor-switch.sh [--status|--list-modes <monitor>|--set <monitor> <key> <value>|--apply|--apply-nwg|--settings]\n' >&2
    printf 'Keys: scale (0.5-3.0), dpi (32-300), power (on|off)\n' >&2
    ;;
esac
