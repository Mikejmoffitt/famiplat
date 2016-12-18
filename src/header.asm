.segment "HEADER"
; Borrowed from https://github.com/furrykef/pacman

; Magic cookie
.byte "NES", $1a

; 4: Size of PRG in 16 KB units
.byte 32

; 5: Size of CHR in 8 KB units (0 = CHR RAM)
.byte 0

; 6: Mirroring, save RAM, trainer, mapper low nybble
.byte $21					; UxROM

; 7: Vs., PlayChoice-10, NES 2.0, mapper high nybble
.byte $0B					; UxROM

; 8:
.byte $00

; 9: NTSC
.byte 00

.byte $07
.byte $07
.byte %00000010
.byte $00
.byte $00
.byte $00

