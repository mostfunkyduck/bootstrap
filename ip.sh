#!/bin/bash
set -e

function get_ips_usage() {
  >&2 echo "get_ips:"
  >&2 echo "  -f: which ip fam to use ('4' or '6')"
  >&2 echo "  -i: which interface to check (used in a grep filter, any non existent interface will cause empty output)"
  >&2 echo "  -h: print this message and exit"
  >&2 echo
}

#shellcheck disable=SC2207
#args=($(getopt -o fih --long family --long interface --long help -- "$@"))
#for arg in "${args[@]}"; do
while getopts "f:i:h" arg; do
  case "$arg" in
    h)
      get_ips_usage
      exit 1
      ;;  
    f)
      fam="$OPTARG"
      if [ "$fam" != 4 ] && [ "$fam" != 6 ]; then
        >&2 echo "illegal value for family: $fam"
        get_ips_usage 
        exit 1
      fi
      ;;
    i)
      if=$OPTARG
      ;;
    *)
      get_ips_usage
      exit 1
      ;;
  esac
done

cmd="ip -o"
if [ -n "$fam" ]; then
  cmd="$cmd -${fam}"
fi

cmd="$cmd addr"
if [ -n "$if" ]; then
  cmd="$cmd | grep $if"
fi
# shellcheck disable=SC2089,2016
cmd="$cmd | awk '{print \$4}' | awk -F / '{print \$1}'"
# shellcheck disable=SC2090,2086
eval $cmd
