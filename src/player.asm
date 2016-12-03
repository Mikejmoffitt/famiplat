; Player top-level

MAP_END = $7F
ANIM_NULL = 0
ANIM_STAND = 1
ANIM_RUN = 2
MAX_PL_SPRITES = (16*4)

PL_GRAVITY = $14
PL_MAX_DY = $05
PL_MAX_DX = $01
PL_MAX_DX_EX = $40
PL_DDX = $1A

PL_JUMP_STR = $07
PL_JUMP_STR_EX = $35

.segment "BANKF"
.include "player_movement.asm"
.include "player_anims.asm"
.include "player_render.asm"
