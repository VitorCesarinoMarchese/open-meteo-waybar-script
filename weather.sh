#!/bin/bash

LAT="-23.55068"
LON="-46.63412"
CACHE_TTL=900 # seconds
CACHE_FILE="/tmp/weather_cache.json"

URL="https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&hourly=weather_code,temperature_2m&timezone=America%2FSao_Paulo&forecast_days=1"

# Functions
get_wmo() {
  case "$1" in
  0) echo "" ;;                      # Clear sky
  1 | 2) echo "" ;;                  # Mostly clear / partly cloudy
  3) echo "" ;;                      # Overcast
  45 | 48) echo "󰖑" ;;                # Fog
  51 | 53 | 55 | 56 | 57) echo "" ;; # Drizzle / freezing drizzle
  61 | 63 | 65 | 66 | 67) echo "" ;; # Rain / freezing rain
  71 | 73 | 75 | 77) echo "" ;;      # Snow + grains
  80 | 81 | 82) echo "" ;;           # Rain showers
  85 | 86) echo "" ;;                # Snow showers
  95 | 96 | 99) echo "" ;;           # Thunderstorm
  *) echo "󰖎" ;;                      # Unknown
  esac
}

# Fetch
if [ "$CACHE_TTL" -gt 0 ] && [ -f "$CACHE_FILE" ]; then
  age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE")))
  if [ "$age" -lt "$CACHE_TTL" ]; then
    response=$(cat "$CACHE_FILE")
  fi
fi

# If not cached, fetch from API
if [ -z "$response" ]; then
  if ! response=$(curl -fs "$URL"); then
    printf '{"text":"󰖎","tooltip":"API error","class":"weather"}\n'
    exit 0
  fi
  [ "$CACHE_TTL" -gt 0 ] && echo "$response" >"$CACHE_FILE"
fi

# Validate JSON
if ! echo "$response" | jq . >/dev/null 2>&1; then
  printf '{"text":"󰖎","tooltip":"Invalid JSON","class":"weather"}\n'
  exit 0
fi

# Data
current_hour=$(date +"%H")
next_hour=$(((current_hour + 1) % 24))

mapfile -t vals < <(
  jq -r \
    ".hourly.temperature_2m[$current_hour],
     .hourly.temperature_2m[$next_hour],
     .hourly.weather_code[$current_hour],
     .hourly.weather_code[$next_hour]" \
    <<<"$response"
)

# ensure we got 4 values back
if [ "${#vals[@]}" -lt 4 ]; then
  printf '{"text":"󰖎","tooltip":"API returned incomplete data","class":"weather"}\n'
  exit 0
fi

temperature="${vals[0]}"
next_temperature="${vals[1]}"
weather_code="${vals[2]}"
next_weather_code="${vals[3]}"

if [ "$temperature" = "null" ] || [ "$weather_code" = "null" ]; then
  printf '{"text":"󰖎","tooltip":"API returned null","class":"weather"}\n'
  exit 0
fi

# Formated Data
temperature=$(printf "%.0f" "$temperature")
wmo=$(get_wmo "$weather_code")
next_temperature=$(printf "%.0f" "$next_temperature")
next_wmo=$(get_wmo "$next_weather_code")

output="$wmo $temperature°"
next_output="$next_wmo $next_temperature°"

# --- Output JSON for Waybar ---
printf '{"text":"%s","tooltip":"%s","class":"weather"}\n' \
  "$output" "$next_output"
