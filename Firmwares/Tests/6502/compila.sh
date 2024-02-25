#!/bin/bash

echo "Assemblando wozmon.s"
ca65 wozmon.s -l wozmon.lst

echo "linkando wozmon.o"
ld65 -C linker.cfg wozmon.o

hexdump a.out
