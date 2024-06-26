#!/bin/bash

# Function to check if ddcutil is available and working for a display
check_ddcutil() {
    local display=$1
    ddcutil getvcp 10 --display $display &>/dev/null
    return $?
}

# Function to get brightness using ddcutil
get_brightness_ddcutil() {
    local display=$1
    local value=$(ddcutil getvcp 10 --display $display 2>/dev/null | grep -oP 'current value =\s*\K[0-9]+')
    echo $value
}

# Function to set brightness using ddcutil
set_brightness_ddcutil() {
    local display=$1
    local value=$2
    ddcutil setvcp 10 $value --display $display 2>/dev/null
}

# Function to get brightness using xrandr
get_brightness_xrandr() {
    local output=$1
    local brightness=$(xrandr --verbose --current | awk -v output="$output" '$0 ~ output {p=1} p&&/Brightness:/ {print $2; exit}')
    echo $brightness
}

# Function to set brightness using xrandr
set_brightness_xrandr() {
    local output=$1
    local brightness=$2
    xrandr --output $output --brightness $brightness
}

# Get list of displays
displays=($(ddcutil detect | grep "Display" | cut -d' ' -f2))

# Get corresponding xrandr output names
xrandr_outputs=($(xrandr | grep " connected" | cut -d' ' -f1))

# Print available displays
echo "Available displays:"
for i in "${!displays[@]}"; do
    echo "$i: Display ${displays[$i]} (xrandr output: ${xrandr_outputs[$i]})"
    ddcutil detect --display ${displays[$i]} | grep "Model:"
done

# Function to adjust brightness for a single display
adjust_brightness() {
    local display=$1
    local xrandr_output=$2
    local new_brightness=$3

    use_ddcutil=$(check_ddcutil $display)

    if [ $use_ddcutil -eq 0 ]; then
        set_brightness_ddcutil $display $new_brightness
        verified_brightness=$(get_brightness_ddcutil $display)
        echo "Display $display: New brightness set to $verified_brightness (ddcutil)"
    else
        # Convert 0-100 to 0.0-1.0 for xrandr
        xrandr_brightness=$(awk "BEGIN {print $new_brightness/100}")
        set_brightness_xrandr $xrandr_output $xrandr_brightness
        verified_brightness=$(get_brightness_xrandr $xrandr_output)
        echo "Display $display: New brightness set to $verified_brightness (xrandr)"
    fi
}

# Prompt user for brightness adjustment mode
echo "Select brightness adjustment mode:"
echo "1: Adjust both displays to the same brightness"
echo "2: Set individual brightness for each display"
read -p "Enter your choice (1 or 2): " mode

if [ "$mode" == "1" ]; then
    read -p "Enter new brightness value (0-100): " new_brightness
    for i in "${!displays[@]}"; do
        adjust_brightness ${displays[$i]} ${xrandr_outputs[$i]} $new_brightness
    done
elif [ "$mode" == "2" ]; then
    for i in "${!displays[@]}"; do
        read -p "Enter new brightness value for Display ${displays[$i]} (0-100): " new_brightness
        adjust_brightness ${displays[$i]} ${xrandr_outputs[$i]} $new_brightness
    done
else
    echo "Invalid choice. Exiting."
    exit 1
fi

echo "Brightness adjustment completed."
