param (
    [string]$csvFilePath
)

# Import the CSV file
$data = Import-Csv -Path $csvFilePath

# Check if the FrameTime column exists
if (-not $data[0].PSObject.Properties['FrameTime']) {
    Write-Error "The CSV file does not contain a 'FrameTime' column."
    exit 1
}

# Calculate FPS from FrameTime (assuming FrameTime is in milliseconds)
$fpsValues = $data | ForEach-Object { 1000 / $_.FrameTime }

# Calculate statistics
$averageFPS = [math]::Round(($fpsValues | Measure-Object -Average).Average, 2)
$minFPS = [math]::Round(($fpsValues | Measure-Object -Minimum).Minimum, 2)
$maxFPS = [math]::Round(($fpsValues | Measure-Object -Maximum).Maximum, 2)

# Calculate 1% lows and 0.1% lows
$sortedFPS = $fpsValues | Sort-Object
$onePercentLowIndex = [math]::Ceiling($sortedFPS.Count * 0.01) - 1
$pointOnePercentLowIndex = [math]::Ceiling($sortedFPS.Count * 0.001) - 1

$onePercentLowFPS = [math]::Round($sortedFPS[$onePercentLowIndex], 2)
$pointOnePercentLowFPS = [math]::Round($sortedFPS[$pointOnePercentLowIndex], 2)

# Prepare the summary content
$summaryContent = @"
Average FPS: $averageFPS
Minimum FPS: $minFPS
Maximum FPS: $maxFPS
1% Low FPS: $onePercentLowFPS
0.1% Low FPS: $pointOnePercentLowFPS
1% Percentile FPS: $onePercentLowFPS
0.1% Percentile FPS: $pointOnePercentLowFPS
"@

# Write the summary to the output file
$outputFilePath = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($csvFilePath), "summary.txt")
Set-Content -Path $outputFilePath -Value $summaryContent

# Output only the final message
Write-Output "Summary created: $outputFilePath"