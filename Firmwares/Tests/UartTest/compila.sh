#!/bin/bash

ca65 uartTest.s -l uartTest.lst
if [[ $? -eq 0 ]]; then
    ld65 -C uart.cfg  uartTest.o
    if [[ $? -eq 0 ]]; then
        hexdump a.out
    else
        echo "Linker failed..."    
    fi
else
    echo "Compilation failed..."    
fi    
