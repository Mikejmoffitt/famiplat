

; =====================================
; Main movement routines
player_movement:
	; TODO: Tail calls for minor speed boost once things are set
	jsr player_handle_input
	jsr player_apply_deltas
	jsr player_delta_limits
	jsr player_decel
	jsr player_col_check
	rts

; =====================================
; Decelerate the player running on the ground
player_decel:
; Determine sign of dx
	lda player_dx+1
	bpl @dx_pos
	; If dx is negative, set a flag to mark it as such.
	lda #$01
	sta temp
	; Invert dx
	neg16 player_dx
	key_isdown pad_1, btn_left
	; Exit if key is held
	jmp @decel_done
:
	jmp @post_negate

@dx_pos:
	key_isdown pad_1, btn_right
	rts
:
	lda #$00
	sta temp

@post_negate:

	; If dx is already zero, get out of here
	bne @nonzero
	lda player_dx
	bne @nonzero
	rts

@nonzero:
	sub16 player_dx, #PL_DDX
	; If dx has done negative, zero it out (underflow)
	lda player_dx+1
	bmi @dx_went_negative
	jmp @decel_done

@dx_went_negative:
	; Dx underflowed; zero it out.
	lda #$00
	sta player_dx
	sta player_dx+1
	; Fall-through to @decel_done

@decel_done:
	; If dx was negative to begin with, put it back.
	lda temp
	beq :+
	neg16 player_dx
:
	rts


; =====================================
; Applies limits to the player's movement deltas
player_delta_limits:
; Restrict falling speed
	lda player_dy+1
	bmi :+
	cmp #PL_MAX_DY ; Is dy lower than max dy?
	bmi :+
	lda #PL_MAX_DY
	sta player_dy+1
:
; Restrict running speed
	lda #$00
	sta temp
	lda player_dx+1
	bpl @pos_dx_check

	; If dx is negative, set a flag to mark it as such.
	lda #$01
	sta temp
	; Invert dx
	neg16 player_dx

@pos_dx_check:
	lda player_dx+1
	; First, is dx equal to the max?
	cmp #PL_MAX_DX
	bne :+
	; If so, check subpixel amount
	lda player_dx
	cmp #PL_MAX_DX_EX
	bcc @dx_done
	beq @dx_done
	lda #PL_MAX_DX_EX
	sta player_dx
	jmp @dx_done
:
	bpl :+ ; Is dx greater than max dx?
	jmp @dx_done
:
	lda #PL_MAX_DX
	sta player_dx+1
	lda #PL_MAX_DX_EX
	sta player_dx
	jmp @dx_done

@dx_done:
	; If dx was negative to begin with, put it back.
	lda temp
	beq :+
	neg16 player_dx
:
	rts

; =====================================
; Modify player state based on controller inputs
player_handle_input:
	key_isdown pad_1, btn_left
	sub16 player_dx, #PL_DDX
: ; not pressed
	key_isdown pad_1, btn_right
	add16 player_dx, #PL_DDX
: ; not pressed
	lda player_is_grounded
	beq @post_jump_check

; Do a jump
	key_down pad_1, btn_a
	lda #PL_JUMP_STR
	sta player_dy+1
	lda #PL_JUMP_STR_EX
	sta player_dy
	jmp @skip_jump_cancel
:
@post_jump_check:
	key_isup pad_1, btn_a
	lda player_is_grounded
	bne @skip_jump_cancel
; Check for dy restriction if A is not held
	lda player_dy+1
	cmp #PL_JUMP_CUTOFF
	bpl @skip_jump_cancel
	lda #PL_JUMP_CUTOFF
	sta player_dy+1
:
	
@skip_jump_cancel:
	rts

