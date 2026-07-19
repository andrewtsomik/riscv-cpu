import cocotb
from cocotb.triggers import Timer

VECTORS = [(0x00, 0x00500293, "Element 0 - First word"),
           (0x04, 0x00300313, "Element 1 - Shift works"),
           (0x08, 0x006282B3, "Element 2 - Shift holds"),
           (0x0C, 0x0052A023, "Element 3 - Last loaded word"),
           (0x10, 0x00000000, "Element 4 - Zeroed, not X"),
           (0x7C, 0x00000000, "Element 31 - Last valid slot"),
           (0x80, 0x00500293, "Technically Element 1 - Wraps around")
        ]

@cocotb.test()
async def test_instruct_mem(dut):
    for addr, expected, label in VECTORS:
        dut.addr.value = addr
        await Timer(1, unit="ns")
        val = int(dut.instruct.value)
        assert val == expected, f"{label}: addr={hex(addr)}, val={hex(val)}, expected={hex(expected)}"
    dut._log.info(f"All {len(VECTORS)} instruction memory tests passed")
