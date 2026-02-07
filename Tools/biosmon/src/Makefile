all: bios.bin

bios.bin: bios.o
	ld65 -C bios.cfg -vm -m bios.map -o bios.bin bios.o -Ln tmp/bios.sym

bios.o: bios.s
	ca65 -g -l bios.lst bios.s

#House keeping
clean:
	$(RM) *.o *.lst *.mon *.map *.bin *.sym

distclean: clean

archive: all
	zip bios.zip bios.s  cmd_cblock.s  cmd_dump.s  cmd_echo.s  cmd_fill.s  cmd_peek.s  cmd_poke.s  cmd_run.s  disasm.s  drv16550.s  mem_test.s  miniasm.s  utils.s   Makefile

grava:
	minipro -p SST39SF512 -w bios.bin