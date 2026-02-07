if [ ! -d tmp ]; then
	mkdir tmp
fi
i="bios"
rm -Rf tmp/$i.*


echo $i
ca65 -I /usr/local/share/cc65/asminc -l $i.lst -D $i $i.s -o tmp/$i.o &&
ld65 -vm -m tmp/$i.map -C $i.cfg tmp/$i.o -o tmp/$i.bin -Ln tmp/$i.lbl

# For ROM
#bintomon -v -l 0xa000 -r 0xbd0d tmp/wozmon.bin > tmp/wozmon.mon
# For RAM
#bintomon -v -l 0x6000 -r 0x7d0d tmp/wozmon.bin > tmp/wozmon.mon
