; Player animation scripts

; =============== Animation Mappings ====================
; Arrangements of sprites to form single animation frames, or "metasprites"
; Four bytes follow the mapping of what goes into OAM, mostly
;       Sprite Y (relative to player's Y), signed; set to MAP_END to end list
;       Tile selection
;       Attributes; player 2 is ORed with %00000010
;       Sprite X (relative to player's X), signed; flipped to face left
; Twelve sprites are allocated for a frame.

pl_mapping_stand1:
	.byte   <-32, $00, %00000000, <-8
	.byte   <-32, $01, %00000000, 0
	.byte   <-24, $10, %00000000, <-8
	.byte   <-24, $11, %00000000, 0
	.byte   <-16, $20, %00000000, <-8
	.byte   <-16, $21, %00000000, 0
	.byte   <-8,  $30, %00000000, <-8
	.byte   <-8,  $31, %00000000, 0
	.byte   MAP_END

pl_mapping_stand2:
	.byte   <-32, $02, %00000000, <-8
	.byte   <-32, $03, %00000000, 0
	.byte   <-24, $12, %00000000, <-8
	.byte   <-24, $13, %00000000, 0
	.byte   <-16, $22, %00000000, <-8
	.byte   <-16, $23, %00000000, 0
	.byte   <-8,  $32, %00000000, <-8
	.byte   <-8,  $33, %00000000, 0
	.byte   MAP_END

pl_mapping_run1:
	.byte	<-31, $05, %00000000, <-4
	.byte	<-31, $06, %00000000, 4
	.byte	<-23, $15, %00000000, <-4
	.byte	<-23, $16, %00000000, 4
	.byte	<-15, $24, %00000000, <-12
	.byte	<-15, $25, %00000000, <-4
	.byte	<-15, $26, %00000000, 4
	.byte	<-7,  $35, %00000000, <-4
	.byte	MAP_END

pl_mapping_run2:
	.byte	<-31, $08, %00000000, <-5
	.byte	<-31, $09, %00000000, 3
	.byte	<-23, $17, %00000000, <-12
	.byte	<-23, $18, %00000000, <-4
	.byte	<-23, $19, %00000000, 4
	.byte	<-15, $27, %00000000, <-9
	.byte	<-15, $28, %00000000, <-1
	.byte	<-7,  $37, %00000000, <-12
	.byte	MAP_END

pl_mapping_run3:
	.byte	<-31, $0C, %00000000, <-5
	.byte	<-31, $0D, %00000000, 3
	.byte	<-23, $1B, %00000000, <-12
	.byte	<-23, $1C, %00000000, <-4
	.byte	<-23, $1D, %00000000, 4
	.byte	<-27, $3C, %00000000, 12
	.byte	<-15, $2B, %00000000, <-12
	.byte	<-15, $2C, %00000000, <-4
	.byte	<-15, $2D, %00000000, 4
	.byte	<-7,  $3A, %00000000, <-20
	.byte	<-7,  $3B, %00000000, <-12
	.byte	<-7,  $3D, %00000000, 4
	.byte	MAP_END

pl_mapping_run4:
	.byte	<-30, $41, %00000000, <-11
	.byte	<-30, $42, %00000000, <-3
	.byte	<-30, $43, %00000000, 5
	.byte	<-22, $51, %00000000, <-11
	.byte	<-22, $52, %00000000, <-3
	.byte	<-22, $53, %00000000, 5
	.byte	<-14, $60, %00000000, <-19
	.byte	<-14, $61, %00000000, <-11
	.byte	<-14, $62, %00000000, <-3
	.byte	<-14, $63, %00000000, 5
	.byte	<-6,  $73, %00000000, 5
	.byte	MAP_END

pl_mapping_run5:
	.byte	<-32, $44, %00000000, <-10
	.byte	<-32, $45, %00000000, <-2
	.byte	<-32, $46, %00000000, 6
	.byte	<-24, $54, %00000000, <-10
	.byte	<-24, $55, %00000000, <-2
	.byte	<-16, $64, %00000000, <-10
	.byte	<-16, $65, %00000000, <-2
	.byte	<-16, $66, %00000000, 6
	.byte	<-8,  $75, %00000000, <-2
	.byte	MAP_END

pl_mapping_run6:
	.byte	<-32, $48, %00000000, <-2
	.byte	<-32, $49, %00000000, 6
	.byte	<-24, $57, %00000000, <-6
	.byte	<-24, $58, %00000000, 2
	.byte	<-16, $67, %00000000, <-9
	.byte	<-16, $68, %00000000, <-1
	.byte	<-8,  $77, %00000000, <-10
	.byte	MAP_END

pl_mapping_run7:
	.byte	<-30, $4B, %00000000, <-10
	.byte	<-30, $4C, %00000000, <-2
	.byte	<-30, $4D, %00000000, 6
	.byte	<-22, $5B, %00000000, <-10
	.byte	<-22, $5C, %00000000, <-2
	.byte	<-22, $5D, %00000000, 6
	.byte	<-14, $6A, %00000000, <-16
	.byte	<-14, $6B, %00000000, <-8
	.byte	<-14, $6C, %00000000, 0
	.byte	<-6,  $7A, %00000000, <-16
	.byte	MAP_END

pl_mapping_run8:
	.byte	<-30, $81, %00000000, <-8
	.byte	<-30, $82, %00000000, 0
	.byte	<-30, $83, %00000000, 8
	.byte	<-22, $91, %00000000, <-8
	.byte	<-22, $92, %00000000, 0
	.byte	<-22, $93, %00000000, 8
	.byte	<-14, $A0, %00000000, <-14
	.byte	<-14, $A1, %00000000, <-6
	.byte	<-14, $A2, %00000000, 2
	.byte	<-6,  $B3, %00000000, 7
	.byte	MAP_END

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

pl_anim_dummy:
	.byte	1
	.byte	0
	.addr	pl_mapping_dummy
	.byte	1, 0

pl_anim_stand:
	.byte 	2
	.byte	0
	.addr	pl_mapping_stand1
	.byte	32, 0
	.addr	pl_mapping_stand2
	.byte	28, 0

pl_anim_run:
	.byte	9
	.byte	1
	.addr	pl_mapping_stand2
	.byte	3, 0
	.addr	pl_mapping_run6
	.byte	4, 0
	.addr	pl_mapping_run7
	.byte	5, 0
	.addr	pl_mapping_run8
	.byte	6, 0
	.addr	pl_mapping_run1
	.byte	5, 0
	.addr	pl_mapping_run2
	.byte	4, 0
	.addr	pl_mapping_run3
	.byte	5, 0
	.addr	pl_mapping_run4
	.byte	6, 0
	.addr	pl_mapping_run5
	.byte	5, 0

; ============ Animation Number Map ====================
; An array containing the addresses of animation numbers. Used to
; number to an animation script.
pl_anim_num_map:
	.addr	pl_anim_dummy
	.addr	pl_anim_stand
	.addr	pl_anim_run

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
