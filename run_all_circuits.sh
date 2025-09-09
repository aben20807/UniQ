#!/bin/bash
# Iterate over all QASM files and run each 5 times, logging last 5 lines of output.
# Outer directory (all .qasm files): ./tests/additional_input
# You can override the executable via environment variable EXECUTABLE (default: ./main).

set -euo pipefail

QASM_DIR="./tests/additional_input"
EXECUTABLE="${EXECUTABLE:-./main}"
REPEAT=5
TAIL_N=5
LOG_FILE="run_all_circuits.log"

echo "[INFO] Logging to $LOG_FILE" >&2
touch "$LOG_FILE"

if [ ! -d "$QASM_DIR" ]; then
	echo "[ERROR] QASM directory not found: $QASM_DIR" >&2
	exit 1
fi

shopt -s nullglob
qasm_files=("$QASM_DIR"/*.qasm)
shopt -u nullglob

if [ ${#qasm_files[@]} -eq 0 ]; then
	echo "[WARN] No .qasm files found under $QASM_DIR" >&2
	exit 0
fi

for qasm in "${qasm_files[@]}"; do
	circuit_name="$(basename "$qasm")"
	for (( run=1; run<=REPEAT; run++ )); do
		start_ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
		tmp_out="$(mktemp)"
		status="OK"
		if ! "$EXECUTABLE" "$qasm" >"$tmp_out" 2>&1; then
			status="ERR:$?"
		fi
		end_ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
		{
			echo "-----"
			echo "timestamp_start=$start_ts timestamp_end=$end_ts circuit=$circuit_name run=$run/$REPEAT status=$status tail_last=${TAIL_N}lines"
			tail -n "$TAIL_N" "$tmp_out"
		} >> "$LOG_FILE"
		rm -f "$tmp_out"
	done
done

echo "[INFO] Completed all circuits" >&2