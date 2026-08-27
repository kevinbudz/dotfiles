#!/usr/bin/env bash
# Reports battery and network state for the SDDM greeter (key=value lines).

has_battery=0
battery_percent=0

for ps in /sys/class/power_supply/BAT* /sys/class/power_supply/battery; do
    [ -d "$ps" ] || continue
    type=$(cat "$ps/type" 2>/dev/null || true)
    [ "$type" = "Battery" ] || continue
    has_battery=1
    cap=$(cat "$ps/capacity" 2>/dev/null || true)
    if [ -n "$cap" ] && [ "$cap" -ge 0 ] 2>/dev/null; then
        battery_percent=$cap
    fi
    break
done

network=none

# Prefer an active wired connection (type 1 = ethernet).
for iface in /sys/class/net/*; do
    [ -d "$iface" ] || continue
    name=$(basename "$iface")
    [ "$name" = "lo" ] && continue

    type=$(cat "$iface/type" 2>/dev/null || true)
    state=$(cat "$iface/operstate" 2>/dev/null || true)
    [ "$type" = "1" ] || continue
    [ "$state" = "up" ] || continue

    if [ -f "$iface/carrier" ]; then
        carrier=$(cat "$iface/carrier" 2>/dev/null || echo 0)
        [ "$carrier" = "1" ] || continue
    fi

    network=ethernet
    break
done

# Fall back to wireless (802.11 interfaces use type 801 on Linux).
if [ "$network" = "none" ]; then
    for iface in /sys/class/net/*; do
        [ -d "$iface" ] || continue
        name=$(basename "$iface")
        [ "$name" = "lo" ] && continue

        type=$(cat "$iface/type" 2>/dev/null || true)
        state=$(cat "$iface/operstate" 2>/dev/null || true)
        [ "$type" = "801" ] || continue
        [ "$state" = "up" ] || continue

        network=wifi
        break
    done
fi

printf 'has_battery=%s\n' "$has_battery"
printf 'battery_percent=%s\n' "$battery_percent"
printf 'network=%s\n' "$network"
