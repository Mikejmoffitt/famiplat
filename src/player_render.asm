
; Animation and rendering related player code

; Responsible for drawing both players to the screen based on state structs.
; No particular pre-conditions; this is a wrapper for the various subroutines
; which draw both players to the screen.
player_render:
	jsr player_choose_animation
	jsr player_choose_mapping
	jsr player_animate
	jsr player_draw
	rts

; Based on player state (position, action, etc) choose an animation sequence
; to run. I
; Postconditions:
;	If appropriate, the player's animation number will have changed, and
;	the animation address will update as well.
player_choose_animation:
	lda #ANIM_RUN
	jsr player_set_anim_num
	rts

; Sets the player's animation to the number loaded in A. If the animation is
; already loaded, do nothing. Otherwise, reset animation counters.
; Preconditions:
;	A is loaded with the desired animation script
; Postconditions:
;	If a new animation is chosen, player_struct has these fields updated:
;		-Animation script address (ANIM_ADDR)
;		-Animation script length (ANIM_LEN)
;		-Animation number (ANIM_NUM)
;		-Animation frame accumulator (ANIM_CNT) (reset to zero)
;		-Animation frame number (ANIM_FRAME) (reset to zero)
player_set_anim_num:

	sta temp3				; Store number argument
	cmp player_anim_num
	beq @done	; If we're already in this animation, don't bother
	sta player_anim_num
	lda #$00
	sta player_anim_cnt
	sta player_anim_frame

	; First we need the address of the animation script from the map
	lda #<pl_anim_num_map
	sta addr_ptr
	lda #>pl_anim_num_map
	sta addr_ptr + 1

	; addr_ptr now contains the map address
	lda temp3
	asl a					; Multiply by two
	tay					; Get our animation # from A
	lda (addr_ptr), y			; Get lobyte
	sta player_anim_addr
	sta temp
	iny
	lda (addr_ptr), y			; Get hibyte
	sta player_anim_addr + 1
	sta temp2

	; The player struct now has a reference to the chosen animation script.
	; From that we can extract the length, but we need to put it into temp.

	ldy #$00				; First parameter is length.
	lda (temp), y				; A gets animation length
	sta player_anim_len

@done:
	rts

; Based on current animation number and frame number, choose a mapping to
; draw the player with.
; Preconditions:
;	X is loaded with the player struct offset
; Postconditions:
;	addr_ptr is loaded with the appropriate mapping
player_choose_mapping:

	; Get address of script into temp
	lda player_anim_addr
	sta temp
	lda player_anim_addr + 1
	sta temp2

	; Temp contains the script offset; we want the address of the first
	; mapping, which is $02 in

	add16 temp, #$02		; addr_ptr = script's first mapping

	lda player_anim_frame ; Get current frame #
	asl a
	asl a				; A = index into script for frame
					; A = current frame * 4
	sta temp3
	add16 temp, temp3		; addr_ptr = address of frame now


	; Temp has the address of the animation mapping now.

	ldy #$00
	lda (temp), y
	sta addr_ptr			; addr_ptr = lowaddr of mapping
	iny
	lda (temp), y
	sta addr_ptr+1			; addr_ptr+1 = hiaddr of mapping

	;addr_ptr now contains the mapping address.

	rts


; Have the player step through an animation script.
; Preconditions:
;	X is loaded with the player struct offset
;	ANIM_ADDROFF is loaded wtih a valid animation script address.
; Postconditions:
;	ANIM_CNTOFF has incremented, and if it's reached the current frame
;	  length, it will have reset to zero and incremented ANIM_FRAMEOFF.
;	ANIM_FRAMEOFF will reset to zero when it has reached the script length.
player_animate:

	; Get address of script into temp
	lda player_anim_addr
	sta temp
	lda player_anim_addr + 1
	sta temp2

	add16 temp, #$04		; Point at first frame's duration

	lda player_anim_frame ; Get current frame #
	asl a
	asl a				; A = index into script for frame
	sta temp3
	add16 temp, temp3

	; Temp points to the current frame's length
	ldy #$00
	lda (temp), y
	sta temp

	; Temp now contains the frame duration to compare against

	; Increment animation accumulator
	ldy player_anim_cnt
	iny
	cpy temp		; Have we reached the end of this frame?
	beq @frame_inc		; If so, increment frame number.
	; Otherwise, just increment the accumulator.
	sty player_anim_cnt
	rts

@frame_inc:
	lda #$00
	sta player_anim_cnt ; Reset frame accumulator
	ldy player_anim_frame
	iny
	tya
	cmp player_anim_len ; Is the animation over?
	beq @anim_loop	; If so, loop animation
	; Otherwise, just increment the frame number.
	sty player_anim_frame
	rts
@anim_loop:
	; Get address of script into temp
	lda player_anim_addr
	sta temp
	lda player_anim_addr + 1
	sta temp2

	add16 temp, #$01		; Point at the loop point

	ldy #$00
	lda (temp), y
	sta player_anim_frame
	rts

; Draws a player to the screen; called by players_draw.
; Preconditions:
;	addr_ptr is loaded with the address of the animation frame struct.
player_draw:
; Pre-loop entry conditions:
	; addr_ptr is a ZP 16-bit pointer to the base of the animation data to copy from
	; addr_ptr has initial Y subtracted from it to counter Y's offset
	; X contains the player state offset (right now it is zero and unused anyway)
	; temp contains Y + 64, which is the base case to end this loop
	ldy #$00
@oam_copy_loop:
					; Y = OAM Y position

	; Y position
	lda (addr_ptr), y		; Y pos relative to player
	cmp #MAP_END			; Check unused flag
	beq @end_frame			; Y-Pos was MAP_END; terminate loop
	clc
	adc player_ypos + 1; Offset from player's Y center
	sec
	sbc yscroll			; Factor in scrolling position
	sta OAM_BASE, y
	sta temp4
	iny				; Y = OAM tile select

	lda (addr_ptr), y
@tile_store:
	sta OAM_BASE, y
	iny				; Y = OAM attributes
	lda (addr_ptr), y

	; Process X flip for attributes
	rol a
	rol a
	rol a
	eor player_dir ; X flip
	ror a
	ror a
	ror a


	sta OAM_BASE, y
	iny				; Y = OAM X position

	; Check if tile position needs to be flipped about Y axis (horiz)
	lda player_dir
	beq @noflipx
	lda #$00
	sec
	sbc (addr_ptr), y		; Reverse relative X position
	sec
	sbc #$08
	sec
	sbc xscroll			; Factor in scrolling position
	clc
	adc player_xpos + 1; Offset from player's X center
	sec
	sta OAM_BASE, y
	iny
	cpy #MAX_PL_SPRITES
	bne @oam_copy_loop
	rts

@noflipx:
	lda (addr_ptr), y		; X pos relative to player
	clc				; Add one to X offset
	adc player_xpos + 1; Offset from player's X center
	sec
	sbc xscroll			; Factor in scrolling position
	sta OAM_BASE, y
	iny

	cpy #MAX_PL_SPRITES
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
	cpy #MAX_PL_SPRITES			; Hide all remaining sprites
	bne @end_frame			; for this player.
	rts

