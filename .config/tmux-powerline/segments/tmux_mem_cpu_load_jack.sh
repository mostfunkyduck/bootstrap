# Print out Memory, cpu and load using https://github.com/thewtex/tmux-mem-cpu-load

run_segment() {
	stats=""
	if type tmux-mem-cpu-load >/dev/null 2>&1; then
		stats="$(tmux-mem-cpu-load $TMUX_SEGMENT_TMCL_JACK_ARGS)"
	else
		return
	fi

	if [ -n "$stats" ]; then
		echo "$stats";
	fi
	return 0
}
