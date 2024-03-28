#!/bin/bash
rm tmp/pdsilva.*
./make.sh
minipro -p SST39SF512 -w tmp/osi.bin
