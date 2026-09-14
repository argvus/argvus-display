# shellcheck shell=sh
# Shared parser for nwg-displays monitors.conf -> ARGVUS monitor state.
#
# This is sourced by both nwg-displays-adapter.sh and monitor-switch.sh so the
# two always agree on how nwg-displays' output is converted into the
# single-source ~/.config/argvus/.monitors state file.
#
# nwg-displays writes (settings_applier.py):
#   monitor=NAME,WxH@refresh,XxY,scale
#   monitor=NAME,disable                      (disabled monitor)
#   monitor=NAME,transform,CODE               (rotation, on its own line)
#   monitor=NAME,preferred,auto               (mode fallback)
#   ...optionally suffix ",mirror,OTHER" and/or ",bitdepth,10"
#
# Usage: parse_nwg_monitors_conf <input_conf> <output_state>
# The output state is written append-style; callers should truncate first.

parse_nwg_monitors_conf() {
  _src_conf="$1"
  _out_state="$2"
  [ -f "$_src_conf" ] || return 0

  while IFS= read -r _line || [ -n "$_line" ]; do
    _line="$(printf '%s' "$_line" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    case "$_line" in
      ''|\#*) continue ;;
    esac

    case "$_line" in
      monitor=*)
        _arg="${_line#monitor=}"
        ;;
      "monitor = "*)
        _arg="${_line#monitor = }"
        ;;
      *) continue ;;
    esac

    _output="$(printf '%s' "$_arg" | cut -d',' -f1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    _args="$(printf '%s' "$_arg" | cut -d',' -f2-)"
    [ -n "$_output" ] || continue

    case "$_args" in
      disable|disabled)
        printf '%s.enabled=false\n' "$_output" >> "$_out_state"
        continue
        ;;
    esac

    case "$_args" in
      transform,*)
        _tcode="$(printf '%s' "$_args" | cut -d',' -f2 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
        case "$_tcode" in
          0|normal)           printf '%s.rotation=0\n'   "$_output" >> "$_out_state" ;;
          1|90)               printf '%s.rotation=90\n'  "$_output" >> "$_out_state" ;;
          2|180)              printf '%s.rotation=180\n' "$_output" >> "$_out_state" ;;
          3|270)              printf '%s.rotation=270\n' "$_output" >> "$_out_state" ;;
        esac
        continue
        ;;
    esac

    # Extra flags carried on their own line(s): mirror / bitdepth.
    case "$_args" in
      mirror,*)
        _mirror="$(printf '%s' "$_args" | cut -d',' -f2 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
        [ -n "$_mirror" ] && printf '%s.mirror=%s\n' "$_output" "$_mirror" >> "$_out_state"
        continue
        ;;
    esac
    case "$_args" in
      bitdepth,10)
        printf '%s.bitdepth=10\n' "$_output" >> "$_out_state"
        continue
        ;;
    esac

    _mode="$(printf '%s' "$_args" | cut -d',' -f1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    _pos="$(printf '%s' "$_args"  | cut -d',' -f2 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    _scale="$(printf '%s' "$_args" | cut -d',' -f3 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    # Inline transform sometimes also appears as the 4th field.
    _inline_t="$(printf '%s' "$_args" | cut -d',' -f4 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

    case "$_mode" in
      disable|disabled|preferred|auto)
        case "$_mode" in
          disable|disabled)
            printf '%s.enabled=false\n' "$_output" >> "$_out_state"
            ;;
        esac
        ;;
      *)
        _w="$(printf '%s' "$_mode" | cut -d'x' -f1)"
        _rest_mode="$(printf '%s' "$_mode" | cut -d'x' -f2-)"
        _h="$(printf '%s' "$_rest_mode" | cut -d'@' -f1)"
        _r="$(printf '%s' "$_rest_mode" | cut -d'@' -f2- | sed 's/Hz$//')"
        [ -n "$_w" ] && [ -n "$_h" ] && {
          printf '%s.resolution=%sx%s\n' "$_output" "$_w" "$_h" >> "$_out_state"
        }
        [ -n "$_r" ] && printf '%s.refresh=%s\n' "$_output" "$_r" >> "$_out_state"
        ;;
    esac

    [ -n "$_pos" ] && [ "$_pos" != "auto" ] && [ "$_pos" != "0x0" ] && {
      printf '%s.position=%s\n' "$_output" "$_pos" >> "$_out_state"
    }

    [ -n "$_scale" ] && printf '%s.scale=%s\n' "$_output" "$_scale" >> "$_out_state"

    [ -n "$_inline_t" ] && [ "$_inline_t" != "0" ] && [ "$_inline_t" != "normal" ] && {
      case "$_inline_t" in
        1|90)  printf '%s.rotation=90\n'  "$_output" >> "$_out_state" ;;
        2|180) printf '%s.rotation=180\n' "$_output" >> "$_out_state" ;;
        3|270) printf '%s.rotation=270\n' "$_output" >> "$_out_state" ;;
      esac
    }
  done < "$_src_conf"
}
