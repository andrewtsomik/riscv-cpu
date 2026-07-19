import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_immediate_instruction(dut):
    dut.instruct.value = 0x00530293
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0x00000005, f"I-Type: got {hex(dut.imm_out.value)}, expected 0x00000005"

    dut.instruct.value = 0xFFF30293
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0xFFFFFFFF, f"I-Type: got {hex(dut.imm_out.value)}, expected 0xFFFFFFFF"

    dut.instruct.value = 0x7FF30293
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0x000007FF, f"I-Type: got {hex(dut.imm_out.value)}, expected 0x000007FF"

    dut.instruct.value = 0x80030293
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0xFFFFF800, f"I-Type: got {hex(dut.imm_out.value)}, expected 0xFFFFF800"

    dut.instruct.value = 0x00830283
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0x00000008, f"I-Type: got {hex(dut.imm_out.value)}, expected 0x00000008"

    dut.instruct.value = 0xFF830283
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0xFFFFFFF8, f"I-Type: got {hex(dut.imm_out.value)}, expected 0xFFFFFFF8"

    dut.instruct.value = 0x2A7322A3
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0x000002A5, f"S-Type: got {hex(dut.imm_out.value)}, expected 0x000002A5"

    dut.instruct.value = 0x00732423
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0x00000008, f"S-Type: got {hex(dut.imm_out.value)}, expected 0x00000008"

    dut.instruct.value = 0xFE732623
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0xFFFFFFEC, f"S-Type: got {hex(dut.imm_out.value)}, expected 0xFFFFFFEC"

    dut.instruct.value = 0x00730863
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0x00000010, f"B-Type: got {hex(dut.imm_out.value)}, expected 0x00000010"

    dut.instruct.value = 0xFE7308E3
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0xFFFFFFF0, f"B-Type: got {hex(dut.imm_out.value)}, expected 0xFFFFFFF0"

    dut.instruct.value = 0x7E730FE3
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0x00000FFE, f"B-Type: got {hex(dut.imm_out.value)}, expected 0x00000FFE"

    dut.instruct.value = 0x80730063
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0xFFFFF000, f"B-Type: got {hex(dut.imm_out.value)}, expected 0xFFFFF000"

    dut.instruct.value = 0x001000EF
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0x00000800, f"J-Type: got {hex(dut.imm_out.value)}, expected 0x00000800"

    dut.instruct.value = 0x800FF0EF
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0xFFFFF000, f"J-Type: got {hex(dut.imm_out.value)}, expected 0xFFFFF000"

    dut.instruct.value = 0x7FFFF0EF
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0x000FFFFE, f"J-Type: got {hex(dut.imm_out.value)}, expected 0x000FFFFE"

    dut.instruct.value = 0x007302B3
    await Timer(1, unit="ns")
    assert dut.imm_out.value == 0x00000000, f"R-Type: got {hex(dut.imm_out.value)}, expected 0x00000000"

    dut._log.info("Op code tests passed") 
