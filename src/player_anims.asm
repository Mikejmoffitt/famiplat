; Player animation scripts

; =============== Animation Mappings ====================
; Arrangements of sprites to form single animation frames, or "metasprites"
; Four bytes follow the mapping of what goes into OAM, mostly
;       Sprite Y (relative to player's Y), signed; set to MAP_END to end list
;       Tile selection
;       Attributes; player 2 is ORed with %00000010
;       Sprite X (relative to player's X), signed; flipped to face left
; Twelve sprites are allocated for a frame.

pl_mapping_stand:
        .byte   <-32, $00, %00000001, <-8
        .byte   <-32, $01, %00000001, 0
        .byte   <-24, $10, %00000001, <-8
        .byte   <-24, $11, %00000001, 0
        .byte   <-16, $20, %00000001, <-8
        .byte   <-16, $21, %00000001, 0
        .byte   <-8, $30, %00000001, <-8
        .byte   <-8, $31, %00000001, 0
        .byte   MAP_END

pl_mapping_stand2:
        .byte   <-32, $02, %00000001, <-8
        .byte   <-32, $03, %00000001, 0
        .byte   <-24, $12, %00000001, <-8
        .byte   <-24, $13, %00000001, 0
        .byte   <-16, $22, %00000001, <-8
        .byte   <-16, $23, %00000001, 0
        .byte   <-8, $32, %00000001, <-8
        .byte   <-8, $33, %00000001, 0
        .byte   MAP_END

pl_mapping_dummy:
	.byte	<-$20, <-$20, 0, 0
	.byte	MAP_END


; =============== Animation Scripts ===============
; Sequences of mappings to form animation sequences
; Animation scripts are simply like this:
; 	Length
; 	Loop P oint in frames
; --------- Then, for every frame:
; 	Mapping address		(.addr)
; 	Length in frames	(.byte)
; 	Padding			(.byte)

pl_anim_stand:
	.byte 	2
	.byte	0
	.addr	pl_mapping_stand
	.byte	23, 0
	.addr	pl_mapping_stand2
	.byte	23, 0

; ============ Animation Number Map ====================
; An array containing the addresses of animation numbers. Used to
; number to an animation script.
pl_anim_num_map:
	.addr	pl_anim_stand
	.addr	pl_anim_stand

; Character graphics

;	pl_chr:
;	.incbin "../assets/char/girl.chr";
;
;	pl_pal:
;	;     null blck skin extra
;	.byte $00, $0F, $35, $30
;	.byte $00, $0F, $35, $11
;	;     null blck skin extra
;	.byte $00, $0F, $26, $30
;	.byte $00, $0F, $26, $16
