import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_jal(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    for c in range(20):
        await RisingEdge(dut.clk)

    await Timer(1, unit="ns")

    reg = dut.reg_inst.registers

    x1 = int(reg[1].value)
    x7 = int(reg[7].value)
    x8 = int(reg[8].value)
    
    for i in range(20):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        pc = int(dut.pc.value)
        instruct = int(dut.instruct.value)
        dut._log.info(f"Cycle {i}: PC={pc:#x} instruct={instruct:#010x} "
                      f"x1={int(dut.reg_inst.registers[1].value)} "
                      f"x7={int(dut.reg_inst.registers[7].value)} "
                      f"x8={int(dut.reg_inst.registers[8].value)}")

    dut._log.info(f"x1 = {x1} x1 = {x7} x8 = {x8}")

    assert x1 == 4, f"x5 = {x1}, expected 4"
    assert x7 == 0, f"x6 = {x7}, expected 0"
    assert x8 == 42, f"x8 = {x8}, expected 42"

    dut._log.info("jal works")
