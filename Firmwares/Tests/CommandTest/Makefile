all:	command.mon

command.mon: command.bin
	bintomon -v command.bin >command.mon

command.bin: command.o
	ld65 -C command.cfg -vm -m command.map -o command.bin command.o

command.o: command.s
	ca65 -g -l command.lst command.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean

archive: all
	zip command.zip *.s *.mon  Makefile

grava:
	minipro -p SST39SF512 -w command.bin
