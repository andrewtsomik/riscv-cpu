import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_cpu_top(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    for c in range(10):
        await RisingEdge(dut.clk)

    await Timer(1, unit="ns")

    reg = dut.reg_inst.registers

    x5 = int(reg[5].value)
    x6 = int(reg[6].value)
    x7 = int(reg[7].value)
    x8 = int(reg[8].value)
    
    for i in range(10):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        pc = int(dut.pc_out.value)
        instruct = int(dut.instruct.value)
        dut._log.info(f"Cycle {i}: PC={pc:#x} instruct={instruct:#010x} "
                      f"x5={int(dut.reg_inst.registers[5].value)} "
                      f"x6={int(dut.reg_inst.registers[6].value)} "
                      f"x7={int(dut.reg_inst.registers[7].value)}")

    dut._log.info(f"x5 = {x5} x6 = {x6} x7 = {x7} x8 = {x8}")

    assert x5 == 5, f"x5 = {x5}, expected 5 (addi failed)"
    assert x6 == 3, f"x6 = {x6}, expected 3 (addi failed)"
    assert x7 == 8, f"x7 = {x7}, expected 8 (add failed)"
    assert x8 == 8, f"x8 = {x8}, expected 8 (load/store/writeback failed)"

    dut._log.info("CPU integration tests passed")
