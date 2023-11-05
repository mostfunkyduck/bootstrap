#!/bin/bash
run_segment() {
  status=$(tailscale status)
  if [ "$status" = "Tailscale is stopped." ]; then
    echo -n "off"
  else
    tailscale ip | head -1 | tr -d '\n'
  fi
	return 0
}
