#!/bin/bash

# Function to get VCP value from a display
get_vcp() {
    local display=$1
    local feature=$2
    local value=$(ddcutil getvcp $feature --display $display 2>/dev/null | grep -oP 'current value =\s*\K[0-9]+')
    echo $value
}

# Function to set VCP value on a display
set_vcp() {
    local display=$1
    local feature=$2
    local value=$3
    ddcutil setvcp $feature $value --display $display 2>/dev/null
}

# Get list of displays
displays=($(ddcutil detect | grep "Display" | cut -d' ' -f2))

# Print available displays
echo "Available displays:"
for i in "${!displays[@]}"; do
    echo "$i: Display ${displays[$i]}"
    ddcutil detect --display ${displays[$i]} | grep "Model:"
done

# Prompt user to select source and target displays
read -p "Enter the number of the source display: " source_num
read -p "Enter the number of the target display: " target_num

source_display=${displays[$source_num]}
target_display=${displays[$target_num]}

echo "Copying settings from Display $source_display to Display $target_display"

# Array of VCP codes to copy
vcp_codes=(
    10  # Brightness
    12  # Contrast
    14  # Color Temperature Select
    16  # Red Gain
    18  # Green Gain
    26  # Blue Gain
    62  # Audio Volume
)

# Copy settings
for code in "${vcp_codes[@]}"; do
    value=$(get_vcp $source_display $code)
    if [ ! -z "$value" ]; then
        echo "Copying VCP $code: $value"
        set_vcp $target_display $code $value
    else
        echo "Failed to get value for VCP $code"
    fi
done

echo "Settings copied from Display $source_display to Display $target_display"

# Verify settings on target display
echo "Verifying settings on target display:"
for code in "${vcp_codes[@]}"; do
    value=$(get_vcp $target_display $code)
    echo "VCP $code: $value"
done
