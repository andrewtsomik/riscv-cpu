# Five Stage Pipelined RV32I Processor
Programmed in SystemVerilog, ran on an S7-25 FPGA, and verified with official RISC-V tests.

## Demo of Shadow Register Output over UART
https://github.com/user-attachments/assets/c123ed0f-9343-433f-8851-143eb074b562

## Results

| | |
|---|---|
| **ISA** | RV32I Base Integer Set, 38/38 RV32UI compliance tests passed |
| **Microarchitecture** | Five Stage Pipeline: forwarding, load-use interlock, branch flush |
| **Target** | Arty S7-25 |
| **Clock** | Timing closed with 100 MHz (WNS +0.043 ns) |
| **Resource Allocation** | 1,536 LUT, 715 FF, and 1 BRAM |
| **Verification** | CocoTB Python testbenches, riscv-tests compliance suite, and hardware readout over UART |

## FPGA Implementation

Synthesized in Vivado and result is read out of the register file over UART.

### Timing Closure

The first time I ran the CPU, I could not close time at 100 MHz and actually missed the timing by 1.636 ns.
The critical path ran from the forwarding comparator, through the ALU chain, into the branch condition logic, and back to the program counter in one cycle.

This was because in the ALU, the `zero` flag was based on the result of the ALU, specifically true when subtraction occurred and the result was 0.
The `zero` flag was forced to wait for the full 32-bit carry to propagate before the branch condition was known every `beq`/`bne` instruction.

Thus I changed the `zero` flag to compare the operands instead of looking at the result.
This let the `zero` flag resolve in parallel with the ALU.

#### Before
```systemverilog
assign zero = (result == 32'd0);
```

#### After
```systemverilog
assign zero = (o1 == o2);
```

After making this change, I was able to close timing at 100 MHz.

| | WNS | Logic Levels |
|---|---|---|
| Before | -1.636 ns | 18 |
| After | +0.495 ns | 10 |

### The Decision To Use BRAM instead of LUTs

The instruction memory initially synthesized to 560 LUTs of distributed RAM because the read was combinational and BRAM is synchronous for FPGAs.
My thought was that by freeing up LUTs and using BRAM, I could have better timing and, as a result, increase the clock frequency.
Converting to BRAM meant that the instruction arrives one cycle after the PC that asked for it. To keep the PC aligned with its instruction required an extra delay, in the form of a register, and flush had to cover an extra cycle since one more incorrectly fetched instruction is already inside of the memory's output register when a branch resolves.
But the results disproved my hypothesis.

| | Before | After |
|---|---|---|
| LUTs | 1,707 | 1,536 |
| LUTs of Distributed RAM | 560 | 560 |
| Registers | 565 | 715 |
| BRAM | 0 | 1 |
| WNS | +0.204 ns | +0.043 ns |
| Branch Penalty | 2 instructions | 3 instructions |

I did free 171 LUTs and gained 1 BRAM but the amount of LUTs of distributed RAM stayed the same and the timing actually became worse.
The BRAM's clock-to-output delay and pipeline registers offset the improvements made to the routing.

Data memory was left as distributed RAM. Making the same changes to it that I made to instruction memory would push a cycle of latency into the load path and interact with the load-use interlock. The results from the instruction memory changes also gave no indication that changing data memory the same way would achieve the desired result of my hypothesis.

### Hardware Verification

I implemented a UART transmitter with a four state FSM which reported the compliance result from the board.
I added a "shadow" register which captures `x3` from the register whenever write-back targets it.

```systemverilog
always_ff @(posedge clk or posedge rst) begin
    if(rst)
        x3_shadow <= '0;
    else if(mem_wb_reg.reg_wr && mem_wb_reg.wr_addr == 5'd3)
        x3_shadow <= wr_dt;
end
```

Running `rv32ui-p-add` on hardware streams `0x31` at 115200 baud.
This confirms all 38 compliance tests pass on the board.

## Structure
Implemented a five stage pipeline for the CPU with hazard handling.
### Diagram (Created by Claude Opus 5)
<img width="1345" height="634" alt="image" src="https://github.com/user-attachments/assets/31581d75-bb36-42a0-b1ef-cba23776d12a" />

