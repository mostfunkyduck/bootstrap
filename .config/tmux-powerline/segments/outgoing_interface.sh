#!/bin/bash
run_segment() {
  if=$(ip route get 8.8.8.8 | head -1 | awk '{ print $5 }' | tr -d "\n")
  echo -n "$if"
	return 0
}
