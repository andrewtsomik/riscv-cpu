import cocotb
from cocotb.triggers import Timer

@cocotb.test()

async def test_and(dut):
    for a in (0,1):
        for b in (0,1):
            dut.a.value = a
            dut.b.value = b
            await Timer(1, unit="ns")
            expected = a & b
            assert dut.y.value == expected, f"a={a} b={b}: got {dut.y.value}, expected {expected}"
