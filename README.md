# Open-Meteo Waybar Script

A lightweight shell script that fetches weather data from the Open-Meteo API and formats it as a Waybar custom module. It displays temperature and weather conditions.

## Features

- Uses the free Open-Meteo API (no API key required)
- Outputs valid JSON for Waybar
- Automatic tooltip support
- Customizable refresh interval

## Installation

1. Place the script in your Waybar scripts directory:
```bash
~/your/waybar/scripts/path/weather.sh
```
2. Make it executable:
```bash
chmod +x ~/your/waybar/scripts/path/weather.sh
```
3. Add the module to your Waybar config.

## Waybar Configuration Example
```json
"custom/weather": {
  "exec": "~/your/waybar/scripts/path/weather.sh",
  "format": "{}",
  "tooltip": true,
  "interval": 1800,
  "return-type": "json"
}
```

- `interval`: refresh every 30 minutes
- `format`: displays whatever text the script returns
- `tooltip`: shows detailed forecast when hovering
- `return-type`: ensures Waybar parses JSON output correctly

## Script Output Example
The script returns JSON like:
```json
{
"text":" 20°",
"tooltip":" 19°",
"class":"weather"
}
```

## Requirements
- bash or POSIX-compatible shell
- curl
- Waybar 
- jq

## Customization
You can modify:
- Everything 
