#!/bin/bash
run_segment() {
  sensors -u thinkpad-isa-0000 | grep temp1_input | awk '{ print "C: " int($2) "C" }' 2>&1 | tr -d "\n"
  echo -n " G: "
  nvidia-smi --format=csv,noheader --query-gpu=temperature.gpu | tr -d "\n"
  echo -n "C"
  return 0
}