### Fetch
Computes PC+4 and decides whether the next PC will be sequential, branch target, or jump target. Also the instruction memory read uses BRAM so the PC is delayed one cycle to stay aligned with its instruction.
### Decode
Produces every signal the later stages need and deciphers the fetched instruction into something the CPU can understand.
### Execute
The decoded instruction is evaluated here using the ALU, operand muxes, and forwarding muxes. Branches and jumps are also resolved here which feed back into the fetch stage.
### Memory
Byte enables handle sized stores, loads get extracted and sign or zero extension happens here so Write-Back can receive a normal 32-bit value.
### Write-Back
A 4x1 mux is used here to decide what should be sent back to the register file in decode. Decides between the ALU result, memory data, PC+4, and the immediate.

## Hazard Handling
This is needed as having overlapping instructions requires a result from a nearby instruction that hasn't been written yet.

### Data Hazards
Forwarding routes the needed value from where it already exists in the pipeline. The sources for these values are the Memory stage and Write-Back stage where the Memory stage takes priority if both match as it's the more recent instruction.
This is not sufficient for handling overlapping instruction though, we also need to cover load-use hazards.
Each forwarding condition also required three guards, `reg_wr` only forwarded from instruction that write a register, `wr_addr != 0` since `x0` is hardwired to 0 thus accidentally forwarding it would corrupt the read, and the destination address must match the source address being read.
There is also a register file bypass which is used to cover the case when an instruction is three slots behind its producer and reads the register file in the same cycle the write happens, by the time it reaches the Execute stage, the producer has left the pipeline so there is nothing to forward from unless we add a bypass where it returns the value being written when the addresses match in the same cycle.

### Load-Use Hazard
Load-Use covers the case where a load's data doesn't exist yet until the end of the Memory stage, so the instruction behind it has nothing to forward from yet.
We solve this by holding the front of the pipeline and bubbling ID/EX to allow for the one cycle that the loaded value needs to exist.
After that MEM/WB forwarding delivers the value normally.

### Control Hazards
Branches resolve in Execute rather than Memory, which reduces the penalty of control hazards.
We need to be able to kill the previous instructions in the pipeline to make sure the wrong path that was already fetched cannot be used.
By flushing a pipeline register, an instruction is killed since a zeroed register has `reg_wr = 0`, `mem_wr = 0`, and `branch = 0`, so nothing is written, stored, or redirected anywhere.
Flush spans two cycles because of the latency caused by BRAM, so three instructions are discarded on every taken branch.

## Verification

### Testbenches
Every module was written with a CocoTB testbench alongside it. I used Python because writing reference models and generating test programs is much easier there than in SystemVerilog, and I could encode instructions directly in the testbench instead of hand-assembling everything.

The single-cycle version of this CPU was built and verified first, then pipelined. Since a correct pipeline has to produce the same results as the single-cycle core on the same programs, the existing test suite became the regression check for the pipelined version. Every hazard bug I introduced showed up as a test that used to pass and suddenly didn't, which made them much easier to find.

### riscv-tests
The CPU passes 38/38 of the `rv32ui` tests from the official RISC-V test suite. These matter more than my own tests because they were written by the people who defined the ISA and cover edge cases I would not have thought to write, like writes to `x0`, overflow boundaries, and back to back dependency chains.

Getting them running took some work. The stock `env/p` target assumes machine mode: it sets up CSRs like `mtvec` and `mcause`, installs a trap vector, returns with `mret`, links at `0x80000000`, and reports results by storing to a `tohost` address about 4KB above the code. My core has none of that, so I wrote a replacement `riscv_test.h` and linker script that:

- link at address `0x0`, where my PC resets to
- remove all CSR access and trap handling
- report pass/fail in `x3` instead of a memory location

The last one is convenient. riscv-tests already puts the current sub-test number in `x3` as it runs, so on a failure that register tells me exactly which sub-test broke, not just that something did. On success the test writes 1 and spins.

Since my core is Harvard, the same program image has to be loaded into both instruction and data memory. riscv-tests link their data sections into the text image, so without this every load returns zero.

### Hardware
Simulation passing is not the same as silicon working, so the last check was reading the compliance result off the board itself over UART. That is covered in the FPGA section above.

### A note on the unit tests
The module-level unit tests in this repo are stale. As the design evolved I added decoder outputs, ALU operations, and memory ports, and renamed signals, and I chose not to keep those testbenches updated. The full-core tests and the compliance suite exercise every module in context and far more thoroughly, so maintaining a second, weaker set of tests was not worth the time.

## Design Decisions

### The Decoder Owns All Instruction-Format Knowledge
No stage past Decode ever looks at raw instruction bits. This is why the decoder outputs `branch_op` and a `jalr` flag instead of Execute slicing `funct3` and comparing opcodes itself, and why `mem_size` carries the load/store width down to the Memory stage.

