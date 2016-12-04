

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

	; Factor in positional arguments
	tya
	sta temp
	txa
	sta temp2

	bank_load current_nt_bank

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
; Sets A to $80 if player is on a solid
;
player_col_check_ground:
	ldx #PL_BOTTOM_L
	ldy #PL_BOTTOM_DIST
	jsr player_nametable_check
	and #$80
	sta temp3
	ldx #PL_BOTTOM_R
	ldy #PL_BOTTOM_DIST
	jsr player_nametable_check
	and #$80
	ora temp3
	rts

player_col_check_sides:
; Check sides
	lda player_dx+1
	bne @nonzero_dx
	lda player_dx
	bne @nonzero_dx
	jmp @post_dx
@nonzero_dx:
	; Is dx negative?
	lda player_dx+1
	bmi @neg_dx
	; No, dx is positive
	ldx #PL_RIGHT_DIST
	ldy #PL_RIGHT_B
	jsr player_nametable_check
	sta temp3
	ldx #PL_RIGHT_DIST
	ldy #PL_RIGHT_M1
	jsr player_nametable_check
	sta temp4
	ldx #PL_RIGHT_DIST
	ldy #PL_RIGHT_M2
	jsr player_nametable_check
	sta temp5
	ldx #PL_RIGHT_DIST
	ldy #PL_RIGHT_T
	jsr player_nametable_check
	sta temp6
	ora temp5
	ora temp4
	ora temp3
	and #$80
	beq @post_dx
	; Colliding on the right side. Zero out dx.
	lda #$00
	sta player_dx
	sta player_dx+1

	; Snap player to right side
	lda player_xpos+1
	clc
	adc #PL_RIGHT_DIST
	and #$F8
	sec
	sbc #PL_RIGHT_DIST
	sta player_xpos+1
	lda #$00
	sta player_xpos
	rts
	; Calculate coordinates of wall
	txa
	sta temp
	lda player_xpos+1
	clc
	adc temp
	; A now has X position of the right of the player. Snap it to 8px.
	and #$F8
	; Now it is snapped to the 8px boundary. Subtract distance for new X.
	sec
	sbc #PL_RIGHT_DIST
	sta player_xpos+1

@neg_dx:

@post_dx:

	rts

; =====================================
; Perform collision checks
player_col_check:
	jsr player_col_check_sides
	jsr player_col_check_ground
	cmp #$00
	bne :+
	lda #$00
	sta player_is_grounded
	rts
:
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
	lda #$01
	sta player_is_grounded
	rts

; =====================================
; Commit dx, dy, and ddx (gravity)
player_apply_deltas:
	sum16 player_xpos, player_dx
	sum16 player_ypos, player_dy
	add16 player_dy, #PL_GRAVITY
	rts
