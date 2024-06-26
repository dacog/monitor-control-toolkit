# Dual Monitor Brightness Control using Monitorian

# Function to get current brightness
function Get-Brightness {
    param (
        [int]$monitor
    )
    $brightness = & "C:\Program Files\Monitorian\Monitorian.exe" /get $monitor
    return $brightness
}

# Function to set brightness
function Set-Brightness {
    param (
        [int]$monitor,
        [int]$brightness
    )
    & "C:\Program Files\Monitorian\Monitorian.exe" /set $monitor $brightness
}

# Get number of monitors
$monitorCount = (& "C:\Program Files\Monitorian\Monitorian.exe" /get count).Trim()

# Display available monitors
Write-Host "Available monitors: $monitorCount"
for ($i = 0; $i -lt $monitorCount; $i++) {
    $currentBrightness = Get-Brightness -monitor $i
    Write-Host "Monitor $i - Current brightness: $currentBrightness%"
}

# Prompt user for adjustment mode
$mode = Read-Host "Select brightness adjustment mode:`n1: Adjust both displays to the same brightness`n2: Set individual brightness for each display`nEnter your choice (1 or 2)"

if ($mode -eq "1") {
    $newBrightness = Read-Host "Enter new brightness value (0-100)"
    for ($i = 0; $i -lt $monitorCount; $i++) {
        Set-Brightness -monitor $i -brightness $newBrightness
        $verifiedBrightness = Get-Brightness -monitor $i
        Write-Host "Monitor $i: New brightness set to $verifiedBrightness%"
    }
}
elseif ($mode -eq "2") {
    for ($i = 0; $i -lt $monitorCount; $i++) {
        $newBrightness = Read-Host "Enter new brightness value for Monitor $i (0-100)"
        Set-Brightness -monitor $i -brightness $newBrightness
        $verifiedBrightness = Get-Brightness -monitor $i
        Write-Host "Monitor $i: New brightness set to $verifiedBrightness%"
    }
}
else {
    Write-Host "Invalid choice. Exiting."
    exit
}

Write-Host "Brightness adjustment completed."
