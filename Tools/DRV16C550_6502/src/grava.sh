#!/bin/bash

#Força a gravação de arquivo de 32k no chip de 64k
./make.sh && minipro -p SST39SF512 -s -S -y -w tmp/bios.bin