; =====================================
; Pre:
;	X has X offset from player to check
; 	Y has Y offset from player to check
; Post:
;	A returns nametable tile
; Mangles temp, temp2, A, Y
player_nametable_check:
	; Load base nametable address (in PRG space)
	lda current_nt
	sta addr_ptr
	lda current_nt+1
	sta addr_ptr+1
	bank_load current_nt_bank

	; Factor in positional arguments
	tya
	sta temp
	txa
	sta temp2

	lda player_ypos+1
	clc
	adc temp
	and #%11111000
	sta temp
	; Add (current_row * 4) to address
	add16 addr_ptr, temp
	add16 addr_ptr, temp
	add16 addr_ptr, temp
	add16 addr_ptr, temp
	; A now contains the upper part of the nametable lookup 
	; Add X position to get horizontal index
	lda player_xpos+1
	clc
	adc temp2
	lsr
	lsr
	lsr
	and #$1F
	sta temp
	add16 addr_ptr, temp
	ldy #$00
	lda (addr_ptr), y
	rts

; =====================================
; Checks for collision above the player
player_col_check_top:

	lda player_dy+1
	bne @nonzero_dy
	lda player_dy+1
	bne @nonzero_dy
	rts

@nonzero_dy:
	ldx #PL_TOP_L
	ldy #PL_TOP_DIST
	jsr player_nametable_check
	sta temp3
	ldx #PL_TOP_R
	ldy #PL_TOP_DIST
	jsr player_nametable_check
	ora temp3
	and #$80
	bne @touched
	rts
@touched:
	lda player_ypos+1
	clc
	adc #$08
	adc #PL_TOP_DIST
	and #$F8
	sec
	sbc #PL_TOP_DIST
	sta player_ypos+1
	lda #$00
	sta player_dy
	sta player_dy+1
	sta player_ypos
	rts

; =====================================
; Sets A to $80 if player is on a solid
;
player_col_check_ground:
	ldx #PL_BOTTOM_L
	ldy #PL_BOTTOM_DIST
	jsr player_nametable_check
	sta temp3
	ldx #PL_BOTTOM_R
	ldy #PL_BOTTOM_DIST
	jsr player_nametable_check
	ora temp3
	and #$80
	bne :+
	; If it's not a collision, mark the player as not grounded
	lda #$00
	sta player_is_grounded
	rts
: ; A ground collision was made:

	;Snap to 8px boundary
	lda player_ypos+1
	clc
	adc #PL_BOTTOM_DIST
	and #$F8
	sec
	sbc #PL_BOTTOM_DIST
	sta player_ypos+1
	lda #$00
	sta player_ypos
	sta player_dy
	sta player_dy+1

	; Mark player as grounded
	lda #$01
	sta player_is_grounded
	rts

; =====================================
player_col_check_sides:
	lda player_dx+1
	bne @nonzero_dx
	lda player_dx
	bne @nonzero_dx
	rts

@nonzero_dx:
	; Is dx negative?
	lda player_dx+1
	bmi @neg_dx
	ldx #PL_SIDE_DIST
	jmp @colcheck
@neg_dx:
	ldx #<-PL_SIDE_DIST
	jmp @colcheck
@colcheck:
	; Run checks on the four points
	ldy #PL_SIDE_B
	jsr player_nametable_check
	sta temp3
	ldy #PL_SIDE_M1
	jsr player_nametable_check
	sta temp4
	ldy #PL_SIDE_M2
	jsr player_nametable_check
	sta temp5
	ldy #PL_SIDE_T
	jsr player_nametable_check
	ora temp5
	ora temp4
	ora temp3
	and #$80
	bne @is_solid
	rts

@is_solid:
	lda #$00
	sta player_dx
	sta player_dx+1

	txa
	sta temp
	; Snap player to collision point
	sta player_xpos
	lda player_xpos+1
	clc
	adc #$04
	adc temp
	and #$F8
	sec
	sbc temp
	sta player_xpos+1

	lda temp
	bmi @neg_offset
	rts

@neg_offset:
	lda player_xpos+1
	sec
	sbc #$01
	sta player_xpos+1
	rts

; =====================================
; Perform collision checks for one frame.
player_col_check:
	fix12_to_8 player_xpos, temp7
	fix12_to_8 player_ypos, temp8
	jsr player_col_check_sides
	jsr player_col_check_top
	jsr player_col_check_ground
	rts

; =====================================
; Commit dx, dy, and ddx (gravity)
player_apply_deltas:
	sum16 player_xpos, player_dx
	sum16 player_ypos, player_dy
	add16 player_dy, #PL_GRAVITY
	rts
