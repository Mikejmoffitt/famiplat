# CA65 configuration script for UOROM
# Based on Damian Yerrick's original script
# The original copyright information is reproduced at the bottom
# of this linker script.

MEMORY
{
    # RAM
    ZEROPAGE:   start = 0, size=$100, file="";
    STACK:      start = $100, size=$100, file="";
    OAM:        start = $200, size=$100, file="";
    RAM:        start = $300, size=$500, file="";
	WRAM:		start = $6000, size=$2000, file="";

    # ROM
    HEADER:     start = 0, size=$10, fill=yes, fillval=$FF;
    ROM0:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$00;
    ROM1:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$01;
    ROM2:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$02;
    ROM3:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$03;
    ROM4:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$04;
    ROM5:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$05;
    ROM6:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$06;
    ROM7:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$07;
    ROM8:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$08;
    ROM9:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$09;
    ROMA:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$0A;
    ROMB:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$0B;
    ROMC:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$0C;
    ROMD:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$0D;
    ROME:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$0E;
    ROMF:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$0F;
    ROM10:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$10;
    ROM11:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$11;
    ROM12:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$12;
    ROM13:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$13;
    ROM14:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$14;
    ROM15:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$15;
    ROM16:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$16;
    ROM17:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$17;
    ROM18:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$18;
    ROM19:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$19;
    ROM1A:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$1A;
    ROM1B:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$1B;
    ROM1C:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$1C;
    ROM1D:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$1D;
    ROM1E:      start = $8000, size = $4000, type = ro, file = %O, fill=yes, fillval=$1E;
    ROM1F:      start = $C000, size = $4000, type = ro, file = %O, fill=yes, fillval=$1F;
}

SEGMENTS
{
    ZEROPAGE:  load = ZEROPAGE, type=zp;
    RAM:       load = RAM, type=bss, define = yes, align = $100;
	WRAM:      load = WRAM, type=bss, define = yes, align = $100;

    HEADER:	   load = HEADER;

    BANK0:     load = ROM0, type = ro, align = $100, optional = yes;
    BANK1:     load = ROM1, type = ro, align = $100, optional = yes;
    BANK2:     load = ROM2, type = ro, align = $100, optional = yes;
    BANK3:     load = ROM3, type = ro, align = $100, optional = yes;
    BANK4:     load = ROM4, type = ro, align = $100, optional = yes;
    BANK5:     load = ROM5, type = ro, align = $100, optional = yes;
    BANK6:     load = ROM6, type = ro, align = $100, optional = yes;
    BANK7:     load = ROM7, type = ro, align = $100, optional = yes;
    BANK8:     load = ROM8, type = ro, align = $100, optional = yes;
    BANK9:     load = ROM9, type = ro, align = $100, optional = yes;
    BANKA:     load = ROMA, type = ro, align = $100, optional = yes;
    BANKB:     load = ROMB, type = ro, align = $100, optional = yes;
    BANKC:     load = ROMC, type = ro, align = $100, optional = yes;
    BANKD:     load = ROMD, type = ro, align = $100, optional = yes;
    BANKE:     load = ROME, type = ro, align = $100, optional = yes;
    BANKF:     load = ROMF, type = ro, align = $100, optional = yes;
    BANK10:     load = ROM10, type = ro, align = $100, optional = yes;
    BANK11:     load = ROM11, type = ro, align = $100, optional = yes;
    BANK12:     load = ROM12, type = ro, align = $100, optional = yes;
    BANK13:     load = ROM13, type = ro, align = $100, optional = yes;
    BANK14:     load = ROM14, type = ro, align = $100, optional = yes;
    BANK15:     load = ROM15, type = ro, align = $100, optional = yes;
    BANK16:     load = ROM16, type = ro, align = $100, optional = yes;
    BANK17:     load = ROM17, type = ro, align = $100, optional = yes;
    BANK18:     load = ROM18, type = ro, align = $100, optional = yes;
    BANK19:     load = ROM19, type = ro, align = $100, optional = yes;
    BANK1A:     load = ROM1A, type = ro, align = $100, optional = yes;
    BANK1B:     load = ROM1B, type = ro, align = $100, optional = yes;
    BANK1C:     load = ROM1C, type = ro, align = $100, optional = yes;
    BANK1D:     load = ROM1D, type = ro, align = $100, optional = yes;
    BANK1E:     load = ROM1E, type = ro, align = $100, optional = yes;

    FIXED:     load = ROM1F, type = ro, start = $c000;
    VECTORS:    load = ROM1F, type = ro, start = $fffa;

}

# Copyright 2010 Damian Yerrick
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice and this notice are preserved.
# This file is offered as-is, without any warranty.
#
