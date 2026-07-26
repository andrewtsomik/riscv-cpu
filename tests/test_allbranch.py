import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_branch_top(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    for c in range(20):
        await RisingEdge(dut.clk)

    await Timer(1, unit="ns")

    reg = dut.reg_inst.registers
    
    for i in range(20):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        pc = int(dut.pc.value)
        instruct = int(dut.instruct.value)
        dut._log.info(f"Cycle {i}: PC={pc:#x} instruct={instruct:#010x} "
                      f"x5={int(dut.reg_inst.registers[5].value)} "
                      f"x6={int(dut.reg_inst.registers[6].value)} "
                      f"x8={int(dut.reg_inst.registers[8].value)}")
    
    x5 = int(reg[5].value)
    x6 = int(reg[6].value)
    x8 = int(reg[8].value)

    dut._log.info(f"x5 = {x5} x6 = {x6} x8 = {x8}")

    assert x5 == 0, f"x5 = {x5}, expected 0"
    assert x6 == 6, f"x6 = {x6}, expected 6"
    assert x8 == 42, f"x8 = {x8}, expected 42"

    dut._log.info("bne works")
