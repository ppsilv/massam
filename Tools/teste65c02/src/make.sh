if [ ! -d tmp ]; then
	mkdir tmp
fi
i="test"
rm -Rf tmp/$i.*


#Constroy o binario

echo $i
ca65 -I /usr/share/cc65/asminc -l $i.lst -D $i $i.s -o tmp/$i.o &&
ld65 -vm -m tmp/$i.map -C $i.cfg tmp/$i.o -o tmp/$i.bin -Ln tmp/$i.lbl
