import cocotb
from cocotb.triggers import Timer

ALU_ADD, ALU_SUB, ALU_AND, ALU_OR, ALU_XOR, ALU_SLT = 0, 1, 2, 3, 4, 5

VECTORS = [(0x007302B3, 1, 0, 0, 0, 0, 0, ALU_ADD, "add x5, x6, x7"),
           (0x407302B3, 1, 0, 0, 0, 0, 0, ALU_SUB, "sub x5, x6, x7"),
           (0x007372B3, 1, 0, 0, 0, 0, 0, ALU_AND, "and x5, x6, x7"),
           (0x007362B3, 1, 0, 0, 0, 0, 0, ALU_OR, "or x5, x6, x7"),
           (0x007342B3, 1, 0, 0, 0, 0, 0, ALU_XOR, "xor x5, x6, x7"),
           (0x007322B3, 1, 0, 0, 0, 0, 0, ALU_SLT, "slt x5, x6, x7"),

           (0x00530293, 1, 1, 0, 0, 0, 0, ALU_ADD, "addi x5, x6, 5"),
           (0xFFF30293, 1, 1, 0, 0, 0, 0, ALU_ADD, "addi x5, x6, -1"),
           (0x00537293, 1, 1, 0, 0, 0, 0, ALU_AND, "andi x5, x6, 5"),
           (0x00536293, 1, 1, 0, 0, 0, 0, ALU_OR, "ori x5, x6, 5"),
           (0x00534293, 1, 1, 0, 0, 0, 0, ALU_XOR, "xori x5, x6, 5"),
           (0x00532293, 1, 1, 0, 0, 0, 0, ALU_SLT, "slti x5, x6, 5"),

           (0x00832283, 1, 1, 1, 0, 1, 0, ALU_ADD, "lw x5, 8(x6)"),
           (0x00732423, 0, 1, 0, 1, 0, 0, ALU_ADD, "sw x7, 8(x6)"),

           (0x00730863, 0, 0, 0, 0, 0, 1, ALU_SUB, "beq x6 , x7, 16"),

           (0x0000007F, 0, 0, 0, 0, 0, 0, ALU_ADD, "Invalid opcode")
          ]

SIGNALS = ["reg_wr", "alu_src", "mem_rd", "mem_wr", "mem_to_reg", "branch", "alu_op"]

@cocotb.test()
async def test_decoder(dut):
    for instr, *expected, label in VECTORS:
        dut.instruct.value = instr
        await Timer(1, unit="ns")

        got = [int(dut.reg_wr.value),
               int(dut.alu_src.value),
               int(dut.mem_rd.value),
               int(dut.mem_wr.value),
               int(dut.mem_to_reg.value),
               int(dut.branch.value),
               int(dut.alu_op.value)]
        for name, g, e in zip(SIGNALS, got, expected):
            assert g == e, (f"{label} (Instruction = {hex(instr)}): {name} = {g}, expected {e}\n"
                            f"All signals: {dict(zip(SIGNALS, got))}")
    dut._log.info(f"All {len(VECTORS)} decoder tests passed")
