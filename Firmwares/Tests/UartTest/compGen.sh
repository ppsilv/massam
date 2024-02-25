#!/bin/bash

echo "Compiling $1.s"

ca65 $1.s -l $1.lst
if [[ $? -eq 0 ]]; then
    ld65 -C uart.cfg  $1.o
    if [[ $? -eq 0 ]]; then
        hexdump a.out
    else
        echo "Linker failed..."    
    fi
else
    echo "Compilation failed..."    
fi    
echo "All compiled OK..."
