@echo off

REM resources

tools\rle_nt\comp.exe resources\nametable.nam resources\nt_comp.bin


REM assemble
tools\cc65\ca65 src\main.asm -g -I src -o main.o

REM link
tools\cc65\ld65 -C ldscripts\nes.ld -o main.nes -vm main.o
