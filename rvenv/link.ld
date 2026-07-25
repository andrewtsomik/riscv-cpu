OUTPUT_ARCH("riscv")
ENTRY(_start)

SECTIONS{
	. = 0x00000000;
	.text.init : {*(.text.init)}
	.text : {*(.text) *(.text.*)}
	. = ALIGN(4);
	.data : {*(.data) *(.data.*) *(.sdata) *(.sdata.*) *(.rodata) *(.rodata.*)}
	. = ALIGN(4);
	.bss : {*(.bss) *(.bss.*) *(.sbss) *(.sbss.*)}
	_end = .;
}
