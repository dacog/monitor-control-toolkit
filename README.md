# monitor-control-toolkit
Monitor Control Toolkit: A collection of Linux scripts for multi-monitor management. Easily sync settings, adjust brightness, and control displays using DDC/CI and xrandr. Streamline your multi-monitor setup with simple, powerful tools.

## Linux

A GUI Alternative for Linux to change the Brightness only is [Brightness](https://github.com/LordAmit/Brightness)

I wanted to also sync the settings of my monitors and set the brightness of my monitors at the same time, thus the scripts below.
I also think that the terminal is much faster :)


### `rc/light.sh`

This is a quick script to change the brightness of monitor 1 and 2 to a brightness x.

```shell
sudo light.sh 15 # this will set brightness to 15. Values from 0 to 100.
```

Same as in the other scripts, you my avoid using sudo if you give access to your user to group `i2c` and then logout/login or `su -l $USER`

```shell
sudo usermod -G i2c -a $USER
su -l $USER
```

### `src/universal_copy_display_settings.sh`

**Status: works**

- It first tries to use ddcutil for both the source and target displays.
- If ddcutil doesn't work for either display, it falls back to using xrandr for brightness control.
- For xrandr, it only handles brightness adjustment.
- It detects the correct output names for xrandr based on the selected display numbers.

To use this script:

1. Save it as universal_copy_display_settings.sh
2. Make it executable:

```shell
chmod +x universal_copy_display_settings.sh
```

3. Run the script 

with sudo:

```bash
sudo ./universal_copy_display_settings.sh
```

or add your user to the `i2c` group

```shell
sudo usermod -G i2c -a $USER
```

and then logout and login again. You can also open a new terminal and run

```shell
./universal_copy_display_settings.sh

# or

bash universal_copy_display_settings.sh
```


### `src/universal_dual_monitor_brightness_control.sh`

**Status: works**

This script does the following:

- Detects all connected displays that support DDC/CI and their corresponding xrandr outputs.
- Lists the available displays and their models.
- Offers two modes of operation:
  - (a) Adjust both displays to the same brightness
  - (b) Set individual brightness for each display
- Uses `ddcutil` if available for a display, otherwise falls back to `xrandr`.
- Adjusts the brightness of both monitors according to the user's choice.
- Verifies and reports the new brightness for each display.

Key features:

    Supports both ddcutil and xrandr methods for maximum compatibility.
    Allows synchronizing brightness across both monitors or setting them individually.
    Automatically detects and uses the appropriate method (ddcutil or xrandr) for each monitor.
    Provides feedback on the actual brightness set for each display.


To use this script:

1. Save it as `universal_dual_monitor_brightness_control.sh`
2. Make it executable:

```shell
chmod +x universal_dual_monitor_brightness_control.sh
```

3. Run the script 

with sudo:

```bash
sudo ./universal_dual_monitor_brightness_control.sh
```

or add your user to the `i2c` group

```shell
sudo usermod -G i2c -a $USER
```

and then logout and login again. You can also open a new terminal and run

```shell
./universal_dual_monitor_brightness_control.sh

# or

bash universal_dual_monitor_brightness_control.sh
```

## Windows (Powershell)

Note: A way better alternative is to use [Monitorian](https://github.com/emoacht/Monitorian)

### Change Brightness with Monitorian

Install Monitorian:

- Download and install Monitorian from the Microsoft Store or GitHub: [Monitorian GitHub](https://github.com/emoacht/Monitorian)
- Save the Script
- Run the script: ```.\Dual_Monitor_Brightness_Control.ps1```

Notes:

- Monitorian Path:
  - Ensure the path to Monitorian.exe is correct in the script. If you installed it in a different location, update the path accordingly.
- Monitor Indexing:
  - Monitorian uses zero-based indexing for monitors, so the script starts from monitor 0.
- No Admin Rights:
  - This script does not require administrative privileges as it leverages Monitorian, which can adjust brightness without elevated permissions.


If you still want to play with PowerShell, check the scripts below.

## 

1. Save it as `Dual_Monitor_Brightness_Control.ps1`
2. Open PowerShell as Administrator
3. Run the script:

```shell
.\Dual_Monitor_Brightness_Control.ps1
```

This version:

- uses PowerShell
- Uses WMI (Windows Management Instrumentation) to interact with monitor brightness.
- Detects the number of connected monitors
- Allows setting the same brightness for both monitors or individual brightness for each
- Provides feedback on the current and new brightness levels

_Note that this script requires administrative privileges to run due to WMI access requirements. Also, some monitors or graphics drivers might not support WMI brightness control, in which case you might need to use alternative methods specific to the hardware or driver._

### Sync monitor settings in windows.

this is a work-in-progress

```shell
# Universal Copy Display Settings for Windows

# Ensure Monitorian is installed and in the default location
$monitorianPath = "C:\Program Files\Monitorian\Monitorian.exe"

# Function to get current brightness using Monitorian
function Get-Brightness {
    param ([int]$monitor)
    $brightness = & $monitorianPath /get $monitor
    return $brightness
}

# Function to set brightness using Monitorian
function Set-Brightness {
    param ([int]$monitor, [int]$brightness)
    & $monitorianPath /set $monitor $brightness
}

# Function to get current color settings
function Get-ColorSettings {
    $colorSettings = Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods
    return $colorSettings
}

# Function to set color settings
function Set-ColorSettings {
    param ($settings)
    $settings.WmiSetContrast(1, $settings.CurrentContrast)
    # Add more color settings here if supported by WMI
}

# Get number of monitors
$monitorCount = (& $monitorianPath /get count).Trim()

# Display available monitors
Write-Host "Available monitors: $monitorCount"
for ($i = 0; $i -lt $monitorCount; $i++) {
    $currentBrightness = Get-Brightness -monitor $i
    Write-Host "Monitor $i - Current brightness: $currentBrightness%"
}

# Prompt user to select source and target monitors
$sourceMonitor = Read-Host "Enter the number of the source monitor"
$targetMonitor = Read-Host "Enter the number of the target monitor"

# Copy brightness
$sourceBrightness = Get-Brightness -monitor $sourceMonitor
Set-Brightness -monitor $targetMonitor -brightness $sourceBrightness
Write-Host "Brightness copied from Monitor $sourceMonitor to Monitor $targetMonitor"

# Attempt to copy color settings
try {
    $colorSettings = Get-ColorSettings
    if ($colorSettings) {
        Set-ColorSettings -settings $colorSettings[$targetMonitor]
        Write-Host "Color settings copied from Monitor $sourceMonitor to Monitor $targetMonitor"
    } else {
        Write-Host "Unable to copy color settings. WMI color control not supported."
    }
} catch {
    Write-Host "Error copying color settings: $_"
}

Write-Host "Settings copy completed."

```

To use this script:

- Ensure Monitorian is installed on your system.
- `.\Universal_Copy_Display_Settings.ps1`

Notes from searching:

- This script primarily focuses on brightness control using Monitorian, as it's more reliable and doesn't require administrative privileges.
- The color settings part uses WMI, which may have limited support depending on your monitor and graphics driver. It might not work on all systems.
- For more advanced color control, you might need to use specific APIs provided by your graphics card manufacturer (e.g., NVIDIA, AMD, or Intel).
- This script doesn't require administrative privileges for brightness control, but some color settings might need elevated permissions if they're accessible.
- Windows doesn't seem to provide as comprehensive control over monitor settings through standard APIs as Linux does with tools like ddcutil.



# LICENSE

All scripts are under MIT License.