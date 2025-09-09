#!/bin/bash
# Tuning LOCAL_QUBIT_SIZE from 10 to 18 for the given QASM and summarizing the last 5 lines of output per run.

set -euo pipefail

START_SIZE=10
END_SIZE=18
QASM_PATH="./tests/additional_input/bv32.qasm"
SUMMARY_LOG="local_qubit_size_tuning.log"
TAIL_N=5

echo "[info] Writing summary to ${SUMMARY_LOG}" >"${SUMMARY_LOG}"

for SIZE in $(seq ${START_SIZE} ${END_SIZE}); do
	echo "[info] Configuring build for LOCAL_QUBIT_SIZE=${SIZE}"
	CXX=g++-10 cmake . -DHARDWARE=cpu -DLOCAL_QUBIT_SIZE=${SIZE} >/dev/null
	echo "[info] Building..."
	make -j >/dev/null

	RUN_LOG="run_LQS_${SIZE}.log"
	echo "[info] Running ./main ${QASM_PATH} -> ${RUN_LOG}"
	./main "${QASM_PATH}" | tee "${RUN_LOG}" >/dev/null

	echo "===== LOCAL_QUBIT_SIZE=${SIZE} | last ${TAIL_N} lines =====" >>"${SUMMARY_LOG}"
	tail -n ${TAIL_N} "${RUN_LOG}" >>"${SUMMARY_LOG}"
	echo >>"${SUMMARY_LOG}"
done

echo "[info] Summary tail (${TAIL_N} lines):"
tail -n ${TAIL_N} "${SUMMARY_LOG}"