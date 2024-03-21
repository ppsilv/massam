all:	cpuTest.mon

cpuTest.mon: cpuTest.bin
	bintomon -v cpuTest.bin >cpuTest.mon

cpuTest.bin: cpuTest.o
	ld65 -C cpuTest.cfg -vm -m cpuTest.map -o cpuTest.bin cpuTest.o

cpuTest.o: cpuTest.s
	ca65 -g -l cpuTest.lst cpuTest.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean

archive: all
	zip cpuTest.zip cpuTest.s *.mon  Makefile

grava:
	minipro -p SST39SF512 -w cpuTest.bin