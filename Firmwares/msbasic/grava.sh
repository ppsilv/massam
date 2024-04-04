#!/bin/bash



#echo "Gravando para endereço 0000 da eprom."
#grava em 0000
#./make.sh && minipro -p SST39SF512 -s -S -y -w tmp/osi.bin

echo "Gravando para endereço C000 da eprom."
#grava em 8000
./make.sh && minipro -p SST39SF512 -w tmp/osi.bin

