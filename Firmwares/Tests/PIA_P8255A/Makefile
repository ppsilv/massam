all:	p8255a.mon

p8255a.mon: p8255a.bin
	bintomon -v p8255a.bin >p8255a.mon

p8255a.bin: p8255a.o
	ld65 -C p8255a.cfg -vm -m p8255a.map -o p8255a.bin p8255a.o

p8255a.o: p8255a.s
	ca65 -g -l p8255a.lst p8255a.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean

archive: all
	zip p8255a.zip p8255a.s *.mon  Makefile

grava:
	minipro -p SST39SF512 -w p8255a.bin