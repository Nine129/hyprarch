#!/bin/bash
# ── Volume/Brightness notification script ────────────────
# Replaces swayosd-client with direct tool + notify-send
# Usage: osd-notify.sh <action> <subaction> [value]
#
# Actions:
#   volume  raise | lower | mute-toggle | set <pct>
#   source  raise | lower | mute-toggle
#   brightness  raise | lower | set <pct>

set -euo pipefail

STEP=5
MAX_VOL=1.5        # 1.0 = 100%, 1.5 = 150% overamplification

# ── helpers ──────────────────────────────────────────────

get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ \
        | awk '{vol=$2; mut=$3; printf "%.0f %s", vol*100, mut}'
}

get_source_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SOURCE@ \
        | awk '{vol=$2; mut=$3; printf "%.0f %s", vol*100, mut}'
}

get_brightness() {
    local cur max
    cur=$(brightnessctl get)
    max=$(brightnessctl max)
    echo $(( cur * 100 / max ))
}

# ── notifiers ────────────────────────────────────────────

notify_volume() {
    local pct muted pct_text
    read -r pct muted <<< "$(get_volume)"
    if [ "$muted" = "[MUTED]" ]; then
        pct_text="<span font_size='15pt' weight='bold' color='#ff2d55'>MUTED</span>"
    else
        pct_text="<span font_size='15pt' weight='bold'>${pct}%</span>"
    fi
    notify-send -a "Volume" "VOLUME" "$pct_text" \
        -h string:synchronous:volume -t 1000
}

notify_source() {
    local pct muted pct_text
    read -r pct muted <<< "$(get_source_volume)"
    if [ "$muted" = "[MUTED]" ]; then
        pct_text="<span font_size='15pt' weight='bold' color='#ff2d55'>MUTED</span>"
    else
        pct_text="<span font_size='15pt' weight='bold'>${pct}%</span>"
    fi
    notify-send -a "Mic" "MIC" "$pct_text" \
        -h string:synchronous:mic -t 1000
}

notify_brightness() {
    local pct pct_text
    pct=$(get_brightness)
    pct_text="<span font_size='15pt' weight='bold'>${pct}%</span>"
    notify-send -a "Brightness" "BRIGHTNESS" "$pct_text" \
        -h string:synchronous:brightness -t 1000
}

case "${1:-help}" in
    volume)
        case "${2:-}" in
            raise)        wpctl set-volume -l "$MAX_VOL" @DEFAULT_AUDIO_SINK@ "${STEP}%+";  notify_volume ;;
            lower)        wpctl set-volume @DEFAULT_AUDIO_SINK@ "${STEP}%-";  notify_volume ;;
            mute-toggle)  wpctl set-mute  @DEFAULT_AUDIO_SINK@ toggle;       notify_volume ;;
            set)          wpctl set-volume -l "$MAX_VOL" @DEFAULT_AUDIO_SINK@ "${3:-50}%";  notify_volume ;;
            *)            echo "Usage: $0 volume [raise|lower|mute-toggle|set <pct>]"; exit 1 ;;
        esac
        ;;
    source)
        case "${2:-}" in
            raise)        wpctl set-volume @DEFAULT_AUDIO_SOURCE@ "${STEP}%+"; notify_source ;;
            lower)        wpctl set-volume @DEFAULT_AUDIO_SOURCE@ "${STEP}%-"; notify_source ;;
            mute-toggle)  wpctl set-mute  @DEFAULT_AUDIO_SOURCE@ toggle;      notify_source ;;
            *)            echo "Usage: $0 source [raise|lower|mute-toggle]"; exit 1 ;;
        esac
        ;;
    brightness)
        case "${2:-}" in
            raise)  brightnessctl set "${STEP}%+";  notify_brightness ;;
            lower)  brightnessctl set "${STEP}%-";  notify_brightness ;;
            set)    brightnessctl set "${3:-50}%";  notify_brightness ;;
            *)      echo "Usage: $0 brightness [raise|lower|set <pct>]"; exit 1 ;;
        esac
        ;;
    help|*)
        echo "Usage: $0 <action> <subaction> [value]"
        echo ""
        echo "Actions:"
        echo "  volume       raise|lower|mute-toggle|set <pct>"
        echo "  source       raise|lower|mute-toggle"
        echo "  brightness   raise|lower|set <pct>"
        exit 0
        ;;
esac
