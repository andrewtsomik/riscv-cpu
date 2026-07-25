#!/bin/bash

set -e
RVTESTS=${RVTESTS:-$HOME/riscv-tests}
BAREENV=${BAREENV:-$HOME/riscv-cpu/rvenv}
OUTDIR=${OUTDIR:-$HOME/riscv-cpu/programs/isa}

TEST=$1
if [ -z "$TEST" ]; then
	echo "usage: $0 <testname> e.g. $0 add"
	exit 1
fi

mkdir -p "$OUTDIR"
TMP=$(mktemp -d)

riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -static -mcmodel=medany \
	-fvisibility=hidden -nostdlib -nostartfiles \
	-I"$BAREENV" -I"$RVTESTS/isa/macros/scalar" -T"$BAREENV/link.ld" \
	"$RVTESTS/isa/rv32ui/$TEST.S" -o "$TMP/$TEST.elf"

riscv64-unknown-elf-objcopy -O binary "$TMP/$TEST.elf" "$TMP/$TEST.bin"

python3 "$BAREENV/bin2hex.py" "$TMP/$TEST.bin" "$OUTDIR/rv32ui-p-$TEST.hex"

riscv64-unknown-elf-objdump -d "$TMP/$TEST.elf" > "$OUTDIR/rv32ui-p-$TEST.dump"

rm -rf "$TMP"

