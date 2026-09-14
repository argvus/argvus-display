#!/usr/bin/env sh
# monitor-switch - manage monitor layout, scale and power via hyprctl.
# Usage: monitor-switch.sh [--status|--list-modes <monitor>|--set <monitor> <key> <value>|--apply|--apply-nwg]
# Keys: scale, dpi, power (on/off)
# shellcheck disable=SC1090,SC1091,SC2034

set -u

: "${HOME:?HOME is not set}"

ARGVUS_SYSTEM_CONFIG="${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}"
ARGVUS_CONFIG_HOME="${ARGVUS_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}}"
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-$ARGVUS_SYSTEM_CONFIG/session/sh/bootstrap.sh}"
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
GENERATED_DIR="${ARGVUS_CONFIG_HOME}/argvus/generated/hypr"
GENERATED_MONITORS_LUA="$GENERATED_DIR/monitors.lua"
NWG_ADAPTER="${ARGVUS_SYSTEM_CONFIG}/display/sh/nwg-displays-adapter.sh"

have() {
  command -v "$1" >/dev/null 2>&1
}

Nwg_parse="${Nwg_parse:-$ARGVUS_SYSTEM_CONFIG/display/sh/nwg-monitors-parse.sh}"
if [ -r "$Nwg_parse" ]; then
  . "$Nwg_parse"
fi

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
      is_number_in_range "$_value" 0.1 10 || {
        printf 'Invalid scale: %s (use 0.1-10)\n' "$_value" >&2
        return 1
      }
      hyprctl keyword monitor "$_monitor",preferred,auto,"$_value" >/dev/null 2>&1
      persist_setting "$_monitor" "scale" "$_value"
      write_lua
      ;;
    resolution)
      case "$_value" in
        [0-9]*x[0-9]*) ;;
        *)
          printf 'Invalid resolution: %s (use WxH, e.g. 1920x1080)\n' "$_value" >&2
          return 1
          ;;
      esac
      persist_setting "$_monitor" "resolution" "$_value"
      write_lua
      ;;
    refresh)
      is_number_in_range "$_value" 1 2000 || {
        printf 'Invalid refresh: %s (use 1-2000)\n' "$_value" >&2
        return 1
      }
      persist_setting "$_monitor" "refresh" "$_value"
      write_lua
      ;;
    position)
      case "$_value" in
        [0-9]*x[0-9]*) ;;
        *)
          printf 'Invalid position: %s (use XxY, e.g. 0x0)\n' "$_value" >&2
          return 1
          ;;
      esac
      persist_setting "$_monitor" "position" "$_value"
      write_lua
      ;;
    rotation)
      case "$_value" in
        0|90|180|270) ;;
        *)
          printf 'Invalid rotation: %s (use 0|90|180|270)\n' "$_value" >&2
          return 1
          ;;
      esac
      persist_setting "$_monitor" "rotation" "$_value"
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
      hyprctl dispatch "hl.dsp.dpms({ action = \"$_value\", monitor = \"$_monitor\" })" >/dev/null 2>&1
      persist_setting "$_monitor" "power" "$_value"
      ;;
    enabled)
      case "$_value" in
        true|false) ;;
        *)
          printf 'Invalid enabled: %s (use true|false)\n' "$_value" >&2
          return 1
          ;;
      esac
      persist_setting "$_monitor" "enabled" "$_value"
      write_lua
      ;;
    *)
      printf 'Invalid key: %s (scale|resolution|refresh|position|rotation|power|enabled)\n' "$_key" >&2
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
  mkdir -p "$GENERATED_DIR"
  {
    printf '%s\n' '-- Generated by argvus-display/monitor-switch.sh'
    printf '%s\n' '-- Loaded by /usr/share/argvus/hyprland/config/hyprland.lua'
    [ -f "$STATE_FILE" ] || {
      printf '%s\n' '-- No monitor state. Defaults apply.'
      printf '%s\n' '-- End generated.'
      return 0
    }
    awk -F. '{print $1}' "$STATE_FILE" | sort -u | while IFS= read -r _monitor; do
      [ -n "$_monitor" ] || continue
      _fields=""
      _disabled=""
      while IFS= read -r _line; do
        case "$_line" in
          "$_monitor".*) ;;
          *) continue ;;
        esac
        _rest="${_line#*.}"
        _key="${_rest%%=*}"
        _val="${_rest#*=}"
        case "$_key" in
          scale)
            is_number_in_range "$_val" 0.1 10 && _fields="$_fields, scale = $_val"
            ;;
          refresh)
            : # refresh folded into mode=WxH@R below
            ;;
          position)
            _fields="$_fields, position = \"$_val\""
            ;;
          rotation)
            case "$_val" in
              90) _tc=1 ;;
              180) _tc=2 ;;
              270) _tc=3 ;;
              *) _tc=0 ;;
            esac
            [ "$_tc" != "0" ] && _fields="$_fields, transform = $_tc"
            ;;
          enabled)
            [ "$_val" = "false" ] && _disabled=", disabled = true"
            ;;
          mirror)
            _fields="$_fields, mirror = \"$_val\""
            ;;
          bitdepth)
            _fields="$_fields, bitdepth = $_val"
            ;;
        esac
      done < "$STATE_FILE"

      _mode_val=""
      while IFS= read -r _line; do
        case "$_line" in
          "$_monitor".resolution=*)
            _mode_val="${_line#*.resolution=}"
            ;;
          "$_monitor".refresh=*)
            [ -n "$_mode_val" ] && _mode_val="${_mode_val}@${_line#*.refresh=}"
            ;;
        esac
      done < "$STATE_FILE"
      [ -n "$_mode_val" ] && _fields=", mode = \"$_mode_val\"$_fields"

      printf 'hl.monitor({ output = "%s"%s })\n' "$_monitor" "$_fields${_disabled}"
    done
    printf '%s\n' '-- End generated.'
  } > "$GENERATED_MONITORS_LUA"
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
      hyprctl dispatch "hl.dsp.dpms({ action = \"off\", monitor = \"$_monitor\" })" >/dev/null 2>&1 || true
    elif [ "$_key" = "enabled" ] && [ "$_val" = "false" ]; then
      hyprctl keyword monitor "$_monitor",disabled >/dev/null 2>&1 || true
    fi
  done < "$STATE_FILE"

  hyprctl reload >/dev/null 2>&1 || true
}

