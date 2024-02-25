if [ ! -d tmp ]; then
	mkdir tmp
fi

for i in hmc56; do

echo $i
ca65 -D $i msbasic.s -l $i.lst -o tmp/$i.o &&
ld65 -C $i.cfg tmp/$i.o -o tmp/$i.bin -Ln tmp/$i.lbl

done

