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

player_handle_input:
	key_isdown pad_1, btn_left
	sub16 player_dx, #PL_DDX
: ; not pressed
	key_isdown pad_1, btn_right
	add16 player_dx, #PL_DDX
: ; not pressed
	lda player_is_grounded
	beq :+
	key_isdown pad_1, btn_a
	
	lda #PL_JUMP_STR
	sta player_dy+1
	lda #PL_JUMP_STR_EX
	sta player_dy
:
	rts

player_col_check:
	lda player_ypos+1
	cmp #207
	bcs :+
	lda #$00
	sta player_is_grounded
	rts
:
	lda #207
	sta player_ypos+1
	lda #$00
	sta player_ypos
	sta player_dy
	sta player_dy+1
	lda #$01
	sta player_is_grounded
	rts

player_apply_deltas:
	sum16 player_xpos, player_dx
	sum16 player_ypos, player_dy
	add16 player_dy, #PL_GRAVITY
	jsr player_delta_limits
	rts

player_movement:
	jsr player_handle_input
	jsr player_apply_deltas
	jsr player_col_check
	rts
