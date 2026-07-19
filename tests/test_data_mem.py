import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

async def write_mem(dut, addr, data, enable=1):
    dut.mem_addr.value = addr
    dut.mem_wr_dt.value = data
    dut.mem_wr.value = enable
    await RisingEdge(dut.clk)
    dut.mem_wr.value = 0
    await Timer(1, unit="ns")

async def read_mem(dut, addr, enable=1):
    dut.mem_addr.value = addr
    dut.mem_rd.value = enable
    await Timer(1, unit="ns")
    return int(dut.mem_rd_dt.value)

@cocotb.test()
async def test_data_mem(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    
    dut.mem_wr.value = 0
    dut.mem_rd.value = 0
    await Timer(1, unit="ns")

    val = await read_mem(dut, 0x00)
    assert val == 0x00000000, f"Unwritten address 0x00: got {hex(val)}, expected 0x0"

    await write_mem(dut, 0x08, 0xDEADBEEF)
    val = await read_mem(dut, 0x08)
    assert val == 0xDEADBEEF, f"Write/read 0x08: got {hex(val)}, expected 0xDEADBEEF"

    await write_mem(dut, 0x0C, 0x12345678)
    val = await read_mem(dut, 0x0C)
    assert val == 0x12345678, f"Write/read 0x0C: got {hex(val)}, expected 0x12345678"

    val = await read_mem(dut, 0x08)
    assert val == 0xDEADBEEF, f"0x08 corrupt by write to 0x0C: got {hex(val)}"

    await write_mem(dut, 0x08, 0xAAAAAAAA, enable=0)
    val = await read_mem(dut, 0x08)
    assert val == 0xDEADBEEF, f"Write happened with mem_wr=0: got {hex(val)}"

    val = await read_mem(dut, 0x08, enable=0)
    assert val == 0x0000000, f"mem_rd=0 should drve 0: got {hex(val)}"

    val = await read_mem(dut, 0x08)
    assert val == 0xDEADBEEF, f"Value lost after gated read: got {hex(got)}"

    val = await read_mem(dut, 0x88)
    assert val == 0xDEADBEEF, f"0x88 should alias 0x08: got {hex(val)}"

    await write_mem(dut, 0x08, 0x0000002A)
    val = await read_mem(dut, 0x08)
    assert val == 0x0000002A, f"Overwrite 0x08: got {hex(val)}, expected 0x2A"

    dut._log.info("All data memory tests passed")
