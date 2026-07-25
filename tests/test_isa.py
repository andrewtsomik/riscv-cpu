import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

MAX_CYCLES = 8000

@cocotb.test()
async def test_isa(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    reg = dut.reg_inst.registers
    prev_pc = -1
    stuck = 0
    cycles = 0

    for i in range(MAX_CYCLES):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        cycles = i + 1

        pc = int(dut.pc.value)
        if pc == prev_pc:
            stuck += 1
        else:
            stuck = 0
            prev_pc = pc

        if int(reg[3].value) == 1:
            break
    x3 = int(reg[3].value)
    dut._log.info(f"Finished after {cycles}, x3 = {x3}")
    
    if x3 == 1:
        dut._log.info("All subtests passed")
    elif x3 == 0:
        dut._log.info("x3 = 0: program never reached pass or faill "
                      f"(Ran {MAX_CYCLES})")
    else:
        dut._log.info(f"Failed sub-test")

    assert x3 == 1, f"x3 = {x3} (1 means pass and others mean failing sub-test number)"

