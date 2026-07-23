cd ~/riscv-cpu/tests
for pair in "branch:test_allbranch" \
	    "shift:test_shift" \
	    "lui:test_lui" \
	    "auipc:test_auipc" \
	    "jal:test_jal" \
	    "jalr:test_jalr" \
	    "hazard:test_hazard_piped_cpu" \
	    "stall:test_stall_cpu" \
	    "piped:test_piped_cpu"; do
	hex="${pair%%:*}"; mod="${pair##*:}"
	cp ../programs/$hex.hex ../programs/test.hex
	printf "%-26s " "$mod"
	make MODULE=$mod 2>&1 | grep -q "PASS=1 FAIL=0" && echo PASS || echo FAIL
done
