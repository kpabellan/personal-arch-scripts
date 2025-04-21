#!/bin/bash
set -e

# Define paths
WAL_COLORS="$HOME/.cache/wal/colors"
BTOP_THEME_PATH="$HOME/.config/btop/themes/wallpaper-theme.theme"
WAL_ROFI_COLORS="$HOME/.cache/wal/colors-rofi-dark.rasi"
ROFI_THEME_PATH="$HOME/.config/rofi/wallpaper-theme.rasi"
WALLPAPER_COPY="$HOME/.cache/wal/wallpaper.png"

# ── Copy the Wallpaper ──

# Extract the wallpaper path from the wal file
WALLPAPER_PATH="$(cat "$HOME/.cache/wal/wal")"

# Check if the wallpaper file exists and copy it to the fixed path
if [[ -f "$WALLPAPER_PATH" ]]; then
    cp -f "$WALLPAPER_PATH" "$WALLPAPER_COPY"
fi

# ── Update btop ──

# Generate btop theme using colors from wal
cat > "$BTOP_THEME_PATH" << EOF
theme[main_bg]=$(head -n 1 "$WAL_COLORS")
theme[main_fg]=$(sed -n 8p "$WAL_COLORS")
theme[title]=$(sed -n 8p "$WAL_COLORS")
theme[hi_fg]=$(sed -n 3p "$WAL_COLORS")
theme[selected_bg]=$(sed -n 4p "$WAL_COLORS")
theme[selected_fg]=$(sed -n 15p "$WAL_COLORS")
theme[inactive_fg]=$(sed -n 2p "$WAL_COLORS")
theme[graph_text]=$(sed -n 9p "$WAL_COLORS")
theme[meter_bg]=$(sed -n 1p "$WAL_COLORS")
theme[meter_fg_good]=$(sed -n 3p "$WAL_COLORS")
theme[meter_fg_warn]=$(sed -n 2p "$WAL_COLORS")
theme[meter_fg_crit]=$(sed -n 1p "$WAL_COLORS")
theme[proc_misc]=$(sed -n 7p "$WAL_COLORS")
theme[proc_cpu]=$(sed -n 4p "$WAL_COLORS")
theme[proc_mem]=$(sed -n 5p "$WAL_COLORS")
theme[proc_net]=$(sed -n 6p "$WAL_COLORS")
theme[proc_stat_bg]=$(sed -n 1p "$WAL_COLORS")
theme[proc_stat_fg]=$(sed -n 8p "$WAL_COLORS")
EOF

# Set theme in btop config
sed -i 's/^theme =.*/theme = wallpaper-theme/' ~/.config/btop/btop.conf

# ── Update rofi ──

# Extract key: #hex; pairs from the wal generated rofi theme
declare -A rofi_colors
while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_-]+):[[:space:]]*(#[A-Fa-f0-9]{6})\; ]]; then
        key="${BASH_REMATCH[1]}"
        hex="${BASH_REMATCH[2]}"
        rofi_colors["$key"]="$hex"
    fi
done < "$WAL_ROFI_COLORS"

# Replace hex values in the custom rofi theme
tmpfile=$(mktemp)
while IFS= read -r line; do
    if [[ "$line" =~ ^([[:space:]]*)([a-zA-Z0-9_-]+):[[:space:]]*(#[A-Fa-f0-9]{6})(\;.*)?$ ]]; then
        indent="${BASH_REMATCH[1]}"
        key="${BASH_REMATCH[2]}"
        oldval="${BASH_REMATCH[3]}"
        rest="${BASH_REMATCH[4]}"
        newval="${rofi_colors[$key]}"
        if [[ -n "$newval" ]]; then
            echo "${indent}${key}: ${newval}${rest}" >> "$tmpfile"
        else
            echo "$line" >> "$tmpfile"
        fi
    else
        echo "$line" >> "$tmpfile"
    fi
done < "$ROFI_THEME_PATH"

# Overwrite the original rofi theme with updated colors
mv "$tmpfile" "$ROFI_THEME_PATH"
