; Player top-level

MAP_END = $7F
ANIM_STAND = 0
MAX_PL_SPRITES = (16*4)

.segment "BANKF"
.include "player_render.asm"
.include "player_anims.asm"
