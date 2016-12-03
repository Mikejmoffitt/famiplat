; Player top-level

MAP_END = $7F
ANIM_NULL = 0
ANIM_STAND = 1
ANIM_RUN = 2
ANIM_JUMP = 3
ANIM_FALL = 4
MAX_PL_SPRITES = (16*4)

PL_GRAVITY = $29
PL_MAX_DY = $05
PL_MAX_DX = $02
PL_MAX_DX_EX = $22
PL_DDX = $1A

PL_JUMP_STR = <-$06
PL_JUMP_STR_EX = <-$75
PL_JUMP_CUTOFF = <-$03

PL_BOTTOM_L = <-4
PL_BOTTOM_R = 4

.segment "BANKF"
.include "player_movement.asm"
.include "player_anims.asm"
.include "player_render.asm"
