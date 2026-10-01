#!/usr/bin/env sh
# nwg-displays-adapter — Launch nwg-displays in an isolated XDG_CONFIG_HOME
# so it works even when ~/.config/hypr does not exist.
#
# nwg-displays hard-exits (sys.exit(1)) when running under Hyprland and
# ~/.config/hypr is missing. We work around this by creating a temporary
# staging directory under XDG_RUNTIME_DIR, seeding it with any existing
# config, and pointing XDG_CONFIG_HOME at it for the duration of the process.
#
# After nwg-displays exits we absorb its output: monitors.conf is parsed into
# ARGVUS monitor state (~/.config/argvus/data/.monitors, the single source) and the
# generated monitors.lua is regenerated from that state. No ~/.config/hypr is
# ever created on the real user config.
#
# Usage: nwg-displays-adapter.sh [--nwg-args...]
# shellcheck disable=SC1090,SC1091,SC2034,SC2329

set -u

: "${HOME:?HOME is not set}"

ARGVUS_SYSTEM_CONFIG="${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}"
ARGVUS_CONFIG_HOME="${ARGVUS_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}}"
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-$ARGVUS_SYSTEM_CONFIG/session/sh/bootstrap.sh}"

STATE_DIR="${ARGVUS_CONFIG_HOME}/argvus/data"
STATE_FILE="${ARGVUS_DISPLAY_STATE_FILE:-$STATE_DIR/.monitors}"
GENERATED_DIR="${ARGVUS_CONFIG_HOME}/argvus/data/generated/hypr"
GENERATED_MONITORS_LUA="$GENERATED_DIR/monitors.lua"

if [ -r "$ARGVUS_BOOTSTRAP" ]; then
  . "$ARGVUS_BOOTSTRAP"
fi
# shellcheck source=/usr/share/argvus/lib/i18n.sh
. /usr/share/argvus/lib/i18n.sh

log_info() { printf '[nwg-displays-adapter] %s\n' "$1"; }
log_error() { printf '[nwg-displays-adapter] ERROR: %s\n' "$1" >&2; }

have() {
  command -v "$1" >/dev/null 2>&1
}

runtime_apply_monitors_conf() {
  _conf="$1"
  [ -f "$_conf" ] || return 0
  have hyprctl || return 0

  while IFS= read -r _line || [ -n "$_line" ]; do
    _line="$(printf '%s' "$_line" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/#.*//')"
    [ -n "$_line" ] || continue

    case "$_line" in
      monitor=*) _arg="${_line#monitor=}" ;;
      "monitor = "*) _arg="${_line#monitor = }" ;;
      *) continue ;;
    esac

    _arg="$(printf '%s' "$_arg" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    [ -n "$_arg" ] || continue
    hyprctl keyword monitor "$_arg" >/dev/null 2>&1 || true
  done < "$_conf"
}

monitors_conf_fingerprint() {
  _conf="$1"
  [ -f "$_conf" ] || {
    printf 'missing\n'
    return 0
  }

  if command -v cksum >/dev/null 2>&1; then
    cksum "$_conf" 2>/dev/null || printf 'unreadable\n'
  else
    wc -c "$_conf" 2>/dev/null || printf 'unreadable\n'
  fi
}

watch_staged_monitors() {
  _conf="$1"
  _last=""

  while [ -d "$STAGING_HYPR" ]; do
    _current="$(monitors_conf_fingerprint "$_conf")"
    if [ "$_current" != "$_last" ]; then
      _last="$_current"
      runtime_apply_monitors_conf "$_conf"
    fi
    sleep 1
  done
}

have nwg-displays || {
  log_error "$(argvus_tr display error.nwg_missing)"
  exit 127
}

Nwg_parse="${Nwg_parse:-$ARGVUS_SYSTEM_CONFIG/display/sh/nwg-monitors-parse.sh}"
if [ -r "$Nwg_parse" ]; then
  . "$Nwg_parse"
else
  log_error "$(argvus_tr display error.parser_missing parser="$Nwg_parse")"
  exit 127
fi

STAGING="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/argvus-nwg-displays"
STAGING_HYPR="$STAGING/hypr"
WATCH_PID=""

cleanup() {
  if [ -n "$WATCH_PID" ]; then
    kill "$WATCH_PID" >/dev/null 2>&1 || true
    wait "$WATCH_PID" 2>/dev/null || true
  fi
  rm -rf "$STAGING"
}

trap cleanup EXIT INT TERM

rm -rf "$STAGING"
mkdir -p "$STAGING_HYPR"

EXISTING_MONITORS="$ARGVUS_CONFIG_HOME/hypr/monitors.conf"
EXISTING_WORKSPACES="$ARGVUS_CONFIG_HOME/hypr/workspaces.conf"

