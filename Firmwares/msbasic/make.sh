if [ ! -d tmp ]; then
	mkdir tmp
fi

echo "apagando todos os arquivos de tmp..."
rm tmp/*

#for i in cbmbasic1 cbmbasic2 kbdbasic osi kb9 applesoft microtan; do
for i in osi; do
echo "Compilando $i."

echo $i
ca65 -I /usr/share/cc65/asminc -l msbasic.lst -D $i msbasic.s -o tmp/$i.o &&
ld65 -vm -D cpu=6502 -m tmp/$i.map -C osi.cfg tmp/$i.o -o tmp/$i.bin -Ln tmp/$i.lbl
done

# For ROM
#bintomon -v -l 0xa000 -r 0xbd0d tmp/osi.bin > tmp/osi.mon
# For RAM
#bintomon -v -l 0x6000 -r 0x7d0d tmp/osi.bin > tmp/osi.mon
