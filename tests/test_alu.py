import cocotb
from cocotb.triggers import Timer

async def write_alu(dut, op1, op2, opera):
    dut.o1.value = op1
    dut.o2.value = op2
    dut.oper.value = opera
    await Timer(1, unit="ns")

@cocotb.test()
async def test_alu(dut):

    await write_alu(dut, 0x00000005, 0x00000003, 0)
    await Timer(1, unit="ns")
    assert dut.result.value == 0x00000008, f"add got: {dut.result.value}, expected 0x00000008"

    await write_alu(dut, 0xFFFFFFFF, 0x00000001, 0)
    await Timer(1, unit="ns")
    assert dut.result.value == 0x00000000, f"add got: {dut.result.value}, expected 0x00000000"

    await write_alu(dut, 0x0000000A, 0x0000000B, 1)
    await Timer(1, unit="ns")
    assert dut.result.value == 0xFFFFFFFF, f"sub got: {dut.result.value}, expected 0xFFFFFFFF"

    await write_alu(dut, 0xF00F0FFF, 0xFFF00F00, 2)
    await Timer(1, unit="ns")
    assert dut.result.value == 0xF0000F00, f"and got: {dut.result.value}, expected 0xF0000F00"

    await write_alu(dut, 0x1234F921, 0xAAFDE908, 3)
    await Timer(1, unit="ns")
    assert dut.result.value == 0xBAFDF929, f"or got: {dut.result.value}, expected 0xBAFDF929"

    await write_alu(dut, 0xFFFFFFFF, 0xAAAAAAAA, 4)
    await Timer(1, unit="ns")
    assert dut.result.value == 0x55555555, f"xor got: {dut.result.value}, expected 0x55555555"

    await write_alu(dut, 0xFFFFFFFF, 0x00000001, 5)
    await Timer(1, unit="ns")
    assert dut.result.value == 0x00000001, f"slt got: {dut.result.value}, expected 0x00000001"

    await write_alu(dut, 0x00000005, 0x00000003, 5)
    await Timer(1, unit="ns")
    assert dut.result.value == 0x00000000, f"slt got: {dut.result.value}, expected 0x00000000"

    await write_alu(dut, 0x00000003, 0x00000005, 5)
    await Timer(1, unit="ns")
    assert dut.result.value == 0x00000001, f"slt got: {dut.result.value}, expected 0x00000001"

    await write_alu(dut, 0xFFFFFFFF, 0xAAAAAAAA, 6)
    await Timer(1, unit="ns")
    assert dut.result.value == 0x00000000, f"Non valid operation got: {dut.result.value}, expected 0x00000000"

    await write_alu(dut, 0xFFFFFFFF, 0xAAAAAAA, 7)
    await Timer(1, unit="ns")
    assert dut.result.value == 0x00000000, f"Non valid operation got: {dut.result.value}, expected 0x00000000"
    
    dut._log.info("ALU tests passed")
    
