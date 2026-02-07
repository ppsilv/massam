if [ ! -d tmp ]; then
	mkdir tmp
fi
i="bios"
rm -Rf tmp/$i.*


#Constroy o binario

echo $i
#ca65 -I /usr/share/cc65/asminc -l $i.lst -D $i $i.s -o tmp/$i.o &&
ca65 -g -l tmp/$i.lst -D $i $i.s -o tmp/$i.o &&
ld65 -C $i.cfg -vm  -m tmp/$i.map  -o tmp/$i.bin tmp/$i.o  -Ln tmp/$i.sym 

# For ROM
#bintomon -v -l 0xa000 -r 0xbd0d tmp/wozmon.bin > tmp/wozmon.mon
# For RAM
#bintomon -v -l 0x6000 -r 0x7d0d tmp/wozmon.bin > tmp/wozmon.mon
