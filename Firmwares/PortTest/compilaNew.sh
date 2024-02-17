#!/bin/bash

echo "Assemblando wozmon.s"
ca65 wozmonNew.s -l wozmonNew.lst

echo "linkando wozmon.o"
ld65 -C linkerNew.cfg wozmonNew.o

hexdump a.out
