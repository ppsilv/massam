#!/bin/bash

echo "Compila e grava na memoria."
#Grava em 32k inferior da memoria
./make.sh && minipro -p SST39SF512 -s -S -y -w tmp/bios.bin
