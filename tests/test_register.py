import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

async def write_reg(dut, addr, dt):
    dut.wr_en.value = 1
    dut.wr_addr.value = addr
    dut.wr_dt.value = dt
    await RisingEdge(dut.clk)
    dut.wr_en.value = 0

@cocotb.test()
async def test_register_file(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await write_reg(dut, 5, 0x132EEFDD)
    dut.rd_addr1.value = 5
    await Timer(1, unit="ns")
    assert dut.rd_dt1.value == 0x132EEFDD, f"x5 read wrong: {dut.rd_dt1.value}"

    await write_reg(dut, 10, 0x21436234)
    dut.rd_addr2.value = 10
    await Timer(1, unit="ns")
    assert dut.rd_dt2.value == 0x21436234, f"x10 read wrong: {dut.rd_dt2.value}"

    await write_reg(dut, 0, 0xFFFFFFFF)
    dut.rd_addr1.value = 0
    await Timer(1, unit="ns")
    assert dut.rd_dt1.value == 0, f"x0 not zero: {dut.rd_dt1.value}"

     dut._log.info("Register file tests passed")


