import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_auipc(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    for c in range(20):
        await RisingEdge(dut.clk)

    await Timer(1, unit="ns")

    reg = dut.reg_inst.registers

    x5 = int(reg[5].value)
    
    for i in range(20):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        pc = int(dut.pc_out.value)
        instruct = int(dut.instruct.value)
        dut._log.info(f"Cycle {i}: PC={pc:#x} instruct={instruct:#010x} "
                      f"x5={int(dut.reg_inst.registers[5].value)} ")

    dut._log.info(f"x5 = {x5}")

    assert x5 == 0x1000, f"x5 = {x5}, expected 0x1000"

    dut._log.info("auipc works")
