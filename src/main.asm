; iNES Header
.segment "FIXED"

bank_load_table:
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
	.byte 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
.include "nes.asm"
.include "header.asm"
.include "ram.asm"
.include "cool_macros.asm"
.include "utils.asm"
.include "bg.asm"
.include "metasprite.asm"
.include "player.asm"
.include "sound.asm"

.segment "FIXED"
; ============================
; PRG bank F
;
; Bank F is hardwired to $C000 - $FFFF, and is where the boot code resides.
; Subsequently all code in Bank F is accessible when any bank is active. Common
; utility code should go here.
; ============================

; ============================
; NMI ISR
; This is run once per frame - it will allow any function spinning on the
; vblank_flag variable to proceed.
;
; For frame synchronization, call wait_nmi:
;
;	jsr wait_nmi
; ============================
nmi_vector:
	pha				; Preseve A
	php
	
	lda #$00
	sta PPUCTRL			; Disable NMI
	sta vblank_flag

	lda #$80			; Bit 7, VBlank activity flag
@vbl_done:
	bit PPUSTATUS			; Check if vblank has finished
	bne @vbl_done			; Repeat until vblank is over

	lda ppuctrl_config
	sta PPUCTRL			; Re-enable NMI

	plp
	pla				; Restore registers from stack

	rti

; ============================
; IRQ ISR
; Unused; can be wired to cartridge for special hardware. The UNROM mapper does
; not use the IRQ pin for anything like scanline interrupts or timers, etc.
; ============================
irq_vector:
	rti

; ============================
; Entry vector
; ============================

reset_vector:
; Basic 6502 init, straight outta NESDev
	sei				; ignore IRQs
	cld				; No decimal mode, it isn't supported
	ldx #%00000100
	stx $4017			; Disable APU frame IRQ

	ldx #$ff
	txs				; Set up stack

; Clear some PPU registers
	inx				; X = 0 now
	stx PPUCTRL			; Disable NMI
	stx PPUMASK			; Disable rendering
	stx DMCFREQ			; Disable DMC IRQs

; Wait for first vblank
@waitvbl1:
	lda #$80
	bit PPUSTATUS
	bne @waitvbl1

; Wait for the PPU to go stable
	txa				; X still = 0; clear A with this
@clrmem:
	sta $000, x
	sta $100, x
	; Reserving $200 for OAM display list
	sta $300, x
	sta $400, x
	sta $500, x
	sta $600, x

	inx
	bne @clrmem

; One more vblank
@waitvbl2:
	lda #$80
	bit PPUSTATUS
	bne @waitvbl2