migrate_nwg_state() {
  _legacy_monitors="$HOME/.config/hypr/monitors.conf"
  [ -f "$_legacy_monitors" ] || return 0
  [ -s "$STATE_FILE" ] && return 0

  mkdir -p "$STATE_DIR"
  _tmp_state_nwg="${STATE_FILE}.nwg.migration"
  : > "$_tmp_state_nwg"

  if [ -r "$Nwg_parse" ]; then
    parse_nwg_monitors_conf "$_legacy_monitors" "$_tmp_state_nwg"
  else
    # Fallback: conservative best-effort if the shared parser is unavailable.
    while IFS= read -r _line; do
      _line="$(printf '%s' "$_line" | sed 's/^[[:space:]]*//; s/#.*//')"
      [ -n "$_line" ] || continue
      case "$_line" in
        monitor=*)
          _arg="${_line#monitor=}"
          _arg="$(printf '%s' "$_arg" | sed 's/[[:space:]]*$//')"
          _output="$(printf '%s' "$_arg" | cut -d',' -f1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
          _args="$(printf '%s' "$_arg" | cut -d',' -f2-)"
          _mode="$(printf '%s' "$_args" | cut -d',' -f1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
          case "$_mode" in
            disable|disabled)
              printf '%s.enabled=false\n' "$_output" >> "$_tmp_state_nwg"
              ;;
          esac
          _pos="$(printf '%s' "$_args" | cut -d',' -f2 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
          _scale="$(printf '%s' "$_args" | cut -d',' -f3 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
          _transform="$(printf '%s' "$_args" | cut -d',' -f4 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
          case "$_mode" in
            disable|disabled) ;;
            preferred|auto) ;;
            *)
              _w="$(printf '%s' "$_mode" | cut -d'x' -f1)"
              _h="$(printf '%s' "$_mode" | cut -d'x' -f2- | cut -d'@' -f1)"
              _r="$(printf '%s' "$_mode" | cut -d'@' -f2- | sed 's/Hz$//')"
              [ -n "$_w" ] && [ -n "$_h" ] && \
                printf '%s.resolution=%sx%s\n' "$_output" "$_w" "$_h" >> "$_tmp_state_nwg"
              [ -n "$_r" ] && printf '%s.refresh=%s\n' "$_output" "$_r" >> "$_tmp_state_nwg"
              ;;
          esac
          [ -n "$_pos" ] && [ "$_pos" != "auto" ] && [ "$_pos" != "0x0" ] && \
            printf '%s.position=%s\n' "$_output" "$_pos" >> "$_tmp_state_nwg"
          [ -n "$_scale" ] && printf '%s.scale=%s\n' "$_output" "$_scale" >> "$_tmp_state_nwg"
          [ -n "$_transform" ] && [ "$_transform" != "0" ] && [ "$_transform" != "normal" ] && {
            case "$_transform" in
              1|90)   printf '%s.rotation=90\n'  "$_output" >> "$_tmp_state_nwg" ;;
              2|180)  printf '%s.rotation=180\n' "$_output" >> "$_tmp_state_nwg" ;;
              3|270)  printf '%s.rotation=270\n' "$_output" >> "$_tmp_state_nwg" ;;
            esac
          }
          ;;
      esac
    done < "$_legacy_monitors"
  fi

  if [ -s "$_tmp_state_nwg" ]; then
    mv "$_tmp_state_nwg" "$STATE_FILE"
    write_lua
    notify_send "Displays" "Migrated nwg-displays config to ARGVUS" 2>/dev/null || true
  else
    rm -f "$_tmp_state_nwg"
  fi
}

apply_session_prepare() {
  apply_state
}

apply_nwg_conf() {
  _legacy_monitors="$HOME/.config/hypr/monitors.conf"
  [ -f "$_legacy_monitors" ] || return 0
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
  done < "$_legacy_monitors"

  notify_send "Displays" "Legacy layout from nwg-displays applied" 2>/dev/null || true
}

open_settings() {
  if [ -x "$NWG_ADAPTER" ]; then
    sh "$NWG_ADAPTER" "$@"
    return $?
  fi

  have nwg-displays || {
    printf 'nwg-displays not found\n' >&2
    return 127
  }

  nwg-displays "$@"
  _status=$?

  if [ -f "$HOME/.config/hypr/monitors.conf" ]; then
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
  --apply-nwg)
    apply_nwg_conf
    ;;
  --session-reload)
    apply_state
    ;;
  --migrate-nwg)
    migrate_nwg_state
    ;;
  --settings)
    shift
    open_settings "$@"
    ;;
  *)
    printf 'Usage: monitor-switch.sh [--status|--list-modes <monitor>|--set <monitor> <key> <value>|--apply|--session-prepare|--session-reload|--settings]\n' >&2
    printf 'Keys: scale (0.1-10), resolution (WxH), refresh (Hz), position (XxY), rotation (0|90|180|270), power (on|off)\n' >&2
    ;;
esac
