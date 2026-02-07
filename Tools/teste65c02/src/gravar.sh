#!/bin/bash

echo "Compile and record ."

./make.sh && minipro -p SST39SF512 -s -S -y -w tmp/test.bin
