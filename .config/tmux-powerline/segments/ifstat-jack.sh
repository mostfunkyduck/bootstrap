# #!/bin/bash
# Show network statistics for all active interfaces found.

run_segment() {
	type ifstat >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return 1
	fi

	sed="sed"
	type gsed >/dev/null 2>&1
	if [ "$?" -eq 0 ]; then
		sed="gsed"
	fi

	data=$(ifstat -T -z -S -q 1 1)
	flow_data=$(echo -e "${data}" | tail -n 1 | ${sed} "s/\s\{1,\}/,/g")
  echo $flow_data | awk '{ printf( "⇊%5.01f ⇈%5.01f", $(NF-1), $NF) }'
	return 0
}