### Instructions Only Share A `case` Branch If Every Signal Matches
I got caught by this three times, with OP_IMM and AUIPC, JAL and JALR, and again when `mem_size` was added. Two instructions that agree on nine signals and differ on one cannot be grouped, and the bug it causes is silent.

### Harvard Architecture
Separate instruction and data memories avoid the structural hazard of Fetch and Memory contending for a single port every cycle, which is the same reason real cores split L1 into instruction and data caches. The trade-off is the one described above, where unified program images have to be loaded into both.

### Branches Resolve In Execute
This is as early as possible given that the comparison needs the ALU flags. Resolving in Memory would cost an extra instruction on every taken branch.

### A Zeroed Pipeline Register Is A Nop By Construction
Because a zeroed struct has `reg_wr = 0`, `mem_wr = 0`, `branch = 0` and `jump = 0`, the same `'0` assignment serves reset, stall bubbles, and branch flushes. No separate nop encoding is needed.

### Control Signals Thin Out As They Are Consumed
ALU controls appear in `id_ex_t` and disappear from `ex_mem_t`. Memory controls stop at `ex_mem_t`. Only the destination register and write-back controls travel the full length of the pipeline. A signal riding further than the stage that uses it is a sign something is wrong.

## Limitations

### No M Extension
Multiply and divide are not implemented. The interesting part of M is an iterative divider that stalls the pipeline, which I would want to build properly rather than as a single-cycle shortcut.

### `fence`, `ecall` and `ebreak` Are Stubbed
Each only means something in a context this core does not have: memory reordering, an operating system, and a debugger respectively.

### Misaligned Accesses Are Ignored
A misaligned halfword store writes nothing rather than trapping, since there is no trap machinery to trap into.

### Data Memory Is Still Distributed RAM
For the reasons described in the BRAM section above.

### No Branch Prediction
Every taken branch costs three instructions.

## Repository Layout

```
rtl/          SystemVerilog source
constraints/  Arty-S7-25-Master.xdc, pin and clock constraints
tests/        CocoTB testbenches and Makefile
programs/     hex test programs
programs/isa/ generated riscv-tests images
rvenv/        bare-metal riscv-tests environment and build script
```

## Running the Tests

The instruction memory takes its hex file as a runtime plusarg, so one testbench can run any program:

```bash
cd tests
make MODULE=test_shift PLUSARGS=+HEX=../programs/shift.hex
```

The full suites:

```bash
./tests.sh      # CPU-level tests
./run_isa.sh    # builds and runs all 38 riscv-tests
```

`run_isa.sh` needs a RISC-V toolchain on the path and a checkout of riscv-tests.

## Building for FPGA

I used Vivado 2026.1 with an Arty S7-25.

1. Create an RTL project targeting `xc7s25csga324-1`, or select the Arty S7-25 board directly if you have the Digilent board files installed.
2. Add every file in `rtl/` as a design source and set `cpu_top` as the top module.
3. Add `constraints/Arty-S7-25-Master.xdc` as a constraints source.
4. Pick a program to bake into the bitstream, such as `programs/isa/rv32ui-p-add.hex`, and point both memories at it.
5. Run synthesis, implementation, and generate a bitstream.
6. Program the board and open a serial terminal on its COM port at 115200 8N1.

There are two things here that cost me time, so I want to point them out.

### The hex path is hardcoded
Both `instruct_mem.sv` and `data_mem.sv` have an absolute path inside their `` `ifdef SYNTHESIS `` branch.

```systemverilog
$readmemh("C:/riscv-fpga/program.hex", arr);
```

In simulation the program is chosen at runtime with a plusarg, but synthesis needs the filename fixed when the bitstream is built, so I hardcoded a path on my machine. If you build this yourself you need to change it in both files.

### The design needs an output or it gets deleted
Synthesis removes any logic that does not eventually drive a pin. My `cpu_top` originally only had `clk` and `rst`, so Vivado decided the whole processor was unobservable and deleted it. My first implementation reported 1 LUT, 4 flip flops, and no timing endpoints at all.

The LED and UART outputs are what keep the design alive, but the value driving them has to trace back through the datapath. I first tried driving the LEDs from the PC and that was not enough, since the PC only depends on the branch and jump signals so everything else still got stripped. Driving them from the write-back value keeps the register file, ALU, and memories in the design.
