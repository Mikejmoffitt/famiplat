.segment "HEADER"

; Borrowed from https://github.com/furrykef/pacman

; Magic cookie
.byte "NES", $1a

; Size of PRG in 16 KB units
.byte 32

; Size of CHR in 8 KB units (0 = CHR RAM)
.byte 0

; Mirroring, save RAM, trainer, mapper low nybble
.byte $21                                   ; UOROM
;.byte $e1                                   ; UNROM-512

; Vs., PlayChoice-10, NES 2.0, mapper high nybble
.byte $00					; UOROM
;.byte $10					; UNROM-512
;.byte 

; Size of PRG RAM in 8 KB units
.byte 1

; NTSC/PAL
.byte $00
