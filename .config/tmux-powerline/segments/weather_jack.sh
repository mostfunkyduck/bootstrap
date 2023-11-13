#!/bin/bash
run_segment() {
  weather="weather -q kbwi"
  temp=$($weather | grep ^Temperature | awk '{ print $2"F" }')
  wind=$($weather | grep ^Wind: | sed 's/.*: //')
  windchill=$($weather | grep ^Windchill | awk '{ print $2"F" }')
  if [ -n "$windchill" ]; then
    temp="$temp ($windchill)"
  fi
  if [[ "$wind" =~ ^from ]]; then
    direction=$(echo -n "$wind" | awk '{ print $3 }')
    speed=$(echo -n "$wind" | awk '{ print $7, $8 }') 
    wind="$direction $speed"
  elif [[ "$wind" =~ ^Variable ]]; then
    direction="Variable"
    speed=$(echo "$wind" | awk '{ print $3, $4 }')
    wind="$direction $speed"
  fi
  sky=$($weather | grep ^Sky | sed 's/.*: //')
  echo -n "$temp | $wind | $sky"
  return 0
}
