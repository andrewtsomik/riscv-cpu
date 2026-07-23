import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_shifts(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    for i in range(20):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        r = dut.reg_inst.registers
        pc = int(dut.pc.value)
        instruct = int(dut.instruct.value)
        dut._log.info(f"Cycle {i}: PC={int(dut.pc.value):#x} instruct={int(dut.instruct.value):#010x} "
                      f"x5={int(r[5].value)} "
                      f"x6={int(r[6].value)} "
                      f"x7={int(r[7].value)} "
                      f"x8={int(r[8].value)} "
                      f"x9={int(r[9].value)} "
                      f"x10={int(r[10].value)} "
                      f"x11={int(r[11].value)} "
                      f"x12={int(r[12].value)} "
                      f"x13={int(r[13].value)} "
                      f"x14={int(r[14].value)}")
    reg = dut.reg_inst.registers

    x5 = int(reg[5].value)
    x6 = int(reg[6].value)
    x7 = int(reg[7].value)
    x8 = int(reg[8].value)
    x9 = int(reg[9].value)
    x10 = int(reg[10].value)
    x11 = int(reg[11].value)
    x12 = int(reg[12].value)
    x13 = int(reg[13].value)
    x14 = int(reg[14].value)


    dut._log.info(f"x5 = {x5} x6 = {x6} x7 = {x7} x8 = {x8} x9 = {x9} x10 = {x10} x11 = {x11} x12={x12} x13={x13} x14={x14}")

    assert x5 == 0xFFFFFFF0, f"x5 = {x5}, expected -16/0xFFFFFFF0"
    assert x6 == 1, f"x6 = {x6}, expected 1"
    assert x7 == 0xFFFFFFFC, f"x7 = {x7}, expected -4 (SRA)"
    assert x8 == 0x3FFFFFFC, f"x8 = {x8}, expected 0x3FFFFFFC (SL)"
    assert x9 == 16, f"x9 = {x9}, expected 16 (SLL)"
    assert x10 == 3, f"x10 = {x10}, expected 3 (shift amount)"
    assert x11 == 8, f"x11 = {x11}, expected 8 (SLL)"
    assert x12 == 0xFFFFFFFF, f"x12 = {x12}, expected 0xFFFFFFFF"
    assert x13 == 1, f"x13 = {x13}, expected 1 (signed -1 < 1)"
    assert x14 == 0, f"x14 = {x14}, expected 0 (4 billion !< 1 (unsigned)"

    dut._log.info("All shift tests passed")
