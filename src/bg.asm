
; =====================================
; Compressed nametable in current_nt, bank in current_nt_bank, writes to col_map	
; addr_ptr: write destionation
; temp: pattern first byte
; temp2: pattern second byte
; temp3: pattern repeat counter
; temp4: iteration counter

; temp6: read ptr low;
; temp7: read ptr hi

.macro decomp_unroll

	; Get 16-bit pattern from compressed NT
	lda (temp6), y
	sta temp
	iny
	lda (temp6), y
	sta temp2
	iny
	
	; Get repetition count from compressed NT
	lda (temp6), y
	sta temp3
	ldy #$00
	
	; Move read pointer forwards 3
	add16 temp6, #$03
	
:
		; Write first byte of pattern
		lda temp
		sta PPUDATA
		sta (addr_ptr), y
		iny
		
		lda temp2
		sta PPUDATA
		sta (addr_ptr), y
		dey
		add16 addr_ptr, #$02
		
	; Decrement repeat counter, loop if needed
	dec temp3
	bne :-
.endmacro

; =======================================
; Routine to decompress an RLE16 nametable into $2000 and put a shadow copy in
; col_map as well.
;	A: Bank map is stored in
;	X: Low byte of NT address
;	Y: High byte of NT address
decomp_room:
	; Get the nametable address in ZP
	stx temp
	sty temp7
	; Load bank for NT
	tax
	sta bank_load_table, x
	
	; Get set up to write to the nametable
	bit PPUSTATUS ; Reset address latch
	lda #$20
	sta PPUADDR ; Write $2000 to
	ldy #$00
	sty PPUADDR ; PPUADDR latch
	sty temp4 ; Clear iteration counter
	
	; Set up addr_ptr as our write destination
	lda #<col_map
	sta addr_ptr
	lda #>col_map
	sta addr_ptr+1
	
@decomp_top:
	decomp_unroll
	decomp_unroll
	decomp_unroll
	decomp_unroll
	
	inc temp4
	lda temp4
	cmp #$40
	beq @finished
	jmp @decomp_top
	
@finished:
	lda #<col_map
	sta current_nt
	lda #>col_map
	sta current_nt+1
	
	rts