[ -f "$EXISTING_MONITORS" ] && cp "$EXISTING_MONITORS" "$STAGING_HYPR/monitors.conf"
[ -f "$EXISTING_WORKSPACES" ] && cp "$EXISTING_WORKSPACES" "$STAGING_HYPR/workspaces.conf"

SAVED_XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-}"
export XDG_CONFIG_HOME="$STAGING"
# nwg-displays reads workspace assignment by default; keep the session value.
export ARGVUS_DISPLAY_LUA_OK=1

log_info "$(argvus_tr display adapter.launching config="$STAGING")"
watch_staged_monitors "$STAGING_HYPR/monitors.conf" &
WATCH_PID="$!"
nwg-displays "$@"
_status=$?

kill "$WATCH_PID" >/dev/null 2>&1 || true
wait "$WATCH_PID" 2>/dev/null || true
WATCH_PID=""

if [ -n "$SAVED_XDG_CONFIG_HOME" ]; then
  export XDG_CONFIG_HOME="$SAVED_XDG_CONFIG_HOME"
else
  unset XDG_CONFIG_HOME
fi

if [ "$_status" -eq 0 ]; then
  # Parse nwg-displays monitors.conf into ARGVUS monitor state, then
  # regenerate the generated monitors.lua from that state (single source).
  if [ -f "$STAGING_HYPR/monitors.conf" ]; then
    mkdir -p "$STATE_DIR"
    _tmp_state="${STATE_FILE}.nwg.tmp"
    : > "$_tmp_state"

    parse_nwg_monitors_conf "$STAGING_HYPR/monitors.conf" "$_tmp_state"

    if [ -s "$_tmp_state" ]; then
      if [ -s "$STATE_FILE" ]; then
        : > "${STATE_FILE}.nwg.merged"
        while IFS= read -r _existing; do
          [ -n "$_existing" ] || continue
          _e_monitor="${_existing%%.*}"
          _e_rest="${_existing#*.}"
          _e_key="${_e_rest%%=*}"
          _dupe=0
          while IFS= read -r _new; do
            [ -n "$_new" ] || continue
            _n_monitor="${_new%%.*}"
            _n_rest="${_new#*.}"
            _n_key="${_n_rest%%=*}"
            if [ "$_e_monitor" = "$_n_monitor" ] && [ "$_e_key" = "$_n_key" ]; then
              _dupe=1
              break
            fi
          done < "$_tmp_state"
          [ "$_dupe" -eq 0 ] && printf '%s\n' "$_existing" >> "${STATE_FILE}.nwg.merged"
        done < "$STATE_FILE"
        cat "$_tmp_state" >> "${STATE_FILE}.nwg.merged"
        mv "${STATE_FILE}.nwg.merged" "$STATE_FILE"
      else
        mv "$_tmp_state" "$STATE_FILE"
      fi
    else
      rm -f "$_tmp_state"
    fi
  fi

  # Regenerate the generated monitors.lua from the single-source ARGVUS state.
  if [ -s "$STATE_FILE" ]; then
    mkdir -p "$GENERATED_DIR"
    {
      printf '%s\n' '-- Generated by argvus-display/nwg-displays-adapter.sh'
      printf '%s\n' '-- Loaded by /usr/share/argvus/hyprland/config/hyprland.lua'
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
            scale)   _fields="$_fields, scale = $_val" ;;
            refresh) : ;; # folded into mode=WxH@R below
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
            mirror)   _fields="$_fields, mirror = \"$_val\"" ;;
            bitdepth) _fields="$_fields, bitdepth = $_val" ;;
          esac
        done < "$STATE_FILE"
        _mode_val=""
        while IFS= read -r _line; do
          case "$_line" in
            "$_monitor".resolution=*) _mode_val="${_line#*.resolution=}" ;;
            "$_monitor".refresh=*) [ -n "$_mode_val" ] && _mode_val="${_mode_val}@${_line#*.refresh=}" ;;
          esac
        done < "$STATE_FILE"
        [ -n "$_mode_val" ] && _fields=", mode = \"$_mode_val\"$_fields"
        printf 'hl.monitor({ output = "%s"%s })\n' "$_monitor" "$_fields${_disabled}"
      done
      printf '%s\n' '-- End generated.'
    } > "$GENERATED_MONITORS_LUA"
    log_info "$(argvus_tr display adapter.generated path="$GENERATED_MONITORS_LUA")"
  fi

  runtime_apply_monitors_conf "$STAGING_HYPR/monitors.conf"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$(argvus_tr display notification.title)" "$(argvus_tr display notification.layout_saved)" >/dev/null 2>&1 || true
  fi
fi

exit "$_status"