; PPU configuration for actual use
	ldx #%10010000         ; Nominal PPUCTRL settings:
	;     |||||||___________ Nametable at $2000
	;     ||||||____________ VRAM inc at 1
	;     |||||_____________ SPR at $0000
	;     ||||______________ BG at $1000
	;     |||_______________ 8x8 Sprites
	;     ||________________ Slave mode (don't change this!)
	;     |_________________ NMI enable
	stx ppuctrl_config
	stx PPUCTRL

	ldx #%00011110
	;     ||||||||__________ Greyscale off
	;     |||||||___________ BG left column
	;     ||||||____________ SPR left column
	;     |||||_____________ BG enable
	;     ||||______________ SPR enable
	;     |||_______________ No red emphasis
	;     ||________________ No green emphasis
	;     |_________________ No blue emphasis
	stx ppumask_config

	stx PPUMASK

	jsr spr_init

	ppu_enable

; Build button comparison table
	lda #$80
	ldx #$00
@build_controller_table:
	sta button_table, x
	inx
	lsr
	bne @build_controller_table
	jmp main_entry ; GOTO main loop

; =============================================================================
; ====                                                                     ====
; ====                            Program Begin                            ====
; ====                                                                     ====
; =============================================================================
main_entry:

	; The PPU must be disabled before we write to VRAM. This is done during
	; the vertical blanking interval typically, so we do not need to blank
	; the video in the middle of a frame.
	ppu_disable

	; Switch the upper half of PRG memory to Bank E (please see note below)
	;lda #$0E
	;sta bank_load_table + $0E
	bank_load #$13

	; Load in a palette
	ppu_load_bg_palette sample_palette_data
	ppu_load_spr_palette sample_spr_palette_data
	
	; Load in CHR tiles to VRAM for BG
	; Remember, BG data starts at $0000 - we must specify the upper byte of
	; the destination address ($00).
	ppu_write_32kbit sample_chr_data, #$00

	; and for sprites, which start at $1000.
	ppu_write_32kbit sample_chr_data + $1000, #$10

	; Finally, bring in a nametable so the background will draw something.
	; The first nametable begins at $2000, so we specify $20(00).

;	lda #$0E
;	sta current_nt_bank
;	lda #<nt2
;	sta current_nt
;	lda #>nt2
;	sta current_nt+1
;	lda #$24
;	jsr load_Room

	lda #$13
	sta current_nt_bank
	lda #<ntcomp
	sta current_nt
	lda #>ntcomp
	sta current_nt+1
	lda #$20
	jsr decomp_room
	
	lda #<col_map
	sta current_nt
	lda #>col_map
	sta current_nt+1

	lda #$00
	sta xscroll
	sta yscroll
	sta yscroll+1
	sta xscroll+1

	lda #$80
	sta player_xpos + 1
	sta player_ypos + 1
	sta player_xpos
	sta player_ypos

	lda $5555
	; Make some noise
	ldx #<testmus_music_data
	ldy #>testmus_music_data
	lda #80
	jsr FamiToneInit
	;lda #80
	lda #$00
	jsr FamiToneMusicPlay

	; Bring the PPU back up.
	jsr wait_nmi
	ppu_enable

main_top_loop:

	; Run game logic here
	jsr read_joy_safe
	jsr player_movement
	jsr player_render
	jsr eval_leaving_room
	jsr FamiToneUpdate

	; End of game logic frame; wait for NMI (vblank) to begin
	jsr wait_nmi

	; Commit VRAM updates while PPU is disabled in vblank
	ppu_disable

	spr_dma
	ppu_load_scroll xscroll, yscroll

	; Re-enable PPU for the start of a new frame
	ppu_enable

	jmp main_top_loop; loop forever


; While our main code is in Bank F, the simple palette data (colors),
; CHR data (graphics), and Nametable data (layout) is located in another
; bank.
; Addresses $C000-$FFFF are hardwired to Bank F in the 2A03's data space "PRG",
; but the upper half of ROM space at $8000-BFFF can be switched out when the
; programmer desires. 

; =====================================
; Nametable in current_nt, bank in current_nt_bank, destination in A ($20 or $24)
load_room:
	tay
	bank_load current_nt_bank
	tya
	ldy current_nt
	sty addr_ptr
	ldy current_nt+1
	sty addr_ptr+1

	bit PPUSTATUS
	sta PPUADDR
	ldy #$00
	sty PPUADDR

:
	lda (addr_ptr), y		; Offset within both source and dest.
	sta PPUDATA
	iny
	bne :-
	add16 addr_ptr, #$80
	add16 addr_ptr, #$80
:
	lda (addr_ptr), y		; Offset within both source and dest.
	sta PPUDATA
	iny
	bne :-
	add16 addr_ptr, #$80
	add16 addr_ptr, #$80
:
	lda (addr_ptr), y		; Offset within both source and dest.
	sta PPUDATA
	iny
	bne :-
	add16 addr_ptr, #$80
	add16 addr_ptr, #$80
:
	lda (addr_ptr), y		; Offset within both source and dest.
	sta PPUDATA
	iny
	bne :-
	add16 addr_ptr, #$80
	add16 addr_ptr, #$80

	rts

eval_leaving_room:
	rts
	lda player_xpos+1
	cmp #248
	bcc @not_rightside
@rightside:
	jsr wait_nmi
	ppu_disable
	lda #$0E
	sta current_nt_bank
	lda #<nt2
	sta current_nt
	lda #>nt2
	sta current_nt+1
	lda #$24
	jsr load_room
	lda #16
	sta player_xpos+1
	lda #10
	sta player_xpos
	rts

@not_rightside:
	cmp #08
	bcc @leftside
	rts

@leftside:
	jsr wait_nmi
	ppu_disable
	lda #$0E
	sta current_nt_bank
	lda #<nt1
	sta current_nt
	lda #>nt1
	sta current_nt+1
	jsr load_room
	lda #246
	sta player_xpos+1
	lda #$00
	sta player_xpos
	rts

testmus:
	.include "../resources/testmus.asm"


.segment "BANK13"

; The sample graphics resources.
sample_chr_data:
	.incbin "resources/chr.chr"

nt1:
	.incbin "resources/nametable.nam"
nt2:
	.incbin "resources/nametable2.nam"
ntcomp:
	.incbin "resources/nt_comp.bin"

sample_palette_data:
	.byte	$0F, $0B, $1A, $29
	.byte	$0F, $03, $14, $25
	.byte	$0F, $06, $16, $27
	.byte	$0F, $2C, $24, $2A

sample_spr_palette_data:
	.byte	$0F, $01, $30, $27
	.byte	$0F, $02, $24, $30
	.byte	$0F, $06, $26, $30
	.byte	$0F, $2C, $24, $2A
	; For a large project, palette data like this is often separated
	; into a separate file and .incbin'd in, just like the other data.

; These are needed to boot the NES.
.segment "VECTORS"

	.addr	nmi_vector	; Every vblank, this ISR is executed.
	.addr	reset_vector	; On bootup or reset, execution begins here.
	.addr	irq_vector	; Triggered by external hardware in the
				; game cartridge, this ISR is executed. A
				; software break (BRK) will do it as well.
