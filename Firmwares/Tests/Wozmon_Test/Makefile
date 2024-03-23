all:	wozmon.mon

wozmon.mon: wozmon.bin
	bintomon -v wozmon.bin >wozmon.mon

wozmon.bin: wozmon.o ser16550.o
	ld65 -C wozmon.cfg -vm -m wozmon.map -o wozmon.bin wozmon.o ser16550.o -Ln wozmon.sym

wozmon.o: wozmon.s
	ca65 -g -l wozmon.lst wozmon.s

ser16550.o: ser16550.s
	ca65 -g -l ser16550.lst ser16550.s

#House keeping
clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean

archive: all
	zip wozmon.zip wozmon.s *.mon  Makefile

grava:
	minipro -p SST39SF512 -w wozmon.bin