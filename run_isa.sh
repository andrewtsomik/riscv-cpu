#!/bin/bash

cd ~/riscv-cpu
export RVTESTS=${RVTESTS:-$HOME/riscv-tests}
export BAREENV=${BAREENV:-$HOME/riscv-cpu/rvenv}

TESTS="simple add addi and andi auipc beq bge bgeu blt bltu bne \
       jal jalr lb lbu lh lhu lui lw or ori sb sh sw \
       sll slli slt slti sltiu sltu sra srai srl srli sub xor xori"
pass=0; fail=0; skip=0;

for t in $TESTS; do
	printf "%-12s " "$t"

	if ! ./rvenv/build_test.sh "$t" > /dev/null 2>&1; then
		echo "BUILD FAIL"
		skip=$((skip+1))
		continue
	fi

	out=$(cd tests && make MODULE=test_isa \
		PLUSARGS=+HEX=../programs/isa/rv32ui-p-$t.hex 2>&1)

	if echo "$out" | grep -q "PASS=1 FAIL=0"; then
		echo "PASS"
		pass=$((pass+1))
	else
		detail=$(echo "$out" | grep -oE "x3 = [0-9]+" | tail -1)
		echo "FAIL ($detail)"
		fail=$((fail+1))
	fi
done

echo
echo "Passed $pass Failed $fail Build-Failed $skip"
