#!/usr/bin/env sh
# nwg-displays-adapter — Launch nwg-displays in an isolated XDG_CONFIG_HOME
# so it works even when ~/.config/hypr does not exist.
#
# nwg-displays hard-exits (sys.exit(1)) when running under Hyprland and
# ~/.config/hypr is missing. We work around this by creating a temporary
# staging directory under XDG_RUNTIME_DIR, seeding it with any existing
# config, and pointing XDG_CONFIG_HOME at it for the duration of the process.
#
# After nwg-displays exits, its monitors.conf is imported by argvus-config into
# the canonical /displays state, which argvus-config projects to monitors.lua.
# The parsing and the runtime are argvus-config's `display` command. No
# ~/.config/hypr is ever created on the real user config.
#
# Usage: nwg-displays-adapter.sh [--nwg-args...]
# shellcheck disable=SC1090,SC1091,SC2034,SC2329

set -u

: "${HOME:?HOME is not set}"

ARGVUS_SYSTEM_CONFIG="${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}"
ARGVUS_CONFIG_HOME="${ARGVUS_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}}"
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-$ARGVUS_SYSTEM_CONFIG/session/sh/bootstrap.sh}"

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
  have argvus || return 0
  argvus config display nwg-apply "$_conf" >/dev/null 2>&1 || true
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
  # The layout nwg-displays saved becomes the canonical /displays state, and
  # the running session follows it.
  if [ -f "$STAGING_HYPR/monitors.conf" ]; then
    argvus config display nwg-import "$STAGING_HYPR/monitors.conf" >/dev/null 2>&1 || true
    runtime_apply_monitors_conf "$STAGING_HYPR/monitors.conf"
  fi

  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$(argvus_tr display notification.title)" "$(argvus_tr display notification.layout_saved)" >/dev/null 2>&1 || true
  fi
fi

exit "$_status"
