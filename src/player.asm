; Player top-level

MAP_END = $7F
ANIM_NULL = 0
ANIM_STAND = 1
ANIM_RUN = 2
ANIM_JUMP = 3
ANIM_FALL = 4
MAX_PL_SPRITES = (16*4)

PL_GRAVITY = $31
PL_MAX_DY = $05
PL_MAX_DX = $02
PL_MAX_DX_EX = $22
PL_DDX = $1C

PL_JUMP_STR = <-$05
PL_JUMP_STR_EX = <-$34
PL_JUMP_CUTOFF = <-$03

PL_BOTTOM_DIST = 1
PL_BOTTOM_L = <-4
PL_BOTTOM_R = 4

PL_TOP_DIST = <-28
PL_TOP_L = PL_BOTTOM_L
PL_TOP_R = PL_BOTTOM_R

PL_SIDE_DIST = 6
PL_SIDE_T = <-27
PL_SIDE_M1 = <-22
PL_SIDE_M2 = <-14
PL_SIDE_B = <-6

.segment "FIXED"

player_init:
	lda #$80
	sta player_xpos + 1
	sta player_ypos + 1
	sta player_xpos
	sta player_ypos
rts

.include "player_movement.asm"
.include "player_anims.asm"
.include "player_render.asm"
