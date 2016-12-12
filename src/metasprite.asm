METASPRITE_MAX_TILES = (24*4)

.segment "BANKF"
; Draws a metasprite to the screen. 
; Preconditions:
;	Put screen X in temp and screen Y in temp2.
;	Temp3 flips about the Y axis (horizontally)
;	Temp4 has the starting sprite number.
;	Put the metasprite structure's address in addr_ptr
draw_metasprite:

	; Normalize the flip flag to exactly #$40
	lda temp3
	beq @post_flip_fix
	lda #$40
	sta temp3
@post_flip_fix:

	lda temp4
	asl
	asl
	tay
	sta temp4
	sub16 addr_ptr, temp4
	lda temp4
	clc
	adc #METASPRITE_MAX_TILES
	sta temp4
	

@oam_copy_loop:
	; Y = OAM Y position
	lda (addr_ptr), y		; Y pos relative to metasprite
	cmp #MAP_END			; Check unused flag
	beq @end_frame			; Y-Pos was MAP_END; terminate loop
	clc
	adc temp2			; Offset from sprite's Y center
	sbc yscroll			; Factor in scrolling position
	sta OAM_BASE, y
	iny				; Y = OAM tile select

	lda (addr_ptr), y
@tile_store:
	sta OAM_BASE, y
	iny				; Y = OAM attributes
	lda (addr_ptr), y

	; Process X flip for attributes
	eor temp3 ; X flip
	sta OAM_BASE, y
	iny				; Y = OAM X position

	; Check if tile position needs to be flipped about Y axis (horiz)
	lda temp3
	beq @noflipx
	lda #$00
	sec
	sbc (addr_ptr), y		; Reverse relative X position
	sec
	sbc #$08
	;sec
	;sbc xscroll			; Factor in scrolling position
	clc
	adc temp; Offset from sprite's X center
@no_x_overflow:
	sta OAM_BASE, y
	iny
	cpy temp4
	bne @oam_copy_loop
	rts

@noflipx:
	lda (addr_ptr), y		; X pos relative to metasprite
	clc
	adc temp			; Offset from sprite's X center
	;sec
	;sbc xscroll			; Factor in scrolling position
	sta OAM_BASE, y
	iny

	cpy temp4
	bne @oam_copy_loop
	rts

; This branch is for when a sprite is to be hidden so we can ignore everything
; other than the Y position
@end_frame:
	lda #$FF
	sta OAM_BASE, y			; Hide this sprite
	iny
	iny
	iny
	iny
	cpy temp4			; Hide all remaining sprites
	bne @end_frame			; for this metasprite.
	rts

