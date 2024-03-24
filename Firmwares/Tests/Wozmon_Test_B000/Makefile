all:	wozmon.mon

wozmon.mon: wozmon.bin
	bintomon -v wozmon.bin >wozmon.mon

wozmon.bin: wozmon.o bios.o
	ld65 -C wozmon.cfg -vm -m wozmon.map -o wozmon.bin wozmon.o bios.o -Ln wozmon.sym

wozmon.o: wozmon.s
	ca65 -g -l wozmon.lst wozmon.s

bios.o: bios.s
	ca65 -g -l bios.lst bios.s

#House keeping
clean:
	$(RM) *.o *.lst *.mon *.map *.bin *.sym

distclean: clean

archive: all
	zip wozmon.zip wozmon.s *.mon  Makefile

grava:
	minipro -p SST39SF512 -w wozmon.bin