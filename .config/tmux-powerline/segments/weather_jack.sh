#!/bin/bash
run_segment() {
  weather="weather -q kbwi"
  temp=$($weather | grep ^Temperature | awk '{ print $2"F" }')
  wind=$($weather | grep ^Wind | sed 's/.*: //')
  if [[ "$wind" =~ ^from ]]; then
    direction=$(echo "$wind" | awk '{ print $3 }')
    speed=$(echo "$wind" | awk '{ print $7, $8 }') 
    wind="$direction $speed"
  fi
  sky=$($weather | grep ^Sky | sed 's/.*: //')
  echo -n "$temp | $wind | $sky"
  return 0
}
