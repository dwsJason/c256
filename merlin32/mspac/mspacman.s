;
;  Foenix MsPacman in Merlin32
;
; $00:2000 - $00:7FFF are free for application use.
;
;
;  224x288 Screen Resolution on the arcard machine
;  400x300 mode on the Phoenix
;
;  300-288 = 12,  border 6 vertical, and 8 horizontal
;
;  400-16-224 = 160 (leaving 80 bitmap pixels on the left, and on the right)
;

; Conditional Compile
DEBUG equ 0

        rel     ; relocatable
        lnk     Main.l

        use Util.Macs
		use ms.macs

; External Addresses

		ext title_pic
		ext panel_pic
		ext decompress_lzsa

		ext tile_rom
		ext sprite_rom
		ext color_rom
		ext palette_rom
		ext sound_rom1
		ext sound_rom2

        mx %00

; Phoenix Machine includes - Merlin32 doesn't support nested includes
; (SHAME!)

		; Vicky
		use phx/vicky_ii_def.asm
		use phx/VKYII_CFP9553_BITMAP_def.asm 
		use phx/VKYII_CFP9553_TILEMAP_def.asm
		use phx/VKYII_CFP9553_VDMA_def.asm   
		use phx/VKYII_CFP9553_SDMA_def.asm   
		use phx/VKYII_CFP9553_SPRITE_def.asm 

		; Kernel
		use phx/kernel_inc.asm

		; Interrupts
		use phx/interrupt_def.asm

		; Math
		use phx/Math_def.asm


;
; Decompress to this address
;
pixel_buffer = $100000	; need about 480k, put it in memory at 1.0MB mark
			; try to leave room for kernel on a U


;
; Key Codes
;
KEY_UP		equ $17 ;$48 ;$68
KEY_DOWN	equ $25 ;$50 ;$6A
KEY_LEFT	equ $24 ;$4B ;$69
KEY_RIGHT	equ $26 ;$4D ;$6B

KEY_F1		equ $3B
KEY_F2		equ $3C

; bit codes for the IN0

;JOY_UP_BIT	equ %00000001
;JOY_LEFT_BIT	equ %00000010
;JOY_RIGHT_BIT	equ %00000100
;JOY_DOWN_BIT	equ %00001000

; bit codes for the IN1

;COIN1_INSERT_BIT equ %00100000
;COIN2_INSERT_BIT equ %01000000

;P1_START_BIT equ %00100000
;P2_START_BIT equ %01000000

JOY_UP_BIT	equ $01
JOY_LEFT_BIT	equ $02
JOY_RIGHT_BIT	equ $04
JOY_DOWN_BIT	equ $08

; bit codes for the IN1

COIN1_INSERT_BIT equ $20
COIN2_INSERT_BIT equ $40

P1_START_BIT equ $20
P2_START_BIT equ $40


VRAM = $B00000
ONEMB = $100000

; Ms Pacman Memory Defines

]VIDEO_MODE = Mstr_Ctrl_Graph_Mode_En
]VIDEO_MODE = ]VIDEO_MODE+Mstr_Ctrl_Bitmap_En
]VIDEO_MODE = ]VIDEO_MODE+Mstr_Ctrl_TileMap_En
]VIDEO_MODE = ]VIDEO_MODE+Mstr_Ctrl_Sprite_En
]VIDEO_MODE = ]VIDEO_MODE+Mstr_Ctrl_GAMMA_En
]VIDEO_MODE = ]VIDEO_MODE+$100                  ; +800x600
;]VIDEO_MODE = ]VIDEO_MODE+$200                 ; pixel double/ half resolution

VICKY_MAP_TILES     = $000000
VICKY_SPRITE_TILES  = $010000				      ; Normal Sprites
VICKY_SPRITE_TILES2 = VICKY_SPRITE_TILES+$010000  ; V-Flip Sprites
VICKY_SPRITE_TILES3 = VICKY_SPRITE_TILES2+$010000 ; H-Flip Sprites
VICKY_SPRITE_TILES4 = VICKY_SPRITE_TILES3+$010000 ; HV-Flip Sprites

VICKY_MAP0          = VICKY_SPRITE_TILES4+$010000  ; MAP Data for tile map 0
VICKY_MAP1          = VICKY_MAP0+{64*64*2}	  ; MAP Data for tile map 1
VICKY_MAP2          = VICKY_MAP1+{64*64*2}	  ; MAP Data for tile map 2
VICKY_MAP3          = VICKY_MAP2+{64*64*2}	  ; MAP Data for tile map 3

; 800x600 bitmap, 480000 bytes, I think it should fit ok on the U
VICKY_BITMAP0       = VICKY_MAP0+$010000 	 ; pixel data for the panel

TILE_CLEAR_SIZE = $010000
MAP_CLEAR_SIZE = 64*64*2

TILE_Pal0 = 0*$800
TILE_Pal1 = 1*$800
TILE_Pal2 = 2*$800
TILE_Pal3 = 3*$800
TILE_Pal4 = 4*$800
TILE_Pal5 = 5*$800
TILE_Pal6 = 6*$800
TILE_Pal7 = 7*$800


;------------------------------------------------------------------------------
; I like having my own Direct Page
MyDP = $100

;------------------------------------------------------------------------------
; Direct Page Equates
;
; $$TODO, Separate out Interrupt based temp, vs non-interrupt based temp
;
		dum $80
lzsa_sourcePtr	ds 4
lsza_destPtr	ds 4
lzsa_matchPtr	ds 4
lzsa_nibble	ds 2
lzsa_suboffset	ds 2
lzsa_token	ds 2

temp0		ds 4
temp1		ds 4
temp2		ds 4
temp3		ds 4
temp4		ds 4
temp5		ds 4
temp6		ds 4
temp7		ds 4


i32EOF_Address 	ds 4
i32FileLength  	ds 4
pData          	ds 4
i16Version     	ds 2
i16Width       	ds 2
i16Height      	ds 2
pCLUT          	ds 4
pPIXL	       	ds 4

dpJiffy        	ds 2    ; Jiffy Timer
		dend


;------------------------------------------------------------------------------
; Enums / Game Constants

	dum 0
MS_INIT ds 1		; MAINSTATE_INIT
MS_DEMO ds 1 		; MAINSTATE_DEMO
MS_COIN ds 1		; MAINSTATE_COIN inserted
MS_PLAY ds 1		; MAINSTATE_PLAYING
	dend

;------------------------------------------------------------------------------

start   ent             ; make sure start is visible outside the file
        clc
        xce
        rep $31         ; long MX, and CLC

; Default Stack is on top of System DMA Registers
; So move the stack before proceeding

        lda #$FEFF      ; I really don't know much RAM the kernel is using in bank 0
        tcs

        lda #MyDP
        tcd

		phk
		plb

;
; Setup a Jiffy Timer, using Kernel Jump Table
; Trying to be friendly, in case we can friendly exit
;
		jsr InstallJiffy

		jsr WaitVBL

;------------------------------------------------------------------------------
; $$JGA to  bring this back in, be sure to edit data0.s, so there's
; some valid data to decompress/display
;
;		jsr ShowTitlePage

;------------------------------------------------------------------------------
;
;  FMX Hardware Initialization
;
		jsr InitMsPacVideo

		; Convert the Tiles so we can see them
		jsr TestTiles

		; Convert the Sprites so we can see them!
		jsr TestSprites

		; Decompress the Color ROM into Vicky Format
		jsr DecompressColors

		; Panel Decompress, and copy into VRAM
		jsr DecompressPanel

		; There are now 64 Sprites, that are 32x32 (1024 bytes each)
		; at VICKY_SPRITE_TILES
		; need to convert them to V-Flip, at address VICKY_SPRITE_TILES1
		; need to convert them to HV-Flip, at address VICKY_SPRITE_TILES2
		; need to convert them to H-Flip, at address VICKY_SPRITE_TILES3

		; Wait 1 second
;		lda #60
;]lp 	jsr WaitVBL
;		dec
;		bpl ]lp

; The fastest way to convert them is DMA, and DMA can run very fast
; as long as video is disabled.

		; Disable Video
		; generate H-FLip Bank from the base tiles
		; generate V-Flip Bank from the base tiles
		; generate HV-Flip Bank from H-Tiles (if that's quicker than from V)

		; looks like VDMA can do 1 horizontal line at a time
		; which would be decent for doing the V-Flip
		; it can also do 1 vertical line at a time
		; which would be good for the H-Flip
		; unfortunately, is still going to require 32 separate
		; DMA (in either case)
		; Right now, I only know I need H-Flip to get the intro working
		; I'm not sure how long I had that paused, but hopefully
		; I see the video cut, and catch this.		
		jsr GenerateSpriteFlips


;------------------------------------------------------------------------------
;
; Clear Map data
;
		ldx #0
		lda #$00FF
]lp
		sta >VICKY_MAP0+VRAM+{64*2}+4,x
;		sta >VICKY_MAP1+VRAM+{64*2}+4,x
		inx
		inx
		cpx #64*64*2
		bcc ]lp

;---------------------------------------------------
		; Quick Disable All the Sprites
		phb
		pea >SP00_CONTROL_REG
		plb
		plb

		ldx #0
		txa
]lp
		stz |SP00_CONTROL_REG,x
		stz |SP00_X_POS_L,x
		stz |SP00_Y_POS_L,x
		adc #8
		tax
		cpx #8*64
		bcc ]lp
		plb

;------------------------------------------------------------------------------
]next

	;; Clear screen
	;; 40 -> 4000-43ff (Video RAM)
		; 2315 - Clear the Screen, to 0x40

		lda #$4040
		ldx #1022
]clear
		sta |tile_ram,x
		dex
		dex
		bpl ]clear

;------------------------------------------------------------------------------

	;; 0f -> 4400 - 47ff (Color RAM)
		; 2329
		lda #$0F0F
		ldx #1022
]clear
		sta |palette_ram,x
		dex
		dex
		bpl ]clear

;------------------------------------------------------------------------------
	    do DEBUG
	    else
; Display the panel_pic
	    sep #$20
	    lda #BM_Enable
	    sta >BM0_CONTROL_REG
	    rep #$30
	    fin
;------------------------------------------------------------------------------
;
		; This is the Test Loop for showing off the levels
;		jmp JasonTestStuff

;------------------------------------------------------------------------------
;
; Begin Actual MsPacman!!!
;
;------------------------------------------------------------------------------
;0000
rst0 mx %00
		sei					; Disable Interrupts
		jmp	startuptest
;memset Address X, with A, for length Y
;0008
rst8 mx %00
		cpy #3
		sta |0,x
		bcs :mvn
		rts			; so short, the initial store clears it
:mvn
		dey
		dey
		dey
		tya
		txy
		iny
		iny
		mvn ^rst8,^rst8

		rts

;------------------------------------------------------------------------------
;;$$TODO, port the rst28 - Add task, with argument
;0028
rst28 mx %00
; continuation of rst 28 from #002E
; this sub can be called with call #0042, if B and C are loaded manually
; B and C have the data bytes
;; A=PNTN, PN = parameter, TN = task number
;0042
task_add mx %00
;0042  2a804c    ld      hl,(#4c80)	; load HL with address pointing to the beginning of the task list
			ldx |tasksTail
;0045  70        ld      (hl),b		; store task 
;0046  2c        inc     l		; next address
;0047  71        ld      (hl),c		; store parameter
;0048  2c        inc     l		; next address
			sta |0,x

			inx
			inx
			cpx #foreground_tasks+64
;0049  2002      jr      nz,#004d	; If non zero, skip next step
			bcc :no_wrap
;004b  2ec0      ld      l,#c0		; else load L with C0 to cycle HL back to #4CC0 (spins #C0-#FF)
			ldx #foreground_tasks		; wrap around task list
:no_wrap
;004d  22804c    ld      (#4c80),hl	; store new task pointer back (4c80, 4c81) = hl
			stx |tasksTail
;0050  c9        ret     		; return to program
			rts

;------------------------------------------------------------------------------
; rst #30
; when rst #30 is called, the 3 data bytes following the call are inserted
; into the timed task list at the next available location.  Up to #10 (16 decimal)
; locations are searched before giving up.
; A=TNTM Y=param  TN=Task number, TM=Timer
;0030
rst30 mx %00
			phy
			pha
;0030: 11 90 4C	ld	de,#4C90	; load DE with starting address of task table
;0033: 06 10	ld	b,#10		; For B = 1 to #10
			sep #$20
			ldx #irq_tasks

	; continuation of rst 30 from #0035 (Task manager)
:loop
;0051: 1A	ld	a,(de)		; load A with task
			lda |0,x		; actually this is the task timer, not task no
;0052: A7	and	a		; == #00 ?
;0053: 28 06	jr	z,#005B 	; yes, skip ahead, we will insert the new task here
			beq :insert_task_here

;0055: 1C	inc	e		; else inc E by 3
;0056: 1C	inc	e
;0057: 1C	inc	e		; DE now at next task
			inx
			inx
			inx
;0058: 10 F7	djnz	#0051		; Next B, loops up to #10 times
			cpx #irq_tasks+48
			bcc :loop
			rep #$20
			pla
			ply
;005A: C9	ret			; return
			rts

:insert_task_here mx %10

;005B: E1	pop	hl		; HL = data address of the 3 data bytes to be inserted
;005C: 06 03	ld	b,#03		; For B = 1 to 3

;005E: 7E	ld	a,(hl)		; load A with table value
;005F: 12	ld 	(de),a		; store into task list
;0060: 23	inc	hl		; next HL
;0061: 1C	inc	e		; next DE
;0062: 10 FA	djnz	#005E		; next B
;0064: E9	jp	(hl)		; return to program (HL now has return address following the 3 data bytes)
			pla
			sta |0,x
			pla
			sta |1,x
			pla
			sta |2,x
			pla			; Y was wide here
			rep #$20
			rts

	; rst 38 (vblank)
	; INTERRUPT MODE 1 handler
rst38 mx %00
		jmp VBL_Handler  ; 008d


;------------------------------------------------------------------------------
;; part of the interrupt routine (non-test)
;; continuation of RST 38 partially...  (vblank)
;; (gets called from the #1f9b patch, from #0038)
;008d
VBL_Handler mx %00
; I think there's a problem with my temp variables getting stomped
; because I don't know what will be called in this interrupt here
		pei temp0
		pei temp0+2
		pei temp1
		pei temp1+2
		pei temp2
		pei temp2+2
		pei temp3
		pei temp3+2
		pei temp4
		pei temp4+2
		pei temp5
		pei temp5+2
		pei temp6
		pei temp6+2
		pei temp7
		pei temp7+2

;
; I think first thing in VBlank Should be code to refresh the sprites
; convert from MsPac HW to C256
;
SP_SIZE equ 8
		phkb ^SP00_CONTROL_REG
		plb
		phd
		lda #allsprite
		tcd

		; since this controls color as well, needs tweaked
		lda #SPRITE_Enable+SPRITE_LUT0+SPRITE_DEPTH1
		sta |SP00_CONTROL_REG+{SP_SIZE*0}
		lda #SPRITE_Enable+SPRITE_LUT1+SPRITE_DEPTH1
		sta |SP00_CONTROL_REG+{SP_SIZE*1}
		lda #SPRITE_Enable+SPRITE_LUT2+SPRITE_DEPTH1
		sta |SP00_CONTROL_REG+{SP_SIZE*2}
		lda #SPRITE_Enable+SPRITE_LUT3+SPRITE_DEPTH1
		sta |SP00_CONTROL_REG+{SP_SIZE*3}
		lda #SPRITE_Enable+SPRITE_LUT4+SPRITE_DEPTH1
		sta |SP00_CONTROL_REG+{SP_SIZE*4}
		lda #SPRITE_Enable+SPRITE_LUT5+SPRITE_DEPTH1
		sta |SP00_CONTROL_REG+{SP_SIZE*5}

		; sprite 0
		lda <{redghostcolor-allsprite}
		asl
		asl
		asl
		asl
		tax
		lda >color_table+4,x
		sta |GRPH_LUT0_PTR+4+16
		lda >color_table+6,x
		sta |GRPH_LUT0_PTR+6+16
		lda >color_table+8,x
		sta |GRPH_LUT0_PTR+8+16
		lda >color_table+10,x
		sta |GRPH_LUT0_PTR+10+16
		lda >color_table+12,x
		sta |GRPH_LUT0_PTR+12+16
		lda >color_table+14,x
		sta |GRPH_LUT0_PTR+14+16

		; sprite 1
		lda <{pinkghostcolor-allsprite}
		asl
		asl
		asl
		asl
		tax
		lda >color_table+4,x
		sta |GRPH_LUT1_PTR+4+16
		lda >color_table+6,x
		sta |GRPH_LUT1_PTR+6+16
		lda >color_table+8,x
		sta |GRPH_LUT1_PTR+8+16
		lda >color_table+10,x
		sta |GRPH_LUT1_PTR+10+16
		lda >color_table+12,x
		sta |GRPH_LUT1_PTR+12+16
		lda >color_table+14,x
		sta |GRPH_LUT1_PTR+14+16

		; sprite 2
		lda <{blueghostcolor-allsprite}
		asl
		asl
		asl
		asl
		tax
		lda >color_table+4,x
		sta |GRPH_LUT2_PTR+4+16
		lda >color_table+6,x
		sta |GRPH_LUT2_PTR+6+16
		lda >color_table+8,x
		sta |GRPH_LUT2_PTR+8+16
		lda >color_table+10,x
		sta |GRPH_LUT2_PTR+10+16
		lda >color_table+12,x
		sta |GRPH_LUT2_PTR+12+16
		lda >color_table+14,x
		sta |GRPH_LUT2_PTR+14+16

		; sprite 3
		lda <{orangeghostcolor-allsprite}
		asl
		asl
		asl
		asl
		tax
		lda >color_table+4,x
		sta |GRPH_LUT3_PTR+4+16
		lda >color_table+6,x
		sta |GRPH_LUT3_PTR+6+16
		lda >color_table+8,x
		sta |GRPH_LUT3_PTR+8+16
		lda >color_table+10,x
		sta |GRPH_LUT3_PTR+10+16
		lda >color_table+12,x
		sta |GRPH_LUT3_PTR+12+16
		lda >color_table+14,x
		sta |GRPH_LUT3_PTR+14+16

		; sprite 4
		lda <{pacmancolor-allsprite}
		asl
		asl
		asl
		asl
		tax
		lda >color_table+4,x
		sta |GRPH_LUT4_PTR+4+16
		lda >color_table+6,x
		sta |GRPH_LUT4_PTR+6+16
		lda >color_table+8,x
		sta |GRPH_LUT4_PTR+8+16
		lda >color_table+10,x
		sta |GRPH_LUT4_PTR+10+16
		lda >color_table+12,x
		sta |GRPH_LUT4_PTR+12+16
		lda >color_table+14,x
		sta |GRPH_LUT4_PTR+14+16

		; sprite 5
		lda <{fruitspritecolor-allsprite}
		asl
		asl
		asl
		asl
		tax
		lda >color_table+4,x
		sta |GRPH_LUT5_PTR+4+16
		lda >color_table+6,x
		sta |GRPH_LUT5_PTR+6+16
		lda >color_table+8,x
		sta |GRPH_LUT5_PTR+8+16
		lda >color_table+10,x
		sta |GRPH_LUT5_PTR+10+16
		lda >color_table+12,x
		sta |GRPH_LUT5_PTR+12+16
		lda >color_table+14,x
		sta |GRPH_LUT5_PTR+14+16

		; Update the Sprite Frames
		; Turns out the hi-bit is an H-Flip for the sprite
		; I don't think Phoenix can do this, but I can make this math
		; 100% work, if I just use more VRAM
		lda <{redghostsprite-allsprite}
		asl
		asl
		adc #>VICKY_SPRITE_TILES
		sta |SP00_ADDY_PTR_L+1+{SP_SIZE*0}

		lda <{pinkghostsprite-allsprite}
		asl
		asl
		adc #>VICKY_SPRITE_TILES
		sta |SP00_ADDY_PTR_L+1+{SP_SIZE*1}

		lda <{blueghostsprite-allsprite}
		asl
		asl
		adc #>VICKY_SPRITE_TILES
		sta |SP00_ADDY_PTR_L+1+{SP_SIZE*2}

		lda <{orangeghostsprite-allsprite}
		asl
		asl
		adc #>VICKY_SPRITE_TILES
		sta |SP00_ADDY_PTR_L+1+{SP_SIZE*3}

		lda <{pacmansprite-allsprite}
		asl
		asl
		adc #>VICKY_SPRITE_TILES
		sta |SP00_ADDY_PTR_L+1+{SP_SIZE*4}

		lda <{fruitsprite-allsprite}
		asl
		asl
		adc #>VICKY_SPRITE_TILES
		sta |SP00_ADDY_PTR_L+1+{SP_SIZE*5}

		lda #red_ghost_y
		tcd

SCR_OFFSET_X equ {{{800-{224*2}}/2}-16}
SCR_OFFSET_Y equ {{{600-{256*2}}/2}+16}

		; Do Red Ghost X
		lda <{red_ghost_x-red_ghost_y}
		eor #$FFFF
		inc
		and #$FF
		asl		; x2
		adc #SCR_OFFSET_X
		sta |SP00_X_POS_L+{SP_SIZE*0}

		; Do Red Ghost Y
		lda <{red_ghost_y-red_ghost_y}
		and #$FF
		asl
		adc #SCR_OFFSET_Y
		sta |SP00_Y_POS_L+{SP_SIZE*0}

		; Do Pink Ghost X
		lda <{pink_ghost_x-red_ghost_y}
		eor #$FFFF
		inc
		and #$FF
		asl		; x2
		adc #SCR_OFFSET_X
		sta |SP00_X_POS_L+{SP_SIZE*1}

		; Do Pink Ghost Y
		lda <{pink_ghost_y-red_ghost_y}
		and #$FF
		asl
		adc #SCR_OFFSET_Y
		sta |SP00_Y_POS_L+{SP_SIZE*1}

		; Do Blue Ghost X
		lda <{blue_ghost_x-red_ghost_y}
		eor #$FFFF
		inc
		and #$FF
		asl		; x2
		adc #SCR_OFFSET_X
		sta |SP00_X_POS_L+{SP_SIZE*2}

		; Do Blue Ghost Y
		lda <{blue_ghost_y-red_ghost_y}
		and #$FF
		asl
		adc #SCR_OFFSET_Y
		sta |SP00_Y_POS_L+{SP_SIZE*2}

		; Do Orange Ghost X
		lda <{orange_ghost_x-red_ghost_y}
		eor #$FFFF
		inc
		and #$FF
		asl		; x2
		adc #SCR_OFFSET_X
		sta |SP00_X_POS_L+{SP_SIZE*3}

		; Do Orange Ghost Y
		lda <{orange_ghost_y-red_ghost_y}
		and #$FF
		asl
		adc #SCR_OFFSET_Y
		sta |SP00_Y_POS_L+{SP_SIZE*3}

		; Do Ms Pacman X
		lda <{pacman_x-red_ghost_y}
		eor #$FFFF
		inc
		and #$FF
		asl		; x2
		adc #SCR_OFFSET_X
		sta |SP00_X_POS_L+{SP_SIZE*4}

		; Do Ms Pacman Y
		lda <{pacman_y-red_ghost_y}
		and #$FF
		asl		; x2
		adc #SCR_OFFSET_Y
		sta |SP00_Y_POS_L+{SP_SIZE*4}

		; Do Fruit X
		;lda <{fruit_x-red_ghost_y}
		lda >fruit_x
		eor #$FFFF
		inc
		and #$FF
		asl		; x2
		adc #SCR_OFFSET_X
		sta |SP00_X_POS_L+{SP_SIZE*5}

		; Do Fruit Y
		;lda <{fruit_y-red_ghost_y}
		lda >fruit_y
		and #$FF
		asl		; x2
		adc #SCR_OFFSET_Y
		sta |SP00_Y_POS_L+{SP_SIZE*5}

		pld
		plb
;
; Then code to refresh the character map
; convert from MsPac HW to C256
;

;
; Then code to mix C256 Audio
;

;
; Then translated code
;

;008d  f5        push    af		; save AF [restored at #01DA]
;008e  32c050    ld      (#50c0),a	; kick the dog
;0091  af        xor     a		; 0 -> a
;0092  320050    ld      (#5000),a	; disable hardware interrupts
;0095  f3        di			; disable cpu interrupts

		; interrupt shouldn't require disabling in the handler
		; they should already be disabled

; save registers. they are restored starting at #01BF

;0096  c5        push    bc		; save BC
;0097  d5        push    de		; save DE
;0098  e5        push    hl		; save HL
;0099  dde5      push    ix		; save IX
;009b  fde5      push    iy		; save IY

        ;;
        ;; VBLANK - 1 (SOUND)
        ;;
        ;; load the sound into the hardware
	;;
;009d  ld      hl,#CH1_FREQ0             ; pointer to frequencies and volumes of the 3 voices
;00a0  ld      de,#5050                  ; hardware address
;00a3  ld      bc,#0010                  ; #10 (16 decimal) byte to copy
;00a6  ldir                              ; copy
	    ldx #CH1_FREQ0
	    ldy #HW_V0_FREQ0
	    lda #15
	    mvn ^CH1_FREQ0,^HW_V0_FREQ0  ; copy the shadow values into the "HW" registers


	    sep #$30

        ;; voice 1 wave select

;00a8  ld      a,(#CH1_W_NUM)            ; if we play a wave
;00ab  and     a
;00ac  ld      a,(#CH1_W_SEL)            ; then WaveSelect = CH1_W_SEL
;00af  jr      nz,#00b4
;00b1  ld      a,(#CH1_E_TABLE0)         ; else WaveSelect = CH1_E_TABLE0
;00b4  ld      (#5045),a                 ; write WaveSelect to hardware
	    ldx |CH1_W_SEL
	    lda |CH1_W_NUM
	    bne :wsel
	    ldx |CH1_E_TABLE0
:wsel	    stx |HW_WAVESELECT_0


        ;; voice 2 wave select
;00b7  ld      a,(#CH2_W_NUM)
;00ba  and     a
;00bb  ld      a,(#CH2_W_SEL)
;00be  jr      nz,#00c3
;00c0  ld      a,(#CH2_E_TABLE0)
;00c3  ld      (#504a),a
	    ldx |CH2_W_SEL
	    lda |CH2_W_NUM
	    bne :wsel2
	    ldx |CH2_E_TABLE0
:wsel2      stx |HW_WAVESELECT_1

        ;; voice 3 wave select

;00c6  ld      a,(#CH3_W_NUM)
;00c9  and     a
;00ca  ld      a,(#CH3_W_SEL)
;00cd  jr      nz,#00d2
;00cf  ld      a,(#CH3_E_TABLE0)
;00d2  ld      (#504f),a
	    ldx |CH3_W_SEL
	    lda |CH3_W_NUM
	    bne :wsel3
	    ldx |CH3_E_TABLE0
:wsel3	    stx |HW_WAVESELECT_2

	    rep #$31

	;$$JGA TODO
	; copy last frame calculated sprite data into sprite buffer

;00d5  21024c    ld      hl,#4c02	; load HL with source address (calculated sprite data)
;00d8  11224c    ld      de,#4c22	; load DE with destination (sprite buffer)
;00db  011c00    ld      bc,#001c	; load counter with #1C bytes to copy
;00de  edb0      ldir    		; copy

	;$$JGA TODO
	; update sprite data, adjusting to hardware

;00e0  dd21204c  ld      ix,#4c20	; load IX with start of sprite buffer	
;00e4  dd7e02    ld      a,(ix+#02) 	; load A with red ghost sprite
;00e7  07        rlca
;00e8  07        rlca			; rotate 2 bits up 
;00e9  dd7702    ld      (ix+#02),a	; store
;00ec  dd7e04    ld      a,(ix+#04)	; load A with pink ghost sprite
;00ef  07        rlca    
;00f0  07        rlca    		; rotate 2 bits up
;00f1  dd7704    ld      (ix+#04),a	; store
;00f4  dd7e06    ld      a,(ix+#06)	; load A with blue (inky) ghost sprite
;00f7  07        rlca    
;00f8  07        rlca    		; rotate 2 bits up
;00f9  dd7706    ld      (ix+#06),a	; store
;00fc  dd7e08    ld      a,(ix+#08)	; load A with orange ghost sprite
;00ff  07        rlca    
;0100  07        rlca    		; rotate 2 bits up
;0101  dd7708    ld      (ix+#08),a	; store
;0104  dd7e0a    ld      a,(ix+#0a)	; load A with ms pac sprite
;0107  07        rlca    
;0108  07        rlca    		; rotate 2 bits up
;0109  dd770a    ld      (ix+#0a),a	; store
;010c  dd7e0c    ld      a,(ix+#0c)	; load A with fruit sprite
;010f  07        rlca    
;0110  07        rlca    		; rotate 2 bits up
;0111  dd770c    ld      (ix+#0c),a	; store

;0114  3ad14d    ld      a,(#4dd1)	; load A with killed ghost animation state
			lda |dead_ghost_anim_state
;0117  fe01      cp      #01		; is there a ghost being eaten ?
			cmp #1
;0119  2038      jr      nz,#0153        ; no , skip ahead
			bne :not_eaten

			;;$$JGA TODO
;011b  dd21204c  ld      ix,#4c20	; else load IX with sprite data buffer start
;011f  3aa44d    ld      a,(#4da4)	; load A with the unhandled killed ghost #
;0122  87        add     a,a		; A := A * 2
;0123  5f        ld      e,a		; copy to E
;0124  1600      ld      d,#00		; D := #00
;0126  dd19      add     ix,de		; add to index.  now has the eaten ghost sprite
;0128  2a244c    ld      hl,(#4c24)	; load HL with start of ghost sprite address
;012b  ed5b344c  ld      de,(#4c34)	; load DE with sprite number and color for spriteram
;012f  dd7e00    ld      a,(ix+#00)	; load A with eaten ghost sprite
;0132  32244c    ld      (#4c24),a	; store
;0135  dd7e01    ld      a,(ix+#01)	; load A with next ghost sprite
;0138  32254c    ld      (#4c25),a	; store
;013b  dd7e10    ld      a,(ix+#10)	; load A with eaten ghost spriteram
;013e  32344c    ld      (#4c34),a	; store
;0141  dd7e11    ld      a,(ix+#11)	; load A with next ghost spriteram
;0144  32354c    ld      (#4c35),a	; store
;0147  dd7500    ld      (ix+#00),l	; 
;014a  dd7401    ld      (ix+#01),h
;014d  dd7310    ld      (ix+#10),e
;0150  dd7211    ld      (ix+#11),d	; store L, H, E, and D

:not_eaten
;0153  3aa64d    ld      a,(#4da6)	; load A with power pill effect (1=active, 0=no effect)
			lda |powerpill
;0156  a7        and     a		; is a power pill active ?
;0157  ca7601    jp      z,#0176		; no, skip ahead
			beq :no_power

; power pill active

		;; $$JGA TODO - I will need to do all this sprite stuff here and above
		;; so that we cn have the sprites sorted

;015a  ed4b224c  ld      bc,(#4c22)	; else swap pac for first ghost.  load BC with red ghost sprite
;015e  ed5b324c  ld      de,(#4c32)	; load DE with highest sprite for spriteram
;0162  2a2a4c    ld      hl,(#4c2a)	; load HL with fruit sprite
;0165  22224c    ld      (#4c22),hl	; store into highest priority sprite
;0168  2a3a4c    ld      hl,(#4c3a)	; load HL with ms pac spriteram
;016b  22324c    ld      (#4c32),hl	; store into highest priority spriteram
;016e  ed432a4c  ld      (#4c2a),bc	; store first ghost sprite
;0172  ed533a4c  ld      (#4c3a),de	; store first ghost spriteram

:no_power

;0176  21224c    ld      hl,#4c22	; load source address with start of sprites
;0179  11f24f    ld      de,#4ff2	; load destiantion address with spriteram2
;017c  010c00    ld      bc,#000c	; set counter at #0C bytes

; green eyed ghost bug encountered here
; 4FF2,3 - 
; 4FF2,3 - red ghost (8x,11)
; 4FF4,5 - pink ghost (8x,11)
; 4FF6,7 - blue ghost (8x,11)
; 4FF8,9 - orange ghost (8x,11)

; the actual hardware sprite BLIT

;017f  edb0      ldir    		; copy

;0181  21324c    ld      hl,#4c32	; load source address with start of spriteram	
;0184  116250    ld      de,#5062	; load destination address with hardware sprite
;0187  010c00    ld      bc,#000c	; set counter at #0C bytes
;018a  edb0      ldir			; copy [write updated sprites to spriteram]

;------------------------------------------------------------------------------
;
; Core game loop
;

;018c  cddc01    call    #01dc		; update all timers
			jsr update_timers

;018f  cd2102    call    #0221		; check timed tasks and execute them if it is time to do so
			jsr check_timed_tasks

;0192  cdc803    call    #03c8		; runs subprograms based on game mode, power-on stuff, attract mode, push start screen, and core loops for game playing
			jsr gamemode_dispatch

;0195  3a004e    ld      a,(#4e00)	; load A with game mode
			lda |mainstate
;0198  a7        and     a		; is the game still in power-on mode ?
;0199  2812      jr      z,#01ad         ; yes, skip over next calls
			beq :init

;019B  cd9d03    call    #039d		; check for double size pacman in intermission (pac-man only)
			; this is a nop, in ms.pacman

;019E  cd9014    call    #1490		; when player 1 or 2 is played without cockatil mode, update all sprites
			jsr sprite_updater

;01a1  cd1f14    call    #141f		; when player 2 is played on cockatil mode, update all sprites
;01a4  cd6702    call    #0267		; debounce rack input / add credits
			jsr coin_input
;01a7  cdad02    call    #02ad		; debounce coin input / add credits
			jsr coin_debounce
;01aa  cdfd02    call    #02fd		; blink coin lights
			jsr blink_coin_lights
					; print player 1 and player two
					; check for game mode 3
					; draw cprt stuff
:init
;01ad  3a004e    ld      a,(#4e00)	; load A with game mode
			lda |mainstate
;01b0  3d        dec     a		; are we in the demo mode ?
			dec
;01b1  2006      jr      nz,#01b9        ; no, skip next 2 steps		; set to jr #01b9 to enable sound in demo
			bne :not_demo
;01B3: 32 AC 4E	ld	(#4EAC),a	; yes, clear sound channel 2
;01B6: 32 BC 4E	ld	(#4EBC),a	; clear sound channel 3
			sta |CH2_E_NUM
			sta |CH3_E_NUM

        ;; VBLANK - 2 (SOUND)
        ;;
        ;; Process sound
:not_demo
;01b9    call    #2d0c                   ; process effects
			jsr process_effects
;01bc    call    #2cc1                   ; process waves
			jsr intermission_sprite_blit ; 9797 (because ms pac)
			jsr process_waves ; decided to call from here, instead of chaining from the intermession_sprite_blit

; restore registers.  they were saved at #0096

;01bf  fde1      pop     iy		; restore IY
;01c1  dde1      pop     ix		; restore IX
;01c3  e1        pop     hl		; restore HL
;01c4  d1        pop     de		; restore DE
;01c5  c1        pop     bc		; restore BC

;

;01c6  3a004e    ld      a,(#4e00)	; load A with game mode
			lda |mainstate
;01c9  a7        and     a		; is this the initialization?
;01ca  2808      jr      z,#01d4         ; yes, skip ahead
			beq :init_state

;01cc  3a4050    ld      a,(#5040)	; else load A with IN1
;01cf  e610      and     #10		; is the service mode switch set ?

	; elimiate test mode ; HACK7
	;01d1  00        nop
	;01d2  00        nop
	;01d3  00        nop
	;

;01d1  ca0000    jp      z,#0000		; yes, reset
:init_state
;01d4  3e01      ld      a,#01		; else A := #01
;01d6  320050    ld      (#5000),a	; reenable hardware interrupts
;01d9  fb        ei      		; enable cpu interrupts
;01da  f1        pop     af		; restore AF [was saved at #008D]
;01db  c9        ret     		; return

;------------------------------------------------------------------------------
; Inject our code to copy the original Ms Pacman HW areas, over to the
; C256 so that we can see what's happening
;

			jsr BlitColorMap	; Based on Color RAM, fix up Vicky CLUTs
			jsr BlitMap		; Copy the map data from tile_ram, to the Vicky RAM


;-----------------------------------------------------------------------------
; Get something going with the input

	sep #$30

	; for latching
	lda |IN0
	sta |last_IN0
	lda |IN1
	sta |last_IN1


    ; IN0

	lda |IN0
	ora #JOY_UP_BIT

	ldx |keyboard+KEY_UP
	beq :set_up
	; clear_up
	and #JOY_UP_BIT!$FF
:set_up
	ora #JOY_DOWN_BIT
	ldx |keyboard+KEY_DOWN
	beq :set_down
	; clear down
	and #JOY_DOWN_BIT!$FF
:set_down
	ora #JOY_LEFT_BIT
	ldx |keyboard+KEY_LEFT
	beq :set_left
	; clear left
	and #JOY_LEFT_BIT!$FF
:set_left
	ora #JOY_RIGHT_BIT
	ldx |keyboard+KEY_RIGHT
	beq :set_right
	; clear right
	and #JOY_RIGHT_BIT!$FF
:set_right
	ora #COIN1_INSERT_BIT
	ldx |keyboard+KEY_F1
	beq :setcoin1
	and #COIN1_INSERT_BIT!$FF
:setcoin1
	sta |IN0

    ; IN1

	lda |IN1
	ora #P1_START_BIT
	ldx |keyboard+KEY_F2
	beq :setstart1
	and #P1_START_BIT!$FF
:setstart1

	sta |IN1

	rep #$30

	jsr DebugAudio
	jsr DebugMouse

	rep #$30

;
; Restore the temp variables, that might have been stomped on, that
; the foreground tasks might be using
;

			plx
			pla
			sta <temp7
			stx <temp7+2
			plx
			pla
			sta <temp6
			stx <temp6+2
			plx
			pla
			sta <temp5
			stx <temp5+2
			plx
			pla
			sta <temp4
			stx <temp4+2
			plx
			pla
			sta <temp3
			stx <temp3+2
			plx
			pla
			sta <temp2
			stx <temp2+2
			plx
			pla
			sta <temp1
			stx <temp1+2
			plx
			pla
			sta <temp0
			stx <temp0+2

			rts

;------------------------------------------------------------------------------

	; called from #018C
	; this sub increments the timers and random numbers from #4C84 to #4C8C
update_timers mx %00
:c = temp0
:loop_count = temp1

;01dc  21844c    ld      hl,#4c84	; load HL with sound counter address
;01df  34        inc     (hl)		; increment
;01e0  23        inc     hl		; load HL with 2nd sound counter address
;01e1  35        dec     (hl)		; decrement
			sep #$20
			inc |SOUND_COUNTER
			dec |SOUND_COUNTER+1
			;rep #$20
;01e2  23        inc     hl		; next address.  HL now has #4C86
;01e3  111902    ld      de,#0219	; load DE with start of table data
			ldy #0
;01e6  010104    ld      bc,#0401	; C := #01,  For B = 1 to 4, 
			ldx #1
			stx <:c

			ldx #4
			stx <:loop_count

			tyx
:loop
;01e9  34        inc     (hl)		; increase memory
			inc |counter0,x
;01ea  7e        ld      a,(hl)		; load A with this value
			lda |counter0,x
;01eb  e60f      and     #0f		; mask bits, now between #00 and #0F
			and #$0F
;01ed  eb        ex      de,hl		; DE <-> HL
;01ee  be        cp      (hl)		; compare with value in table
			cmp |:data,y
;01ef  2013      jr      nz,#0204        ; if not equal, break out of loop
			bne :break_loop
;01f1  0c        inc     c		; else C := C + 1
			inc <:c
;01f2  1a        ld      a,(de)		; load A with the value
			lda |counter0,x
;01f3  c610      add     a,#10		; add #10
			clc
			adc #$10
;01f5  e6f0      and     #f0		; mask bits
			and #$F0
;01f7  12        ld      (de),a		; store result
			sta |counter0,x
;01f8  23        inc     hl		; next table value
			iny
;01f9  be        cp      (hl)		; compare with value in table
			cmp |:data,y

;01fa  2008      jr      nz,#0204        ; if not equal, break out of loop
			bne :break_loop
;01fc  0c        inc     c		; else C := C + 1
			inc <:c
;01fd  eb        ex      de,hl		; DE <-> HL
;01fe  3600      ld      (hl),#00	; clear the value in HL
			stz |counter0,x
;0200  23        inc     hl		; next HL
			inx
;0201  13        inc     de		; next table value
			iny
;0202  10e5      djnz    #01e9           ; loop
			dec <:loop_count
			bne :loop

; set up psuedo random number generator values, #4C8A, #4C8B, #4C8C
:break_loop
;0204  218a4c    ld      hl,#4c8a	; load HL with timer address
;0207  71        ld      (hl),c		; store C which was computed above
			lda <:c
			sta |counter_limits
;0208  2c        inc     l		; next address.  HL now has #4C8B
;			inx
;0209  7e        ld      a,(hl)		; load A with the value from this timer
			lda |unused_rng0
;020a  87        add     a,a		; A := A * 2
			asl
;020b  87        add     a,a		; A := A * 2
			asl
;020c  86        add     a,(hl)		; A := A + (HL) (A is now 5 times what it was)
			clc
			adc |unused_rng0
;020d  3c        inc     a		; increment.   (A is now 5 times plus 1 what it was)
			inc
;020e  77        ld      (hl),a		; store new value
			sta |unused_rng0
;020f  2c        inc     l		; next address.  HL now has #4C8C
;			inx
;0210  7e        ld      a,(hl)		; load A with the value from this timer
			lda |unused_rng1
;0211  87        add     a,a		; A := A * 2
			asl
;0212  86        add     a,(hl)		; A := A + (HL) (A is now 3 times what it was)  
			clc
			adc |unused_rng1
;0213  87        add     a,a		; A := A * 2
			asl
;0214  87        add     a,a		; A := A * 2
			asl
;0215  86        add     a,(hl)		; A := A + (HL) (A is now 13 times what it was)
			clc
			adc |unused_rng1
;0216  3c        inc     a		; increment.  (A is now 13 times plus 1 what it was)
			inc
;0217  77        ld      (hl),a		; store result
			sta |unused_rng1
;0218  c9        ret			; return
		rep #$20
		rts

; data used in subroutine above, loaded at #01E3
;0219
:data db $06,$A0,$0A,$60,$0A,$60,$0A,$A0

;------------------------------------------------------------------------------
; checks timed tasks
; counts down timer and executes the task if the timer has expired
; called from #018F
;0221
check_timed_tasks mx %00

;	    jsr DebugTimedTasks

:pTask = temp0
:counter_mask = temp1
:loop_count = temp2
;0221: 21 90 4C	ld	hl,#4C90	; load HL with task list address
	    lda #irq_tasks
	    sta <:pTask

;0224: 3A 8A 4C	ld	a,(#4C8A)	; load A with number of counter limits changes in this frame
	    lda |counter_limits
	    sta <:counter_mask
;0227: 4F	ld	c,a		; save to C for testing in line #0232
;0228: 06 10	ld	b,#10		; for B = 1 to #10
	    lda #16
	    sta <:loop_count
:task_loop
	    sep #$20
;022A: 7E	ld	a,(hl)		; load A with task list first value (timer)
	    lda (:pTask)
;022B: A7	and	a		; == #00 ?  (is this task empty?)
;022C: 28 2F	jr	z,#025D		; Yes, jump ahead and loop for next task
	    beq :next_task

;022E: E6 C0	and	#C0		; else mask bits with binary 1100 0000 - the left 2 bits (6 and 7) are the time units
	    and #$C0
	    clc
;0230: 07	rlca
	    rol		
;0231: 07	rlca			; rotate twice left.  The time unit bits are now rightmost, in bits 0 and 1.  EG #02 for seconds
	    rol
	    rol
;0232: B9	cp	c		; compare to counter.  is it time to count down the timer?
	    cmp <:counter_mask
;0233: 30 28	jr	nc,#025D	; if no, jump ahead and loop for next task
	    ;beq :dec_time
	    bcs :next_task
:dec_time
;0235: 35	dec	(hl)		; else decrease the task timer
	    lda (:pTask)
	    dec
	    sta (:pTask)
;0236: 7E	ld	a,(hl)		; load A with new task timer
	    ;lda (:pTask)
;0237: E6 3F	and	#3F		; mask bits with binary 0011 1111. This will erase the units in the left 2 bits. is the timer counted all the way down?
	    and #$3F
;0239: 20 22	jr	nz,#025D	; no, jump ahead and loop for next task
	    bne :next_task

;023B: 77	ld	(hl),a		; yes, store A into task timer.  this should be zero and effectively clears the task
;   		sep #$20
	    sta (:pTask)
	    rep #$20

;023C: C5	push	bc		; save BC
	    pei <:counter_mask
	    pei <:loop_count
;023D: E5	push	hl		; save HL
	    pei <:pTask
;023E: 2C	inc	l		; HL now has the coded task number address
	    inc <:pTask
;023F: 7E	ld	a,(hl)		; load A with task number, used for jump table below
	    lda (<:pTask)
	    and #$FF
	    asl
	    tax
;0240: 2C	inc	l		; HL now has the coded task parameter address
	    inc <:pTask
;0241: 46	ld	b,(hl)		; load B with task parameter
	    lda (<:pTask)
;0242: 21 5B 02	ld	hl,#025B	; load HL with return address
	    pea :return_addy-1
;0245: E5	push	hl		; push to stack so a RET call will return to #025B
;0246: E7	rst	#20		; jump based on A
	    jmp (:table,x)
:table
	    da ttask0 ; A==0, #0894 ; increases main subroutine number (#4E04) and returns 
	    da ttask1 ; A==1, #06A3	; increments main routine 2, subroutine # (#4E03)
	    da ttask2 ; A==2, #058E ; increases the main routine # (#4E02)
	    da ttask3 ; A==3, #1272 ; increases killed ghost animation state when a ghost is eaten
	    da clear_fruit ; A==4, #1000 ; clears the fruit sprite
	    da ttask5 ; A==5, #100B ; clears the fruit score sprite
	    da ttask6 ; A==6, #0263 ; clears the "READY!" message
	    da ttask7 ; A==7, #212B ; to increase state in 1st cutscene (#4E06) (pac-man only)
	    da ttask8 ; A==8, #21F0 ; to increase state in 2nd cutscene (#4E07) (pac-man only)
	    da ttask9 ; A==9, #22B9 ; to increase state in 3rd cutscene (#4E08) (pac-man only)
:return_addy
;025B: E1            pop  hl		; restore HL
	    pla
	    sta <:pTask
;025C: C1            pop  bc		; restore BC
	    pla
	    sta <:loop_count
	    pla
	    sta <:counter_mask
:next_task
;025D: 2C            inc  l
;025E: 2C            inc  l
;025F: 2C            inc  l		; next task
	    rep #$30
	    inc <:pTask
	    inc <:pTask
	    inc <:pTask
;0260: 10 C8         djnz #022A		; next B
	    dec <:loop_count
	    bne :task_loop
;0262: C9            ret			; return    
	    rts

;------------------------------------------------------------------------------
; timed task #06 - clears ready message
;0263
ttask6 mx %00
;0263  EF        rst     #28		; insert task #1C, parameter 86 to clear the "READY!" message
;0264  1C 86				; task data
	lda #$861C
	jsr rst28
;0266  C9        ret     		; return
	rts


;------------------------------------------------------------------------------
; debounce rack input / add credits (if 99 or over, return)
; called from #01A4
;0267
coin_input mx %00
;0267  3a6e4e    ld      a,(#4e6e)	; load A with number of  current credits in BCD
;026a  fe99      cp      #99		; == #99 ? (99 is max number of credits avail)
;026c  17        rla     		; rotate left A
;026d  320650    ld      (#5006),a	; store into #5006 (coin lockout, not used ?)
;0270  1f        rra     		; rotate right A
;0271  d0        ret     nc		; return if 99 credits
	    lda |no_credits
	    cmp #$99
	    bcc :lessthan99
	    rts

:lessthan99
;0272  3a0050    ld      a,(#5000)	; load A with IN0 input (joystick, credits, service mode button)
	    lda #COIN1_INSERT_BIT
	    jsr :checkcoin
	    lda #COIN2_INSERT_BIT

:checkcoin
	    bit |IN0
	    bne :rts
	    bit |last_IN0
	    beq :rts

	    inc |coin_counter
:rts
	    rts

;0275  47        ld      b,a		; copy to B
;0276  cb00      rlc     b		; rotate left
;0278  3a664e    ld      a,(#4e66)	; load A with service mode indicator
;027b  17        rla     		; rotate left with carry
;027c  e60f      and     #0f		; and it with #0F
;027e  32664e    ld      (#4e66),a	; put it back
;0281  d60c      sub     #0c		; subtract #0C.  is the service mode being used to add a credit?
;0283  ccdf02    call    z,#02df		; If yes, call #02df  ; add credit
;0286  cb00      rlc     b		; rotate left B
;0288  3a674e    ld      a,(#4e67)	; load A with coin input #1
;028b  17        rla     		; rotate left
;028c  e60f      and     #0f		; mask bits
;028e  32674e    ld      (#4e67),a	; put back
;0291  d60c      sub     #0c		; subtract C.  is a coin being inserted?
;0293  c29a02    jp      nz,#029a	; no, skip ahead
;0296  21694e    ld      hl,#4e69	; yes, load HL with coin counter
;0299  34        inc     (hl)		; increase counter
;029a  cb00      rlc     b		; rotaate left B
;029c  3a684e    ld      a,(#4e68)	; load A with coint input #2
;029f  17        rla     		; rotate left
;02a0  e60f      and     #0f		; maks bits
;02a2  32684e    ld      (#4e68),a	; put back
;02a5  d60c      sub     #0c		; subtract #0C.  is a coin being inserted?
;02a7  c0        ret     nz		; no, return

;02a8  21694e    ld      hl,#4e69	; else load HL with coin counter
;02ab  34        inc     (hl)		; increase
;02ac  c9        ret     		; return


;------------------------------------------------------------------------------
; debounce coin input / add credits
; called from #01A7
;02ad
coin_debounce mx %00

	    jsr coins_credits

	    rts

;02ad  3a694e    ld      a,(#4e69)	; load A with coin counter
;02b0  a7        and     a		; == #00 ?
;02b1  c8        ret     z		; yes, return
;02b2  47        ld      b,a		; else copy coin counter to B
;02b3  3a6a4e    ld      a,(#4e6a)	; load A with coin counter timeout
;02b6  5f        ld      e,a		; copy timeout to E
;02b7  fe00      cp      #00		; is the timeout == #00?
;02b9  c2c402    jp      nz,#02c4	; no, skip ahead
;02bc  3e01      ld      a,#01		; else A := #01
;02be  320750    ld      (#5007),a	; store into coin counter
;02c1  cddf02    call    #02df		; call coins -> credits routine
;02c4  7b        ld      a,e		; load A with timeout
;02c5  fe08      cp      #08		; is the timeout == #08 ?
;02c7  c2ce02    jp      nz,#02ce	; no, skip next 2 steps
;02ca  af        xor     a		; A := #00
;02cb  320750    ld      (#5007),a	; clear coin counter
;02ce  1c        inc     e		; increment timeout
;02cf  7b        ld      a,e		; copy to A
;02d0  326a4e    ld      (#4e6a),a	; store into coin counter timeout
;02d3  d610      sub     #10		; subtract #10.  did the timeout end?
;02d5  c0        ret     nz		; no, return
;02d6  326a4e    ld      (#4e6a),a	; else clear the counter timeout [A now has #00]
;02d9  05        dec     b		; decrement B, this was a copy of the coin counter
;02da  78        ld      a,b		; copy to A
;02db  32694e    ld      (#4e69),a	; store into coin counter
;02de  c9        ret     		; return

;------------------------------------------------------------------------------
; coins -> credits routine
;02df
coins_credits mx %00
;02df  3a6b4e    ld      a,(#4e6b)	; load A with #coins per #credits
;02e2  216c4e    ld      hl,#4e6c	; load HL with # of leftover coins
;02e5  34        inc     (hl)		; add 1
;02e6  96        sub     (hl)		; subract this value from A
;02e7  c0        ret     nz		; if not zero, then not enough coins for credits.  return

	    lda |coin_counter
	    beq :not_enough

	    cmp |no_coins_per_credit
	    bcc :not_enough

	    sbc |no_coins_per_credit
	    sta |coin_counter

;02e8  77        ld      (hl),a		; else store A into leftover coins
;02e9  3a6d4e    ld      a,(#4e6d)	; load A with #credits per #coins
;02ec  216e4e    ld      hl,#4e6e	; load HL with #credits
;02ef  86        add     a,(hl)		; add # credits
;02f0  27        daa     		; decimal adjust
;02f1  d2f602    jp      nc,#02f6	; if no carry, skip ahead
;02f4  3e99      ld      a,#99		; else load a with #99
;02f6  77        ld      (hl),a		; store #credits, max #99
	    lda |no_credits
	    cmp #$99
	    bcs :maxed_out

	    sed
	    adc #1
	    cld
	    sta |no_credits
:maxed_out
;02f7  219c4e    ld      hl,#4e9c	; load HL with sound register
;02fa  cbce      set     1,(hl)		; play credit sound
;02fc  c9        ret     		; return
	    lda #2
	    tsb |CH1_E_NUM
:not_enough
	    rts


;------------------------------------------------------------------------------
; blink coin lights, print player 1 and player 2, check for mode 3
; called from #01AA
;02fd
blink_coin_lights mx %00
;02fd  21ce4d    ld      hl,#4dce	; load HL with counter started after insert coin (LED and 1UP/2UP blink)
;0300  34        inc     (hl)		; increment counter
			inc |insert_coin_timer

:skip_ahead
;0325  dd21d843  ld      ix,#43d8	; load IX with start address where the screen shows "1UP"
			ldx #$03d8
;0329  fd21c543  ld      iy,#43c5	; load IY with start address where the screen shows "1UP"
			ldy #$03c5
;032d  3a004e    ld      a,(#4e00)	; load A with game mode
			lda |mainstate
;0330  fe03      cp      #03		; is a game being played ?
			cmp #3
;0332  ca4403    jp      z,#0344		; Yes, Jump ahead
			beq :game_played

;0335  3a034e    ld      a,(#4e03)	; else load A with main routine 2, subroutine #
;0338  fe02      cp      #02		; <= 2 ?
			lda |mainroutine2
			cmp #3
;033a  d24403    jp      nc,#0344	; yes, skip ahead
			bcc :game_played

;033d  cd6903    call    #0369		; else draw "1UP"
			jsr draw_1up
;0340  cd7603    call    #0376		; draw "2UP"
			jsr draw_2up
;0343  c9        ret     		; return
			rts

	;; display and blink 1UP/2UP depending on player up
:game_played
;0344  3a094e    ld      a,(#4e09)	; load A with current player number:  0=P1, 1=P2
			lda |player_no
			php
;0347  a7        and     a		; is this player 1 ?
;0348  3ace4d    ld      a,(#4dce)	; load A with counter started after insert coin (LED and 1UP/2UP blink)
			lda |insert_coin_timer
			plp
;034b  c25903    jp      nz,#0359	; 
			bne :up2

;034e  cb67      bit     4,a		; test bit 4 of the counter.  is it on?
			bit #$10
;0350  cc6903    call    z,#0369		; no, draw  "1UP"
			bne :clear1up
			jsr draw_1up
			bra :skip361
;0353  c48303    call    nz,#0383	; yes, clear "1UP"
;356  c36103    jp      #0361		; skip ahead
:clear1up
			jsr clear_1up
			bra :skip361
:up2
;0359  cb67      bit     4,a		; test bit 4 of the counter.  is it on?
			bit #$10
;035b  cc7603    call    z,#0376		; no, draw  "2UP"
			bne :clear2up
			jsr draw_2up
			bra :skip361
:clear2up
;035e  c49003    call    nz,#0390	; yes, clear "2UP"
			jsr clear_2up
			rts
:skip361
;0361  3a704e    ld      a,(#4e70)	; load A with player# (0=player1, 1=player2)
;0364  a7        and     a		; is this player 1 ?
			lda |no_players
			beq clear_2up
;0365  cc9003    call    z,#0390		; yes, clear "2UP"
;0368  c9        ret			; return
			rts

;------------------------------------------------------------------------------
; draw "1UP"
;0369
draw_1up mx %00
;0369  dd360050  ld      (ix+#00),#50	; 'P'
;036d  dd360155  ld      (ix+#01),#55	; 'U'
			lda #$5550
			sta |tile_ram,x
;0371  dd360231  ld      (ix+#02),#31	; '1'
			lda #$3155
			sta |tile_ram+1,x
;0375  c9        ret     
			rts

;------------------------------------------------------------------------------
; draw "2UP"
;0376
draw_2up mx %00
;0376  fd360050  ld      (iy+#00),#50	; 'P'
;037a  fd360155  ld      (iy+#01),#55	; 'U'
			lda #$5550
			sta |tile_ram,y
;037e  fd360232  ld      (iy+#02),#32	; '2'
			lda #$3255
			sta |tile_ram+1,y
;0382  c9        ret     
			rts

;------------------------------------------------------------------------------
; clear "1UP"
;0383
clear_1up mx %00
			lda #$4040
;0383  dd360040  ld      (ix+#00),#40	; ' '
;0387  dd360140  ld      (ix+#01),#40	; ' '
;038b  dd360240  ld      (ix+#02),#40	; ' '
			sta |tile_ram,x
			sta |tile_ram+1,x
;038f  c9        ret
			rts

;------------------------------------------------------------------------------
; clear "2UP"
;0390
clear_2up mx %00
			lda #$4040
;0390  fd360040  ld      (iy+#00),#40	; ' '
;0394  fd360140  ld      (iy+#01),#40	; ' '
			sta |tile_ram,y
;0398  fd360240  ld      (iy+#02),#40	; ' '
			sta |tile_ram+1,y
;039c  c9        ret
			rts

;------------------------------------------------------------------------------
;; enable sound out and other stuff
; called from #0192
;03c8
gamemode_dispatch mx %00
;03c8  3a004e    ld      a,(#4e00)	; load A with game mode
;03cb  e7        rst     #20		; jump based on A
			lda |mainstate
			asl
			tax
			jmp (:dispatch,x)
:dispatch
			da power_on	 ;#03D4;#4E00 = 0 ;GAME POWER ON
			da attract_mode  ;#03FE;#4E00 = 1 ;ALL ATTRACT MODES.  this runs until a credit is inserted
			da oneortwo      ;#05E5;#4E00 = 2 ;PLAYER 1 OR 2 SCREEN.  draw screen and wait for start to be pressed
			da gameplay_mode ;#06BE;#4E00 = 3 ;PLAYER 1 OR 2 PLAYING.  runs core game loop

;------------------------------------------------------------------------------
; arrive here after power on
;03d4
power_on mx %00

;03d4  3a014e	ld	a,(#4e01)	; load A with main routine 0, subroutine #
;03d5  e7        rst     #20		; jump based on A
			lda |mainroutine0
			asl
			tax
			jmp (:table,x)
:table
			da :init ; #03DC
			da :rts  ; #000C.  returns immediately (to #0195)

; arrive here after powering on
; this sets up the following tasks
;03DC
:init
;03DC: EF        rst	#28		; insert task to clear the whole screen
;03DD: 00 00				; data for above, task #00         
			lda #$0000
			jsr rst28

;03DF: EF        rst	#28		; insert task to clear the color RAM
;03E0: 06 00				; data for above, task #06
			lda #$0006
			jsr rst28
;03e2  ef        rst     #28		; insert task color the maze
;03e3  01 00				; data for above, task #01
			lda #$0001
			jsr rst28
;03e5  ef        rst     #28		; insert task to check all dip switches and assign memories to the settings indicated
;03e6  14 00				; data for above, task #14
			lda #$0014
			jsr rst28
;03e8  ef        rst     #28		; insert task - draws "high score" and scores.  clears player 1 and 2 scores to zero.
;03e9  18 00				; data for above, task #18
			lda #$0018
			jsr rst28
;03eb  ef        rst     #28		; insert task - resets a bunch of memories
;03ec  04 00				; data for above, task #04
			lda #$0004
			jsr rst28
;03ee  ef        rst     #28		; insert task - clear fruit, pacman, and all ghosts
;03ef  1e 00				; data for above, task #1E
			lda #$001e
			jsr rst28

;03f1  ef        rst     #28		; insert task - set game to demo mode
;03f2  07 00				; data for above, task #07
			lda #$0007
			jsr rst28

;03F4: 21 01 4E	ld	hl,#4E01	; load HL with main routine 0, subroutine #
;03F7: 34	inc	(hl)		; increase so this sub doesn't run again.
			inc |mainroutine0
;03f8  210150    ld      hl,#5001	; load HL with sound address
;03fb  3601      ld      (hl),#01	; enable sound
			;$$JGA TODO fix the enable sound
:rts
;03fd  c9        ret     		; return
			rts
;------------------------------------------------------------------------------
; attract mode main routine
;03fe
attract_mode mx %00

;03fe  cda12b    call    #2ba1		; write # of credits on screen
			jsr task_drawCredits
;0401  3a6e4e    ld      a,(#4e6e)	; load A with # of credits
			lda |no_credits
;0404  a7        and     a		; == #00 ?
;0405  280c      jr      z,#0413         ; yes, skip ahead
			beq JPATTRACT

;0407  af        xor     a		; else A := #00
;0408  32044e    ld      (#4e04),a	; clear level state subroutine #
			stz |levelstate
;040b  32024e    ld      (#4e02),a	; clear main routine 1, subroutine #
			stz |mainroutine1
;040e  21004e    ld      hl,#4e00	; load HL with game mode
;0411  34        inc     (hl)		; increase game mode to press start screen
			inc |mainstate
;0412  c9        ret     		; return (to #0195)
			rts
	; table lookup
; OTTOPATCH
;PATCH FOR NEW ATTRACT MODE
;ORG 0413H
JPATTRACT
;0413  c35c3e    jp      #3e5c		; jump to mspac patch when there are no credits - controls the demo mode
			jmp ATTRACT
  	   
 						 
;------------------------------------------------------------------------------
; ms. pac code resumes here
; arrive here from #3E67 when subroutine # = 00
; sets up the attract mode
;045f
setup_attract mx %00
;045f  ef        rst     #28		; insert task #00 - clears the maze
;0460  00 01
			lda #$0100
			jsr rst28
;0462  ef        rst     #28		; insert task #01 - colors the screen
;0464  01 00
			lda #$0001
			jsr rst28
;0465  ef        rst     #28		; insert task #04 - resets a bunch of memories
;0466  04 00
			lda #$0004
			jsr rst28
;0468  ef        rst     #28		; insert task #1E - clear fruit, pacman and all ghosts
;0469  1e 00
			lda #$001e
			jsr rst28

;046b  0e0c      ld      c,#0c		; load C with text code for "Ms Pac Man"
;046d  cd8505    call    #0585		; draw text to screen, increase subroutine #
			lda #$0C
			jsr draw_text

;0470  c9        ret     		; return (to #0195)
			rts
 						 
 			
;------------------------------------------------------------------------------
; arrive here in demo mode from #3ECD
;057c
start_mspac2_demo mx %00
;057c  cdbe06    call    #06be		; jump to new subroutine based on game state
			jsr gameplay_mode
;057f  c9        ret   			; returns to #0195  
			rts
			 
;------------------------------------------------------------------------------
; called from #046D and other places.  C is preloaded with the text code to display
;0585
draw_text mx %00
;0585  061c      ld      b,#1c		; load B with task code for text display
			xba
			and #$FF00
			ora #$001C
;0587  cd4200    call    #0042		; insert task to display text, parameter = variable text
			jsr task_add

;058a  f7        rst     #30		; insert timed task to increase the main routine # (#4E02)
;058b  4a 02 00		    		; timer = #4A, task = 2, parameter = 0
; BUGFIX03 - Blue maze - Don Hodges
;058b  41 02 00		    		; 41 is 1/10 second rather than 1 second
;			lda #$0241
 			lda #$024a   	   ; things run further without Don's patch, so we're going to
							   ; leave the original code for now.  And debug
			ldy #0
			jsr rst30
 						 
;------------------------------------------------------------------------------
; called from # 0246 from jump table based on game state
; or, timed task number #02 has been encountered, arrive from #0246
; also arrive from #3E93 during marquee mode in demo
;058e
ttask2
;058e  21024e    ld      hl,#4E02	; load HL with main routine 1, subroutine #
;0591  34        inc     (hl)		; increase
			inc |mainroutine1
;0592  c9        ret     		; return
			rts

;------------------------------------------------------------------------------
; arrive from #03CB
; arrive here when credit has been inserted and game is waiting for start button to be pressed
oneortwo mx %00

			lda |mainroutine2
			asl
			tax
			jmp (:table,x)

;05E5: 3A 03 4E	ld	a,(#4E03)	; load A with main routine 2, subroutine #
;05E8: E7	rst	#20		; jump based on A

:table
			da :drawinfo    ; #05F3		; inserts tasks to draw info on screen
			da :disp12  	; #061B		; display 1/2 player and check start buttons
			da :press_start	; #0674		; run when start button pressed, gets game ready to be played
			da :rts		; #000C		; returns immediately
			da :drawlives	; #06A8		; draw remaining lives at bottom of screen and start game
:rts
			rts
;05F3
:drawinfo mx %00
;05F3: CD A1 2B	call	#2BA1		; write # of credits on screen
			jsr task_drawCredits

;05F6: EF	rst	#28		; insert task to clear the maze
;05F7: 00 01				; task #00, parameter #01
			lda #$0100
			jsr rst28

;05F9: EF	rst	#28		; insert task to color the maze
;05FB: 01 00				; task #01
			lda #$0001
			jsr rst28

;05FC: EF	rst	#28		; insert task to display "PUSH START BUTTON"
;05FD: 1C 07				; task #1c, parameter #07.  
			lda #$071C
			jsr rst28

;05FF: EF	rst	#28		; insert task to display "ADDITIONAL    AT   000"
;0600: 1C 0B				; task #1C, parameter #0B. 
			lda #$0B1C
			jsr rst28

;0602: EF	rst	#28		; insert task to clear fruit, pacman, and all ghosts
;0603: 1E 00				; task #1E
			lda #$001E
			jsr rst28

;0605: 21 03 4E	ld	hl,#4E03	; load HL with main routine 2, subroutine #
;0608: 34	inc	(hl)		; increase
			inc |mainroutine2

;0609: 3E 01	ld	a,#01		; A := #01
			lda #1
;060B: 32 D6 4D	ld	(#4DD6),a	; store in LED state ( 1: game waits for 1P/2P start button press)
			sta |led_state

;060E: 3A 71 4E	ld	a,(#4E71)	; load A with setting for bonus life
			lda |bonus_life
;0611: FE FF	cp	#FF		; does this game award any bonus lives?
;0613: C8	ret	z		; no, return
			cmp #$00FF
			beq :no_bonus_life

;0614: EF	rst	#28		; else insert task to draw the MS PAC MAN graphic which appears between "ADDITIONAL" and "AT 10,000 pts"
;0615: 1C 0A				; task data
			lda #$0A1C
			jsr rst28

;0617: EF	rst	#28		; insert task to write points needed for extra life digits to screen
;0618: 1F 00				; task data
			lda #$001F
			jsr rst28

:no_bonus_life
;061A: C9	ret			; return
			rts
;------------------------------------------------------------------------------
;; jump here from #05E8
;; display 1/2 player and check start buttons
;061b
:disp12 mx %00
;061b  cda12b    call    #2ba1		; write # of credits on screen
		jsr task_drawCredits

;061e  3a6e4e    ld      a,(#4e6e)	; load A with # of credits
		lda |no_credits
;0621  fe01      cp      #01		; is it 1?
		ldy #$09
;0623  0609      ld      b,#09		; load B with message #9:  "1 OR 2 PLAYERS"
		cmp #1
;0625  2002      jr      nz,#0629        ; if >= 2 credits, skip next step
		bne :is1o2
;0627  0608      ld      b,#08		; load B with message #8:  "1 PLAYER ONLY"
		dey
:is1o2
;0629  cd5e2c    call    #2c5e		; print message
		jsr DrawText
;062c  3a6e4e    ld      a,(#4e6e)	; load A with # of credits
		lda |no_credits
;062f  fe01      cp      #01		; 1 credit?
		cmp #1
		beq :only1p
;0631  3a4050    ld      a,(#5040)	; load A with IN1 (player start buttons)
		lda |IN1
;0634  280c      jr      z,#0642         ; don't check p2 with 1 credit
;0636  cb77      bit     6,a		; check for player 2 start button
		bit #P2_START_BIT
;0638  2008      jr      nz,#0642        ; if not, pressed, skip ahead to check for player 1 start
		bne :only1p
;063a  3e01      ld      a,#01		; else set 2 players
;063c  32704e    ld      (#4e70),a	; store into # of players (0=1 player, 1=2 players)
		lda #1
		sta |no_players
;063f  c34906    jp      #0649		; jump ahead
		bra :players_set 
:only1p
		lda |IN1
;0642  cb6f      bit     5,a		; player 1 start being pressed ?
;0644  c0        ret     nz		; no, return
		bit #P1_START_BIT
		bne :rts

;0645  af        xor     a		; A := #00
;0646  32704e    ld      (#4e70),a	; store into # of players (0=1 player, 1=2 players)
		stz |no_players
:players_set
;0649  3a6b4e    ld      a,(#4e6b)	; load A with number of coins per credit
;064c  a7        and     a		; Is free play activated?
		lda |no_coins_per_credit
;064d  2815      jr      z,#0664         ; Yes, skip ahead
		beq :skip_free
;064f  3a704e    ld      a,(#4e70)	; else load A with # of players
;0652  a7        and     a		; Is this a 1 player game?
		lda |no_players
		beq :num_players1
;0653  3a6e4e    ld      a,(#4e6e)	; load A with number of credits
;0656  2803      jr      z,#065b         ; If 1 player game, skip ahead and only subtract 1 credit
;0658  c699      add     a,#99		; else subtract 2 credits.  one here...
;065a  27        daa     		; decimal adjust
		sec
		sed
		lda |no_credits
		sbc #1
		sta |no_credits
		cld
:num_players1
		sec
		sed
;065b  c699      add     a,#99		; subtract a credit
;065d  27        daa     		; decimal adjust
;065e  326e4e    ld      (#4e6e),a	; save result in credits counter
		lda |no_credits
		sbc #1
		sta |no_credits
		cld
;0661  cda12b    call    #2ba1		; write # of credits on screen
		jsr task_drawCredits
:skip_free
;0664  21034e    ld      hl,#4e03	; load HL with main routine 2, subroutine #
;0667  34        inc     (hl)		; increase
		inc |mainroutine2
;0668  af        xor     a		; A := #00
;0669  32d64d    ld      (#4dd6),a	; store in LED state ( 1: game waits for 1P/2P start button press)
		stz |led_state
;066c  3c        inc     a		; A := #01
;066d  32cc4e    ld      (#4ecc),a	; store in wave to play (begins intro music tune)
;0670  32dc4e    ld      (#4edc),a	; store in wave to play (beigns intro music tune)
		sep #$20
		stz |CH1_W_NUM
		stz |CH2_W_NUM
		rep #$30
:rts
;0673  c9        ret     		; return (to #0195)
		rts
	; arrive from #05E8 when start button has been pressed
:press_start mx %00

;0674  ef        rst     #28		; set task #00, parameter #01 - clears the maze
;0675  00 01
			lda #$0100
			jsr rst28

;0677  ef        rst     #28		; set task #01, parameter #01 - colors the maze
;0678  01 01
			lda #$0101
			jsr rst28

;067a  ef        rst     #28		; set task #02, parameter #00 - draws the maze
;067b  02 00
			lda #$0002
			jsr rst28

;067d  ef        rst     #28		; set task #12, parameter #00 - sets up coded pill and power pill memories
;067e  12 00
			lda #$0012
			jsr rst28
;0680  ef        rst     #28		; set task #03, parameter #00 - draws the pellets
;0681  03 00
			lda #$0003
			jsr rst28
;0683  ef        rst     #28		; set task #1C, parameter #03 - draws text on screen "PLAYER 1"
;0684  1c 03
			lda #$031c
			jsr rst28
;0686  ef        rst     #28		; set task #1C, parameter #06 - draws text on screen "READY!" and clears the intermission indicator
;0687  1c 06
			lda #$061c
			jsr rst28
;0689  ef        rst     #28		; set task #18, parameter #00 - draws "high score" and scores.  clears player 1 and 2 scores to zero.
;068a  18 00
			lda #$0018
			jsr rst28
;068c  ef        rst     #28		; set task #1B, parameter #00 - draws fruit at bottom right of screen
;068d  1b 00
			lda #$001b
			jsr rst28

;068f  af        xor     a		; A := #00
;0690  32134e    ld      (#4e13),a	; current board level = 0
			stz |level
;0693  3a6f4e    ld      a,(#4e6f)	; load number of lives to start
			lda |no_lives
;0696  32144e    ld      (#4e14),a	; set number of lives
			sta |num_lives
;0699  32154e    ld      (#4e15),a	; set number of lives displayed
			sta |displayed_lives
;069c  ef        rst     #28		; set task #1A, parameter #00 - draws remaining lives at bottom of screen
;069d  1a 00
			lda #$001a
			jsr rst28

;069f  f7        rst     #30		; set timed task to increment main routine 2, subroutine # (#4E03)
;06a0  57 01 00				; task data: timer=#57, task=01, parameter=0.
			lda #$0157
			ldy #$0000
			jsr rst30

;------------------------------------------------------------------------------
; also arrive here from #0246.   This is timed task #01
ttask1 mx %00
;06a3  21 03 4E	ld	hl,#4E03	; load HL with main routine 2, subroutine #
;06a6  34        inc     (hl)		; increase
			inc |mainroutine2
;06a7  c9        ret     		; return
			rts

;------------------------------------------------------------------------------

	;; draw lives displayed onto the screen
:drawlives
;06a8  21154e    ld      hl,#4e15	; load HL with lives displayed on screen loc
;06ab  35        dec     (hl)		; decrement
		dec |displayed_lives
;06ac  cd6a2b    call    #2b6a		; draw remaining lives at bottom of screen 
		jsr task_drawLives
;06af  af        xor     a		; A := #00
;06b0  32034e    ld      (#4e03),a	; clear main routine 2, subroutine #
		stz |mainroutine2
;06b3  32024e    ld      (#4e02),a	; clear main routine 1, subroutine #
		stz |mainroutine1
;06b6  32044e    ld      (#4e04),a	; clear level state subroutine #
		stz |levelstate
;06b9  21004e    ld      hl,#4e00	; load HL with game mode address
;06bc  34        inc     (hl)		; inc game mode.  game mode is now 3 = game is just now starting
		inc |mainstate
;06bd  c9        ret     		; return
		rts

;------------------------------------------------------------------------------
; arrive here from #03CB or from #057C, when someone or demo is playing
gameplay_mode mx %00
;06BE: 3A 04 4E      ld   a,(#4E04)	; load A with level state
;06C1: E7            rst  #20		; jump based on A
			lda |levelstate
			asl
			tax
			jmp (:table,x)
:rts
			rts
:table
			da game_init	; #0879		; set up game initialization
			da game_setup   ; #0899		; set up tasks for beginning of game
			da :rts 	; #000C		; returns immediately
			da game_playing ; #08CD		; demo mode or player is playing
			da player_die   ; #090D		; when player has collided with hostile ghost (died)
			da :rts 	; #000C		; returns immediately
			da gameover_check ; #0940	; check for game over, do things if true
			da :rts 	; #000C		; returns immediately
			da end_demo     ; #0972		; end of demo mode when ms pac dies in demo.  clears a bunch of memories.
			da ready_go     ; #0988		; sets a bunch of tasks and displays "ready" or "game over"
			da :rts 	; #000C		; returns immediately
			da start_demo   ; #09D2		; begin start of maze demo after marquee
			da clear_sounds ; #09D8		; clears sounds and sets a small delay.  run at end of each level
			da :rts 	; #000C		; returns immediately
			da flash_screen ; #09E8		; flash screen
			da :rts 	; #000C		; returns immediately
			da flash_off	; #09FE		; flash screen
			da :rts 	; #000C		; returns immediately
			da flash_screen ; #0A02		; flash screen
			da :rts 	; #000C		; returns immediately
			da flash_off    ; #0A04		; flash screen
			da :rts 	; #000C		; returns immediately
			da flash_screen ; #0A06		; flash screen
			da :rts 	; #000C		; returns immediately
			da flash_off    ; #0A08		; flash screen
			da :rts 	; #000C		; returns immediately
			da flash_screen ; #0A0A		; flash screen
			da :rts 	; #000C		; returns immediately
			da flash_off    ; #0A0C		; flash screen
			da :rts 	; #000C		; returns immediately
			da after_flash	; #0A0E		; set a bunch of tasks
			da :rts 	; #000C		; returns immediately
			da end_level	; #0A2C		; clears all sounds and runs intermissions when needed
			da :rts 	; #000C		; returns immediately
			da next_board   ; #0A7C		; clears sounds, increases level, increases difficulty if needed, resets pill maps
			da ready_go     ; #0AA0		; get game ready to play and set this sub back to #03
			da :rts 	; #000C		; returns immediately
			da start_demo	; #0AA3		; sets sub # back to #03

;------------------------------------------------------------------------------
; arrive here from #000D
; sets up game difficulty
task_setDifficulty mx %00
;070e  78        ld      a,b		; load A with parameter from task
;070f  a7        and     a		; == #00 ?
;0710  2004      jr      nz,#0716        ; no, skip ahead
			bne :passed_in		; difficulty arg in a
;0712  2a0a4e    ld      hl,(#4e0a)	; else load HL with difficulty setting pointer.  EG #0068
;0715  7e        ld      a,(hl)		; load A with difficulty, EG #00
			lda |pDifficulty
			and #$FF
:passed_in
;0716  dd219607  ld      ix,#0796	; load IX with difficulty table start
;071a  47        ld      b,a
;071b  87        add     a,a
;071c  87        add     a,a
;071d  80        add     a,b
;071e  80        add     a,b		; A is now 6 times what it was
;071f  5f        ld      e,a
;0720  1600      ld      d,#00
;0722  dd19      add     ix,de		; adjust IX based on current difficulty
			; A * 6, then into X
			asl
			pha
			asl
			adc 1,s
			sta 1,s
			ply

;0724  dd7e00    ld      a,(ix+#00)	; load A with first value from table
			lda |:difficulty_table,y
			and #$ff

;0727  87        add     a,a 	    ; a*=2
;0728  47        ld      b,a 		; b = 2a
;0729  87        add     a,a 		; a*=2
;072a  87        add     a,a 		; a*=2
;072b  4f        ld      c,a 		; c = 8a
;072c  87        add     a,a 		; a*=2
;072d  87        add     a,a 		; a*=2
;072e  81        add     a,c 		; a = (32*a) + 8a
;072f  80        add     a,b 		; +2a
									; a=a*42
			asl
			pha ; 2a
			asl
			asl
			pha ; 8a
			asl
			asl
			adc 1,s  ; (a*32 + 8*a)
			sta 1,s
			pla
			adc 1,s  ; (a*40 + 2*a)
			sta 1,s
			pla
;0730  5f        ld      e,a
;0731  1600      ld      d,#00
;0733  210f33    ld      hl,#330f	; load HL with start of data table - speeds of ghosts and pacman
;0736  19        add     hl,de		; add offset computed above
			adc #difficulty_data
			tax
;0737  cd1408    call    #0814		; copy data into #4d46 through #4d94
			jsr copy_difficulty_data

;073a  dd7e01    ld      a,(ix+#01)	; load A with second value from table
			lda |:difficulty_table+1,y
			and #$FF
;073d  32b04d    ld      (#4db0),a	; store.  appears to be unused
			sta |difficulty_table_entry_1

;0740  dd7e02    ld      a,(ix+#02)	; load A with third value from table
			lda |:difficulty_table+2,y
			and #$FF
;0743  47        ld      b,a		; copy to B
;0744  87        add     a,a		; A := A*2
;0745  80        add     a,b		; A is now 3 times value in table
;0746  5f        ld      e,a		; store in E
;0747  1600      ld      d,#00		; D := #00
;0749  214308    ld      hl,#0843	; load HL with hard/easy data table check 
;074c  19        add     hl,de		; add offset computed above
			pha
			asl
			adc 1,s
			sta 1,s
			pla         ; a*3
			adc #ooh_table
;074d  cd3a08    call    #083a		; copy difficulty info to #4DB8 to #4DBA
			jsr copy_ooh_data
;0750  dd7e03    ld      a,(ix+#03)	; load A with fourth value from table
			lda |:difficulty_table+3,y
			and #$FF
;0753  87        add     a,a		; A := A * 2
			asl
;0754  5f        ld      e,a		; copy to E
;0755  1600      ld      d,#00		; D := #00
;0757  fd214f08  ld      iy,#084f	; load IY with data table start
;075b  fd19      add     iy,de		; add offset
			tax
;075d  fd6e00    ld      l,(iy+#00)	; 
;0760  fd6601    ld      h,(iy+#01)	; load HL with table data
			lda |pill_difficulty_table,x
;0763  22bb4d    ld      (#4dbb),hl	; store into remainder of pills when first diff. flag is set
			sep #$20
			sta |pill_remain0
			xba
			sta |pill_remain1
			rep #$30

;0766  dd7e04    ld      a,(ix+#04)	; load A with fifth value from table
			lda |:difficulty_table+4,y
			and #$FF
;0769  87        add     a,a		; A := A * 2
;076a  5f        ld      e,a		; store into E
;076b  1600      ld      d,#00		; clear D
;076d  fd216108  ld      iy,#0861	; load IY with start of table that controls time that ghosts stay blue
;0771  fd19      add     iy,de		; add offset
;0773  fd6e00    ld      l,(iy+#00)	; 
;0776  fd6601    ld      h,(iy+#01)	; load HL with data from table
			asl
			tax
			lda |blue_diff_table,x
;0779  22bd4d    ld      (#4dbd),hl	; store into time the ghosts stay blue when pacman eats a power pill
			sta |stay_blue_time

;077c  dd7e05    ld      a,(ix+#05)	; load A with sixth value from table
			lda |:difficulty_table+5,y
			and #$FF
;077f  87        add     a,a		; A := A * 2
;0780  5f        ld      e,a		; copy to E
;0781  1600      ld      d,#00		; clear D
;0783  fd217308  ld      iy,#0873	; load IY with start of difficulty table - number of units before ghosts leaves home
;0787  fd19      add     iy,de		; add offset
;0789  fd6e00    ld      l,(iy+#00)
;078c  fd6601    ld      h,(iy+#01)	; load HL with data from table
			asl
			tax
			lda |ght_table,x
;078f  22954d    ld      (#4d95),hl	; store
			sta |home_counter1
			stz |home_counter2
;0792  cdea2b    call    #2bea		; draw fruit at bottom of screen
			jsr task_drawFruit
;0795  c9        ret			; return (to # 238D ?) 
			rts
;	-- difficulty related table
;	each entry is 6 bytes
;	byte 0: (0..6) speed bit patterns and orientation changes (table at #330F)
;	byte 1: (00, 01, 02) stored at #4DB0 - seems to be unused
;	byte 2: (0..3) ghost counter table to exit home (table at #0843)
;	byte 3: (0..7) remaining number of pills to set difficulty flags (table at #084F)
;	byte 4: (0..8) ghost time to stay blue when pacman eats the big pill (table at #0861)
;	byte 5: (0..2) number of units before a ghost goes out of home (table at #0873)

;0796
:difficulty_table
	db $03,$01,$01,$00,$02,$00 ; 0796
	db $04,$01,$02,$01,$03,$00 ; 079c
	db $04,$01,$03,$02,$04,$01 ; 07a2
	db $04,$02,$03,$02,$05,$01 ; 07a8
	db $05,$00,$03,$02,$06,$02 ; 07ae
	db $05,$01,$03,$03,$03,$02 ; 07b4
	db $05,$02,$03,$03,$06,$02 ; 07ba
	db $05,$02,$03,$03,$06,$02 ; 07c0
	db $05,$00,$03,$04,$07,$02 ; 07c6
	db $05,$01,$03,$04,$03,$02 ; 07cc
	db $05,$02,$03,$04,$06,$02 ; 07d2
	db $05,$02,$03,$05,$07,$02 ; 07d8
	db $05,$00,$03,$05,$07,$02 ; 07de
	db $05,$02,$03,$05,$05,$02 ; 07e4
	db $05,$01,$03,$06,$07,$02 ; 07ea
	db $05,$02,$03,$06,$07,$02 ; 07f0
	db $05,$02,$03,$06,$08,$02 ; 07f6
	db $05,$02,$03,$06,$07,$02 ; 07fc
	db $05,$02,$03,$07,$08,$02 ; 0802
	db $05,$02,$03,$07,$08,$02 ; 0808
	db $06,$02,$03,$07,$08,$02 ; 080e


; called from #0737
; copies difficulty-related data into #4d46 through #4d94
; includes 4d58 which is blinky's normal speed
; include 4d86 which controls timing of reversals

copy_difficulty_data mx %00
			phy
;0814  11464d    ld      de,#4d46	; set destination
			ldy #speedbit_normal
;0817  011c00    ld      bc,#001c	; set counter
			lda #28-1
;081a  edb0      ldir    		; copy
			mvn ^copy_difficulty_data,^copy_difficulty_data

;081c  010c00    ld      bc,#000c	; set counter
;081f  a7        and     a		; clear carry flag
;0820  ed42      sbc     hl,bc		; subtract from source
;0822  edb0      ldir    		; copy
			sec
			txa
			sbc #12
			tax
			lda #12-1
			mvn ^copy_difficulty_data,^copy_difficulty_data

;0824  010c00    ld      bc,#000c	; set counter
;0827  a7        and     a		; clear carry flag
;0828  ed42      sbc     hl,bc		; subtract from source
;082a  edb0      ldir    		; copy
			sec
			txa
			sbc #12
			tax
			lda #12-1
			mvn ^copy_difficulty_data,^copy_difficulty_data

;082c  010c00    ld      bc,#000c	; set counter
;082f  a7        and     a		; clear carry flag
;0830  ed42      sbc     hl,bc		; subtract source
;0832  edb0      ldir    		; copy

			sec
			txa
			sbc #12
			tax
			lda #12-1
			mvn ^copy_difficulty_data,^copy_difficulty_data

;0834  010e00    ld      bc,#000e	; set counter
;0837  edb0      ldir    		; copy
			lda #14-1
			mvn ^copy_difficulty_data,^copy_difficulty_data

;0839  c9        ret     		; return
			ply
			rts

;------------------------------------------------------------------------------
; called from #0749
copy_ooh_data mx %00
;083a  11b84d    ld      de,#4db8	; load destination with #4DB8
;083d  010300    ld      bc,#0003	; set bytes to copy at 3
;0840  edb0      ldir    		; copy
;0842  c9        ret     		; return
			sep #$20
			lda |0,x
			sta |pink_home_limit
			lda |1,x
			sta |blue_home_limit
			lda |2,x
			sta |orange_home_limit
			rep #$30
			rts

;------------------------------------------------------------------------------
;-- table related to difficulty - each entry is 3 bytes
; b0: when counter at 4E0F reaches this value, pink ghost goes out of home
; b1: when counter at 4E10 reaches this value, blue ghost goes out of home
; b2: when counter at 4E11 reaches this value, orange ghost goes out of home
; out of home table
; these don't seem to be used in ms-pac at all.
;0843
ooh_table
	db $14,$1e,$46
	db $00,$1e,$3c
	db $00,$00,$00
	db $32,$00,$00,$00

	; hard hack: HACK6
	; 0843  0f 14 37 04  18 34  02 06 28   00 04 08
	;

;------------------------------------------------------------------------------
; -- difficulty table --
; each entry is 2 bytes
; b1: remaining number of pills when first difficulty flag is set (cruise elroy 1)
; b2: remaining number of pills when second difficulty flag is set (cruise elroy 2)
;084f
pill_difficulty_table
	db $14,$0a
	db $1e,$0f
	db $28,$14
	db $32,$19
	db $3c,$1e
	db $50,$28
	db $64,$32
	db $78,$3c
	db $8c,$46

;------------------------------------------------------------------------------
; difficulty table - Time the ghosts stay blue when pacman eats a big pill
;		-- do not use with l set up at #076D 
;0861
blue_diff_table
	db $c0,$03		; 03c0 (960) 8 seconds (not used)
	db $48,$03		; 0348 (840) 7 seconds (not used)
	db $d0,$02		; 02d0 (720) 6 seconds
	db $58,$02		; 0258 (600) 5 seconds
	db $e0,$01		; 01e0 (480) 4 seconds
	db $68,$01		; 0168 (360) 3 seconds
	db $f0,$00		; 00f0 (240) 2 seconds
	db $78,$00		; 0078 (120) 1 second
	db $01,$00		; 0001 (1)   0 seconds

;------------------------------------------------------------------------------
; difficulty table - number of units before ghosts leaves home
; set up at #0783
;0873
ght_table
	db $f0,$00		; 00f0 (240) 2 seconds
	db $f0,$00		; 00f0 (240) 2 seconds
	db $b4,$00		; 00b4 (180) 1.5 seconds


;------------------------------------------------------------------------------
;$$JGA HORRIBLE TEMP RNG
;$$JGA FIXME
RANDOM mx %00
		lda <dpJiffy
		xba
		eor <dpJiffy
		rts
;------------------------------------------------------------------------------

JasonTestStuff

		jsr ColorMaze		; fill, based on color# the maze

		jsr DrawMaze		; draw the maze pacman style

		jsr ResetPills		; be sure to mark all pills as active

		jsr DrawPills		; Draw out the player pills, int tile RAM

		jsr DrawPowerPills  ; Draw out the power pills for the current maze

		jsr BlitColor		; Based on Color RAM, fix up Vicky CLUTs
		jsr BlitMap			; Copy the map data from tile_ram, to the Vicky RAM

		lda #2*60
]delay
		jsr WaitVBL
		dec
		bpl ]delay

		sep #$20
		inc |level
		rep #$30

		jmp ]next

end 	bra     end


;------------------------------------------------------------------------------

		put bitmap.s

;------------------------------------------------------------------------------
;
; Jiffy Timer Installer, Enabler
; Depends on the Kernel Interrupt Handler
;
InstallJiffy mx %00

; Fuck over the vector

		sei

		lda #$4C	; JMP
		sta |VEC_INT00_SOF

		lda #:JiffyTimer
		sta |VEC_INT00_SOF+1

; Enable the SOF interrupt

		lda #FNX0_INT00_SOF
		trb |INT_MASK_REG0

		cli
		rts

:JiffyTimer
;		pha					   ; 4
;		lda >{MyDP+dpJiffy}    ; 6
;		inc					   ; 2
;		sta >{MyDP+dpJiffy}    ; 6
;		pla					   ; 5
;		rtl

		php					   ; 3
		phb 				   ; 3
		phk 				   ; 3
		plb 				   ; 4
		rep #$38			   ; 3
		inc |{MyDP+dpJiffy}    ; 6

jsr38		nop
		nop
		nop

		plb 				   ; 4
		plp					   ; 4
		rtl


;------------------------------------------------------------------------------
; WaitVBL
; Preserve all registers, and processor status
;
WaitVBL mx %00
		php
		pha
		lda <dpJiffy
]lp
		cmp <dpJiffy
		beq ]lp
		pla
		plp
		rts


;------------------------------------------------------------------------------
;
; JBSI

HEXIN EQU 0 ;2 bytes
DECWORK EQU 2 ;2 bytes
DECOUT EQU 4 ;2 bytes

* On Entry:
* Word to convert at HEXIN
* e=0, m=0, x=0
* DPage=0
* On Exit:
* A=Low 4 decimal digits
* X,Y,DB,DPage preserved
* e=0, m=0, x=0, Decimal flag cleared
* DECOUT=Highest decimal digit
* HEXIN & DECWORK altered
HEXDEC
	SEP #9    		; set BCD, and Set c=1, SED + SEC
	TDC    			; load A with Zero
	ROL HEXIN
]LOOP
	STA DECWORK
	ADC DECWORK
	ROL DECOUT
	ASL HEXIN
	BNE ]LOOP
	CLD
	RTS

;------------------------------------------------------------------------------
;
;	Title Page Stuff
;
		put title.s


;------------------------------------------------------------------------------
; Configure the FMX for Ms Pacman
;
; 800x600 mode - Game is 448x576  (600-576 = 24)
;
; Border 16 horizontal, with 12 tall on the top and bottom
;
; Tile Map 0 - 64x64
; Also uses Sprites
;
InitMsPacVideo mx %00

		jsr WaitVBL

		pea >MASTER_CTRL_REG_L
		plb
		plb

		lda #]VIDEO_MODE
		sta |MASTER_CTRL_REG_L

		sep #$10

;---------------------------------------------------------
		; Initialize the border

		do DEBUG
		ldx #Border_Ctrl_Enable
		else
		ldx #0 ; disable border
		fin
		stx |BORDER_CTRL_REG			; Enable the Border

		stz |BORDER_COLOR_B				; Black
		stz |BORDER_COLOR_R

		ldy #$FF		   	; Red for debug
		sty |BORDER_COLOR_R

		ldx #16
		stx |BORDER_X_SIZE
		ldy #12
		sty |BORDER_Y_SIZE

;---------------------------------------------------------
; Initalize Bitmaps
		do 1 ;;DEBUG
		ldx #0  ; need to get SPRITE_DEPTH set
		else
		ldx #BM_Enable
		fin
		stx |BM0_CONTROL_REG
		ldx #0
		stx |BM1_CONTROL_REG

		lda #VICKY_BITMAP0
		sta |BM0_START_ADDY_L
		sta |BM1_START_ADDY_L
		ldx #^VICKY_BITMAP0
		stx |BM0_START_ADDY_H
		stx |BM1_START_ADDY_H

		stz |BM0_X_OFFSET   ; + BM0_Y_OFFSET
		stz |BM0_RESERVED_6 ; + 7
		stz |BM1_X_OFFSET   ; + BM0_Y_OFFSET
		stz |BM1_RESERVED_6 ; + 7

;---------------------------------------------------------

		; Set the Background Color
		stz |BACKGROUND_COLOR_B  	 ; Black
		stz |BACKGROUND_COLOR_G

;---------------------------------------------------------
;
; Default the first 4 colors of LUT0-LUT7

		rep #$31

		ldx #0
]loop
		; Black - Tile Color
		stz |GRPH_LUT0_PTR,x
		stz |GRPH_LUT0_PTR+2,x 
		; Black - sprite Color
		stz |GRPH_LUT0_PTR+16,x
		stz |GRPH_LUT0_PTR+18,x 


		; Dark Grey - Tile Color
		lda #$5050
		sta |GRPH_LUT0_PTR+4,x 
		sta |GRPH_LUT0_PTR+6,x 
		; Dark Grey - Sprite Color
		sta |GRPH_LUT0_PTR+20,x 
		sta |GRPH_LUT0_PTR+22,x 

		; Dark Grey - Tile Color
		lda #$A0A0
		sta |GRPH_LUT0_PTR+8,x 
		sta |GRPH_LUT0_PTR+10,x 
		; Dark Grey - Sprite Color
		sta |GRPH_LUT0_PTR+24,x 
		sta |GRPH_LUT0_PTR+26,x 


		; White - Tile Color
		lda #$FFFF
		sta |GRPH_LUT0_PTR+12,x 
		sta |GRPH_LUT0_PTR+14,x 
		; White - Sprite Color
		sta |GRPH_LUT0_PTR+28,x 
		sta |GRPH_LUT0_PTR+30,x 

		txa
		adc #$400 				 ;next LUT
		tax
		cpx #$2000
		bcc ]loop

		sep #$10

;---------------------------------------------------------
;
;  Initialize Tile Map
;

		; While Tile planes are active
		ldx #TILE_Enable
		ldy #0
		stx |TL0_CONTROL_REG  	; Tile Plane 0 Enable
		sty |TL1_CONTROL_REG	; Tile Plane 1 Disable
		sty |TL2_CONTROL_REG	; Tile Plane 2 Disable
		sty |TL3_CONTROL_REG	; Tile Plane 3 Disable

		; Map Data Size
		lda #64
		sta |TL0_TOTAL_X_SIZE_L
		sta |TL1_TOTAL_X_SIZE_L
		sta |TL0_TOTAL_Y_SIZE_L
		sta |TL1_TOTAL_Y_SIZE_L

		; Tile Set Address
		lda #VICKY_MAP_TILES
		sta |TILESET0_ADDY_L
		sta |TILESET1_ADDY_L
		ldx #^VICKY_MAP_TILES
		stx |TILESET0_ADDY_H
		stx |TILESET1_ADDY_H

		; Set TileMap 0 Name Data Address
		lda #VICKY_MAP0
		sta |TL0_START_ADDY_L
		ldx #^VICKY_MAP0
		stx |TL0_START_ADDY_H

		; Set TileMap 1 Name Data Address
		lda #VICKY_MAP1
		sta |TL1_START_ADDY_L
		ldx #^VICKY_MAP1
		stx |TL1_START_ADDY_H


		; Map display position
		stz |TL0_WINDOW_X_POS_L
		stz |TL1_WINDOW_X_POS_L
		lda #4
		sta |TL0_WINDOW_Y_POS_L
		sta |TL1_WINDOW_Y_POS_L


;---------------------------------------------------
		; Quick Disable All the Sprites

		rep #$31	; mxc=000

		ldx #0
		txa
]lp
		stz |SP00_CONTROL_REG,x
		adc #8
		tax
		cpx #8*64
		bcc ]lp

;---------------------------------------------------

		; Clear Tile Catalog 0  - used for the map tiles
		pea #^VICKY_MAP_TILES
		pea #VICKY_MAP_TILES

		pea #^TILE_CLEAR_SIZE
		pea #TILE_CLEAR_SIZE

		jsr vmemset0

		; Clear Tile Catalog 1  - used for the sprites!
		pea #^VICKY_SPRITE_TILES
		pea #VICKY_SPRITE_TILES

		pea #^TILE_CLEAR_SIZE
		pea #TILE_CLEAR_SIZE

		jsr vmemset0

		; Clear Tile Map 0
		pea #^VICKY_MAP0
		pea #VICKY_MAP0

		pea #^MAP_CLEAR_SIZE
		pea #MAP_CLEAR_SIZE
		
		jsr vmemset0

		; Clear Tile Map 1
		pea #^VICKY_MAP1
		pea #VICKY_MAP1

		pea #^MAP_CLEAR_SIZE
		pea #MAP_CLEAR_SIZE
		
		jsr vmemset0


		rts


;------------------------------------------------------------------------------
; From Previous expermimentation, I know that src and dst addresses
; of VRAM to VRAM DMA on this machine have to be 1MB apart in memory
; my best guess, is separate chips?
;
; Generate the Flipped Sprite Banks
GenerateSpriteFlips mx %00

		jsr WaitVBL

		; change B, so it points at the hardware registers
		pea >MASTER_CTRL_REG_L
		plb
		plb

		; Disable Video (so we can DMA)
		lda #Mstr_Ctrl_Disable_Vid
		; this will be annoying until the emulator is fixed
		;tsb |MASTER_CTRL_REG_L

:src = temp0
:dst = temp1
:len = temp2

		lda #VICKY_SPRITE_TILES
		ldx #^VICKY_SPRITE_TILES
		sta <:src
		stx <:src+2

		lda #VICKY_SPRITE_TILES3+ONEMB
		ldx #^{VICKY_SPRITE_TILES3+ONEMB}
		sta <:dst
		stx <:dst+2

		sep #$10
		clc
		ldy #64
]loop
		jsr HFlipSprite

		lda <:src
		adc #32*32
		sta <:src
		lda <:dst
		adc #32*32
		sta <:dst

		dey
		bne ]loop

		rep #$30

		jsr WaitVBL

; Let's DMA the new tiles back to where they need to live

		lda #VICKY_SPRITE_TILES3+ONEMB
		ldx #^{VICKY_SPRITE_TILES3+ONEMB}
		sta <:src
		stx <:src+2

		lda #VICKY_SPRITE_TILES3
		ldx #^VICKY_SPRITE_TILES3
		sta <:dst
		stx <:dst+2

		; 64K Bytes
		stz <:len
		lda #1
		sta <:len+2

		jsr V2V_DMA

		jsr WaitVBL

; We need the VFLips and HVFLips
; VFLIPS ----------------------------------------------------------------------
		lda #VICKY_SPRITE_TILES
		ldx #^VICKY_SPRITE_TILES
		sta <:src
		stx <:src+2

		lda #VICKY_SPRITE_TILES2+ONEMB
		ldx #^{VICKY_SPRITE_TILES2+ONEMB}
		sta <:dst
		stx <:dst+2

		sep #$10
		clc
		ldy #64
]loop
		jsr VFlipSprite

		lda <:src
		adc #32*32
		sta <:src

		lda <:dst
		adc #32*32
		sta <:dst

		dey
		bne ]loop

		rep #$30

		jsr WaitVBL

; Let's DMA the new tiles back to where they need to live

		lda #VICKY_SPRITE_TILES2+ONEMB
		ldx #^{VICKY_SPRITE_TILES2+ONEMB}
		sta <:src
		stx <:src+2

		lda #VICKY_SPRITE_TILES2
		ldx #^VICKY_SPRITE_TILES2
		sta <:dst
		stx <:dst+2

		; 64K Bytes
		stz <:len
		lda #1
		sta <:len+2

		jsr V2V_DMA

		jsr WaitVBL

; HVFLIPS ---------------------------------------------------------------------

		lda #VICKY_SPRITE_TILES2
		ldx #^VICKY_SPRITE_TILES2
		sta <:src
		stx <:src+2

		lda #VICKY_SPRITE_TILES4+ONEMB
		ldx #^{VICKY_SPRITE_TILES4+ONEMB}
		sta <:dst
		stx <:dst+2

		sep #$10
		clc
		ldy #64
]loop
		jsr HFlipSprite

		lda <:src
		adc #32*32
		sta <:src
		lda <:dst
		adc #32*32
		sta <:dst

		dey
		bne ]loop

		rep #$30

		jsr WaitVBL

; Let's DMA the new tiles back to where they need to live

		lda #VICKY_SPRITE_TILES4+ONEMB
		ldx #^{VICKY_SPRITE_TILES4+ONEMB}
		sta <:src
		stx <:src+2

		lda #VICKY_SPRITE_TILES4
		ldx #^VICKY_SPRITE_TILES4
		sta <:dst
		stx <:dst+2

		; 64K Bytes
		stz <:len
		lda #1
		sta <:len+2

		jsr V2V_DMA

;------------------------------------------------------------------------------

		jsr WaitVBL

		; Enable Video
		lda #Mstr_Ctrl_Disable_Vid
		trb |MASTER_CTRL_REG_L

		phk
		plb

		rts

;------------------------------------------------------------------------------
; VFlipSprite
VFlipSprite mx %01
:src = temp0
:dst = temp1
:len = temp2

		phy
		pei <:src+2
		pei <:src
		pei <:dst+2
		pei <:dst

		lda #32
		sta <:len
		stz <:len+2

		clc
		lda <:src
		adc #{32*32}-32
		sta <:src

		ldy #32
]loop
		jsr V2V_DMA

		sec
		lda <:src
		sbc #32
		sta <:src

		clc
		lda <:dst
		adc #32
		sta <:dst
		
		dey
		bne ]loop

		pla
		sta <:dst
		pla
		sta <:dst+2
		pla
		sta <:src
		pla
		sta <:src+2

		ply
		rts


;------------------------------------------------------------------------------
; HFlipSprite
HFlipSprite mx %01

; Well, this DMA version isn't working, I think it's trashing memory

; CPU version, when we read from VRAM, seems to be clearing VRAM

; I'll have to change the Sprite Converion to dump the sprites into
; regular SRAM, then I'll be able to flip them, and eventually
; copy them into the VRAM

; If the hardware just worked, this wouldn't be so frustrating

; If the assembler worked right, this wouldn't be so frustrating


:src = temp0
:dst = temp1

:pSrc = temp2
:pDst = temp3

		phy

		lda <:src
		sta <:pSrc
		lda <:src+2
		sta <:pSrc+2
		lda <:dst
		adc #31
		sta <:pDst
		lda <:dst+2
		sta <:pDst+2

		ldy #32
]loop
		jsr :BlitVerticalLine
		inc <:pSrc
		dec <:pDst
		dey
		bne ]loop

		ply

		rts

		do 0

; Let's try using the CPU
; this isn't working because CPU can't read from the VRAM
; well, we'll do 1 test with video disabled
; it seems like reading from VRAM, writes a 0, based on what we see
; on the screen.

:BlitVerticalLine

		phy
		phb
		php

		rep #$31
:pSource equ temp4
:pDest   equ temp5

		lda <:pSrc
		sta <:pSource
		lda <:pSrc+2
		adc #^VRAM
		sta <:pSource+2
		lda <:pDst
		sta <:pDest
		lda <:pDst+2
		adc #^VRAM
		sta <:pDest+2

		sep #$20
]y_offset = 0
		lup 32
		ldy #]y_offset
		;lda [:pSource],y
		;sta [:pDest],y

		db $B7,:pSource
		db $97,:pDest

]y_offset = ]y_offset+32
		--^

		plp
		plb
		ply

		rts

		else
:BlitVerticalLine

		ldx #VDMA_CTRL_Enable+VDMA_CTRL_1D_2D
		stx |VDMA_CONTROL_REG

		; Source
		lda <:pSrc
		sta |VDMA_SRC_ADDY_L
		ldx <:pSrc+2
		stx |VDMA_SRC_ADDY_H

	    ; Dest
		lda <:pDst
		sta |VDMA_DST_ADDY_L
		ldx <:pDst+2
		stx |VDMA_DST_ADDY_H

		lda #1
		sta |VDMA_X_SIZE_L
		lda #32
		sta |VDMA_Y_SIZE_L
		sta |VDMA_SRC_STRIDE_L
		sta |VDMA_DST_STRIDE_L

		lda #VDMA_CTRL_Start_TRF
		tsb |VDMA_CONTROL_REG
		nop 				; the example code has this
		nop
		nop
]wait_dma_loop
		ldx |VDMA_STATUS_REG
		bmi ]wait_dma_loop
		nop
		stz |VDMA_CONTROL_REG
		rts
		fin

;------------------------------------------------------------------------------
;
V2V_DMA mx %00

:src = temp0
:dst = temp1
:len = temp2

		; save P, and B
		phb
		php

		; change B, so it points at the hardware registers
		pea >MASTER_CTRL_REG_L
		plb
		plb

		sep #$10  ; mx=01

		ldx #VDMA_CTRL_Enable
		stx |VDMA_CONTROL_REG

		ldx #0
		stx |VDMA_BYTE_2_WRITE

		; Source Address
		lda <:src
		sta |VDMA_SRC_ADDY_L
		ldx <:src+2
		stx |VDMA_SRC_ADDY_H

		; Dest Address
		lda <:dst
		sta |VDMA_DST_ADDY_L
		ldx <:dst+2
		stx |VDMA_DST_ADDY_H

		; Size
		lda <:len
		sta |VDMA_SIZE_L
		lda <:len+2
		sta |VDMA_SIZE_H

		stz |VDMA_SRC_STRIDE_L
		stz |VDMA_DST_STRIDE_L

		lda #VDMA_CTRL_Start_TRF
		TSB |VDMA_CONTROL_REG
		NOP
		NOP
		NOP

]wait_done
		ldx |VDMA_STATUS_REG
		bmi ]wait_done
		NOP
		stz |VDMA_CONTROL_REG

		plp
		plb
		rts

;------------------------------------------------------------------------------
; Convert the Sprites and Display them!

TestSprites mx %00

LEFT = 400
TOP  = 64

:pSprite = temp0
:xPos    = temp1
:yPos    = temp1+2

		pea >SP00_CONTROL_REG
		plb
		plb

		lda #LEFT
		sta <:xPos
		lda #TOP
		sta <:yPos


		; Setup a 16x16 Sprite Tile Grid
		;
		; Sprite Tile 0 Address
		; 32x32
		lda #VICKY_SPRITE_TILES
		sta <:pSprite
		lda #^VICKY_SPRITE_TILES
		sta <:pSprite+2

		clc

		ldx #0			; index over to the first sprite
]lp
		lda #SPRITE_Enable  		  ; Enable the sprite
		sta |SP00_CONTROL_REG,x

		lda <:pSprite   			  ; point at a tile in memory
		sta |SP00_ADDY_PTR_L,x

		lda <:pSprite+1
		sta |SP00_ADDY_PTR_L+1,x

		lda <:xPos
		sta |SP00_X_POS_L,x 			  ; Set X Position

		lda <:yPos
		sta |SP00_Y_POS_L,x            ; Set Y Position

		lda <:pSprite
		adc #1024					  ; increment sprite pointer
		sta <:pSprite

		lda <:xPos  				  ; increment x position
		adc #48
		cmp #LEFT+{8*48}
		bcc :skip_y

		lda <:yPos  		  		  ; increment y position
		adc #47		; c=1
		sta <:yPos

		; c=0

		lda #LEFT
:skip_y
		sta <:xPos

		txa
		adc #8
		tax
		cpx #8*64
		bcc ]lp

; Sprites Initialized

;---------------------------------------------------------
; Convert MsPacman Tile data into Vicky Format!
;
; 16x16 Sprite Rom over to 32x32 Sprite RAM
;
; decompress sprite_rom, to Tile RAM
;
:pTile   = temp0
:pPixels = temp1
:temp    = temp2
:loop_counter = temp3

		; Initialize Tile Address
		lda #VRAM+VICKY_SPRITE_TILES
		sta <:pTile
		lda #^{VRAM+VICKY_SPRITE_TILES}
		sta <:pTile+2
		sta <:pPixels+2

		ldx #0    ; start at offset zero in the sprite ROM

;
; 5(0,0)  1(16,0)
; 6(0,8)  2(16,8)
; 7(0,16) 3(16,16)
; 4(0,24) 0(16,24)

		clc

		lda #64
]tile_loop
		pha


; Decode Section 0

		lda <:pTile
		adc #{32*24}+30
		sta <:pPixels

		jsr :decode_section

; Decode Section 1

		lda <:pTile
		adc #30
		sta <:pPixels

		jsr :decode_section

; Decode Section 2

		lda <:pTile
		adc #{32*8}+30
		sta <:pPixels

		jsr :decode_section

; Decode Section 3

		lda <:pTile
		adc #{32*16}+30
		sta <:pPixels

		jsr :decode_section

; Decode Section 4

		lda <:pTile
		adc #{32*24}+14
		sta <:pPixels

		jsr :decode_section

; Decode Section 5

		lda <:pTile
		adc #14
		sta <:pPixels

		jsr :decode_section

; Decode Section 6

		lda <:pTile
		adc #{8*32}+14
		sta <:pPixels

		jsr :decode_section

; Decode Section 7

		lda <:pTile
		adc #{16*32}+14
		sta <:pPixels

		jsr :decode_section

		lda <:pTile				; Goto next tile
		adc #1024
		sta <:pTile

		pla
		dec						; loop 64 times
		bne ]tile_loop

		phk
		plb

		rts

;------------------------------------------------

:decode_section

		lda #8
		sta <:loop_counter
]lp
		lda >sprite_rom,x
		inx

		jsr :decode4pixels

		dec <:pPixels
		dec <:pPixels

		dec <:loop_counter

		bne ]lp

		clc

		rts


:decode4pixels
; input pPixels in :pPixels
; A contains 4 pixels in MsPacman Arcade ROM format
		pha

		and #1
		sta <:temp
		lda 1,s
		lsr
		lsr
		lsr
		and #2
		ora <:temp
		sta <:temp
		xba
		ora <:temp

		; Massage the pixel from color index 0-3 up to index 4-7
		; but if it's 0, we need to leave it alone
		beq :is_zero1
		ora #$0404
:is_zero1

		ldy #6*32
		sta [:pPixels],y  ; top half of pixel #4
		ldy #7*32 
		sta [:pPixels],y  ; bottom half of pixel #

		lda 1,s
		lsr
		and #1
		sta <:temp
		lda 1,s
		lsr
		lsr
		lsr
		lsr
		and #2
		ora <:temp
		sta <:temp
		xba
		ora <:temp

		; Massage the pixel from color index 0-3 up to index 4-7
		; but if it's 0, we need to leave it alone
		beq :is_zero2
		ora #$0404
:is_zero2

		ldy #4*32
		sta [:pPixels],y  ; Top half pixel #3 
		ldy #5*32
		sta [:pPixels],y  ; Bottom half of pixel #3

		lda 1,s
		lsr
		lsr
		and #1
		sta <:temp
		lda 1,s
		lsr
		lsr
		
		lsr
		lsr
		lsr
		and #2
		ora <:temp
		sta <:temp
		xba
		ora <:temp

		; Massage the pixel from color index 0-3 up to index 4-7
		; but if it's 0, we need to leave it alone
		beq :is_zero3
		ora #$0404
:is_zero3

		ldy #2*32
		sta [:pPixels],y  ; Top half of pixel #2
		ldy #3*32
		sta [:pPixels],y  ; Bottom Half of pixel #2

		lda 1,s
		lsr
		lsr
		lsr
		and #1
		sta <:temp
		pla
		lsr
		lsr
		lsr
		
		lsr
		lsr
		lsr
		and #2
		ora <:temp
		sta <:temp
		xba
		ora <:temp

		; Massage the pixel from color index 0-3 up to index 4-7
		; but if it's 0, we need to leave it alone
		beq :is_zero4
		ora #$0404
:is_zero4

		sta [:pPixels]		; Top half of pixel
		ldy #32
		sta [:pPixels],y    ; Bottom Half of pixel

		rts


;------------------------------------------------------------------------------
; Convert the Tiles and Display them!

TestTiles mx %00

;---------------------------------------------------------
; Copy map data to VRAM - Special Map data to see our converted tile data

		ldx #0
]lp
		lda |:map_data,x
		sta >VICKY_MAP0+VRAM+{64*2}+4,x
;		sta >VICKY_MAP1+VRAM+{64*2}+4,x
		inx
		inx
		cpx #64*16*2
		bcc ]lp

; Clear out the rest of the map data with $00FF, a clear tile character

		lda #$00FF
]lp
		sta >VICKY_MAP0+VRAM+{64*2}+4,x
;		sta >VICKY_MAP1+VRAM+{64*2}+4,x
		inx
		inx
		cpx #64*64*2
		bcc ]lp

;---------------------------------------------------------
; Convert MsPacman Tile data into Vicky Format!
;
; 8x8 Tile Rom over to 16x16 Tile RAM
;
; decompress tile_rom, to Tile RAM
;
:pTile   = temp0
:pPixels = temp1
:temp    = temp2
:loop_counter = temp3

		; Initialize Tile Address
		lda #VRAM+VICKY_MAP_TILES
		sta <:pTile
		lda #^{VRAM+VICKY_MAP_TILES}
		sta <:pTile+2

		ldx #0    ; start at offset zero in the tile ROM

		lda #256
]tile_loop
		pha

		; Pixels Address
		clc
		lda <:pTile
		adc #{16*8}+14
		sta <:pPixels
		lda <:pTile+2
;		adc #0  		; never going to need this
		sta <:pPixels+2



; Decode Bottom Half of a Tile

		jsr :decode_half


; Decode Top Half

		clc
		lda <:pTile
		adc #14
		sta <:pPixels

		jsr :decode_half

		clc
		lda <:pTile				; Goto next tile
		adc #256
		sta <:pTile


		pla
		dec						; loop 256 times
		bne ]tile_loop

		rts



:decode_half

		lda #8
		sta <:loop_counter
]lp
		lda >tile_rom,x
		inx

		jsr :decode4pixels

		dec <:pPixels
		dec <:pPixels

		dec <:loop_counter

		bne ]lp

		rts


:decode4pixels
; input pPixels in :pPixels
; A contains 4 pixels in MsPacman Arcade ROM format
		pha

		and #1
		sta <:temp
		lda 1,s
		lsr
		lsr
		lsr
		and #2
		ora <:temp
		sta <:temp
		xba
		ora <:temp

		ldy #6*16
		sta [:pPixels],y  ; top half of pixel #4
		ldy #7*16 
		sta [:pPixels],y  ; bottom half of pixel #

		lda 1,s
		lsr
		and #1
		sta <:temp
		lda 1,s
		lsr
		lsr
		lsr
		lsr
		and #2
		ora <:temp
		sta <:temp
		xba
		ora <:temp

		ldy #4*16
		sta [:pPixels],y  ; Top half pixel #3 
		ldy #5*16
		sta [:pPixels],y  ; Bottom half of pixel #3

		lda 1,s
		lsr
		lsr
		and #1
		sta <:temp
		lda 1,s
		lsr
		lsr
		
		lsr
		lsr
		lsr
		and #2
		ora <:temp
		sta <:temp
		xba
		ora <:temp

		ldy #2*16
		sta [:pPixels],y  ; Top half of pixel #2
		ldy #3*16
		sta [:pPixels],y  ; Bottom Half of pixel #2

		lda 1,s
		lsr
		lsr
		lsr
		and #1
		sta <:temp
		pla
		lsr
		lsr
		lsr
		
		lsr
		lsr
		lsr
		and #2
		ora <:temp
		sta <:temp
		xba
		ora <:temp

		sta [:pPixels]		; Top half of pixel
		ldy #16
		sta [:pPixels],y    ; Bottom Half of pixel

		rts

;------------------------------------------------------------------------------
;
; Vicky Compatible Map data, used to tell vicky which
; tiles to display on the layer
;
:map_data
	do 1
]var = 0
	lup 16
	dw $000+]var,$001+]var,$002+]var,$003+]var,$004+]var,$005+]var,$006+]var,$007+]var
	dw $008+]var,$009+]var,$00A+]var,$00B+]var,$00C+]var,$00D+]var,$00E+]var,$00F+]var
	dw 255,255,255,255,255,255,255,255
	dw 255,255,255,255,255,255,255,255

	dw 255,255,255,255,255,255,255,255
	dw 255,255,255,255,255,255,255,255
	dw 255,255,255,255,255,255,255,255
	dw 255,255,255,255,255,255,255,255

]var = ]var+16
	--^

	else

]var = 0
	lup 16
	dw $000+]var,255,$001+]var,255,$002+]var,255,$003+]var,255
	dw $004+]var,255,$005+]var,255,$006+]var,255,$007+]var,255
	dw $008+]var,255,$009+]var,255,$00A+]var,255,$00B+]var,255
	dw $00C+]var,255,$00D+]var,255,$00E+]var,255,$00F+]var,255

	dw 255,255,255,255,255,255,255,255
	dw 255,255,255,255,255,255,255,255
	dw 255,255,255,255,255,255,255,255
	dw 255,255,255,255,255,255,255,255

]var = ]var+16
	--^



	fin


;------------------------------------------------------------------------------
; vmemset0
;
; Memset a section of VRAM to 0, using VDMA

;
; PushL Dest VRAM Address
; PushL Size
;
vmemset0 mx %00

]size_bytes = 3
]dest_addr  = 7

		; switch into the VDMA Bank
		pea >VDMA_CONTROL_REG
		plb
		plb

		stz |VDMA_CONTROL_REG ; Disable DMA, set Fill Byte to 00

		sep #$10

		; Activate VDMA Circuit
		ldx #VDMA_CTRL_Enable+VDMA_CTRL_TRF_Fill
		stx |VDMA_CONTROL_REG

		; Setup the Destination address
		lda ]dest_addr,s
		sta |VDMA_DST_ADDY_L
		lda ]dest_addr+1,s
		sta |VDMA_DST_ADDY_L+1

		; set the length
		lda ]size_bytes,s
		sta |VDMA_SIZE_L
		lda ]size_bytes+2,s
		sta |VDMA_SIZE_L+2

		ldx #VDMA_CTRL_Enable+VDMA_CTRL_TRF_Fill+VDMA_CTRL_Start_TRF
		stx |VDMA_CONTROL_REG  ; kick the dma

		nop
		nop
		nop

]wait_dma
		ldx |VDMA_STATUS_REG
		bmi ]wait_dma

		ldx #0  			   ; done
		stx |VDMA_CONTROL_REG

		rep #$31    ; mxc=000

		; fix up stack
		lda 1,s
		sta 9,s

		tsc
		adc #8
		tcs

		phk
		plb
		rts
		
;------------------------------------------------------------------------------
; We need some kind of palette manager for use on background plane
; On MsPacMan hardware we could have up to 64 palettes on the screen at once
; In practice, we hope that we're less than 8 because that's what we can
; support on the C256 Foenix
;
; I think my basic idea is to record every color write into the "palette_ram"
;
; This is to track which palettes are in use, and how many tiles reference them
; We'll keep a lookup table up-to-date, that can quickly convert map palettes
; into Foenix Palettes
;
; What if we map the palette indices on-the-fly? palette_ram could hold
; pacman hw indices, or maybe it could hold native Foenix indices?
;

		
;------------------------------------------------------------------------------
;
;  Draw Maze to Screen
;
; 2419
DrawMaze mx %00

:pVRAM = temp0
:pMap  = temp1
:temp  = temp2

		lda #tile_ram		; Point to start of the video ram shadow
		sta <:pVRAM

		jsr WallAddress		; return address to map data in the rom, into :pMap

		clc
]loop
		lda (:pMap)
		and #$00FF
		beq :return
		bit #$0080
		bne :not_offset

		adc <:pVRAM			; Add offset to screen location
		dec
		sta <:pVRAM

		inc <:pMap
		lda (:pMap)

:not_offset

		inc <:pVRAM 		; screen location
		pei :pVRAM			; save the vram pointer
		sep #$20
		sta (:pVRAM)		; Store Maze to Screen
		pha 	  			; save the tile# we're writing
		rep #$30

		; mirror the maze screen to the right hand size?

		sec
		lda <:pVRAM
		sbc #tile_ram
		eor #$3E0  ;%1111100000   	; adjust address for H-FLIP
		clc
		adc #tile_ram
		sta <:pVRAM

		sep #$20
		pla 				; restore tile #
		eor #1  			; flip bit in tile# to find h flip version
		sta (:pVRAM)
		rep #$30

		pla
		sta <:pVRAM



;2430  11e083    ld      de,#83e0	; load DE with mirror position offset
;2433  7d        ld      a,l		; load A with L
;2434  e61f      and     #1f		; mask bits
;2436  87        add     a,a		; A := A * 2
;2437  2600      ld      h,#00		; H := #00

;2439  6f        ld      l,a		; load L with A
;243a  19        add     hl,de		; add offset to HL
;243b  d1        pop     de		; restore HL into DE
;243c  a7        and     a		; clear carry flag
;243d  ed52      sbc     hl,de		; subtract offset
;243f  f1        pop     af		; restore AF
;2440  ee01      xor     #01		; flip bit 1 of maze data = calculate reflected maze tile
;2442  77        ld      (hl),a		; store reflected tile in position
;2443  eb        ex      de,hl		; DE <-> HL

		inc <:pMap 			; next data
		bra ]loop

:return
		rts


;------------------------------------------------------------------------------
;
; OTTOPATCH
;PATCH TO DO SAME THING FOR DOTS
;NOTE THAT THE DOT TABLE IS USED TWICE, ONCE TO WRITE THE DOTS ONTO
;THE SCREEN THEN AGAIN TO SEE WHICH DOTS HAVE BEEN EATEN.
;
; 2448
DrawPills mx %00

:bitmask = temp 0
:pVRAM = temp1
:counter = temp2
:bitcount = temp3

		lda #tile_ram
		sta <:pVRAM

		lda #30			; the output size of the pilldata, also loop counter
		sta <:counter

		lda #PelletTable	; lookup table address
		sta <temp0

		jsr ChooseMaze
		tay 			; pointer to source pellet table

		ldx #pilldata		; pointer to output pill table data
]lp
		lda |0,x		; load A with pill entry
		sta <:bitmask

		lda #8			; 8 bits in the byte
		sta <:bitcount
]plp
		lda |0,y 		; load the pellet table, adjust offset into vram
		and #$FF
		clc
		adc <:pVRAM
		sta <:pVRAM

		sep #$20		; a short

		lda <:bitmask   	; load A with pill entry 
		cmp #$80
		rol
		sta <:bitmask

		bcc :no_pill

		lda #16 	 	; tile # for a pelette
		sta (:pVRAM)		; draw pill
:no_pill
		iny    			; next table data
		dec <:bitcount
		rep #$30		; a long again
		bne ]plp

		inx			; next pill entry
		dec <:counter
		bne ]lp

;		rts

;------------------------------------------------------------------------------
;
; 246f
DrawPowerPills mx %00

		lda #PowerPelletTable	; Lookup Table Address
		sta <temp0

		jsr ChooseMaze
		tay			; address of pelette table for this map

; Draw 4 Power Pills

		lda |0,y
		tax			; x = vram address
		sep #$20
		lda |powerpills		; first power pill
		sta |0,x		; store to VRAM
		rep #$20

		lda |2,y
		tax			; x = vram address
		sep #$20
		lda |powerpills+1	; 2nd power pill
		sta |0,x		; store to VRAM
		rep #$20

		lda |4,y
		tax			; x = vram address
		sep #$20
		lda |powerpills+2	; 3rd power pill
		sta |0,x		; store to VRAM
		rep #$20

		lda |6,y
		tax			; x = vram address
		sep #$20
		lda |powerpills+3	; 4th power pill
		sta |0,x		; store to VRAM
		rep #$20

		rts

; 24d7
task_colorMaze mx %00

;24d7  58        ld      e,b		; save task parameter to E, for use later at #24F3
;24d8  78        ld      a,b		; load A with task parameter
;24d9  fe02      cp      #02		; == # 02 ?
;24db  3e1f      ld      a,#1f		; load A with #1F = white color for flashing at end of level
		cmp #2
		bne ColorMaze

		lda #$1F
		bra ColorMaze+3


;------------------------------------------------------------------------------
;
; Color the Maze
;
; 24dd
		
ColorMaze mx %00

		jsr GetLevelColor

		; now A has the fill color
		ldx #1022-128  ; length

		; mirror color in low and high, for 16 bit stores
		pha
		xba
		ora 1,s
		sta 1,s
		pla

]lp
		sta |palette_ram+$40,x
		dex
		dex
		bpl ]lp
; 24eb

		; color top bar white
		; color bottom bar white
		ldx #64-2
		lda #$0F0F		; white
]lp
		sta |palette_ram,x        ; bottom
		sta |palette_ram+$3C0,x   ; top
		dex
		dex
		bpl ]lp

;$$TODO, finish task business and mark SLOW Areas

; sets bit 6 in the color grid of certain screen locations on the first three levels.
; This color bit is ignored when actually coloring the grid, so it is invisible onscreen.
; When a ghost encounters one of these specially painted areas, he slows down.
; This is used to slow down the ghosts when they use the tunnels on these levels. 
; called from #24F9

;95C3 3A 13 4E 	LD 	A,(#4E13) 	; Load A with current level number
;95C6 FE 03 	CP 	#03 		; Is A < #03 ?
;95C8 F2 34 25 	JP 	P,#2534 	; No, jump back to program [bug.  should be JP NC, not JP P.]
;95CB 21 DF 95 	LD 	HL,#95DF 	; Yes, load HL with start of table data address
;95CE CD BD 94 	CALL 	#94BD 		; Load BC with either #95DF or #95E1 depending on the level
;95D1 21 00 44 	LD 	HL,#4400 	; Load HL with start of color memory
;95D4 0A 	LD 	A,(BC) 		; Load A with the table data
;95D5 03 	INC 	BC 		; Set BC to next value in table
;95D6 A7 	AND 	A 		; Is A == 0 ?
;95D7 CA 34 25 	JP 	Z,#2534 	; Yes, jump back to program
;95DA D7 	RST 	#10 		; No, load A with table value of (HL + A) and load HL with HL + A
;95DB CB F6 	SET 	6,(HL) 		; Sets bit 6 of HL - MAKE tunnel slow for ghosts
;95DD 18 F5 	JR 	#95D4 		; Loop back and do again

;95DF 3D 8B 				; #83BD Pointer to table for tunnel data for levels 1 and 2
;95E1 28 8E 				; #8E28 Pointer to table for tunnel data for level 3



; ms. pac resumes here
;2534  3e18      ld      a,#18		; A := #18 = code for pink color
		sep #$20
		lda #$18
;2536  32ed45    ld      (#45ed),a	; store into ghost house door (right side) color
		sta |palette_ram+$1ED
;2539  320d46    ld      (#460d),a	; store into ghost house door (left side) color
		sta |palette_ram+$20D
		rep #$30
;253c  c9        ret     		; return
		rts		


;------------------------------------------------------------------------------
;
; select the proper maze
;
; 946a
WallAddress mx %00

		lda #MazeTable
		sta <temp0
		jsr ChooseMaze  ; A is the pointer to the maze, base on current level
		sta <temp1

		lda #tile_ram
		sta <temp0

		rts

MazeTable
		da Maze1    ; 88c1
		da Maze2    ; 8bae
		da Maze3    ; 8ea8
		da Maze4    ; 9179


;	; pellet crossreference routine patch
;	; arrive from #244b
;
;947c  215324    ld      hl,#2453	; load HL with return address
;947f  1803      jr      #9484           ; skip next step
;
;	; arrive here from #248A
;
;9481  219224    ld      hl,#2492	; load HL with return address
;
;9484  e5        push    hl		; push HL to stack for return address (either #2453 or #2492)
;9485  219994    ld      hl,#9499	; load HL with pellet map lookup table address
;9488  cdbd94    call    #94bd		; load BC with value based on the level
;948b  fd210000  ld      iy,#0000	; IY = #0000
;948f  fd09      add     iy,bc		; add BC into IY
;9491  210040    ld      hl,#4000	; load HL with start of video RAM
;9494  dd21164e  ld      ix,#4e16	; load IX with pellet entries
;9498  c9        ret     		; return (returns to either #2453 or #2492)

; 9499
PelletTable
		da Pellet1  ; 8a3b ; pellets for maze 1
		da Pellet2  ; 8d27 ; pellets for maze 2
		da Pellet3  ; 9018 ; pellets for maze 3
		da Pellet4  ; 92ec ; pellets for maze 4

; 94B5
PelletCountTable
		da PelletCount1
		da PelletCount2
		da PelletCount3
		da PelletCount4


;------------------------------------------------------------------------------
; Used to determine which maze to draw and other things
; load BC with a value based on the level and the value already loaded into HL.
; This keeps the game cycling between the 3rd and 4th mazes, which appear on levels 6 through 14.
; 94bd
ChooseMaze mx %00

		lda |level
		cmp #13			; is level number >= 13
		bcs :wrap_level		; level needs clamped between 0 and 13
:continue
		tax
		lda |MapOrderTable,x
		and #$FF
		asl
		tay
		lda (temp0),y
	
		rts
		
; keep level from 0-13
:wrap_level
		; c=1
		sbc #13

]lp		sec
		sbc #8  	 	; subtract 8 until negative
		bcs ]lp

		adc #13			; add 13 back in

		bra :continue

MapOrderTable
		db 0,0			; 1st and 2nd Boards use Maze 1
		db 1,1,1		; 3rd,4th, and 5th boards use mase 2
		db 2,2,2,2		; 6-9 use maze 3
		db 3,3,3,3		; 10-13 use maze 4


; 88c1
Maze1
	;; Maze Table 1
		db	$40,$FC,$D0,$D2,$D2,$D2,$D2,$D4,$FC,$DA,$02,$DC,$FC,$FC,$FC
		db  $FC,$FC,$FC,$DA,$02,$DC,$FC,$FC,$FC,$D0,$D2,$D2,$D2,$D2,$D2,$D2
		db  $D2,$D4,$FC,$DA,$05,$DC,$FC,$DA,$02,$DC,$FC,$FC,$FC,$FC,$FC,$FC
		db  $DA,$02,$DC,$FC,$FC,$FC,$DA,$08,$DC,$FC,$DA,$02,$E6,$EA,$02,$E7
		db  $D2,$EB,$02,$E7,$D2,$D2,$D2,$D2,$D2,$D2,$EB,$02,$E7,$D2,$D2,$D2
		db  $EB,$02,$E6,$E8,$E8,$E8,$EA,$02,$DC,$FC,$DA,$02,$DE,$E4,$15,$DE
		db  $C0,$C0,$C0,$E4,$02,$DC,$FC,$DA,$02,$DE,$E4,$02,$E6,$E8,$E8,$E8
		db  $E8,$EA,$02,$E6,$E8,$E8,$E8,$EA,$02,$E6,$EA,$02,$E6,$EA,$02,$DE
		db  $C0,$C0,$C0,$E4,$02,$DC,$FC,$DA,$02,$E7,$EB,$02,$E7,$E9,$E9,$E9
		db  $F5,$E4,$02,$DE,$F3,$E9,$E9,$EB,$02,$DE,$E4,$02,$DE,$E4,$02,$E7
		db  $E9,$E9,$E9,$EB,$02,$DC,$FC,$DA,$09,$DE,$E4,$02,$DE,$E4,$05,$DE
		db  $E4,$02,$DE,$E4,$08,$DC,$FC,$FA,$E8,$E8,$EA,$02,$E6,$E8,$EA,$02
		db  $DE,$E4,$02,$DE,$E4,$02,$E6,$E8,$E8,$F4,$E4,$02,$DE,$E4,$02,$E6
		db  $E8,$E8,$E8,$EA,$02,$DC,$FC,$FB,$E9,$E9,$EB,$02,$DE,$C0,$E4,$02
		db  $E7,$EB,$02,$E7,$EB,$02,$E7,$E9,$E9,$F5,$E4,$02,$E7,$EB,$02,$DE
		db  $F3,$E9,$E9,$EB,$02,$DC,$FC,$DA,$05,$DE,$C0,$E4,$0B,$DE,$E4,$05
		db  $DE,$E4,$05,$DC,$FC,$DA,$02,$E6,$EA,$02,$DE,$C0,$E4,$02,$E6,$EA
		db  $02,$EC,$D3,$D3,$D3,$EE,$02,$DE,$E4,$02,$E6,$EA,$02,$DE,$E4,$02
		db  $E6,$EA,$02,$DC,$FC,$DA,$02,$DE,$E4,$02,$E7,$E9,$EB,$02,$DE,$E4
		db  $02,$DC,$FC,$FC,$FC,$DA,$02,$E7,$EB,$02,$DE,$E4,$02,$E7,$EB,$02
		db  $DE,$E4,$02,$DC,$FC,$DA,$02,$DE,$E4,$06,$DE,$E4,$02,$F0,$FC,$FC
		db  $FC,$DA,$05,$DE,$E4,$05,$DE,$E4,$02,$DC,$FC,$DA,$02,$DE,$E4,$02
		db  $E6,$E8,$E8,$E8,$F4,$E4,$02,$CE,$FC,$FC,$FC,$DA,$02,$E6,$E8,$E8
		db  $F4,$E4,$02,$E6,$E8,$E8,$F4,$E4,$02,$DC,$00

	;; Pellet table for maze 1
;8A3B
Pellet1
		db $62,$02,$01,$13,$01
		db $01,$01,$02,$01,$04,$03,$13,$06,$04,$03,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$06,$04,$03
		db $10,$03,$06,$04,$03,$10,$03,$06,$04,$01,$01,$01,$01,$01,$01,$01
		db $0C,$03,$01,$01,$01,$01,$01,$01,$07,$04,$0C,$03,$06,$07,$04,$0C
		db $03,$06,$04,$01,$01,$01,$04,$0C,$01,$01,$01,$03,$01,$01,$01,$04
		db $03,$04,$0F,$03,$03,$04,$03,$04,$0F,$03,$03,$04,$03,$01,$01,$01
		db $01,$0F,$01,$01,$01,$03,$04,$03,$19,$04,$03,$19,$04,$03,$01,$01
		db $01,$01,$0F,$01,$01,$01,$03,$04,$03,$04,$0F,$03,$03,$04,$03,$04
		db $0F,$03,$03,$04,$01,$01,$01,$04,$0C,$01,$01,$01,$03,$01,$01,$01
		db $07,$04,$0C,$03,$06,$07,$04,$0C,$03,$06,$04,$01,$01,$01,$01,$01
		db $01,$01,$0C,$03,$01,$01,$01,$01,$01,$01,$04,$03,$10,$03,$06,$04
		db $03,$10,$03,$06,$04,$03,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01,$01,$06,$04,$03,$13,$06,$04,$02
		db $01,$13,$01,$01,$01,$02,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

	;; number of pellets to eat for maze 1

;8b2c
PelletCount1
		db  $e0				; #E0 = 224 decimal

	;; ghost destination table for maze 1
; 8B2D
ghost_targets_1
		db $1d,$22				; column 22, row 1D (top right)
		db $1d,$39				; column 39, row 1D (top left)
		db $40,$20				; column 20, row 40 (bottom right)
		db $40,$3b				; column 3B, row 40 (bottom left)


	;; Power Pellet Table for maze 1 (screen locations)
;8b35
Power1
		da tile_ram+$63			; #4063 = location of upper right power pellet
		da tile_ram+$7c			; #407C = location of lower right power pellet
		da tile_ram+$383		; #4383	= location of upper left power pellet
		da tile_ram+$39c		; #439C = location of lower left power pellet


; data table used for drawing slow down tunnels on levels 1 and 2

;8b3d
		db $49,$09,$17
		db $09,$17,$09,$0E,$E0,$E0,$E0,$29,$09,$17,$09,$17,$09,$00,$00

;------------------------------------------------------------------------------
;; entrance fruit paths for maze 1:  #8b4f - #8b81
;8b4f
ent_fpaths_maze1
		da :path0 			;db $63,$8B	; #8B63
		db $13,$94,$0C
		da :path1 			;db $68,$8B	; #8B68
		db $22,$94,$F4
		da :path2 			;db $71,$8B	; #8B71
		db $27,$4C,$F4
		da :path3 			;db $7B,$8B	; #8B7B
		db $1C,$4C,$0C
:path0
		db $80,$AA,$AA,$BF,$AA
:path1
		db $80,$0A,$54,$55,$55,$55,$FF,$5F,$55
:path2
		db $EA,$FF,$57,$55,$F5,$57,$FF,$15,$40,$55
:path3
		db $EA,$AF,$02,$EA,$FF,$FF,$AA

	;; exit fruit paths for maze 1
;8b82
exit_fpaths_maze1
		da :path0 		;db $94,$8B	; #8B94
		db $14,$00,$00
		da :path1 		;db $99,$8B	; #8B99
		db $17,$00,$00
		da :path2 		;db $9F,$8B	; #8B9F
		db $1A,$00,$00
		da :path3 		;db $A6,$8B	; #8BA6
		db $1D
:path0
		db $55,$40,$55,$55,$BF
:path1
		db $AA,$80,$AA,$AA,$BF,$AA
:path2
		db $AA,$80,$AA,$02,$80,$AA,$AA
:path3
		db $55,$00,$00,$00,$55,$55,$FD,$AA


; 8BAE
Maze2

	;; Maze 2 Table
		db $40,$FC
		db $DA,$02,$DE,$D8,$D2,$D2,$D2,$D2,$D2,$D2,$D2,$D6,$D8,$D2,$D2,$D2
		db $D2,$D4,$FC,$FC,$FC,$FC,$DA,$02,$DE,$D8,$D2,$D2,$D2,$D2,$D4,$FC
		db $DA,$02,$DE,$E4,$08,$DE,$E4,$05,$DC,$FC,$FC,$FC,$FC,$DA,$02,$DE
		db $E4,$05,$DC,$FC,$DA,$02,$DE,$E4,$02,$E6,$E8,$E8,$E8,$EA,$02,$DE
		db $E4,$02,$E6,$EA,$02,$E7,$D2,$D2,$D2,$D2,$EB,$02,$E7,$EB,$02,$E6
		db $EA,$02,$DC,$FC,$DA,$02,$DE,$E4,$02,$DE,$F3,$E9,$E9,$EB,$02,$DE
		db $E4,$02,$DE,$E4,$0C,$DE,$E4,$02,$DC,$FC,$DA,$02,$DE,$E4,$02,$DE
		db $E4,$05,$DE,$E4,$02,$DE,$F2,$E8,$E8,$E8,$EA,$02,$E6,$EA,$02,$E6
		db $E8,$E8,$F4,$E4,$02,$DC,$FC,$DA,$02,$E7,$EB,$02,$DE,$E4,$02,$E6
		db $EA,$02,$E7,$EB,$02,$E7,$E9,$E9,$E9,$E9,$EB,$02,$DE,$E4,$02,$E7
		db $E9,$E9,$E9,$EB,$02,$DC,$FC,$DA,$05,$DE,$E4,$02,$DE,$E4,$0C,$DE
		db $E4,$08,$DC,$FC,$FA,$E8,$E8,$EA,$02,$DE,$E4,$02,$DE,$F2,$E8,$E8
		db $E8,$E8,$EA,$02,$E6,$E8,$E8,$EA,$02,$DE,$F2,$E8,$E8,$EA,$02,$E6
		db $EA,$02,$DC,$FC,$FB,$E9,$E9,$EB,$02,$E7,$EB,$02,$E7,$E9,$E9,$E9
		db $E9,$E9,$EB,$02,$E7,$E9,$F5,$E4,$02,$DE,$F3,$E9,$E9,$EB,$02,$DE
		db $E4,$02,$DC,$FC,$DA,$12,$DE,$E4,$02,$DE,$E4,$05,$DE,$E4,$02,$DC
		db $FC,$DA,$02,$E6,$EA,$02,$E6,$E8,$E8,$E8,$E8,$EA,$02,$EC,$D3,$D3
		db $D3,$EE,$02,$E7,$EB,$02,$E7,$EB,$02,$E6,$EA,$02,$DE,$E4,$02,$DC
		db $FC,$DA,$02,$DE,$E4,$02,$E7,$E9,$E9,$E9,$F5,$E4,$02,$DC,$FC,$FC
		db $FC,$DA,$08,$DE,$E4,$02,$E7,$EB,$02,$DC,$FC,$DA,$02,$DE,$E4,$06
		db $DE,$E4,$02,$F0,$FC,$FC,$FC,$DA,$02,$E6,$E8,$E8,$E8,$EA,$02,$DE
		db $E4,$05,$DC,$FC,$DA,$02,$DE,$F2,$E8,$E8,$E8,$EA,$02,$DE,$E4,$02
		db $CE,$FC,$FC,$FC,$DA,$02,$DE,$C0,$C0,$C0,$E4,$02,$DE,$F2,$E8,$E8
		db $EA,$02,$DC,$00,$00,$00,$00

	;; Pellet table for maze 2
;8d27
Pellet2
		db $66,$01,$01,$01,$01,$01,$03,$01,$01
		db $01,$0B,$01,$01,$07,$06,$03,$03,$0A,$03,$07,$06,$03,$03,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01,$03,$07,$03,$01,$01,$01,$03,$07
		db $03,$06,$07,$03,$03,$03,$07,$03,$06,$07,$03,$03,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$03,$01,$01,$01,$01,$01,$01,$07,$03,$0D
		db $06,$03,$07,$03,$0D,$06,$03,$04,$01,$01,$01,$01,$01,$01,$0D,$03
		db $01,$01,$01,$03,$04,$03,$10,$03,$03,$03,$04,$03,$10,$01,$01,$01
		db $03,$03,$04,$03,$01,$01,$01,$01,$12,$01,$01,$01,$04,$07,$15,$04
		db $07,$15,$04,$03,$01,$01,$01,$01,$12,$01,$01,$01,$04,$03,$10,$01
		db $01,$01,$03,$03,$04,$03,$10,$03,$03,$03,$04,$01,$01,$01,$01,$01
		db $01,$0D,$03,$01,$01,$01,$03,$07,$03,$0D,$06,$03,$07,$03,$0D,$06
		db $03,$07,$03,$03,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$03,$01
		db $01,$01,$01,$01,$01,$07,$03,$03,$03,$07,$03,$06,$07,$03,$01,$01
		db $01,$03,$07,$03,$06,$07,$06,$03,$03,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$03,$07,$06,$03,$03,$0A,$03,$08,$01,$01,$01,$01,$01
		db $03,$01,$01,$01,$0B,$01,$01

	;; number of pellets to eat for map 2
;8e17
PelletCount2
		db  $f4				; #F4 = 244 decimal


	;; destination table for maze 2
;8e18
ghost_targets_2
		db $1d,$22				; column 22, row 1D (top right)
		db $1d,$39				; column 39, row 1D (top right)
		db $40,$20				; column 20, row 40 (bottom right)
		db $40,$3b				; column 3B, row 40 (bottom left)

	;; Power Pellet Table for maze 2 screen locations
;8e20
Power2
		da tile_ram+$65	   		; #4065 = power pellet upper right
		da tile_ram+$7b	   		; #407B = power pellet lower right
		da tile_ram+$385		; #4385 = power pellet upper left
		da tile_ram+$39b		; #439B = power pellet lower left


; data table used for drawing slow down tunnels on level 3
;8e28
		db $42,$16,$0A,$16,$0A,$16,$0A,$20
		db $30,$20,$20,$DE,$E0,$22,$20,$20,$20,$20,$16,$0A,$16,$16,$00,$00

;------------------------------------------------------------------------------
	;; entrance fruit paths for maze 2:  #8E40-8E72
;8e40
ent_fpaths_maze2
		da :path0 ;db $54,$8E				; #8E54
		db $13,$C4,$0C
		da :path1 ;db $59,$8E				; #8E59
		db $1E,$C4,$F4
		da :path2 ;db $61,$8E				; #8E61
		db $26,$14,$F4
		da :path3 ;db $6B,$8E				; #8E6B
		db $1D,$14,$0C
:path0
		db $02,$AA,$AA,$80,$2A
:path1
		db $02,$40,$55,$7F,$55,$15,$50,$05
:path2
		db $EA,$FF,$57,$55,$F5,$FF,$57,$7F,$55,$05
:path3
		db $EA,$FF,$FF,$FF,$EA,$AF,$AA,$02


	;; exit fruit paths for maze 2
;8e73
exit_fpaths_maze2
		da :path0 ;db $87,$8E				; #8E87
		db $12,$00,$00
		da :path1 ;db $8C,$8E				; #8E8C
		db $1D,$00,$00
		da :path2 ;db $94,$8E				; #8E94
		db $21,$00,$00
		da :path3 ;db $9D,$8E				; #8E9D
		db $2C,$00,$00
:path0
		db $55,$7F,$55,$D5,$FF
:path1
		db $AA,$BF,$AA,$2A,$A0,$EA,$FF,$FF
:path2
		db $AA,$2A,$A0,$02,$00,$00,$A0,$AA,$02
:path3
		db $55,$15,$A0,$2A,$00,$54,$05,$00,$00,$55,$FD


Maze3

	;; Maze Table 3
;8ea8
		db $40,$FC,$D0,$D2,$D2,$D2,$D2,$D2
		db $D2,$D6,$E4,$02,$E7,$D2,$D2,$D2,$D2,$D2,$D2,$D2,$D2,$D2,$D2,$D6
		db $D8,$D2,$D2,$D2,$D2,$D2,$D2,$D2,$D4,$FC,$DA,$07,$DE,$E4,$0D,$DE
		db $E4,$08,$DC,$FC,$DA,$02,$E6,$E8,$E8,$EA,$02,$DE,$E4,$02,$E6,$E8
		db $E8,$EA,$02,$E6,$E8,$E8,$E8,$EA,$02,$E7,$EB,$02,$E6,$EA,$02,$E6
		db $EA,$02,$DC,$FC,$DA,$02,$DE,$F3,$E9,$EB,$02,$E7,$EB,$02,$E7,$E9
		db $F5,$E4,$02,$E7,$E9,$E9,$F5,$E4,$05,$DE,$E4,$02,$DE,$E4,$02,$DC
		db $FC,$DA,$02,$DE,$E4,$09,$DE,$E4,$05,$DE,$E4,$02,$E6,$E8,$E8,$F4
		db $E4,$02,$DE,$E4,$02,$DC,$FC,$DA,$02,$DE,$E4,$02,$E6,$E8,$E8,$E8
		db $E8,$EA,$02,$E7,$EB,$02,$E6,$EA,$02,$E7,$EB,$02,$E7,$E9,$E9,$E9
		db $EB,$02,$E7,$EB,$02,$DC,$FC,$DA,$02,$DE,$E4,$02,$E7,$E9,$E9,$E9
		db $F5,$E4,$05,$DE,$E4,$0E,$DC,$FC,$DA,$02,$DE,$E4,$06,$DE,$E4,$02
		db $E6,$E8,$E8,$F4,$E4,$02,$E6,$E8,$E8,$E8,$EA,$02,$E6,$E8,$E8,$E8
		db $E8,$E8,$F4,$FC,$DA,$02,$E7,$EB,$02,$E6,$E8,$EA,$02,$E7,$EB,$02
		db $E7,$E9,$E9,$E9,$EB,$02,$DE,$F3,$E9,$E9,$EB,$02,$DE,$F3,$E9,$E9
		db $E9,$E9,$F5,$FC,$DA,$05,$DE,$C0,$E4,$0B,$DE,$E4,$05,$DE,$E4,$05
		db $DC,$FC,$FA,$E8,$E8,$EA,$02,$DE,$C0,$E4,$02,$E6,$EA,$02,$EC,$D3
		db $D3,$D3,$EE,$02,$DE,$E4,$02,$E6,$EA,$02,$DE,$E4,$02,$E6,$EA,$02
		db $DC,$FC,$FB,$E9,$E9,$EB,$02,$E7,$E9,$EB,$02,$DE,$E4,$02,$DC,$FC
		db $FC,$FC,$DA,$02,$E7,$EB,$02,$DE,$E4,$02,$E7,$EB,$02,$DE,$E4,$02
		db $DC,$FC,$DA,$09,$DE,$E4,$02,$F0,$FC,$FC,$FC,$DA,$05,$DE,$E4,$05
		db $DE,$E4,$02,$DC,$FC,$DA,$02,$E6,$E8,$E8,$E8,$E8,$EA,$02,$DE,$E4
		db $02,$CE,$FC,$FC,$FC,$DA,$02,$E6,$E8,$E8,$F4,$E4,$02,$E6,$E8,$E8
		db $F4,$E4,$02,$DC,$00,$00,$00,$00

	;; Pellet table for maze 3
;9018
Pellet3
		db $62,$01,$02,$01,$01,$03,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01,$01,$04,$01,$01,$01,$01,$01,$04
		db $05,$03,$0B,$03,$03,$03,$04,$05,$03,$0B,$01,$01,$01,$03,$03,$04
		db $03,$01,$01,$01,$01,$01,$0B,$06,$03,$04,$03,$10,$06,$03,$04,$03
		db $10,$01,$01,$01,$01,$01,$01,$01,$01,$01,$04,$03,$01,$01,$01,$01
		db $0F,$0A,$03,$04,$0F,$0A,$01,$01,$01,$04,$0C,$01,$01,$01,$03,$01
		db $01,$01,$07,$04,$0C,$03,$03,$03,$07,$04,$0C,$03,$03,$03,$04,$01
		db $01,$01,$01,$01,$01,$01,$0C,$03,$01,$01,$01,$03,$04,$07,$15,$04
		db $07,$15,$04,$01,$01,$01,$01,$01,$01,$01,$0C,$03,$01,$01,$01,$03
		db $07,$04,$0C,$03,$03,$03,$07,$04,$0C,$03,$03,$03,$04,$01,$01,$01
		db $04,$0C,$01,$01,$01,$03,$01,$01,$01,$04,$03,$04,$0F,$0A,$03,$01
		db $01,$01,$01,$0F,$0A,$03,$10,$01,$01,$01,$01,$01,$01,$01,$01,$01
		db $04,$03,$10,$06,$03,$04,$03,$01,$01,$01,$01,$01,$0B,$06,$03,$04
		db $05,$03,$0B,$01,$01,$01,$03,$03,$04,$05,$03,$0B,$03,$03,$03,$04
		db $01,$02,$01,$01,$03,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
		db $04,$01,$01,$01,$01,$01,$00,$00,$00

	;; number of pellets to eat for maze 3
;9109
PelletCount3
		db  $f2				; #F2 = 242 decimal

	;; destination table for maze 3
;910a
ghost_targets_3
		db $40,$2d				; column 2d, row 40 (bottom center)
		db $1d,$22				; column 22, row 1D (top right)
		db $1d,$39				; column 39, row 1D (top left)
		db $40,$20				; column 20, row 40 (bottom right)

	;; Power Pellet Table 3
;9112
Power3
		da tile_ram+$64			; #4064
		da tile_ram+$78			; #4078
		da tile_ram+$384		; #4384
		da tile_ram+$398		; #4398

	;; entrance fruit paths for maze 3:  #911A-9141
;911a
ent_fpaths_maze3
		da :path0 ;db $2E,$91				; #912E
		db $15,$54,$0C
		da :path1 ;db $34,$91				; #9134
		db $1E,$54,$F4
		da :path2 ;db $34,$91				; #9134
		db $1E,$54,$F4
		da :path3 ;db $3C,$91				; #913C
		db $15,$54,$0C

;912e
:path0
		db $EA,$FF,$AB,$FA,$AA,$AA
:path1
:path2
		db $EA,$FF,$57,$55,$55,$D5,$57,$55
:path3
		db $AA,$AA,$BF,$FA

	;; exit fruit paths for maze 3
;9142
exit_fpaths_maze3
		da :path0 ;db $56,$91				; #9156
		db $22,$00,$00
		da :path1 ;db $5f,$91				; #915F
		db $25,$00,$00
		da :path2 ;db $5f,$91				; #915F
		db $25,$00,$00
		da :path3 ;db $6f,$91				; #916F
		db $28,$00,$00

;9156
:path0
		db $05,$00,$00,$54,$05,$54,$7F,$F5,$0B
:path1
:path2
		db $0A,$00,$00,$A8,$0A,$A8,$BF,$FA,$AB,$AA,$AA,$82,$AA,$00,$A0,$AA
:path3
		db $55,$41,$55,$00,$A0,$02,$40,$F5,$57,$BF


	;; Maze Table 4
;9179
Maze4
		db $40,$FC,$D0,$D2,$D2,$D2,$D2
		db $D2,$D2,$D2,$D2,$D4,$FC,$FC,$DA,$02,$DE,$E4,$02,$DC,$FC,$FC,$FC
		db $FC,$D0,$D2,$D2,$D2,$D2,$D2,$D2,$D2,$D4,$FC,$DA,$09,$DC,$FC,$FC
		db $DA,$02,$DE,$E4,$02,$DC,$FC,$FC,$FC,$FC,$DA,$08,$DC,$FC,$DA,$02
		db $E6,$E8,$E8,$E8,$E8,$EA,$02,$E7,$D2,$D2,$EB,$02,$DE,$E4,$02,$E7
		db $D2,$D2,$D2,$D2,$EB,$02,$E6,$E8,$E8,$E8,$EA,$02,$DC,$FC,$DA,$02
		db $E7,$E9,$E9,$E9,$F5,$E4,$07,$DE,$E4,$09,$DE,$F3,$E9,$E9,$EB,$02
		db $DC,$FC,$DA,$06,$DE,$E4,$02,$E6,$EA,$02,$E6,$E8,$F4,$F2,$E8,$EA
		db $02,$E6,$E8,$E8,$EA,$02,$DE,$E4,$05,$DC,$FC,$DA,$02,$E6,$E8,$EA
		db $02,$E7,$EB,$02,$DE,$E4,$02,$E7,$E9,$E9,$E9,$E9,$EB,$02,$E7,$E9
		db $F5,$E4,$02,$E7,$EB,$02,$E6,$EA,$02,$DC,$FC,$DA,$02,$DE,$C0,$E4
		db $05,$DE,$E4,$0B,$DE,$E4,$05,$DE,$E4,$02,$DC,$FC,$DA,$02,$DE,$C0
		db $E4,$02,$E6,$E8,$E8,$F4,$F2,$E8,$E8,$EA,$02,$E6,$E8,$E8,$E8,$EA
		db $02,$DE,$E4,$02,$E6,$E8,$E8,$F4,$E4,$02,$DC,$FC,$DA,$02,$E7,$E9
		db $EB,$02,$E7,$E9,$E9,$F5,$F3,$E9,$E9,$EB,$02,$E7,$E9,$E9,$F5,$E4
		db $02,$E7,$EB,$02,$E7,$E9,$E9,$F5,$E4,$02,$DC,$FC,$DA,$09,$DE,$E4
		db $08,$DE,$E4,$08,$DE,$E4,$02,$DC,$FC,$DA,$02,$E6,$E8,$E8,$E8,$E8
		db $EA,$02,$DE,$E4,$02,$EC,$D3,$D3,$D3,$EE,$02,$DE,$E4,$02,$E6,$E8
		db $E8,$E8,$EA,$02,$DE,$E4,$02,$DC,$FC,$DA,$02,$DE,$F3,$E9,$E9,$E9
		db $EB,$02,$E7,$EB,$02,$DC,$FC,$FC,$FC,$DA,$02,$E7,$EB,$02,$E7,$E9
		db $E9,$F5,$E4,$02,$E7,$EB,$02,$DC,$FC,$DA,$02,$DE,$E4,$09,$F0,$FC
		db $FC,$FC,$DA,$08,$DE,$E4,$05,$DC,$FC,$DA,$02,$DE,$E4,$02,$E6,$E8
		db $E8,$E8,$E8,$EA,$02,$CE,$FC,$FC,$FC,$DA,$02,$E6,$E8,$E8,$E8,$EA
		db $02,$DE,$E4,$02,$E6,$E8,$E8,$F4,$00,$00,$00,$00

	;; Pellet table for maze 4
;92ec
Pellet4
		db $62,$01,$02,$01
		db $01,$01,$01,$0F,$01,$01,$01,$02,$01,$04,$07,$0F,$06,$04,$07,$01
		db $01,$01,$07,$01,$01,$01,$01,$01,$06,$04,$01,$01,$01,$01,$03,$03
		db $07,$05,$03,$01,$01,$01,$04,$04,$03,$03,$07,$05,$03,$03,$04,$04
		db $01,$01,$01,$03,$01,$01,$01,$01,$01,$01,$01,$01,$01,$03,$01,$01
		db $01,$03,$04,$04,$0F,$03,$06,$04,$04,$0F,$03,$06,$04,$01,$01,$01
		db $01,$01,$01,$01,$0C,$01,$01,$01,$01,$01,$01,$03,$04,$07,$12,$03
		db $04,$07,$12,$03,$04,$03,$01,$01,$01,$01,$12,$01,$01,$01,$04,$03
		db $16,$07,$03,$16,$07,$03,$01,$01,$01,$01,$12,$01,$01,$01,$04,$07
		db $12,$03,$04,$07,$12,$03,$04,$01,$01,$01,$01,$01,$01,$01,$0C,$01
		db $01,$01,$01,$01,$01,$03,$04,$04,$0F,$03,$06,$04,$04,$0F,$03,$06
		db $04,$04,$01,$01,$01,$03,$01,$01,$01,$01,$01,$01,$01,$01,$01,$03
		db $01,$01,$01,$03,$04,$04,$03,$03,$07,$05,$03,$03,$04,$01,$01,$01
		db $01,$03,$03,$07,$05,$03,$01,$01,$01,$04,$07,$01,$01,$01,$07,$01
		db $01,$01,$01,$01,$06,$04,$07,$0F,$06,$04,$01,$02,$01,$01,$01,$01
		db $0F,$01,$01,$01,$02,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00

	;; number of pellets to eat for maze 4
;93f9
PelletCount4
		db  $EE				; #EE = 238 decimal

	;; Power Pellet Table for maze 4
;93fa
Power4  
		da tile_ram+$64				; #4064
		da tile_ram+$7c				; #407C
		da tile_ram+$384			; #4384
		da tile_ram+$39c			; #439C

	;; destination table for maze 4
;9402
ghost_targets_4
		db $1d,$22				; column 22, row 1D (top right)
		db $40,$20				; column 20, row 40 (bottom right)
		db $1d,$39				; column 39, row 1D (top left)
		db $40,$3b				; column 3B, row 40 (bottom left)

	;; entrance fruit paths for maze 4:  #940A - #943B
;940a
ent_fpaths_maze4
		da :path0 ;db $1E,$94				; #941E
		db $14,$8C,$0C
		da :path1 ;db $23,$94				; #9423
		db $1D,$8C,$F4
		da :path2 ;db $2B,$94				; #942B
		db $2A,$74,$F4
		da :path3 ;db $36,$94				; #9436
		db $15,$74,$0C
:path0
		db $80,$AA,$BE,$FA,$AA
:path1
		db $00,$50,$FD,$55,$F5,$D5,$57,$55
:path2
		db $EA,$FF,$57,$D5,$5F,$FD,$15,$50,$01,$50,$55
:path3
		db $EA,$AF,$FE,$2A,$A8,$AA


	;; exit fruit paths for maze 4
;943c
exit_fpaths_maze4
		da :path0 ;db $50,$94				; #9450
		db $15,$00,$00
		da :path1 ;db $56,$94				; #9456
		db $18,$00,$00
		da :path2 ;db $5C,$94				; #945C
		db $19,$00,$00	
		da :path3 ;db $63,$94				; #9463
		db $1C,$00,$00
:path0
		db $55,$50,$41,$55,$FD,$AA
:path1
		db $AA,$A0,$82,$AA,$FE,$AA
:path2
		db $AA,$AF,$02,$2A,$A0,$AA,$AA
:path3
		db $55,$5F,$01,$00,$50,$55,$BF

;------------------------------------------------------------------------------

PowerPelletTable
		da Power1   ; #8B35 ; maze 1 power pellet address table 
		da Power2   ; #8E20 ; maze 2 power pellet address table 
		da Power3   ; #9112 ; maze 3 power pellet address table 
		da Power4   ; #93FA ; maze 4 power pellet address table

;------------------------------------------------------------------------------
; this subroutine flashes the power pellets
; arrive from #0C21
; $$JGA this works by altering the palette index used, all 4 locations
; $$JGA "flash" even after the power pill has been eaten/removed from the map
; 9524
FLASHEN	mx %00

;9524  c5        push    bc		; save BC
;9525  d5        push    de		; save DE
;9526  211c95    ld      hl,#951c	; load HL with power pellet lookup table start
;9529  cdbd94    call    #94bd		; load BC with address of power pellet table based on map played

	    lda #PowerPelletTable		; Lookup Table Address
	    sta <temp0

	    jsr ChooseMaze
	    tay							; address of pelette table for this map

;952c  60        ld      h,b
;952d  69        ld      l,c		; load HL with BC
;952e  5e        ld      e,(hl)		; 
;952f  23        inc     hl
;9530  56        ld      d,(hl)		; load DE with the screen location of the first power pellet
	    lda |0,y
;9531  eb        ex      de,hl		; Copy to HL
;9532  cbd4      set     2,h		; convert the screen address to a color address
	    clc
	    adc #$400
	    tax
	    sep #$20

;9534  3a7e44    ld      a,(#447e)	; load A with the graphic for power pellets
	    lda |palette_ram+$7e
;9537  be        cp      (hl)		; compare with value in HL
	    cmp |0,x
;9538  2002      jr      nz,#953c        ; if not zero then skip next step
	    bne :make_vis
;953a  3e00      ld      a,#00		; else A := #00 (used for clearing the power pellets every other time)
	    lda #0
:make_vis
	    pha			; temporary save clear color on stack
;953c  77        ld      (hl),a		; flash the power pellet
	    sta |0,x
	    rep #$21
;953d  eb        ex      de,hl
;953e  23        inc     hl
;953f  5e        ld      e,(hl)
;9540  23        inc     hl
;9541  56        ld      d,(hl)
	    lda |2,y
;9542  cbd2      set     2,d
	    adc #$400
	        tax
;9544  12        ld      (de),a		; flash the power pellet
	    sep #$20
	    lda 1,s
	    sta |0,x
	    rep #$21
;9545  23        inc     hl
;9546  5e        ld      e,(hl)
;9547  23        inc     hl
;9548  56        ld      d,(hl)
	    lda |4,y
;9549  cbd2      set     2,d
	    adc #$400
	        tax
;954b  12        ld      (de),a		; flash the power pellet
	    sep #$20
	    lda 1,s
	    sta |0,x
;954c  23        inc     hl
;954d  5e        ld      e,(hl)
;954e  23        inc     hl
;954f  56        ld      d,(hl)
	    rep #$21
	    lda |6,y
;9550  cbd2      set     2,d
	    adc #$400
	        tax
;9552  12        ld      (de),a		; flash the power pellet
	    sep #$20
        pla
	    sta |0,x
	    rep #$31
;9553  d1        pop     de		; restore DE
;9554  c1        pop     bc		; restore BC
;9555  3e10      ld      a,#10		; A := #10
	    lda #$10
;9557  be        cp      (hl)		; 
;9558  c9        ret     		; return (to #0906)
	    rts


;
; All the pacman RAM definitions
;
		put ram.s

;------------------------------------------------------------------------------
; ResetPills
;24c9

ResetPills mx %00
; Enable all the pills in the maze
	lda #$FFFF
	ldx #28
]lp sta |pilldata,x
	dex
	dex
	bpl ]lp

; Initialize Power Pills

	lda #$1414
	sta |powerpills
	sta |powerpills+2

	rts

;------------------------------------------------------------------------------
;
; The idea here is to take the 64 palettes that are in the pacman ROM
; and decompress them into palettes that can be directly copied into
; the vicky color RAM
;
; Each Palette is 4 colors, so it will be 16 bytes * 64 entries
; 1024 bytes
;
DecompressColors mx %00

:color = temp0

		ldx #0
]lp
		lda >palette_rom,x
		and #$FF

		jsr Pac2PhxColor

		txa
		asl
		asl
		tay

		lda <:color
		sta |color_table,y
		lda <:color+2
		sta |color_table+2,y

		inx 	  ; next color

		cpx #256  ; color 0-255
		bcc ]lp

		rts

;------------------------------------------------------------------------------
; BlitColorMap
;
; The idea here, is to manage colors in the map based on the contents of the
; palette_ram buffer
;
; The initial pass at this, all I care about is "make it work"
;
; Later both this, and the BlitMap will need to be changed to use a dirty
; system, or allow writes to be mirrors from tile_ram, and palette_ram
; in real-time, as they happen, so things like the power pills blinking
; will actually work right, and also to keep the game going 60hz
;
BlitColorMap mx %00
	; make sure all 8 palettes are available
	jsr BGPaletteAllocatorReset

	; reset fast hash table as uninitialized
	jsr PaletteHashReset

	; We want to loop through the palette_ram
	; we check to see if the palette in palette ram is in the palette_hash
	; if it is, we just take the result, and store it in the vicky
	; BGRAM
	; if it doesn't exist, we need to allocate a vicky palette
	;   (once palette is allocated, we then load the vicky color memory
	;    with the pacman colors)
	; we need to update the palette_hash
	; and then we finally store the result into the vicky VGRAM

	; eventually we need a "fast" way to translate from a tile_ram/
	; palette_ram address into a vicky address
	; so this can approach some semblance of "real-time" speed

	; let's rip off the code in the BlitMap, that iterates through
	; addresses, then we can get cracking
	

; This does the main map area

:row_offset = temp0
:cursor	    = temp1
:count      = temp2

		lda #$3A0+palette_ram
		sta <:row_offset

		ldx #64*6+{{25-14}*2}+2
]row_loop

		sta <:cursor

		lda #28
		sta <:count

]col_loop
		lda (:cursor)		
		and #$3F
		sep #$20

		tay
		lda |palette_hash,y
		bpl :good_value

		lda |:ColorReduce,y
		tay
		lda |palette_hash,y
		bpl :good_value

		rep #$30
		phx

		jsr BGPaletteAlloc
		bpl :ok
		; error, out of palettes :-/
		plx
		bra :error
:ok
		sep #$20
		pha
		asl
		asl
		asl  			; shift it over for vicky
		sta |palette_hash,y
		pla
		rep #$30

		jsr :LoadPalette

		plx
		bra ]col_loop

:good_value
		sta >VRAM+VICKY_MAP0+1,x   ; it seems like DMA could work here?
:error
		rep #$30
		inx
		inx

		; increment cursor
		sec
		lda <:cursor
		sbc #$20
		sta <:cursor

		dec <:count
		bne ]col_loop

		; adjust destination in tile map
		txa
		; c=0
		clc
		adc #{64*2}-{28*2}
		tax

		lda <:row_offset
		inc
		sta <:row_offset
		cmp #$3C0+palette_ram
		bcc ]row_loop

;------------------------------------------------------------------------------
; Need the Top 2 lines

; 3DF->3C0 - line 0
;		ldx #64*2+{{25-14}*2}-2	; offset into vicky
;		ldy #palette_ram+$3C0+31
;		jsr :BlitLine

; 3FF->3E0 - line 1
;		ldx #64*4+{{25-14}*2}-2	; offset into vicky
;		ldy #palette_ram+$3E0+31
;		jsr :BlitLine

;------------------------------------------------------------------------------
; Need the Bottom 2 lines

; 01F->000 - line 34
		ldx #64*{{34*2}+2}+{{25-14}*2}-2	; offset into vicky
		ldy #palette_ram+$000+31
		jsr :BlitLine
; 03F->020 - line 35
		ldx #64*{{35*2}+2}+{{25-14}*2}-2	; offset into vicky
		ldy #palette_ram+$020+31
		jsr :BlitLine

		rts

;------------------------------------------------------------------------------

:BlitLine
		sty <:cursor
		lda #32
		sta <:count
]loop
		lda (:cursor)
		and #$3F
		sep #$20

		tay
		lda |palette_hash,y
		bpl :BL_good_value

		rep #$30
		phx
		jsr BGPaletteAlloc
		bpl :BL_ok
		; error, out of palettes :-/
		plx
		bra :BL_error
:BL_ok
		sep #$20
		pha
		asl
		asl
		asl
		sta |palette_hash,y
		pla
		rep #$30

		jsr :LoadPalette

		plx
		bra ]loop

:BL_good_value
		sta >VRAM+VICKY_MAP0+1,x
:BL_error
		rep #$30
		inx
		inx
		dec <:cursor
		dec <:count
		bne ]loop

		rts

;------------------------------------------------------------------------------


; A = target palette# on Vicky
; Y = source palette# on ms pacman
:LoadPalette mx %00

	xba   ; x256
	asl   ; x512
	asl   ; x1024
	tax

	tya
	asl
	asl
	asl
	asl
	tay

	lda |color_table+4,y
	sta >GRPH_LUT0_PTR+4,x
	lda |color_table+6,y
	sta >GRPH_LUT0_PTR+6,x
	lda |color_table+8,y
	sta >GRPH_LUT0_PTR+8,x
	lda |color_table+10,y
	sta >GRPH_LUT0_PTR+10,x
	lda |color_table+12,y
	sta >GRPH_LUT0_PTR+12,x
	lda |color_table+14,y
	sta >GRPH_LUT0_PTR+14,x

	rts

;
; For each of the 64 palettes, this will have an index
; to the lowest duplicate palette
; 
; This is to work around the map data using more than 8 palettes
; many of the "different" palettes are not unique, so hoping to fix
; this here
; 
:ColorReduce
	db 0  ; 0->0
	db 1  ; 1->1
	db 0  ; 2->0
	db 3  ; 3->3
	db 0  ; 4->0
	db 5  ; 5->5
	db 0  ; 6->0
	db 7  ; 7->7
	db 0  ; 8->0
	db 9  ; 9->9
	db 0  ;10->0 
	db 0  ;11->0 
	db 0  ;12->0 
	db 0  ;13->0 
	db 14 ;14->14
	db 15 ;15->15
	db 16 ;16->16
	db 17 ;17->17
	db 18 ;18->18
	db 0  ;19->0
	db 20 ;20->20
	db 21 ;21->21
	db 22 ;22->22
	db 23 ;23->23
	db 24 ;24->24
	db 25 ;25->25
	db 16 ;26->16
	db 16 ;27->16
	db 0  ;28->0
	db 29 ;29->29
	db 30 ;30->30
	db 31 ;31->31
	ds 32 ; these all map to 0

;------------------------------------------------------------------------------

PaletteHashReset mx %00

	lda #$FFFF
	sta |palette_hash
	ldx #palette_hash+1
	ldy #palette_hash+2
	lda #64-3
	mvn ^palette_hash,^palette_hash

	rts

;------------------------------------------------------------------------------
;
; Stack based palette allocator functions
;
NUM_ALLOCATABLE_BG_PALETTES equ 8

BGPaletteAllocatorReset mx %00

	lda #NUM_ALLOCATABLE_BG_PALETTES-1
	sta |BGPalIndex
	asl
	tax
	lsr
]lp
	sta |BGPalStack,x
	dec
	dex
	dex
	bpl ]lp

	rts

BGPalIndex dw NUM_ALLOCATABLE_BG_PALETTES-1
BGPalStack ds NUM_ALLOCATABLE_BG_PALETTES*2

;------------------------------------------------------------------------------
;
; Return with a palette # in A
;
BGPaletteAlloc mx %00
	lda |BGPalIndex
	bmi :error

	asl
	tax
	lsr
	dec
	sta |BGPalIndex

	lda |BGPalStack,x
:error
	rts

;------------------------------------------------------------------------------
;
; A = palette you want to free up
;
BGPaletteFree mx %00
	tay
	lda |BGPalIndex
	inc
	cmp #NUM_ALLOCATABLE_BG_PALETTES
	bcs :error
	asl
	tax
	tya
	sta |BGPalStack,y
:error
	rts


;------------------------------------------------------------------------------
; BlitColor
;
; $$BlitMap needs to include the color palette #'s
;
BlitColor mx %00

:color = temp0
:count = temp1
; Initialize 8 Background Tile Color Palettes

		jsr GetLevelColor
		; A = the palette # to use for this maze

		asl
		asl
		tax

		stz <:count
]lp
		lda >palette_rom,x  ; color
		and #$FF

		jsr Pac2PhxColor

		phx
		lda <:count
		asl
		asl
		tax

		lda <:color
		sta >GRPH_LUT0_PTR,x
		lda <:color+2
		sta >GRPH_LUT0_PTR+2,x

		plx

		inx	; increment to next color

		lda <:count
		inc
		sta <:count   ; up to 4 colors
		cmp #4
		bcc ]lp

		rts

Pac2PhxColor mx %00

:color = temp0

		phx
		tax
		lda >color_rom,x
		pha
		asl
		asl
		xba
		and #3
		tay
		lda |:b,y
		sta <:color ; blue

		lda 1,s
		lsr
		lsr
		lsr
		and #7
		tay
		lda |:rg,y
		sta <:color+1  ; Green

		pla
		and #7
		tay
		lda |:rg,y
		and #$FF
		sta <:color+2	; red

		plx
		rts

:rg 	db 0,$21,$47,$21+$47,$97,$97+$21,$97+$47,$21+$47+$97
:b 		db 0,$51,$AE,$51+$AE



;TranslatePaletteTable
;
;; Default 16 is white palette, index 0
;
;		db 0,0,0,0,0,0,0,3	; $00-$07
;		db 0,0,0,0,0,0,0,0	; $08-$0F
;		db 0,0,4,0,5,0,0,0	; $10-$17
;		db 6,0,0,0,0,7,0,0	; $18-$1F

;------------------------------------------------------------------------------
;
; BlitMap
;
; Copy the Pacman Shadow to real VRAM
;
; This is not fast enough, it's what is keeping the game from going 60hz
; it also isn't paying any attention to color, so it needs to do more
; work, and get it done much quicker than it does now
;
; is there any way we can use DMA here?
;
; Maybe it would be best, to just write values immediately when they
; are written on the real HW?
;
BlitMap mx %00

; This does the main map area

:row_offset = temp0
:cursor	    = temp1
:count      = temp2

		lda #$3A0+tile_ram
		sta <:row_offset

		ldx #64*6+{{25-14}*2}+2
]row_loop

		sta <:cursor

		lda #28
		sta <:count

]col_loop
		sep #$21
		lda (:cursor) 	 ; this is doing a load/store

		sta >VRAM+VICKY_MAP0,x   ; it seems like DMA could work here?
		rep #$30
		inx
		inx

		; increment cursor
		; c=1
		lda <:cursor
		sbc #$20
		sta <:cursor

		dec <:count
		bne ]col_loop

		; adjust destination in tile map
		txa
		; c=0
		clc
		adc #{64*2}-{28*2}
		tax

		lda <:row_offset
		inc
		sta <:row_offset
		cmp #$3C0+tile_ram
		bcc ]row_loop

;------------------------------------------------------------------------------
; Need the Top 2 lines

		phb
		pea >{VRAM+VICKY_MAP0}
		plb
		plb

; 3DF->3C0 - line 0
		ldy #64*2+{{25-14}*2}-2	; offset into vicky
		ldx #tile_ram-MyDP+$3C0
		jsr :BlitLine

; 3FF->3E0 - line 1
		ldy #64*4+{{25-14}*2}-2	; offset into vicky
		ldx #tile_ram-MyDP+$3E0
		jsr :BlitLine

;------------------------------------------------------------------------------
; Need the Bottom 2 lines

; 01F->000 - line 34
		ldy #64*{{34*2}+2}+{{25-14}*2}-2	; offset into vicky
		ldx #tile_ram-MyDP+$000
		jsr :BlitLine
; 03F->020 - line 35
		ldy #64*{{35*2}+2}+{{25-14}*2}-2	; offset into vicky
		ldx #tile_ram-MyDP+$020
		jsr :BlitLine

		plb

;------------------------------------------------------------------------------
; temp test code

		lda |level
		ldx #VICKY_MAP0+{64*2}+4
		jsr PrintHex

		lda |PATH
		ldx #VICKY_MAP0+{64*2*33}+4
		jsr PrintHex

		lda |COUNT
		ldx #VICKY_MAP0+{64*2*34}+4
		jsr PrintHex

		lda |BCNT
		ldx #VICKY_MAP0+{64*2*35}+4
		jsr PrintHex

		jsr DebugKeyboard

		rts

:BlitLine
		sep #$20    ; short a
]count  =  0
		lup 32
		lda <$1F-]count,x
		sta |VRAM+VICKY_MAP0+{]count*2},y
]count = ]count+1
		--^

		rep #$31    ; mxc=0
		rts

;------------------------------------------------------------------------------

PrintHex 	mx %00

		phkb ^{VRAM+VICKY_MAP0}
		plb

		pha		; hex we're going to print

		xba
		lsr
		lsr
		lsr
		lsr
		and #$F
		ora #TILE_Pal1
		sta |0,x 	; High Digit

		lda 1,s
		xba
		and #$000F
		ora #TILE_Pal1
		sta |2,x    	; Next Digit

		lda 1,s
		and #$00F0      ; second from last
		lsr
		lsr
		lsr
		lsr
		ora #TILE_Pal1
		sta |4,x

		pla
		and #$000F	; last digit
		ora #TILE_Pal1
		sta |6,x

		;$$JGA TEMP HACK, to work around color bug in Vicky
		lda #TILE_Pal1+$40
		sta |8,x

		plb

		rts

;------------------------------------------------------------------------------

PrintHexSmall 	mx %00

		phkb ^{VRAM+VICKY_MAP0}
		plb

		pha		; hex we're going to print

		lda 1,s
		and #$00F0      ; second from last
		lsr
		lsr
		lsr
		lsr
		ora #TILE_Pal1
		sta |0,x

		pla
		and #$000F	; last digit
		ora #TILE_Pal1
		sta |2,x

		;$$JGA TEMP HACK, to work around color bug in Vicky
		lda #TILE_Pal1+$40
		sta |4,x

		plb

		rts


;------------------------------------------------------------------------------
;
; The status of up to 128 keys on the keyboard
;
keyboard ds 128

;------------------------------------------------------------------------------

DebugKeyboard mx %00
;		php
;		sei 

HISTORY_SIZE = 32

	; Collect Scancodes, but only when they change
	; place into a history buffer
	; print out the history buffer onto the screen
	; for the world to see
]key_loop
		jsl GETSCANCODE
		and #$FF
		beq :exit
		cmp |:last_code
		beq :exit       	; duplicate code, so ignore

		sta |:last_code		; last code, for the duplicate check

	; hack in the actual keyboard driver?

		sep #$30
		tay
		and #$7F
		tax
		tya
		bpl :keydown
		lda #$00  		; key-up
:keydown
		sta |keyboard,x

; we sometimes miss key-up events, so lets "fix" that by
; making sure conflicting keys are not pressed
		cmp #KEY_UP
		bne :not_up
		stz |keyboard+KEY_DOWN ; press up, clear down
:not_up
		cmp #KEY_DOWN
		bne :not_down
		stz |keyboard+KEY_UP ; press down, clear up
:not_down
		cmp #KEY_LEFT
		bne :not_left
		stz |keyboard+KEY_RIGHT ; press left, clear right
:not_left
		cmp #KEY_RIGHT
		bne :not_rt
		stz |keyboard+KEY_LEFT ; when we press right, clear left
:not_rt

		
		tya
		rep #$30

	; done with the hack

		ldx |:index     	; current index
		sta |:history,x 	; save in history
		dex
		dex     		; next index
		bpl :continue
		ldx #{HISTORY_SIZE*2}-2 ; index wrap
:continue
		stx |:index     	; save index for next time

		bra ]key_loop

	; print out the current history

;		txy

;		ldx #VICKY_MAP0+{64*6}+4
;]loop
;		iny
;		iny
;		cpy #HISTORY_SIZE*2
;		bcc :cont2
;		ldy #0
;:cont2
;		cpy |:index
;		beq :exit

;		lda |:history,y
;		jsr PrintHexSmall

;		txa
;		clc
;		adc #64*2
;		tax
;		bra ]loop
:exit
;		plp
		rts


:index		dw 0
:last_code	dw 0

:history	ds HISTORY_SIZE*2

;------------------------------------------------------------------------------
;
DebugTimedTasks mx %00
:pTask = temp0
:loop_count = temp1

:vram_address = temp2

	lda #VICKY_MAP0+{64*6}+{44*2}
	sta <:vram_address

	lda #16
	sta <:loop_count

	lda #irq_tasks
	sta <:pTask

]loop
	ldx <:vram_address
	lda (:pTask)
	inc <:pTask
	inc <:pTask
	xba
	jsr PrintHex
	clc
	txa
	adc #{4*2}
	tax
	lda (:pTask)
	inc <:pTask
	jsr PrintHexSmall

	clc
	lda <:vram_address
	adc #64*2
	sta <:vram_address

	dec <:loop_count
	bne ]loop

	rts

;------------------------------------------------------------------------------

; Voice Structure Layout
    dum 0
vo_wave_no	ds 2   ; 0-7
vo_volume	ds 2   ; 0-F
vo_frequency	ds 4   ; 20 bits resolution
vo_accumulator	ds 4   ; 20 bits accumulator
vo_size ds 0
    dend
;------------------------------------------------------------------------------
;
DebugAudio mx %00

; I don't know, try to scrap mspac audio registers, convert into
; something that the cpu can more easily deal with?

	sep #$30
	lda |HW_V0_VOL
	sta |{:v0+vo_volume}
	lda |HW_V1_VOL
	sta |{:v1+vo_volume}
	lda |HW_V2_VOL
	sta |{:v2+vo_volume}

	lda |HW_WAVESELECT_0
	sta |{:v0+vo_wave_no}
	lda |HW_WAVESELECT_1
	sta |{:v1+vo_wave_no}
	lda |HW_WAVESELECT_1
	sta |{:v1+vo_wave_no}

	rep #$30

;--- BEGIN V0
	lda |HW_V0_FREQ3
	and #$F
	asl
	asl
	asl
	asl
	sta <temp0
	lda |HW_V0_FREQ2
	and #$F
	ora <temp0
	asl
	asl
	asl
	asl
	sta <temp0
	lda |HW_V0_FREQ1
	and #$F
	ora <temp0
	asl
	asl
	asl
	asl
	sta <temp0
	lda |HW_V0_FREQ0
	ora <temp0
	sta |{:v0+vo_frequency}

	lda |HW_V0_FREQ4
	and #$F
	sta |{:v0+vo_frequency}+2
;--- END V0

;--- BEGIN V1
	lda |HW_V1_FREQ3
	and #$F
	asl
	asl
	asl
	asl
	sta <temp0
	lda |HW_V1_FREQ2
	and #$F
	ora <temp0
	asl
	asl
	asl
	asl
	sta <temp0
	lda |HW_V1_FREQ1
	and #$F
	ora <temp0
	asl
	asl
	asl
	asl
	sta |{:v1+vo_frequency}

	lda |HW_V1_FREQ4
	and #$F
	sta |{:v1+vo_frequency}+2
;--- END V1

;--- BEGIN V2
	lda |HW_V2_FREQ3
	and #$F
	asl
	asl
	asl
	asl
	sta <temp0
	lda |HW_V2_FREQ2
	and #$F
	ora <temp0
	asl
	asl
	asl
	asl
	sta <temp0
	lda |HW_V2_FREQ1
	and #$F
	ora <temp0
	asl
	asl
	asl
	asl
	sta |{:v2+vo_frequency}

	lda |HW_V2_FREQ4
	and #$F
	sta |{:v2+vo_frequency}+2
;--- END V2


	ldx #VICKY_MAP0+{64*6}+{44*2}
	ldy #0
]loop	lda |:voices+vo_wave_no,y
	jsr PrintHexSmall
	jsr :next_line

	lda |:voices+vo_volume,y
	jsr PrintHexSmall
	jsr :next_line

	lda |:voices+vo_frequency+2,y
	Jsr PrintHexSmall
	lda |:voices+vo_frequency,y
	inx
	inx
	inx
	inx
	jsr PrintHex
	dex
	dex
	dex
	dex
	jsr :next_line

	; next voice
	tya
	clc
	adc #vo_size
	tay
	cpy #{vo_size*3}
	bcc ]loop


	rts

:next_line
	;next line
	txa
	clc
	adc #{64*2}
	tax
	rts

:voices
:v0	ds vo_size
:v1	ds vo_size
:v2	ds vo_size

;------------------------------------------------------------------------------
;
; Look at Mouse Stuff
;
DebugMouse mx %00

	lda >MOUSE_PTR_CTRL_REG_L
	ldx #VICKY_MAP0+{64*6}+{2*2}
	jsr PrintHex

	lda >MOUSE_PTR_X_POS_L
	ldx #VICKY_MAP0+{64*8}+{2*2}
	jsr PrintHex

	lda >MOUSE_PTR_Y_POS_L
	ldx #VICKY_MAP0+{64*10}+{2*2}
	jsr PrintHex

	lda >MOUSE_PTR_BYTE0
	ldx #VICKY_MAP0+{64*12}+{2*2}
	jsr PrintHex

	lda >MOUSE_PTR_BYTE2
	ldx #VICKY_MAP0+{64*14}+{2*2}
	jsr PrintHex



	rts

;------------------------------------------------------------------------------
;
; 9580
GetLevelColor mx %00
;		beq :done
; check task $$TODO fix this
;

; controls the color of the mazes

; 9590
		lda |level  ; get level #
		cmp #21		; compare to 21
		bcs	:mod_range  ; >= modify range
:cont
		tax
		lda |:palette_table,x
		and #$FF
:done
		rts

;95A3
:mod_range
		sec
		sbc #21		; subtract 21
]mod_loop
		sec
		sbc #17
		bpl ]mod_loop
		clc
		adc #21
		bra :cont

;------------------------------------------------------------------------------

	;; color palette table for the first 21 mazes ($0F)
;$95AE
:palette_table
		db	$1d,$1d				; color code for levels 1 and 2
		db  $16,$16,$16			; color code for levels 3, 4, 5
		db  $14,$14,$14,$14		; color code for levels 6 - 9
		db  $07,$07,$07,$07		; color code for levels 10 - 13
		db  $18,$18,$18,$18		; color code for levels 14 - 17
		db  $1d,$1d,$1d,$1d 	; color code for levels 18 - 21


;------------------------------------------------------------------------------
; main routine #3.  arrive here at the start of the game when a new game is started
; arrive from #04E5 or #06C1
;0879
game_init mx %00
;0879  21094e    ld      hl,#4e09	; load HL with player # address
;087c  af        xor     a		; A := #00
;087d  060b      ld      b,#0b		; set counter to #0B
;087f  cf        rst     #8		; clear memories from #4E09 through #4E09 + #0B
			stz |player_no
			stz |pDifficulty
			stz |FIRSTF
			stz |SECONDF
			stz |dotseat
			stz |all_home_counter
			stz |blue_home_counter
			stz |orange_home_counter
			stz |pacman_dead
			stz |level
			;stz |num_lives       ; $$JGA seems like these should not be cleared
			;stz |displayed_lives

;0880  cdc924    call    #24c9		; set up pills and power pills in RAM
			jsr ResetPills

;0883  2a734e    ld      hl,(#4e73)	; load HL with difficulty
			lda |p_difficulty
;0886  220a4e    ld      (#4e0a),hl	; store difficulty
			sta |pDifficulty

		   ; unsure why we need this, circle back
		   ; $$JGA TODO
;0889  210a4e    ld      hl,#4e0a	; load source with difficulty
;088c  11384e    ld      de,#4e38	; load destination with difficulty
;088f  012e00    ld      bc,#002e	; set byte counter at #2E
;0892  edb0      ldir    		; copy

;------------------------------------------------------------------------------
; arrive here from #09CF
; this is also timed task #00, arrive from #0246
;0894
ttask0 mx %00

;0894  21044e    ld      hl,#4e04	; load HL with main subroutine number
;0897  34        inc     (hl)		; increment
;0898  c9        ret     		; return
			inc |levelstate
			rts

;------------------------------------------------------------------------------
; arrive from #06C1
;0899
game_setup mx %00
;0899  3a004e    ld      a,(#4e00)	; load A with game mode
			lda |mainstate
;089c  3d        dec     a		; are we in the demo mode ?
			dec
;089d  2006      jr      nz,#08a5        ; no, skip ahead
			bne :not_demo

;089f  3e09      ld      a,#09		; yes, load A with #09
			lda #9
;08a1  32044e    ld      (#4e04),a	; store in main subroutine
			sta |levelstate
;08a4  c9        ret    			; return 
			rts
:not_demo
;08a5  ef        rst     #28		; insert task #11 - clears memories from #4D00 through #4DFF
;08a6  11 00
			lda #$0011
			jsr rst28
;08a8  ef        rst     #28		; insert task #1C, parameter #83 - displays or clears text
;08a9  1c 83
			lda #$831c
			jsr rst28
;08ab  ef        rst     #28		; insert task #04 - resets a bunch of memories and
;08ac  04 00
			lda #$0004
			jsr rst28
;08ae  ef        rst     #28		; insert task #05 - resets ghost home counter
;08af  05 00
			lda #$0005
			jsr rst28
;08b1  ef        rst     #28		; insert task #10 - sets up difficulty
;08b2  10 00
			lda #$0010
			jsr rst28

;08b4  ef        rst     #28		; insert task #1A - draws remaining lives at bottom of screen
;08b5  1a 00
			lda #$001a
			jsr rst28

;08b7  f7        rst     #30		; set timed task to increase the main subroutine number (#4E04)
;08b8  54 00 00				; task timer=#54, task=0, param=0    
			lda #$0054
			ldy #$00
			jsr rst30

;08bb  f7        rst     #30		; set timed task to clear the "READY!" message
;08bc  54 06 00				; task timer=#54, task=6, param=0
			lda #$0654
			ldy #$00
			jsr rst30


;08bf  3a724e    ld      a,(#4e72)	; load A with cocktail or upright
;08c2  47        ld      b,a		; copy to B
;08c3  3a094e    ld      a,(#4e09)	; load A with current player #
;08c6  a0        and     b		; is this game cockatil mode and player # 2 ? If so , this value becomes 1
;08c7  320350    ld      (#5003),a	; store into flip screen register
;08ca  c39408    jp      #0894		; loop back to increment level complete register and return
			bra ttask0

;------------------------------------------------------------------------------
; demo or game is playing
;
; 08CD;
game_playing mx %00
		; yes we get here
		; test if we get here
		;lda #Mstr_Ctrl_Disable_Vid
		;sta >MASTER_CTRL_REG_L 
;		nop
;		nop
;		nop
;]wait   bra ]wait
;		nop
;		nop
;		nop


;
; In original code, rack test stuff, that I didn't port
;
;	    lda |dotseat 	; number of dots player has eaten

; check to see if the board is cleared
;
; 94a1
	    lda #PelletCountTable
	    sta <temp0

	    jsr ChooseMaze

	    tax			; Address of the pellet count

	    sep #$20

	    lda |dotseat  ; number of dots player has eaten!
	    cmp |0,x
	    rep #$30
	    bcc :not_done

;08e5
; 	  level complete
;
		; $$TODO ENUM?
	    lda #12        	; signal end of level
	    sta |levelstate

	    rts

:not_done

	; core game loop

;08eb  cd1710    call    #1017		; another core game loop that does many things
	    jsr pm1017
;08ee  cd1710    call    #1017		; another core game loop that does many things
	    jsr pm1017
;08f1  cddd13    call    #13dd		; check for release of ghosts from ghost house
	    jsr ghosthouse
;08f4  cd420c    call    #0c42		; adjust movement of ghosts if moving out of ghost house
	    jsr ghost_house_movement

;08f7  cd230e    call    #0e23		; change animation of ghosts every 8th frame
	    jsr animate_ghosts

;08fa  cd360e    call    #0e36		; periodically reverse ghost direction based on difficulty (only when energizer not active)
	    jsr reverse_ghosts

;08fd  cdc30a    call    #0ac3		; handle ghost flashing and colors when power pills are eaten
	    jsr ghost_flashing

;0900  cdd60b    call    #0bd6		; color dead ghosts the correct colors
	    jsr set_dead_color

;0903  cd0d0c    call    #0c0d		; handle power pill (dot) flashes
	    jsr flash_power

;0906  cd6c0e    call    #0e6c		; change the background sound based on # of pills eaten
	    jsr change_sound_pills

;0909: CDAD0E	 call	 #0EAD		; check for fruit to come out.  (new ms. pac sub actually at #86EE.)
	    jsr DOFRUIT

	    rts   			; return ( to #0195 ) 

;------------------------------------------------------------------------------
; arrive here from #06C1 when player has died
;090d
player_die mx %00
;090d  3e01      ld      a,#01		; A := #01
		lda #1
;090f  32124e    ld      (#4e12),a	; store into player dead flag
		sta |pacman_dead

;	4e12	1 after dying in a level, reset to 0 if ghosts have left home
;		because of 4d9f

;0912  cd8724    call    #2487		; save pellet info to memory
		jsr task_updatePills

;0915  21044e    ld      hl,#4e04	; load HL with main subroutine number
;0918  34        inc     (hl)		; increase it
		inc |levelstate

;0919  3a144e    ld      a,(#4e14)	; load A with number of lives left
		lda |num_lives
;091c  a7        and     a		; == #00 ?
;091d  201f      jr      nz,#093e        ; no, skip ahead
		bne :keep_playing

		; Game Over 
;091f  3a704e    ld      a,(#4e70)	; else game over.  load A with number of players (0=1 player, 1=2 players)
		lda |no_players
;0922  a7        and     a		; is this a one player game?
;0923  2819      jr      z,#093e         ; yes, skip ahead
		beq :one_player_game

		; $$JGA TODO
;0925  3a424e    ld      a,(#4e42)	; else load A with game state
;0928  a7        and     a		; is this the demo mode ?
;0929  2813      jr      z,#093e         ; yes, skip ahead
		lda |backup_num_lives
		beq :keep_playing

;092b  3a094e    ld      a,(#4e09)	; else load A with current player number:  0=P1, 1=P2
		lda |player_no
;092e  c603      add     a,#03		; add #03, result is either #03 or #04
		clc
		adc #3
;0930  4f        ld      c,a		; store into C for call below
		xba
		and #$FF00
;0931  061c      ld      b,#1c		; load B with #1C for task call below
		ora #$1C
;0933  cd4200    call    #0042		; insert task to draw to screen either "PLAYER ONE" or "PLAYER TWO"
		jsr task_add
;0936  ef        rst     #28		; insert task to draw "GAME OVER"
;0937  1c 05
		lda #$051c
		jsr rst28
;0939  f7        rst     #30		; set timed task to increase the main subroutine number (#4E04)
;093a  54 00 00				; task timer=#54, task=0, param=0    
		lda #$0054
		ldy #$00
		jsr rst30
;093d  c9        ret     		; return
		rts
:one_player_game
:keep_playing
;093e  34        inc     (hl)		; increase game state
		inc |levelstate
;093f  c9        ret     		; return
		rts


;------------------------------------------------------------------------------
; arrive from #06C1
;0940
gameover_check mx %00
;0940  3a704e    ld      a,(#4e70)	; load A with number of players
	lda |no_players
;0943  a7        and     a		; == #00 ?
;0944  2806      jr      z,#094c         ; yes, skip ahead if 1 player
	beq :zero
;0946  3a424e    ld      a,(#4e42)	; else load A with game state 
;0949  a7        and     a		; is a game being played ?
;094a  2015      jr      nz,#0961        ; yes, skip ahead and switch from player 1 to player 2 or vice versa
	lda |backup_num_lives
	bne :two_player_game

:zero
;094c  3a144e    ld      a,(#4e14)	; else load A with number of lives left
;094f  a7        and     a		; are there any lives left ?
;0950  201a      jr      nz,#096c        ; yes, jump ahead
	lda |num_lives
	bne :lives_left

	; change 0950 to 
	; 0950  18 1a		jr	#096C 	; always jump ahead 
	; for never-ending pac goodness


;0952  cda12b    call    #2ba1		; else draw # credits or free play on bottom of screen
	jsr task_drawCredits

;0955  ef        rst     #28		; insert task #1C , parameter #05 .  Draws text on screen "GAME OVER"
;0956  1c 05				; task data
	lda #$051C
	jsr rst28

;0958  f7        rst     #30		; set timed task to increase main subroutine number (#4E04)
;0959  54 00 00    			; task timer=#54, task=0, param=0
	lda #$0054
	ldy #$00
	jsr rst30

;095c  21044e    ld      hl,#4e04	; Load HL with level state subroutine #
;095f  34        inc     (hl)		; increment
	inc |levelstate
;0960  c9        ret     		; return
	rts

; arrive here from #094a when there 2 players, when a player dies
:two_player_game
;0961  cda60a    call    #0aa6		; transposes data from #4e0a through #4e37 into #4e38 through #4e66
;0964  3a094e    ld      a,(#4e09)	; load A with current player number:  0=P1, 1=P2
;0967  ee01      xor     #01		; flip bit 0
;0969  32094e    ld      (#4e09),a	; store result.  toggles between player 1 and 2
:lives_left
;096c  3e09      ld      a,#09		; A := #09
;096e  32044e    ld      (#4e04),a	; store into level state subroutine #
	lda #9
	sta |levelstate
;0971  c9        ret     		; return
	rts

;------------------------------------------------------------------------------
; arrive from #06C1 when subroutine# (#4E04)= #08
; zeros some important variables
; arrive here after demo mode finishes (ms pac man dies in demo)
;0972
end_demo mx %00
;0972  af        xor     a		; A := #00
;0973  32024e    ld      (#4e02),a	; clear main routine 1, subroutine #
		stz |mainroutine1
;0976  32044e    ld      (#4e04),a	; clear level state subroutine #
		stz |levelstate
;0979  32704e    ld      (#4e70),a	; clear number of players
		stz |no_players
;097c  32094e    ld      (#4e09),a	; clear current player number
		stz |player_no
;097f  320350    ld      (#5003),a	; clear flip screen register
;0982  3e01      ld      a,#01		; A := #01
;0984  32004e    ld      (#4e00),a	; set game mode to demo
		lda #1
		sta |mainstate
;0987  c9        ret     		; return (to #057F)
		rts

;------------------------------------------------------------------------------
; arrive from #06C1 when (#4E04==#09)  when marquee mode ends or after player has been killed
; or from #06C1 when (#4E04 == #20) when a level has ended and a new one is about to begin
;0988
ready_go mx %00
; We are getting here at least
;		lda #Mstr_Ctrl_Disable_Vid
;		sta >MASTER_CTRL_REG_L

;0988  ef        rst     #28		; set task #00, parameter = #01. - clears the maze
;0989  00 01
		lda #$0100
		jsr rst28

;098b  ef        rst     #28		; set task #01, parameter = #01. - colors the maze
;098c  01 01
		lda #$0101
		jsr rst28

;098e  ef        rst     #28		; set task #02, parameter = #00. - draws the maze
;098f  02 00
		lda #$0002
		jsr rst28

;0991  ef        rst     #28		; set task #11, parameter = #00. - clears memories from #4D00 through #4DFF
;0992  11 00
		lda #$0011
		jsr rst28

;0994  ef        rst     #28		; set task #13, parameter = #00. - clears the sprites
;0995  13 00
		lda #$0013
		jsr rst28

;0997  ef        rst     #28		; set task #03, parameter = #00. - draws the pellets
;0998  03 00
		lda #$0003
		jsr rst28

;099a  ef        rst     #28		; set task #04, parameter = #00. - resets a bunch of memories
;099b  04 00
		lda #$0004
		jsr rst28

;099d  ef        rst     #28		; set task #05, parameter = #00. - resets ghost home counter
;099e  05 00
		lda #$0005
		jsr rst28

;09a0  ef        rst     #28		; set task #10, parameter = #00. - sets up difficulty
;09a1  10 00
		lda #$0010
		jsr rst28

;09a3  ef        rst     #28		; set task #1A, parameter = #00. - draws remaining lives at bottom of screen
;09a4  1a 00
		lda #$001a
		jsr rst28

;09a6  ef        rst     #28		; set task #1C, parameter = #06. Draws text on screen "READY!" and clears the intermission indicator
;09a7  1c 06
		lda #$061c
		jsr rst28

;09a8  3a004e    ld      a,(#4e00)	; load A with game state
		lda |mainstate
;09ac  fe03      cp      #03		; is someone playing ?
		cmp #3
;09ae  2806      jr      z,#09b6         ; Yes, skip ahead
		beq :yes_playing

;09b0  ef        rst     #28		; set task #1C, parameter = #05.  Draws text on screeen "GAME OVER"
;09b1  1c 05
		lda #$051c
		jsr rst28

;09b3  ef        rst     #28		; set task #1D - write # of credits on screen
;09b4  1d 00
		lda #$001d
		jsr rst28

:yes_playing
;09b6  f7        rst     #30		; set timed task to increase main subroutine number (#4E04)
;09b7  54 00 00				; taks timer = #54, task = 00, parameter = 00    
		lda #$0054
		ldy #$00
		jsr rst30

;09ba  3a004e    ld      a,(#4e00)	; load A with game sate
;09bd  3d        dec     a		; is this the demo mode ?
		lda |mainstate
		dec
;09be  2804      jr      z,#09c4         ; yes, skip next step
		beq :is_demo

;09c0  f7        rst     #30		; set timed task to clear the "READY!" text from the screen
;09c1  54 06 00				; timer = #54, task = 6, parameter = 00
		lda #$0654
		ldy #$00
		jsr rst30

:is_demo
;09c4  3a724e    ld      a,(#4e72)	; load A with cocktail mode (0=no, 1=yes)
;09c7  47        ld      b,a		; copy to B
;09c8  3a094e    ld      a,(#4e09)	; load A with current player #
;09cb  a0        and     b		; mix together
;09cc  320350    ld      (#5003),a	; flip screens if player 2 in cocktail mode, else screen is set upright
;09cf  c39408    jp      #0894		; increase main routine # and return from sub
		jmp ttask0

;------------------------------------------------------------------------------
; called after marquee mode is done during demo
; called from #06C1 when (#4E04 == #0B)
;09d2
start_demo mx %00

;09d2  3e03      ld      a,#03		; A := #03
		lda #3  					; ghost move
;09d4  32044e    ld      (#4e04),a	; store into main routine #.  signals the maze part of game is on
		sta |levelstate
;09d7  c9        ret     		; return
		rts

;------------------------------------------------------------------------------
; called from #06C1 when (#4E04 == #0C)
; arrive here at end of level
;09d8
clear_sounds mx %00
;09d8  f7        rst     #30		; set timed task to increase main subroutine number (#4E04)
;09d9  54 00 00    			; timer = #54, task = #00, parameter = #00
		lda #$0054
		ldy #$00
		jsr rst30

;09DC: 21 04 4E	ld	hl,#4E04	; load HL with game subroutine #
;09DF: 34	inc	(hl)		; increase 
		inc |levelstate

;09E0: AF	xor	a		; A := #00
;09E1: 32 AC 4E	ld	(#4EAC),a	; clear sound channel 2
		stz |CH2_E_NUM
;09E4: 32 BC 4E	ld	(#4EBC),a	; clear sound channel 3
		stz |CH3_E_NUM
;09E7: C9	ret			; return   
		rts

;------------------------------------------------------------------------------
; Called from #06C1 when (#4E04 == #0E)
;09e8
flash_screen mx %00
;09e8  0e02      ld      c,#02		; C := #02
		lda #$200
flash_screen2 mx %00
;09ea  0601      ld      b,#01		; B := #01
		and #$FF00
		ora #$0001
;09ec  cd4200    call    #0042		; set task #01 with parameter #02, or task #01 with parameter #00
		jsr task_add

;09ef  f7        rst     #30		; set timed task to increase main subroutine number (#4E04)
;09f0  42 00 00				; timer = #42, task = #00, parameter = #00
		lda #$0042
		ldy #$00
		jsr rst30

;09f3  210000    ld      hl,#0000	; clear HL
;09f6  cd7e26    call    #267e		; clears all ghosts from screen
		jsr clear_ghosts

;09f9  21044e    ld      hl,#4e04	; load HL with game subroutine #
;09fc  34        inc     (hl)		; increase
		inc |levelstate
;09fd  c9        ret     		; return
		rts

flash_off 	lda #$0
		bra flash_screen2

;------------------------------------------------------------------------------
; arrive here at end of level after screen has flashed several times
; called from #06C1 when (#4E04 == #14)
;0a0e
after_flash mx %00
;0a0e  ef        rst     #28		; insert task #00, parameter #01 - clears the maze
;0a0f  00 01
		lda #$0100
		jsr rst28

;0a11  ef        rst     #28		; insert task #06, parameter #00 - clears the color RAM
;0a12  06 00
		lda #$0006
		jsr rst28

;0a14  ef        rst     #28		; insert task #11, parameter #00 - clears memories from #4D00 through #4DFF
;0a15  11 00
		lda #$0011
		jsr rst28

;0a17  ef        rst     #28		; insert task #13, parameter #00 - clears the sprites
;0a18  13 00
		lda #$0013
		jsr rst28

;0a1a  ef        rst     #28		; insert task #04, parameter #01 - resets a bunch of memories
;0a1b  04 01
		lda #$0104
		jsr rst28

;0a1d  ef        rst     #28		; insert task #05, parameter #01 - resets ghost home counter
;0a1e  05 01
		lda #$105
		jsr rst28

;0a20  ef        rst     #28		; insert task #10, parameter #13 - sets up difficulty
;0a21  10 13
		lda #$1310
		jsr rst28

;0a23  f7        rst     #30		; set timed task to increase main subroutine number (#4E04)
;0a24  43 00 00     			; task timer = #43, task #00, parameter #00
		lda #$0043
		ldy #$00
		jsr rst30

;0a27  21044e    ld      hl,#4e04	; load HL with main subroutine number
;0a2a  34        inc     (hl)		; increase subroutine number
		inc |levelstate
;0a2b  c9        ret     		; return
		rts

;------------------------------------------------------------------------------
; arrive here at end of level
; called from #06C1 when (#4E04 == #16)
; clear sounds and run intermissions when needed
;0A2C
end_level mx %00
;0A2C: AF            xor  a		; A := #00
;0A2D: 32 AC 4E      ld   (#4EAC),a	; clear sound channel #2
;0A30: 32 BC 4E      ld   (#4EBC),a	; clear sound channel #3
	sep #$20
	stz |CH2_E_NUM
	stz |CH3_E_NUM
;0A33: 18 06         jr   #0A3B		; skip next 2 steps

; junk from pac-man
;0A35: 32CC4E	ld	(#4ECC),a	
;0A38: 32DC4E	ld	(#4EDC),a
	rep #$30
;0a3b  3a134e    ld      a,(#4e13)	; load A with current board level
	lda |level
;0a3e  fe14      cp      #14		; > #14 ?
	cmp #$14
;0a40  3802      jr      c,#0a44         ; no, skip next step
	bcc :less
;0a42  3e14      ld      a,#14		; else load A with #14
	lda #$14
:less
;0a44  e7        rst     #20		; jump based on A
	asl
	tax
	jmp (:table,x)

	; jump table to control when cutscenes occur
:table
	da next_state ; #0A6F ; increment level state and stop sound
	da cutscene1  ; #2108 ; cut scene 1
	da next_state ; #0A6F ; increment level state and stop sound
	da next_state ; #0A6F ; increment level state and stop sound
	da cutscene2  ; #219E ; cut scene 2
	da next_state ; #0A6F ; increment level state and stop sound
	da next_state ; #0A6F ; increment level state and stop sound
	da next_state ; #0A6F ; increment level state and stop sound
	da cutscene3  ; #2297 ; cut scene 3
	da next_state ; #0A6F ; increment level state and stop sound
	da next_state ; #0A6F ; increment level state and stop sound
	da next_state ; #0A6F ; increment level state and stop sound
	da cutscene3  ; #2297 ; cut scene 3
	da next_state ; #0A6F ; increment level state and stop sound
	da next_state ; #0A6F ; increment level state and stop sound
	da next_state ; #0A6F ; increment level state and stop sound
	da cutscene3  ; #2297 ; cut scene 3
	da next_state ; #0A6F ; increment level state and stop sound
	da next_state ; #0A6F ; increment level state and stop sound
	da next_state ; #0A6F ; increment level state and stop sound
	da next_state ; #0A6F ; increment level state and stop sound

	; increment level state and stop sound
next_state
;0a6f  21044e    ld      hl,#4e04	; load HL with level state subroutine #
;0a72  34        inc     (hl)
;0a73  34        inc     (hl)		; increase twice
	inc |levelstate
	inc |levelstate

;0a74  af        xor     a		; A := #00
;0a75  32cc4e    ld      (#4ecc),a	; clear sound
;0a78  32dc4e    ld      (#4edc),a	; clear sound
	sep #$20
	stz |CH1_W_NUM
	stz |CH2_W_NUM
	rep #$30
;0a7b  c9        ret     		; return
	rts
;------------------------------------------------------------------------------
; we're about to start the next board, (it's about to be drawn)
; called from #06C1 when (#4E04 == #18)
;0A7C
next_board mx %00
;0a7c  af        xor     a		; A := #00
;0a7d  32cc4e    ld      (#4ecc),a	; clear sound
;0a80  32dc4e    ld      (#4edc),a	; clear sound
	sep #$20
	stz |CH1_W_NUM 
	stz |CH2_W_NUM
	rep #$30

;0a83  0607      ld      b,#07		; B := #07
;0a85  210c4e    ld      hl,#4e0c	; load HL with start address to clear
;0a88  cf        rst     #8		; clear #4e0c through #4e0c+7.  these flags are reset at beginning of each level
	stz |FIRSTF
	stz |SECONDF
	stz |dotseat
	stz |all_home_counter
	stz |blue_home_counter
	stz |orange_home_counter
	stz |pacman_dead
	;stz |level

;0a89  cdc924    call    #24c9		; set addresses #4E16 through #4E39 with #FF and #14 (pill map???)
	jsr task_setPills

;0a8c  21044e    ld      hl,#4e04	; load HL with subroutine #
;0a8f  34        inc     (hl)		; increase
	inc |levelstate


	; level 255 pac fix ; BUGFIX01 (1 of 2)
	; 0a90  c3800f	jp	#0f88      
	; 0a93  00	nop
	;


	; level 141 mspac fix ; BUGFIX02 (1 of 2)
	; 0a90  c3960f	jp	#0f96
	; 0a93  00	nop
 	;


;0a90  21134e    ld      hl,#4e13	; load HL with current board level
;0a93  34        inc     (hl)		; increment board level
	inc |level
;0a94  2a0a4e    ld      hl,(#4e0a)	; load HL with pointer to current difficulty settings (#0068 for easy, #007D for hard)
;0a97  7e        ld      a,(hl)		; load A with the result
	lda |pDifficulty
;0a98  fe14      cp      #14		; == #14 (is this already the highest difficulty?)
	cmp #$14
;0a9a  c8        ret     z		; yes, return
	beq :rts

;0a9b  23        inc     hl		; else increase difficulty
;0a9c  220a4e    ld      (#4e0a),hl	; store result
	inc
	sta |pDifficulty
:rts
;0a9f  c9        ret     		; return
	rts
; called from #06C1 when (#4E04 == #20)

;0aa0  c38809    jp      #0988		; 

; ; called from #06C1 when (#4E04 == #22)

;0aa3  c3d209    jp      #09d2		; 

; called from #0961
; transposes data from #4e0a through #4e37 into #4e38 through #4e66
; used to copy data in and out for 2 player games

;0aa6  062e      ld      b,#2e		; For B = 1 to #2E
;0aa8  dd210a4e  ld      ix,#4e0a	; load IX with group 1 start address
;0aac  fd21384e  ld      iy,#4e38	; load IY with group 2 start address

;0ab0  dd5600    ld      d,(ix+#00)	; load D with data from group 1
;0ab3  fd5e00    ld      e,(iy+#00)	; load E with data from group 2
;0ab6  fd7200    ld      (iy+#00),d	; store D into group 2
;0ab9  dd7300    ld      (ix+#00),e	; store E into group 1
;0abc  dd23      inc     ix		; next address
;0abe  fd23      inc     iy		; next address
;0ac0  10ee      djnz    #0ab0           ; next B
;0ac2  c9        ret     		; return

;------------------------------------------------------------------------------
; called from #08FD
ghost_flashing mx %00
;0ac3  3aa44d    ld      a,(#4da4)	; load A with # of ghost killed but no collision for yet [0..4]
	    lda |num_ghosts_killed
;0ac6  a7        and     a		; is there a collision ?
;0ac7  c0        ret     nz		; yes, return
	    beq :continue
	    rts

; this subroutine never gets called when the green-eyed ghost bug occurs
:continue

;0ac8  dd21004c  ld      ix,#4c00	; else load IX with start of sprites address
	; 4c00 = allsprite
;0acc  fd21c84d  ld      iy,#4dc8	; load IY with (counter used to change ghost colors under big pill effects?)
	; 4dc8 = big_pill_timer
;0ad0  110001    ld      de,#0100	; load DE with offset value of #0100.  [used at #0AE7]
;0ad3  fdbe00    cp      (iy+#00)	; compare.  is it time to flash?
	    lda |big_pill_timer
;0ad6  c2d20b    jp      nz,#0bd2	; no, decrement (IY) and return
	    bnel :dec_return

;0ad9  fd36000e  ld      (iy+#00),#0e	; else reset counter to #0E
	    lda #$0e
	    sta |big_pill_timer

;0add  3aa64d    ld      a,(#4da6)	; load A with power pill effect (1=active, 0=no effect)
;0ae0  a7        and     a		; is a power pill still active ?
	    lda	|powerpill
;0ae1  281b      jr      z,#0afe         ; no, skip ahead
	    beq :no_pp
;0ae3  2acb4d    ld      hl,(#4dcb)	; yes, load HL with counter while ghosts are blue
	    lda |ghosts_blue_timer
;0ae6  a7        and     a		; clear carry flag
;0ae7  ed52      sbc     hl,de		; subtract offset of #0100.  has this counter gone under?
;0ae9  3013      jr      nc,#0afe       ; no, skip ahead
	    cmp #$100
	    bcs :no_pp

; arrive here when ghosts start flashing after being blue
; this sub controls the flashing and the return

;0AEB: 21 AC 4E	ld	hl,#4EAC	; yes, load HL with sound 2 channel
;0AEE: CB FE	set	7,(hl)		; play sound = high frequency
	    lda #$80
	    tsb |CH2_E_NUM

;0AF0: 3E 09	ld	a,#09		; A := #09
	    lda #9
;0AF2: DD BE 0B	cp	(ix+#0b)	; compare with #4C0b = pacman color entry.  is a ghost being eaten?
	    cmp |pacmancolor
	    sta |pacmancolor
;0AF5: 20 04	jr	nz,#0AFB	; no, skip ahead
	    bne :yello

;0AF7: CB BE	res	7,(hl)		; clear sound
	    lda #$80
	    trb |CH2_E_NUM
;0AF9: 3E 09	ld	a,#09		; A := #09
:yello
;0afb  320b4c    ld      (#4c0b),a	; set pacman color to yellow
:no_pp
;0afe  3aa74d    ld      a,(#4da7)	; load A with red ghost blue flag (0=not blue)
	    lda |redghost_blue
;0b01  a7        and     a		; is red ghost blue (edible) ?
;0b02  281d      jr      z,#0b21         ; no, skip ahead and set red ghost to red
	    beq :set_red_red

;0b04  2acb4d    ld      hl,(#4dcb)	; else load HL with counter while ghosts are blue
	    lda |ghosts_blue_timer
;0b07  a7        and     a		; clear carry flag
;0b08  ed52      sbc     hl,de		; subtract offset (#0100).  has this counter gone under?
	    cmp #$100
;0b0a  3027      jr      nc,#0b33       ; no, jump ahead and check next ghost
	    bcs :chk_pink

;0b0c  3e11      ld      a,#11		; yes, A := #11
	    lda #$11
;0b0e  ddbe03    cp      (ix+#03)	; compare with red ghost color. is red ghost blue ?
	    cmp |redghostcolor
;0b11  2807      jr      z,#0b1a         ; yes, skip ahead and change his color to white
	    beq :set_red_white

;0b13  dd360311  ld      (ix+#03),#11	; no, set red ghost to blue color
	    sta |redghostcolor
;0b17  c3330b    jp      #0b33		; skip ahead and check next ghost
	    bra :chk_pink
:set_red_white
;0b1a  dd360312  ld      (ix+#03),#12	; set red ghost color to white
	    lda #$12
	    sta |redghostcolor
;0b1e  c3330b    jp      #0b33		; skip ahead and check next ghost
	    bra :chk_pink
:set_red_red
;0b21  3e01      ld      a,#01		; A := #01
	    lda #1
;0b23  ddbe03    cp      (ix+#03)	; compare with red ghost color.  is the red ghost red?
	    sta |redghostcolor
;0b26  2807      jr      z,#0b2f         ; yes, then jump ahead
;0b28  dd360301  ld      (ix+#03),#01	; set red ghost back to red
;0b2c  c3330b    jp      #0b33		; skip ahead

;0b2f  dd360301  ld      (ix+#03),#01	; set red ghost back to red
:chk_pink
;0b33  3aa84d    ld      a,(#4da8)	; load A with pink ghost blue flag
	    lda |pinkghost_blue
;0b36  a7        and     a		; is pink ghost blue (edible) ?
;0b37  281d      jr      z,#0b56        ; no, skip ahead and set pink ghost to pink
	    beq :set_pink_pink

;0b39  2acb4d    ld      hl,(#4dcb)	; else load HL with counter while ghosts are blue 
	    lda |ghosts_blue_timer
;0b3c  a7        and     a		; clear carry flag
;0b3d  ed52      sbc     hl,de		; subtract offset (#0100).  has this counter gone under?
	    cmp #$100
;0b3f  3027      jr      nc,#0b68       ; no, jump ahead and check next ghost
	    bcs :check_inky

;0b41  3e11      ld      a,#11		; A := #11
	    lda #$11
;0b43  ddbe05    cp      (ix+#05)	; compare with pink ghost color.  is the pink ghost blue?
	    cmp |pinkghostcolor
;0b46  2807      jr      z,#0b4f         ; yes, jump ahead and change his color to white
	    beq :pink_white

;0b48  dd360511  ld      (ix+#05),#11	; no, set pink ghost back to blue
	    sta |pinkghostcolor
;0b4c  c3680b    jp      #0b68		; skip ahead
	    bra :check_inky
:pink_white
;0b4f  dd360512  ld      (ix+#05),#12	; set pink ghost color to white
	    lda #$12
	    sta |pinkghostcolor
;0b53  c3680b    jp      #0b68		; skip ahead
	    bra :check_inky
:set_pink_pink
;0b56  3e03      ld      a,#03		; A := #03
	    lda #3
;0b58  ddbe05    cp      (ix+#05)	; is the pink ghost pink ?
	    sta |pinkghostcolor
;0b5b  2807      jr      z,#0b64         ; yes, skip ahead

;0b5d  dd360503  ld      (ix+#05),#03	; set pink ghost to pink
;0b61  c3680b    jp      #0b68		; jump ahead

;0b64  dd360503  ld      (ix+#05),#03	; set pink ghost to pink
:check_inky
;0b68  3aa94d    ld      a,(#4da9)	; load A with blue ghost (inky) blue flag
	    lda |blueghost_blue
;0b6b  a7        and     a		; is inky blue (edible) ?
;0b6c  281d      jr      z,#0b8b         ; no, skip ahead
	    beq :blue_not_blue

;0b6e  2acb4d    ld      hl,(#4dcb)	; else load HL with counter while ghosts are blue
	    lda |ghosts_blue_timer
;0b71  a7        and     a		; clear carry flag
;0b72  ed52      sbc     hl,de		; subtract offset (#0100).  has this counter gone under?
	    cmp #$100
;0b74  3027      jr      nc,#0b9d        ; no, jump ahead and check next ghost
	    bcs :check_orange

;0b76  3e11      ld      a,#11		; A := #11
	    lda #$11
;0b78  ddbe07    cp      (ix+#07)	; is inky blue (edible) ?
	    cmp |blueghostcolor
;0b7b  2807      jr      z,#0b84         ; yes, jump ahead and change his color to white
	    beq :make_blue_white

;0b7d  dd360711  ld      (ix+#07),#11	; no, set inky to blue color
	    sta |blueghostcolor
;0b81  c39d0b    jp      #0b9d		; skip ahead
	    bra :check_orange

:make_blue_white
;0b84  dd360712  ld      (ix+#07),#12	; set inky to white color
	    lda #$12
	    sta |blueghostcolor
;0b88  c39d0b    jp      #0b9d		; skip ahead
	    bra :check_orange
:blue_not_blue
;0b8b  3e05      ld      a,#05		; A := #05
	    lda #5
	    sta |blueghostcolor
;0b8d  ddbe07    cp      (ix+#07)	; is inky his regular color ?
;0b90  2807      jr      z,#0b99         ; yes, skip ahead

;0b92  dd360705  ld      (ix+#07),#05	; set inky to his regular color
;0b96  c39d0b    jp      #0b9d		; skip ahead

;0b99  dd360705  ld      (ix+#07),#05	; set inky to his regular color

:check_orange
;0b9d  3aaa4d    ld      a,(#4daa)	; load A with orange ghost blue flag
	    lda |orangeghost_blue
;0ba0  a7        and     a		; is orange ghost blue (edible) ?
;0ba1  281d      jr      z,#0bc0         ; no, skip ahead
	    beq :not_orange_blue

;0ba3  2acb4d    ld      hl,(#4dcb)	; else load HL with counter while ghosts are blue 
	    lda |ghosts_blue_timer
;0ba6  a7        and     a		; clear carry flag
;0ba7  ed52      sbc     hl,de		; subtract offset (#0100).  has this counter gone under?
	    cmp #$100
;0ba9  3027      jr      nc,#0bd2        ; no, jump ahead
	    bcs :dec_return

;0bab  3e11      ld      a,#11		; A := #11
	    lda #$11
;0bad  ddbe09    cp      (ix+#09)	; is orange ghost blue (edible) ?
	    cmp |orangeghostcolor
;0bb0  2807      jr      z,#0bb9         ; yes, skip ahead and change to white
	    beq :make_orange_white

;0bb2  dd360911  ld      (ix+#09),#11	; no, set orange ghost color to blue
	    sta |orangeghostcolor
;0bb6  c3d20b    jp      #0bd2		; skip ahead
	    bra :dec_return
:make_orange_white
;0bb9  dd360912  ld      (ix+#09),#12	; set orange ghost color to white
	    lda #$12
	    sta |orangeghostcolor
;0bbd  c3d20b    jp      #0bd2		; skip ahead
	    bra :dec_return
:not_orange_blue
;0bc0  3e07      ld      a,#07		; A := #07
	    lda #7
	    sta |orangeghostcolor
;0bc2  ddbe09    cp      (ix+#09)	; is orange ghost orange ?
;0bc5  2807      jr      z,#0bce         ; yes, skip ahead

;0bc7  dd360907  ld      (ix+#09),#07	; set orange ghost to orange
;0bcb  c3d20b    jp      #0bd2		; skip ahead

;0bce  dd360907  ld      (ix+#09),#07	; set orange ghost to orange
:dec_return
;0bd2  fd3500    dec     (iy+#00)	; decrease the flash counter
	    dec |big_pill_timer
;0bd5  c9        ret     		; return
	    rts
;------------------------------------------------------------------------------
; called from #0900
;0bd6
set_dead_color mx %00
    ; set the color for a dead ghost
;0bd6  0619      ld      b,#19		; B := #19 - floating death eyes (good band name!)
	    ldy #$19
;0bd8  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
	    lda |mainroutine1
;0bdb  fe22      cp      #22		; == #22 ? is code is used in pac-man only, not ms. pac.  its checking for the routine where pacman heads towards the energizer followed by 4 ghosts
	    cmp #$22
;0bdd  c2e20b    jp      nz,#0be2	; no, skip next step
	    bne :next
;0be0  0600      ld      b,#00		; B := #00.  code used to clear ghosts after they get eaten in the pac-man attract
	    ldy #0
:next
;0be2  dd21004c  ld      ix,#4c00	; load IX with start of offset for ghost sprites and colors
;0be6  3aac4d    ld      a,(#4dac)	; load A with red ghost state
	    lda |redghost_state

;0be9  a7        and     a		; is red ghost alive ?
;0bea  caf00b    jp      z,#0bf0		; yes, skip next step. only set color if not alive
	    beq :red_alive
;0bed  dd7003    ld      (ix+#03),b	; store B into red ghost color entry
	    sty |redghostcolor
:red_alive
;0bf0  3aad4d    ld      a,(#4dad)	; load A wtih pink ghost state
	    lda |pinkghost_state
;0bf3  a7        and     a		; is pink ghost alive ?
;0bf4  cafa0b    jp      z,#0bfa		; yes, skip next step
	    beq :pink_alive
;0bf7  dd7005    ld      (ix+#05),b	; store B into pink ghost color entry
	    sty |pinkghostcolor
:pink_alive
;0bfa  3aae4d    ld      a,(#4dae)	; load A with blue ghost (inky) state
	    lda |blueghost_state
;0bfd  a7        and     a		; is inky alive ?
;0bfe  ca040c    jp      z,#0c04		; yes, skip next step
	    beq :blue_alive
;0c01  dd7007    ld      (ix+#07),b	; store B into blue ghost (inky) color entry
	    sty |blueghostcolor
:blue_alive
;0c04  3aaf4d    ld      a,(#4daf)	; load A with orange ghost state
	    lda |orangeghost_state
;0c07  a7        and     a		; is orange ghost alive ? 
;0c08  c8        ret     z		; yes, return
	    beq :orange_alive
;0c09  dd7009    ld      (ix+#09),b	; store B into orange ghost color entry
	    sty |orangeghostcolor
:orange_alive
;0c0c  c9        ret   			; return  
	    rts

;------------------------------------------------------------------------------
; called from #0903
; routine to handle power pill flashes
;0c0d
flash_power mx %00
;0c0d  21cf4d    ld      hl,#4dcf	; load HL with power pill counter
;0c10  34        inc     (hl)		; increment
	    inc |powerpill_flash_timer
;0c11  3e0a      ld      a,#0a		; A := #0A
	    lda #$0a
;0c13  be        cp      (hl)		; is it time to flash the power pellets ?
	    cmp |powerpill_flash_timer
;0c14  c0        ret     nz		; no, return
	    beq :continue
	    rts
:continue
;0c15  3600      ld      (hl),#00	; else we will flash the pellets.  reset counter to #00
	    stz |powerpill_flash_timer
;0c17  3a044e    ld      a,(#4e04)	; load A with game state indicator.  this is #03 when game or demo is in play
	    lda |levelstate
;0c1a  fe03      cp      #03		; == #03 ?  Is a game being played ?
	    cmp #3
;0c1c  2015      jr      nz,#0c33        ; no, skip ahead and flash the pellets in the demo screen where pac is chased by 4 ghosts and then eats a power pill and eats them all
	    bne :not_play
;
;; BUGFIX05 - Map discoloration fix - Don Hodges
;0c1c  2000	jr 	nz,#0c1e	; no, do nothing
;
;0c1e  216444    ld      hl,#4464	; else load HL with first power pellet address (legacy from pac-man.  new routine loads new value)
;
;; OTTOPATCH
;;PATCH TO MAKE THE ENERGIZERS FLASH IN NEW AND EXCITING COLORS
;ORG 0C21H
;JP FLASHEN
;0c21  c32495    jp      #9524		; jump to new ms pac routine to flash power pellets
	    jmp FLASHEN
;
;;; Pac-man code:
;; 0c21  3e10      ld      a,#10		; load A with code for power pellet
;; 0c23  be        cp      (hl)		; is there already a power pellet there?
;;; end pac-man code
;
;; junk from pac-man, flashes power pellets for non-changing maze
;
;0c24  2002      jr      nz,#0c28        ; no, skip ahead
;0c26  3e00      ld      a,#00		; yes, change code to empty graphic
;0c28  77        ld      (hl),a		; flash power pellet
;0c29  327844    ld      (#4478),a	; flash power pellet
;0c2c  328447    ld      (#4784),a	; flash power pellet
;0c2f  329847    ld      (#4798),a	; flash power pellet
;0c32  c9        ret     		; return
;
;; arrive from #0C1C
;; flash the pellets in the demo screen where pac is chased by 4 ghosts and then eats a power pill and eats them all
;; this causes a very minor bug in pac-man and ms. pac man.  
;; potentially 2 screen elements can sometimes get colored wrong when player dies.
;; in pac-man, a dot may disappear at #4678
:not_play
;0c33  213247    ld      hl,#4732	; load HL with screen color address (?)
;0c36  3e10      ld      a,#10		; A := #10
	    lda |palette_ram+$332
	    and #$FF
;0c38  be        cp      (hl)		; is the screen color in this address == #10 ?
	    cmp #$10
;0c39  2002      jr      nz,#0c3d        ; no, skip next step
	    bne :rts
;
;0c3b  3e00      ld      a,#00		; A := #00
	    lda #$00FF
;0c3d  77        ld      (hl),a		; store #10 or #00 into this color location to flash the power pill in the demo
	    trb |palette_ram+$332
;0c3e  327846    ld      (#4678),a	; store into #4678 to flash the other power pill
	    trb |palette_ram+$278
:rts
;0c41  c9        ret     		; return (to #0906)
	    rts

;------------------------------------------------------------------------------
; called from #08f4
; handles ghost movements when they are moving around in or coming out of the ghost home
;0c42
ghost_house_movement mx %00

; red ghost

;0c42  3aa44d    ld      a,(#4da4)	; load A with # of ghost killed but no collision for yet [0..4]
	    lda	|num_ghosts_killed
;0c45  a7        and     a		; == #00 ?
;0c46  c0        ret     nz		; return if no collision
	    beq :do_red
:rts
	    rts
:do_red
;0c47  3a944d    ld      a,(#4d94)	; else load A with counter related to ghost movement inside home
;0c4a  07        rlca    		; rotate left
;0c4b  32944d    ld      (#4d94),a	; store result
	    sep #$20
	    asl |home_counter0
		rep #$30
;0c4e  d0        ret     nc		; return if no carry
		bcc :rts

	    lda #1
	    tsb |home_counter0
	    bcc :rts

;0c4f  3aa04d    ld      a,(#4da0)	; else load A with red ghost substate
	    lda |red_substate
;0c52  a7        and     a		; is red ghost out of the ghost house ?
;0c53  c2900c    jp      nz,#0c90	; yes, skip ahead and check next ghost
	    bne :do_pink

;0c56  dd210533  ld      ix,#3305	; no, load IX with address for offsets to move up
	    ldx #move_up
;0c5a  fd21004d  ld      iy,#4d00	; load IY with red ghost position
	    ldy #red_ghost_y
;0c5e  cd0020    call    #2000		; load HL with IY + IX = new position by moving up
	    jsr double_add
;0c61  22004d    ld      (#4d00),hl	; store into red ghost position
	    sta |red_ghost_y
;0c64  3e03      ld      a,#03		; A := #03
	    lda #3
;0c66  32284d    ld      (#4d28),a	; set previous red ghost orientation as moving up
	    sta |prev_red_ghost_dir
;0c69  322c4d    ld      (#4d2c),a	; set red ghost orientation as moving up
	    sta |red_ghost_dir
;0c6c  3a004d    ld      a,(#4d00)	; load A with red ghost Y position
	    lda |red_ghost_y
	    and #$FF
;0c6f  fe64      cp      #64		; is the red ghost out of the ghost house ?
	    cmp #$64
;0c71  c2900c    jp      nz,#0c90	; no, skip ahead and check next ghost
	    bne :do_pink

;0c74  212c2e    ld      hl,#2e2c	; yes, HL := #2E, 2C
	    lda #$2e2c
;0c77  220a4d    ld      (#4d0a),hl	; store into red ghost position
	    sta |redghost_tile_y
;0c7a  210001    ld      hl,#0100	; HL := #01 00 (code for moving to left)
	    lda #$0100
;0c7d  22144d    ld      (#4d14),hl	; store into red ghost tile changes
	    sta |red_ghost_tchangeA_y
;0c80  221e4d    ld      (#4d1e),hl	; store into red ghost tile changes
	    sta |red_ghost_tchange_y
;0c83  3e02      ld      a,#02		; A := #02
	    lda #2
;0c85  32284d    ld      (#4d28),a	; set previous red ghost orientation as moving left
	    sta |prev_red_ghost_dir
;0c88  322c4d    ld      (#4d2c),a	; set red ghost orientation as moving left
	    sta |red_ghost_dir
;0c8b  3e01      ld      a,#01		; A := #01
	    lda #1
;0c8d  32a04d    ld      (#4da0),a	; set red ghost indicator to outside the ghost house
	    sta |red_substate

; pink ghost
:do_pink
;0c90  3aa14d    ld      a,(#4da1)	; load A with pink ghost substate
	    lda |pink_substate
;0c93  fe01      cp      #01		; is pink ghost out of the ghost house ?
	    cmp #1
;0c95  cafb0c    jp      z,#0cfb	; yes, skip ahead and check next ghost
	    beq :do_blue

;0c98  fe00      cp      #00		; is pink ghost waiting to leave the ghost house?
	    cmp #0
;0c9a  c2c10c    jp      nz,#0cc1	; no, skip ahead
	    bne :pink_escape

; pink ghost is moving up and down in the ghost house

;0c9d  3a024d    ld      a,(#4d02)	; yes, load A with pink ghost Y position
	    lda |pink_ghost_y
	    and #$FF
;0ca0  fe78      cp      #78		; is pink ghost at the upper limit of the ghost house?
	    cmp #$78
;0ca2  cc2e1f    call    z,#1f2e		; yes, reverse direction of pink ghost
	    bne :not78
	    jsr reverse_pink
	    lda |pink_ghost_y
	    and #$FF
:not78
;0ca5  fe80      cp      #80		; is pink ghost at bottom of the ghost house?
	    cmp #$80
	    bne :not80
;0ca7  cc2e1f    call    z,#1f2e		; yes, reverse direction of pink ghost
	    jsr reverse_pink
:not80
;0caa  3a2d4d    ld      a,(#4d2d)	; load A with pink ghost orientation
	    lda |pink_ghost_dir
;0cad  32294d    ld      (#4d29),a	; store into previous pink ghost orienation
	    sta |prev_pink_ghost_dir
;0cb0  dd21204d  ld      ix,#4d20	; load IX with pink ghost tile changes
	    ldx #pink_ghost_tchange_y
;0cb4  fd21024d  ld      iy,#4d02	; load IY with pink ghost position
	    ldy #pink_ghost_y
;0cb8  cd0020    call    #2000		; load HL with IX + IY = new pink ghost position
	    jsr double_add
;0cbb  22024d    ld      (#4d02),hl	; store into pink ghost position
	    sta |pink_ghost_y
;0cbe  c3fb0c    jp      #0cfb		; skip ahead and check next ghost
	    bra :do_blue

; pink ghost is moving up out of the ghost house
:pink_escape
;0cc1  dd210533  ld      ix,#3305	; load IX with address for offsets to move up
	    ldx #move_up
;0cc5  fd21024d  ld      iy,#4d02	; load IY with pink ghost position
	    ldy #pink_ghost_y
;0cc9  cd0020    call    #2000		; load HL with IY + IX = new pink ghost position
	    jsr double_add
;0ccc  22024d    ld      (#4d02),hl	; store result into pink ghost position
	    sta |pink_ghost_y
;0ccf  3e03      ld      a,#03		; A := #03
	    lda #3
;0cd1  322d4d    ld      (#4d2d),a	; set previous pink ghost orientation as moving up
	    sta |pink_ghost_dir
;0cd4  32294d    ld      (#4d29),a	; set pink ghost orientation as moving up
	    sta |prev_pink_ghost_dir
;0cd7  3a024d    ld      a,(#4d02)	; load A with pink ghost Y position
	    lda |pink_ghost_y
;0cda  fe64      cp      #64		; is pink ghost out of the ghost house ?
	    and #$FF
	    cmp #$64
;0cdc  c2fb0c    jp      nz,#0cfb	; no, skip ahead and check next ghost
	    bne :do_blue

; pink ghost has made it out of the ghost house

;0cdf  212c2e    ld      hl,#2e2c	; HL := 2E, 2C
	    lda #$2e2c
;0ce2  220c4d    ld      (#4d0c),hl	; store into pink ghost position
	    sta |pinkghost_tile_y
;0ce5  210001    ld      hl,#0100	; HL := #01 00 (code for moving left)
	    lda #$0100
;0ce8  22164d    ld      (#4d16),hl	; store into pink ghost tile changes
	    sta |pink_ghost_tchangeA_y
;0ceb  22204d    ld      (#4d20),hl	; store into pink ghost tile changes
	    sta |pink_ghost_tchange_y
;0cee  3e02      ld      a,#02		; A := #02
	    lda #2
;0cf0  32294d    ld      (#4d29),a	; set previous pink ghost orientation as moving left
	    sta |prev_pink_ghost_dir
;0cf3  322d4d    ld      (#4d2d),a	; set pink ghost orientation as moving left
	    sta |pink_ghost_dir
;0cf6  3e01      ld      a,#01		; A := #01
	    lda #1
;0cf8  32a14d    ld      (#4da1),a	; set pink ghost indicator to outside the ghost house
	    sta |pink_substate

; blue ghost (inky)
:do_blue
;0cfb  3aa24d    ld      a,(#4da2)	; load A with blue ghost (inky) substate
	    lda |blue_substate
;0cfe  fe01      cp      #01		; is inky out of the ghost house ?
	    cmp #1
;0d00  ca930d    jp      z,#0d93		; yes, skip ahead and check next ghost
	    beql :do_orange

;0d03  fe00      cp      #00		; is inky waiting to leave the ghost house ?
	    cmp #0
;0d05  c22c0d    jp      nz,#0d2c	; no, skip ahead
	    bne :inky_no_wait

; inky is moving up and down in the ghost house

;0d08  3a044d    ld      a,(#4d04)	; load A with inky Y position
	    lda |blue_ghost_y
;0d0b  fe78      cp      #78		; is inky at the upper limit of ghost house ?
	    and #$FF
	    cmp #$78
	    bne :bg_no_top
;0d0d  cc551f    call    z,#1f55		; yes, reverse direction of inky
	    jsr reverse_inky
	    lda |blue_ghost_y
	    and #$FF
:bg_no_top
;0d10  fe80      cp      #80		; is inky at the bottom of the ghost house ?
	    cmp #$80
	    bne :bg_no_bot
;0d12  cc551f    call    z,#1f55		; yes, reverse direction of inky
	    jsr reverse_inky
:bg_no_bot
;0d15  3a2e4d    ld      a,(#4d2e)	; load A with inky orientation
	    lda |blue_ghost_dir
;0d18  322a4d    ld      (#4d2a),a	; store into previous inky orientation
	    sta |prev_blue_ghost_dir
;0d1b  dd21224d  ld      ix,#4d22	; load IX with inky tile changes
	    ldx #blue_ghost_tchange_y
;0d1f  fd21044d  ld      iy,#4d04	; load IY with inky position
	    ldy #blue_ghost_y
;0d23  cd0020    call    #2000		; load HL with IX + IY = new inky position
	    jsr double_add
;0d26  22044d    ld      (#4d04),hl	; store into inky position
	    sta |blue_ghost_y
;0d29  c3930d    jp      #0d93		; skip ahead and check next ghost
	    bra :do_orange
:inky_no_wait
;0d2c  3aa24d    ld      a,(#4da2)	; load A with inky substate
	    lda |blue_substate
;0d2f  fe03      cp      #03		; is inky moving to his right, on his way out of the ghost house?
	    cmp #3
;0d31  c2590d    jp      nz,#0d59	; no, skip ahead
	    bne :inky_not_right

; inky is on his way out of ghost house to right

;0d34  dd21ff32  ld      ix,#32ff	; yes, load IX with tile movement for moving right
	    ldx #move_right
;0d38  fd21044d  ld      iy,#4d04	; load IY with inky position
	    ldy #blue_ghost_y
;0d3c  cd0020    call    #2000		; load HL with IX + IY = new inky position
	    jsr double_add
;0d3f  22044d    ld      (#4d04),hl	; store new position for inky
	    sta |blue_ghost_y
;0d42  af        xor     a		; A := #00
;0d43  322a4d    ld      (#4d2a),a	; set previous inky orientation as moving right
	    stz |prev_blue_ghost_dir
;0d46  322e4d    ld      (#4d2e),a	; set inky orientation as moving right
	    stz |blue_ghost_dir
;0d49  3a054d    ld      a,(#4d05)	; load A with inky X position
	    lda |blue_ghost_x
;0d4c  fe80      cp      #80		; is inky exactly under the ghost house door ?
	    and #$FF
	    cmp #$80
;0d4e  c2930d    jp      nz,#0d93	; no, skip ahead and check next ghost
	    bne :do_orange

;0d51  3e02      ld      a,#02		; yes, A := #02
	    lda #2
;0d53  32a24d    ld      (#4da2),a	; store into inky substate to indicate moving up and out of ghost house
	    sta |blue_substate
;0d56  c3930d    jp      #0d93		; skip ahead and check next ghost
	    bra :do_orange

; inky is moving up out of the ghost house
:inky_not_right
;0d59  dd210533  ld      ix,#3305	; load IX with address for offsets to move up
	    ldx #move_up
;0d5d  fd21044d  ld      iy,#4d04	; load IY with inky position
	    ldy #blue_ghost_y
;0d61  cd0020    call    #2000		; load HL with IX + IY = new inky position
	    jsr double_add
;0d64  22044d    ld      (#4d04),hl	; store into inky position
	    sta |blue_ghost_y
;0d67  3e03      ld      a,#03		; A := #03
	    lda #3
;0d69  322a4d    ld      (#4d2a),a	; set previous inky orientation as moving up
	    sta |prev_blue_ghost_dir
;0d6c  322e4d    ld      (#4d2e),a	; set inky orientation as moving up
	    sta |blue_ghost_dir
;0d6f  3a044d    ld      a,(#4d04)	; load A with inky's Y position
	    lda |blue_ghost_y
;0d72  fe64      cp      #64		; is inky out of the ghost house ?
	    and #$FF
	    cmp #$64
;0d74  c2930d    jp      nz,#0d93	; no, skip ahead and check next ghost
	    bne :do_orange

; inky has made it out of the ghost house

;0d77  212c2e    ld      hl,#2e2c	; load HL with 2E, 2C
	    lda #$2e2c
;0d7a  220e4d    ld      (#4d0e),hl	; store into inky tile position
	    sta |blueghost_tile_y
;0d7d  210001    ld      hl,#0100	; load HL with code for moving left
	    lda #$0100
;0d80  22184d    ld      (#4d18),hl	; store into inky tile changes
	    sta |blue_ghost_tchangeA_y
;0d83  22224d    ld      (#4d22),hl	; store into inky tile changes
	    sta |blue_ghost_tchange_y
;0d86  3e02      ld      a,#02		; A := #02
	    lda #2
;0d88  322a4d    ld      (#4d2a),a	; set previous inky orientation as moving left
	    sta |prev_blue_ghost_dir
;0d8b  322e4d    ld      (#4d2e),a	; set inky orientation as moving left
	    sta |blue_ghost_dir
;0d8e  3e01      ld      a,#01		; A := #01	
	    lda #1
;0d90  32a24d    ld      (#4da2),a	; set inky ghost indicator to outside the ghost house
	    sta |blue_substate

; orange ghost
:do_orange
;0d93  3aa34d    ld      a,(#4da3)	; load A with orange ghost substate
	    lda |orange_substate
;0d96  fe01      cp      #01		; is orange ghost out of the ghost house ?
	    cmp #1
;0d98  c8        ret     z		; yes, return
	    bne :continue_orange
	    rts
:continue_orange
;0d99  fe00      cp      #00		; is orange ghost waiting to leave the ghost house ?
	    cmp #0
;0d9b  c2c00d    jp      nz,#0dc0	; no, skip ahead
	    bne :not_up_down

; orange ghost is moving up and down in the ghost house

;0d9e  3a064d    ld      a,(#4d06)	; yes, load A with orange ghost Y position
	    lda |orange_ghost_y
	    and #$FF
;0da1  fe78      cp      #78		; is orange ghost at upper limit of ghost house ?
	    cmp #$78
	    bne :not_orange_reverse1
;0da3  cc7c1f    call    z,#1f7c		; yes, reverse orange ghost direction
	    jsr reverse_orange
:not_orange_reverse1
	    lda |orange_ghost_y
	    and #$FF
;0da6  fe80      cp      #80		; is orange ghost at bottom of ghost house ?
	    cmp #$80
	    bne :no_orange_rev
;0da8  cc7c1f    call    z,#1f7c		; yes, reverse orange ghost direction
	    jsr reverse_orange
:no_orange_rev
;0dab  3a2f4d    ld      a,(#4d2f)	; load A with orange ghost orientation
	    lda |orange_ghost_dir
;0dae  322b4d    ld      (#4d2b),a	; store into previous orange ghost orientation
	    sta |prev_orange_ghost_dir
;0db1  dd21244d  ld      ix,#4d24	; load IX with orange ghost tile changes
	    ldx #orange_ghost_tchange_y
;0db5  fd21064d  ld      iy,#4d06	; load IY with orange ghost position
	    ldy #orange_ghost_y
;0db9  cd0020    call    #2000		; load HL with IX + IY = new orange ghost position
	    jsr double_add
;0dbc  22064d    ld      (#4d06),hl	; store into orange ghost position
	    sta |orange_ghost_y
;0dbf  c9        ret     		; return
:rts2
	    rts
:not_up_down
;0dc0  3aa34d    ld      a,(#4da3)	; load A with orange ghost substate
	    lda |orange_substate
;0dc3  fe03      cp      #03		; is orange ghost moving to his left, on his way out of the ghost house ?
	    cmp #3
;0dc5  c2ea0d    jp      nz,#0dea	; no, skip ahead
	    bne :orange_up_out

; orange ghost is moving left, on his way out of ghost house

;0dc8  dd210333  ld      ix,#3303	; load IX with address for offsets to move left
	    ldx #move_left
;0dcc  fd21064d  ld      iy,#4d06	; load IY with orange ghost position 
	    ldy #orange_ghost_y
;0dd0  cd0020    call    #2000		; load HL with IX + IY = new orange ghost position
	    jsr double_add
;0dd3  22064d    ld      (#4d06),hl	; store new orange ghost position
	    sta |orange_ghost_y
;0dd6  3e02      ld      a,#02		; A := #02
	    lda #2
;0dd8  322b4d    ld      (#4d2b),a	; set previous orange ghost orientation as moving left
	    sta |prev_orange_ghost_dir
;0ddb  322f4d    ld      (#4d2f),a	; set orange ghost orientation as moving left
	    sta |orange_ghost_dir
;0dde  3a074d    ld      a,(#4d07)	; load A with orange ghost X position
	    lda |orange_ghost_x
	    and #$FF
;0de1  fe80      cp      #80		; is orange ghost exactly under the ghost house door ?
	    cmp #$80
;0de3  c0        ret     nz		; no, return
	    bne :rts2 

;0de4  3e02      ld      a,#02		; yes, A := #02
	    lda #2
;0de6  32a34d    ld      (#4da3),a	; store into orange ghost substate to indicate moving up and out of ghost house
	    sta |orange_substate
;0de9  c9        ret			; return
	    rts

; orange ghost is moving up and out of ghost house
:orange_up_out
;0dea  dd210533  ld      ix,#3305	; load IX with address for offsets to move up
	    ldx #move_up
;0dee  fd21064d  ld      iy,#4d06	; load IY with orange ghost position
	    ldy #orange_ghost_y
;0df2  cd0020    call    #2000		; load HL with IX + IY = new orange ghost position
	    jsr double_add
;0df5  22064d    ld      (#4d06),hl	; store into orange ghost position
	    sta |orange_ghost_y
;0df8  3e03      ld      a,#03		; A := #03
	    lda #3
;0dfa  322b4d    ld      (#4d2b),a	; set previous orange ghost orientation as moving up
	    sta |prev_orange_ghost_dir
;0dfd  322f4d    ld      (#4d2f),a	; set orange ghost orientation as moving up
	    sta |orange_ghost_dir
;0e00  3a064d    ld      a,(#4d06)	; load A with orange ghost Y position
	    lda |orange_ghost_y
	    and #$FF
;0e03  fe64      cp      #64		; is orange ghost out of the ghost house ?
	    cmp #$64
;0e05  c0        ret     nz		; no, return
	    bne :rts3

; orange ghost has made it out of the ghost house

;0e06  212c2e    ld      hl,#2e2c	; load HL with 2E, 2C
	    lda #$2e2c
;0e09  22104d    ld      (#4d10),hl	; store into orange ghost tile position
	    sta |orangeghost_tile_y
;0e0c  210001    ld      hl,#0100	; load HL with code for moving left
	    lda #$0100
;0e0f  221a4d    ld      (#4d1a),hl	; store into oragne ghost tile changes
	    sta |orange_ghost_tchangeA_y
;0e12  22244d    ld      (#4d24),hl	; store into orange ghost tile changes
	    sta |orange_ghost_tchange_y
;0e15  3e02      ld      a,#02		; A := #02
	    lda #2
;0e17  322b4d    ld      (#4d2b),a	; set previous orange ghost orientation as moving left
	    sta |prev_orange_ghost_dir
;0e1a  322f4d    ld      (#4d2f),a	; set orange ghost orientation as moving left
	    sta |orange_ghost_dir
;0e1d  3e01      ld      a,#01		; A := #01
	    lda #1
;0e1f  32a34d    ld      (#4da3),a	; set orange ghost indicator to outside the ghost house
	    sta |orange_substate

;0e22  c9        ret     		; return
:rts3
	    rts
;------------------------------------------------------------------------------
; called from #08f7
;0e23
animate_ghosts mx %00
;0e23  21c44d    ld      hl,#4dc4	; load HL with counter
;0e26  34        inc     (hl)		; increment
;0e27  3e08      ld      a,#08		; A := #08
;0e29  be        cp      (hl)		; is the counter == #08 ?
	    lda |counter8
	    inc
	    sta |counter8
	    cmp #8
;0e2a  c0        ret     nz		; no, return
	    bne :rts

;0e2b  3600      ld      (hl),#00	; else clear counter
	    stz |counter8
;0e2d  3ac04d    ld      a,(#4dc0)	; load A with address used for ghost animations
	    lda |ghost_anim_counter
;0e30  ee01      xor     #01		; flip bit 0
	    eor #1
;0e32  32c04d    ld      (#4dc0),a	; store result
	    sta |ghost_anim_counter
:rts
;0e35  c9        ret     		; return
	    rts

;------------------------------------------------------------------------------
; called from #08fa
;0e36
reverse_ghosts mx %00
;0e36  3aa64d    ld      a,(#4da6)	; load A with power pill effect (1=active, 0=no effect)
	    lda |powerpill
;0e39  a7        and     a		; is a power pill active ?
;0e3a  c0        ret     nz		; yes, return, we never reverse dir. when power pill is on
	    bne :rts

;0e3b  3ac14d    ld      a,(#4dc1)	; no, load A with ghost orientation index
	    lda |orientation_changes_index
;0e3e  fe07      cp      #07		; == #07 ?
	    cmp #7
;0e40  c8        ret     z		; yes, return, we never reverse dir. more than 7 times (pac-man only)
	    beq :rts

;0e41  87        add     a,a		; Double the index, this is used below for offset in the table
	    asl
	    tax

;0e42  2ac24d    ld      hl,(#4dc2)	; load HL with counter for ghost reversals
;0e45  23        inc     hl		; increment
;0e46  22c24d    ld      (#4dc2),hl	; store result
	    inc |ghost_orientation_counter
;0e49  5f        ld      e,a		; E := A
;0e4a  1600      ld      d,#00		; D := #00
;0e4c  dd21864d  ld      ix,#4d86	; load IX with start of difficulty table
;0e50  dd19      add     ix,de		; add offset based on which reversal this is
;0e52  dd5e00    ld      e,(ix+#00)	; 
;0e55  dd5601    ld      d,(ix+#01)	; load DE with result from table.  for first reverse this is #01A4
	    lda |orientation_changes,x
;0e58  a7        and     a		; clear carry flag
;0e59  ed52      sbc     hl,de		; subtract.  are they equal ? = time to reverse direction of ghosts
	    cmp |ghost_orientation_counter
;0e5b  c0        ret     nz		; if not, return
	    bne :rts

; arrive here when ghosts reverse direction
; this differs from the pac-man code

; OTTOPATCH
;PATCH TO MAKE RED MONSTER GO AFTER OTTO TO AVOID PARKING
;0e5c  af        xor     a		; else A := #00
;0e5d  00        nop     		; 


;; Pac-Man code follows
	; 0E5C CB 3F SRL A		; this undoes the double from line #0E41
;; end pac-man code

;0e5e  3c        inc     a		; increment
	    lda # 1
;0e5f  32c14d    ld      (#4dc1),a	; store into orientation index
	    sta |orientation_changes_index
;0e62  210101    ld      hl,#0101
;0e65  22b14d    ld      (#4db1),hl
;0e68  22b34d    ld      (#4db3),hl	; load #01 ghost orientations - reverses ghosts direction
	    sta |red_change_dir
	    sta |pink_change_dir
	    sta |blue_change_dir
	    sta |orange_change_dir
;0e6b  c9        ret     		; return
:rts
	    rts

;------------------------------------------------------------------------------
; called from #0906
; changes the background sound based on # of pills eaten
;0e6c
change_sound_pills mx %00
;0e6c  3aa54d    ld      a,(#4da5)	; load A with pacman dead animation state (0 if not dead)
	    lda |pacman_dead_state
;0e6f  a7        and     a		; is pacman dead ?
;0e70  2805      jr      z,#0e77         ; no, skip ahead
	    beq :not_dead
;0e72  af        xor     a		; else A := #00
;0e73  32ac4e    ld      (#4eac),a	; clear sound channel 2
	    stz |CH2_E_NUM
;0e76  c9        ret     		; return
	    rts
:not_dead
;0E77: 21 AC 4E	ld	hl,#4EAC	; else pacman is alive.  load HL with sound 2 channel
	    lda |CH2_E_NUM
;0E7A: 06 E0	ld	b,#E0		; B := #E0.  this is a binary bitmask of 11100000 applied later
	    and #$E0
;0E7C: 3A 0E 4E	ld	a,(#4E0E)	; load A with number of pills eaten in this level
	    ldx |dotseat
;0E7F: FE E4	cp	#E4		; > #E4 ?
	    cpx #$E4
;0E81: 38 06	jr	c,#0E89		; no, skip ahead
	    bcc :skip

;0E83: 78	ld	a,b		; else load A with bitmask
;0E84: A6	and	(hl)		; apply bitmask to sound 2 channel. this turns off bits 0 through 4
;0E85: CB E7	set	4,a		; turn on bit 4
	    ora #$10
;0E87: 77	ld	(hl),a		; play sound
	    sta |CH2_E_NUM
;0E88: C9	ret  			; return
	    rts
:skip
;0e89  fed4      cp      #d4		; is the number of pills eaten in this level > #D4 ? 
	    cpx #$d4
;0e8b  3806      jr      c,#0e93         ; no, skip ahead
	    bcc :skip2

;0e8d  78        ld      a,b		; else load A with bitmask
;0e8e  a6        and     (hl)		; turn off bits 0 through 4 on sound channel
;0e8f  cbdf      set     3,a		; turn on bit 3
	    ora #$08
;0e91  77        ld      (hl),a		; play sound
	    sta |CH2_E_NUM
;0e92  c9        ret     		; return
	    rts
:skip2
;0e93  feb4      cp      #b4		; is the number of pills eaten in this level > #B4 ?
	    cpx #$b4
;0e95  3806      jr      c,#0e9d        ; no, skip ahead
	    bcc :skip3
;0e97  78        ld      a,b		; else load A with bitmask
;0e98  a6        and     (hl)		; turn off bits 0 through 4 on sound channel
;0e99  cbd7      set     2,a		; turn on bit 2
	    ora #4
;0e9b  77        ld      (hl),a		; play sound
	    sta |CH2_E_NUM
;0e9c  c9        ret     		; return
	    rts
:skip3
;0e9d  fe74      cp      #74		; is the number of pills eaten in this level > #74 ?
	    cpx #$74
;0e9f  3806      jr      c,#0ea7         ; no, skip ahead
	    bcc :skip4
;0ea1  78        ld      a,b		; load A with bitmask
;0ea2  a6        and     (hl)		; turn off bits 0 through 4 on sound channel
;0ea3  cbcf      set     1,a		; turn on bit 1
	    ora #2
;0ea5  77        ld      (hl),a		; play sound
	    sta |CH2_E_NUM
;0ea6  c9        ret     		; return
	    rts
:skip4
;0ea7  78        ld      a,b		; else load A with bitmask
;0ea8  a6        and     (hl)		; turn off bits 0 through 4 on sound channel
;0ea9  cbc7      set     0,a		; turn on bit 0
	    ora #1
;0eab  77        ld      (hl),a		; play sound
	    sta |CH2_E_NUM
;0eac  c9        ret     		; return
	    rts

;------------------------------------------------------------------------------
; clear fruit
; arrive from #0246 as timed task #04
;1000
clear_fruit mx %00
;1000  af        xor     a		; A := #00
;1001  32d44d    ld      (#4dd4),a	; clear fruit
			stz |FVALUE
;1004  c9        ret     		; return
			rts

;------------------------------------------------------------------------------
; this is timed task #05, arrive from #0246
;100B
ttask5 mx %00
;100B: C3 78 36	jp	#3678		; ms pac patch to erase the fruit score
;3678
;3678  210000    ld      hl,#0000	; clear HL
;367b  22d24d    ld      (#4dd2),hl	; clears the fruit score sprite 
;367e  c9        ret    			; return
			stz |FRUITP
			rts

;------------------------------------------------------------------------------
;
; called from #0909
;
; OTTOPATCH
;PATCH TO THE PRIMARY FRUIT ROUTINE, THIS ROUTINE IS CALLED ONCE PER
;GAME STEP (THE MINIMUM TIME IT TAKES A MONSTER TO MOVE A PIXEL)
;0EAD
;JP DOFRUIT
;0ead  c3ee86    jp      #86ee		; jump to Ms. Pac patch for fruit release OTTO DOFRUIT

;------------------------------------------------------------------------------
; called from #052C, #052F, #08EB and #08EE 
; 1017
pm1017      mx %00

	    jsr	mspac_death_update

	    lda |pacman_dead_state	; skip out early if dead squence playing
	    beq :continue
		; else pacman is dead
	    rts

:continue

	    jsr eatghosts		; check for ghosts being eaten and set ghost states accordingly
;1022  cd9410    call    #1094		; check for red ghost state and do things if not alive
	    jsr red_ghost_death_update

;1025  cd9e10    call    #109e		; check for pink ghost state and do things if not alive
	    jsr pink_ghost_death_update

;1028  cda810    call    #10a8		; check for blue ghost (inky) state and do things if not alive
	    jsr blue_ghost_death_update

;102b  cdb410    call    #10b4		; check for orange ghost state and do things if not alive
	    jsr orange_ghost_death_update

;102e  3aa44d    ld      a,(#4da4)	; load A with # of ghost killed but no collision for yet [0..4]
	    lda |num_ghosts_killed
;1031  a7        and     a		; == #00 ?
;1032  ca3910    jp      z,#1039		; yes, skip ahead
	    beq :none
;
;1035  cd3512    call    #1235		; no, call this sub
	    jsr ghost_eat_process
;1038  c9        ret     		; and return
	    rts
:none
;1039  cd1d17    call    #171d		; check for collision with regular ghosts
	    jsr normal_ghost_collide

;103c  cd8917    call    #1789		; check for collision with blue ghosts
	    jsr blue_ghost_collide
;103f  3aa44d    ld      a,(#4da4)	; load A with # of ghost killed but no collision for yet [0..4]
	    lda |num_ghosts_killed
;1042  a7        and     a		; is there a collsion ?
;1043  c0        ret     nz		; yes, return
	    bne :rts
;
;1044  cd0618    call    #1806		; handle all pac-man movement
	    jsr pacman_movement
;1047  cd361b    call    #1b36		; control movement for red ghost
	    jsr control_red
;104a  cd4b1c    call    #1c4b		; control movement for pink ghost
	    jsr control_pink
;104d  cd221d    call    #1d22		; control movement for blue ghost (inky)
	    jsr control_inky
;1050  cdf91d    call    #1df9		; control movement for orange ghost
	    jsr control_orange
;1053  3a044e    ld      a,(#4e04)	; load A with level state subroutine #
	    lda |levelstate
;1056  fe03      cp      #03		; is a game being played ?
	    cmp #3
;1058  c0        ret     nz		; no, return
	    bne :rts
;
;1059  cd7613    call    #1376		; control blue ghost timer and reset ghosts when it is over or when pac eats all blue ghosts
	    jsr control_blue_time

;105c  cd6920    call    #2069		; check for pink ghost to leave the ghost house
	    jsr check_pink_house

;105f  cd8c20    call    #208c		; check for blue ghost (inky) to leave the ghost house
	    jsr check_inky_house

;1062  cdaf20    call    #20af		; check for orange ghost to leave the ghost house
	    jsr check_orange_house
:rts
	    rts

;------------------------------------------------------------------------------
;1066 
eatghosts   mx %00
	    lda |killghost_state	; ghost being eaten
	    bne :continue
	    rts				; no
:continue
	    stz |killghost_state	; clear killing ghost state
	    dec				; is red ghost being eaten?
	    bne	:not_red

	    inc				; A := A + 1 [ A is now #01, code for dead ghost]
	    sta |redghost_state         ; store into red ghost state
	    rts
:not_red
	    dec 			; is the pink ghost being eaten?
	    bne :not_pink
	    inc

	    sta |pinkghost_state	; set pink ghost state to dead
	    rts
:not_pink
	    dec				; is blue ghost (inky) being eaten?
	    bne :not_blue

	    inc 			; A := #01
	    sta |blueghost_state        ; set inky ghost state to dead
	    rts
:not_blue
	    sta |orangeghost_state	; else orange ghost is being eaten.   set orange ghost state to dead 

	    rts

;------------------------------------------------------------------------------
; called from #1022
;1094
red_ghost_death_update mx %00
	    lda |redghost_state
	    asl
	    tax
	    jmp (:dispatch,x)   	; 1097 ; rst #20
:dispatch
	    da :return   ; #000C	; return immediately when ghost is alive
	    da :eyes     ; #10C0	; when ghost is dead
        da :at_house ; #10D2	; when ghost eyes are above and entering the ghost house when returning home

; arrive here from #1097 when red ghost is dead (eyes)
:eyes
	    jsr red_ghost_move ;call #1BD8 ; handle red ghost movement

;10C3: 2A 00 4D	ld	hl,(#4D00)	; load HL with red ghost (Y,X) position
	    lda |red_ghost_y   		
	    ora |red_ghost_x-1

;10c6  116480    ld      de,#8064	; load DE with X=80, Y=64 position which is right above the ghost house
;10c9  a7        and     a		; clear carry flag
;10ca  ed52      sbc     hl,de		; is red ghost eyes right above the ghost house?
;10cc  c0        ret     nz		; no, return
	    cmp #$8064
	    beq :next_state
	    rts

:next_state
;10cd  21ac4d    ld      hl,#4dac	; yes, load HL with red ghost state
;10d0  34        inc     (hl)		; increase
;10d1  c9        ret			; return
	    inc |redghost_state

:return	    rts

; arrive here from #1097 when red ghost eyes are above and entering the ghost house when returning home
; 10d2
:at_house
;10d2  dd210133  ld      ix,#3301	; load IX with direction address tiles for moving down
	    ldx #move_down
;10d6  fd21004d  ld      iy,#4d00	; load IY with red ghost position
	    ldy #red_ghost_y
;10da  cd0020    call    #2000		; HL := (IX) + (IY)
	    jsr double_add
;10dd  22004d    ld      (#4d00),hl	; store new position for red ghost
	    sta |red_ghost_y

;10e0  3e01      ld      a,#01		; A := #01
	    lda #1
;10e2  32284d    ld      (#4d28),a	; set previous red ghost orientation as moving down
	    sta |prev_red_ghost_dir
;10e5  322c4d    ld      (#4d2c),a	; set red ghost orientation as moving down
	    sta |red_ghost_dir
;10e8  3a004d    ld      a,(#4d00)	; load A with red ghost Y position
	    lda |red_ghost_y
	    and #$FF
;10eb  fe80      cp      #80		; has the red ghost eyes fully entered the ghost house?
	    cmp #$80
;10ed  c0        ret     nz		; no, return
	    bne :return

;10ee  212f2e    ld      hl,#2e2f	; yes, load HL with 2E, 2F location which is the center of the ghost house
	    lda #$2e2f
;10f1  220a4d    ld      (#4d0a),hl	; store into red ghost tile position
	    sta |redghost_tile_y
;10f4  22314d    ld      (#4d31),hl	; store into red ghost tile position 2
	    sta |red_tile_y_2
;10f7  af        xor     a		; A := #00
;10f8  32a04d    ld      (#4da0),a	; set red ghost substate as at home
	    stz |red_substate
;10fb  32ac4d    ld      (#4dac),a	; set red ghost state as alive
	    stz |redghost_state
;10fe  32a74d    ld      (#4da7),a	; set red ghost blue flag as not edible
	    stz |redghost_blue
;
;; the other ghost subroutines arrive here after the ghost has arrived at home
;
ghost_arrive_home mx %00
;1101  dd21ac4d  ld      ix,#4dac	; load IX with ghost state starting address
;1105  ddb600    or      (ix+#00)	; is red ghost dead?
	    lda |redghost_state
;1108  ddb601    or      (ix+#01)	; or the pink ghost dead?
	    ora |pinkghost_state
;110b  ddb602    or      (ix+#02)	; or the blue ghost dead?
	    ora |blueghost_state
;110e  ddb603    or      (ix+#03)	; or the orange ghost dead
	    ora |orangeghost_state
;1111  c0        ret     nz		; yes, return
	    beq :make_noise
	    rts

:make_noise
;
;; arrive here when ghost eyes return to ghost home and there are no other ghost eyes still moving around
;
;1112: 21 AC 4E	ld	hl,#4EAC	; load HL with sound channel 2
;1115: CB B6	res	6,(hl)		; clear sound on bit 6
	    lda #$40	; bit 6
	    trb |CH2_E_NUM		; clear bit 6
;1117: C9	ret			; return
	    rts

;------------------------------------------------------------------------------
; called from #1025
pink_ghost_death_update mx %00
;109E: 3A AD 4D	ld	a,(#4DAD)	; load A with pink ghost state
	    lda |pinkghost_state
;10A1: E7	rst	#20		; jump based on A
	    asl
	    tax
	    jmp (:table,x)

:table
	    da :rts 	 ; #000C ; return immediately when ghost is alive
	    da :isdead   ; #1118 ; when ghost is dead
	    da :at_house ; #112A ; when ghost eyes are above and entering the ghost house when returning home

; arrive here from #10A1 when pink ghost is dead (eyes)
:isdead
;1118  cdaf1c    call    #1caf		; handle pink ghost movement
	    jsr pink_ghost_move

;111b  2a024d    ld      hl,(#4d02)	; load HL with pink ghost position
	    lda |pink_ghost_y
;111e  116480    ld      de,#8064	; load DE with Y,X position above ghost house 
;1121  a7        and     a		; clear carry flag
;1122  ed52      sbc     hl,de		; subtract. is the pink ghost eyes right above the ghost home?
	    cmp #$8064
;1124  c0        ret     nz		; no, return
	    bne :rts

;1125  21ad4d    ld      hl,#4dad	; yes, load HL with pink ghost state
;1128  34        inc     (hl)		; increase
	    inc |pinkghost_state
;1129  c9        ret  			; return
:rts
	    rts
; arrive here from #10A1 when pink ghost eyes are above and entering the ghost house when returning home
:at_house
;112a  dd210133  ld      ix,#3301	; load IX with direction address tiles for moving down
	    ldx #move_down
;112e  fd21024d  ld      iy,#4d02	; load IY with pink ghost position
	    ldy #pink_ghost_y
;1132  cd0020    call    #2000		; HL := (IX) + (IY)
	    jsr double_add
;1135  22024d    ld      (#4d02),hl	; store new position for pink ghost
	    sta |pink_ghost_y
;1138  3e01      ld      a,#01		; A := #01
	    lda #1
;113a  32294d    ld      (#4d29),a	; set previous pink ghost orientation as moving down
	    sta |prev_pink_ghost_dir
;113d  322d4d    ld      (#4d2d),a	; set pink ghost orientation as moving down
	    sta |pink_ghost_dir
;1140  3a024d    ld      a,(#4d02)	; load A with pink ghost Y position
	    lda |pink_ghost_y
	    and #$FF
;1143  fe80      cp      #80		; has the pink ghost eyes fully entered the ghost house?
	    cmp #$80
;1145  c0        ret     nz		; no, return
	    bne :rts
;
;1146  212f2e    ld      hl,#2e2f	; yes, load HL with 2E, 2F location which is the center of the ghost house
	    lda #$2e2f
;1149  220c4d    ld      (#4d0c),hl	; store into pink ghost tile position
	    sta |pinkghost_tile_y
;114c  22334d    ld      (#4d33),hl	; store into pink ghost tile position 2
	    sta |pink_tile_y_2
;114f  af        xor     a		; A := #00
;1150  32a14d    ld      (#4da1),a	; set pink ghost substate as at home
	    stz |pink_substate
;1153  32ad4d    ld      (#4dad),a	; set pink ghost state as alive
	    stz |pinkghost_state
;1156  32a84d    ld      (#4da8),a	; set pink ghost blue flag as not edible
	    stz |pinkghost_blue
;1159  c30111    jp      #1101		; jump to check for clearing eyes sound
	    jmp ghost_arrive_home

;------------------------------------------------------------------------------
; called from #1028
;10A8
blue_ghost_death_update mx %00
	    lda |blueghost_state        ; load A with blue ghost (Inky) state 
	    asl
	    tax
	    jmp (:table,x)       	; jump based on A 
:table
	    da :rts    		    ; #000C	; return immediately when ghost is alive
	    da :isdead		    ; #115C	; when ghost is dead
	    da :at_house	    ; #116E	; when ghost eyes are above and entering the ghost house when returning home
	    da :move_left	    ; #118F	; when ghost eyes have arrived in ghost house and when moving to left side of ghost house


; arrive here from #10AB when blue ghost (inky) is dead (eyes)
:isdead
;115c  cd861d    call    #1d86		; handle inky movement
	    jsr inky_ghost_move

;115f  2a044d    ld      hl,(#4d04)	; load HL with blue ghost (inky) position
	    lda |blue_ghost_y
;1162  116480    ld      de,#8064	; load DE with Y,X position above ghost house
;1165  a7        and     a		; clear carry flag
;1166  ed52      sbc     hl,de		; subtract.  are inky's eyes right above the ghost home?
	    cmp #$8064
;1168  c0        ret     nz		; no, return
	    bne :rts

;1169  21ae4d    ld      hl,#4dae	; yes, load HL with blue ghost (inky) state
;116c  34        inc     (hl)		; increase
	    inc |blueghost_state
;116d  c9        ret			; return
:rts
	    rts

; arrive here from #10AB when blue ghost (inky) eyes are above and entering the ghost house when returning home
:at_house
;116e  dd210133  ld      ix,#3301	; load IX with direction address tiles for moving down
	    ldx #move_down
;1172  fd21044d  ld      iy,#4d04	; load IY with inky position
	    ldy #blue_ghost_y
;1176  cd0020    call    #2000		; HL := (IX) + (IY)
	    jsr double_add
;1179  22044d    ld      (#4d04),hl	; store new position for inky
	    sta |blue_ghost_y
;117c  3e01      ld      a,#01		; A := #01
	    lda #1
;117e  322a4d    ld      (#4d2a),a	; set previous inky orientation as moving down
	    sta |prev_blue_ghost_dir
;1181  322e4d    ld      (#4d2e),a	; set inky orientation as moving down
	    sta |blue_ghost_dir
;1184  3a044d    ld      a,(#4d04)	; load A with inky Y position
	    lda |blue_ghost_y
;1187  fe80      cp      #80		; have the inky eyes fully entered the ghost house?
	    and #$00FF
	    cmp #$80
;1189  c0        ret     nz		; no, return
	    bne :rts

;118a  21ae4d    ld      hl,#4dae	; yes, load HL with blue ghost (inky) state 
;118d  34        inc     (hl)		; increase
	    inc |blueghost_state
;118e  c9        ret			; return
	    rts

; arrive here from #10AB when inky ghost eyes have arrived in ghost house and when moving to left side of ghost house
:move_left

;118f  dd210333  ld      ix,#3303	; load IX with direction address tiles for moving left
	    ldx #move_left
;1193  fd21044d  ld      iy,#4d04	; load IY with inky position
	    ldy #blue_ghost_y
;1197  cd0020    call    #2000		; HL := (IX) + (IY)
	    jsr double_add
;119a  22044d    ld      (#4d04),hl	; store new position for inky
	    sta |blue_ghost_y
;119d  3e02      ld      a,#02		; A := #02
	    lda #2
;119f  322a4d    ld      (#4d2a),a	; set previous inky orientation as moving left
	    sta |prev_blue_ghost_dir
;11a2  322e4d    ld      (#4d2e),a	; set inky orientation as moving left
	    sta |blue_ghost_dir
;11a5  3a054d    ld      a,(#4d05)	; load A with inky X position
	    lda |blue_ghost_x
;11a8  fe90      cp      #90		; has inky reached the left side of the ghost house?
	    and #$00FF
	    cmp #$0090
;11aa  c0        ret     nz		; no, return
	    bne :rts

;11ab  212f30    ld      hl,#302f	; yes, load HL with #30, #2F for tile position inside ghost house
	    lda #$302F
;11ae  220e4d    ld      (#4d0e),hl	; store into inky tile position
	    sta |blueghost_tile_y
;11b1  22354d    ld      (#4d35),hl	; store into inky tile position 2
	    sta |blue_tile_y_2
;11b4  3e01      ld      a,#01		; A := #01
	    lda #1
;11b6  322a4d    ld      (#4d2a),a	; set previous inky orientation as moving down
	    sta |prev_blue_ghost_dir
;11b9  322e4d    ld      (#4d2e),a	; set inky orientation as moving down
	    sta |blue_ghost_dir
;11bc  af        xor     a		; A := #00
;11bd  32a24d    ld      (#4da2),a	; set inky substate as at home
	    stz |blue_substate
;11c0  32ae4d    ld      (#4dae),a	; set inky state as alive
	    stz |blueghost_state
;11c3  32a94d    ld      (#4da9),a	; set inky blue flag as not edible
	    stz |blueghost_blue
;11c6  c30111    jp      #1101		; jump to check for clearing eyes sound
	    jmp ghost_arrive_home

;------------------------------------------------------------------------------
; called from #102B
;10B4
orange_ghost_death_update mx %00
;10B4: 3A AF 4D	ld	a,(#4DAF)	; load A with orange ghost state
	    lda |orangeghost_state
	    asl
	    tax
	    jmp (:table,x)
:table
	    da :rts    		   ; #000C	; return immediately when ghost is alive
	    da :is_dead   	   ; #11C9	; when ghost is dead
	    da :at_house	   ; #11DB	; when ghost eyes are above and entering the ghost house when returning home
	    da :move_right  	   ; #11FC	; when ghost eyes have arrived in ghost house and when moving to right side of ghost house
:is_dead
; arrive here from #10B7 when orange ghost is dead (eyes)

;11c9  cd5d1e    call    #1e5d		; handle orange ghost movement
	    jsr orange_ghost_move
;11cc  2a064d    ld      hl,(#4d06)	; load HL with orange ghost position
	    lda |orange_ghost_y
;11cf  116480    ld      de,#8064	; load DE with Y,X position above ghost home
;11d2  a7        and     a		; clear carry flag
;11d3  ed52      sbc     hl,de		; subtract.  is orange ghost eyes right above ghost home?
	    cmp #$8064
;11d5  c0        ret     nz		; no, return
	    bne :rts
;11d6  21af4d    ld      hl,#4daf	; yes, load HL with orange ghost state
;11d9  34        inc     (hl)		; increase
	    inc |orangeghost_state
;11da  c9        ret 			; return
:rts
	    rts

; arrive here from #10B7 when orange ghost eyes are above and entering the ghost house when returning home
:at_house
;11db  dd210133  ld      ix,#3301	; load IX with direction address tiles for moving down
	    ldx #move_down
;11df  fd21064d  ld      iy,#4d06	; load IY with orange ghost position 
	    ldy #orange_ghost_y
;11e3  cd0020    call    #2000		; HL := (IX) + (IY)
	    jsr double_add
;11e6  22064d    ld      (#4d06),hl	; store new position for orange ghost
	    sta |orange_ghost_y
;11e9  3e01      ld      a,#01		; A := #01
	    lda #1
;11eb  322b4d    ld      (#4d2b),a	; set previous orange ghost orientation as moving down
	    sta |prev_orange_ghost_dir
;11ee  322f4d    ld      (#4d2f),a	; set orange orientation as moving down
	    sta |orange_ghost_dir
;11f1  3a064d    ld      a,(#4d06)	; load A with orange ghost Y position
	    lda |orange_ghost_y
;11f4  fe80      cp      #80		; has the orange ghost eyes fully entered the ghost house?
	    and #$FF
	    cmp #$80
;11f6  c0        ret     nz		; no, return
	    bne :rts

;11f7  21af4d    ld      hl,#4daf	; yes, load HL with orange ghost state
;11fa  34        inc     (hl)		; increase
	    inc |orangeghost_state
;11fb  c9        ret			; return
	    rts

; arrive here from #10B7 when orange ghost eyes have arrived in ghost house and when moving to right side of ghost house
:move_right
;11fc  dd21ff32  ld      ix,#32ff	; load IX with direction address tiles for moving right
	    ldx #move_right
;1200  fd21064d  ld      iy,#4d06	; load IY with orange ghost position 
	    ldy #orange_ghost_y
;1204  cd0020    call    #2000		; HL := (IX) + (IY)
	    jsr double_add
;1207  22064d    ld      (#4d06),hl	; store new position for orange ghost
	    sta |orange_ghost_y
;120a  af        xor     a		; A := #00
;120b  322b4d    ld      (#4d2b),a	; set previous orange ghost orientation as moving right
	    stz |prev_orange_ghost_dir
;120e  322f4d    ld      (#4d2f),a	; set orange orientation as moving right
	    stz |orange_ghost_dir
;1211  3a074d    ld      a,(#4d07)	; load A with orange ghost X position
	    lda |orange_ghost_x
;1214  fe70      cp      #70		; has the orange ghost reached the right side of the ghost house?
	    and #$FF
	    cmp #$70
;1216  c0        ret     nz		; no, return
	    bne :rts

;1217  212f2c    ld      hl,#2c2f	; yes, load HL with tile position of the right side of ghost house
	    lda #$2c2f
;121a  22104d    ld      (#4d10),hl	; store into orange ghost tile position
	    sta |orangeghost_tile_y
;121d  22374d    ld      (#4d37),hl	; store into orange ghost tile position 2
	    sta |orange_tile_y_2
;1220  3e01      ld      a,#01		; A := #01
	    lda #1
;1222  322b4d    ld      (#4d2b),a	; set previous orange ghost orientation as moving down
	    sta |prev_orange_ghost_dir
;1225  322f4d    ld      (#4d2f),a	; set orange ghost orientation as moving down
	    sta |orange_ghost_dir
;1228  af        xor     a		; A := #00
;1229  32a34d    ld      (#4da3),a	; set orange ghost substate as at home
	    stz |orange_substate
;122c  32af4d    ld      (#4daf),a	; set orange ghost state as alive
	    stz |orangeghost_state
;122f  32aa4d    ld      (#4daa),a	; set orange ghost blue flag as not edible
	    stz |orangeghost_blue
;1232  c30111    jp      #1101		; jump to check for clearing eyes sound
	    jmp ghost_arrive_home

;------------------------------------------------------------------------------
; called from #1035
; arrive here when a ghost is eaten, or after the point score for eating a ghost is set to vanish
;1235
ghost_eat_process mx %00
;1235: 3A D1 4D	ld	a,(#4DD1)	; load A with killed ghost animation state
;1238: E7 	rst  #20		; jump based on A
	    lda |dead_ghost_anim_state
	    asl
	    tax
	    jmp (:table,x)
:table
	    da :process    ; #123F	; a ghost is being eaten
	    da :rts        ; #000C	; return immediately
	    da :process    ; #123F	; point score is set to vanish

:rts	    rts
:process
;123f  21004c    ld      hl,#4c00	; load HL with starting address for ghost sprites and colors
;1242  3aa44d    ld      a,(#4da4)	; load A with # of ghost killed but no collision for yet
;1245  87        add     a,a		; A := A * 2
;1246  5f        ld      e,a		; store into E
;1247  1600      ld      d,#00		; clear D
;1249  19        add     hl,de		; add.  now HL has the sprite address of the ghost killed

	    lda |num_ghosts_killed
	    asl
	    asl
	    tax

;124a  3ad14d    ld      a,(#4dd1)	; load A with killed ghost animation state
	    lda |dead_ghost_anim_state
;124d  a7        and     a		; is this ghost killed, showing points per kill ?
;124e  2027      jr      nz,#1277        ; no, skip ahead
	    bne next_gep
;
;1250  3ad04d    ld      a,(#4dd0)	; yes, load A with current number of killed ghosts
	    lda |num_killed_ghosts
;1253  0627      ld      b,#27		; B := #27
;1255  80        add     a,b		; add together to choose correct sprite (200, 400, 800 or 1600)
	    clc
	    adc #$27

	    ; We don't need cocktail stuff
;1256  47        ld      b,a		; store result into B
;1257  3a724e    ld      a,(#4e72)	; load A with cocktail mode (0=no, 1=yes)
;125a  4f        ld      c,a		; copy to C
;125b  3a094e    ld      a,(#4e09)	; load A with current player number (0=P1, 1=P2)
;125e  a1        and     c		; is this player 2 and cocktail mode ?
;125f  2804      jr      z,#1265         ; no, skip next 2 steps
;
;1261  cbf0      set     6,b		; set bit 6 of B
;1263  cbf8      set     7,b		; set bit 7 of B
;
;1265  70        ld      (hl),b		; store B into ghost sprite score
	    sta |allsprite,x
;1266  23        inc     hl		; HL now has ghost sprite color
;1267  3618      ld      (hl),#18	; store color #18
	    lda #$18
	    sta |allsprite+2,x
;1269  3e00      ld      a,#00		; A := #00
;126b  320b4c    ld      (#4c0b),a	; store into pacman sprite color
	    stz |pacmancolor
;126e  f7        rst     #30		; set timed task to increase killed ghost animation state when a ghost is eaten
;126f  4a 03 00				; task timer=#4A, task=3, param=0.  
	    lda #$034a
	    ldy #0
	    jsr rst30

; arrive here from task table when a ghost has been eaten.  Task #03, arrive from #0246
ttask3 mx %00
;1272  21d14d    ld      hl,#4dd1	; load HL with killed ghost animation state
;1275  34        inc     (hl)		; increase to next type
	    inc |dead_ghost_anim_state
;1276  c9        ret     		; return
	    rts

; arrive here when score for eating a ghost is set to dissapear
next_gep
;1277: 36 20	ld	(hl),#20	; set ghost sprite to eyes
	    lda #$20
	    sta |allsprite,x
;1279: 3E 09	ld	a,#09		; load A with #09
	    lda #9
;127B: 32 0B 4C	ld	(#4C0B),a	; store into pacman sprite color to restore pacman to screen
	    sta |pacmancolor
;127E: 3A A4 4D	ld	a,(#4DA4)	; load A with # of ghost killed but no collision for yet
	    lda |num_ghosts_killed
;1281: 32 AB 4D	ld	(#4DAB),a	; store into killing ghost state
	    sta |killghost_state
;1284: AF	xor	a		; A := #00
;1285: 32 A4 4D	ld	(#4DA4),a	; store into # of ghost killed but no collision for yet
	    stz |num_ghosts_killed
;1288: 32 D1 4D	ld	(#4DD1),a	; store into killed ghost animation state
	    stz |dead_ghost_anim_state
;128B: 21 AC 4E	ld	hl,#4EAC	; load HL with sound channel 2
;128E: CB F6	set	6,(hl)		; play sound for ghost eyes
	    lda #%01000000
	    tsb |CH2_E_NUM
;1290: C9	ret			; return
	    rts

;------------------------------------------------------------------------------
;
; State Machine for MsPacman Death Sequence
;
; called from #052C, #052F, #08EB and #08EE 
mspac_death_update mx %00
	    lda |pacman_dead_state
	    asl
	    tax
	    jmp (:table,x)

;1295
:table
	    da :alive         ; #000C ; alive returns immediately
	    da :counter       ; #12B7 ; increase counter
	    da :counter       ; #12B7 ; increase counter
	    da :counter       ; #12B7 ; increase counter
	    da :counter       ; #12B7 ; increase counter

	    da :dead_state_1  ; #12CB	; animate dead mspac
	    da :dead_state_2  ; #12F9	; animate dead mspac + start dying sound
	    da :dead_state_3  ; #1306	; animate dead mspac
	    da :dead_state_4  ; #130E	; animate dead mspac
	    da :dead_state_5  ; #1316	; animate dead mspac
	    da :dead_state_6  ; #131E	; animate dead mspac
	    da :dead_state_7  ; #1326	; animate dead mspac
	    da :dead_state_8  ; #132E	; animate dead mspac
	    da :dead_state_9  ; #1336	; animate dead mspac
	    da :dead_state_10 ; #133E	; animate dead mspac
	    da :dead_state_11 ; #1346	; animate dead mspac + clear sound
	    da :dead_state_12 ; #1353	; animate last time, decrease lives, clear ghosts, increase game state

;12b7   ; increase counter
:counter    inc |pacman_dead_counter
	    lda #$78
	    cmp |pacman_dead_counter
	    bne :alive			; short cut to rts

	    lda #5
	    sta |pacman_dead_state

;000c - do nothing
:alive	    rts

:dead_state_1

	    jsr clear_ghosts		; hide the ghosts

; choose a different sprite for cocktail mode
; we don't support this, so I didn't port this

; death animation display
; 12e5
	    ldx #$34   ;sprite number
	    ldy #$b4   ; time

:dead_anim
	    stx |pacmansprite		; sprite frame/tile #

	    inc |pacman_dead_counter
	    cpy |pacman_dead_counter
	    bne :rts

	    inc |pacman_dead_state
:rts
	    rts
;12F9
:dead_state_2
	    ; set dying sound
	    lda #8
	    tsb |bnoise		; enable dying sound

	    ldx #$35		; sprite number
	    ldy #$c3    	; time
	    bra	:dead_anim
;1306
:dead_state_3
	    ldx #$36		; sprite no
	    ldy #$d2
	    bra :dead_anim
;130e
:dead_state_4
	    ldx #$37		; mspac sprite := #37  Frame 3
	    ldy #$00e1		; timer := #E1
	    bra :dead_anim

:dead_state_5  ; #1316	; animate dead mspac
	    ldx #$38		; mspac sprite := #38  Frame 4
	    ldy #$00f0		; timer := #F0
	    bra :dead_anim

:dead_state_6  ; #131E	; animate dead mspac
	    ldx #$39		; mspac sprite := #39  Frame 5
	    ldy #$00ff		; timer := #FF
	    bra :dead_anim

:dead_state_7  ; #1326	; animate dead mspac
	    ldx #$3a		; mspac sprite := #3A  Frame 6
	    ldy #$010e		; timer := #10E
	    bra :dead_anim

:dead_state_8  ; #132E	; animate dead mspac
	    ldx #$3b   		; mspac sprite := #3B  Frame 7
	    ldy #$011d 		; timer := #11D
	    bra :dead_anim

:dead_state_9  ; #1336	; animate dead mspac
	    ldx #$3c		; mspac sprite := #3C  Frame 8
	    ldy #$012c		; timer := #12C
	    bra :dead_anim

:dead_state_10 ; #133E	; animate dead mspac
	    ldx #$3d		; mspac sprite := #3D  Frame 9
	    ldy #$013b		; timer := #13B
	    bra :dead_anim

:dead_state_11 ; #1346	; animate dead mspac + clear sound
	    stz |bnoise		; clear sound
	    ldx #$3e		; mspac sprite = #3E  Frame 10
	    ldy #$0159		; timer := #159
	    bra :dead_anim

:dead_state_12 ; #1353	; animate last time, decrease lives, clear ghosts, increase game state

	    lda #$3F		; set the sprite frame
	    sta |pacmansprite

	    inc |pacman_dead_counter

	    lda #$1b8
	    cmp |pacman_dead_counter

	    bne :return

	    ; times up

	; decrement lives
	; this gets called after the death animation, but before the screen gets redrawn.
	; -- probably a good hook point for 'insert coin to contunue' --
	; 1366
	    dec |num_lives
	    dec |displayed_lives
	    inc |levelstate
	    jsr task_clearActors
:return
	    rts

;------------------------------------------------------------------------------
;; routine to control blue time
;; ret immediately to make ghosts stay blue till eaten 
;1376
control_blue_time mx %00
;1376  3aa64d    ld      a,(#4da6)	; load A with power pill effect (1=active, 0=no effect)
	    lda |powerpill
;1379  a7        and     a		; is a power pill active ?
;137a  c8        ret     z		; no, return
	    bne :continue
:rts
	    rts
:continue
;137b  dd21a74d  ld      ix,#4da7	; yes, load IX with ghost blue flag starting address
;137f  dd7e00    ld      a,(ix+#00)	; load A with red ghost blue flag
	    lda |redghost_blue
;1382  ddb601    or      (ix+#01)	; OR with pink ghost blue flag
	    ora |pinkghost_blue
;1385  ddb602    or      (ix+#02)	; OR with blue ghost (inky) blue flag
	    ora |blueghost_blue
;1388  ddb603    or      (ix+#03)	; OR with oragne ghost blue flag
	    ora |orangeghost_blue
;138b  ca9813    jp      z,#1398		; if all ghosts are not blue, then skip ahead and reset power pill effect
	    beq :none_blue

;138e  2acb4d    ld      hl,(#4dcb)	; else load HL with blue ghost counter
;1391  2b        dec     hl		; count down
;1392  22cb4d    ld      (#4dcb),hl	; store result
	    dec |ghosts_blue_timer
;1395  7c        ld      a,h		; load A with counter high byte
;1396  b5        or      l		; or with counter low byte.  are both counters at #00 ?
;1397  c0        ret     nz		; no, return
	    bne :rts

; arrive here when power pill effect is over, either by timer or by eating all ghosts
:none_blue
;1398  210b4c    ld      hl,#4c0b	; load HL with pacman color entry
;139b  3609      ld      (hl),#09	; store #09 into pacman color entry
	    lda #9
	    sta |pacmancolor
;139d  3aac4d    ld      a,(#4dac)	; load A with red ghost state
	    lda |redghost_state
;13a0  a7        and     a		; is red ghost alive ?
;13a1  c2a713    jp      nz,#13a7	; yes, skip next step
	    bne :red_alive

;13a4  32a74d    ld      (#4da7),a	; clear red ghost blue state
	    stz |redghost_blue
:red_alive
;13a7  3aad4d    ld      a,(#4dad)	; load A with pink ghost state
	    lda |pinkghost_state
;13aa  a7        and     a		; is pink ghost alive ?
;13ab  c2b113    jp      nz,#13b1	; yes, skip next step
	    bne :pink_alive

;13ae  32a84d    ld      (#4da8),a	; clear pink ghost blue state
	    stz |pinkghost_blue
:pink_alive
;13b1  3aae4d    ld      a,(#4dae)	; load A with blue ghost (inky) state
	    lda |blueghost_state
;13b4  a7        and     a		; is inky alive ?
;13b5  c2bb13    jp      nz,#13bb	; yes, skip next step
	    bne :blue_alive

;13b8  32a94d    ld      (#4da9),a	; clear inky blue state
	    stz |blueghost_blue
:blue_alive
;13bb  3aaf4d    ld      a,(#4daf)	; load A with orange ghost state
	    lda |orangeghost_state
;13be  a7        and     a		; is orange ghost alive ?
;13bf  c2c513    jp      nz,#13c5	; yes, skip next step
	    bne :orange_dead

;13C2: 32 AA 4D	ld	(#4DAA),a	; clear orange ghost blue state
	    stz |orangeghost_blue
:orange_dead

;13C5: AF	xor	a		; A := #00
;13C6: 32 CB 4D	ld	(#4DCB),a	; clear counter while ghosts are blue
;13C9: 32 CC 4D	ld	(#4DCC),a	; clear counter while ghosts are blue
	    stz |ghosts_blue_timer
;13CC: 32 A6 4D	ld	(#4DA6),a	; clear pill effect
	    stz |powerpill
;13CF: 32 C8 4D	ld	(#4DC8),a	; clear counter used to change ghost colors under big pill effects
	    stz |big_pill_timer
;13D2: 32 D0 4D	ld	(#4DD0),a	; clear current number of killed ghosts
	    stz |num_killed_ghosts
;13D5: 21 AC 4E	ld	hl,#4EAC	; load HL with sound channel 2
	    lda #%10100000
;13D8: CB AE	res	5,(hl)		; clear sound bit 5
;13DA: CB BE	res	7,(hl)		; clear sound bit 7
	    trb |CH2_E_NUM
;13DC: C9	ret			; return
	    rts

;------------------------------------------------------------------------------
; arrive here from call at #08F1
; 13dd
ghosthouse mx %00
;13dd  219e4d    ld      hl,#4d9e	; load HL with address related to number of pills eaten before last pacman move
	    lda |RTNOPEBLPM
;13e0  3a0e4e    ld      a,(#4e0e)	; load A with # of pills eaten
;13e3  be        cp      (hl)		; are they equal ?
	    cmp |dotseat
;13e4  caee13    jp      z,#13ee		; yes, skip ahead
	    beq :skip
;13e7  210000    ld      hl,#0000	; else HL := #0000
;13ea  22974d    ld      (#4d97),hl	; clear inactivity counter
	    stz |home_counter3
;13ed  c9        ret     		; return
:rts
	    rts
:skip
;13ee  2a974d    ld      hl,(#4d97)	; load HL with inactivity counter
;13f1  23        inc     hl		; increment
;13f2  22974d    ld      (#4d97),hl	; store
	    inc |home_counter3
;13f5  ed5b954d  ld      de,(#4d95)	; load DE with number of units before ghost leaves home (no change w/ pills)
	    lda |home_counter1
;13f9  a7        and     a		; clear carry flag
;13fa  ed52      sbc     hl,de		; subtract.  are they equal ?
	    cmp |home_counter3
;13fc  c0        ret     nz		; no, return
	    bne :rts

;13fd  210000    ld      hl,#0000	; else HL := #0000
;1400  22974d    ld      (#4d97),hl	; clear inactivity counter
	    stz |home_counter3
;1403  3aa14d    ld      a,(#4da1)	; load A with pink ghost substate
	    lda |pink_substate
;1406  a7        and     a		; is pink ghost in the ghost house ?
	    bne :next_ghost
;1407  f5        push    af		; save AF
;1408  cc8620    call    z,#2086		; yes, then call this sub which will release the pink ghost
	    jmp release_pink
;140b  f1        pop     af		; restore AF
;140c  c8        ret     z		; yes, then return
:next_ghost
;140d  3aa24d    ld      a,(#4da2)	; else load A with blue (inky) ghost state
	    lda |blue_substate
;1410  a7        and     a		; is inky in the ghost house ?
	    bne :next_ghost2
;1411  f5        push    af		; save AF
;1412  cca920    call    z,#20a9		; yes, then call this sub which will release Inky
	    jmp release_blue
;1415  f1        pop     af		; restore AF
;1416  c8        ret     z		; yes, then return
:next_ghost2
;1417  3aa34d    ld      a,(#4da3)	; else load A with orange ghost state
	    lda |orange_substate
	    bne :rts
;141a  a7        and     a		; is orange ghost in the ghost house?
;141b  ccd120    call    z,#20d1		; yes, then call this sub which will release orange ghost
;141e  c9        ret     		; return
	    jmp release_orange

;------------------------------------------------------------------------------
; called from #019E during core game loop
; display the sprites in the intro and game and cutscenes
;1490
sprite_updater mx %00
;1490  3a724e    ld      a,(#4e72)	; load A with cocktail mode
;1493  47        ld      b,a		; store into B
;1494  3a094e    ld      a,(#4e09)	; load A with player number
;1497  a0        and     b		; is this player 2 and cocktail mode ?
;1498  c0        ret     nz		; yes, return

; we already blit from these 4D00 into the Foenix
; sprite hardware, so do we really needy to do these?

;1499  47        ld      b,a			; B := #00
;149a  1e09      ld      e,#09		; E := #09
;149c  0e07      ld      c,#07		; C := #07
;149e  1606      ld      d,#06		; D := #06
;14a0  dd21004c  ld      ix,#4c00	; load IX with starting address of sprite values

;14a4  3a004d    ld      a,(#4d00)	; load A with red ghost Y position
;14a7  2f        cpl			; invert A
;14a8  83        add     a,e		; Add #09
;14a9  dd7713    ld      (ix+#13),a	; store into #4C13 (?)

;14ac  3a014d    ld      a,(#4d01)	; load A with red ghost X position
;14af  82        add     a,d		; add #06
;14b0  dd7712    ld      (ix+#12),a	; store into #4C12 (?)

;14b3  3a024d    ld      a,(#4d02)	; load A with pink ghost Y position
;14b6  2f        cpl     		; invert
;14b7  83        add     a,e		; add #09
;14b8  dd7715    ld      (ix+#15),a	; store into #4C15 (?)

;14bb  3a034d    ld      a,(#4d03)	; load A with pink ghost X position
;14be  82        add     a,d		; add #06
;14bf  dd7714    ld      (ix+#14),a	; store into #4C14 (?)

;14c2  3a044d    ld      a,(#4d04)	; load A with inky Y position
;14c5  2f        cpl     		; invert
;14c6  83        add     a,e		; add #06
;14c7  dd7717    ld      (ix+#17),a	; store into #4C17 (?)

;14ca  3a054d    ld      a,(#4d05)	; load A with inky X position
;14cd  81        add     a,c		; add #07
;14ce  dd7716    ld      (ix+#16),a	; store into #4C16 (?)

;14d1  3a064d    ld      a,(#4d06)	; load A with orange ghost Y position
;14d4  2f        cpl     		; invert
;14d5  83        add     a,e		; add #09
;14d6  dd7719    ld      (ix+#19),a	; store into #4C19 (?)

;14d9  3a074d    ld      a,(#4d07)	; load A with orange ghost X position
;14dc  81        add     a,c		; add #07
;14dd  dd7718    ld      (ix+#18),a	; store into #4C18 (?)

;14e0  3a084d    ld      a,(#4d08)	; load A with pacman Y position
;14e3  2f        cpl     		; invert
;14e4  83        add     a,e		; add #09
;14e5  dd771b    ld      (ix+#1b),a	; store into #4C1B (?)

;14e8  3a094d    ld      a,(#4d09)	; load A with pacman X position
;14eb  81        add     a,c		; add #07
;14ec  dd771a    ld      (ix+#1a),a	; store into #4C1A (?)

;14ef  3ad24d    ld      a,(#4dd2)	; load A with fruit Y position
;14f2  2f        cpl     		; invert
;14f3  83        add     a,e		; add #09
;14f4  dd771d    ld      (ix+#1d),a	; store into #4C1D (?)

;14f7  3ad34d    ld      a,(#4dd3)	; load A with fruit X position
;14fa  81        add     a,c		; add #07
;14fb  dd771c    ld      (ix+#1c),a	; store into #4C1C (?)

; also arrive here if player 2 and cocktail mode from #148D

;14fe  3aa54d    ld      a,(#4da5)	; load A with pacman dead animation state (0 if not dead)
;1501  a7        and     a		; is pacman dead ?
;1502  c24b15    jp      nz,#154b	; yes, jump ahead
		lda |pacman_dead_state
		bne :pacman_dead

;1505  3aa44d    ld      a,(#4da4)	; no, load A with # of ghost killed but no collision for yet
;1508  a7        and     a		; are we currently eating a ghost ?
;1509  c2b415    jp      nz,#15b4	; yes, jump ahead
		lda |num_ghosts_killed
		bnel :killed_ghost

;150c  211c15    ld      hl,#151c	; no, load HL with return address
;150f  e5        push    hl		; push return address to stack so RET comes back to #151C
		pea :return_here-1

;1510: 3A 30 4D	ld	a,(#4D30)	; load A with pacman orientation
;1513: E7	rst	#20		; jump based on which way pac man is facing - for drawing sprite frames to the screen
		lda |pacman_dir
		asl
		tax
		jmp (:jmptable,x)

:jmptable
		da :right ; #168C	; right
		da :down  ; #16B1	; down
		da :left  ; #16D6	; left
		da :up    ; #16F7	; up

:return_here
; cocktail support
;151C: 78	ld	a,b		; load A with B which was created earlier to indicate 2 player and cocktail
;151D: A7	and	a		; is this player 2 and cocktail mode ?
;151e  282b      jr      z,#154b         ; no, skip ahead
;
;1520  0ec0      ld      c,#c0		; yes, C := #C0
;1522  3a0a4c    ld      a,(#4c0a)	; load A with mspac sprite number
;1525  57        ld      d,a		; copy into D
;1526  a1        and     c		; apply mask of #1100 0000 = #C0
;1527  2005      jr      nz,#152e        ; not zero, skip ahead
;
;1529  7a        ld      a,d		; zero, load A with original value
;152a  b1        or      c		; turn on bits 7 and 6
;152b  c34815    jp      #1548		; skip ahead
;
;152e  3a304d    ld      a,(#4d30)	; load A with pacman orientation
;1531  fe02      cp      #02		; pacman facing left ?
;1533  2009      jr      nz,#153e        ; no, skip ahead
;
;1535  cb7a      bit     7,d		; yes, turn on bit 7 of D
;1537  2812      jr      z,#154b         ; if zero, skip ahead
;
;1539  7a        ld      a,d		; else A := D
;153a  a9        xor     c		; flip bits 6 and 7
;153b  c34815    jp      #1548		; skip ahead
;
;153e  fe03      cp      #03		; pacman facing up ?
;1540  2009      jr      nz,#154b        ; no, skip ahead
;
;1542  cb72      bit     6,d		; yes, turn on bit 6 of D
;1544  2805      jr      z,#154b         ; if zero, skip ahead
;
;1546  7a        ld      a,d		; else A := D
;1547  a9        xor     c		; flip bits 6 and 7
;
;1548  320a4c    ld      (#4c0a),a	; store result into mspac sprite number

; the next section of code toggles the sprites for the ghosts based on the counter that flips every 8 frames
:pacman_dead
;154b  21c04d    ld      hl,#4dc0	; load HL with counter that changes from 0 to 1 and back every 8 frames; used for ghost animations
;154e  56        ld      d,(hl)		; load D with the counter
			lda |ghost_anim_counter
;154f  3e1c      ld      a,#1c		; A := #1C
;1551  82        add     a,d		; add to counter
			clc
			adc #$1C

; toggle between #1C and #1D (edible ghost sprites) for all ghosts ... those that are not edible are changed again later

;1552  dd7702    ld      (ix+#02),a	; store into red ghost sprite
			sta |redghostsprite
;1555  dd7704    ld      (ix+#04),a	; store into pink ghost sprite
			sta |pinkghostsprite
;1558  dd7706    ld      (ix+#06),a	; store into inky sprite
			sta |blueghostsprite
;155b  dd7708    ld      (ix+#08),a	; store into orange ghost sprite
			sta |orangeghostsprite

;155e  0e20      ld      c,#20		; C := #20

;1560  3aac4d    ld      a,(#4dac)	; load A with red ghost state
;1563  a7        and     a		; is red ghost alive ?
;1564  2006      jr      nz,#156c        ; no, skip next 3 steps
			lda |redghost_state
			bne :red_dead

;1566  3aa74d    ld      a,(#4da7)	; yes, load A with red ghost blue flag (0=not blue)
;1569  a7        and     a		; is red ghost blue (edible) ?
			lda |redghost_blue
;156a  2009      jr      nz,#1575        ; yes, skip ahead and check next ghost
			bne :do_pink

:red_dead
;156c  3a2c4d    ld      a,(#4d2c)	; no, load A with red ghost orientation
			lda |red_ghost_dir
;156f  87        add     a,a		; A := A * 2
			asl
;1570  82        add     a,d		; A := A + D
			adc |ghost_anim_counter
;1571  81        add     a,c		; A := A + #20
			adc #$20
;1572  dd7702    ld      (ix+#02),a	; store into red ghost sprite
			sta |redghostsprite

:do_pink
;1575  3aad4d    ld      a,(#4dad)	; load A with pink ghost state
;1578  a7        and     a		; is pink ghost alive ?
;1579  2006      jr      nz,#1581        ; no, skip next 3 steps
			lda |pinkghost_state
			bne :pink_dead

;157b  3aa84d    ld      a,(#4da8)	; load A with pink ghost blue flag
;157e  a7        and     a		; is pink ghost blue (edible) ?
;157f  2009      jr      nz,#158a        ; yes, skip ahead and check next ghost
			lda |pinkghost_blue
			bne :do_blue

:pink_dead
;1581  3a2d4d    ld      a,(#4d2d)	; no, load A with pink ghost orientation
			lda |pink_ghost_dir
;1584  87        add     a,a		; A := A * 2
			asl
;1585  82        add     a,d		; A := A + D
			adc |ghost_anim_counter
;1586  81        add     a,c		; A := A + #20
			adc #$20
;1587  dd7704    ld      (ix+#04),a	; store into pink ghost sprite
			sta |pinkghostsprite

:do_blue
;158a  3aae4d    ld      a,(#4dae)	; load A with inky state
;158d  a7        and     a		; is inky alive ?
;158e  2006      jr      nz,#1596        ; no, skip next 3 steps
			lda |blueghost_state
			bne :blue_dead

;1590  3aa94d    ld      a,(#4da9)	; load A with inky blue flag
;1593  a7        and     a		; is inky edible ?
;1594  2009      jr      nz,#159f        ; yes, skip ahead and check next ghost
			lda |blueghost_blue
			bne :do_orange
:blue_dead
;1596  3a2e4d    ld      a,(#4d2e)	; no, load A with inky orientation
			lda |blue_ghost_dir
;1599  87        add     a,a		; A := A * 2
			asl
;159a  82        add     a,d		; A := A + D
			adc |ghost_anim_counter
;159b  81        add     a,c		; A := A + #20
			adc #$20
;159c  dd7706    ld      (ix+#06),a	; store into inky sprite
			sta |blueghostsprite

:do_orange
;159f  3aaf4d    ld      a,(#4daf)	; load A with orange ghost state
;15a2  a7        and     a		; is orange ghost alive ?
;15a3  2006      jr      nz,#15ab        ; no, skip next 3 steps
			lda |orangeghost_state
			bne :orange_dead

;15a5  3aaa4d    ld      a,(#4daa)	; load A with orange ghost blue flag
;15a8  a7        and     a		; is orange ghost blue (edible) ?
;15a9  2009      jr      nz,#15b4        ; yes, skip ahead
			lda |orangeghost_blue
			bne :skip_orange
:orange_dead
;15ab  3a2f4d    ld      a,(#4d2f)	; load A with orange ghost orienation
			lda |orange_ghost_dir
;15ae  87        add     a,a		; A = A * 2
			asl
;15af  82        add     a,d		; A = A + D
			adc |ghost_anim_counter
;15b0  81        add     a,c		; A = A + #20
			adc #$20
;15b1  dd7708    ld      (ix+#08),a	; store into orange ghost sprite
			sta |orangeghostsprite
:skip_orange
:killed_ghost

;15b4  cde615    call    #15e6		; check for and handle big pac-man sprites in 1st cutscene (pac-man only)
;15b7  cd2d16    call    #162d		; check for and handle sprites in 2nd cutscene (pac-man only)
;15ba  cd5216    call    #1652		; check for and handle sprites in 3rd cutscene (pac-man only)

;15bd  78        ld      a,b		; A := B
;15be  a7        and     a		; is this player 2 and cocktail mode ?
;15bf  c8        ret     z		; no, return

; 2 player and cocktail

;15c0  0ec0      ld      c,#c0		; C := #C0 (binary 1100 0000)
;
;15c2  3a024c    ld      a,(#4c02)	; load A with red ghost sprite
;15c5  b1        or      c		; make upside down
;15c6  32024c    ld      (#4c02),a	; store
;
;15c9  3a044c    ld      a,(#4c04)	; load A with pink ghost sprite
;15cc  b1        or      c		; make upside down
;15cd  32044c    ld      (#4c04),a	; store
;
;15d0  3a064c    ld      a,(#4c06)	; load A with inky sprite
;15d3  b1        or      c		; make upside down
;15d4  32064c    ld      (#4c06),a	; store
;
;15d7  3a084c    ld      a,(#4c08)	; load A with orange ghost sprite
;15da  b1        or      c		; make upside down
;15db  32084c    ld      (#4c08),a	; store
;
;15de  3a0c4c    ld      a,(#4c0c)	; load A with pacman sprite
;15e1  b1        or      c		; make upside down
;15e2  320c4c    ld      (#4c0c),a	; store
;15e5  c9        ret     		; return
			rts

; called from #15B4

;15e6  3a064e    ld      a,(#4e06)	; load A with state in first cutscene
;15e9  d605      sub     #05		; is this cutscene state <= 5 ?
;15eb  d8        ret     c		; yes, return

; pac-man only, not used in ms. pac
; arrive here when the big pac-man needs to be animated in the 1st cutscene

;15ec  3a094d    ld      a,(#4d09)
;15ef  e60f      and     #0f
;15f1  fe0c      cp      #0c
;15f3  3804      jr      c,#15f9         ; (4)

;15f5  1618      ld      d,#18
;15f7  1812      jr      #160b           ; (18)

;15f9  fe08      cp      #08
;15fb  3804      jr      c,#1601         ; (4)

;15fd  1614      ld      d,#14
;15ff  180a      jr      #160b           ; (10)

;1601  fe04      cp      #04
;1603  3804      jr      c,#1609         ; (4)

;1605  1610      ld      d,#10
;1607  1802      jr      #160b           ; (2)

;1609  1614      ld      d,#14
;160b  dd7204    ld      (ix+#04),d
;160e  14        inc     d
;160f  dd7206    ld      (ix+#06),d
;1612  14        inc     d
;1613  dd7208    ld      (ix+#08),d
;1616  14        inc     d
;1617  dd720c    ld      (ix+#0c),d
;161a  dd360a3f  ld      (ix+#0a),#3f
;161e  1616      ld      d,#16
;1620  dd7205    ld      (ix+#05),d
;1623  dd7207    ld      (ix+#07),d
;1626  dd7209    ld      (ix+#09),d
;1629  dd720d    ld      (ix+#0d),d
;162c  c9        ret     

; called from #15B7

;162d  3a074e    ld      a,(#4e07)	; load A with state in second cutscene
;1630  a7        and     a		; == #00 ?
;1631  c8        ret     z		; yes, return

; pac-man only, not used in ms. pac
; arrive here during 2nd cutscene

;1632  57        ld      d,a
;1633  3a3a4d    ld      a,(#4d3a)
;1636  d63d      sub     #3d
;1638  2004      jr      nz,#163e        ;

;163a  dd360b00  ld      (ix+#0b),#00
;163e  7a        ld      a,d
;163f  fe0a      cp      #0a
;1641  d8        ret     c

;1642  dd360232  ld      (ix+#02),#32
;1646  dd36031d  ld      (ix+#03),#1d
;164a  fe0c      cp      #0c
;164c  d8        ret     c

;164d  dd360233  ld      (ix+#02),#33
;1651  c9        ret     

; called from #15BA

;1652  3a084e    ld      a,(#4e08)	; load A with state in third cutscene
;1655  a7        and     a		; == #00 ?
;1656  c8        ret     z		; yes, return

; pac-man only, not used is ms. pac
; arrive here during 3rd cutscene

;1657  57        ld      d,a
;1658  3a3a4d    ld      a,(#4d3a)
;165b  d63d      sub     #3d
;165d  2004      jr      nz,#1663        ; (4)

;165f  dd360b00  ld      (ix+#0b),#00
;1663  7a        ld      a,d
;1664  fe01      cp      #01
;1666  d8        ret     c

;1667  3ac04d    ld      a,(#4dc0)
;166a  1e08      ld      e,#08
;166c  83        add     a,e
;166d  dd7702    ld      (ix+#02),a
;1670  7a        ld      a,d
;1671  fe03      cp      #03
;1673  d8        ret     c

;1674  3a014d    ld      a,(#4d01)
;1677  e608      and     #08
;1679  0f        rrca    
;167a  0f        rrca    
;167b  0f        rrca    
;167c  1e0a      ld      e,#0a
;167e  83        add     a,e
;167f  dd770c    ld      (ix+#0c),a
;1682  3c        inc     a
;1683  3c        inc     a
;1684  dd7702    ld      (ix+#02),a
;1687  dd360d1e  ld      (ix+#0d),#1e
;168b  c9        ret     


; arrive here when pac man is facing right from #1513

; MOVING EAST
:right
;168c  c39c86    jp      #869c		; jump to ms. pacman patch to animate ms pac
; arrive from #168C when ms pac is facing right
; MSPAC MOVING EAST
;869c  3a094d    ld      a,(#4d09)	; load A with pacman X position
			lda |pacman_x
;869f  e607      and     #07		; mask bits, now between #00 and #07
			and #$07
;86a1  cb3f      srl     a		; shift right, now between #00 and #03
			lsr
;86a3  2f        cpl     		; invert
			eor #$FFFF
;86a4  1e30      ld      e,#30		; E := #30
;86a6  83        add     a,e		; add #30
			clc
			adc #$30
;86a7  cb47      bit     0,a		; test bit 0.  is it on ?
			bit #1
;86a9  2002      jr      nz,#86ad        ; yes, skip next step
			bne :skip1
;86ab  3e37      ld      a,#37		; no, A := #37
			lda #$37
:skip1
;86ad  320a4c    ld      (#4c0a),a	; store into mspac sprite number
			sta |pacmansprite
;86b0  c9        ret			; return
			rts


; arrive here when pac man is facing down from #1513
; MOVING SOUTH
:down
;16b1  c3b186    jp      #86b1		; jump to ms. pacman patch to animate ms pac
; arrive from #16B1 when ms pac is facing down
; MSPAC MOVING SOUTH
;86b1  3a084d    ld      a,(#4d08)	; load A with pacman Y position
			lda |pacman_y
;86b4  e607      and     #07		; mask bits, now between #00 and #07
			and #$07
;86b6  cb3f      srl     a		; shift right, now between #00 and #03
			lsr
;86b8  1e30      ld      e,#30		; E := #30
;86ba  83        add     a,e		; add #30
			clc
			adc #$30
;86bb  cb47      bit     0,a		; test bit 0.  is it on ?
			bit #1
;86bd  2002      jr      nz,#86c1        ; yes, skip next step
			bne :skip2
;86bf  3e34      ld      a,#34		; no, A := #34
			lda #$34
:skip2
;86c1  320a4c    ld      (#4c0a),a	; store into mspac sprite number
			sta |pacmansprite
;86c4  c9        ret			; return
			rts

; arrive here when pac man is facing left from #1513
; MOVING WEST
:left
;16d6  3a094d    ld      a,(#4d09)
;16d9  c3c586    jp      #86c5		; jump to ms. pacman patch to animate ms pac
; arrive from #16D9 when ms pac is facing left
; MSPAC MOVING WEST
;86c5  3a094d    ld      a,(#4d09)	; load A with pacman X position
			lda |pacman_x
;86c8  e607      and     #07		; mask bits, now between #00 and #07
			and #$7
;86ca  cb3f      srl     a		; shift right, now between #00 and #03
			lsr
;86cc  1eac      ld      e,#ac		; E := #AC
;86ce  83        add     a,e		; add #AC
			clc
			adc #$ac
;86cf  cb47      bit     0,a		; test bit 0 , is it on ?
			bit #1
;86d1  2002      jr      nz,#86d5        ; yes, skip next step
			bne :skip3
;86d3  3e35      ld      a,#35		; no, A := #35
			lda #$35
:skip3
;86d5  320a4c    ld      (#4c0a),a	; store into mspac sprite number
			sta |pacmansprite
;86d8  c9        ret
			rts

; arrive here when pac man is facing up from #1513
; MOVING NORTH
:up
;16f7  3a084d    ld      a,(#4d08)
;16fa  c3d986    jp      #86d9		; jump to ms. pacman patch to animate ms pac

; arrive from #16FA when ms pac is facing up
; MSPAC MOVING NORTH
;86d9  3a084d    ld      a,(#4d08)	; load A with pacman Y position
			lda |pacman_y
;86dc  e607      and     #07		; mask bits, now between #00 and #07
			and #$7
;86de  cb3f      srl     a		; shift right, now between #00 and #03
			lsr
;86e0  2f        cpl     		; invert
			eor #$FFFF
;86e1  1ef4      ld      e,#f4		; E := #F4
;86e3  83        add     a,e		; add #F4
			clc
			adc #$fff4
;86e4  cb47      bit     0,a		; test bit 0 .  is it on ?
			bit #1
;86e6  2002      jr      nz,#86ea        ; yes, skip next step
			bne :skip4
;86e8  3e36      ld      a,#36		; no, A := #36
			lda #$36
:skip4
			and #$FF
;86ea  320a4c    ld      (#4c0a),a	; store into mspac sprite number
			sta |pacmansprite
;86ed  c9        ret     
			rts

;------------------------------------------------------------------------------
;; normal ghost collision detect
;; called from #1039
;171d
normal_ghost_collide mx %00

;171d  0604      ld      b,#04		; B := #04
	    ldy #4
;171f  ed5b394d  ld      de,(#4d39)	; load DE with pacman Y and X tile positions
	    ldx |pacman_tile_pos_y
;1723  3aaf4d    ld      a,(#4daf)	; load A with orange ghost state
	    lda |orangeghost_state
;1726  a7        and     a		; is orange ghost alive ?
;1727  2009      jr      nz,#1732        ; no, skip ahead for next ghost
	    bne :check_blue

;1729  2a374d    ld      hl,(#4d37)	; else load HL with orange ghost Y and X tile positions
	    cpx |orange_tile_y_2

;172c  a7        and     a		; clear the carry flag
;172d  ed52      sbc     hl,de		; is pacman colliding with orange ghost?
;172f  ca6317    jp      z,#1763		; yes, jump ahead and continue checks
	    beq :collided
:check_blue
;1732  05        dec     b		; B := #03
	    dey
;1733  3aae4d    ld      a,(#4dae)	; load A with blue ghost (inky) state
	    lda |blueghost_state
;1736  a7        and     a		; is inky alive ?
;1737  2009      jr      nz,#1742        ; no, skip ahead for next ghost
	    bne :check_pink

;1739  2a354d    ld      hl,(#4d35)	; else load HL with inky's Y and X tile positions
;173c  a7        and     a		; clear carry flag
;173d  ed52      sbc     hl,de		; is pacman colliding with inky ?
	    cpx |blue_tile_y_2
;173f  ca6317    jp      z,#1763		; yes, jump ahead and continue checks
	    beq :collided
:check_pink
;1742  05        dec     b		; B := #02
	    dey
;1743  3aad4d    ld      a,(#4dad)	; load A with pink ghost state
	    lda |pinkghost_state
;1746  a7        and     a		; is pink ghost alive ?
;1747  2009      jr      nz,#1752        ; no, skip ahead
	    bne :check_red

;1749  2a334d    ld      hl,(#4d33)	; else load HL with pink ghost Y and X tile positions
;174c  a7        and     a		; clear carry flag
;174d  ed52      sbc     hl,de		; is pacman colliding with pink ghost?
	    cpx |pink_tile_y_2
;174f  ca6317    jp      z,#1763		; yes, jump ahead and continue checks
	    beq :collided
:check_red
;1752  05        dec     b		; B := #01
	    dey
;1753  3aac4d    ld      a,(#4dac)	; load A with red ghost state
	    lda |redghost_state
;1756  a7        and     a		; is red ghost alive ?
;1757  2009      jr      nz,#1762        ; no, skip ahead
	    bne :red_dead

;1759  2a314d    ld      hl,(#4d31)	; else load HL with red ghost Y and X tile positions
;175c  a7        and     a		; clear carry flag
;175d  ed52      sbc     hl,de		; is pacman colliding with red ghost?
	    cpx |red_tile_y_2
;175f  ca6317    jp      z,#1763		; yes, jump ahead and continue checks
	    beq :collided
:red_dead
;1762  05        dec     b		; B := #00 , no collision occurred
	    dey
:collided
ghost_collided = *
;1763  78        ld      a,b		; load A with ghost # that collided with pacman
	    tya
;1764  32a44d    ld      (#4da4),a	; store
	    sta |num_ghosts_killed

	; invincibility check ; HACK3
	; 1764 c3b01f    jp      #1fb0
	;

;1767  32a54d    ld      (#4da5),a	; store into pacman dead animation state (0 if not dead)
	    sta |pacman_dead_state
;176a  a7        and     a		; was there a collision?
;176b  c8        ret     z		; no, return
	    beq :rts

;176c  21a64d    ld      hl,#4da6	; else load HL with start of ghost flags
;176f  5f        ld      e,a		; load E with ghost # that collided
;1770  1600      ld      d,#00		; D := #00
;1772  19        add     hl,de		; add.  HL now has the ghost blue flag (0 if not blue)
	    asl
	    tax
;1773  7e        ld      a,(hl)		; load A with the ghost's status
	    lda |redghost_blue-2,x
;1774  a7        and     a		; is this ghost blue (eatable) ?
;1775  c8        ret     z		; no, return
	    beq :not_blue

;1776  af        xor     a		; A := #00
;1777  32a54d    ld      (#4da5),a	; store into pacman dead animation state (0 if not dead)
	    stz |pacman_dead_state
;177a  21d04d    ld      hl,#4dd0	; load HL with # of ghosts killed
;177d  34        inc     (hl)		; increase
	    inc |num_killed_ghosts
;177e  46        ld      b,(hl)		; load B with this # of ghosts killed
	    lda |num_killed_ghosts
;177f  04        inc     b		; increase by one, used for scoring routine
	    inc
;1780  cd5a2a    call    #2a5a		; update score.  B has code for items scored. draws score on screen, checks for high score and extra lives
	    jsr update_score

;1783: 21 BC 4E	ld	hl,#4EBC	; load HL with sound channel 3
	    lda #%1000
;1786: CB DE	set	3,(hl)		; set sound for eating a ghost
	    tsb |bnoise
:not_blue
:rts
;1788: C9	ret			; return
	    rts
	;; end normal ghost collision detect

;------------------------------------------------------------------------------
;; blue (edible) ghost collision detect
;
; called from #103C
; 1789
blue_ghost_collide mx %00
;1789  3aa44d    ld      a,(#4da4)	; load A with ghost # that collided with pacman (0=no collision)
	    lda |num_ghosts_killed
;178c  a7        and     a		; was there a collision ?
;178d  c0        ret     nz		; yes, return
	    beq :continue
:rts
	    rts
:continue
;178e  3aa64d    ld      a,(#4da6)	; no, load A with power pill status
	    lda |powerpill
;1791  a7        and     a		; is a power pill active ?
;1792  c8        ret     z		; no, return
	    beq :rts

	    sep #$31  ; mxc = 1
;1793  0e04      ld      c,#04		; else C := #04
;1795  0604      ld      b,#04		; B := #04
	    ldy #4
;1797  dd21084d  ld      ix,#4d08	; load IX with pacman Y position
;179b  3aaf4d    ld      a,(#4daf)	; load A with orange ghost state
	    lda |orangeghost_state
;179e  a7        and     a		; is ghost alive ?
;179f  2013      jr      nz,#17b4        ; no, skip ahead for next ghost
	    bne :check_blue
;
;17a1  3a064d    ld      a,(#4d06)	; yes, load A with orange ghost Y position
	    lda |orange_ghost_y
;17a4  dd9600    sub     (ix+#00)	; subtract pacman's Y position
	    ; c=1
	    sbc |pacman_y
;17a7  b9        cp      c		; <= #04 ?
	    cmp #4
;17a8  300a      jr      nc,#17b4        ; no, skip ahead for next ghost
	    bcs :check_blue
;
;17aa  3a074d    ld      a,(#4d07)	; yes, load A with orange ghost X position
	    lda |orange_ghost_x
;17ad  dd9601    sub     (ix+#01)	; subtract pacman's X position
	    sbc |pacman_x
;17b0  b9        cp      c		; <= #04 ?
	    cmp #4
;17b1  da6317    jp      c,#1763		; yes, jump back and set collision
	    ;bcc :check_blue
	    ;rep #$30
	    ;jmp ghost_collided
	    bcc :collided

:check_blue mx %11
;17b4  05        dec     b		; B := #03
	    dey
;17b5  3aae4d    ld      a,(#4dae)	; load A with blue ghost (inky) state
	    lda |blueghost_state
;17b8  a7        and     a		; is inky alive ?
;17b9  2013      jr      nz,#17ce        ; no, skip ahead for next ghost
	    bne :check_pink
;
;17bb  3a044d    ld      a,(#4d04)	; load A with inky's Y position
	    lda |blue_ghost_y
;17be  dd9600    sub     (ix+#00)	; subtract pacman's Y position
	    sec
	    sbc |pacman_y
;17c1  b9        cp      c		; <= #04 ?
	    cmp #4
;17c2  300a      jr      nc,#17ce        ; no, skip ahead for next ghost
	    bcs :check_pink
;
;17c4  3a054d    ld      a,(#4d05)	; yes, load A with inky's X position
	    lda |blue_ghost_x
;17c7  dd9601    sub     (ix+#01)	; subtract pacman's X position
	    sbc |pacman_x
;17ca  b9        cp      c		; <= #04 ?
	    cmp #4
;17cb  da6317    jp      c,#1763		; yes, jump back and set collision
	    bcc :collided

:check_pink mx %11
;17ce  05        dec     b		; B := #02
	    dey
;17cf  3aad4d    ld      a,(#4dad)	; load A with pink ghost state
	    lda |pinkghost_state
;17d2  a7        and     a		; is pink ghost alive ?
;17d3  2013      jr      nz,#17e8        ; no, skip ahead for next ghost
	    bne :check_red
;
;17d5  3a024d    ld      a,(#4d02)	; load A with pink ghost Y position
	    lda |pink_ghost_y
;17d8  dd9600    sub     (ix+#00)	; subtract pacman's Y position
	    sec
	    sbc |pacman_y
;17db  b9        cp      c		; <= #04 ?
	    cmp #4
;17dc  300a      jr      nc,#17e8        ; no, skip ahead for next ghost
	    bcs :check_red
;
;17de  3a034d    ld      a,(#4d03)	; yes, load A with pink ghost X position
	    lda |pink_ghost_x
;17e1  dd9601    sub     (ix+#01)	; subtract pacman's X position
	    sbc |pacman_x
;17e4  b9        cp      c		; <= #04 ?
	    cmp #4
;17e5  da6317    jp      c,#1763		; yes, jump back and set collision
	    bcc	:collided
:check_red mx %11
;17e8  05        dec     b		; B := #01
	    dey
;17e9  3aac4d    ld      a,(#4dac)	; load A with red ghost state
	    lda |redghost_state
;17ec  a7        and     a		; is red ghost alive ?
;17ed  2013      jr      nz,#1802        ; no, skip ahead
	    bne :red_dead
;
;17ef  3a004d    ld      a,(#4d00)	; yes, load A with red ghost Y position
	    lda |red_ghost_y
;17f2  dd9600    sub     (ix+#00)	; subtract pacman's Y position
	    sec
	    sbc |pacman_y
;17f5  b9        cp      c		; <= #04 ?
	    cmp #4
;17f6  300a      jr      nc,#1802        ; no, skip ahead
	    bcs :red_dead
;
;17f8  3a014d    ld      a,(#4d01)	; yes, load A with red ghost X position
	    lda |red_ghost_x
;17fb  dd9601    sub     (ix+#01)	; subtract pacman's X position
	    sbc |pacman_x
;17fe  b9        cp      c		; <= #04 ?
	    cmp #4
;17ff  da6317    jp      c,#1763		; yes, jump back and set collision
	    bcc :collided
:red_dead
;1802  05        dec     b		; else no collision ; B := #00
	    dey
;1803  c36317    jp      #1763		; jump back and set collision
:collided
	    rep #$31
	    jmp ghost_collided

	; end of blue ghost collision detection

;------------------------------------------------------------------------------
; called from #1044
;1806
pacman_movement mx %00
		nop
		nop
		nop
;]wait   bra ]wait
		nop
		nop
		nop

		; do we get here?, yes, now we do
		;lda #Mstr_Ctrl_Disable_Vid
		;sta >MASTER_CTRL_REG_L


;1806  219d4d    ld      hl,#4d9d	; load HL with address of delay to update pacman movement
;1809  3eff      ld      a,#ff		; A := #FF = code for no delay
	    lda |move_delay


	; Hack code:
	; 1809  c3c01f	jp	#1fc0		; Intermission fast fix ; HACK8 (1 of 3)
	; 1809  c3d01f	jp	#1fd0		; P1P2 cheat  ; HACK3
	; 1809  c34c0f	jp	#0f4c		; pause cheat ; HACK5
	; end hack code


;180b  be        cp      (hl)		; is pacman slow due to the eating of a pill ?
	    bmi :no_delay

	; Hack code
	; set 0xbe to 0x01 for fast cheat.	; HACK2 (1 of 2)
	; 180b  01
	;		i'm not entirely sure how this works.  it mangles
	;		the opcodes starting at 180b to be:
	;
	;	    080b 01ca11    ld      bc,11cah
	;	    080e 1835      jr      1845h
	;	    0810 c9        ret     
	;
	;	which makes little to no sense, but it works


	; end hack code

;180c  ca1118    jp      z,#1811		; no, skip ahead
;180f  35        dec     (hl)		; yes, decrement the counter to delay pacman movement
	    dec
	    sta |move_delay
:rts
;1810  c9        ret     		; return without movement
	    rts
:no_delay
;1811  3aa64d    ld      a,(#4da6)	; load A with power pill effect (1=active, 0=no effect)
	    lda |powerpill
;1814  a7        and     a		; is a power pill active ?
;1815  ca2f18    jp      z,#182f		; no, skip ahead
	    beq :no_powerpill

; movement when power pill active

;1818  2a4c4d    ld      hl,(#4d4c)	; yes, load HL with speed bit patterns for pacman in power pill state (low bytes)
	    lda |speedbit_bigpill+2
;181b  29        add     hl,hl		; double
	    clc
		adc |speedbit_bigpill+2
;181c  224c4d    ld      (#4d4c),hl	; store result
	    sta |speedbit_bigpill+2
;181f  2a4a4d    ld      hl,(#4d4a)	; load HL with speed bit patterns for pacman in power pill state (high bytes)
	    lda |speedbit_bigpill
;1822  ed6a      adc     hl,hl		; double, with the carry = we have doubled the speed
	    adc |speedbit_bigpill
;1824  224a4d    ld      (#4d4a),hl	; store result. have we reached the threshold ?
	    sta |speedbit_bigpill
;1827  d0        ret     nc		; no, return
	    bcc :rts

;1828  214c4d    ld      hl,#4d4c	; yes, load HL with speed bit patterns for pacman in power pill state (low bytes)
;182b  34        inc     (hl)		; increase
	    inc |speedbit_bigpill+2
;182c  c34318    jp      #1843		; skip ahead to move pacman
	    bra  :all_pac_move

; movement when power pill not active
:no_powerpill
;182f  2a484d    ld      hl,(#4d48)	; load HL with speed for pacman in normal state (low bytes)
	    lda |speedbit_normal+2
;1832  29        add     hl,hl		; double
	    clc
		adc |speedbit_normal+2
;1833  22484d    ld      (#4d48),hl	; store result
	    sta |speedbit_normal+2
;1836  2a464d    ld      hl,(#4d46)	; load HL with speed for pacman in normal state (high bytes)
	    lda |speedbit_normal
;1839  ed6a      adc     hl,hl		; double with carry
	    adc |speedbit_normal
;183b  22464d    ld      (#4d46),hl	; store result.  is it time for pacman to move?
	    sta |speedbit_normal
;183e  d0        ret     nc		; no, return.  pacman will be idle this time.
	    bcc :rts

;183f  21484d    ld      hl,#4d48	; yes, load HL with speed for pacman in normal state (low byte)
;1842  34        inc     (hl)		; increase by one
	    inc |speedbit_normal+2

; all pacman movement
:all_pac_move
;1843  3a0e4e    ld      a,(#4e0e)	; load A with number of pills eaten in this level
	    lda |dotseat
;1846  329e4d    ld      (#4d9e),a	; store into counter related to number of pills eaten before last pacman move
	    sta |RTNOPEBLPM
;1849  3a724e    ld      a,(#4e72)	; load A with cocktail mode (0=no, 1=yes)
;184c  4f        ld      c,a		; copy to C
;184d  3a094e    ld      a,(#4e09)	; load A with current player number:  0=P1, 1=P2
;1850  a1        and     c		; mix together
;1851  4f        ld      c,a		; copy to C.  This is checked at #1879 and #18BB
;1852  213a4d    ld      hl,#4d3a	; load HL with address of pacman X tile position 
;1855  7e        ld      a,(hl)		; load A with pacman X tile position
	    lda |pacman_tile_pos_x
	    and #$FF
;1856  0621      ld      b,#21		; B := #21
;1858  90        sub     b		; subtract.  is pacman past the right edge of the screen?
	    cmp #$21
;1859  3809      jr      c,#1864         ; yes, skip ahead to handle tunnel movement
	    bcc :yes_tunnel

;185b  7e        ld      a,(hl)		; load A with pacman X tile position
	    ;lda |pacman_tile_pos_x
	    ;and #$FF
;185c  063b      ld      b,#3b		; B := #3B
;185e  90        sub     b		; subtract. is pacman pas the left edge of the screen?
	    cmp #$3B
;185f  3003      jr      nc,#1864        ; yes, skip ahead to handle tunnel movement
	    ;bcc :yes_tunnel
;1861  c3ab18    jp      #18ab		; no tunnel movement.  jump ahead to handle normal movement
	    bcc :normal_move

; this sub is only called while player is in a tunnel
:yes_tunnel
;1864  3e01      ld      a,#01		; A := #01
	    lda #1
;1866  32bf4d    ld      (#4dbf),a	; store into pacman about to enter a tunnel flag
	    sta |pacman_enter_tunnel

;1869  3a004e    ld      a,(#4e00)	; load A with game state
	    lda |mainstate
;186c  fe01      cp      #01		; are we in demo mode ?
	    cmp #1
;186e  ca191a    jp      z,#1a19		; yes, skip ahead [ zero this instruction to NOP's to enable playing in demo mode (part 1/2) ] 
	    beql :demo_mode
;1871  3a044e    ld      a,(#4e04)	; else load A with subroutine #
	    lda |levelstate
;1874  fe10      cp      #10		; <=#10 ?
	    cmp #$10
;1876  d2191a    jp      nc,#1a19	; no, skip ahead
	    ;bcc :continue
	    bccl :demo_mode

;1879  79        ld      a,c		; load A with mix of cocktail mode and player number, created above at #1849-#1851
;187a  a7        and     a		; is this player 2 and cocktail mode ?
;187b  2806      jr      z,#1883         ; No, skip ahead and check IN0

; check player 1 or player 2 input
; the program jumps to one of two locations to check
; player input based on whether it's player 1 or player 2 currently playing, and cocktail mode is enabled
; if player 2 is playing and cocktail mode enabled, 187b will fall through to 187d.
; if player 1 is playing or cocktail mode is disabled, 187b will jump to 1883 

;187d  3a4050    ld      a,(#5040)	; else load A with IN1 (player 2)
;1880  c38618    jp      #1886		; skip ahead

;1883  3a0050    ld      a,(#5000)	; load A with IN0 (player 1)
		lda |IN1
;1886  cb4f      bit     1,a		; is joystick pushed to left?
		bit #$0002
;1888  c29918    jp      nz,#1899	; no, skip ahead
		bne :not_left

;188b  2a0333    ld      hl,(#3303)	; yes, load HL with move left tile change
		ldx |move_left
;188e  3e02      ld      a,#02		; A := #02
		lda #2
;1890  32304d    ld      (#4d30),a	; store into pac orientation
		sta |pacman_dir
;1893  221c4d    ld      (#4d1c),hl	; store HL into pacman Y tile changes (A)
		stx |pacman_tchangeA_y
;1896  c35019    jp      #1950		; jump back to program
		jmp :do_move

:not_left
;1899  cb57      bit     2,a		; is joystick pushed to right?
		bit #$0004
;189b  c25019    jp      nz,#1950	; no, skip ahead
		bnel :not_right

;189e  2aff32    ld      hl,(#32ff)	; load HL with move right tile change
		ldx |move_right
;18a1  af        xor     a		; A := #00
;18a2  32304d    ld      (#4d30),a	; store into pac orientation
		stz |pacman_dir
;18a5  221c4d    ld      (#4d1c),hl	; store HL into pacman Y tile changes (A)
		stx |pacman_tchangeA_y
;18a8  c35019    jp      #1950		; jump back to program
		jmp :do_move

; arrive here via #1861, this handles normal (not tunnel) movement
:normal_move
;18ab  3a004e    ld      a,(#4e00)	; load A with game state
		lda |mainstate
;18ae  fe01      cp      #01		; are we in demo mode ?
		cmp #1
;18b0  ca191a    jp      z,#1a19		; yes, skip ahead [ zero this instruction into NOP's to enable playable demo mode, (part 2/2) ]
		beql :demo_mode

;18b3  3a044e    ld      a,(#4e04)	; else load A with subroutine #
		lda |levelstate
;18b6  fe10      cp      #10		; <= #10 ?
		cmp #$10
;18b8  d2191a    jp      nc,#1a19	; no, skip ahead
		bcsl :demo_mode

;18bb  79        ld      a,c		; A := C
;18bc  a7        and     a		; is this player 2 and cocktail mode ?
;18bd  2806      jr      z,#18c5         ; yes, skip next 2 steps

; p1/p2 check.  see 187b above for info.

	; p2 movement check

;18bf  3a4050    ld      a,(#5040)	; load A with IN1
;18c2  c3c818    jp      #18c8		; skip next step

	; p1 movement check

;18c5  3a0050    ld      a,(#5000)	; load A with IN0
		lda |IN0
;18c8  cb4f      bit     1,a		; joystick pressed left?
		bit #2
;18ca  cac91a    jp      z,#1ac9		; yes, jump to process
		beql :player_move_left

;18cd  cb57      bit     2,a		; joystick pressed right?
		bit #4
;18cf  cad91a    jp      z,#1ad9		; yes, jump to process
		beql :player_move_right

;18d2  cb47      bit     0,a		; joystick pressed up?
		bit #1
;18d4  cae81a    jp      z,#1ae8		; yes, jump to process
		beql :player_move_up

;18d7  cb5f      bit     3,a		; joystick pressed down?
		bit #8
;18d9  caf81a    jp      z,#1af8		; yes, jump to process
		beql :player_move_down

	; no change in movement - joystick is centered

;18dc  2a1c4d    ld      hl,(#4d1c)	; load HL with pacman tile change
		ldx |pacman_tchangeA_y
;18df  22264d    ld      (#4d26),hl	; store into wanted pacman tile changes
		stx |wanted_pacman_tile_y
;18e2  0601      ld      b,#01		; B := #01 - this codes that the joystick was not moved

	; movement checks return to here
mc_return equ *

;18e4  dd21264d  ld      ix,#4d26	; load IX with wanted pacman tile changes
		ldx #wanted_pacman_tile_y
;18e8  fd21394d  ld      iy,#4d39	; load IY with pacman tile position
		ldy #pacman_tile_pos_y
;18ec  cd0f20    call    #200f		; load A with screen value of position computed in (IX) + (IY)
		jsr screen_xy
;18ef  e6c0      and     #c0		; mask bits
		and #$C0
;18f1  d6c0      sub     #c0		; subtract.  is the maze blocking pacman from moving this way?
		sec
		sbc #$c0
;18f3  204b      jr      nz,#1940        ; no, skip ahead
		bne :not_blocked
;18f5  05        dec     b		; yes, was the joystick moved ?
		lda |IN0
		and #$F
		cmp #$F
;18f6  c21619    jp      nz,#1916	; yes, skip ahead
		bne :yes_moved

;18f9  3a304d    ld      a,(#4d30)	; no, load A with pacman orientation
		lda |pacman_dir
;18fc  0f        rrca    		; roll right with carry.  is pacman moving either up or down?
		ror
;18fd  da0b19    jp      c,#190b		; yes, skip next 5 steps
		bcs :updown

;1900  3a094d    ld      a,(#4d09)	; no, load A with pacman X position
		lda |pacman_x
;1903  e607      and     #07		; mask bits, now between 0 and 7
		and #$7
;1905  fe04      cp      #04		; == #04 ?  (In center of tile ?)
		cmp #4
;1907  c8        ret     z		; yes, return
		beq :rts2

;1908  c34019    jp      #1940		; else skip ahead
		bra :not_blocked
:updown
;190b  3a084d    ld      a,(#4d08)	; load A with pacman Y position
		lda |pacman_y
;190e  e607      and     #07		; mask bits, now between 0 and 7
		and #$7
;1910  fe04      cp      #04		; == #04 ? (In center of tile ?)
		cmp #4
;1912  c8        ret     z		; yes, return
		beq :rts2

;1913  c34019    jp      #1940		; no, skip ahead
		bra :not_blocked
:not_moved
:yes_moved
;1916  dd211c4d  ld      ix,#4d1c	; load IX with pacman Y,X tile changes 
		; amazingly y should be preserved in the above functions
		ldx #pacman_tchangeA_y
;191a  cd0f20    call    #200f		; load A with screen value of position computed in (IX) + (IY)
		jsr screen_xy
;191d  e6c0      and     #c0		; mask bits
		and #$C0
;191f  d6c0      sub     #c0		; subtract.  is the maze blocking pacman from moving this way?
		sec
		sbc #$C0
;1921  202d      jr      nz,#1950        ; no, skip ahead
		bne :do_move

; code seems to be why pacman turns corners fast.  it gives an extra boost to the new direction

;1923  3a304d    ld      a,(#4d30)	; yes, load A with pacman orientation
		lda |pacman_dir
;1926  0f        rrca    		; roll right with carry.  is pacman moving either up or down ?
		ror
;1927  da3519    jp      c,#1935		; yes, skip next 5 steps
		bcs :isupdown

;192a  3a094d    ld      a,(#4d09)	; no, load A with pacman X position
		lda |pacman_x
;192d  e607      and     #07		; mask bits, now between 0 and 7
		and #7
;192f  fe04      cp      #04		; == #04 ? ( In center of tile ? )
		cmp #4
;1931  c8        ret     z		; yes, return
		bne :do_move
;1932  c35019    jp      #1950		; no, skip ahead
:rts2		rts
:isupdown
;1935  3a084d    ld      a,(#4d08)	; load A with pacman Y position
		lda |pacman_y
;1938  e607      and     #07		; mask bits, now between 0 and 7
		and #7
;193a  fe04      cp      #04		; == #04 ( In center of tile?)
		cmp #4
;193c  c8        ret     z		; yes, return
		bne :do_move
;193d  c35019    jp      #1950		; no, jump ahead
		rts

; arrive when changing direction (???)
:not_blocked
;1940  2a264d    ld      hl,(#4d26)	; load HL with wanted pacman tile changes
		lda |wanted_pacman_tile_y
;1943  221c4d    ld      (#4d1c),hl	; store into pacman tile changes
		sta |pacman_tchangeA_y
;1946  05        dec     b		; was the joystick moved?
		lda |IN0
		and #$F
		cmp #$F
;1947  ca5019    jp      z,#1950		; no, skip ahead
		beq :do_move

;194a  3a3c4d    ld      a,(#4d3c)	; yes, load A with wanted pacman orientation
		lda |wanted_pacman_orientation
;194d  32304d    ld      (#4d30),a	; store into pacman orientation
		sta |pacman_dir
:not_right
:do_move
;1950  dd211c4d  ld      ix,#4d1c	; load IX with pacman Y,X tile changes
		ldx #pacman_tchangeA_y
;1954  fd21084d  ld      iy,#4d08	; load IY with pacman position
		ldy #pacman_y
;1958  cd0020    call    #2000		; HL := (IX) + (IY)
		jsr double_add
		sta <temp0
;195b  3a304d    ld      a,(#4d30)	; load A with pacman orientation
		lda |pacman_dir
;195e  0f        rrca    		; roll right, is pacman moving either up or down ?
		ror
;195f  da7519    jp      c,#1975		; yes, skip ahead
		bcs :handle_updown

;1962  7d        ld      a,l		; load A with X position of new location
					; this comment is wrong, it's Y position
		lda <temp0

;1963  e607      and     #07		; mask bits, now between 0 and 7
		and #7
;1965  fe04      cp      #04		; == #04 ( in center of tile ?)
		cmp #4
;1967  ca8519    jp      z,#1985		; yes, skip ahead
		beq :skip_center

;196a  da7119    jp      c,#1971		; was the last comparison less than #04 ?, if yes, skip next 2 steps
		bcc :corner_from_down

; cornering up to the left or up to the right

;196d  2d        dec     l		; lower the X position
		dec <temp0
;196e  c38519    jp      #1985		; skip ahead
		bra :skip_center

; cornering right from down , cornering left from down
:corner_from_down

;1971  2c        inc     l		; else increase the X position
		inc <temp0
;1972  c38519    jp      #1985		; skip ahead
		bra :skip_center

; handle up/down movement turns
:handle_updown
;1975  7c        ld      a,h		; load A with Y position of new location
		lda <temp0+1
;1976  e607      and     #07		; mask bits, now between 0 and 7
		and #7
;1978  fe04      cp      #04		; == #04 ( in center of tile ?)
		cmp #4
;197a  ca8519    jp      z,#1985		; yes, skip ahead
		beq :skip_center

;197d  da8419    jp      c,#1984		; was the last comparison less than #04 ?, if yes, skip next 2 steps
		bcc :corner_from_right

; cornering up from the left side, or down from the left side

;1980  25        dec     h		; else lower the Y position 
		dec <temp0+1
;1981  c38519    jp      #1985		; skip ahead
		bra :skip_center

; arrive here when cornering up from the right side
; or when cornering down from the right side
:corner_from_right
;1984  24        inc     h		; increase the Y position
		inc <temp0+1

; arrive here from several locations
; HL has the expected new position of a sprite
:skip_center
		lda <temp0
movement_check equ *
;1985  22084d    ld      (#4d08),hl	; store the new sprite position into pacman position
		sta |pacman_y
;1988  cd1820    call    #2018		; convert sprite position into a tile position
		jsr spr_to_tile
;198b  22394d    ld      (#4d39),hl	; store tile position into pacman's tile position
		sta |pacman_tile_pos_y
;198e  dd21bf4d  ld      ix,#4dbf	; load IX with tunnel indicator address
;1992  dd7e00    ld      a,(ix+#00)	; load A with tunnel indiacator.  1=pacman in a tunnel
		lda |pacman_enter_tunnel
;1995  dd360000  ld      (ix+#00),#00	; clear the tunnel indicator
		stz |pacman_enter_tunnel
;1999  a7        and     a		; is pacman in a tunnel ?
;199a  c0        ret     nz		; yes, return
		beq :check_item_eat
		rts

; check for items eaten
:check_item_eat
;199B: 3A D2 4D	ld	a,(#4DD2)	; load A with fruit position
		lda |FRUITP
;199E: A7	and	a		; == #00 ?
;199F: 28 2C	jr	z,#19CD		; yes, skip ahead
		beq :no_fruit_eaten

;19A1: 3A D4 4D	ld	a,(#4DD4)	; else load A with entry to fruit points, or 0 if no fruit
		lda |FVALUE
;19A4: A7	and	a		; == #00 ?
;19A5: 28 26	jr	z,#19CD		; yes, skip ahead
		beq :no_fruit_eaten

; else check for fruit to be eaten

;19A7: 2A 08 4D	ld	hl,(#4D08)	; load HL with pacman Y position
		lda |pacman_y
;19AA: 11 94 80	ld	de,#8094	; load DE with #8094 (why?  on jump DE is loaded with new values.  this is junk from pac-man)

; OTTOPATCH
;PATCH TO MAKE THE PACMAN AWARE OF THE CHANGING POSITION OF THE FRUIT
;ORG 19ADH
;JP EATFRUIT
;19AD: C3 18 88	jp	#8818		; MS Pac-man patch. jump to check for fruit being eaten

; check for fruit being eaten ... jumped from #19AD
; HL has pacman X,Y

;8818: F5	push	af		; Save AF
	    pha
	    sep #$21
;8819: ED5BD24D	ld	de,(#4DD2)	; load fruit X position into D, fruit Y position into E
;881D: 7C	ld	a,h		; load A with pacman X position
	    xba
;881E: 92	sub	d		; subtract fruit X position
	    sbc |FRUITP+1
;881F: C6 03	add	a,#03		; add margin of error == #03
	    clc
	    adc #3
;8821: FE 06	cp	#06		; X values match within margin ?
	    cmp #6
;8823: 30 18	jr	nc,#883D	; no , jump back to program
	    bcs :return

;8825: 7D	ld	a,l		; else load A with pacman Y values
	    xba
;8826: 93	sub	e		; subtract fruit Y position
	    ;c=1
	    sbc |FRUITP
;8827: C6 03	add	a,#03		; add margin of error
	    clc
	    adc #3
;8829: FE 06	cp	#06		; Y values match within margin?
	    cmp #6
;882B: 30 10	jr	nc,#883D	; no, jump back to program
	    bcs :return

; else a fruit is being eaten

;882D: 3E 01	ld	a,#01		; load A with #01
;882F: 32 0D 4C	ld	(#4C0D),a	; store into fruit sprite entry
	    lda #1
	    sta |fruitspritecolor
;8832: F1	pop	af		; Restore AF
	    lda |FVALUE
;8833: C6 02	add	a,#02		; add 2 to A
	    clc
	    adc #2

;8835: 32 0C 4C	ld	(#4C0C),a	; store into fruit sprite number
	    sta |fruitsprite

;8838: D6 02	sub	#02		; sub 2 from A, make A the same as it was

;883A: C3 B2 19	jp	#19B2		; jump back to program for fruit being eaten
	    rep #$20
	    pla
	    bra :fruit_eaten
:return
;883D: F1	pop	af		; Restore AF
	    rep #$20
	    pla
;883E: C3 CD 19	jp	#19CD		; jump back to program with no fruit eaten
	    bra :no_fruit_eaten

;19B0: 20 1B	jr	nz,#19CD	; junk from pac-man

; arrive here when fruit is eaten
:fruit_eaten
;19B2: 06 19	ld	b,#19		; else a fruit is eaten.  load B with task #19
;19B4: 4F	ld	c,a		; load C with task from A register
	    xba
	    and #$FF00
	    ora #$0019
;19B5: CD 42 00	call	#0042		; set task #19 with parameter variable A.  updates score.  B has code for items scored, draw score on screen, check for high score and extra lives
	    jsr task_add

;19B8: CD 00 10	call	#1000		; clear fruit.  clears #4DD4 and returns
	    stz |FVALUE

;19BB: 18 07	jr	#19C4		; skip ahead.  a fruit has been eaten

; Pac man code:
; 19b8  0e15      ld      c,#15
; 19ba  81        add     a,c
; 19bb  4f        ld      c,a
; 19bc  061c      ld      b,#1c
; end pac-man code


;19BD: 1C				; junk from pac-man
;19BE: CD 42 00	call	#0042		; pac-man only
;19C1: CD 04 10	call	#1004		; pac-man only

;19C4: F7	rst	#30		; set timed task to clear the fruit score sprite
;19C5: 54 05 00				; timer=54, task=5, param=0
	    lda #$0554
	    ldy #0
	    jsr rst30

;19C8: 21 BC 4E	ld	hl,#4EBC	; load HL with voice 3 address
;19CB: CB D6	set	2,(hl)		; set up fruit eating sound.
	    lda #$0004
	    tsb |bnoise

; arrive here when no fruit eaten from fruit eating check subroutine
:no_fruit_eaten
;19CD: 3E FF	ld	a,#FF		; load A with #FF
	    lda #$FFFF
;19CF: 32 9D 4D	ld	(#4D9D),a	; store into delay to update pacman movement
	    sta |move_delay

;19D2: 2A 39 4D	ld	hl,(#4D39)	; load HL with pacman's position
	    lda |pacman_tile_pos_y
;19D5: CD 65 00	call	#0065		; load HL with pacman's grid position
	    jsr yx_to_screen

;19D8: 7E	ld	a,(hl)		; load A with item on grid
	    tax
	    lda |0,x
	    and #$00FF
;19D9: FE 10	cp	#10		; is a dot being eaten ?
	    cmp #$10
;19DB: 28 03	jr	z,#19E0		; yes, skip ahead
	    beq :eat_dot

;19DD: FE 14	cp	#14		; else is an energizer being eaten?
	    cmp #$14
;19DF: C0	ret	nz		; no, return
	    beq :eat_dot
	    rts

; arrive here when a dot or energizer has been eaten
; A has either #10 or #14 loaded
:eat_dot
;19E0: DD210E4E	ld	ix,#4E0E	; else load number of pills eaten in this level
;19E4: DD 34 00	inc	(ix+#00)	; increase
	    inc |dotseat
;19E7: E6 0F	and	#0F		; mask bits.  If a dot is eaten, A is now #00.  Energizer, A is now #04
	    and #$0F
;19E9: CB 3F	srl	a		; shift right (div by 2)
	    lsr
;19EB: 06 40	ld	b,#40		; load B with #40 (clear graphic)
;19ED: 70	ld	(hl),b		; update maze to clear the dot that has been eaten
	    sep #$20
	    pha
	    lda #$40
	    sta |0,x
	    pla
	    rep #$20

;19EE: 06 19	ld	b,#19		; load B with #19 for task call below
;19F0: 4F	ld	c,a		; load C with A (either #00 or #02)
;19F1: CB 39	srl	c		; shift right (div by 2).  now C is either #00 or #01
	    tay
	    lsr
	    xba
	    and #$FF00
	    ora #$0019

;19F3: CD 42 00	call	#0042		; set task #19 with variable parameter
	    phy
	    jsr task_add
	    pla

; task #19 will update score.  B has code for items scored, draw score on screen, check for high score and extra lives

;19F6: 3C	inc	a		; A := A + 1.  A is now either 1 or 3
	    inc
;19F7: FE 01	cp	#01		; was a dot just eaten?
	    cmp #1
;19F9: CA FD 19	jp	z,#19FD		; yes, skip next step
	    beq :normal_pill
;19FC: 87	add  a,a		; else it was an energizer. double A to 6
	    asl
:normal_pill
;19FD: 32 9D 4D	ld	(#4D9D),a	; store A to delay update pacman movement
	    sta |move_delay
;1A00: CD 08 1B	call	#1B08		; update timers for ghosts to leave ghost house
	    jsr ghost_house_timers
;1A03: CD 6A 1A	call	#1A6A		; check for energizer eaten
	    jsr check_energizer
;1A06: 21 BC 4E	ld	hl,#4EBC	; load HL with sound #3
;1A09: 3A 0E 4E	ld	a,(#4E0E)	; load A with number of pills eaten in this level
	    lda |dotseat
;1A0C: 0F	rrca			; roll right
	    ror
	    lda |bnoise
;1A0D: 38 05	jr	c,#1A14		; if carry then use other sound pattern
	    bcc :other_sound

;1A0F: CB C6	set	0,(hl)		; else set sound bit 0
;1A11: CB 8E	res	1,(hl)		; clear sound bit 1
	    ora #1
	    and #2!$FFFF
	    sta |bnoise
;1A13: C9	ret			; return
	    rts
:other_sound
	    and #1!$FFFF
;1A14: CB 86	res	0,(hl)		; clear sound bit 0
	    ora #2
;1A16: CB CE	set	1,(hl)		; set sound bit 1
	    sta |bnoise
;1A18: C9	ret			; return     
	    rts
; arrive here from #18b0 when game is in demo mode
;1A19
:demo_mode

;1a19  211c4d    ld      hl,#4d1c	; load HL with pacman Y tile changes (A) location
;1a1c  7e        ld      a,(hl)		; load A pacman Y tile changes (A)
	    lda |pacman_tchangeA_y
;1a1d  a7        and     a		; == #00 ?  is pacman moving left-right ?
		and #$FF
;1a1e  ca2e1a    jp      z,#1a2e		; yes, skip ahead
	    beq :left_right
;
;1a21  3a084d    ld      a,(#4d08)	; else load A with pacman Y position
	    lda |pacman_y
;1a24  e607      and     #07		; mask bits, now between 0 and 7
	    and #7
;1a26  fe04      cp      #04		; == #04?
	    cmp #4
;1a28  ca381a    jp      z,#1a38		; yes, skip ahead
	    beq :middle
;1a2b  c35c1a    jp      #1a5c		; else jump ahead
	    bra :jump_ahead
:left_right
;1a2e  3a094d    ld      a,(#4d09)	; load A with pacman X position
	    lda |pacman_x
;1a31  e607      and     #07		; mask bits, now between 0 and 7
	    and #7
;1a33  fe04      cp      #04		; == #04 ?
	    cmp #4
;1a35  c25c1a    jp      nz,#1a5c	; no, skip ahead
	    bne :jump_ahead
:middle
;1a38  3e05      ld      a,#05		; yes, A := #05. sets up call below to check if pacman is using tunnel in demo
	    lda #5
;1a3a  cdd01e    call    #1ed0		; if using tunnel, set carry flag
	    jsr check_screen_edge
;1a3d  3803      jr      c,#1a42		; is pacman in tunnel?  no, skip next 2 steps
	    bcs  :skip
;1a3f  ef        rst     #28		; insert task to control pacman AI during demo mode.
;1a40  17 00				; task #17, parameter #00
	    lda #$0017
	    jsr rst28
:skip
;1a42  dd21264d  ld      ix,#4d26	; load IX with wanted pacman tile changes
	    ldx #wanted_pacman_tile_y
;1a46  fd21124d  ld      iy,#4d12	; load IY with pacman tile pos in demo and cut scenes
	    ldy #pacman_demo_tile_y
;1a4a  cd0020    call    #2000		; load HL with new position of pacman
	    jsr double_add
;1a4d  22124d    ld      (#4d12),hl	; store new position into pacman tile position in demo and cut scenes
	    sta |pacman_demo_tile_y
;1a50  2a264d    ld      hl,(#4d26)	; load HL with wanted pacman tile changes
	    lda |wanted_pacman_tile_y
;1a53  221c4d    ld      (#4d1c),hl	; store into pacman tile changes (Y,X)
	    sta |pacman_tchangeA_y
;1a56  3a3c4d    ld      a,(#4d3c)	; load A with wanted pacman orientation
	    lda |wanted_pacman_orientation
;1a59  32304d    ld      (#4d30),a	; store into pacman orientation
	    sta |pacman_dir
:jump_ahead
;1a5c  dd211c4d  ld      ix,#4d1c	; load IX with pacman tile changes (Y,X)
	    ldx #pacman_tchangeA_y
;1a60  fd21084d  ld      iy,#4d08	; load IY with pacman position (Y,X) address
	    ldy #pacman_y
;1a64  cd0020    call    #2000		; load HL with new position of pacman
	    jsr double_add
;1a67  c38519    jp      #1985		; jump to movement check
	    jmp movement_check
;------------------------------------------------------------------------------
;; called from #1A03 after a dot has been eaten
;1a6a
check_energizer mx %00
;1a6a  3a9d4d    ld      a,(#4d9d)	; load A with dot just eaten
	    lda |move_delay
;1a6d  fe06      cp      #06		; was it an energizer?
	    cmp #6
;1a6f  c0        ret     nz		; no, return
	    beq :cont
	    rts
:cont
;
;; else an engergizer has been eaten
;; this is also called even on boards where energizers have "no effect"
;
;1A70: 2A BD 4D	ld	hl,(#4DBD)	; load HL with time the ghosts stay blue when pacman eats a big pill
	    lda |stay_blue_time
;1a73  22cb4d    ld      (#4dcb),hl	; store into counter used while ghosts are blue
	    sta |ghosts_blue_timer
;1a76  3e01      ld      a,#01		; A := #01
	    lda #1
;1a78  32a64d    ld      (#4da6),a	; set power pill to active
	    sta |powerpill
;1a7b  32a74d    ld      (#4da7),a	; set red ghost blue flag
	    sta |redghost_blue
;1a7e  32a84d    ld      (#4da8),a	; set pink ghost blue flag
	    sta |pinkghost_blue
;1a81  32a94d    ld      (#4da9),a	; set inky blue flag
	    sta |blueghost_blue
;1a84  32aa4d    ld      (#4daa),a	; set orange ghost blue flag
	    sta |orangeghost_blue
;1a87  32b14d    ld      (#4db1),a	; set red ghost change orientation flag
	    sta |red_change_dir
;1a8a  32b24d    ld      (#4db2),a	; set pink ghost change orientation flag
	    sta |pink_change_dir
;1a8d  32b34d    ld      (#4db3),a	; set blue ghost (inky) change orientation flag
	    sta |blue_change_dir
;1a90  32b44d    ld      (#4db4),a	; set orange ghost change orientation flag
	    sta |orange_change_dir
;1a93  32b54d    ld      (#4db5),a	; set pacman change orientation flag (?)
	    sta |pacman_change_dir
;1a96  af        xor     a		; A := #00
;1a97  32c84d    ld      (#4dc8),a	; clear counter used to change ghost colors under big pill effects
	    stz |big_pill_timer
;1a9a  32d04d    ld      (#4dd0),a	; clear current number of killed ghosts (used for scoring)
	    stz |num_killed_ghosts
;1a9d  dd21004c  ld      ix,#4c00	; load IX with start of sprites address
;1aa1  dd36021c  ld      (ix+#02),#1c	; set red ghost sprite to edible
;1aa5  dd36041c  ld      (ix+#04),#1c	; set pink ghost sprite to edible
;1aa9  dd36061c  ld      (ix+#06),#1c	; set inky sprite to edible
;1aad  dd36081c  ld      (ix+#08),#1c	; set orange ghost sprite to edible
	    lda #$1c
	    sta |redghostsprite
	    sta |pinkghostsprite
	    sta |blueghostsprite
	    sta |orangeghostsprite
;
;1ab1  dd360311  ld      (ix+#03),#11	; set red ghost color to blue
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Patch to fix the green-eye bug
;; by Don Hodges 1/19/2009
;; part 1/2 (rest at #1FB0):
;;
;; 1AB1 C3B01F	JP	#1FB0		; jump to new sub to only color ghosts when enough time
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;1ab5  dd360511  ld      (ix+#05),#11	; set pink ghost color to blue
;1ab9  dd360711  ld      (ix+#07),#11	; set inky color to blue
;1abd  dd360911  ld      (ix+#09),#11	; set orange ghost color to blue
	    lda #$11
	    sta |redghostcolor
	    sta |pinkghostcolor
	    sta |blueghostcolor
	    sta |orangeghostcolor
;
;1AC1: 21 AC 4E	ld	hl,#4EAC	; load HL with sound channel 2
	    lda #%100000
;1AC4: CB EE	set	5,(hl)		; play sound bit 5
	    tsb |CH2_E_NUM
;1AC6: CB BE	res	7,(hl)		; clear sound bit 7
	    lda #%10000000
	    trb |CH2_E_NUM
;1AC8: C9	ret			; return
	    rts
;
;	; Player move Left
:player_move_left
;1ac9  2a0333    ld      hl,(#3303)	; load HL with tile movement left
;1acc  3e02      ld      a,#02		; load A with code for moving left
;1ace  323c4d    ld      (#4d3c),a	; store into wanted pacman orientation
;1ad1  22264d    ld      (#4d26),hl	; store into wanted pacman tile changes
	    lda #2
	    sta |wanted_pacman_orientation

	    lda |move_left
	    sta |wanted_pacman_tile_y
;1ad4  0600      ld      b,#00		; B := #00
	    ldy #0 ;$$JGA TODO, verify this is what we want
;1ad6  c3e418    jp      #18e4		; return to program
	    jmp mc_return

;	; player move Right
:player_move_right
;1ad9  2aff32    ld      hl,(#32ff)	; load HL with tile movement right
;1adc  af        xor     a		; A := #00, code for moving right
;1add  323c4d    ld      (#4d3c),a	; store into wanted pacman orientation
;1ae0  22264d    ld      (#4d26),hl	; store into wanted pacman tile changes 
	    lda |move_right
	    sta |wanted_pacman_tile_y
	    stz |wanted_pacman_orientation
;1ae3  0600      ld      b,#00		; B := #00
	    ldy #0 ;$$JGA TODO, verify this is what we want
;1ae5  c3e418    jp      #18e4		; return to program
	    jmp mc_return
;	; player move Up
:player_move_up
;1ae8  2a0533    ld      hl,(#3305)	; load HL with tile movement up
;1aeb  3e03      ld      a,#03		; load A with code for moving up
;1aed  323c4d    ld      (#4d3c),a	; store into wanted pacman orientation
;1af0  22264d    ld      (#4d26),hl	; store into wanted pacman tile changes
	    lda #3
	    sta |wanted_pacman_orientation
	    lda |move_up
	    sta |wanted_pacman_tile_y
;1af3  0600      ld      b,#00		; B := #00
	    ldy #0 ;$$JGA TODO, verify this is what we want
;1af5  c3e418    jp      #18e4		; return to program
	    jmp mc_return
;	; player move Down
:player_move_down
;1af8  2a0133    ld      hl,(#3301)	; load HL with tile movement down
;1afb  3e01      ld      a,#01		; load A with code for moving down
;1afd  323c4d    ld      (#4d3c),a	; store into wanted pacman orientation
;1b00  22264d    ld      (#4d26),hl	; store into wanted pacman tile changes
	    lda #1
	    sta |wanted_pacman_orientation
	    lda |move_down
	    sta |wanted_pacman_tile_y
;1b03  0600      ld      b,#00		; B := #00
	    ldy #0 ;$$JGA TODO, verify this is what we want
;1b05  c3e418    jp      #18e4		; return to program
	    jmp mc_return

;------------------------------------------------------------------------------
;
;; called from #1A00
;1b08
ghost_house_timers mx %00
;1b08  3a124e    ld      a,(#4e12)	; load A with flag set to 1 after dying in a level, reset to 0 if ghosts have left home
	    lda |pacman_dead
;1b0b  a7        and     a		; has pacman died this level?  (or has this flag been reset after eating enough dots after death) ?
;1b0c  ca141b    jp      z,#1b14		; no, skip ahead
	    beq :not_dead
;
;1b0f  219f4d    ld      hl,#4d9f	; no, load HL with eaten pills counter after pacman has died in a level
;1b12  34        inc     (hl)		; increase
	    inc |pills_eaten_since_death
;1b13  c9        ret     		; return
	    rts
:not_dead
;1b14  3aa34d    ld      a,(#4da3)	; load A with orange ghost substate
	    lda |orange_substate
;1b17  a7        and     a		; is orange ghost at home ?
;1b18  c0        ret     nz		; no, return
	    bne :rts
;
;1b19  3aa24d    ld      a,(#4da2)	; yes, load A with inky substate
	    lda |blue_substate
;1b1c  a7        and     a		; is inky at home ?
;1b1d  ca251b    jp      z,#1b25		; yes, skip ahead
	    beq :check_pink
;
;1b20  21114e    ld      hl,#4e11	; no, load HL with counter incremented if orange ghost is home but inky is not
;1b23  34        inc     (hl)		; increase counter
;1b24  c9        ret     		; return
:check_pink
;1b25  3aa14d    ld      a,(#4da1)	; load A with pink ghost substate
	    lda |pink_substate
;1b28  a7        and     a		; is pink ghost at home ?
;1b29  ca311b    jp      z,#1b31		; yes, skip ahead
	    beq :pink_home
;1b2c  21104e    ld      hl,#4e10	; no, load HL with counter incremented if inky and orange ghost are home but pinky is not
;1b2f  34        inc     (hl)		; increase counter
	    inc |blue_home_counter
;1b30  c9        ret     		; return
	    rts
:pink_home
;1b31  210f4e    ld      hl,#4e0f	; load HL with counter incremented if pink ghost is home
;1b34  34        inc     (hl)		; increase counter
	    inc |all_home_counter
:rts
;1b35  c9        ret     		; return
	    rts

;------------------------------------------------------------------------------
; called from several locations
;1b37
control_red mx %00
;1b36  3aa04d    ld      a,(#4da0)	; load A with red ghost substate
;1b39  a7        and     a		; is red ghost at home ?
	    lda |red_substate
;1b3a  c8        ret     z		; yes, return
	    bne :forward
:rts	rts
:forward
;1b3b  3aac4d    ld      a,(#4dac)	; else load A with red ghost state
	    lda |redghost_state
;1b3e  a7        and     a		; is red ghost alive ?
;1b3f  c0        ret     nz		; no, return
	    bne :rts

;1b40  cdd720    call    #20d7		; checks for and sets the difficulty flags based on number of pellets eaten
	    jsr check_difficulty

;1b43  2a314d    ld      hl,(#4d31)	; load HL with red ghost Y, X tile position 2
	    lda |red_tile_y_2
;1b46  01994d    ld      bc,#4d99	; load BC with address of aux var used by red ghost to check positions
	    ldy #red_aux
;1b49  cd5a20    call    #205a		; check to see if red ghost has entered a tunnel slowdown area
	    jsr check_slow
;1b4c  3a994d    ld      a,(#4d99)	; load A with aux var used by red ghost to check positions
;1b4f  a7        and     a		; is the red ghost in a tunnel slowdown area ?
	    lda |red_aux
;1b50  ca6a1b    jp      z,#1b6a		; no, skip ahead
	    beq :not_slow

;1b53  2a604d    ld      hl,(#4d60)	; else load HL with red ghost speed bit patterns for tunnel areas
;1b56  29        add     hl,hl		; double it
;1b57  22604d    ld      (#4d60),hl	; store result
	    asl |speedbit_red_tunnel+2

;1b5a  2a5e4d    ld      hl,(#4d5e)	; load HL with red ghost speed bit patterns for tunnel areas
;1b5d  ed6a      adc     hl,hl		; double it
;1b5f  225e4d    ld      (#4d5e),hl	; store result.  have we exceeded the threshold ?
		lda |speedbit_red_tunnel
		adc |speedbit_red_tunnel
		sta |speedbit_red_tunnel
;1b62  d0        ret     nc		; no, return
	    bcs :no_rts
:rts
	    rts
:no_rts

;1b63  21604d    ld      hl,#4d60	; else load HL with red ghost speed bit patterns for tunnel areas
;1b66  34        inc     (hl)		; increase
	    inc |speedbit_red_tunnel+2
;1b67  c3d81b    jp      #1bd8		; skip ahead
	    bra red_ghost_move
:not_slow
;1b6a  3aa74d    ld      a,(#4da7)	; load A with red ghost blue flag (0=not blue)
	    lda |redghost_blue
;1b6d  a7        and     a		; is red ghost blue ?
;1b6e  ca881b    jp      z,#1b88		; no, skip ahead
	    beq :not_blue

;1b71  2a5c4d    ld      hl,(#4d5c)	; yes, load HL with red ghost speed bit patterns for blue state
;1b74  29        add     hl,hl		; double it
;1b75  225c4d    ld      (#4d5c),hl	; store result
	    asl |speedbit_red_blue+2
;1b78  2a5a4d    ld      hl,(#4d5a)	; load HL with red ghost speed bit patterns for blue state
;1b7b  ed6a      adc     hl,hl		; double it
;1b7d  225a4d    ld      (#4d5a),hl	; store result.  have we exceeded the threshold ?
		lda |speedbit_red_blue
		adc |speedbit_red_blue
		sta |speedbit_red_blue
;1b80  d0        ret     nc		; no, return
	    bcc :rts

;1b81  215c4d    ld      hl,#4d5c	; yes, load HL with red ghost speed bit patterns for blue state
;1b84  34        inc     (hl)		; increase
	    inc |speedbit_red_blue+2
;1b85  c3d81b    jp      #1bd8		; skip ahead
	    bra red_ghost_move
:not_blue
;1b88  3ab74d    ld      a,(#4db7)	; load A with 2nd difficulty flag
	    lda |red_difficulty1
;1b8b  a7        and     a		; is cruise elroy 2 active ?
;1b8c  caa61b    jp      z,#1ba6		; no, skip ahead
	    beq :no_elroy

;1b8f  2a504d    ld      hl,(#4d50)	; yes, load HL with speed bit patterns for second difficulty flag
;1b92  29        add     hl,hl		; double
;1b93  22504d    ld      (#4d50),hl	; store result
	    asl |speedbit_difficult2+2
;1b96  2a4e4d    ld      hl,(#4d4e)	; load HL with speed bit patterns for second difficulty flag
;1b99  ed6a      adc     hl,hl		; double
;1b9b  224e4d    ld      (#4d4e),hl	; store result.  have we exceeded the threshold ?
		lda |speedbit_difficult2
		adc |speedbit_difficult2
		sta |speedbit_difficult2

;1b9e  d0        ret     nc		; no, return
	    bcc :rts

;1b9f  21504d    ld      hl,#4d50	; yes, load HL with movement bit patterns for second difficulty flag
;1ba2  34        inc     (hl)		; increase
	    inc |speedbit_difficult2+2
;1ba3  c3d81b    jp      #1bd8		; skip ahead
	    bra red_ghost_move

:no_elroy
;1ba6  3ab64d    ld      a,(#4db6)	; load A with 1st difficulty flag
	    lda |red_difficulty0
;1ba9  a7        and     a		; is cruise elroy 1 active?
;1baa  cac41b    jp      z,#1bc4		; no, skip ahead
	    beq :no_elroy2

;1bad  2a544d    ld      hl,(#4d54)	; yes, load HL with speed bit patterns for first difficulty flag
;1bb0  29        add     hl,hl		; double
;1bb1  22544d    ld      (#4d54),hl	; store result
	    asl |speedbit_difficult+2
;1bb4  2a524d    ld      hl,(#4d52)	; load HL with speed bit patterns for first difficulty flag
;1bb7  ed6a      adc     hl,hl		; double
;1bb9  22524d    ld      (#4d52),hl	; store result.  have we exceeded the threshold ?
		lda |speedbit_difficult
		adc |speedbit_difficult
		sta |speedbit_difficult
;1bbc  d0        ret     nc		; no, return
	    bcc :rts

;1bbd  21544d    ld      hl,#4d54	; yes, load HL with speed bit patterns for first difficulty flag
;1bc0  34        inc     (hl)		; increase
	    inc |speedbit_difficult+2
;1bc1  c3d81b    jp      #1bd8		; skip ahead
	    bra red_ghost_move
:no_elroy2
;1bc4  2a584d    ld      hl,(#4d58)	; load HL with speed bit patterns for red ghost normal state
;1bc7  29        add     hl,hl		; double
;1bc8  22584d    ld      (#4d58),hl	; store result
	    asl speedbit_red_normal+2
;1bcb  2a564d    ld      hl,(#4d56)	; load HL with  speed bit patterns for red ghost normal state
;1bce  ed6a      adc     hl,hl		; double
;1bd0  22564d    ld      (#4d56),hl	; store result.  have we exceed the threshold ?
		lda |speedbit_red_normal
		adc |speedbit_red_normal
		sta |speedbit_red_normal
;1bd3  d0        ret     nc		; no, return
	    bccl :rts

;1bd4  21584d    ld      hl,#4d58	; yes, load HL with speed bit patterns for red ghost normal state
;1bd7  34        inc     (hl)		; increase
	    inc |speedbit_red_normal+2


;------------------------------------------------------------------------------
; called from #10C0 and several other places
; handles red ghost movement
; 1bd8
red_ghost_move mx %00
;1bd8  21144d    ld      hl,#4d14	; load HL with red ghost Y tile changes address
;1bdb  7e        ld      a,(hl)		; load A with red ghost Y tile changes
	    lda |red_ghost_tchangeA_y
;1bdc  a7        and     a		; is the red ghost moving left to right or right to left ?
	    and #$00FF
;1bdd  caed1b    jp      z,#1bed		; yes, skip ahead
	    beq :skip_ahead

;1be0  3a004d    ld      a,(#4d00)	; load A with red ghost Y position
	    lda |red_ghost_y
;1be3  e607      and     #07		; mask out bits, result is between 0 and 7
	    and #$7
;1be5  fe04      cp      #04		; == #04 ?  Is the red ghost in the middle of a tile where he can change direction?
	    cmp #4
;1be7  caf71b    jp      z,#1bf7		; yes, skip ahead
	    beq :skip_ahead2
;1bea  c3361c    jp      #1c36		; no, jump ahead
	    bra :jump_ahead

:skip_ahead
;1bed  3a014d    ld      a,(#4d01)	; load A with red ghost X position
	    lda |red_ghost_x
;1bf0  e607      and     #07		; mask bits.  result is between 0 and 7
	    and #$7
;1bf2  fe04      cp      #04		; == #04 ? Is the red ghost in the middle of a tile where he can change direction?
	    cmp #4
;1bf4  c2361c    jp      nz,#1c36	; no, jump ahead
	    bne :jump_ahead
:skip_ahead2
;1bf7  3e01      ld      a,#01		; A := #01
	    lda #1
;1bf9  cdd01e    call    #1ed0		; check to see if red ghost is on the edge of the screen (tunnel)
	    jsr check_screen_edge

;1bfc  381b      jr      c,#1c19         ; yes, jump ahead
	    bcs :is_on_edge

;1bfe  3aa74d    ld      a,(#4da7)	; no, load A with red ghost blue flag (0=not blue)
	    lda |redghost_blue
;1c01  a7        and     a		; is the red ghost blue (edible) ?
;1c02  ca0b1c    jp      z,#1c0b		; no, skip ahead
	    beq :not_blue
;1c05  ef        rst     #28		; yes, insert task #0C to control red ghost movement when power pill active
;1c06  0c 00
	    lda #$000C
	    jsr rst28

;1c08  c3191c    jp      #1c19		; skip ahead
	    bra :is_on_edge

:not_blue
;1c0b  2a0a4d    ld      hl,(#4d0a)	; else load HL with red tile position (Y,X)
	    lda |redghost_tile_y
;1c0e  cd5220    call    #2052		; convert ghost Y,X position in HL to a color screen location
	    jsr yx_to_color_addy

;1c11  7e        ld      a,(hl)		; load A with color of screen location of ghost
	    tax
	    lda |0,x
	    and #$00FF
;1c12  fe1a      cp      #1a		; == #1A ?  (this color marks zones where ghosts cannot change direction, e.g. above the ghost house in pac-man)
	    cmp #$1A
;1c14  2803      jr      z,#1c19         ; yes, skip next step
	    beq :is_on_edge

;1c16  ef        rst     #28		; no, insert task #08 to control red ghost AI
;1c17  08 00

;]waithere bra ]waithere
; I think this doesn't get through, because the foreground
; must not be polling

	    lda #$0008
	    jsr rst28

:is_on_edge
;1c19  cdfe1e    call    #1efe		; check for and handle red ghost direction reversals
	    jsr check_reverse_red

;1c1c  dd211e4d  ld      ix,#4d1e	; load IX with red ghost tile changes
	    ldx #red_ghost_tchange_y
;1c20  fd210a4d  ld      iy,#4d0a	; load IY with red ghost tile position
	    ldy #redghost_tile_y
;1c24  cd0020    call    #2000		; HL := (IX) + (IY)
	    jsr double_add
;1c27  220a4d    ld      (#4d0a),hl	; store new result into red ghost tile position
	    sta |redghost_tile_y
;1c2a  2a1e4d    ld      hl,(#4d1e)	; load HL with red ghost tile changes
	    lda |red_ghost_tchange_y
;1c2d  22144d    ld      (#4d14),hl	; store into red ghost tile changes (A)
	    sta |red_ghost_tchangeA_y
;1c30  3a2c4d    ld      a,(#4d2c)	; load A with red ghost orientation
	    lda |red_ghost_dir
;1c33  32284d    ld      (#4d28),a	; store into previous red ghost orientation
	    sta |prev_red_ghost_dir
;
:jump_ahead

;1c36  dd21144d  ld      ix,#4d14	; load IX with red ghost tile changes (A)
	    ldx #red_ghost_tchangeA_y
;1c3a  fd21004d  ld      iy,#4d00	; load IY with red ghost position
	    ldy #red_ghost_y
;1c3e  cd0020    call    #2000		; HL := (IX) + (IY)
	    jsr double_add
;1c41  22004d    ld      (#4d00),hl	; store result into red ghost position
	    sta |red_ghost_y
;1c44  cd1820    call    #2018		; convert sprite position into a tile position
	    jsr spr_to_tile
;1c47  22314d    ld      (#4d31),hl	; store into red ghost tile position 2 
	    sta |red_tile_y_2
;1c4a  c9        ret			; return
	    rts
;------------------------------------------------------------------------------
; control movement patterns for pink ghost
; called from #104A
; 1c4b
control_pink mx %00
;1c4b  3aa14d    ld      a,(#4da1)	; load A with pink ghost substate
	    lda |pink_substate
;1c4e  fe01      cp      #01		; is pink ghost at home ?
	    cmp #1
;1c50  c0        ret     nz		; yes, return
	    beq :pink_out
:rts
	    rts
:pink_out
;1c51  3aad4d    ld      a,(#4dad)	; else load A with pink ghost state
	    lda |pinkghost_state
;1c54  a7        and     a		; is pink ghost alive ?
;1c55  c0        ret     nz		; no, return
	    bne :rts

;1c56  2a334d    ld      hl,(#4d33)	; load HL with pink ghost tile position 2
	    lda |pink_tile_y_2
;1c59  019a4d    ld      bc,#4d9a	; load BC with address of aux var used by pink ghost to check positions
	    ldy #pink_aux
;1c5c  cd5a20    call    #205a		; check to see if pink ghost has entered a tunnel slowdown area
	    jsr check_slow
;1c5f  3a9a4d    ld      a,(#4d9a)	; load A with aux var used by pink ghost to check positions
	    lda |pink_aux
;1c62  a7        and     a		; is the pink ghost in a tunnel slowdown area ?
;1c63  ca7d1c    jp      z,#1c7d		; no, skip ahead
	    beq :not_slow

;1c66  2a6c4d    ld      hl,(#4d6c)	; else load HL with speed bit patterns for pink ghost tunnel areas
;1c69  29        add     hl,hl		; double it
;1c6a  226c4d    ld      (#4d6c),hl	; store result
	    asl |speedbit_pink_tunnel+2
;1c6d  2a6a4d    ld      hl,(#4d6a)	; load HL with speed bit patterns for pink ghost tunnel areas
;1c70  ed6a      adc     hl,hl		; double it
;1c72  226a4d    ld      (#4d6a),hl	; store result.   Have we exceeded the threshold ?
		lda |speedbit_pink_tunnel
		adc |speedbit_pink_tunnel
		sta |speedbit_pink_tunnel
;1c75  d0        ret     nc		; no, return
	    bcc :rts

;1c76  216c4d    ld      hl,#4d6c	; else load HL with address of speed bit patterns for pink ghost tunnel areas
;1c79  34        inc     (hl)		; increase
	    inc |speedbit_pink_tunnel+2
;1c7a  c3af1c    jp      #1caf		; skip ahead
	    bra pink_ghost_move
:not_slow
;1c7d  3aa84d    ld      a,(#4da8)	; load A with pink ghost blue flag
	    lda |pinkghost_blue
;1c80  a7        and     a		; is the pink ghost blue ?
;1c81  ca9b1c    jp      z,#1c9b		; no, skip ahead
	    beq :not_blue

;1c84  2a684d    ld      hl,(#4d68)	; yes, load HL with speed bit patterns for pink ghost blue state
;1c87  29        add     hl,hl		; double it
;1c88  22684d    ld      (#4d68),hl	; store result
	    asl |speedbit_pink_blue+2
;1c8b  2a664d    ld      hl,(#4d66)	; load HL with speed bit patterns for pink ghost blue state
;1c8e  ed6a      adc     hl,hl		; double it
;1c90  22664d    ld      (#4d66),hl	; store result.  have we exceeded the threshold ?
		lda |speedbit_pink_blue
		adc |speedbit_pink_blue
		sta |speedbit_pink_blue
;1c93  d0        ret     nc		; no, return
	    bcc :rts

;1c94  21684d    ld      hl,#4d68	; yes, load HL with speed bit patterns for pink ghost blue state
;1c97  34        inc     (hl)		; increase
	    inc |speedbit_pink_blue+2
;1c98  c3af1c    jp      #1caf		; skip ahead
	    bra pink_ghost_move
:not_blue
;1c9b  2a644d    ld      hl,(#4d64)	; load HL with speed bit patterns for pink ghost normal state
;1c9e  29        add     hl,hl		; double it
;1c9f  22644d    ld      (#4d64),hl	; store result
	    asl |speedbit_pink_normal+2
;1ca2  2a624d    ld      hl,(#4d62)	; load HL with speed bit patterns for pink ghost normal state
;1ca5  ed6a      adc     hl,hl		; double it
;1ca7  22624d    ld      (#4d62),hl	; store result.  have we exceeded the threshold ?
		lda |speedbit_pink_normal
		adc |speedbit_pink_normal
		sta |speedbit_pink_normal
;1caa  d0        ret     nc		; no, return
	    bcc :rts
;1cab  21644d    ld      hl,#4d64	; yes, load HL with speed bit patterns for pink ghost normal state
;1cae  34        inc     (hl)		; increase
	    inc |speedbit_pink_normal+2

;------------------------------------------------------------------------------
;1caf
pink_ghost_move mx %00
;1caf  21164d    ld      hl,#4d16	; load HL with address for pink ghost Y tile changes
;1cb2  7e        ld      a,(hl)		; load A with pink ghost Y tile changes
	    lda |pink_ghost_tchangeA_y
;1cb3  a7        and     a		; Is the pink ghost moving left-right or right-left ?
	    and #$FF
;1cb4  cac41c    jp      z,#1cc4		; yes, skip ahead
	    beq :skip_ahead

;1cb7  3a024d    ld      a,(#4d02)	; no, load A with pink ghost Y position
	    lda |pink_ghost_y
;1cba  e607      and     #07		; mask bits
	    and #$0007
;1cbc  fe04      cp      #04		; is pink ghost in the middle of the tile ?
	    cmp #4
;1cbe  cace1c    jp      z,#1cce		; yes, skip ahead
	    beq :mid_tile

;1cc1  c30d1d    jp      #1d0d		; no, jump ahead
	    bra :jump_ahead
:skip_ahead
;1cc4  3a034d    ld      a,(#4d03)	; load A with pink ghost X position
	    lda |pink_ghost_x
;1cc7  e607      and     #07		; mask bits
	    and #$0007
;1cc9  fe04      cp      #04		; is pink ghost in the middle of the tile ?
	    cmp #4
;1ccb  c20d1d    jp      nz,#1d0d	; no, skip ahead
	    bne :jump_ahead
:mid_tile
;1cce  3e02      ld      a,#02		; yes, A := #02
	    lda #2
;1cd0  cdd01e    call    #1ed0		; check to see if pink ghost is on the edge of the screen (tunnel)
	    jsr check_screen_edge
;1cd3  381b      jr      c,#1cf0         ; yes, jump ahead
	    bcs :is_on_edge

;1cd5  3aa84d    ld      a,(#4da8)	; no, load A with pink ghost blue flag (0=not blue)
	    lda |pinkghost_blue
;1cd8  a7        and     a		; is the pink ghost blue ?
;1cd9  cae21c    jp      z,#1ce2		; no, skip ahead
	    beq :not_blue

;1cdc  ef        rst     #28		; yes, insert task to handle pink ghost movement when power pill active
;1cdd  0d 00				; task data
	    lda #$000D
	    jsr rst28
;1cdf  c3f01c    jp      #1cf0		; skip ahead
	    bra :is_on_edge

:not_blue
;1ce2  2a0c4d    ld      hl,(#4d0c)	; load HL with pink ghost Y,X tile pos
	    lda |pinkghost_tile_y
;1ce5  cd5220    call    #2052		; convert ghost Y,X position in HL to a color screen location
	    jsr yx_to_color_addy

;1ce8  7e        ld      a,(hl)		; load A with color screen position of ghost
	    tax
	    lda |0,x
	    and #$00FF
;1ce9  fe1a      cp      #1a		; == #1A? (this color marks zones where ghosts cannot change direction, e.g. above the ghost house in pac-man)
	    cmp #$1A
;1ceb  2803      jr      z,#1cf0         ; yes, skip next step
	    beq :is_on_edge

;1ced  ef        rst     #28		; insert task to handle pink ghost AI
;1cee  09 00				; task data
	    lda #$0009
	    jsr rst28
:is_on_edge
;1cf0  cd251f    call    #1f25		; check for and handle when pink ghost reverses directions
	    jsr check_reverse_pink
;1cf3  dd21204d  ld      ix,#4d20	; load IX with pink ghost tile changes
	    ldx #pink_ghost_tchange_y
;1cf7  fd210c4d  ld      iy,#4d0c	; load IY with pink ghost tile position
	    ldy #pinkghost_tile_y
;1cfb  cd0020    call    #2000		; HL := (IX) + (IY)
	    jsr double_add
;1cfe  220c4d    ld      (#4d0c),hl	; store new result into pink ghost tile position
	    sta |pinkghost_tile_y
;1d01  2a204d    ld      hl,(#4d20)	; load HL with pink ghost tile changes
	    lda |pink_ghost_tchange_y
;1d04  22164d    ld      (#4d16),hl	; store into pink ghost tile changes (A)
	    sta |pink_ghost_tchangeA_y
;1d07  3a2d4d    ld      a,(#4d2d)	; load A with pink ghost orientation
	    lda |pink_ghost_dir
;1d0a  32294d    ld      (#4d29),a	; store into previous pink ghost orientation
	    sta |prev_pink_ghost_dir
:jump_ahead
;1d0d  dd21164d  ld      ix,#4d16	; load IX with pink ghost tile changes (A)
	    ldx #pink_ghost_tchangeA_y
;1d11  fd21024d  ld      iy,#4d02	; load IY with pink ghost position
	    ldy #pink_ghost_y
;1d15  cd0020    call    #2000		; HL := (IX) + (IY)
	    jsr double_add
;1d18  22024d    ld      (#4d02),hl	; store result into pink ghost postion			
	    sta |pink_ghost_y
;1d1b  cd1820    call    #2018		; convert sprite position into a tile position
	    jsr spr_to_tile
;1d1e  22334d    ld      (#4d33),hl	; store into pink ghost tile position 2
	    sta |pink_tile_y_2
	    rts                    ; return 

;------------------------------------------------------------------------------
; check movement patterns for inky
; called from #104D
;1d22
control_inky mx %00
;1d22  3aa24d    ld      a,(#4da2)	; load A with blue ghost (inky) substate
	    lda |blue_substate
;1d25  fe01      cp      #01		; is blue ghost at home ?
	    cmp #1
;1d27  c0        ret     nz		; yes, return
	    beq :stay
:rts
	    rts
:stay
;1d28  3aae4d    ld      a,(#4dae)	; else load A with blue ghost (inky) state
	    lda |blueghost_state
;1d2b  a7        and     a		; is inky alive ?
;1d2c  c0        ret     nz		; no, return
	    bne :rts

;1d2d  2a354d    ld      hl,(#4d35)	; load HL with inky tile position 2
	    lda |blue_tile_y_2
;1d30  019b4d    ld      bc,#4d9b	; load BC with address of aux var used by inky to check positions
	    ldy #blue_aux
;1d33  cd5a20    call    #205a		; check to see if inky has entered a tunnel slowdown area
	    jsr check_slow
;1d36  3a9b4d    ld      a,(#4d9b)	; load A with aux var used by inky to check positions
	    lda |blue_aux
;1d39  a7        and     a		; is inky in a tunnel slowdown area?
;1d3a  ca541d    jp      z,#1d54		; no, skip ahead
	    beq :not_slow

;1d3d  2a784d    ld      hl,(#4d78)	; yes, load HL with speed bit patterns for inky tunnel areas
;1d40  29        add     hl,hl		; double it
;1d41  22784d    ld      (#4d78),hl	; store result
	    asl |speedbit_blue_tunnel+2
;1d44  2a764d    ld      hl,(#4d76)	; load HL with speed bit patterns for inky tunnel areas
;1d47  ed6a      adc     hl,hl		; double it
;1d49  22764d    ld      (#4d76),hl	; store result.  have we exceeded the threshold?
		lda |speedbit_blue_tunnel
		adc |speedbit_blue_tunnel
		sta |speedbit_blue_tunnel
;1d4c  d0        ret     nc		; no, return
	    bcc :rts

;1d4d  21784d    ld      hl,#4d78	; yes, load HL with address of speed bit patterns for inky tunnel areas
;1d50  34        inc     (hl)		; increase
	    inc |speedbit_blue_tunnel+2
;1d51  c3861d    jp      #1d86		; skip ahead
	    bra inky_ghost_move
:not_slow
;1d54  3aa94d    ld      a,(#4da9)	; load A with inky blue flag
	    lda |blueghost_blue
;1d57  a7        and     a		; is inky edible ?
;1d58  ca721d    jp      z,#1d72		; no, skip ahead
	    beq :not_blue

;1d5b  2a744d    ld      hl,(#4d74)	; yes, load HL with speed bit patterns for inky in blue state
;1d5e  29        add     hl,hl		; double it
;1d5f  22744d    ld      (#4d74),hl	; store result
	    asl |speedbit_blue_blue+2
;1d62  2a724d    ld      hl,(#4d72)	; load HL with speed bit patterns for inky in blue state
;1d65  ed6a      adc     hl,hl		; double it
;1d67  22724d    ld      (#4d72),hl	; store result.  have we exceeded the threshold?
		lda |speedbit_blue_blue
		adc |speedbit_blue_blue
		sta |speedbit_blue_blue
;1d6a  d0        ret     nc		; no, return
	    bcc :rts

;1d6b  21744d    ld      hl,#4d74	; yes, load HL with speed bit patterns for inky in blue state
;1d6e  34        inc     (hl)		; increase
	    inc |speedbit_blue_blue+2
;1d6f  c3861d    jp      #1d86		; jump ahead
	    bra inky_ghost_move
:not_blue
;1d72  2a704d    ld      hl,(#4d70)	; load HL with speed bit patterns for inky normal state
;1d75  29        add     hl,hl		; double it
;1d76  22704d    ld      (#4d70),hl	; store result
	    asl |speedbit_blue_normal+2
;1d79  2a6e4d    ld      hl,(#4d6e)	; load HL with speed bit patterns for inky normal state
;1d7c  ed6a      adc     hl,hl		; double it
;1d7e  226e4d    ld      (#4d6e),hl	; store result. have we exceeded the threshold ?
		lda |speedbit_blue_normal
		adc |speedbit_blue_normal
		sta |speedbit_blue_normal
;1d81  d0        ret     nc		; no, return
	    bcc :rts

;1d82  21704d    ld      hl,#4d70	; yes, load HL with speed bit patterns for inky normal state
;1d85  34        inc     (hl)		; increase
	    inc |speedbit_blue_normal+2

inky_ghost_move	mx %00
;1d86  21184d    ld      hl,#4d18	; load HL with address of inky Y tile changes
;1d89  7e        ld      a,(hl)		; load A with inky Y tile changes
	    lda |blue_ghost_tchangeA_y
;1d8a  a7        and     a		; is inky moving left-right or right left ?
	    and #$00FF
;1d8b  ca9b1d    jp      z,#1d9b		; yes, skip ahead
	    beq :skip_ahead

;1d8e  3a044d    ld      a,(#4d04)	; no, load A with inky Y position
	    lda |blue_ghost_y
;1d91  e607      and     #07		; mask bits
	    and #7
;1d93  fe04      cp      #04		; is inky in the middle of a tile ?
	    cmp #4
;1d95  caa51d    jp      z,#1da5		; yes, skip ahead
	    beq :is_middle
;1d98  c3e41d    jp      #1de4		; no, jump ahead
	    bra :jump_ahead
:skip_ahead
;1d9b  3a054d    ld      a,(#4d05)	; load A with inky X position
	    lda |blue_ghost_x
;1d9e  e607      and     #07		; mask bits
	    and #7
;1da0  fe04      cp      #04		; is inky in the middle of the tile ?
	    cmp #4
;1da2  c2e41d    jp      nz,#1de4	; no, skip ahead
	    bne	:jump_ahead
:is_middle
;1da5  3e03      ld      a,#03		; yes, A := #03
	    lda #3
;1da7  cdd01e    call    #1ed0		; check to see if inky is on the edge of the screen (tunnel)
	    jsr check_screen_edge
;1daa  381b      jr      c,#1dc7         ; yes, jump ahead
	    bcs :is_on_edge

;1dac  3aa94d    ld      a,(#4da9)	; no, load A with inky blue flag (0 = not blue)
	    lda |blueghost_blue
;1daf  a7        and     a		; is inky edible ?
;1db0  cab91d    jp      z,#1db9		; no, skip ahead
	    beq :not_blue

;1db3  ef        rst     #28		; yes, insert task to handle blue ghost (inky) movement when power pill active
;1db4  0e 00
	    lda #$000E
	    jsr rst28
;1db6  c3c71d    jp      #1dc7		; skip ahead
	    bra :is_on_edge
:not_blue
;1db9  2a0e4d    ld      hl,(#4d0e)	; load HL with inky tile position
	    lda |blueghost_tile_y
;1dbc  cd5220    call    #2052		; covert to color screen location
	    jsr yx_to_color_addy
	    tax
;1dbf  7e        ld      a,(hl)		; load A with color of screen location
	    lda |0,x
	    and #$00FF
;1dc0  fe1a      cp      #1a		; == #1A ? (this color marks zones where ghosts cannot change direction, e.g. above the ghost house in pac-man)
	    cmp #$001A
;1dc2  2803      jr      z,#1dc7         ; yes, skip next step
	    beq :is_on_edge

;1dc4  ef        rst     #28		; insert task to handle blue ghost (inky) AI
;1dc5  0a 00
	    lda #$000A
	    jsr rst28

:is_on_edge
;1dc7  cd4c1f    call    #1f4c		; check for and handle when inky reverses directions
	    jsr check_reverse_inky

;1dca  dd21224d  ld      ix,#4d22	; load IX with inky tile changes
	    ldx #blue_ghost_tchange_y
;1dce  fd210e4d  ld      iy,#4d0e	; load IY with inky tile position
	    ldy #blueghost_tile_y
;1dd2  cd0020    call    #2000		; HL := (IX) + (IY)
	    jsr double_add
;1dd5  220e4d    ld      (#4d0e),hl	; store new result into inky tile position
	    sta |blueghost_tile_y
;1dd8  2a224d    ld      hl,(#4d22)	; load HL with inky tile changes
	    lda |blue_ghost_tchange_y
;1ddb  22184d    ld      (#4d18),hl	; store into inky tile changes (A)
	    sta |blue_ghost_tchangeA_y
;1dde  3a2e4d    ld      a,(#4d2e)	; load A with inky orientation
	    lda |blue_ghost_dir
;1de1  322a4d    ld      (#4d2a),a	; store into inky previous orientation
	    sta |prev_blue_ghost_dir
:jump_ahead
;1de4  dd21184d  ld      ix,#4d18	; load IX with inky tile changes (A)
	    ldx #blue_ghost_tchangeA_y
;1de8  fd21044d  ld      iy,#4d04	; load IY with inky position
	    ldy #blue_ghost_y
;1dec  cd0020    call    #2000		; HL := (IX) + (IY)
	    jsr double_add
;1def  22044d    ld      (#4d04),hl	; store result into inky position
	    sta |blue_ghost_y
;1df2  cd1820    call    #2018		; convert sprite position into a tile position
	    jsr spr_to_tile
;1df5  22354d    ld      (#4d35),hl	; store into inky tile position 2
	    sta |blue_tile_y_2
;1df8  c9        ret     		; return
	    rts

;------------------------------------------------------------------------------
; control movement patterns for orange ghost
; called from #1050
;1df9
control_orange mx %00
;1df9  3aa34d    ld      a,(#4da3)	; load A with orange ghost substate
	    lda |orange_substate
;1dfc  fe01      cp      #01		; is orange ghost at home ?
	    cmp #1
;1dfe  c0        ret     nz		; yes, return
	    beq :stay
:rts
	    rts
:stay
;1dff  3aaf4d    ld      a,(#4daf)	; else load A with orange ghost state
	    lda |orangeghost_state
;1e02  a7        and     a		; is orange ghost alive ?
;1e03  c0        ret     nz		; no, return
	    bne :rts
;1e04  2a374d    ld      hl,(#4d37)	; load HL with orange ghost tile position 2
	    lda |orange_tile_y_2
;1e07  019c4d    ld      bc,#4d9c	; load BC with address of aux var used by orange ghost to check positions
	    ldy #orange_aux
;1e0a  cd5a20    call    #205a		; check to see if orange ghost has entered a tunnel slowdown area
	    jsr check_slow
;1e0d  3a9c4d    ld      a,(#4d9c)	; load A with aux var used by orange ghost to check positions
	    lda |orange_aux
;1e10  a7        and     a		; is the orange ghost in a tunnel slowdown area?
;1e11  ca2b1e    jp      z,#1e2b		; no, skip ahead
	    beq :not_slow
;1e14  2a844d    ld      hl,(#4d84)	; yes, load HL with speed bit patterns for orange ghost tunnel areas
;1e17  29        add     hl,hl		; double it
;1e18  22844d    ld      (#4d84),hl	; store result
	    asl |speedbit_orange_tunnel+2
;1e1b  2a824d    ld      hl,(#4d82)	; load HL with speed bit patterns for orange ghost tunnel areas
;1e1e  ed6a      adc     hl,hl		; double it
;1e20  22824d    ld      (#4d82),hl	; store result.  have we exceeded the threshold?
		lda |speedbit_orange_tunnel
		adc |speedbit_orange_tunnel
		sta |speedbit_orange_tunnel
;1e23  d0        ret     nc		; no, return
	    bcc :rts
;
;1e24  21844d    ld      hl,#4d84	; yes, load HL with speed bit patterns for orange ghost tunnel areas
;1e27  34        inc     (hl)		; increase
	    inc |speedbit_orange_tunnel+2
;1e28  c35d1e    jp      #1e5d		; skip ahead
	    bra orange_ghost_move
:not_slow
;1e2b  3aaa4d    ld      a,(#4daa)	; load A with orange ghost blue flag
	    lda |orangeghost_blue
;1e2e  a7        and     a		; is the orange ghost blue ( edible ) ?
;1e2f  ca491e    jp      z,#1e49		; no, skip ahead
	    beq :not_blue
;
;1e32  2a804d    ld      hl,(#4d80)	; yes, load HL with speed bit patterns for orange ghost blue state
;1e35  29        add     hl,hl		; double it
;1e36  22804d    ld      (#4d80),hl	; store result
	    asl |speedbit_orange_blue+2
;1e39  2a7e4d    ld      hl,(#4d7e)	; load HL with speed bit patterns for orange ghost blue state
;1e3c  ed6a      adc     hl,hl		; double it
;1e3e  227e4d    ld      (#4d7e),hl	; store result.  have we exceeded the threshold ?
		lda |speedbit_orange_blue
		adc |speedbit_orange_blue
		sta |speedbit_orange_blue
;1e41  d0        ret     nc		; no, return
	    bcc :rts
;
;1e42  21804d    ld      hl,#4d80	; yes, load HL with speed bit patterns for orange ghost blue state
;1e45  34        inc     (hl)		; increase
	    inc |speedbit_orange_blue+2
;1e46  c35d1e    jp      #1e5d		; skip ahead
	    bra orange_ghost_move

:not_blue
;1e49  2a7c4d    ld      hl,(#4d7c)	; load HL with speed bit patterns for orange ghost normal state
;1e4c  29        add     hl,hl		; double it
;1e4d  227c4d    ld      (#4d7c),hl	; store result
	    asl |speedbit_orange_normal+2
;1e50  2a7a4d    ld      hl,(#4d7a)	; load HL with speed bit patterns for orange ghost normal state
;1e53  ed6a      adc     hl,hl		; double it
;1e55  227a4d    ld      (#4d7a),hl	; store result.  have we exceeded the threshold ?
	    lda |speedbit_orange_normal
	    adc |speedbit_orange_normal
	    sta |speedbit_orange_normal
;1e58  d0        ret     nc		; no, return
	    bcc :rts
;
;1e59  217c4d    ld      hl,#4d7c	; yes, load HL with speed bit patterns for orange ghost normal state
;1e5c  34        inc     (hl)		; increase
	    inc |speedbit_orange_normal+2

;------------------------------------------------------------------------------
;1e5d
orange_ghost_move mx %00
;1e5d  211a4d    ld      hl,#4d1a	; load HL with address for orange ghost Y tile changes
;1e60  7e        ld      a,(hl)		; load A with orange ghost Y tile changes
	    lda |orange_ghost_tchangeA_y
;1e61  a7        and     a		; is the orange ghost moving left-right or right-left ?
	    and #$ff
;1e62  ca721e    jp      z,#1e72		; yes, skip ahead
	    beq :skip_ahead
;
;1e65  3a064d    ld      a,(#4d06)	; no, load A with orange ghost Y position
	    lda |orange_ghost_y
;1e68  e607      and     #07		; mask bits
	    and #7
;1e6a  fe04      cp      #04		; is orange ghost in the middle of the tile ?
	    cmp #4
;1e6c  ca7c1e    jp      z,#1e7c		; yes, skip ahead
	    beq :is_mid_tile
;1e6f  c3bb1e    jp      #1ebb		; no, jump ahead
	    bra :jump_ahead
:skip_ahead
;1e72  3a074d    ld      a,(#4d07)	; load A with orange ghost X position
	    lda |orange_ghost_x
;1e75  e607      and     #07		; mask bits
	    and #7
;1e77  fe04      cp      #04		; is orange ghost in the middle of the tile ?
	    cmp #4
;1e79  c2bb1e    jp      nz,#1ebb	; no, skip ahead
	    bne :jump_ahead
:is_mid_tile
;1e7c  3e04      ld      a,#04		; yes, A := #04
	    lda #4
;1e7e  cdd01e    call    #1ed0		; check to see if orange ghost is on the edge of the screen (tunnel)
	    jsr check_screen_edge
;1e81  381b      jr      c,#1e9e         ; yes, jump ahead
	    bcs :on_edge
;1e83  3aaa4d    ld      a,(#4daa)	; no, load A with orange ghost blue flag (0 = not blue)
	    lda |orangeghost_blue
;1e86  a7        and     a		; is the orange ghost blue (edible) ?
;1e87  ca901e    jp      z,#1e90		; no, skip ahead
	    beq :not_blue
;1e8a  ef        rst     #28		; yes, insert task to handle orange ghost movement when power pill active
;1e8b  0f 00				; task data
	    lda #$000F
	    jsr rst28
;1e8d  c39e1e    jp      #1e9e		; skip ahead
	    bra :on_edge
:not_blue
;1e90  2a104d    ld      hl,(#4d10)	; load HL with orange ghost Y,X tile position
	    lda orangeghost_tile_y
;1e93  cd5220    call    #2052		; covert Y,X position in HL to color screen location
	    jsr yx_to_color_addy
;1e96  7e        ld      a,(hl)		; load A with color screen position of ghost
	    tax
	    lda |0,x
;1e97  fe1a      cp      #1a		; == #1A ((this color marks zones where ghosts cannot change direction, e.g. above the ghost house in pac-man)
	    and #$FF
	    cmp #$1A
;1e99  2803      jr      z,#1e9e         ; yes, skip next step
	    beq :on_edge
;
;1e9b  ef        rst     #28		; insert task to control orange ghost AI
;1e9c  0b 00				; task data
	    lda #$000B
	    jsr rst28
:on_edge
;1e9e  cd731f    call    #1f73		; check for and handle when orange ghost reverses directions
	    jsr check_reverse_orange

;1ea1  dd21244d  ld      ix,#4d24	; load IX with orange ghost tile changes
	    ldx #orange_ghost_tchange_y
;1ea5  fd21104d  ld      iy,#4d10	; load IY with orange ghost tile position
	    ldy #orangeghost_tile_y
;1ea9  cd0020    call    #2000		; HL := (IX) + (IY)
	    jsr double_add
;1eac  22104d    ld      (#4d10),hl	; store result into orange ghost tile position
	    sta |orangeghost_tile_y
;1eaf  2a244d    ld      hl,(#4d24)	; load HL with orange ghost tile changes
	    lda |orange_ghost_tchange_y
;1eb2  221a4d    ld      (#4d1a),hl	; store into orange ghost tile changes (A)
	    sta |orange_ghost_tchangeA_y
;1eb5  3a2f4d    ld      a,(#4d2f)	; load A with orange ghost orientation
	    lda |orange_ghost_dir
;1eb8  322b4d    ld      (#4d2b),a	; store into previous orange ghost orientation
	    sta |prev_orange_ghost_dir
:jump_ahead
;1ebb  dd211a4d  ld      ix,#4d1a	; load IX with orange ghost tile changes (A)
	    ldx #orange_ghost_tchangeA_y
;1ebf  fd21064d  ld      iy,#4d06	; load IY with orange ghost position
	    ldy #orange_ghost_y
;1ec3  cd0020    call    #2000		; HL := (IX) + (IY)
	    jsr double_add
;1ec6  22064d    ld      (#4d06),hl	; store result into orange ghost position
	    sta |orange_ghost_y
;1ec9  cd1820    call    #2018		; convert sprite position into a tile position
	    jsr spr_to_tile
;1ecc  22374d    ld      (#4d37),hl	; store into orange ghost tile position 2
	    sta |orange_tile_y_2
;1ecf  c9        ret			; return
	    rts

;------------------------------------------------------------------------------
; called from #1A3A while in demo mode
; called from #1BF9 when red ghost movement checking.  A is preloaded with #01
; if the ghost/pacman is on the edge of the screen, the carry flag is set, else it is cleared
; 1ed0
check_screen_edge mx %00
	    sep #$30		; short a,x
;1ed0  87        add     a,a		; A := A * 2
	    asl
;1ed1  4f        ld      c,a		; copy to C
;1ed2  0600      ld      b,#00		; B := #00
	    tax
;1ed4  21094d    ld      hl,#4d09	; load HL with pacman X position address
;1ed7  09        add     hl,bc		; add offset to HL.  HL how has the ghost/pacman tile position address
;1ed8  7e        ld      a,(hl)		; load A with ghost/pacman tile X position
	    lda |pacman_x,x
;1ed9  fe1d      cp      #1d		; has the ghost moved off the far right side of the screen?
	    cmp #$1d
;1edb  c2e31e    jp      nz,#1ee3	; no, skip next 2 steps
	    bne :no

;1ede  363d      ld      (hl),#3d	; yes, change ghost/pacman X position to far left side of screen
	    lda #$3d
	    sta |pacman_x,x
;1ee0  c3fc1e    jp      #1efc		; jump ahead, set carry flag and return
	    bra :sec
:no

;1ee3  fe3e      cp      #3e		; has the ghost/pacman moved off the far left side of the screen ?
	    cmp #$3e
;1ee5  c2ed1e    jp      nz,#1eed	; no, skip next 2 steps
	    bne :not_edge

;1ee8  361e      ld      (hl),#1e	; yes, change ghost/pacman X position to far right side of screen
	    lda #$1e
	    sta |pacman_x,x
;1eea  c3fc1e    jp      #1efc		; jump ahead, set carry flag and return
	    bra :sec
:not_edge
;1eed  0621      ld      b,#21		; B := #21
;1eef  90        sub     b		; subtract from ghost/pacman X position.  is the ghost on the far right edge ?
	    sec
	    sbc #$21
;1ef0  dafc1e    jp      c,#1efc		; yes, set carry flag and return
	    bcc :sec

;1ef3  7e        ld      a,(hl)		; else load A with ghost/pacman tile X position
	    lda |pacman_x,x
;1ef4  063b      ld      b,#3b		; B := #3B
;1ef6  90        sub     b		; subtract.  is the ghost/pacman on the far left edge?
	    sec
	    sbc #$3b
;1ef7  d2fc1e    jp      nc,#1efc	; yes, set carry flag and return
	    bcs :sec 			;;$$JGA MAYBE REVISIT
:clc
;1efa  a7        and     a		; else clear carry flag
	    rep #$31	; mxc = 000
;1efb  c9        ret			; return
	    rts
:sec
;1efc  37        scf			; set carry flag
	    rep #$30
	    sec
;1efd  c9        ret			; return
	    rts

;------------------------------------------------------------------------------
; check for reverse direction of red ghost
; 1efe
check_reverse_red mx %00
;1efe  3ab14d    ld      a,(#4db1)	; load A with red ghost change orientation flag
	    lda |red_change_dir
;1f01  a7        and     a		; is the red ghost reversing direction ?
;1f02  c8        ret     z		; no, return
	    bne :yes
	    rts			; no, return

; reverse direction of red ghost
:yes

;;1f03  af        xor     a		; yes, A := #00
;;1f04  32b14d    ld      (#4db1),a	; clear red ghost change orientation flag
	    stz |red_change_dir

;1f07  21ff32    ld      hl,#32ff	; load HL with table data - tile differences tables for movements
;1f0a  3a284d    ld      a,(#4d28)	; load A with previous red ghost orientation
	    lda |prev_red_ghost_dir
;1f0d  ee02      xor     #02		; toggle bit 1
	    eor #$0002
;1f0f  322c4d    ld      (#4d2c),a	; store into red ghost orientation
	    sta |red_ghost_dir
	    tay

;;1f12  47        ld      b,a		; copy to B
;;1f13  df        rst     #18		; load HL with tile difference for movements based on table at #32FF
	    asl
	    tax
	    lda |tile_move_table,x  	; see 1f07

;1f14  221e4d    ld      (#4d1e),hl	; store into red ghost tile changes
	    sta |red_ghost_tchange_y
	    tax

;1f17  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
	    lda |mainroutine1
;1f1a  fe22      cp      #22		; == #22 ?
	    cmp #$22
	    beq :continue
;1f1c  c0        ret     nz		; no, return
	    rts
:continue
;1f1d  22144d    ld      (#4d14),hl	; yes, store movement into alternate red ghost tile changes
	    stx |red_ghost_tchangeA_y
;1f20  78        ld      a,b		; load A with red ghost orientation
;1f21  32284d    ld      (#4d28),a	; store into previous red ghost orientation
	    sty |prev_red_ghost_dir
;1f24  c9        ret			; return
	    rts

;------------------------------------------------------------------------------
; check for reverse direction of pink ghost
; 1f25
check_reverse_pink mx %00

;1f25  3ab24d    ld      a,(#4db2)	; load A with pink ghost change orientation flag
	    lda |pink_change_dir
;1f28  a7        and     a		; is the pink ghost reversing direction ?
;1f29  c8        ret     z		; no, return
	    bne :yes
	    rts				; no, return

; reverse direction of pink ghost
:yes
;1f2a  af        xor     a		; yes, A := #00
;1f2b  32b24d    ld      (#4db2),a	; clear pink ghost change orientation flag
	    stz |pink_change_dir
reverse_pink mx %00
;1f2e  21ff32    ld      hl,#32ff	; load HL with table data - tile differences tables for movements
;1f31  3a294d    ld      a,(#4d29)	; load A with previous pink ghost orientation
	    lda |prev_pink_ghost_dir
;1f34  ee02      xor     #02		; flip bit #1
	    eor #2
;1f36  322d4d    ld      (#4d2d),a	; store into pink ghost orientation
	    sta |pink_ghost_dir
	    tay
;1f39  47        ld      b,a		; copy to B
;1f3a  df        rst     #18		; load HL with new direction tile offsets
	    asl
	    tax
	    lda |tile_move_table,x      ; see 1f2e
;1f3b  22204d    ld      (#4d20),hl	; store into pink ghost tile offsets
	    sta |pink_ghost_tchange_y
	    tax
;1f3e  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
	    lda |mainroutine1
;1f41  fe22      cp      #22		; == #22 (check for demo mode, pac-man only, when pac-man is chased by 4 ghosts on title screen)
	    cmp #$22
	    beq :continue
;1f43  c0        ret     nz		; no, return
	    rts
:continue
;1f44  22164d    ld      (#4d16),hl	; yes, store new direction tile offsets into alternate pink ghost tile changes
	    stx	|pink_ghost_tchangeA_y
;1f47  78        ld      a,b		; load A with pink ghost orientation
;1f48  32294d    ld      (#4d29),a	; store into previous pink ghost direction
	    sty |prev_pink_ghost_dir
;1f4b  c9        ret     		; return
	    rts

;------------------------------------------------------------------------------
; check for reverse direction of inky
; 1f4c
check_reverse_inky mx %00

;1f4c  3ab34d    ld      a,(#4db3)	; load A with blue ghost (inky) change orientation flag
	    lda |blue_change_dir
;1f4f  a7        and     a		; is inky reversing direction ?
;1f50  c8        ret     z		; no, return
	    bne :yes
	    rts				; no, return

; reverse direction of inky
:yes
;+-------1f51  af        xor     a		; yes, A := #00
;1f52  32b34d    ld      (#4db3),a	; clear inky ghost change orienation flag
	    stz |blue_change_dir
reverse_inky mx %00
;1f55  21ff32    ld      hl,#32ff	; load HL with table data - tile differences tables for movements
;1f58  3a2a4d    ld      a,(#4d2a)	; load A with previous inky orientation
	    lda |prev_blue_ghost_dir
;1f5b  ee02      xor     #02		; flip bit #1
	    eor #2
;1f5d  322e4d    ld      (#4d2e),a	; store into inky orientation
	    sta |blue_ghost_dir
	    tay
;1f60  47        ld      b,a		; copy to B
;1f61  df        rst     #18		; load HL with new direction tile offsets
	    asl
	    tax
	    lda |tile_move_table,x	; see 1f55
;1f62  22224d    ld      (#4d22),hl	; store into inky ghost tile offsets
	    sta |blue_ghost_tchange_y
	    tax
;1f65  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
	    lda |mainroutine1
;1f68  fe22      cp      #22		; == #22 ? (check for demo mode, pac-man only, when pac-man is chased by 4 ghosts on title screen)
	    cmp #$22
;1f6a  c0        ret     nz		; no, return
	    beq :continue
	    rts
:continue
;1f6b  22184d    ld      (#4d18),hl	; yes, store new direction tile offsets into alternate inky ghost tile changes
	    stx |blue_ghost_tchangeA_y
;1f6e  78        ld      a,b		; load A with inky orientation
;1f6f  322a4d    ld      (#4d2a),a	; store into previous inky direction
	    sty |prev_blue_ghost_dir 
;1f72  c9        ret			; return
	    rts

;------------------------------------------------------------------------------
; check for reverse direction of orange ghost
; 1f73
check_reverse_orange mx %00

;1f73  3ab44d    ld      a,(#4db4)	; load A with orange ghost change orientation flag
	    lda |orange_change_dir
;1f76  a7        and     a		; is orange ghost reversing direction ?
;1f77  c8        ret     z		; no, return
	    bne :yes
	    rts				; no, return

; reverse direction of orange ghost
:yes
;1f78  af        xor     a		; yes, A := #00
;1f79  32b44d    ld      (#4db4),a	; clear orange ghost change orientation flag
	    stz |orange_change_dir
reverse_orange mx %00
;1f7c  21ff32    ld      hl,#32ff	; load HL with table data - tile differences tables for movements
;1f7f  3a2b4d    ld      a,(#4d2b)	; load A with previous orange ghost orienation
	    lda |prev_orange_ghost_dir
;1f82  ee02      xor     #02		; flip bit #1
	    eor #2
;1f84  322f4d    ld      (#4d2f),a	; store into orange ghost orienation
	    sta |orange_ghost_dir
	    tay
;1f87  47        ld      b,a		; copy to B
;1f88  df        rst     #18		; load HL with new direction tile offsets
	    asl
	    tax
	    lda |tile_move_table,x	; see 1f7c above
;1f89  22244d    ld      (#4d24),hl	; store into orange ghost tile offsets
	    sta |orange_ghost_tchange_y
	    tax
;1f8c  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
	    lda |mainroutine1
;1f8f  fe22      cp      #22		; == #22 ? (check for demo mode, pac-man only, when pac-man is chased by 4 ghosts on title screen)
	    cmp #$22
;1f91  c0        ret     nz		; no, return
	    beq :continue
	    rts

:continue
;1f92  221a4d    ld      (#4d1a),hl	; yes, store new direction tile offsets into alternate orange ghost tile changes
	    stx |orange_ghost_tchangeA_y
;1f95  78        ld      a,b		; load A with orange ghost orienation
;1f96  322b4d    ld      (#4d2b),a	; store into previous orange ghost direction
	    sty |prev_orange_ghost_dir
;1f99  c9        ret     		; return
	    rts


;------------------------------------------------------------------------------
;; this is a common function
; IY is preloaded with sprite locations
; IX is preloaded with offset to add
; result is stored into HL
; HL := (IX) + (IY)
; A = (X) + (Y)
;2000
double_add  mx %00
;2000  fd7e00    ld      a,(iy+#00)	; load A with IY value (Y position)
;2003  dd8600    add     a,(ix+#00)	; add with destination Y value
;2006  6f        ld      l,a		; store result into L
;200a  dd8601    add     a,(ix+#01)	; add with destination X value
;200d  67        ld      h,a		; store result into H
	    sep #$20   ; m=1 x=0
	    clc
	    lda |1,y
	    adc |1,x
	    xba
	    clc
	    lda |0,y
	    adc |0,x
	    rep #$31 	; mxc = 0
;200e  c9        ret     		; return
	    rts

;------------------------------------------------------------------------------
; load A with screen value of position computed in (IX) + (IY)
;200f
screen_xy mx %00
;200f  cd0020    call    #2000		; HL := (IX) + (IY)
	    jsr double_add
;2012  cd6500    call    #0065		; convert to screen position
	    jsr yx_to_screen

;2015  7e        ld      a,(hl)		; load A with the value in this screen position
	    tax
	    lda |0,x
	    and #$00FF
;2016  a7        and     a		; clear flags
	    clc
;2017  c9        ret     		; return
	    rts

;------------------------------------------------------------------------------
; converts a sprite position into a tile position
; HL is preloaded with sprite position
; at end, HL is loaded with tile position
; for us A = HL
;2018
spr_to_tile mx %00
	    sep #$20	; m=1
; I think the X, and Y are swapped here $$JGA revist maybe

;2018  7d        ld      a,l		; load A with X position
;2019  cb3f      srl     a
;201b  cb3f      srl     a
;201d  cb3f      srl     a		; shift right 3 times
	    lsr
	    lsr
	    lsr
	    clc
;201f  c620      add     a,#20		; add offset
	    adc #$20

;2021  6f        ld      l,a		; store into L
;2022  7c        ld      a,h		; load A with Y position
	    xba
;2023  cb3f      srl     a
;2025  cb3f      srl     a
;2027  cb3f      srl     a		; shift right 3 times
	    lsr
	    lsr
	    lsr
;2029  c61e      add     a,#1e		; add offset
	    clc
	    adc #$1e
;202b  67        ld      h,a		; store into H.  HL now has screen location
	    xba
;202c  c9        ret     		; return
	    rep #$31  	; mxc=000
	    rts

;------------------------------------------------------------------------------
; converts pac-mans sprite position into a grid position
; HL has sprite position at start, grid position at end
; 0065 jumps to here. 
; 202D
yx_to_screen mx %00

		sep #$21
		sta <temp0
		stz <temp0+1	; Y
		xba
		sta <temp1  	; X
		stz <temp1+1

		rep #$30  ; mxc = 001

		; (0x22..0x3e) (bottom-top = decrease)
		lda <temp0
		sbc #$20
		sta <temp0

		; (0x1e..0x3d) (left-right = decrease) 
		lda <temp1
		sbc #$20
		asl
		asl
		asl
		asl
		asl
		adc <temp0

		adc #tile_ram+$40

		rts

		do 0
:hl = temp0
:bc = temp1
;202D: F5            push af		; save AF
;202E: C5            push bc		; save BC
	    sta <:hl
;202F: 7D            ld   a,l		; load A with L.  
	    sep #$21	; mxc = 101
;2030: D6 20         sub  #20		; subtract #20.  
	    sbc #$20
;2032: 6F            ld   l,a		; store back into L. 
	    sta <:hl
;2033: 7C            ld   a,h		; load A with H.  
	    xba
;2034: D6 20         sub  #20		; subtract 20.  
	    sec
	    sbc #$20
;2036: 67            ld   h,a		; store back into H. 
	    sta <:hl+1
;2037: 06 00         ld   b,#00		; load B with #00
	    stz <:bc
;2039: CB 24         sla  h		; shift left through carry flag.  mult by 2
;203B: CB 24         sla  h
;203D: CB 24         sla  h
;203F: CB 24         sla  h	 
	    asl
	    asl
	    asl
	    asl
;2041: CB 10         rl   b
	    rol <:bc
;2043: CB 24         sla  h
	    asl
;2045: CB 10         rl   b
	    rol <:bc
;2047: 4C            ld   c,h
	    ;lda <:hl+1
	    sta <:bc+1
;2048: 26 00         ld   h,#00
	    stz <:hl+1

	    rep #$31 ; mxc = 000
;204A: 09            add  hl,bc		; add into HL
	    lda <:hl
	    adc <:bc
;204B: 01 40 40      ld   bc,#4040	; load BC with grid offset
;204E: 09            add  hl,bc		; add into HL
		and #$03FF
	    clc
	    adc #tile_ram+$40
;204F: C1            pop  bc		; restore BC
;2050: F1            pop  af		; restore AF
;2051: C9            ret			; return
	    rts
		fin

;------------------------------------------------------------------------------
; converts pac-man or ghost Y,X position in HL to a color screen location
; 2052

yx_to_color_addy mx %00
	    jsr yx_to_screen
	    clc
	    adc #$400	; add 1k offset
	    rts
;------------------------------------------------------------------------------
; checks for ghost entering a slowdown area in a tunnel
;205a
check_slow mx %00
;205a  cd5220    call    #2052		; convert ghost Y,X position in HL to a color screen location
	    jsr yx_to_color_addy
;205d  7e        ld      a,(hl)		; load A with the color of the ghost's location
	    ;lda |0,y
		sta <temp0
		lda (temp0)
	    and #$FF
;205e  fe1b      cp      #1b		; == #1b ? (code for no change of direction, eg above the ghost home in pac-man)
 ;           cmp #$1B

; OTTOPATCH
;PATCH TO MAKE BIT 6 OF THE COLOR MAP INDICATE SLOW AREAS
;ORG 2060H
;JP SLOWMAP
;NOP
;2060  c36f36    jp      #366f		; jump to new patch for ms. pac man.  if no tunnel match, returns to #2066

; arrive here from #2060 
; A is loaded with the color of the tile the ghost is on

;366f  cb77      bit     6,a		; test bit 6 of the tile.  is this a slow down zone (tunnel) ?
	    bit #$40
;3671  ca6620    jp      z,#2066		; no, jump back and set the var to zero
	    beq :not_slow
;3674  3e01      ld      a,#01		; yes, A := #01
	    lda #1
;3676  02        ld      (bc),a		; store into ghost tunnel slowdown flag
	    sta |0,y
;3677  c9        ret     		; return
	    rts

;2063  00        nop     		; junk from ms-pac patch

	; original pac-man code:
	;
	; 2060: 20 04         jr   nz,$2066	; no, skip ahead
	; 2062: 3E 01         ld   a,$01	; else A := #01
	;

;2064  02        ld      (bc),a		; store into ghost tunnel slowdown flag (pac-man only)
;2065  c9        ret     		; return (pac-man only)
:not_slow
;2066  af        xor     a		; A := #00
;2067  02        ld      (bc),a		; store into ghost tunnel slowdown flag
	    tyx
	    stz |0,x
;2068  c9        ret   ; return
	    rts

;------------------------------------------------------------------------------
;
; called from #105C
;2069
check_pink_house mx %00

;2069  3aa14d    ld      a,(#4da1)	; load A with pink ghost substate
	    lda |pink_substate
;206c  a7        and     a		; is the pink ghost at home ?
;206d  c0        ret     nz		; no, return
	    beq :at_home
:rts
	    rts
:at_home
;206e  3a124e    ld      a,(#4e12)	; load A with flag that is 1 after dying in a level, reset to 0 if ghosts have left home
	    lda |pacman_dead
;2071  a7        and     a		; is this flag set ?
;2072  ca7e20    jp      z,#207e		; no, skip ahead
	    beq :pacman_alive

;2075  3a9f4d    ld      a,(#4d9f)	; yes, load A with eaten pills counter after pacman has died in a level
	    lda |pills_eaten_since_death
;2078  fe07      cp      #07		; == #07 ?
	    cmp #7
;207a  c0        ret     nz		; no, return
	    bne :rts

;207b  c38620    jp      #2086		; yes, jump ahead and release pink ghost
	    bra release_pink

:pacman_alive
;207e  21b84d    ld      hl,#4db8	; load HL with address of pink ghost counter to go out of home pill limit
;2081  3a0f4e    ld      a,(#4e0f)	; load A with counter incremented if orange, blue and pink ghosts are home and pacman is eating pills.
	    lda |all_home_counter
;2084  be        cp      (hl)		; has the counter been exceeded?
	    cmp |pink_home_limit	; $$JGA REVISIT
;2085  d8        ret     c		; no, return
	    bcc :rts

;------------------------------------------------------------------------------
; releases pink ghost from the ghost house
; called from #1408
; 2086
release_pink mx %00
;2086  3e02      ld      a,#02		; A := #02
	    lda #2
;2088  32a14d    ld      (#4da1),a	; store into pink ghost substate to indicate he is leaving the ghost house
	    sta |pink_substate
;208b  c9        ret     		; return
	    rts

;------------------------------------------------------------------------------
; called from #105F
;208c
check_inky_house mx %00

;208c  3aa24d    ld      a,(#4da2)	; load A with blue ghost (inky) substate
	    lda |blue_substate
;208f  a7        and     a		; is inky at home ?
;2090  c0        ret     nz		; no, return
	    beq :continue
:rts
	    rts

:continue
;2091  3a124e    ld      a,(#4e12)	; yes, load A with flag that is 1 after dying in a level, reset to 0 if ghosts have left home
	    lda |pacman_dead
;2094  a7        and     a		; is this flag set ?
;2095  caa120    jp      z,#20a1		; no, skip ahead
	    beq :alive

;2098  3a9f4d    ld      a,(#4d9f)	; yes, load A with eaten pills counter after pacman has died in a level 
	    lda |pills_eaten_since_death
;209b  fe11      cp      #11		; == #11 ?
	    cmp #$11
;209d  c0        ret     nz		; no, return
	    bne :rts

;209e  c3a920    jp      #20a9		; yes, skip ahead and release inky
	    bra release_blue
:alive
;20a1  21b94d    ld      hl,#4db9	; load HL with address of inky counter to go out of home pill limit
;20a4  3a104e    ld      a,(#4e10)	; load A with counter incremented if blue ghost and orange ghost is home and pacman is eating pills.
	    lda |blue_home_counter      ; $$JGA REVISIT
;20a7  be        cp      (hl)		; has the counter been exceeded ?
	    cmp |blue_home_limit
;20a8  d8        ret     c		; no, return
	    bcc :rts

;------------------------------------------------------------------------------
; releases blue ghost (inky) from the ghost house
; called from #1412

release_blue
;20a9  3e03      ld      a,#03		; A := #03
	    lda #3
;20ab  32a24d    ld      (#4da2),a	; store in inky's ghost state
	    sta |blue_substate
;20ae  c9        ret     		; return
	    rts

;------------------------------------------------------------------------------
; called from #1062
;20af
check_orange_house mx %00
;20af  3aa34d    ld      a,(#4da3)	; load A with orange ghost substate
	    lda |orange_substate
;20b2  a7        and     a		; is orange ghost at home ?
;20b3  c0        ret     nz		; no, return
	    beq :continue
:rts
	    rts
:continue
;20b4  3a124e    ld      a,(#4e12)	; yes, load A with flag that is 1 after dying in a level, reset to 0 if ghosts have left home
	    lda |pacman_dead
;20b7  a7        and     a		; is this flag set ?
;20b8  cac920    jp      z,#20c9		; no, skip ahead
	    beq :alive

;20bb  3a9f4d    ld      a,(#4d9f)	; yes, load A with eaten pills counter after pacman has died in a level
	    lda |pills_eaten_since_death

;20be  fe20      cp      #20		; == #20 ?
	    cmp #$20
;20c0  c0        ret     nz		; no, return
	    bne :rts

;20c1  af        xor     a		; yes, A := #00
;20c2  32124e    ld      (#4e12),a	; clear flag that is 1 after dying in a level, reset to 0 if ghosts have left home
	    stz |pacman_dead
;20c5  329f4d    ld      (#4d9f),a	; clear eaten pills counter after pacman has died in a level
	    stz |pills_eaten_since_death
;20c8  c9        ret     		; return
	    rts
:alive
;20c9  21ba4d    ld      hl,#4dba	; load HL with address of orange ghost to go out of home pill limit
;20cc  3a114e    ld      a,(#4e11)	; load A with counter incremented if orange ghost is home alone and pacman is eating pills
	    lda |orange_home_counter
;20cf  be        cp      (hl)		; has the counter been exceeded ?
	    cmp |orange_home_limit	; $$JGA REVISIT, c=?
;20d0  d8        ret     c		; no, return
	    bcc :rts

;------------------------------------------------------------------------------

; releases orange ghost from the ghost house
; called from #141b
release_orange
;20d1  3e03      ld      a,#03		; A := #03
	    lda #3
;20d3  32a34d    ld      (#4da3),a	; store into orange ghost state
	    sta |orange_substate
;20d6  c9        ret     		; return
	    rts

;------------------------------------------------------------------------------
; checks for and sets the difficulty flags based on number of pellets eaten
; called from #1B40
;20d7
check_difficulty mx %00

;20d7  3aa34d    ld      a,(#4da3)	; load A with orange ghost state
	    lda |orange_substate
;20da  a7        and     a		; is the ghost living in the ghost house?
;20db  c8        ret     z		; yes, return
	    beq :rts

;20dc  210e4e    ld      hl,#4e0e	; load HL with number of pellets eaten address
;20df  3ab64d    ld      a,(#4db6)	; load A with first difficulty flag
	    lda |red_difficulty0
;20e2  a7        and     a		; has flag been set ?
;20e3  c2f420    jp      nz,#20f4	; yes, skip ahead
	    bne :skip_ahead

;20e6  3ef4      ld      a,#f4		; no, A := #F4
	    lda #$F4
;20e8  96        sub     (hl)		; subract number of pellets eaten
	    sec
	    sbc |dotseat
;20e9  47        ld      b,a		; load B with the result
	    sta <temp0
;20ea  3abb4d    ld      a,(#4dbb)	; load A with remainder of pills when first diff. flag is set
	    lda |pill_remain0
;20ed  90        sub     b		; subtract the result found above.  is it time to set the flag ?
	    sec
	    sbc <temp0
;20ee  d8        ret     c		; no, return
	    bcc :rts

;20ef  3e01      ld      a,#01		; A := #01
	    lda #1
;20f1  32b64d    ld      (#4db6),a	; set 1st difficulty flag so red ghost goes for pacman
	    sta |red_difficulty0
:skip_ahead
;20f4  3ab74d    ld      a,(#4db7)	; load A with 2nd difficulty flag
	    lda |red_difficulty1
;20f7  a7        and     a		; 2nd difficulty flag set yet ?
;20f8  c0        ret     nz		; no, return
	    bne :rts

;20f9  3ef4      ld      a,#f4		; else A := #F4
	    lda #$f4
;20fb  96        sub     (hl)		; subtract number of pellets eaten
	    sec
	    sbc |dotseat
;20fc  47        ld      b,a		; save result into B
	    sta <temp 0
;20fd  3abc4d    ld      a,(#4dbc)	; load A with remainder of pills when second diff. flag is set
	    lda |pill_remain1
;2100  90        sub     b		; subract result computed above.  is it time to set the 2nd difficulty flag?
	    sec
	    sbc <temp0
;2101  d8        ret     c		; no, return
	    bcc :rts

;2102  3e01      ld      a,#01		; yes, A := #01
	    lda #1
;2104  32b74d    ld      (#4db7),a	; set 2nd difficulty flag
	    sta |red_difficulty1
:rts
;2107  c9        ret     		; return
	    rts

;------------------------------------------------------------------------------
;212b
ttask7 mx %00
;212b  21064e    ld      hl,#4e06	; load HL with state in first cutscene
;212e  34        inc     (hl)		; increase
			inc |cs_state0
;212f  c9        ret     		; return
			rts

;------------------------------------------------------------------------------
;2192
cutscene_end mx %00
;2192  32064e    ld      (#4e06),a
			sta |cs_state0

;2195  f7        rst     #30		; set timed task to increase main subroutine number (#4E04)
;2196  45 00 00				; task timer = #45, task = 0, parameter = 0     
			lda #$0045
			ldy #0
			jsr rst30

;2199  21044e    ld      hl,#4e04
;219c  34        inc     (hl)		; increase main subroutine number
			inc |levelstate
;219d  c9        ret     		; return
			rts

;------------------------------------------------------------------------------
;21f0
ttask8 mx %00
;21f0  21074e    ld      hl,#4e07	; load HL with state in second cutscene
;21f3  34        inc     (hl)		; increase
			inc |cs_state1
;21f4  c9        ret     		; return
			rts


;------------------------------------------------------------------------------
;22b9
ttask9 mx %00
;22b9  21084e    ld      hl,#4e08	; load HL with state in third cutscene
;22bc  34        inc     (hl)		; increase
			inc |cs_state2
;22bd  c9        ret     		; return
			rts

;------------------------------------------------------------------------------
;230B
; This is called on "RESET"
startuptest mx %00

		; Clears 5000-5007

;230b  210050    ld      hl,#5000	; load HL with starting memory address
;230e  0608      ld      b,#08		; For B = 1 to 8
;2310  af        xor     a		; A := #00
;2311  77        ld      (hl),a		; clear memory
;2312  2c        inc     l		    ; next memory
;2313  10fc      djnz    #2311           ; next B

		; We don't have to do that.

		;lda #$FFFF
		;sta |IN0
		;sta |IN1

	;; Clear screen
	;; 40 -> 4000-43ff (Video RAM)
;2315

;2315  210040    ld      hl,#4000	; load HL with start of Video RAM
;2318  0604      ld      b,#04		; For B = 1 to 4

;231a  32c050    ld      (#50c0),a	; kick the dog
;231d  320750    ld      (#5007),a	; kick coin counter?
;2320  3e40      ld      a,#40		; A := #40 (clear character)

;2322  77        ld      (hl),a		; clear screen memory
;2323  2c        inc     l		; next address (low byte)
;2324  20fc      jr      nz,#2322        ; loop #FF times
;2326  24        inc     h		; next address (high byte)
;2327  10f1      djnz    #231a           ; Next B

		; tile_ram all pointing to tile $40, which is blank

		lda #$4040
		sta |tile_ram
		ldx #tile_ram		; Source
		ldy #tile_ram+2		; Dest
		lda #1024-3			; (Length-1)
		mvn ^tile_ram,^tile_ram

	;; 0f -> 4400 - 47ff (Color RAM)

;2329  0604      ld      b,#04		; For B = 1 to 4

;232b  32c050    ld      (#50c0),a	; kick the dog
;232e  af        xor     a		; A := #00
;232f  320750    ld      (#5007),a	; kick coin counter?
;2332  3e0f      ld      a,#0f		; A := #0F

;2334  77        ld      (hl),a		; set color
;2335  2c        inc     l		; next address (low byte)
;2336  20fc      jr      nz,#2334        ; loop #FF times
;2338  24        inc     h		; next high address
;2339  10f0      djnz    #232b           ; Next B

		; palette_ram all set to palette $0F

		lda #$0F0F
		sta |palette_ram
		ldx #palette_ram	; Source
		ldy #palette_ram+2	; Dest
		lda #1024-3 		; (Length-1)
		mvn ^palette_ram,^palette_ram

	;; test the interrupt hardware now
	; INTERRUPT MODE 1

;233b  ed56      im      1		; set interrupt mode 1
	
;233d  00        nop 		   	; no other setup is necessary..
;233e  00        nop     		; interrupts all go through 0x0038
;233f  00        nop     
;2340  00        nop
     
		; I guess hook into the jiffy timer here
		; insert jsr rst38 into the JiffyTimer function
		; which gets called a vblank
		; (this is only safe to do with interrupts disabled)
		lda #$20				; jsr
		sta |jsr38
		lda #rst38
		sta |jsr38+1

	; Pac's routine: (Puckman, Pac-Man Plus)
	; INTERRUPT MODE 2
	; 233b  ed5e      im      2		; interrupt mode 2
	; 233d  3efa      ld      a,#fa
	; 233f  d300      out     (#00),a	; interrupt vector -> 0xfa #3ffa vector to #3000
	; see also "INTERRUPT MODE 2" above...

		lda #$ffff
		sta |IN0
		sta |last_IN0
		sta |IN1
		sta |last_IN1



;2341  af        xor     a		; A := #00
;2342  320750    ld      (#5007),a	; clear coin counter
;2345  3c        inc     a		; A := #01    (a++)
;2346  320050    ld      (#5000),a	; Enable interrupts (pcb)
;2349  fb        ei			; Enable interrupts (cpu)
		cli
;234a  76        halt			; WAIT for interrupt then jump 0x0038 
		wai

	;; main program init
	;; perhaps a contiuation from 3295

;234b  32c050    ld      (#50c0),a	; kick dog
;234e  31c04f    ld      sp,#4fc0	; set stack pointer
		; no watch dog on this box

		; stack is probably good - but I'll set it again
		; just in-case there's a stack leak, and it gets fixed here
        lda #$FEFF      ; I really don't know much RAM the kernel is using in bank 0
        tcs

	;; reset custom registers.  Set them to 0

;2351  af        xor     a		; A := #00
;2352  210050    ld      hl,#5000	; load HL with starting address #5000
;2355  010808    ld      bc,#0808	; load counters with #08 and #08
;2358  cf        rst     #8		; clear #5000 through #5007

	;; clear ram

;2359  21004c    ld      hl,#4c00	; load HL with start of RAM
;235c  06be      ld      b,#be		; load counter with #BE
;235e  cf        rst     #8		; clear #4000 through #40BD
;235f  cf        rst     #8		; clear #40BE through #41BD
;2360  cf        rst     #8		; clear #41BE through #42BD
;2361  cf        rst     #8		; clear #42BE through #43BD

		stz |RAM_START
		ldx #RAM_START
		ldy #RAM_START+2
		lda #{RAM_END-RAM_START}-3
		mvn ^RAM_START,^RAM_START

		lda #1
		sta |no_coins_per_credit
		sta |no_credits_coin

	;; clear sound registers, color ram, screen, task list 

;2362  214050    ld      hl,#5040	; load HL with start of sound output
;2365  0640      ld      b,#40		; set counter at #40
;2367  cf        rst     #8		; clear #5040 through #5079

;2368  32c050    ld      (#50c0),a	; kick dog
;236b  cd0d24    call    #240d		; clear color ram
		jsr task_clearColor

;236e  32c050    ld      (#50c0),a	; kick dog
;2371  0600      ld      b,#00		; set parameter to clear entire screen
		lda #0
;2373  cded23    call    #23ed		; clear entire screen
		jsr task_clearScreen

;2376  32c050    ld      (#50c0),a	; kick dog
;2379  21c04c    ld      hl,#4cc0	; HL := #4CC0
		lda #foreground_tasks
;237c  22804c    ld      (#4c80),hl	; store into  pointer to the end of the tasks list
		sta |tasksTail
;237f  22824c    ld      (#4c82),hl	; store into  pointer to the beginning of the tasks list
		sta |tasksHead
;2382  3eff      ld      a,#ff		; set data to #FF
;2384  0640      ld      b,#40		; set counter to #40
;2386  cf        rst     #8		; store data into #4CC0 through #4CFF = clears task list
		lda #$FFFF
		sta |foreground_tasks
		ldx #foreground_tasks   ; source
		ldy #foreground_tasks+2 ; dest
		lda #64-3				; len - 1
		mvn ^foreground_tasks,^foreground_tasks

;2387  3e01      ld      a,#01		; A := #01
;2389  320050    ld      (#5000),a 	; enable software interrupts
;238C: FB	ei			; enable hardware interrupts

		;This should already be true

; process the task list, a core game loop

process_tasks mx %00

;238d  2a824c    ld      hl,(#4c82)	; load HL with the pointer to beginning of tasks list
			ldx |tasksHead
;2390  7e        ld      a,(hl)		; load A with the task value
;2391  a7        and     a		; examine value
			lda |0,x
			bit #$80
;2392  fa8d23    jp      m,#238d		; if sign negative (EG #FF), loop again; nothing to do
			bne process_tasks
			tay

;2395  36ff      ld      (hl),#ff	; else store #FF into task value
;2397  2c        inc     l		; next task parameter
;2398  46        ld      b,(hl)		; load B with task parameter
;2399  36ff      ld      (hl),#ff	; store #FF into task parameter value
;239b  2c        inc     l		; next task

; If I clear the task, after it's completed
; then I can debug tasks that don't complete
; looking at this code, it might be easier just
; to stuff the last dispatch some place for reference

			lda #$FFFF	; clear the task
			sta |0,x
			inx			; increment to next task
			inx
			cpx #foreground_tasks+64
;239c  2002      jr      nz,#23a0        ; If HL has not reached #4C00 then skip next step
			bcc :no_wrap
;239e  2ec0      ld      l,#c0		; else load L with #C0 to make HL #4CC0
			ldx #foreground_tasks		; wrap around task list
:no_wrap
;23a0  22824c    ld      (#4c82),hl	; store result into the task pointer
			stx |tasksHead

;23A3: 21 8D 23	ld	hl,#238D	; load HL with return address
;23A6: E5	push	hl		; push to stack
			pea #process_tasks-1   ; next rts will return to this loop

;23A7: E7	rst	#20		; jump based on A
			tya 	 
			and #$FF 	; mask task number

			sta <$FE  ; Debug

			asl
			tax
			tya
			xba
			and	 #$FF	; mask argument value
			jmp (|task_table,x)

;------------------------------------------------------------------------------
;
; All the pacman Task functions
;
		put tasks.s

;------------------------------------------------------------------------------
;; 	DrawText
;;
;;   Renders messages from a table with coordinates and message data
;;   B = message # from table
;;   B & 0x80 indicates to erase characters instead of draw them

;; other flags:
;;	top bit of address word & 0x80 -> draw in top or bottom two rows
;;	first color & 0x80 -> use this color for the entire string 

; format of the table data:
;   .byte (offs l), (offs h)	; so an offset of #0234 would be #34, #02
;	increase L by 0x01 to move it down by 1 row
;	increase L by 0x20 to move it left one column
;	set H|0x80 to indicate top or bottom two rows
;   .ascii "STRING"
;   .byte #2f			; termination with 2f
;   .byte colordata:
;	if the color data byte's high bit (#80) is set, the entire string
;	gets colored with (colordata & 0x7f) 
;		no termination, just the one entry.
;	if the color data byte's high bit is not set, then:
;	.byte 	ncolors		; number of bytes to set color
;	.byte	color1		; first character's color
;	.byte	color2		; second character's color
;		...		; etc
;	 (no termination - just as many entries as there were characters)
; Y as B
DrawText mx %00

msgNo   = temp0
pString = temp1
offset  = temp2
pVRAM   = temp3
pCOLOR  = temp4

			sty <msgNo

	; drawText( b )  ; b is index
;2c5e  21a536    ld      hl,#36a5	; load HL with the text string lookup table
;2c61  df        rst     #18		; (hl+2*b) -> hl
			tya
			and #$7F
			asl
			tax
			lda |string_table,x
			tax
			sta <pString

	; 1. get start offset into vid/color buffer
	; e = (hl++) ; d = (hl)		; load two bytes in as a pointer
	; indexOffset = de
;2c62  5e        ld      e,(hl)		; load E with value from table
;2c63  23        inc     hl		; next table entry
;2c64  56        ld      d,(hl)  	; DE contains start offset
			lda |0,x

	; 2. use offset for start of color, save to stack
	; ix = 0x4400 + indexOffset
;2c65  dd210044  ld      ix,#4400	; load IX with start of color RAM
;2c69  dd19      add     ix,de		; add offset to calculate start pos in CRAM
;2c6b  dde5      push    ix		; save to stack for use later (#2C93)

			;and #$7FFF			; We don't want any RAM mirroring
			and #$3FF
			clc
			adc #palette_ram
			sta <pCOLOR


	; 3. use offset for start of character ram
	; ix = characterRam + indexOffset
	; offsetPerCharacter = -1	; de
	; if (hl) & 0x80 then offsetPerCharacter = -0x20
;2c6d  1100fc    ld      de,#fc00	; load DE with offset for VRAM
;2c70  dd19      add     ix,de		; add to calculate start position in VRAM
			adc #$FC00
			sta <pVRAM

;2c72  11ffff    ld      de,#ffff	; load DE with offset for top & bottom lines (offset equals negative 1)
			lda #$FFFF
			sta <offset
;2c75  cb7e      bit     7,(hl)		; test bit 7 of HL.  Is this text for the top + bottom 2 lines ?
			lda (pString)
			bit #$8000


	; it should be noted that since the high bit on the offset address
	; is used to denote that the string goes into the top or bottom
	; two rows, it ends up relying on the unused ram mirroring.
	; that is to say that it actually ends up drawing up around C000
	; instead of 4000.  A patch is below as HACK12

	; (this skips the offsetPerCharacter with -20 if necessary)
;2c77  2003      jr      nz,#2c7c        ; yes, skip next step
			bne BlankTextDrawCheck
;2c79  11e0ff    ld      de,#ffe0	; no, load DE with offset for normal text (equals negative #20)

			lda #$FFE0
			sta <offset
	; 4. determine special entry, go to 2cac for that
	; hl++
	; a = stringToDraw * 2
	; if( carry) goto BlankTextDraw	;AKA  if( stringToDraw# & 0x80) then goto BlankTextDraw
BlankTextDrawCheck
;2c7c  23        inc     hl		; next table entry
;2c7d  78        ld      a,b		; A := B.  B was preloaded with the code # of the text to display
;2c7e  010000    ld      bc,#0000	; clear BC
;2c81  87        add     a,a		; A : = A * 2.  Is this a special entry ?
			tya
			bit #$0080
;2c82  3828      jr      c,#2cac         ; special draw for entries 80+
			bne BlankTextDraw

textRenderLoop0
	; ch = current character  	; 'a' = (hl)
	; if ch == 0x2f, goto SingleOrMultiColorCheck:
	; *characterVram = ch		; ram[ix+0] = 'a'
	; characterVram += de		; (+= but it really subtracts 1 or 0x20, contents of 'de')
	; nchars ++  			; 'b'++
	; goto textRenderLoop0
			ldy #0
;2c84  7e        ld      a,(hl)		; load A with next character
]loop
			sep #$20
			lda |2,x
;2c85  fe2f      cp      #2f		; == #2F ? (end of text code)
			cmp #$2F
;2c87  2809      jr      z,#2c92         ; yes, done with VRAM, skip ahead to color
			beq SingleOrMultiColorCheck

;2c89  dd7700    ld      (ix+#00),a	; write character to screen
			sta (pVRAM)
;2c8c  23        inc     hl		; next character
			inx
;2c8d  dd19      add     ix,de		; calculate next VRAM pos
			rep #$21
			lda <pVRAM
			adc <offset
			sta <pVRAM

;2c8f  04        inc     b		; increment counter
			iny
;2c90  18f2      jr      #2c84           ; loop
			bra ]loop

SingleOrMultiColorCheck mx %10
	; ix = startColorRamPos
;2c92  23        inc     hl		; next table entry
;2c93  dde1      pop     ix		; get CRAM start pos

	; pCOLOR = startColorRamPos

	; color = *colorToUse
	; if (color) is > 80, goto TextSingleColorRender
;2c95  7e        ld      a,(hl)		; load A with color
			lda |3,x
;2c96  a7        and     a		; > #80 ?
;2c97  faa42c    jp      m,#2ca4		; yes, skip ahead
			bmi TextSingleColorRender

TextMultiColorRender mx %10
	; color = *colorToUse
	; colorRam[ix] = color;
	; colorToUse++
	; move ix to the next screen position ( -=1 or -=0x20)
	; b--; if b>0 then goto TextMultiColorRender
	; return
]loop
;2c9a  7e        ld      a,(hl)		; else load A with color
			lda |3,x
;2c9b  dd7700    ld      (ix+#00),a	; color the screen position Color RAM
			sta (pCOLOR)
;2c9e  23        inc     hl		; next color
			inx
			rep #$21
;2c9f  dd19      add     ix,de		; calc next CRAM pos
			lda <pCOLOR
			adc <offset
			sta <pCOLOR
			sep #$20
;2ca1  10f7      djnz    #2c9a           ; loop until b==0
			dey
			bne ]loop
;2ca3  c9        ret     		; return
			rep #$31
			rts

	;; same as above, but all the same color
TextSingleColorRender mx %10
	; colorRam[ix] = color
	; move ix to the next screen position( -=1 or -=0x20)
	; b--; if b>0 then goto TextSingleColorRender
	; return
			tax
]loop
;2ca4  dd7700    ld      (ix+#00),a	; drop in CRAM
			txa
			sta (pCOLOR)
;2ca7  dd19      add     ix,de		; calc next CRAM pos
			rep #$21
			lda <pCOLOR
			adc <offset
			sta <pCOLOR
;2ca9  10f9      djnz    #2ca4           ; loop until b==0
			sep #$20
			dey
			bne ]loop
;2cab  c9        ret
			rep #$31
			rts	 

	;; message # > 80 se 2nd color code
BlankTextDraw mx %00
	; character = *characterToDraw
	; if( color = 0x2f ) goto FinishUpBlankTextDraw
	; characterRam[ix] = 0x40 ("@", which is ' ' in Pac-Man)
	; characterToDraw++
	; b++
			ldy #2
]loop
;2cac  7e        ld      a,(hl)		; read next char
			sep #$20
			lda |2,x
;2cad  fe2f      cp      #2f		; are we done ?
			cmp #$2F
;2caf  280a      jr      z,#2cbb         ; yes, done with vram
			beq FinishUpBlankTextDraw

;2cb1  dd360040  ld      (ix+#00),#40	; clears the character
			lda #$40
			sta (pVRAM)
;2cb5  23        inc     hl		; next char
			inx
			rep #$21
;2cb6  dd19      add     ix,de		; next screen pos
			lda <pVRAM
			adc <offset
			sta <pVRAM
			sep #$20
;2cb8  04        inc     b		; inc char count
			iny
;2cb9  18f1      jr      #2cac           ; loop
			bra ]loop

FinishUpBlankTextDraw mx %10
	; while (*hl != 0x2f) hl++
	; goto SingleOrMultiColorCheck +1
;2cbb  23        inc     hl		; next char
;2cbc  04        inc     b		; inc char count
;2cbd  edb1      cpir    		; loop until [hl] = 2f
;2cbf  18d2      jr      #2c93           ; do CRAM
			bra SingleOrMultiColorCheck

	;; HACK12 - fixes the C000 top/bottom draw mirror issue
	; 2c62  c300d0	jp	hack12

	; hack12:   ;;; up at 0xd000 for this example
	; d000  5e        ld	e, (hl)		; patch (2c62)
	; d001  23        inc	hl		; patch (2c63)
	; d002  7e        ld	a, (hl)		; patch (2c64 almost)
	; d003  e67f      and	#0x7f		; mask off the top/bottom flag
	; d005  57        ld	d, a		; d cleared of that bit now (C000-safe!)
	; d006  7e        ld	a, (hl)		; set aside A for part 2, below
	; d007  c3652c    jp	#2c65		; resume


        ;;
        ;; PROCESS WAVE (all voices) (SOUND)
        ;; called from #01BC
	;;

;#if MSPACMAN
;2cc1  jp      #9797       		; sprite/cocktail stuff. we don't care for sound.
                          		; The routine ends with "ld hl,#9685", "jp #2cc4"
                          		; so this is a Ms Pacman patch
;#else
;2cc1  ld      hl,#SONG_TABLE_1
;#endif

;------------------------------------------------------------------------------
;2cc4
process_waves mx %00
        ;; channel 1 song
;2cc1  ld      hl,#SONG_TABLE_1
;2cc4  ld      ix,#CH1_W_NUM             ; ix = Pointer to Song number
;2cc8  ld      iy,#CH1_FREQ0             ; iy = Pointer to Freq/Vol parameters
;2ccc  call    #2d44                     ; call process_wave
	lda #SONG_TABLE_1
	ldx #CH1_W_NUM
	ldy #CH1_FREQ0
	jsr process_wave
;2ccf  ld      b,a                       ; A is the returned volume (save it in B)
	tax
;2cd0  ld      a,(#CH1_W_NUM)            ; if we are playing a song
;2cd3  and     a
;2cd4  jr      z,#2cda
	lda |CH1_W_NUM
	and #$FF
	beq :nextch0
;2cd6  ld      a,b                       ; then
;2cd7  ld      (#CH1_VOL),a              ; save volume
	sep #$10
	stx |CH1_VOL
	rep #$30

        ;; channel 2 song

:nextch0
;2cda  ld      hl,#SONG_TABLE_2
;2cdd  ld      ix,#CH2_W_NUM
;2ce1  ld      iy,#CH2_FREQ1
;2ce5  call    #2d44
	lda #SONG_TABLE_2
	ldx #CH2_W_NUM
	ldy #CH2_FREQ1
	jsr process_wave

;2ce8  ld      b,a
	tax

;2ce9  ld      a,(#CH2_W_NUM)
;2cec  and     a
;2ced  jr      z,#2cf3
	lda |CH2_W_NUM
	and #$FF
	bne :nextch1
;2cef  ld      a,b
;2cf0  ld      (#CH2_VOL),a
	sep #$10
	stx |CH2_VOL
	rep #$30

        ;; channel 3 song
:nextch1
;2cf3  ld      hl,#SONG_TABLE_3
;2cf6  ld      ix,#CH3_W_NUM
;2cfa  ld      iy,#CH3_FREQ1
;2cfe  call    #2d44
	lda #SONG_TABLE_3
	ldx #CH3_W_NUM
	ldy #CH2_FREQ1
	jsr process_wave

;2d01  ld      b,a
	tax

;2d02  ld      a,(#CH3_W_NUM)
;2d05  and     a
	lda |CH3_W_NUM
	and #$FF
;2d06  ret     z
	beq :rts
;2d07  ld      a,b
;2d08  ld      (#CH3_VOL),a
	sep #$10
	stx |CH3_VOL
	rep #$30
:rts
;2d0b  ret
	    rts

;------------------------------------------------------------------------------
;;
;; PROCESS EFFECT (all voices)
;2d0c
process_effects mx %00
;2d0c  ld      hl,#EFFECT_TABLE_1        ; pointer to sound table
;2d0f  ld      ix,#CH1_E_NUM             ; effect number (voice 1)
;2d13  ld      iy,#CH1_FREQ0
;2d17  call    #2dee                     ; call process effect, returns volume in A
	    lda #EFFECT_TABLE_1
	    ldx #CH1_E_NUM
	    ldy #CH1_FREQ0
	    jsr process_effect
;2d1a  ld      (#CH1_VOL),a              ; store volume
	    sep #$20
	    sta |CH1_VOL
	    rep #$30

;2d1d  ld      hl,#EFFECT_TABLE_2        ; same for voice 2
;2d20  ld      ix,#CH2_E_NUM
;2d24  ld      iy,#CH2_FREQ1
;2d28  call    #2dee
	    lda #EFFECT_TABLE_2
	    ldx #CH2_E_NUM
	    ldy #CH2_FREQ1
	    jsr process_effect
;2d2b  ld      (#CH2_VOL),a
	    sep #$20
	    sta |CH2_VOL
	    rep #$30

;2d2e  ld      hl,#EFFECT_TABLE_3        ; same for voice 3
;2d31  ld      ix,#CH3_E_NUM
;2d35  ld      iy,#CH3_FREQ1
;2d39  call    #2dee
	    lda #EFFECT_TABLE_3
	    ldx #CH3_E_NUM
	    ldy #CH3_FREQ1
	    jsr process_effect
;2d3c  ld      (#CH3_VOL),a
	    sep #$20
	    sta |CH3_VOL
;2d3f  xor     a                         ; A = 0
;2d40  ld      (#CH1_FREQ4),a            ; freq 4 channel 1 = 0
	    stz |CH1_FREQ4
	    rep #$30
;2d43  ret
	    rts

;------------------------------------------------------------------------------
;
; Process wave (one voice)
;
; In:  A = pSongTable
;      X = CH?_W_NUM
;      Y = CH?_FREQ0
;
; Return A = Volume
;
;2d44
process_wave mx %00
:w_num     = temp0
:bit_count = temp0+2
:bit_mask  = temp1
:freq      = temp1+2
:b         = temp2
:c         = temp2+2

;2d44  ld      a,(ix+#00)        ; if (W_NUM == 0)
;2d47  and     a
;2d48  jp      z,#2df4           ; then goto init_param
	lda |0,x		; W_NUM
	and #$FF
	beql init_param

;2d4b  ld      c,a               ; c = W_NUM
	sta <:w_num

;2d4c  ld      b,#08             ; b = 0x08
;2d4e  ld      e,#80             ; e = 0x80
	lda #$08
	sta <:bit_count
	lda #$80
	sta <:bit_mask

]loop
;2d50  ld      a,e               ; find which bit is set in W_NUM
	lda <:bit_mask
;2d51  and     c
	and <:w_num
;2d52  jr      nz,#2d59          ; found one, goto process wave bis
	bne :process_wave
;2d54  srl     e
	lsr <:bit_mask
;2d56  djnz    #2d50
	dec <:bit_count
	bne ]loop
;2d58  ret                       ; return
	rts

;
; Process wave bis : process one wave, represented by 1 bit (in E)
;
:process_wave
	sty <:freq

;2d59  ld      a,(ix+#02)        ; A = CUR_BIT
;2d5c  and     e
;2d5d  jr      nz,#2d66          ; if (CUR_BIT & E != 0) then goto #2d66
	lda |$02,x
	and <:bit_mask
	bne :cur_bit_set

;2d5f  ld      (ix+#02),e        ; else save E in CUR_BIT
	sep #$20
	lda <:bit_mask
	sta |$02,x
	rep #$30
;2d62  jp      #364e             ; jump to new ms. pac man routine.  returns to #2D72
	jsr select_song
;2d65  inc     c                 ; junk from pac-man
	bra :process

:cur_bit_set
;2d66  dec     (ix+#0c)          ; decrement W_DURATION
;2d69  jp      nz,#2dd7          ; if W_DURATION == 0
	sep #$20
	dec |$0C,x
	rep #$30
	bnel :do_freq
:loop
;2d6c  ld      l,(ix+#06)        ; then HL = pointer store in W_OFFSET
;2d6f  ld      h,(ix+#07)

	ldy |$06,x

        ;; process byte
:process
;2d72  ld      a,(hl)            ; A = (HL)
;2d73  inc     hl
	lda |0,y
	iny
;2d74  ld      (ix+#06),l        ; W_OFFSET = ++HL
;2d77  ld      (ix+#07),h
	tya
	sta |$06,x

;2d7a  cp      #f0               ; if (A < #F0)
;2d7c  jr      c,#2da5           ; then process A  (regular byte)
	and #$FF
	cmp #$F0
	bcc :regular

;2d7e  ld      hl,#2d6c          ; else process special byte using a jump table.  load HL with return address
;2d81  push    hl                ; push return address to stack
	pea :loop-1

;2d82  and     #0f               ; mask bits; takes lowest nibble of special byte
;2d84  rst     #20               ; and jump based on A (return in HL = 2d6c)
	and #$0f
	asl
	tax
	txy
	jmp (|:table,x)

        ;; jump table
:table
	da audioF0 ; #2F55 ; byte is F0
	da audioF1 ; #2F65 ; byte is F1
	da audioF2 ; #2F77 ; byte is F2
	da audioF3 ; #2F89 ; byte is F3
	da audioF4 ; #2F9B ; byte is F4
	da :rts    ; #000C ; returns immediately ; byte is F5
	da :rts    ; #000C ; returns immediately ; byte is F6
	da :rts    ; #000C ; returns immediately ; byte is F7
	da :rts    ; #000C ; returns immediately ; byte is F8
	da :rts    ; #000C ; returns immediately ; byte is F9
	da :rts    ; #000C ; returns immediately ; byte is FA
	da :rts    ; #000C ; returns immediately ; byte is FB
	da :rts    ; #000C ; returns immediately ; byte is FC
	da :rts    ; #000C ; returns immediately ; byte is FD
	da :rts    ; #000C ; returns immediately ; byte is FE
	da audioFF ; #2FAD ; byte is FF

:rts
	rts
;
; process regular byte (A=byte to process, it's not a special byte)
;
:regular
;2da5  ld      b,a               ; copy A into B
	sta <:b
;2da6  and     #1f
;2da8  jr      z,#2dad           ; if (A & 0x1f == 0)
	and #$1F
	beq :n
;2daa  ld      (ix+#0d),b        ; then W_DIR = B
	sep #$20
	lda <:b
	sta |$0D,x
	rep #$30
:n
	sep #$20
;2dad  ld      c,(ix+#09)        ; C = W_9
	lda |$09,x
	sta <:c
;2db0  ld      a,(ix+#0b)
	lda |$0B,x
;2db3  and     #08
	and #$08
;2db5  jr      z,#2db9           ; if (W_8 & 0x8 == 0)
	beq :n2
;2db7  ld      c,#00             ; then VOL = 0
	stz <:c
:n2
;2db9  ld      (ix+#0f),c        ; else VOL = W_9
	lda <:c
	sta |$0F,x
	rep #$30
;2dbc  ld      a,b               ; restore A
;2dbd  rlca
;2dbe  rlca
;2dbf  rlca
	lda <:b
	lsr
	lsr
	lsr
	lsr
	lsr
;2dc0  and     #07               ; A = (A & 0xE0) >> 5
	and #$07
;2dc2  ld      hl,#3bb0
;2dc5  rst     #10               ; A = ROM[0x3bb0 + A]
                                ; Note: this is just A = 2**A
	tay
	sep #$20
	lda |pow_table,y
;2dc6  ld      (ix+#0c),a        ; W_DURATION = A
	sta |$0C,x
	rep #$30
;2dc9  ld      a,b               ; restore A
;2dca  and     #1f
	lda <:b
	and #$1F
;2dcc  jr      z,#2dd7           ; if (A & 0x1f == 0) then goto compute_wave_freq
	beq :do_freq
;2dce  and     #0f               ; A = A & 0x0F
;2dd0  ld      hl,#3bb8          ; lookup table, contains a table a frequencies
;2dd3  rst     #10
;2dd4  ld      (ix+#0e),a        ; W_BASE_FREQ = ROM[3bb8 + A]
	sep #$20
	and #$0f
	tay
	lda |freq_table,y
	sta |$0E,x
	rep #$30

        ;; compute wave frequency
:do_freq
;2dd7  ld      l,(ix+#0e)
;2dda  ld      h,#00             ; HL = W_BASE_FREQ (on 16 bits)
	lda |$0E,x
	and #$FF
	tay

;2ddc  ld      a,(ix+#0d)        ; A = W_DIR
	lda |$0D,x
;2ddf  and     #10
	and #$10
;2de1  jr      z,#2de5           ; if (W_DIR & 0x10 != 0) then
	beq :dir0
;2de3  ld      a,#01             ;       A = 1
	lda #$01
:dir0
;2de5  add     a,(ix+#04)        ; A += W_4
	sep #$20
	clc
	adc |$04,x
	rep #$30
;2de8  jp      z,#2ee8           ; compute new frequency  FREQ = BASE_FREQ * (1 << A)
	beql new_freq2
;2deb  jp      #2ee4
	sta <:b
	jmp new_freq

;------------------------------------------------------------------------------
;
; Process effect (one voice)
;
; A = pEffectTable
; X = pCH?_E_NUM
; Y = pCH?_FREQ

; return: A = volume
;
;2dee
process_effect mx %00

:effect_table = temp3

	sta <:effect_table

process_effect2
;2dee    ld      a,(ix+#00)      ; if (E_NUM != 0)
;2df1    and     a               ;
	lda |0,x  ; E_NUM
	and #$FF

;2df2    jr      nz,#2e1b        ; then goto find effect
	bne find_effect

;
; Init Param
;
init_param mx %00

:freq      = temp1+2 ;$$MATCH process_wave

;2df4    ld      a,(ix+#02)      ; if (CUR_BIT == 0)
;2df7    and     a
	lda |2,x  ; CUR_BIT
	and #$FF
;2df8    ret     z               ; then return
	beq :rts

	sep #$20
	sty <:freq

;2df9    ld      (ix+#02),#00    ; CUR_BIT = 0
;2dfd    ld      (ix+#0d),#00    ; DIR = 0
;2e01    ld      (ix+#0e),#00    ; BASE_FREQ = 0
;2e05    ld      (ix+#0f),#00    ; VOL = 0
	stz |$2,x ; CUR_BIT
	stz |$D,x ; DIR
	rep #$30
	stz |$E,x ; BASE_FREQ+VOL
;	stz |$F,x ; VOL
	ldx <:freq
	stz |0,x
	stz |2,x
;2e09    ld      (iy+#00),#00    ; FREQ0 or 1   (5 freq for channel 1)
;2e0d    ld      (iy+#01),#00    ; FREQ1 or 2
;2e11    ld      (iy+#02),#00    ; FREQ2 or 3
;2e15    ld      (iy+#03),#00    ; FREQ3 or 4

;2e19    xor     a               ;
	lda #0
;2e1a    ret                     ; return 0
:rts	rts

;;
;; find effect. Effect num is not zero, find which bits are set
;;
find_effect mx %00
:enum      = temp0	; $$MATCH process_wave
:bit_count = temp0+2
:cur_bit   = temp1
:freq      = temp1+2
:b         = temp2
:c         = temp2+2
:effect_table = temp3

	sty <:freq
;2e1b  ld      c,a               ; c = E_NUM
	sta <:enum

;2e1c  ld      b,#08             ; b = 0x08
	lda #8
	sta <:bit_count

;2e1e  ld      e,#80             ; e = 0x80
	lda #$80
	sta <:cur_bit
]loop
;2e20  ld      a,e               ; find which bit is set in E_NUM
	lda <:cur_bit
;2e21  and     c
	and <:enum

;2e22  jr      nz,#2e29          ; found one, goto proces effect bis
	bne :found_one

;2e24  srl     e
	lsr <:cur_bit
;2e26  djnz    #2e20
	dec <:bit_count
	bne ]loop
;2e28  ret
	rts
;;
;; Process effect bis : process one effect, represented by 1 bit (in E)
;;
:found_one
;2e29  ld      a,(ix+#02)        ; A = CUR_BIT
;2e2c  and     e
	lda |$02,x
	and <:cur_bit
;2e2d  jr      nz,#2e6e          ; if (CUR_BIT & E != 0) then goto 2e6e
	bne :compute_effect
;2e2f  ld      (ix+#02),e        ; else save E in CUR_BIT
	sep #$20
	lda <:cur_bit
	sta |$02,x
	rep #$30
                                ; locate the 8 bytes for this effect in the rom tables
;2e32  dec     b                 ; the address is at HL + (B-1) * 8
;2e33  ld      a,b
	lda <:bit_count
	dec
	sta <:bit_count

;2e34  rlca
;2e35  rlca
;2e36  rlca
	asl
	asl
	asl
	adc <:effect_table
	tay

;2e37  ld      c,a               ; C = (B-1)*8
;2e38  ld      b,#00             ; B = 0
;2e3a  push    hl                ; save HL (pointer to EFFECT_TABLE)
;2e3b  add     hl,bc             ; HL = HL + (B-1)*8
;2e3c  push    ix
;2e3e  pop     de                ; DE = E_NUM
;2e3f  inc     de
;2e40  inc     de
;2e41  inc     de                ; DE = E_TABLE0
;2e42  ld      bc,#0008
;2e45  ldir                      ; copy 8 bytes from rom
;2e47  pop     hl                ; restore HL (pointer to EFFECT_TABLE)
	lda |0,y
	sta |3,x
	lda |2,y
	sta |5,x
	lda |4,y
	sta |7,x
	lda |6,y
	sta |9,x


	sep #$20
;2e48  ld      a,(ix+#06)
;2e4b  and     #7f
;2e4d  ld      (ix+#0c),a        ; E_DURATION = E_TABLE3 & 0x7F
	lda |$06,x
	and #$7F
	sta |$0C,x

;2e50  ld      a,(ix+#04)
;2e53  ld      (ix+#0e),a        ; E_BASE_FREQ = E_TABLE1
	lda |$04,x
	sta |$0E,x

;2e56  ld      a,(ix+#09)
;2e59  ld      b,a               ; B = E_TABLE6
	lda |$09,x
	sta <:b
;2e5a  rrca
;2e5b  rrca
;2e5c  rrca
;2e5d  rrca
;2e5e  and     #0f
	lsr
	lsr
	lsr
	lsr
;2e60  ld      (ix+#0b),a        ; E_TYPE = (E_TABLE6 >> 4) & 0xF
	sta |$0B,x
;2e63  and     #08
;2e65  jr      nz,#2e6e          ; if (E_TYPE & 0x8 == 0) then
	and #$08
	bne :compute_effect
;2e67  ld      (ix+#0f),b        ;       E_VOL = E_TABLE6
	lda <:b
	sta |$0f,x
;2e6a  ld      (ix+#0d),#00      ;       E_DIR = 0
	stz |$0d,x
        ;; compute effect
:compute_effect
	sep #$20
;2e6e  dec     (ix+#0c)          ; E_DURATION--
;2e71  jr      nz,#2ecd          ; if (E_DURATION == 0) then
	dec |$0C,x
	bne :update_freq
;2e73  ld      a,(ix+#08)
;2e76  and     a
;2e77  jr      z,#2e89           ;       if (E_TABLE5 != 0) then
	lda |$08,x
	beq :t5zero
;2e79  dec     (ix+#08)          ;               E_TABLE5--
;2e7c  jr      nz,#2e89          ;               if (E_TABLE5 == 0) then
	dec |$08,x
	bne :t5zero
;2e7e  ld      a,e
;2e7f  cpl
;2e80  and     (ix+#00)
;2e83  ld      (ix+#00),a        ;                       E_NUM &= ~E_CUR_BIT
	lda <:cur_bit
	eor #$FF
	and |$00,x
	sta |$00,x
;2e86  jp      #2dee             ;                       goto process effect (one voice)
	rep #$30
	jmp process_effect2
:t5zero mx %10
;2e89  ld      a,(ix+#06)
;2e8c  and     #7f
;2e8e  ld      (ix+#0c),a        ;       E_DURATION = E_TABLE3 & 0x7F
	lda |$06,x
	and #$7F
	sta |$0C,x

;2e91  bit     7,(ix+#06)
;2e95  jr      z,#2ead           ;       if (E_TABLE3 & 0x80 != 0) then
	lda |$06,x
	bpl :t3pos
;2e97  ld      a,(ix+#05)
;2e9a  neg
;2e9c  ld      (ix+#05),a        ;               E_TABLE2 = - E_TABLE2
	lda |$05,x
	eor #$FF
	inc
	sta |$05,x
;2e9f  bit     0,(ix+#0d)        ;               if (E_DIR & 0x1 == 0) then
;2ea3  set     0,(ix+#0d)        ;                       E_DIR |= 0x1
;2ea7  jr      z,#2ecd           ;                       goto update_freq
;2ea9  res     0,(ix+#0d)        ;               E_DIR &= ~0x1
	lda |$0d,x
	eor #1
	sta |$0d,x
:t3pos
;2ead  ld      a,(ix+#04)
;2eb0  add     a,(ix+#07)
;2eb3  ld      (ix+#04),a        ;       E_TABLE1 += E_TABLE4
;2eb6  ld      (ix+#0e),a        ;       E_BASE_FREQ = E_TABLE1

	lda |$04,x
	clc
	adc |$07,x
	sta |$04,x
	sta |$0e,x

;2eb9  ld      a,(ix+#09)
;2ebc  add     a,(ix+#0a)
;2ebf  ld      (ix+#09),a        ;       E_TABLE6 += E_TABLE7
	lda |$09,x
	clc
	adc |$0A,x
	sta |$09,x

;2ec2  ld      b,a
	sta <:b

;2ec3  ld      a,(ix+#0b)
;2ec6  and     #08
;2ec8  jr      nz,#2ecd          ;       if (E_TYPE & 0x8 == 0) then
	lda |$0B,x
	and #$08
	bne :update_freq
;2eca  ld      (ix+#0f),b        ;               E_VOL = E_TABLE6
	lda <:b
	sta |$0f,x

; update freq
:update_freq
;2ecd  ld      a,(ix+#0e)
;2ed0  add     a,(ix+#05)
;2ed3  ld      (ix+#0e),a        ; E_BASE_FREQ += E_TABLE2
	lda |$0E,x
	clc
	adc |$05,x
	sta |$0E,x

	rep #$30
;2ed6  ld      l,a
;2ed7  ld      h,#00             ; HL = E_BASE_FREQ (on 16 bits)
	and #$FF

	tay

;2ed9  ld      a,(ix+#03)        ; compute new frequency
;2edc  and     #70               ; FREQ = E_BASE_FREQ * ((1 << E_TABLE0 & 0x70) >> 4)
;2ede  jr      z,#2ee8
	lda |$03,x
	and #$70
	beq new_freq2

;2ee0  rrca
;2ee1  rrca
;2ee2  rrca
;2ee3  rrca

	lsr
	lsr
	lsr
	lsr
	sta <:b
	tya

        ;; compute new frequency
new_freq
:b         = temp2
:c         = temp2+2

;2ee4  ld      b,a               ; B = counter
;2ee5  add     hl,hl             ; HL = 2 * HL
	asl
;2ee6  djnz    #2ee5
	dec <:b
	bne new_freq
                                ; HL = HL * 2**B
                                ; now extract the nibbles from HL
new_freq2
:freq      = temp1+2

	ldy <:freq
	sep #$20
;2ee8  ld      (iy+#00),l        ; 1st nibble
;2eeb  ld      a,l
;2eec  rrca
;2eed  rrca
;2eee  rrca
;2eef  rrca
;2ef0  ld      (iy+#01),a        ; 2nd nibble
;2ef3  ld      (iy+#02),h        ; 3rd nibble
;2ef6  ld      a,h
;2ef7  rrca
;2ef8  rrca
;2ef9  rrca
;2efa  rrca
;2efb  ld      (iy+#03),a        ; 4th nibble

	sta |0,y
	lsr
	lsr
	lsr
	lsr
	sta |1,y
	xba
	sta |2,y
	lsr
	lsr
	lsr
	lsr
	sta |3,y
	rep #$30

	txy

;2efe  ld      a,(ix+#0b)        ; A = W_TYPE
;2f01  rst     #20               ; jump table to volume adjust routine

	lda |$0b,x
	and #$0F
	asl
	tax
	jmp (:table,x)

        ; jump table to adjust volume
:table
	da :type0 ; #2F22
	da :type1 ; #2F26
	da :type2 ; #2F2B
	da :type3 ; #2F3C
	da :type4 ; #2F43
	da :type5 ; #2F4A
	da :type6 ; #2F4B
	da :type7 ; #2F4C
	da :type8 ; #2F4D
	da :type9 ; #2F4E
	da :typeA ; #2F4F
	da :typeB ; #2F50
	da :typeC ; #2F51
	da :typeD ; #2F52
	da :typeE ; #2F53
	da :typeF ; #2F54

;; type 0
:type0 
;2f22  ld      a,(ix+#0f)        ; constant volume
	tyx
	lda |$0f,x
	and #$FF
;2f25  ret
	rts

;; type 1
:type1
;2f26  ld      a,(ix+#0f)        ; decreasing volume
;2f29  jr      #2f34
	tyx
	lda |$0f,x
	bra :dec_vol
;; type 2
:type2
	tyx
;2f2b  ld      a,(#4c84)         ; decreasing volume (1/2 rate)
;2f2e  and     #01
	lda |SOUND_COUNTER
	and #$01
	tay
:dec_vol2
;2f30  ld      a,(ix+#0f)        ; (skip decrease if sound_counter (4c84) is odd)
	lda |$0F,x
	and #$0F
	cpy #0
;2f33  ret     nz
	beq :dec_vol
:rts
	rts
:dec_vol
;2f34  and     #0f               ; decrease routine
	and #$0f
;2f36  ret     z
	beq :rts
;2f37  dec     a
;2f38  ld      (ix+#0f),a
	dec
	sep #$20
	sta |$0F,x
	rep #$30
;2f3b  ret
	rts

;; type 3
:type3
	tyx
;2f3c  ld      a,(#4c84)         ; decreasing volume (1/4 rate)
;2f3f  and     #03
;2f41  jr      #2f30
	lda |SOUND_COUNTER
	and #$03
	tay
	bra :dec_vol2

        ;; type 4
:type4
	tyx
;2f43  ld      a,(#4c84)         ; decreasing volume (1/8 rate)
;2f46  and     #07
;2f48  jr      #2f30
	lda |SOUND_COUNTER
	and #$07
	tay
	bra :dec_vol2

        ;; type 5-15
:type5
:type6
:type7
:type8
:type9
:typeA
:typeB
:typeC
:typeD
:typeE
:typeF
	tyx
	lda #0
	rts
;2f4a  c9        ret     
;2f4b  c9        ret     
;2f4c  c9        ret     
;2f4d  c9        ret     
;2f4e  c9        ret     
;2f4f  c9        ret     
;2f50  c9        ret     
;2f51  c9        ret     
;2f52  c9        ret     
;2f53  c9        ret     
;2f54  c9        ret     

;------------------------------------------------------------------------------
;
; Special byte F0 : this is followed by 2 bytes, the new offset (to allow loops)
;
audioF0 mx %00
	tyx
;2f55  ld      l,(ix+#06)
;2f58  ld      h,(ix+#07)        ; HL = (W_OFFSET)
	ldy |$06,x
;2f5b  ld      a,(hl)
	lda |0,y
;2f5c  ld      (ix+#06),a
;2f5f  inc     hl
;2f60  ld      a,(hl)
;2f61  ld      (ix+#07),a        ; HL = (HL)
	sta |$06,x
;2f64  ret
	rts

;------------------------------------------------------------------------------
;
; Special byte F1 : followed by one byte (wave select)
;
audioF1 mx %00
	tyx
;2f65  ld      l,(ix+#06)
;2f68  ld      h,(ix+#07)
	ldy |$06,x
;2f6b  ld      a,(hl)            ; A = (++HL)
	lda |0,y
;;2f6c  inc     hl
	iny
;2f73  ld      (ix+#03),a        ; save A in W_WAVE_SEL
	sep #$20
	sta |$03,x
	rep #$30

;2f6d  ld      (ix+#06),l
;2f70  ld      (ix+#07),h
	tya
	sta |$06,x
;2f76  ret
	rts

;------------------------------------------------------------------------------
;
; Special byte F2 : followed by one byte (Frequency increment)
;
audioF2 mx %00
	tyx
;2f77  ld      l,(ix+#06)
;2f7a  ld      h,(ix+#07)
	ldy |$06,x
;2f7d  ld      a,(hl)            ; A = (++HL)
	lda |$0,y
;2f7e  inc     hl
	iny
;2f85  ld      (ix+#04),a        ; save A in W_A
	sep #$20
	sta |$04,x
	rep #$30
;2f7f  ld      (ix+#06),l
;2f82  ld      (ix+#07),h
	tya
	sta |$06,x
;2f88  ret
	rts

;------------------------------------------------------------------------------
;
; Special byte F3 : followed by one byte (Volume)
;
audioF3 mx %00
	tyx
;2f89  ld      l,(ix+#06)
;2f8c  ld      h,(ix+#07)
	ldy |$06,x
;2f8f  ld      a,(hl)            ; A = (++HL)
	lda |0,y
;2f90  inc     hl
	iny
;2f97  ld      (ix+#09),a        ; save A in W_VOL
	sep #$20
	sta |$09,x
	rep #$30
;2f91  ld      (ix+#06),l
;2f94  ld      (ix+#07),h
	tya
	sta |$06,x
;2f9a  ret
	rts

;------------------------------------------------------------------------------
;
; Special byte F4 : followed by one byte (Type)
;
audioF4 mx %00
	tyx
;2f9b  ld      l,(ix+#06)
;2f9e  ld      h,(ix+#07)
	ldy |$06,x
;2fa1  ld      a,(hl)            ; A = (++HL)
	lda |$0,y
;2fa2  inc     hl
	iny
;2fa9  ld      (ix+#0b),a        ; save A in W_TYPE
	sep #$20
	sta |$0B,x
	rep #$30
;2fa3  ld      (ix+#06),l
;2fa6  ld      (ix+#07),h
	tya
	sta |$06,x
;2fac  ret
	rts

;------------------------------------------------------------------------------
;
; Special byte FF : mark the end of the song
;
audioFF mx %00
	tyx
;2fad  ld      a,(ix+#02)
;2fb0  cpl
;2fb1  and     (ix+#00)
;2fb4  ld      (ix+#00),a        ; W_NUM &= ~W_CUR_BIT
	sep #$20
	lda |$02,x
	eor #$FF
	and |$00,x
	sta |$00,x
	rep #$30
;2fb7  jp      #2df4
	jmp init_param

;------------------------------------------------------------------------------
; data - table for difficulty
; 	each entry has 3 sections
;	0: 0x10 bytes - speed bit patterns
;	1: 0x0c bytes - ghost data movement bit patterns
;	2: 0x0e bytes - ghost counters for orientation changes
;			4dc1-4dc3 related
;
; this table is referenced at #0733
;330f
difficulty_data
	hex 2A552A55555555552A552A554A5294A5
	hex 252525252222222201010101
	hex 0258070809600E10106817701914
;3339
	hex 4A5294A52AAA55552A552A554A5294A5
	hex 249249252448912201010101
	hex 0000000000000000000000000000
;3363
	hex 2A552A55555555552AAA55552A552A55
	hex 4A5294A52448912244210844
	hex 0258083409D80FB4115816081734
;entry 3:
	hex 555555556AD56AD56AAAD55555555555
	hex 2AAA55552492249222222222
	hex	01A4065407F80CA80DD4128413B0
;entry 4:
	hex 6AD56AD55AD6B5AD5AD6B5AD6AD56AD5
	hex 6AAAD5552492492524489122
	hex 01A4065407F80CA80DD4FFFEFFFF
;entry 5:
	hex 6D6D6D6D6D6D6D6D6DB6DB6D6D6D6D6D
	hex 5AD6B5AD2525252524922492
	hex 012C05DC07080BB80CE4FFFEFFFF
;entry 6:
	hex 6AD56AD56AD56AD56DB6DB6D6D6D6D6D
	hex 5AD6B5AD2448912224922492
	hex 012C05DC07080BB80CE4FFFEFFFF


;  the following resumes Ms Pac
;  the whole section from 0x3435-0x36a2 differs from Pac roms.


; arrive here from #2108 when 1st intermission begins
cutscene1 mx %00
;3435  3a004f    ld      a,(#4f00)	; load A with intermission indicator
;3438  fe01      cp      #01		; is the intermission already running ?
;343a  ca9c34    jp      z,#349c		; yes, skip ahead
	lda |is_intermission
	cmp #01
	beq play_cutscene

;343d  ef        rst     #28		; no, insert task to draw text "THEY MEET"
;343e  1c 32				; 1c = draw text,  32 = string code
	lda #$321C
	jsr rst28

;3440  3e01      ld      a,#01		; load A with code for "1"
;3442  32ac42    ld      (#42ac),a	; write text "1" to screen
	sep #$20
	lda #$01
	sta |tile_ram+$2AC

;3445  3e16      ld      a,#16		; load A with code for color = white
;3447  32ac46    ld      (#46ac),a	; paint the "1" white
	lda #$16
	sta |palette_ram+$2AC

;344a  0e00      ld      c,#00		; C := #00
;344c  c39c34    jp      #349c		; jump ahead
        rep #$30
	ldy #00
	bra play_cutscene

; arrive here from #21A1 when 2nd intermission begins
cutscene2 mx %00
;344f  3a004f    ld      a,(#4f00)	; load A with intermission indicator
;3452  fe01      cp      #01		; is the intermission already running ?
;3454  ca9c34    jp      z,#349c		; yes, skip ahead
	lda |is_intermission
	cmp #1
	beq play_cutscene

;3457  ef        rst     #28		; no, insert task to display text "THE CHASE"
;3458  1c 17				; 1c = draw text,  17 = string code
	lda #$171C
	jsr rst28

;345a  3e02      ld      a,#02		; load A with code for "2"
;345c  32ac42    ld      (#42ac),a	; write text "2" to screen
;345f  3e16      ld      a,#16		; load A with code for color = white
;3461  32ac46    ld      (#46ac),a	; paint the "2" white
	sep #$20
	lda #$02
	sta |tile_ram+$2AC
	lda #$16
	sta |palette_ram+$2AC
	rep #$30
;3464  0e0c      ld      c,#0c		; C := #0C.  This offset is added later to set up act 2
	ldy #$0C
;3466  c39c34    jp      #349c		; jump ahead
	bra play_cutscene

; arrive here from #229A when 3rd intermission begins
cutscene3 mx %00
;3469  3a004f    ld      a,(#4f00)	; load A with intermission indicator
;346c  fe01      cp      #01		; is the intermission already running ?
;346e  ca9c34    jp      z,#349c		; yes, skip ahead
	lda |is_intermission
	cmp #$01
	beq play_cutscene

;3471  ef        rst     #28		; insert task to display text "JUNIOR"
;3472  1c 15				; 1c = draw text,  15 = string code
	lda #$151C
	jsr rst28

	; print "ACT **3**"
;3474  3e03      ld      a,#03		; load A with code for "3"
;3476  32ac42    ld      (#42ac),a	; write text "3" to screen
;3479  3e16      ld      a,#16		; load A with code for color = white
;347b  32ac46    ld      (#46ac),a	; paint the "3" white
	sep #$20
	lda #$03
	sta |tile_ram+$2AC
	lda #$16
	sta |palette_ram+$2AC
	rep #$30
;347e  0e18      ld      c,#18		; C := #18.  this offset is added later to set up act 3
	ldy #$18
;3480  c39c34    jp      #349c		; jump ahead
	bra play_cutscene

;------------------------------------------------------------------------------
; arrive here from #3E67 after Blinky has been introduced
;3483
move_blinky_marquee mx %00
;3483  0e24      ld      c,#24		; load C with offset for moving Blinky
			ldy #$24
;3485  c39c34    jp      #349c		; begin moving Blinky across marquee and up left side
			bra play_cutscene

;------------------------------------------------------------------------------
; arrive here from #3E67 after Pinky has been introduced
;3488
move_pinky_marquee mx %00
;3488  0e30      ld      c,#30		; load C with offset for moving Pinky
			ldy #$30
;348a  c39c34    jp      #349c		; begin moving Pinky across marquee and up left side
			bra play_cutscene

;------------------------------------------------------------------------------
; arrive here from #3E67 after Inky has been introduced
;348d
move_inky_marquee mx %00
;348d  0e3c      ld      c,#3c		; load C with offset for moving Inky
			ldy #$3C
;348f  c39c34    jp      #349c		; begin moving Inky across marquee and up left side
			bra play_cutscene

;------------------------------------------------------------------------------
; arrive here from #3E67 after Sue has been introduced
;3492
move_sue_marquee mx %00
;3492  0e48      ld      c,#48		; load C with offset for moving Sue
			ldy #$48
;3494  c39c34    jp      #349c		; begin moving Sue across marquee and up left side
			bra play_cutscene

;------------------------------------------------------------------------------
; arrive here from #3e67 after Ms. Pac Man has been introduced
;3497
move_mspac_marquee mx %00
;3497  0e54      ld      c,#54		; load C with offset for moving MS pac man
			ldy #$54
;3499  c39c34    jp      #349c		; begin moving ms pac man across marquee
			;bra play_cutscene  ; drops through

;------------------------------------------------------------------------------
; main routine to handle intermissions and attract mode ANIMATIONS
; Passing Y as the offset, instead of C
;349c
play_cutscene mx %00

cutscene_loop_counter  = temp0
cutscene_loop_counter2 = temp0+2
;hl = temp1
;bc = temp2

;349c  3a004f    ld      a,(#4f00)	; load A with intermission indicator
			lda |is_intermission
;349f  a7        and     a		; is the intermission running ?
;34a0  cc1136    call    z,#3611		; no, call this sub to get it started
			bne :continue

			jsr init_cutscene

:continue

;34a3  0606      ld      b,#06		; B := #06
			; usually used as a counter
			lda #6
			sta <cutscene_loop_counter
			asl
			sta <cutscene_loop_counter2 ; x2

; 4f02-03 ppart 1
; 4f04-05 ppart 2
; 4f06-07 ppart 3
; 4f08-09 ppart 4
; 4f0A-0B ppart 5
; 4f0C-0D ppart 6

;34a5  dd210c4f  ld      ix,#4f0c	; load IX with stack.  This holds the list of addresses for the data
			ldy #cutscene_parts+10  ; offset to pointer to part 6
;			lda #0					; clear B for 8-bit m

; get the next ANIMATION code.. (codes return to here when done)
anim_code_loop
;			sep #$20
;34a9  dd6e00    ld      l,(ix+#00)
;34ac  dd6601    ld      h,(ix+#01)	; load HL with stack data.  this is an address for data
			ldx |0,y

; this should be a jump table, am I right?
; especailly since we don't have a conditional branch on the 65816

;34af  7e        ld      a,(hl)		; load data
;34b0  fef0      cp      #f0		; == #F0 ?
;34b2  cade34    jp      z,#34de		; handle code #F0 - LOOP
;34b5  fef1      cp      #f1
;34b7  ca6b35    jp      z,#356b		; handle code #F1 - SETPOS
;34ba  fef2      cp      #f2
;34bc  ca9735    jp      z,#3597		; handle code #F2 - SETN
;34bf  fef3      cp      #f3
;34c1  ca7735    jp      z,#3577		; handle code #F3 - SETCHAR
;34c4  fef5      cp      #f5
;34c6  ca0736    jp      z,#3607		; handle code #F5 - PLAYSOUND
;34c9  fef6      cp      #f6
;34cb  caa435    jp      z,#35a4		; handle code #F6 - PAUSE
;34ce  fef7      cp      #f7
;34d0  caf335    jp      z,#35f3		; handle code #F7 - SHOWACT ?
;34d3  fef8      cp      #f8
;34d5  cafd35    jp      z,#35fd		; handle code #F8 - CLEARACT ?
;34d8  feff      cp      #ff
;34da  cacb35    jp      z,#35cb		; handle code #FF - END

;34dd  76        halt			; wait for interrupt

			lda |0,x
			and #$FF
			cmp #$F0
			bcc :invalid_opcode
			and #$0F
			asl
			phx
			tax
			pla
			jmp (:dispatch,x)

:dispatch
			da op_LOOP		;34de $F0 - LOOP
			da op_SETPOS	;356b $F1 - SETPOS
			da op_SETN		;3597 $F2 - SETN
			da op_SETCHAR   ;3577 $F3 - SETCHAR
			da :invalid_opcode  ; $F4
			da op_PLAYSOUND ;3607 $F5 - PLAYSOUND
			da op_PAUSE     ;35a4 $F6 - PAUSE
			da op_SHOWACT   ;35f3 $F7 - SHOWACT
			da op_CLEARACT  ;35fd $F8 - CLEARACT
			da :invalid_opcode ; $F9
			da :invalid_opcode ; $FA
			da :invalid_opcode ; $FB
			da :invalid_opcode ; $FC
			da :invalid_opcode ; $FD
			da :invalid_opcode ; $FE
			da op_END		;35cb $FF - END

:invalid_opcode mx %00

;			nop
;			nop
;			nop
;]wait   	bra ]wait
;			nop
;			nop
;			nop


			wai	; simulate halt
				; falling through here seems bad - but this is the way

; for value == #F0 - LOOP
;
; Based on what the other opcodes do, this opcode must actually
; make things happen, it'll be exciting to understand what the args mean
;
; Y =  offset to the cutscene_parts list
; A =  index to the current opcode
;34de
op_LOOP mx %00


:arg0   = temp3
:arg1   = temp3+2
:arg2   = temp4
:pXY    = temp4+2

;34de  e5        push    hl
			phy					; need to preserve, act offset
;34df  3e01      ld      a,#01
;34e1  d7        rst     #10   ; ptr to byte

			tax					; index to current opcode data

			lda |1,x
			and #$FF
			sta <:arg0

			lda |2,x
			and #$FF
			sta <:arg1		; arg1 and arg2

			lda |3,x
			and #$FF
			sta <:arg2

			; now I don't have to worry about X, it's free to use
			; y is now free to use




;34e2  4f        ld      c,a
			; c = first byte argument

;34e3  212e4f    ld      hl,#4f2e
;34e6  df        rst     #18      ; hl = hl + 2*b,  (hl) -> e, (++hl) -> d, de -> hl 

			ldy #cutscene_vel-2+1
			lda (<cutscene_loop_counter2),y	  ; pointer to the velocity data

			sep #$20
			clc
			adc <:arg0

;34e9  cd5635    call    #3556
			jsr :shift_thing

;34ec  12        ld      (de),a
			sta (<cutscene_loop_counter2),y ; update the velocity data

			rep #$30

;34ed  cd4136    call    #3641
			jsr get_intermission_xy  ; returns pointer to XY data in A
			inc
			sta <:pXY

; rst 18 (for dereferencing pointers to words)
;'  ; hl = hl + 2*b,  (hl) -> e, (++hl) -> d, de -> hl
;   ; HL = base address of table
;	; B  = index
;	; after the call, HL gets the data in HL+(2*B).  DE becomes HL+2B
;	; modified: DE, A
;34f0  df        rst     #18   ; ptr to word
			tay
;34f1  7c        ld      a,h	; X position
;34f2  81        add     a,c    ; Add to C, which is the X Velocity
			sep #$20
			txa 					 	; X velocity into A
			clc
			adc (<cutscene_loop_counter2),y ; Add X position
;34f3  12        ld      (de),a ; store back in X position
			sta (<cutscene_loop_counter2),y ; Store back X position
			rep #$30

;34f4  e1        pop     hl  ; Refreshing Y
;34f5  e5        push    hl

;34f6  3e02      ld      a,#02
;34f8  d7        rst     #10	; returns arg1 on the opcode

;34f9  4f        ld      c,a   ; we can just directly access arg1

			; c=arg1

;34fa  212e4f    ld      hl,#4f2e
;34fd  df        rst     #18

			ldy #cutscene_vel-2
			lda (<cutscene_loop_counter2),y

			sep #$20
			clc
			adc <:arg1

			; A has pointer to velocity y
;34fe  79        ld      a,c
;34ff  85        add     a,l
;3500  cd5635    call    #3556
			jsr :shift_thing

;3503  1b        dec     de
;3504  12        ld      (de),a
			sta (<cutscene_loop_counter2),y
			
			rep #$30

;3505  cd4136    call    #3641
			jsr get_intermission_xy  ; returns pointer to XY data in A
			sta <:pXY
;3508  df        rst     #18
			tay

			; Well here's "a" problem
			; looks like the only unfinished part of this function
			; c = arg1

;3509  7d        ld      a,l
			sep #$20
;350a  81        add     a,c
			txa
			clc
			adc (<cutscene_loop_counter2),y ; vy + y
;350b  1b        dec     de
;350c  12        ld      (de),a
			sta (<cutscene_loop_counter2),y ; store y position

			rep #$31

;350d  210f4f    ld      hl,#4f0f  ; cs_sprite_index-1
;3510  78        ld      a,b
;3511  d7        rst     #10
			ldy #cs_sprite_index-1
			lda (<cutscene_loop_counter),y  ; sprite index
			and #$ff

;3512  e5        push    hl
;3513  3c        inc     a
			inc
;3514  4f        ld      c,a
]loop
;3515  213e4f    ld      hl,#4f3e
;3518  df        rst     #18		; load HL with address (EG 8663)
			pha

			ldy #cutscene_anim-2
			lda (<cutscene_loop_counter2),y ; pointer to character list, anim sequence
			tax

;3519  79        ld      a,c		; Copy C to A
			pla 	; index to sprite frame
			pha
			phx
;351a  cb2f      sra     a		; Shift right (div by 2)
			sep #$20
			cmp #$80
			ror
			rep #$30
			and #$FF
			cmp #$80
			bcc :is_positive
			ora #$FF00
			clc
:is_positive
			adc 1,s
			sta 1,s
			plx
;351c  d7        rst     #10		; dereference sprite number for intro.  loads A with value in HL+A
			lda |0,x
;351d  feff      cp      #ff		; are we done ?
			and #$FF
			tax
			cmp #$FF
			; A = the actual sprite character number
;351f  c22635    jp      nz,#3526	; no, skip ahead
			bne :not_reset

;3522  0e00      ld      c,#00		; else reset counter
;3524  18ef      jr      #3515           ; loop again
			pla
			lda #0
			bra ]loop

:not_reset
;3526  e1        pop     hl
;3527  71        ld      (hl),c
			ldy #cs_sprite_index-1
			pla
			sep #$20
			sta (<cutscene_loop_counter),y
;3528  5f        ld      e,a
;3529  e1        pop     hl
;352a  3e03      ld      a,#03
;352c  d7        rst     #10	; returns arg2 for the opcode
;352d  57        ld      d,a
;352e  d5        push    de
;352f  214e4f    ld      hl,#4f4e ; custscene_misc2-2
;3532  df        rst     #18
;3533  e1        pop     hl
;3534  eb        ex      de,hl
;3535  72        ld      (hl),d
			ldy #cutscene_SpriteRAM-2+1
			sep #$20
			lda <:arg2
			sta (<cutscene_loop_counter2),y ; color
;3536  2b        dec     hl
			dey
			txa
			sta (<cutscene_loop_counter2),y ; sprite frame #


;3537  3a094e    ld      a,(#4e09)
;			lda |player_no

;353a  4f        ld      c,a
;353b  3a724e    ld      a,(#4e72)
;			lda |cocktail_mode
;353e  a1        and     c
;353f  2804      jr      z,#3545         ; (4)

				; Alter Y position, when player 2, and cocktail
;3541  3ec0      ld      a,#c0
;3543  ab        xor     e
;3544  5f        ld      e,a

;3545  73        ld      (hl),e
				; Store out the Y Position of the Sprite

;3546  21174f    ld      hl,#4f17 ; cutscene_nvalues-1
;3549  78        ld      a,b
;354a  d7        rst     #10
			rep #$30

			lda <cutscene_loop_counter
			clc
			adc #cutscene_nvalues-1
			tax
			ply
;354b  3d        dec     a
			sep #$20
			dec |0,x
			rep #$20
			beq :advance_opcode

;354c  77        ld      (hl),a
;354d  110000    ld      de,#0000
;3550  2062      jr      nz,#35b4        ; (98)
			lda #0     				; run the LOOP opcode again next frame
			jmp next2_op

:advance_opcode
; when N Value is zero, we are done with the opcode
;3552  1e04      ld      e,#04		     ; 4 bytes used from the sequence
			lda #$0004
;3554  185e      jr      #35b4           ; (94)
			jmp next2_op

:shift_thing mx %10
			pha
;3556  4f        ld      c,a
;3557  cb29      sra     c
			cmp #$80
			ror
;3559  cb29      sra     c
			cmp #$80
			ror
;355b  cb29      sra     c
			cmp #$80
			ror
;355d  cb29      sra     c
			cmp #$80
			ror
			tax
;355f  a7        and     a 	      ; effected by a
			pla
			bpl :shift_positive
			;bit #$40
			;bvc :shift_positive

; arrive here when ghost is moving up the left side of the marquee

;3563  f6f0      or      #f0
			ora #$F0
;3565  0c        inc     c
			inx
;3566  1802      jr      #356a           ; (2)
			rts
:shift_positive
;3568  e60f      and     #0f
			and #$0F
;356a  c9        ret
			rts	 

; for value == #F1 - SETPOS
op_SETPOS mx %00
;356b  eb        ex      de,hl
			tax
;3571  23        inc     hl
;3572  56        ld      d,(hl)
;3573  23        inc     hl
;3574  5e        ld      e,(hl)
			lda |1,x
			xba
			pha

;356c  cd4136    call    #3641		; load HL with either #4CFE or #4Dc6
			jsr get_intermission_xy  ; returns pointer to XY data in A
;356f  eb        ex      de,hl
;3570  d5        push    de
			pha

;3575  1813      jr      #358a           ; (19)
			bra next_op

; for value == #F3 - SETCHAR
op_SETCHAR mx %00
			tax
			lda |1,x
			pha 	 	; Address word for the character

;3577  eb        ex      de,hl		; save HL into DE
;3578  210f4f    ld      hl,#4f0f	; HL := #4F0F (stack)
;357b  78        ld      a,b		; A := B
;357c  d7        rst     #10		; load A with the data in HL+A
			lda <cutscene_loop_counter
			adc #cs_sprite_index-1
			tax
;357d  3600      ld      (hl),#00	; clear this location
			sep #$20
			stz |0,x
			rep #$20
;357f  eb        ex      de,hl		; restore HL from DE

;3580  113e4f    ld      de,#4f3e	; DE := #4F3E (stack)
			pea cutscene_anim-2
;3583  d5        push    de		; save DE
;3584  23        inc     hl		; next location
;3585  5e        ld      e,(hl)
;3586  23        inc     hl
;3587  56        ld      d,(hl)		; DE how has the address word after the code #F3

;3588  1800      jr      #358a		; does nothing (?) -- jumps to next instruction
;			bra next_op

; cleanup for return from #F0, #F1, #F3
next_op
;358a  e1        pop     hl		; restore DE saved earlier into HL
;358b  d5        push    de		; save the address
;358c  df        rst     #18		; load HL with the data in (HL + 2*B)
;358d  eb        ex      de,hl		; DE <-> HL
;358e  d1        pop     de		; restore the address
;358f  72        ld      (hl),d
;3590  2b        dec     hl
;3591  73        ld      (hl),e
			lda <cutscene_loop_counter
			asl
			adc 1,s
			sta 1,s
			plx
			pla
			sta |0,x

;3592  110300    ld      de,#0003	; 3 bytes used from the code program
			lda #3
;3595  181d      jr      #35b4           ; (29)
			bra next2_op

; for value = #F2 - SETN
op_SETN mx %00
			tax
;3597  23        inc     hl
;3598  4e        ld      c,(hl)    ; argument value
			lda <cutscene_loop_counter
;3599  21174f    ld      hl,#4f17
;359c  78        ld      a,b
;359d  d7        rst     #10	   ; hl with address (4f18->4f1E)
			adc #cutscene_nvalues-1
			sta <temp1
			sep #$20
			lda |1,x   ; inc hl, ld c,(hl)
;359e  71        ld      (hl),c    ; save the value, for whatever wants it
			sta (<temp1)
			rep #$20
;359f  110200    ld      de,#0002  ; 
			lda #$0002			   ; opcode + arg, 2 bytes in size
;35a2  1810      jr      #35b4           ; (16)
			bra next2_op

; for value == #F6 - PAUSE
op_PAUSE mx %00
;35a4  21174f    ld      hl,#4f17   ; calculate pause timer address
;35a7  78        ld      a,b
;35a8  d7        rst     #10	    ; pause timer addr in hl
			lda <cutscene_loop_counter
			; c=0, because jmp table dispatch uses asl
			adc #cutscene_nvalues-1
			tax
;35a9  3d        dec     a  		; countdown value
;35aa  77        ld      (hl),a 	; save
			sep #$20
			dec |0,x
			rep #$20
			beq :done

;35ab  110000    ld      de,#0000    ; this would leave the PC at PAUSE
;35ae  2004      jr      nz,#35b4    ; if the branch is taken
			lda #0
			bra next2_op

:done
;35b0  1e01      ld      e,#01		; 1 byte used from the code program
			lda #$0001
;35b2  1800      jr      #35b4           ; (0)
;			bra next2_op  -- falls through

; finish up for the above

			; Enter with A containing the number of bytes to move
			; forward in the cutscene data
next2_op
;35b4  dd6e00    ld      l,(ix+#00)
;35b7  dd6601    ld      h,(ix+#01)	; load HL with next value
;35ba  19        add     hl,de		; add offset
;35bb  dd7500    ld      (ix+#00),l
;35be  dd7401    ld      (ix+#01),h
			clc
			adc |0,y
			sta |0,y
			 
;35c1  dd2b      dec     ix
			dey
;35c3  dd2b      dec     ix
			dey
;35c5  1001      djnz    #35c8           ; (1)
			lda <cutscene_loop_counter
			dec
			sta <cutscene_loop_counter
			asl
			sta <cutscene_loop_counter2
			bnel anim_code_loop
;35c7  c9        ret     
			rts
;35c8  c3a934    jp      #34a9

; for value == #FF (end code)
op_END mx %00
;35cb  211f4f    ld      hl,#4f1f
			lda #cutscene_act_end-1   ; Set to 1 when END has been encountered
;35ce  78        ld      a,b
;35cf  d7        rst     #10
			adc <cutscene_loop_counter
			tax
			sep #$20
;35d0  3601      ld      (hl),#01
			lda #1
			sta |0,x

;35d2  21204f    ld      hl,#4f20
;35d5  7e        ld      a,(hl)
			lda |cutscene_act_end
;35d6  23        inc     hl
;35d7  a6        and     (hl)
			and |cutscene_act_end+1
;35d8  23        inc     hl
;35d9  a6        and     (hl)
			and |cutscene_act_end+2
;35da  23        inc     hl
;35db  a6        and     (hl)
			and |cutscene_act_end+3
;35dc  23        inc     hl
;35dd  a6        and     (hl)
			and |cutscene_act_end+4
;35de  23        inc     hl
;35df  a6        and     (hl)
			and |cutscene_act_end+5
			rep #$20
			bne :all_end
;35e0  110000    ld      de,#0000
;35e3  28cf      jr      z,#35b4         ; (-49)
			lda #0
			bra next2_op
:all_end
;35e5  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
;35e8  a7        and     a		; == #00 ?
			lda |mainroutine1
;35e9  ca9521    jp      z,#2195		; yes, jump back to program
			beql cutscene_end

;35ec  af        xor     a		; else A := #00
;35ed  32004f    ld      (#4f00),a	; clear the intermission indicator
			stz |is_intermission
;35f0  c38e05    jp      #058e		; jump back to program
			jmp ttask2

; for value == #F7 - SHOWACT ?
op_SHOWACT mx %00
;35f3  78        ld      a,b
;35f4  ef        rst     #28		; insert task to display text "        "
;35f5  1c 30
			lda #$301C
			jsr rst28
;35f6  47        ld      b,a
;35f8  110100    ld      de,#0001
			lda #1
;35fb  18b7      jr      #35b4           ; (-73)
			bra next2_op

; for value == #F8 - CLEARACT
op_CLEARACT mx %00
			sep #$20
;35fd  3e40      ld      a,#40
;35ff  32ac42    ld      (#42ac),a	; blank out the character where the 'ACT' # was displayed
			lda #$40
			sta |tile_ram+$2AC
			rep #$30
;3602  110100    ld      de,#0001
			lda #1
;3605  18ad      jr      #35b4           ; (-83)
			bra next2_op

; for value == #F5 - PLAYSOUND
op_PLAYSOUND mx %00
			tax
;3607  23        inc     hl
;3608  7e        ld      a,(hl)
			lda |1,x				; first argument
;3609  32 BC 4E  ld   	(#4EBC),a	; set sound channel #3.  used when ghosts bump during 1st intermission
			and #$FF
			sta |bnoise
;360c  11 02 00	ld      de,#0002    ; ?? opcode + args, size?
			lda #$0002
;360f  18 a3	jr      #35b4           ; (-93)
			bra next2_op

;------------------------------------------------------------------------------
; arrive here at intermissions and attract mode
; called from above, with C preloaded with an offset depending on which intermission / attract mode we are in
; ja - Y is used instead of C
;3611
init_cutscene mx %00
;3611  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
;3614  a7        and     a		; check for zero.  is a game being played?
			lda |mainroutine1
;3615  2008      jr      nz,#361f        ; no, skip next 3 steps.  no sounds during attract mode
			bne :skip_sound

;3617  3e02      ld      a,#02		; else A := #02
			lda #2
;3619  32cc4e    ld      (#4ecc),a	; store in wave to play
			sta |CH1_W_NUM
;361c  32dc4e    ld      (#4edc),a	; store in wave to play
			sta |CH2_W_NUM

; this is used to generate the animations with the animation programs stored in the tables
:skip_sound
;361f  21f081    ld      hl,#81f0	; load HL with start of table data
;3622  0600      ld      b,#00		; B:=#00
;3624  09        add     hl,bc		; add BC to HL to offset the start of the data
;3625  11024f    ld      de,#4f02	; load Destination with #4F02
;3628  010c00    ld      bc,#000c	; load byte counter with #0C
;362b  edb0      ldir  			; copy data from table into memory
			; copy 6 pointers to 4f02

			clc
			tya
			adc #cutscenes_table
			tax 					; Source
			ldy #cutscene_parts		; Dest
			lda #11					; length
			mvn ^cutscenes_table,^cutscene_parts

;362d  3e01      ld      a,#01		; A := #01
;362f  32004f    ld      (#4f00),a	; set intermission indicator
			lda #1
			sta |is_intermission
;3632  32a44d    ld      (#4da4),a	; set # of ghost killed but no collision for yet to 1
			sta |num_ghosts_killed

;3635  211f4f    ld      hl,#4f1f	; load HL with stack pointer (?)
;3638  3e00      ld      a,#00		; A := #00
;363a  32a54d    ld      (#4da5),a	; set pacman dead animation state to not dead
			stz |pacman_dead_state

;363d  0614      ld      b,#14		; B := #14
			ldx #cutscene_vars  	; nvalues, and act_end flags to 0
			ldy #$14
			lda #0

;363f  cf        rst     #8		;
			jsr rst8 			; memset
;3640  c9        ret 			; return    
			rts
;
; Get a pointer to the XY position
;
get_intermission_xy mx %00

;3641  78        ld      a,b
			lda <cutscene_loop_counter
;3642  fe06      cp      #06
			cmp #6
;3644  2004      jr      nz,#364a        ; (4)
			bne :not6
;3646  21c64d    ld      hl,#4dc6
			lda #fruit_y-12    ; 4DC6+$C = 4DD2
;3649  c9        ret 
			rts
:not6
;364a  21fe4c    ld      hl,#4cfe
			lda #cutscene_positions-2
;364d  c9        ret
			rts
;------------------------------------------------------------------------------
; select song
; arrive here from #2D62
select_song mx %00
;364E: 05	dec	b		; B = current bit of song being played (from loop in #2d50)
					; adapt B to the current level to find out the song number
;364F: C5	push	bc		; save BC	
;3650: 78	ld	a,b		; load A with B
;3651: FE 01	cp	#01		; == #01 ?
;3653: 28 04	jr	z,#3659		; yes, skip next 2 steps
;3655: 06 00	ld	b,#00		; else B := #00
;3657: 18 11	jr	#366A		; jump ahead
;
;3659: 3A 13 4E	ld	a,(#4E13)	; load A with current game level
;365C: 06 01	ld	b,#01		; B := #01 (song #1 for 1st intermission)
;365E: FE 01	cp	#01		; game level == #01 (level 2) ?
;3660: 28 08	jr	z,#366A		; yes, jump ahead
;3662: 06 02	ld	b,#02		; B := #02 (song #2 for 2nd intermission)
;3664: FE 04	cp	#04		; game level == #04 (level 5) ?
;3666: 28 02	jr	z,#366A		; yes, jump ahead
;3668: 06 03	ld	b,#03		; else B := #03 (song #3 for 3rd intermission)

;366A: DF	rst	#18		; HL = (HL+2B)  [read from table in HL, i.e. SONG_TABLE_x]
;366B: C1	pop	bc		; restore BC

; it's better for my local label scope, to call this as function
;366C: C3 72 2D	jp	#2D72		; jump back to main program to "process byte" routine
	    rts

; arrive here from #2060 
; A is loaded with the color of the tile the ghost is on

;366f  cb77      bit     6,a		; test bit 6 of the tile.  is this a slow down zone (tunnel) ?
;3671  ca6620    jp      z,#2066		; no, jump back and set the var to zero
;3674  3e01      ld      a,#01		; yes, A := #01
;3676  02        ld      (bc),a		; store into ghost tunnel slowdown flag
;3677  c9        ret     		; return


;------------------------------------------------------------------------------
;
;; Indirect Lookup table for #2C5E routine  (0x48 entries)
;; patched from Pac-Man.  Pac-man items are indented
;36a5
string_table
	da :s00 ; #3713	; 00        HIGH SCORE
	da :s01 ; #3723	; 01        CREDIT   
	da :s02 ; #3732	; 02        FREE PLAY
	da :s03 ; #3741	; 03        PLAYER ONE
	da :s04 ; #375A	; 04        PLAYER TWO
	da :s05 ; #376A	; 05        GAME  OVER
	da :s06 ; #377A	; 06        READY!
	da :s07 ; #3786	; 07        PUSH START BUTTON
	da :s08 ; #379D	; 08        1 PLAYER ONLY 
	da :s09 ; #37B1	; 09        1 OR 2 PLAYERS
	da st0A ; #3D21	; 0a        "     "
	da st0B ; #3D00	; 0b        ADDITIONAL    AT   000
	da :s0C ; #37FD	; 0c        "MS PAC-MAN"
	da st0D ; #3D67	; 0d        BLINKY
	da st0E ; #3DE3	; 0e        WITH
	da st0F	; #3d86	; 0f        PINKY  
	da st10	; #3E02	; 10        STARRING
	da :s11	; #384C	; 11        . 10 Pts (pac-man only)
	da :s12	; #385A	; 12        o 50 Pts (pac-man only)
	da st13	; #3D3C	; 13        (C) MIDWAY MFG CO
	da st14	; #3D57	; 14        MAD DOG
	da st15	; #3DD3	; 15        JUNIOR
	da st16	; #3D76	; 16        KILLER
	da st17	; #3DF2	; 17        THE CHASE
	da $001	; #0001	; 18 	    - unused -
	da $002	; #0002	; 19	    - unused -
	da $003	; #0003	; 1a	    - unused -

	da :s1B	; #38BC	; 1b        100
	da :s1C	; #38C4	; 1c        SUPER PAC-MAN
	da :s1D	; #38CE	; 1d        MAN
	da :s1E	; #38D8	; 1e        AN
	da :s1F	; #38E2	; 1f        - ? -

	da :s20	; #3820	; 20        - ? -
	da :s21	; #38F6	; 21        - ? -
	da :s22	; #3900	; 22        - ? -
	da :s23	; #390A	; 23        MEMORY  OK
	da :s24	; #391A	; 24        BAD    R M
	da :s25	; #396F	; 25        FREE  PLAY       
	da :s26	; #392A	; 26        1 COIN  1 CREDIT 
	da :s27	; #3958	; 27        1 COIN  2 CREDITS
	da :s28	; #3941	; 28        2 COINS 1 CREDIT 
	da st29	; #3E11	; 29        MS. PAC-MEN	(service mode screen)
	da :s2A	; #3986	; 2a        BONUS  NONE
	da :s2B	; #3997	; 2b        BONUS
	da :s2C	; #39B0	; 2c        TABLE  
	da :s2D	; #39BD	; 2d        UPRIGHT
	da :s2E	; #39CA	; 2e        000		for test screen
	da st2F	; #3DA5	; 2f        INKY    
	da st30	; #3E21	; 30        "        "
	da st31	; #3DC6	; 31        SUE 
	da st32	; #3E40	; 32        THEY MEET
	da st33	; #3D95	; 33        MS. PAC-MAN  (For "Starring" bit)
	da st34	; #3E11	; 34        MS. PAC-MEN	 (service mode screen)
	da st35	; #3DB4	; 35        1980,1981
	da st36	; #3E30	; 36        ACT III

	;; there's another one of these for the text over at 3D00

; and here it is in a more readable format
; macro, so that we can keep each item 1 line in the definition
pms mac
	dw ]1
	asc ]2
	<<<

:s00 pms $83d4;'HIGH@SCORE',$2f,$8f,$2f,$80
:s01 pms $803b;'CREDIT@@@',$2f,$8f,$2f,$80
:s02 pms $803b;'FREE@PLAY',$2f,$8f,$2f,$80
:s03 pms $028c;'PLAYER@ONE',$2f,$85,$2f,$10
:s04 pms $028c;'PLAYER@TWO',$2f,$85,$2f,$80
:s05 pms $0292;'GAME@@OVER',$2f,$81,$2f,$80
:s06 pms $0252;'READY[',$2f,$89,$2f,$90
:s07 pms $02ed;'PUSH@START@BUTTON',$2f,$87,$2f,$80
:s08 pms $02af;'1@PLAYER@ONLY@',$2f,$87,$2f,$80
:s09 pms $02af;'1@OR@2@PLAYERS',$2f,$87,$00,$2F
			db $00,$80,$00
;37c8
	pms $0396;'BONUS@PUCKMAN@FOR@@@000@]^_';$2f;$8e;$2f;$80
;37e9
	pms $02ba;'\@()*+',$3b,'-.@1980',$2f,$83,$2f,$80
;37FD
:s0C pms $0365;'@@@@@@@@&MS@PAC',$3b,'MAN',$27,$40,$2f,$87,$2f,$80
;3817
	pms $0180;'&AKABEI&',$2f,$81,$2f,$80
:s20
;3825
	pms $0145;'&MACKY&',$2f,$81,$2f,$80
;3832
	pms $0148;'&PINKY&',$2f,$83,$2f,$80
;383f
	pms $0148;'&MICKY&',$2f,$83,$2f,$80
;384d
:s11
	pms $1002;'@10@]^_',$2f,$9f,$2f,$80
;385b
:s12
	pms $1402;'@50@]^_',$2f,$9f,$2f,$80
;3868      
	pms $025d;'()*+,-.',$2f,$83,$2f,$80
;3875     
	pms $02c5;'@OIKAKE',$3b,$3b,$3b,$3b,$2f,$81,$2f,$80
;3886      
	pms $02c5;'@URCHIN',$3b,$3b,$3b,$3b,$3b,$2f,$81,$2f,$80
;3898      
	pms $02c8;'@MACHIBUSE',$3b,$3b,$2f,$83,$2f,$80
;38aa      
	pms $02c8;'@ROMP',$3b,$3b,$3b,$3b,$3b,$3b,$3b,$2f,$83,$2f,$80
;38bc
:s1B pms $8025;''
;38be
	pms $8581;'',$2f,$81,$2f,$90
;38c4
:s1C
	pms $026e;'SUPER@PAC',$3b',MAN',$2f,$89,$2f,$80
:s1D
	; this is messed up, maybe not used
;38d5
	pms $802f;'MAN',$2f,$89,$2f,$80
:s1E
:s1F
;38e6
	pms $8e8d;'',$2f,$8f,$2f,$90
;38ec
	pms $8030;'@@@@',$2f,$94,$2f,$90
:s21
;38fa
	pms $8e8d;'',$2f,$89,$2f,$90
:s22
;3904
	pms $8e8d;'',$2f,$89,$2f,$90
;390a 
:s23 pms $0304;'MEMORY@@OK',$2f,$8f,$2f,$80
;391a
:s24 pms $0304;'BAD@@@@R@M',$2f,$8f,$2f,$80
;392a
:s26 pms $0308;'1@COIN@@1@CREDIT@',$2f,$8f,$2f,$80
;3941
:s28 pms $0308;'2@COINS@1@CREDIT@',$2f,$8f,$2f,$80
;3958
:s27 pms $0308;'1@COIN@@2@CREDITS',$2f,$8f,$2f,$80
;396f
:s25 pms $0308;'FREE@@PLAY@@@@@@@',$2f,$8f,$2f,$80
;3986
:s2A pms $030a;'BONUS@@NONE',$2f,$8f,$2f,$80
;3997
:s2B pms $030a;'BONUS@',$2f,$8f,$2f,$80
;39a3
	pms $030c;'PUCKMAN',$2f,$8f,$2f,$80
;39b0
:s2C pms $030e;'TABLE@@',$2f,$8f,$2f,$80
;39bd
:s2D pms $030e;'UPRIGHT',$2f,$8f,$2f,$80
;39ca
:s2E pms $020a;'000',$2f,$8f,$2f,$80
;39d3
	pms $016b;'&AOSUKE&',$2f,$85,$2f,$3d
;3a09
	pms $02cb;'@KIMAGURE',$3b,$3b,$2f,$85,$2f,$80
;3a1a
	pms $02cb;'@STYLIST',$3b,$3b,$3b,$3b,$2f,$85,$2f,$80
;3a2c
	pms $02ce;'@OTOBOKE',$3b,$3b,$3b,,$2f,$87,$2f,$80
;3a3d
	pms $02ce;'@CRYBABY',$3b,$3b,$3b,$3b,$2f,$87,$2f,$80

;------------------------------------------------------------------------------
;;
;; MSPACMAN sound tables
;;
;; 2 effects for channel 1
;3b30
EFFECT_TABLE_1
	db $73,$20,$00,$0c,$00,$0a,$1f,$00  	; extra life sound
;3b38
	db $72,$20,$fb,$87,$00,$02,$0f,$00	; credit sound

;; 8 effects for channel 2
;3B40
EFFECT_TABLE_2
;3B40
	db $59,$01,$06,$08,$00,$00,$02,$00 ; end of energizer
;3B48
	db $59,$01,$06,$09,$00,$00,$02,$00 ; higher frequency when 155 dots eaten
;3B50
    db $59,$02,$06,$0a,$00,$00,$02,$00 ; higher frequency when 179 dots eaten
;3B58
    db $59,$03,$06,$0b,$00,$00,$02,$00 ; higher frequency when 12 dots left
;3B60
	db $59,$04,$06,$0c,$00,$06,$02,$00 ; reset higher frequency when 12 or less dots left
;3b68
	db $24,$00,$06,$08,$02,$00,$0a,$00 ; engergizer eaten
;3B70
	db $36,$07,$87,$6f,$00,$00,$04,$00 ; eyes returning sound
;3B78
	db $70,$04,$00,$00,$00,$00,$08,$00 ; unused ???

	;; 6 effects for channel 3
EFFECT_TABLE_3
;3b80
	db $1c,$70,$8b,$08,$00,$01,$06,$00 ; dot eating sound 1
;3B88
	db $1c,$70,$8b,$08,$00,$01,$06,$00 ; dot eating sound 2
;3b90
	db $56,$0c,$ff,$8c,$00,$02,$08,$00 ; fruit eating sound
;3B98
	db $56,$00,$02,$0a,$07,$03,$0c,$00 ; blue ghost eaten sound
;3bA0
	db $36,$38,$fe,$12,$f8,$04,$0f,$fc ; ghosts bumping during act 1 sound
;3BA8
	db $22,$01,$01,$06,$00,$01,$07,$00 ; fruit bouncing sound

pow_table
;3BB0
	db $01,$02,$04,$08,$10,$20,$40,$80

freq_table
;3BB8
	db $00,$57,$5C,$61,$67,$6D,$74,$7B
	db $82,$8A,$92,$9A,$A3,$AD,$B8,$C3


	;; text strings 2  (copyright, ghost names, intermission)

;3D00:  96 03 40 41 44 44 49 54 49 4F 4E 41 4C 40 40 40  ..@ADDITIONAL@@@
;3D10:  40 41 54 40 40 40 30 30 30 40 5D 5E 5F 2F 95 2F  @AT@@@000@]^_/./
;3D20:  80 5A 02 40 40 40 40 40 40 40 2F 07 07 07 01 01  .Z.@@@@@@@/.....
;3D30:  01 01 2F 80 50 40 40 40 2F 87 2F 80 5B 02 5C 40  ../.P@@@/./.[.\@
;3D40:  4D 49 44 57 41 59 40 4D 46 47 40 43 4F 40 40 40  MIDWAY@MFG@CO@@@
;3D50:  40 2F 81 2F 80 2F 80 C5 02 3B 4D 41 44 40 44 4F  @/././...;MAD@DO
;3D60:  47 40 40 2F 81 2F 80 6E 02 40 40 40 42 4C 49 4E  G@@/./.n.@@@BLIN
;3D70:  4B 59 2F 81 2F 80 C8 02 3B 4B 49 4C 4C 45 52 40  KY/./...;KILLER@
;3D80:  40 40 2F 83 2F 80 6E 02 40 40 40 50 49 4E 4B 59  @@/./.n.@@@PINKY
;3D90:  40 2F 83 2F 80 6E 02 4D 53 40 50 41 43 3B 4D 41  @/./.n.MS@PAC;MA
;3DA0:  4E 2F 89 2F 80 6E 02 40 40 40 49 4E 4B 59 40 40  N/./.n.@@@INKY@@
;3DB0:  2F 85 2F 80 3D 02 40 40 31 39 38 30 3A 31 39 38  /./.=.@@1980:198
;3DC0:  31 40 2F 81 2F 80 6E 02 40 40 40 40 53 55 45 2F  1@/./.n.@@@@SUE/
;3DD0:  87 2F 80 6B 02 4A 55 4E 49 4F 52 40 40 40 40 2F  ./.k.JUNIOR@@@@/
;3DE0:  8F 2F 80 6B 02 57 49 54 48 40 40 40 40 40 2F 8F  ./.k.WITH@@@@@/.
;3DF0:  2F 80 6B 02 54 48 45 40 43 48 41 53 45 40 2F 8F  /.k.THE@CHASE@/.
;3E00:  2F 80 6B 02 53 54 41 52 52 49 4E 47 40 2F 8F 2F  /.k.STARRING@/./
;3E10:  80 0C 03 4D 53 40 50 41 43 3B 4D 45 4E 2F 8F 2F  ...MS@PAC;MEN/./
;3E20:  80 6B 02 40 40 40 40 40 40 40 40 40 2F 85 2F 80  .k.@@@@@@@@@/./.
;3E30:  6B 02 41 43 54 40 49 49 49 26 40 40 2F 87 2F 80  k.ACT@III&@@/./.
;3E40:  6B 02 54 48 45 59 40 4D 45 45 54 2F 8F 2F 80 0C  k.THEY@MEET/./..
;3E50:  03 4F 54 54 4F 4D 45 4E 2F 8F 2F 80              .OTTOMEN/./.

;3d00      
st0B pms $0396;'@ADDITIONAL@@@@AT@@@000@]^_',$2f,$95,$2f,$80
;3d00  P   0x0396, "BONUS@PAC;MAN@FOR@@@000@]^_", 	0x2f, 0x8e, 0x2f, 0x80, 
;3d21
st0A pms $025A;'@@@@@@@',$2F,$07,$07,$07,$01,$01,$01,$01
;3d21  P   0x033a, "\@1980@MIDWAY@MFG%CO%", 		0x2f, 0x83, 0x2f, 0x80, 
;3d32      0x802f, "P@@@", 				0x2f, 0x87, 0x2f, 0x80, 
;3d3c    
st13 pms $025b;'\@MIDWAY@MFG@CO@@@@',$2f,$81,$2f,$80
;3d3c  P   0x033d, "\@1980@MIDWAY@MFG%CO%", 		0x2f, 0x83, 0x2f, 0x80, 

;3d57      
st14 pms $02c5;$3b,'MAD@DOG@@',$2f,$81,$2f,$80
;3d57  P   0x02c5, ";SHADOW@@@", 	0x2f, 0x81, 0x2f, 0x80, 
;3d67
st0D pms $026e;'@@@BLINKY',$2f,$81,$2f,$80
;3d67  P   0x0165, "&BLINKY&@", 		0x2f, 0x81, 0x2f, 0x80, 
;3d76    
st16 pms $02c8;$3b,'KILLER@@@',$2f,$83,$2f,$80
;3d76  P   0x02c8, ";SPEEDY@@@", 	0x2f, 0x83, 0x2f, 0x80, 
;3d86    
st0F pms $026e;'@@@PINKY@',$2f,$83,$2f,$80
;3d86  P   0x0168, "&PINKY&@@", 		0x2f, 0x83, 0x2f, 0x80, 
;3d95    
st33 pms $026e;'MS@PAC',$3b,'MAN',$2f,$89,$2f,$80
;3d95  P   0x02cb, ";BASHFUL@@", 	0x2f, 0x85, 0x2f, 0x80, 
;3da5    
st2F pms $026e;'@@@INKY@@',$2f,$85,$2f,$80
;3da5  P   0x016b, "&INKY&@@@", 		0x2f, 0x85, 0x2f, 0x80, 
;3db4    
st35 pms $023d;'@@1980:1981@',$2f,$81,$2f,$80
;3db4  P   0x02ce, ";POKEY@@@@", 	0x2f, 0x87, 0x2f, 0x80, 
;3dc6
st31 pms $026e;'@@@@SUE',$2f,$87,$2f,$80
;3dc4  P   0x016e, "&CLYDE&@@", 		0x2f, 0x87, 0x2f, 0x80, 
;3dd3    
st15 pms $026b;'JUNIOR@@@@',$2f,$8f,$2f,$80
;3dd3  P   0x02c5, ";AAAAAAAA;", 	0x2f, 0x81, 0x2f, 0x80, 
;3de3    
st0E pms $026b;'WITH@@@@@',$2f,$8f,$2f,$80
;3de3  P   0x0165, "&BBBBBBB&", 		0x2f, 0x81, 0x2f, 0x80, 
;3df2    
st17 pms $026b;'THE@CHASE@',$2f,$8f,$2f,$80
;3df2  P   0x02c8, ";CCCCCCCC;", 	0x2f, 0x83, 0x2f, 0x80, 
;3e02    
st10 pms $026b;'STARRING@',$2f,$8f,$2f,$80
;3e02  P   0x0168, "&DDDDDDD&", 		0x2f, 0x83, 0x2f, 0x80, 
;3e11
st34    
st29 pms $030c;'MS@PAC',$3b,'MEN',$2f,$8f,$2f,$80
;3e11  P   0x02cb, ";EEEEEEEE;", 	0x2f, 0x85, 0x2f, 0x80, 
;3e21    
st30 pms $026b;'@@@@@@@@@',$2f,$85,$2f,$80
;3e21  P   0x016b, "&FFFFFFF&", 		0x2f, 0x85, 0x2f, 0x80, 
;3e30    
st36 pms $026b;'ACT@III&@@',$2f,$87,$2f,$80
;3e30  P   0x02ce, ";GGGGGGGG;", 	0x2f, 0x87, 0x2f, 0x80, 
;3e40    
st32 pms $026b;'THEY@MEET',$2f,$8f,$2f,$80
;3e40  P   0x016e, "&HHHHHHH&", 		0x2f, 0x87, 0x2f, 0x80, 
;3e4f      0x030c, "OTTOMEN", 		0x2f, 0x8f, 0x2f, 0x80, 
;3e4f  P   0x030c, "PAC;MAN", 		0x2f, 0x8f, 0x2f, 0x80, 

;------------------------------------------------------------------------------
;; new code for ms-pacman.  used during demo mode, when there are no credits
;3e5c
ATTRACT mx %00
;3e5c  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
			lda |mainroutine1
;3e5f  fe10      cp      #10		; == #10 ?  #10 indicates that the maze demo is running, not the marquee
			cmp #$10
;3e61  c4d03e    call    nz,#3ed0	; no, call this sub.  it controls the flashing bulbs around the marquee
			beq :skip
			jsr marque_flash
:skip
;3e64  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
;3e67  e7        rst     #20		; jump based on A
			lda |mainroutine1
			asl
			tax
			jmp (:table,x)
:table
;3e68  5f 04				; #045F		; A == #00	; display "ms. Pac Man"
			da setup_attract
;3e6a  96 3e				; #3E96		; A == #01 	; draw the midway logo and copyright
			da draw_copyright
;3e6c  8b 3e				; #3E8B		; A == #02	; display "Ms. Pac Man"
			da disp_mspacman
;3e6e  0c 00				; #000C  	; A == #03	; returns immediately
			da :rts
;3e70  bd 3e				; #3EBD		; A == #04	; display "with"
			da disp_with
;3e72  9c 3e				; #3E9C		; A == #05	; display "Blinky"
			da disp_blinky
;3e74  83 34				; #3483		; A == #06	; move blinky across the marquee and up left side
			da move_blinky_marquee
;3e76  a2 3e				; #3EA2		; A == #07	; clear "with" and display "Pinky"
			da disp_pinky
;3e78  88 34				; #3488		; A == #08	; move pinky across the marquee and up left side
			da move_pinky_marquee
;3e7a  ab 3e				; #3EAB		; A == #09	; display "Inky"
			da disp_inky
;3e7c  8d 34				; #348D		; A == #0A	; move Inky across the marquee and up left side
			da move_inky_marquee
;3e7e  b1 3e				; #3EB1		; A == #0B	; display "Sue"
			da disp_sue
;3e80  92 34				; #3492		; A == #0C	; move Sue across the marquee and up left side
			da move_sue_marquee
;3e82  c3 3e 				; #3EC3		; A == #0D	; display "Starring"
			da disp_starring
;3e84  b7 3e 				; #3EB7		; A == #0E	; display "MS. Pac-Man"
			da disp_mspac2
;3e86  97 34				; #3497		; A == #0F	; move ms pacman across the marquee
			da move_mspac_marquee
;3e88  c9 3e   				; #3EC9		; A == #10	; start demo mode where ms. pac plays herself
			da start_mspac_demo

:rts		rts

; arrive here from #3E67 when sub# == 2
disp_mspacman mx %00
;3e8b  ef        rst     #28		; insert task to display text "MS Pac Man"
;3e8c  1c 0c				; 
			lda #$0C1C
			jsr rst28

;3e8e  3e60      ld      a,#60		; A := #60
;3e90  32014f    ld      (#4f01),a	; store into stack ?
			lda #$60
			sta |marque_counter
;3e93  c38e05    jp      #058e		; jumps back, increases sub # and returns
			jmp ttask2

;------------------------------------------------------------------------------
; draw the midway logo and cprt for the attract screen
;3e96
draw_copyright mx %00
;3e96  cd4296    call    #9642		; draws title screen logo and text
			jsr draw_logo_text

;3e99  c38e05    jp      #058e
			jmp ttask2

;------------------------------------------------------------------------------
disp_blinky mx %00
;3e9c  ef        rst     #28		; insert task to display text "Blinky"
;3e9d  1c 0d				; 
			lda #$0D1C
			jsr rst28
;3e9f  c38e05    jp      #058e
			jmp ttask2

;------------------------------------------------------------------------------
disp_pinky mx %00
;3ea2  ef        rst     #28		; insert task to display text "       " [clears "with"]
;3ea3  1c 30				; 
			lda #$301C
			jsr rst28

;3ea4  ef        rst     #28		; insert task to display text "Pinky"
;3ea6  1c 0f				; 
			lda #$0F1C
			jsr rst28
;3ea8  c38e05    jp      #058e
			jmp ttask2

;------------------------------------------------------------------------------
disp_inky mx %00
;3eab  ef        rst     #28		; insert task to display text "Inky"
;3eac  1c 2f				; 
			lda #$2F1C
			jsr rst28
;3eae  c38e05    jp      #058e
			jmp ttask2
;------------------------------------------------------------------------------
disp_sue mx %00
;3eb1  ef        rst     #28		; insert task to display text "Sue"
;3eb2  1c 31				; 
			lda #$311C
			jsr rst28
;3eb4  c38e05    jp      #058e
			jmp ttask2

;------------------------------------------------------------------------------
disp_mspac2 mx %00
;3eb7  ef        rst     #28		; insert task to display text "Ms. Pac-Man"
;3eb8  1c 33				; 
			lda #$331C
			jsr rst28

;3eba  c38e05    jp      #058e
			jmp ttask2

;------------------------------------------------------------------------------
;3ebd
disp_with mx %00
;3ebd  ef        rst     #28		; insert task to display text "with"
;3ebe  1c 0e				; 
			lda #$0E1C
			jsr rst28
;3ebf  c38e05    jp      #058e
			jmp ttask2

;------------------------------------------------------------------------------
disp_starring mx %00
;3ec3  ef        rst     #28		; insert task to display text "starring"
;3ec4  1c 10				;
			lda #$101C
			jsr rst28
;3ec6  c38e05    jp      #058e
			jmp ttask2

;------------------------------------------------------------------------------
; demo mode when ms pac plays herself in the maze
;3ec9
start_mspac_demo mx %00
;3ec9  af        xor     a		; A := #00
;3eca  32144e    ld      (#4e14),a	; store into number of lives
			stz |num_lives
;3ecd  c37c05    jp      #057c		; jump back
			jmp start_mspac2_demo

;------------------------------------------------------------------------------
; this sub controls the flashing bulbs around the marquee in the attract screen
;3ed0
marque_flash mx %00
;3ed0  3a014f    ld      a,(#4f01)	; load A with counter
			lda |marque_counter
;3ed3  3c        inc     a		; increase
			inc
;3ed4  e60f      and     #0f		; mask bits, now between #00 and #0F
			and #$0F
;3ed6  32014f    ld      (#4f01),a	; store result
			sta |marque_counter

;3ed9  4f        ld      c,a		; copy to C
;3eda  cb81      res     0,c		; reset bit #0 on C
;3edc  0600      ld      b,#00		; B:= #00
;3ede  dd21813f  ld      ix,#3f81	; load IX with start of table data
			ldx #:mtable
			bit #1
;3ee2  cb47      bit     0,a		; test bit 0 of A
			beq :colors
;3ee4  2833      jr      z,#3f19    ; if zero then jump ahead to do other part of routine
			and #$FFFE
			clc
			adc #:mtable
;3ee6  dd09      add     ix,bc		; add counter to index of table data
			tax

			sep #$20

;3ee8  dd6e00    ld      l,(ix+#00)
;3eeb  dd6601    ld      h,(ix+#01)
			ldy |0,x
;3eee  3687      ld      (hl),#87	; moves white spot by one
			lda #$87
			sta |0,y
;3ef0  dd6e10    ld      l,(ix+#10)
;3ef3  dd6611    ld      h,(ix+#11)
			ldy |$10,x
;3ef6  3687      ld      (hl),#87	; moves white spot by one
			sta |0,y
;3ef8  dd6e20    ld      l,(ix+#20)
;3efb  dd6621    ld      h,(ix+#21)
			ldy |$20,x
;3efe  368a      ld      (hl),#8a	; moves white spot by one	
			lda #$8a
			sta |0,y
;3f00  dd6e30    ld      l,(ix+#30)
;3f03  dd6631    ld      h,(ix+#31)
			ldy |$30,x
;3f06  3681      ld      (hl),#81	; moves white spot by one
			lda #$81
			sta |0,y
;3f08  dd6e40    ld      l,(ix+#40)
;3f0b  dd6641    ld      h,(ix+#41)
			ldy |$40,x
;3f0e  3681      ld      (hl),#81	; moves white spot by one
			sta |0,y
;3f10  dd6e50    ld      l,(ix+#50)
;3f13  dd6651    ld      h,(ix+#51)
			ldy |$50,x
;3f16  3684      ld      (hl),#84	; moves white spot by one
			lda #$84
			sta |0,y
			rep #$20
;3f18  c9        ret     		; return
			rts
:colors
;3f19  0d        dec     c		; decrement C
			dec
;3f1a  af        xor     a		; A := #00
;3f1b  b9        cp      c		; compare
;			bmi :neg
;3f1c  fa213f    jp      m,#3f21		; if negative, skip next step
;3f1f  06ff      ld      b,#ff		; load B with #FF

;3f21  0d        dec     c		; decrement C
			dec
;3f22  dd09      add     ix,bc		; add to index of table data
			clc
			adc #:mtable
			tay

			sep #$20
;3f24  dd6e00    ld      l,(ix+#00)
;3f27  dd6601    ld      h,(ix+#01)
			ldx |0,y
;3f2a  35        dec     (hl)		; color marquee spot red
			dec |0,x
;3f2b  dd6e02    ld      l,(ix+#02)
;3f2e  dd6603    ld      h,(ix+#03)
			ldx |2,y
;3f31  3688      ld      (hl),#88	; color next spot white
			lda #$88
			sta |0,x
;3f33  dd6e10    ld      l,(ix+#10)
;3f36  dd6611    ld      h,(ix+#11)
			ldx |$10,y
;3f39  35        dec     (hl)		; color marquee spot red
			dec |0,x
;3f3a  dd6e12    ld      l,(ix+#12)
;3f3d  dd6613    ld      h,(ix+#13)
			ldx |$12,y
;3f40  3688      ld      (hl),#88	; color next spot white
			lda #$88
			sta |0,x
;3f42  dd6e20    ld      l,(ix+#20)
;3f45  dd6621    ld      h,(ix+#21)
			ldx |$20,y
;3f48  35        dec     (hl)		; color marquee spot red
			dec |0,x
;3f49  dd6e22    ld      l,(ix+#22)
;3f4c  dd6623    ld      h,(ix+#23)
			ldx |$22,y
;3f4f  368b      ld      (hl),#8b	; color next spot white
			lda #$8b
			sta |0,x
;3f51  dd6e30    ld      l,(ix+#30)
;3f54  dd6631    ld      h,(ix+#31)
			ldx |$30,y
;3f57  35        dec     (hl)		; color marquee spot red
			dec |0,x
;3f58  dd6e32    ld      l,(ix+#32)
;3f5b  dd6633    ld      h,(ix+#33)
			ldx |$32,y
;3f5e  3682      ld      (hl),#82	; color next spot white
			lda #$82
			sta |0,x
;3f60  dd6e40    ld      l,(ix+#40)
;3f63  dd6641    ld      h,(ix+#41)
			ldx |$40,y
;3f66  35        dec     (hl)		; color marquee spot red
			dec |0,x
;3f67  dd6e42    ld      l,(ix+#42)
;3f6a  dd6643    ld      h,(ix+#43)
			ldx |$42,y
;3f6d  3682      ld      (hl),#82	; color next spot white
			lda #$82
			sta |0,x
;3f6f  dd6e50    ld      l,(ix+#50)
;3f72  dd6651    ld      h,(ix+#51)
			ldx |$50,y
;3f75  35        dec     (hl)		; color marquee spot red
			dec |0,x
;3f76  dd6e52    ld      l,(ix+#52)
;3f79  dd6653    ld      h,(ix+#53)
			ldx |$52,y
;3f7c  3683      ld      (hl),#83	; BUG.  Spot stays red.  SHOULD BE #85, not #83, to color spot white
; BUGFIX04 - Marquee left side animation fix - Don Hodges
;3f7c 36 85
			lda #$85
			sta |0,x
			rep #$20
;3f7e  c9        ret     		; return
			rts

; data Used above in #3EDE, for the flashing marquee
;3F7F:
		da tile_ram+$2D0
:mtable
;3F81:  B0 42 90 42 70 42 50 42 30 42 10 42 F0 41
		da tile_ram+$2B0,tile_ram+$290,tile_ram+$270,tile_ram+$250
		da tile_ram+$230,tile_ram+$210,tile_ram+$1F0
;3F8F:  D0 41 B0 41 90 41 70 41 50 41 30 41 10 41 F0 40
		da tile_ram+$1D0,tile_ram+$1B0,tile_ram+$190,tile_ram+$170
		da tile_ram+$150,tile_ram+$130,tile_ram+$110,tile_ram+$0F0
;3F9F:  D0 40 B0 40 AF 40 AE 40 AD 40 AC 40 AB 40 AA 40
		da tile_ram+$0D0,tile_ram+$0B0,tile_ram+$0AF,tile_ram+$0AE
		da tile_ram+$0AD,tile_ram+$0AC,tile_ram+$0AB,tile_ram+$0AA
;3FAF:  A9 40 C9 40 E9 40 09 41 29 41 49 41 69 41 89 41
		da tile_ram+$0A9,tile_ram+$0C9,tile_ram+$0E9,tile_ram+$109
		da tile_ram+$129,tile_ram+$149,tile_ram+$169,tile_ram+$189
;3FBF:  A9 41 C9 41 E9 41 09 42 29 42 49 42 69 42 89 42
		da tile_ram+$1A9,tile_ram+$1C9,tile_ram+$1E9,tile_ram+$209
		da tile_ram+$229,tile_ram+$249,tile_ram+$269,tile_ram+$289
;3FCF:  A9 42 C9 42 CA 42 CB 42 CC 42 CD 42 CE 42 CF 42
		da tile_ram+$2A9,tile_ram+$2C9,tile_ram+$2CA,tile_ram+$2CB
		da tile_ram+$2CC,tile_ram+$2CD,tile_ram+$2CE,tile_ram+$2CF
;3FDF:  D0 42
		da tile_ram+$2D0

; unused ?

;3FE1:     C9 42 CA 42 CB 42 CC 42 CD 42 CE 42 CF 42
		da tile_ram+$2C9,tile_ram+$2CA,tile_ram+$2CB,tile_ram+$2CC
		da tile_ram+$2CD,tile_ram+$2CE,tile_ram+$2CF
;3FEF:  D0 42 42 CF 42 D0 42 00 4F C9 00
		da tile_ram+$2D0

;------------------------------------------------------------------------------

; lookup table.  used in #361F for sprite movement
; these contain pointers to the step program/codes to be run
cutscenes_table
;81f0  51 82	; #8251		; 1st intermission
;81f2  a3 82	; #82A3
;81f4  12 83	; #8312
;81f6  4c 83	; #834C
;81f8  69 85	; #8569
;81fa  7c 85	; #857C
			da act1_part1
			da act1_part2
			da act1_part3
			da act1_part4
			da act1_part5
			da act1_part6

;81fc  95 83	; #8395		; 2nd intermission
;81fe  f0 83	; #83F0
;8200  2b 85	; #852B
;8202  4a 85	; #854A
;8204  69 85	; #8569
;8206  7c 85	; #857C

			da act2_part1
			da act2_part2
			da act2_part3
			da act2_part4
			da act2_part5
			da act2_part6

;8208  51 84	; #8451		; 3rd intermission
;820a  6d 84	; #846D
;820c  cf 84	; #84CF
;820e  fd 84 	; #84FD
;8210  89 84	; #8489
;8212  7c 85	; #857C

			da act3_part1
			da act3_part2
			da act3_part3
			da act3_part4
			da act3_part5
			da act3_part6

;8214  94 85	; #8594		; attract mode 1st ghost
;8216  50 82	; #8250
;8218  50 82	; #8250
;821a  50 82	; #8250
;821c  50 82	; #8250
;821e  50 82	; #8250
			da attr_ghost1_1
			da nodata
			da nodata
			da nodata
			da nodata
			da nodata

;8220  50 82	; #8250		; attract mode 2nd ghost
;8222  b0 85	; #85B0
;8224  50 82	; #8250
;8226  50 82	; #8250
;8228  50 82	; #8250
;822a  50 82	; #8250
			da nodata
			da attr_ghost2_2
			da nodata
			da nodata
			da nodata
			da nodata

;822c  50 82	; #8250		; attract mode 3rd ghost
;822e  50 82	; #8250
;8230  cc 85	; #85CC
;8232  50 82	; #8250
;8234  50 82	; #8250
;8236  50 82	; #8250

			da nodata
			da nodata
			da attr_ghost3_3
			da nodata
			da nodata
			da nodata

;8238  50 82	; #8250		; attract mode 4th ghost
;823a  50 82	; #8250
;823c  50 82	; #8250
;823e  e8 85	; #85E8
;8240  50 82	; #8250
;8242  50 82	; #8250

			da nodata
			da nodata
			da nodata
			da attr_ghost4_4
			da nodata
			da nodata

;8244  50 82	; #8250		; attract mode ms pac man
;8246  50 82	; #8250
;8248  50 82	; #8250
;824a  50 82	; #8250
;824c  04 86	; #8604
;824e  50 82	; #8250

			da nodata
			da nodata
			da nodata
			da nodata
			da attr_mspac_5
			da nodata

nodata
;8250  ff       	; no data
			db END


; commands: (functionality TBD)
;	cmd	    opc 	bytes	param fcn	opc fcn
;	LOOP      =  F0	; 	3	?		repeat this N times, perhaps?
;							A B (color)
;	SETPOS	  =  F1	; 	2	position?	
;	SETN  	  =  F2	; 	1	value		store for other ops
;	SETCHAR   =  F3	; 	2	table ptr	switch to the specified sprite code table?
;	-         =  F4
;	PLAYSOUND =  F5	;	1	sound code	play a sound (eg 10=ghost bump)
;	PAUSE     =  F6	;	-	-		pause for N ticks?
;	SHOWACT   =  F7	;	
;	CLEARACT  =  F8	; 	-	-		clear the act # from the screen
;	END       =  FF

; this appears to work like,  (guesses here)
;	setchar ADDR	to select the caracter array to work with
;	setpos X Y	moves the sprite to that location instantly
;	loop A B C	moves the sprite to a,b, while using color C
;			for previous SETN units/speed
;	PAUSE		wait for SETN units/time

LOOP      equ $F0
SETPOS    equ $F1
SETN      equ $F2
SETCHAR   equ $F3
PLAYSOUND equ $F5
PAUSE     equ $F6
SHOWACT   equ $F7
CLEARACT  equ $F8
END       equ $FF

	

; data for 1st intermission, part 1
act1_part1
;8251:  F1 00 00 		; SETPOS	00 00	
			db SETPOS,$00,$00
; set character set 8675 (act sign)
;8254:  F3 75 86			; SETCHAR	#8675	; ACT sign
			db SETCHAR
			da act_sign1
;8257:  F2 01 			; SETN		01
;8259:  F0 00 00 		; LOOP		00 00
			db SETN,$01,LOOP,$00,$00,$16  ;!! 825C is missing from the dump!!
;825D:  F1 BD 52			; SETPOS	BD 52
			db SETPOS,$BD,$52
;8260:  F2 28			; SETN		28
;8262:  F6			; PAUSE
			db SETN,$28,PAUSE
;8263:  F2 16			; SETN		16
;8265:  F0 00 00 16		; LOOP		00 00 16
			db SETN,$16,LOOP,$00,$00,$16
	;       ^^ color 16 (white)
;8269:  F2 16			; SETN		16
;826B:  F6			; PAUSE
			db SETN,$16,PAUSE
;826C:  F1 FF 54			; SETPOS	FF 54
			db SETPOS,$FF,$54

;826F:  F3 14 86			; SETCHAR	#8614	  ; otto
			db SETCHAR
			da msp_walk_right 
;8272:  F2 7F			; SETN		7F
;8274:  F0 F0 00 09		; LOOP		F0 00 09  ; otto
			db SETN,$7F,LOOP,$F0,$00,$09
	;       ^^ color 9 (yellow otto)
;8278:  F2 7F			; SETN		7F
;827A:  F0 F0 00 09		; LOOP		F0 00 09  ; otto
			db SETN,$7F,LOOP,$F0,$00,$09
;827E:  F1 00 7F			; SETPOS	00 7F
			db SETPOS,$00,$7F

;8281:  F3 1D 86			; SETCHAR	#861D	  ; otto to center
			db SETCHAR
			da msp_walk_left
;8284:  F2 75			; SETN		75
;8286:  F0 10 00 09		; LOOP		10 00 09
			db SETN,$75,LOOP,$10,$00,$09
;828A:  F2 04			; SETN		04
;828C:  F0 10 F0 09		; LOOP		10 F0 09
			db SETN,$04,LOOP,$10,$F0,$09
;8290:  F3 26 86		; SETCHAR	#8626
			db SETCHAR
			da walk_up
;8293:  F2 30			; SETN		30
;8295:  F0 00 F0 09		; LOOP		00 F0 09
			db SETN,$30,LOOP,$00,$F0,$09
;8299:  F3 1D 86			; SETCHAR	#861D
			db SETCHAR
			da msp_walk_left
;829C:  F2 10			; SETN		10
;829E:  F0 00 00 09		; LOOP		00 00 09
			db SETN,$10,LOOP,$00,$00,$09
;82A2:  FF			; END 
			db END

; data for 1st intermission, part 2

act1_part2
;82A3:  F1 00 00
			db SETPOS,$00,$00

;82A6:  F3 7F 86			; #867F
			db SETCHAR
			da act_sign2
;82A9:  F2 01
;82AB:  F0 00 00 16		; ACT sign
			db SETN,$01,LOOP,$00,$00,$16
;82AF:  F1 AD 52
			db SETPOS,$AD,$52
;82B2:  F2 28
;82B4:  F6
			db SETN,$28,PAUSE
;82B5:  F2 16
;82B7:  F0 00 00 16		; ACT sign
			db SETN,$16,LOOP,$00,$00,$16
;82BB:  F2 16
;82BD:  F6
			db SETN,$16,PAUSE
;82BE:  F1 FF 54 
			db SETPOS,$FF,$54
;82C1:  F3 5C 86			; #865C
			db SETCHAR
			da geyes_right

;82C4:  F2 2F
;82C6:  F6
			db SETN,$2F,PAUSE

;82C7:  F2 70 
;82C9:  F0 EF 00 05		; cyan ghost
			db SETN,$70,LOOP,$EF,$00,$05

;82CD:  F2 74
;82CF:  F0 EC 00 05 		; cyan ghost
			db SETN,$74,LOOP,$EC,$00,$05

;82D3:  F1 00 7F 
			db SETPOS,$00,$7F

;82D6:  F3 63 86 		; #8663
			db SETCHAR
			da geyes_left

;82D9:  F2 1C
;82DB:  F6
			db SETN,$1C,PAUSE

;82DC:  F2 58
;82DE:  F0 16 00 05
			db SETN,$58,LOOP,$16,$00,$05

;82E2:  F5 10			; sound for ghost bump
			db PLAYSOUND,$10

;82E4:  F2 06
;82E6:  F0 F8 F8 05
			db SETN,$06,LOOP,$F8,$F8,$05

;82EA:  F2 06
;82EC:  F0 F8 08 05
			db SETN,$06,LOOP,$F8,$08,$05

;82F0:  F2 06
;82F2:  F0 F8 F8 05
			db SETN,$06,LOOP,$F8,$F8,$05

;82F6:  F2 06
;82F8:  F0 F8 08 05
			db SETN,$06,LOOP,$F8,$08,$05

;82FC:  F1 00 00
			db SETPOS,$00,$00
;82FF:  F3 73 86			; #8673
			db SETCHAR
			da heart

;8302:  F2 01
;8304:  F0 00 00 03
			db SETN,$01,LOOP,$00,$00,$03
;8308:  F1 7F 3A
			db SETPOS,$7F,$3A

;830B:  F2 40
;830D:  F0 00 00 03
			db SETN,$40,LOOP,$00,$00,$03

;8311:  FF			; end code
			db END

; data for 1st intermission, part 3
act1_part3
;8312:  F2 5A 
;8314:  F6
			db SETN,$5A,PAUSE

;8315:  F1 00 A4
			db SETPOS,$00,$A4

;8318:  F3 41 86			; #8641	 left anna
			db SETCHAR
			da left_anna

;831B:  F2 7F 
;831D:  F0 10 00 09 
			db SETN,$7F,LOOP,$10,$00,$09

;8321:  F2 7F
;8323:  F0 10 00 09
			db SETN,$7F,LOOP,$10,$00,$09

;8327:  F1 FF 7F
			db SETPOS,$FF,$7F

;832A:  F3 38 86 		; #8638	; right anna
			db SETCHAR
			da right_anna

;832D:  F2 76
;832F:  F0 F0 00 09
			db SETN,$76,LOOP,$F0,$00,$09

;8333:  F2 04
;8335:  F0 F0 F0 09
			db SETN,$04,LOOP,$F0,$F0,$09

;8339:  F3 4A 86			; #864a ; up anna (?)
			db SETCHAR
			da up_anna

;833C:  F2 30
;833E:  F0 00 F0 09
			db SETN,$30,LOOP,$00,$F0,$09

;8342:  F3 38 86			; #8638	; stopped anna
			db SETCHAR
			da right_anna

;8345:  F2 10
;8347:  F0 00 00 09
			db SETN,$10,LOOP,$00,$00,$09

;834B:  FF			; end code
			db END

; data for 1st intermission, part 4
act1_part4
;834C:  F2 5F
;834E:  F6
			db SETN,$5F,PAUSE

;834F:  F1 01 A4
			db SETPOS,$01,$A4

;8352:  F3 63 86			; #8663
			db SETCHAR
			da geyes_left

;8355:  F2 2F
;8357:  F6
			db SETN,$2F,PAUSE

;8358:  F2 70
;835A:  F0 11 00 03
			db SETN,$70,LOOP,$11,$00,$03

;835E:  F2 74
;8360:  F0 14 00 03
			db SETN,$74,LOOP,$14,$00,$03

;8364:  F1 FF 7F
			db SETPOS,$FF,$7F

;8367:  F3 5C 86			; #865C
			db SETCHAR
			da geyes_right

;836A:  F2 1C
;836C:  F6
			db SETN,$1C,PAUSE

;836D:  F2 58
;836F:  F0 EA 00 03
			db SETN,$58,LOOP,$EA,$00,$03

;8373:  F2 06
;8375:  F0 08 F8 03
			db SETN,$06,LOOP,$08,$F8,$03

;8379:  F2 06 
;837B:  F0 08 08 03
			db SETN,$06,LOOP,$08,$08,$03

;837F:  F2 06
;8381:  F0 08 F8 03
			db SETN,$06,LOOP,$08,$F8,$03

;8385:  F2 06 
;8387:  F0 08 08 03
			db SETN,$06,LOOP,$08,$08,$03

;838B:  F3 71 86			; #8671
			db SETCHAR
			da empty

;838E:  F2 10
;8390:  F0 00 00 16
			db SETN,$10,LOOP,$00,$00,$16

;8394:  FF			; end code
			db END


; CODE from CRAZY OTTO actual source: (Rosetta Stone) (tidied up)
; 2nd intermission data, part 1
;/*
;!    BYTE SETPOS,   0FFH,34H
;!    BYTE SETCHAR
;!    WORD           RIGHT_OTTO
;!    BYTE SETN,     7FH,PAUSE
;!    BYTE SETN,     24H,PAUSE
;!    BYTE SETN,     68H,LOOP,0D8H,00,09
;!    BYTE SETN,     7FH,PAUSE
;!    BYTE SETN,     18H,PAUSE
;!    BYTE SETPOS,   00H,094H
;!    BYTE SETCHAR
;!    WORD           LEFT_ANNA
;!    BYTE SETN,     68H,LOOP,028H,00,09
;!    BYTE SETN,     7FH,PAUSE
;!    BYTE SETPOS,   0FCH,7FH
;!    BYTE SETCHAR
;!    WORD           RIGHT_OTTO
;!    BYTE SETN,     18H,PAUSE
;!    BYTE SETN,     68H,LOOP,0D8H,0,09
;!    BYTE SETN,     7FH,PAUSE
;!    BYTE SETN,     18H,PAUSE
;!    BYTE SETPOS,   00H,054H
;!    BYTE SETCHAR
;!    WORD           LEFT_ANNA
;!    BYTE SETN,     20H,LOOP,070H,00,09
;!    BYTE SETPOS,   0FFH,0B4H
;!    BYTE SETCHAR
;!    WORD           RIGHT_OTTO
;!    BYTE SETN,     10H,PAUSE
;*/


; commands: (functionality TBD)
;	cmd	    opc 	bytes	param fcn	opc fcn
;	LOOP      =  F0	; 	3	?		repeat this N times, perhaps?
;	SETPOS	  =  F1	; 	2	position?	TBD
;	SETN  	  =  F2	; 	1	value		TBD
;	SETCHAR   =  F3	; 	2	table ptr	switch to the specified sprite code table?
;	-         =  F4
;	PLAYSOUND =  F5	;	1	sound code	play a sound (eg 10=ghost bump)
;	PAUSE     =  F6	;	-	-		pause for N ticks?
;	SHOWACT   =  F7	;	
;	CLEARACT  =  F8	; 	-	-		clear the act # from the screen
;	END       =  FF
	
; 2nd intermission data, part 1
;  NOTE: this is the segment that had the above source code published.
;	 That was a rosetta stone for figuring out the animation code system
;	 (work in progress)

	; this is for the pac being chased (red anna)
act2_part1
;8395:  F2 5A			; SETN( 5A )
;8397:  F6			; PAUSE
			db SETN,$5A,PAUSE
;8398:  F1 FF 34			; SETPOS, FF, 34
			db SETPOS,$FF,$34
;839B:  F3 14 86			; SETCHAR ( RIGHT_OTTO )  (sprite codes)
			db SETCHAR
			da msp_walk_right

;839E:  F2 7F			; SETN( 7f )
;83A0:  F6			; PAUSE
			db SETN,$7F,PAUSE

;83A1:  F2 24			; SETN( 24 )
;83A3:  F6			; PAUSE
			db SETN,$24,PAUSE

;83A4:  F2 68			; SETN( 60 )
;83A6:  F0 D8 00 09		; LOOP( d8, 00 09 )
			db SETN,$60,LOOP,$D8,$00,$09

;83AA:  F2 7F			; SETN( 7f )
;83AC:  F6			; PAUSE
			db SETN,$7F,PAUSE

;83AD:  F2 18			; SETN( 18 )
;83AF:  F6			; PAUSE
			db SETN,$18,PAUSE

;83B0:  F1 00 94 		; SETCHAR( LEFT_ANNA )
			db SETPOS,$00,$94

;83B3:  F3 41 86			; SETN( 
			db SETCHAR
			da left_anna

;83B6:  F2 68			; SETN(
;83B8:  F0 28 00 09		; LOOP( 28 00 09 )
			db SETN,$68,LOOP,$28,$00,$09

;83BC:  F2 7F			; SETN( 7f )
;83BE:  F6			; PAUSE
			db SETN,$7F,PAUSE

;83BF:  F1 FC 7F			; SETPOS( fc, 7f )
			db SETPOS,$FC,$7F

;83C2:  F3 14 86			; SETCHAR( RIGHT_OTTO )
			db SETCHAR
			da msp_walk_right

;83C5:  F2 18			; SETN( 18 )
;83C7:  F6			; PAUSE
			db SETN,$18,PAUSE

;83C8:  F2 68			; SETN( 68 )
;83CA:  F0 D8 00 09		; LOOP ( d8, 0, 09 )
			db SETN,$68,LOOP,$D8,$00,$09

;83CE:  F2 7F			; SETN( 7f ) 
;83D0:  F6			; PAUSE
			db SETN,$7F,PAUSE

;83D1:  F2 18			; SETN( 18 )
;83D3:  F6			; PAUSE
			db SETN,$18,PAUSE

;83D4:  F1 00 54			; SETPOS( 00 54 ) 
			db SETPOS,$00,$54

;83D7:  F3 41 86			; SETCHAR( LEFT_ANNA )
			db SETCHAR
			da left_anna

;83DA:  F2 20			; SETN( 20 )
;83DC:  F0 70 00 09		; LOOP
			db SETN,$20,LOOP,$70,$00,$09

;83E0:  F1 FF B4			; SETPOS( ff, 04 )
			db SETPOS,$FF,$04

;83E3:  F3 14 86			; SETCHAR( RIGHT_OTTO )
			db SETCHAR
			da msp_walk_right

;83E6:  F2 10			; SETN( 10 )
;83E8:  F6			; PAUSE
			db SETN,$10,PAUSE

;83E9:  F2 24			; SETN( 24 )
;	  SPEED?
;83EB:  F0 90 00 09		; LOOP( 90 0 09)
;          XX YY CC
			db SETN,$24,LOOP,$90,$00,$09
;83EF:  FF			; end code
			db END


; data for 2nd intermission, part 2

act2_part2
;83F0:  F2 63
;83F2:  F6
			db SETN,$63,PAUSE

;83F3:  F1 FF 34
			db SETPOS,$FF,$34

;83F6:  F3 38 86			; #8638
			db SETCHAR
			da right_anna

;83F9:  F2 24
;83FB:  F6
			db SETN,$24,PAUSE

;83FC:  F2 7F
;83FE:  F6
			db SETN,$7F,PAUSE

;83FF:  F2 18
;8401:  F6
			db SETN,$18,PAUSE

;8402:  F2 57
;8404:  F0 D0 00 09
			db SETN,$57,LOOP,$D0,$00,$09

;8408:  F2 7F
;840A:  F6
			db SETN,$7F,PAUSE

;840B:  F2 28
;840D:  F6
			db SETN,$28,PAUSE

;840E:  F1 00 94
			db SETPOS,$00,$94

;8411:  F3 1D 86			; #861D 8414:  F2 58
			db SETCHAR
			da msp_walk_left

;8416:  F0 30 00 09
			db LOOP,$30,$00,$09

;841A:  F2 7F
;841C:  F6
			db SETN,$7F,PAUSE

;841D:  F2 24
;841F:  F6
			db SETN,$24,PAUSE

;8420:  F1 FF 7F
			db SETPOS,$FF,$7F

;8423:  F3 38 86			; #8638
			db SETCHAR
			da right_anna

;8426:  F2 58
;8428:  F0 D0 00 09
			db SETN,$58,LOOP,$D0,$00,$09

;842C:  F2 7F
;842E:  F6
			db SETN,$7F,PAUSE

;842F:  F2 20
;8431:  F6
			db SETN,$20,PAUSE

;8432:  F1 00 54
			db SETPOS,$00,$54

;8435:  F3 1D 86			; #861D
			db SETCHAR
			da msp_walk_left

;8438:  F2 20
;843A:  F0 70 00 09
			db SETN,$20,LOOP,$70,$00,$09

;843E:  F1 FF B4
			db SETPOS,$FF,$B4

;8441:  F3 38 86			; #8638
			db SETCHAR
			da right_anna

;8444:  F2 10
;8446:  F6
			db SETN,$10,PAUSE

;8447:  F2 24
;8449:  F0 90 00 09
			db SETN,$24,LOOP,$90,$00,$09

;844D:  F2 7F
;844F:  F6
			db SETN,$7F,PAUSE

;8450:  FF 			; end code
			db END


; 3rd intermission data part 1
act3_part1

;8451:  F2 5A
;8453:  F6
			db SETN,$5A,PAUSE

;8454:  F1 00 60
			db SETPOS,$00,$60

;8457:  F3 8D 86			; #868D front of stork
			db SETCHAR
			da stork_front
;845A:  F2 7F
;845C:  F0 0A 00 16
			db SETN,$7F,LOOP,$0A,$00,$16

;8460:  F2 7F
;8462:  F0 10 00 16
			db SETN,$7f,LOOP,$10,$00,$16

;8466:  F2 30
;8468:  F0 10 00 16
			db SETN,$30,LOOP,$10,$00,$16
;846C:  FF			; end code
			db END

; 3rd intermission data part 2
act3_part2

;846D:  F2 6F
;846F:  F6
			db SETN,$6f,PAUSE

;8470:  F1 00 60
			db SETPOS,$00,$60

;8473:  F3 8F 86			; #868F flap stork
			db SETCHAR
			da flap_stork

;8476:  F2 6A
;8478:  F0 0A 00 16
			db SETN,$6A,LOOP,$0A,$00,$16

;847C:  F2 7F
;847E:  F0 10
;8480:  00 16
			db SETN,$7F,LOOP,$10,$00,$16

;8482:  F2 3A
;8484:  F0 10 00 16
			db SETN,$3A,LOOP,$10,$00,$16

;8488:  FF 			; end code
			db END


; 3rd intermission data part 5
; sack fall, baby appears

act3_part5

;8489:  F3 89 86			; #8689 act
		db SETCHAR
		da act_sign3

;848C:  F2 01
;848E:  F0 00 00 16
		db SETN,$01,LOOP,$00,$00,$16

;8492:  F1 BD 62
		db SETPOS,$BD,$62

;8495:  F2 5A
;8497:  F6
		db SETN,$5A,PAUSE

;8498:  F1 05 60
		db SETPOS,$05,$60

;849B:  F3 98 86			; #8698 sack
		db SETCHAR
		da stork_sack

;849E:  F2 7F
;84A0:  F0 0A 00 16		; color 16 makes the sack blue

		db SETN,$7F,LOOP,$0A,$00,$16

;84A4:  F2 7F
;84A6:  F0 06 0C 16		; this here is the bounce
		db SETN,$7F,LOOP,$06,$0C,$16

;84AA:  F2 06
;84AC:  F0 06 F0 16
		db SETN,$06,LOOP,$06,$F0,$16

;84B0:  F2 0C
;84B2:  F0 03 09 16
		db SETN,$0C,LOOP,$03,$09,$16

;84B6:  F2 05
;84B8:  F0 05 F6 16		; final parameter is COLOR
		db SETN,$05,LOOP,$05,$F6,$16

;84BC:  F2 0A
;84BE:  F0 04 03 16
		db SETN,$0A,LOOP,$04,$03,$16

;84C2:  F3 9A 86			; #869A baby
		db SETCHAR
		da pacjr

;84C5:  F2 01
;84C7:  F0 00 00 16		; change baby color here
		db SETN,$01,LOOP,$00,$00,$16

;84CB:  F2 20
;84CD:  F6
		db SETN,$20,PAUSE

;84CE:  FF 			; end code
		db END


; 3rd intermission data part 3
act3_part3

;84CF:  F1 00 00
		db SETPOS,$00,$00

;84D2:  F3 75 86			; #8675
		db SETCHAR
		da act_sign1

;84D5:  F2 01
;84D7:  F0 00 00 16		; ACT 
		db SETN,$01
		db LOOP,$00,$00,$16

;84DB:  F1 BD 52
		db SETPOS,$BD,$52

;84DE:  F2 28
;84E0:  F6
		db SETN,$28,PAUSE

;84E1:  F2 16 
;84E3:  F0 00 00 16
		db SETN,$16,LOOP,$00,$00,$16

;84E7:  F2 16
;84E9:  F6
		db SETN,$16,PAUSE

;84EA:  F1 00 00 
		db SETPOS,$00,$00

;84ED:  F3 38 86			; #8638
		db SETCHAR
		da right_anna

;84F0:  F2 01 
;84F2:  F0 00 00 09		; pac in front, closest to baby
		db SETN,$01,LOOP,$00,$00,$09

;84F6:  F1 C0 C0
		db SETPOS,$C0,$C0

;84F9:  F2 30
;84FB:  F6
		db SETN,$30,PAUSE

;84FC:  FF 			; end code
		db END


; 3rd intermission data part 4
act3_part4
;84FD:  F1 00 00
			db SETPOS,0,0

;8500:  F3 7F 86			; #867F
			db SETCHAR
			da act_sign2

;8503:  F2 01
;8505:  F0 00 00 16
			db SETN,$01,LOOP,$00,$00,$16

;8509:  F1 AD 52
			db SETPOS,$AD,$52

;850C:  F2 28
;850E:  F6
			db SETN,$28,PAUSE

;850F:  F2 16
;8511:  F0 00 00 16
			db SETN,$16,LOOP,$00,$00,$16

;8515:  F2 16
;8517:  F6
			db SETN,$16,PAUSE

;8518:  F1 00 00
			db SETPOS,$00,$00

;851B:  F3 14 86			; #8614
			db SETCHAR
			da msp_walk_right

;851E:  F2 01
;8520:  F0 00 00 09		; pac behind, (red)
			db SETN,$01,LOOP,$00,$00,$09

;8524:  F1 D0 C0
			db SETPOS,$D0,$C0

;8527:  F2 30
;8529:  F6
			db SETN,$30,PAUSE

;852A:  FF			; end code
			db END

; data for 2nd intermission, part 3
act2_part3

;852B:  F1 00 00
			db SETPOS,$00,$00

;852E:  F3 75 86			; #8675
			db SETCHAR
			da act_sign1

;8531:  F2 01
;8533:  F0 00 00 16
			db SETN,$01,LOOP,$00,$00,$16

;8537:  F1 BD 52
			db SETPOS,$BD,$52

;853A:  F2 28
;853C:  F6
			db SETN,$28,PAUSE

;853D:  F2 16
;853F:  F0 00 00 16
			db SETN,$16,LOOP,$00,$00,$16

;8543:  F2 16
;8545:  F6
			db SETN,$16,PAUSE

;8546:  F1 00 00
			db SETPOS,0,0

;8549:  FF			; end code
			db END


; data for 2nd intermission, part 4
act2_part4
;854A:  F1 00 00
			db SETPOS,0,0
;854D:  F3 7F 86			; #867F
			db SETCHAR
			da act_sign2

;8550:  F2 01
;8552:  F0 00 00 16
			db SETN,$01,LOOP,$00,$00,$16

;8556:  F1 AD 52
			db SETPOS,$AD,$52

;8559:  F2 28
;855B:  F6
			db SETN,$28,PAUSE

;855C:  F2 16
;855E:  F0 00 00 16
			db SETN,$16,LOOP,$00,$00,$16

;8562:  F2 16 
;8564:  F6
			db SETN,$16,PAUSE

;8565:  F1 00 00
			db SETPOS,0,0

;8568:  FF			; end code
			db END


; data for 1st, 2nd intermission, part 5
act1_part5
act2_part5
;8569:  F3 89 86			; #8689
			db SETCHAR
			da act_sign3

;856C:  F2 01
;856E:  F0 00 00 16
			db SETN,$01,LOOP,$00,$00,$16

;8572:  F1 BD 62
			db SETPOS,$BD,$62

;8575:  F2 5A
;8577:  F6
			db SETN,$5A,PAUSE

;8578:  F1 00 00
			db SETPOS,0,0

;857B:  FF			; end code
			db END


; data for 1st, 2nd, 3rd intermission, part 6
act1_part6
act2_part6
act3_part6

;857C:  F3 8B 86			; #868B
			db SETCHAR
			da act_sign4

;857F:  F2 01
;8581:  F0 00 00 16
			db SETN,$01,LOOP,$00,$00,$16

;8585:  F1 AD 62
			db SETPOS,$AD,$62

;8588:  F2 39			
;858A:  F6			; pause
			db SETN,$39,PAUSE

;858B:  F7			; display text
			db SHOWACT

;858C:  F2 1E
;858E:  F6
			db SETN,$1E,PAUSE

;858F:  F8			; clear act number
			db CLEARACT

;8590:  F1 00 00
			db SETPOS,0,0

;8593:  FF			; end code
			db END

; data for attract mode 1st ghost

attr_ghost1_1

;8594:  F1 00 94
			db SETPOS,$00,$94

;8597:  F3 63 86			; #8663
			db SETCHAR
			da geyes_left

;859A:  F2 70
;859C:  F0 10 00 01
			db SETN,$70,LOOP,$10,$00,$01

;85A0:  F2 50 
;85A2:  F0 10 00 01
			db SETN,$50,LOOP,$10,$00,$01

;85A6:  F3 6A 86			; #866A
			db SETCHAR
			da geyes_up

;85A9:  F2 48
;85AB:  F0 00
;85AD:  F0 01
			db SETN,$48,LOOP,$00,$F0,$01

;85AF:  FF			; end code
			db END


; data for attract mode 2nd ghost

attr_ghost2_2
;85B0:  F1 00 94
			db SETPOS,$00,$94

;85B3:  F3 63 86			; #8663
			db SETCHAR
			da geyes_left

;85B6:  F2 70 
;85B8:  F0 10 00 03 
			db SETN,$70,LOOP,$10,$00,$03

;85BC:  F2 50
;85BE:  F0 10 00 03 
			db SETN,$50,LOOP,$10,$00,$03

;85C2:  F3 6A 86			; #866A
			db SETCHAR
			da geyes_up

;85C5:  F2 38 
;85C7:  F0 00
;85C9:  F0 03
			db SETN,$38,LOOP,$00,$F0,$03

;85CB:  FF			; end code
			db END


; data for attract mode 3rd ghost
attr_ghost3_3
;85CC:  F1 00 94
			db SETPOS,$00,$94

;85CF:  F3 63 86			; #8663
			db SETCHAR
			da geyes_left

;85D2:  F2 70
;85D4:  F0 10 00 05 
			db SETN,$70,LOOP,$10,$00,$05

;85D8:  F2 50
;85DA:  F0 10 00 05
			db SETN,$50,LOOP,$10,$00,$05

;85DE:  F3 6A 86			; #866A
			db SETCHAR
			da geyes_up

;85E1:  F2 28 
;85E3:  F0 00
;85E5:  F0 05
			db SETN,$28,LOOP,$00,$F0,$05

;85E7:  FF 			; end code
			db END


; data for attract mode 4th ghost
attr_ghost4_4
;85E8:  F1 00 94
			db SETPOS,$00,$94
;85EB:  F3 63 86			; #8663
			db SETCHAR
			da geyes_left

;85EE:  F2 70
;85F0:  F0 10 00 07
			db SETN,$70,LOOP,$10,$00,$07

;85F4:  F2 50
;85F6:  F0 10 00 07
			db SETN,$50,LOOP,$10,$00,$07

;85FA:  F3 6A 86			; #866A
			db SETCHAR
			da geyes_up

;85FD:  F2 18
;85FF:  F0 00
;8601:  F0 07
			db SETN,$18,LOOP,$00,$F0,$07

;8603:  FF 			; end code
			db END

; data for attract mode ms. pac-man

attr_mspac_5

;8604:  F1 00 94
			db SETPOS,$00,$94

;8607:  F3 41 86			; #8641
			db SETCHAR
			da left_anna

;860A:  F2 72
;850C:  F0 10 00 09
			db SETN,$72,LOOP,$10,$00,$09

;8610:  F2 7F F6
			db SETN,$7F,PAUSE

;8613:  FF			; end code
			db END

; used in act 1

; Pac:
;8614
msp_walk_right
		db $1B,$1B,$19,$19,$1B,$1B,$32,$32,$FF	; msp walking right
;861D
msp_walk_left
		db $9B,$9B,$99,$99,$9B,$9B,$B2,$B2,$FF	; msp walking left
;8626
walk_up
		db $6E,$6E,$5A,$5A,$6E,$6E,$72,$72,$FF	; walking up

;862F
pa_left
		db $EE,$EE,$DA,$DA,$EE,$EE,$F2,$F2,$FF	; left pa

;8638
;      r  r  R  R  u  u  rc rc
right_anna
		db $37,$37,$2D,$2D,$37,$37,$2F,$2F,$FF  ; right pac 

; used in attract mode to control ms pac moving under marquee

; moving left
;8641
left_anna
		db $B7,$B7,$AD,$AD,$B7,$B7,$AF,$AF,$FF  ; pac left

;864A
up_anna
		db $36,$36,$F1,$F1,$36,$36,$F3,$F3,$FF ; ms pac man moving up at the end 

; moving down?
;8653
down_anna
		db $34,$34,$31,$31,$34,$34,$33,$33,$FF	;sprite codes for ms pac man

; used in act 1
;865c
geyes_right db $A4,$A4,$A4,$A5,$A5,$A5,$FF  ; ghost with eyes looking right sprite 

; used in attract mode to control the ghosts moving under marquee

;8663
geyes_left
			db $24,$24,$24,$25,$25,$25,$FF	; ghost moving across (sprites with eyes looking left)

;866A
geyes_up
			db $26,$26,$26,$27,$27,$27,$FF	; ghost moving up left side (sprites with eyes looking up)

;8671
empty 		db $1F,$FF 				; empty sprite

;8673
heart		db $1E,$FF		; sprite code for heart

act_sign1
;8675:  10 10 10 14 14 14 16 16 16 FF	; sprite codes for ACT sign
		db $10,$10,$10,$14,$14,$14,$16,$16,$16,$FF
act_sign2
;867F:  11 11 11 15 15 15 17 17 17 FF 	; sprite codes for ACT sign
		db $11,$11,$11,$15,$15,$15,$17,$17,$17,$FF

; used in act 1

;8689
act_sign3 db $12,$FF 				; sprite code for ACT sign
;868B
act_sign4 db $13,$FF				; sprite code for ACT sign

;868D
stork_front	db $30,$FF				; stork sprite

;868F
flap_stork
			db $18,$18,$18,$18,$2C,$2C,$2C,$2C,$FF	; stork sprites
;8698
stork_sack	db $07,$FF 				; sack that stork carries sprite
;869A
pacjr 		db $0F,$FF         		; junior pacman sprite

; end data

; resume program

; arrive from #168C when ms pac is facing right
; MSPAC MOVING EAST
;869c  3a094d    ld      a,(#4d09)	; load A with pacman X position
;869f  e607      and     #07		; mask bits, now between #00 and #07
;86a1  cb3f      srl     a		; shift right, now between #00 and #03
;86a3  2f        cpl     		; invert
;86a4  1e30      ld      e,#30		; E := #30
;86a6  83        add     a,e		; add #30
;86a7  cb47      bit     0,a		; test bit 0.  is it on ?
;86a9  2002      jr      nz,#86ad        ; yes, skip next step
;86ab  3e37      ld      a,#37		; no, A := #37
;86ad  320a4c    ld      (#4c0a),a	; store into mspac sprite number
;86b0  c9        ret			; return
			rts

; arrive from #16B1 when ms pac is facing down
; MSPAC MOVING SOUTH
;86b1  3a084d    ld      a,(#4d08)	; load A with pacman Y position
;86b4  e607      and     #07		; mask bits, now between #00 and #07
;86b6  cb3f      srl     a		; shift right, now between #00 and #03
;86b8  1e30      ld      e,#30		; E := #30
;86ba  83        add     a,e		; add #30
;86bb  cb47      bit     0,a		; test bit 0.  is it on ?
;86bd  2002      jr      nz,#86c1        ; yes, skip next step
;86bf  3e34      ld      a,#34		; no, A := #34
;86c1  320a4c    ld      (#4c0a),a	; store into mspac sprite number
;86c4  c9        ret			; return
			rts

; arrive from #16D9 when ms pac is facing left
; MSPAC MOVING WEST
;86c5  3a094d    ld      a,(#4d09)	; load A with pacman X position
;86c8  e607      and     #07		; mask bits, now between #00 and #07
;86ca  cb3f      srl     a		; shift right, now between #00 and #03
;86cc  1eac      ld      e,#ac		; E := #AC
;86ce  83        add     a,e		; add #AC
;86cf  cb47      bit     0,a		; test bit 0 , is it on ?
;86d1  2002      jr      nz,#86d5        ; yes, skip next step
;86d3  3e35      ld      a,#35		; no, A := #35
;86d5  320a4c    ld      (#4c0a),a	; store into mspac sprite number
;86d8  c9        ret     
			rts

; arrive from #16FA when ms pac is facing up
; MSPAC MOVING NORTH
;86d9  3a084d    ld      a,(#4d08)	; load A with pacman Y position
;86dc  e607      and     #07		; mask bits, now between #00 and #07
;86de  cb3f      srl     a		; shift right, now between #00 and #03
;86e0  2f        cpl     		; invert
;86e1  1ef4      ld      e,#f4		; E := #F4
;86e3  83        add     a,e		; add #F4
;86e4  cb47      bit     0,a		; test bit 0 .  is it on ?
;86e6  2002      jr      nz,#86ea        ; yes, skip next step
;86e8  3e36      ld      a,#36		; no, A := #36
;86ea  320a4c    ld      (#4c0a),a	; store into mspac sprite number
;86ed  c9        ret     
			rts

;------------------------------------------------------------------------------
; subroutine called from #0909, per intermediate jump at #0EAD
;86EE
DOFRUIT mx %00
;
;86EE: 3A A4 4D	ld	a,(#4DA4)	; Load A with # of ghost killed but no collision for yet [0..4]
	    lda |num_ghosts_killed
;86F1: A7	and	a		; == #00 ?
;86F2: C0	ret	nz		; no, return
	    beq :continue
	    ; return if there's a dead ghost
	    rts
:continue
;86F3: 3A D4 4D	ld	a,(#4DD4)	; load A with entry to fruit points, or 0 if no fruit
	    lda |fruit_entry
;86F6: A7	and	a		; == #00 ?
;86F7: CA 47 87	jp	z,#8747		; yes, check for fruit release
	    beq :check_fruit_release
;
;86FA: 3A D2 4D	ld	a,(#4DD2)	; load A with fruit X position
	    lda |fruit_y
;86FD: A7	and	a		; is a fruit already onscreen?
;86FE: CA 47 87	jp	z,#8747		; no, then jump to check for 
	    beq :check_fruit_release
;
;8701  3a414c    ld      a,(#4c41)	; load A with fruit position
	    lda |BCNT
;8704  47        ld      b,a		; copy to B
;8705  214188    ld      hl,#8841	; load HL with start of table data
;8708  df        rst     #18		; load HL with data at table plus offset in B
	    asl
	    tax
	    lda |bounce_table,x
;8709  ed5bd24d  ld      de,(#4dd2)	; load DE with fruit position
;870d  19        add     hl,de		; add result from above
	    adc |FRUITP
;870e  22d24d    ld      (#4dd2),hl	; store result into fruit position
	    sta |FRUITP
;8711  21414c    ld      hl,#4c41	; load HL with fruit position
;8714  34        inc     (hl)		; increment that location
	    inc |BCNT
;8715  7e        ld      a,(hl)		; load A with this value
	    lda |BCNT
;8716  e60f      and     #0f		; mask bits, now between #00 and #0F
	    and #$0F
;8718  c0        ret     nz		; return if not zero ( returns to #090C)
	    beq :fcont
	    rts
:fcont
;8719  21404c    ld      hl,#4c40	; else load HL with fruit position counter
;871c  35        dec     (hl)		; decrement
	    dec |COUNT
;871d  fab587    jp      m,#87b5		; if negative, jump out to this subroutine
	    bmil FruitPathDone

    ; I'm spending a little bit wrapping my head around
    ; what this is supposed to be doing

;8726  21 BC 4E	ld	hl,#4EBC	; load HL with sound channel 3
;8729  CB EE	set	5,(hl)		; set bit 5 to turn on fruit bouncing sound
	    lda #%100000			; I changed order, so I don't have
	    tsb |bnoise				; to preserve A

;8720  7e        ld      a,(hl)		; else load A with this value
	    lda |COUNT
;8721  57        ld      d,a		; copy to D
;8722  cb3f      srl     a		; 
	    lsr
;8724  cb3f      srl     a		; shift A right twice
	    lsr

;872b  2a424c    ld      hl,(#4c42)	; load HL with address of the fruit path
	    clc
	    adc |PATH
;872e  d7        rst     #10		; load A with table data
	    tax
	    lda |0,x
	    and #$FF
;872f  4f        ld      c,a		; copy to C
	    tax
;8730  3e03      ld      a,#03		; A := #03
;8732  a2        and     d		; mask bits with the fruit position
	    lda #3
	    and |COUNT
;8733  2807      jr      z,#873c         ; if zero, skip next 4 steps
	    beq :fskip
;
	    tay
	    txa
:loop
;8735  cb39      srl     c
	    lsr
;8737  cb39      srl     c		; shift C right twice
	    lsr
;8739  3d        dec     a		; A := A - 1.  is A == #00 ?
	    dey
;873a  20f9      jr      nz,#8735        ; no, loop again
	    bne :loop
	    tax
:fskip
;873c  3e03      ld      a,#03		; A := #03
;873e  a1        and     c		; mask bits with C
	    txa
	    and #3
;873f  07        rlca
;8740  07        rlca
;8741  07        rlca
;8742  07        rlca			; rotate left 4 times
	    asl
	    asl
	    asl
	    asl
;8743  32414c    ld      (#4c41),a	; store result into fruit position counter
	    sta |BCNT
;8746  c9        ret     		; return
:rts
	    rts
;; arrive here from #86FE
;; to check to see if it is time for a new fruit to be released
;; only called when a fruit is not already onscreen
:check_fruit_release
;8747: 3A 0E 4E	ld	a,(#4E0E)	; load number of dots eaten
	    lda |dotseat
;874A: FE 40	cp	#40		; == #40 ? (64 decimal)
		cmp #$40
;874C: CA 58 87	jp	z,#8758		; yes, skip ahead and use HL as 4E0C
		beq :is64
;874F: FE B0	cp	#B0		; == #B0 (176 deciaml) ?
		cmp #$B0
;8751: C0	ret	nz		; no, return
		bne :rts
;
;8752: 21 0D 4E	ld	hl,#4E0D	; yes, load HL with #4E0D for 2nd fruit
		ldx #SECONDF
;8755: C3 5B 87	jp	#875B		; skip ahead
		bra :use2
:is64
;8758: 21 0C 4E	ld	hl,#4E0C	; load HL with 4E0C for first fruit
		ldx #FIRSTF
:use2
;875B: 7E	ld	a,(hl)		; load A with fruit flag
		lda |0,x
;875C: A7	and	a		; has this fruit already appeared?
;875D: C0	ret	nz		; yes, return
		bne :rts
;
;875e  34	inc	(hl)
		inc |0,x
;
;	;; Ms. Pacman Random Fruit Probabilities
;	;; (c) 2002 Mark Spaeth
;	;; http://rgvac.978.org/files/MsPacFruit.txt
;
;;  A hotly contested issue on rgvac. here's an explanation
;;  of how the random fruit selection routine works in Ms.
;;  Pacman, and the probabilities associated with the routine:
;
;875f  3a134e    ld      a,(#4e13)       ; Load the board # (cherry = 0)
		lda |level
;8762  fe07      cp      #07             ; Compare it to 7
		cmp #7
;8764  380a      jr      c,#8770         ; If less than 7, use board # as fruit
		bcc :useboardnum
;
;8766  0607      ld      b,#07   	; else B := #07
;
;        ;; selector for random fruits
;        ;; uses r register to get a random number
;
;8768  ed5f      ld      a,r             ; Load the DRAM refresh counter 
		jsr RANDOM
;876a  e61f      and     #1f             ; Mask off the bottom 5 bits
		and #$1F
;
;                ;; Compute ((R % 32) % 7)
:remain7
;876c  90        sub     b               ; Subtract 7
		sec
		sbc #7
;876d  30fd      jr      nc,#876c        ; If >=0 loop
		bpl :remain7
;876f  80        add     a,b             ; Add 7 back
		clc
		adc #7
;
:useboardnum
;8770  219d87    ld      hl,#879d        ; Level / fruit data table      
;8773  47        ld      b,a             ; 3 * a -> a
;8774  87        add     a,a
;8775  80        add     a,b
;8776  d7        rst     #10             ; hl + a -> hl, (hl) -> a  [table look]
		pha
		asl   	; x2
		adc 1,s ; x3
		sta 1,s
		pla

		tax

;8777  320c4c    ld      (#4c0c),a       ; Write 3 fruit data bytes (shape code)
		lda |fruit_shape_table,x
		and #$FF
		sta |fruitsprite
;877a  23        inc     hl
;877b  7e        ld      a,(hl)
;877c  320d4c    ld      (#4c0d),a	; Color code
		lda |fruit_shape_table+1,x
		and #$FF
		sta |fruitspritecolor
;877f  23        inc     hl
;8780  7e        ld      a,(hl)
;8781  32d44d    ld      (#4dd4),a	; Score table offset
		lda |fruit_shape_table+2,x
		and #$FF
		sta |FVALUE
;
;
;;    So, a little more background...
;;
;;    The 'R' register is the dram refresh address register
;;    that is not initalized on startup, so it has garbage
;;    in it.  During every instruction fetch, the counter is
;;    incremented.  Assume on average 4 clock cycles per
;;    instruction, with the clock running at 3.072 Mhz, this
;;    counter is incremented every 1.3us, so if you read it
;;    at any time, it's gonna be pretty damn random.  Of
;;    course, it doesn't just get read at any time, since
;;    the fruit select routine is called during the vertical
;;    blank every 1/60sec, but since the instruction
;;    counts between reads are not all the say, it's still
;;    random to better than 1/60 sec, which is still too fast
;;    for any player to count off.
;;
;;    So, now, assuming that the counter is random, the bottom
;;    5 bits are hacked off giving a number 0-31 (each with
;;    probability 1/32), and this number modulo 7 is used to
;;    determine which fruit appears...
;;
;;    So...
;;
;;     0, 7,14,21,28  ->  Cherry         100 pts @ 5/32 = 15.625 % 
;;     1, 8,15,22,29  ->  Strawberry     200 pts @ 5/32 = 15.625 %
;;     2, 9,16,23,30  ->  Orange         500 pts @ 5/32 = 15.625 %
;;     3,10,17,24,31  ->  Pretzel        700 pts @ 5/32 = 15.625 %
;;     4,11,18,25     ->  Apple         1000 pts @ 4/32 = 12.5   %
;;     5,12,19,26     ->  Pear          2000 pts @ 4/32 = 12.5   %
;;     6,13,20,27     ->  Banana        5000 pts @ 4/32 = 12.5   %
;;
;;    Also interesting to note is that the expected value of
;;    the random fruit is 1234.375 points, which is useful
;;    in determining a good estimate of what the killscreen
;;    score should be.  The standard deviation of this
;;    distribution is 1532.891 / sqrt(n), where n is the
;;    number of random fruits eaten, so at the level 243 (?)
;;    killscreen, (243-7)*2 = 472 fruits have been eaten,
;;    and the SD falls to 21.726, so it should be pretty easy
;;    to tell if the fruit distribution has been tampered
;;    with.  This SD across 472 fruits is +/- 10k from the
;;    mean, is approximaely the difference between the top
;;    3 players in twin galaxies, but given the game crash
;;    issue, the number of levels the game lets you play is
;;    probably a more poingant indicator than the fruits
;;    given.
;;
;;
;;
;;    How to cheat:
;;    -------------
;;
;;    Of course, if you want to be cutesy you can play with
;;    the distribution, by say changing 876b to 0x3f, thus
;;    doing 0-63 mod 7 to choose the fruit, bumping the
;;    average up to 1337.5, but at an extra 100 points a
;;    fruit, thats 47,200 points on average, and without a
;;    close statistical analysis like the one I've provided
;;    (which shows that this is almost 5 standard deviations
;;    above the mean), you could probably get away with it
;;    in competition.
;;
;;    If you really wanted to be cheezy, you could change
;;    0x876b to 0x06, so that only cherry, orange, apple,
;;    and banana come up, and all have equal probability.
;;    That would bump your fruit average up to 1650, but the
;;    absence of strawberries, pretzels, and pears would be
;;    pretty obvious.
;;
;;    These changes would't require any other changes in the
;;    code, but it's also possible to completely rewrite the
;;    routine, in a different part of the code space to do
;;    something different, but that's an exercise left to
;;    the reader.  (Perhaps the simplest would be to add 3
;;    after the mod 32 operation, so that Pretzel-Banana are
;;    slightly more likely than Cherry-Orange).
;;
;;    If you really want to be lame, you can edit the scoring
;;    table at 0x2b17 (many pacman bootlegs did this).
;;    Seriously, you could probably add 10 points to each
;;    value, and the 'judges' couldn't tell whether or not
;;    you were eating a dot while eating the fruit in many
;;    situations, and you could get almost 5000 extra points
;;    over the entire game ;)
;;
;;    One other 'cool' thing to do would be to chage 0x8763
;;    to 0x08, which would utilize the 8th fruit on the 8th
;;    board, and subsequently would give you even odds on
;;    all of the fruit, but since the junior icon and the
;;    banana are both 5000, the average skews WAY up to 1812.5
;;    points.
;;
;;    [To keep things fair, though, note that the junior
;;    fruit uses color code 0x00, which is to say, all black,
;;    so you'd have to find the invisible fruit.  Since the
;;    fruit patterns are pretty well known, that's probably
;;    not that big of a deal for top players.]
;
;
;	;; select the proper fruit path from the table at 87f8
;
;8784  21f887    ld      hl,#87f8	; load HL with fruit path entry lookup table
			ldx #FPATH_ENTRY_TABLE  ; table of tables
;8787  cdcd87    call    #87cd		; set up fruit path
			jsr setup_fruit_path
;878a  23        inc     hl		; HL := HL + 1
;878b  5e        ld      e,(hl)		; load E with table data
;878c  23        inc     hl		; next table entry
;878d  56        ld      d,(hl)		; load D with table data
			lda |3,y
;878e  ed53d24d  ld      (#4dd2),de	; store into fruit position
			sta |fruit_y
;8792  c9        ret			; return
			rts

;; jumped from #2BF4 for fruit drawing subroutine
;; A has the level number
;; keeps the fruit level at banana after level 7
;
;8793 FE 08 	CP 	#08 		; Is Level >= #08 ?
;8795 DA F9 2B 	JP 	C,#2BF9 	; No, return
;8798 3E 07 	LD 	A,#07 		; Yes, set A := #07
;879A C3 F9 2B 	JP 	#2BF9 		; Return
;
;------------------------------------------------------------------------------
;; fruit shape/color/points table
;879d
fruit_shape_table
			db $00,$14,$06 ; Cherry     = sprite 0, color 14, score table 06
			db $01,$0f,$07 ; Strawberry = sprite 1, color 0f, score table 07
			db $02,$15,$08 ; Orange     = sprite 2, color 15, score table 08
			db $03,$07,$09 ; Pretzel    = sprite 3, color 07, score table 09
			db $04,$14,$0a ; Apple      = sprite 4, color 14, score table 0a
			db $05,$15,$0b ; Pear	      = sprite 5, color 15, score table 0b
			db $06,$16,$0c ; Banana     = sprite 6, color 16, score table 0c
			db $07,$00,$0d ; Junior!    = sprite 7, color 00, score table 0d
;
;	; For reference, the score table is at 0x2b17
;	; arrive here from #871D
FruitPathDone mx %00
;87b5  3ad34d    ld      a,(#4dd3)	; load A with fruit position
			lda |fruit_x
			and #$FF
;87b8  c620      add     a,#20		; add 20
			clc
			adc #$20
;87ba  fe40      cp      #40		; > 40 ?
			cmp #$40
;87bc  3852      jr      c,#8810         ; yes, jump ahead and return
		    bcs fruit_exit_screen

;87be  2a424c    ld      hl,(#4c42)	; else load HL with value in #4C42 (EG. #8808, #8B71,)
			lda |PATH
;87c1  110888    ld      de,#8808	; load DE with start of data table
;87c4  37        scf     		; Set Carry Flag.
;87c5  3f        ccf   			; Invert Carry Flag (cleared in this case)  
;87c6  ed52      sbc     hl,de		; subtract DE (value = #8808) from HL
			sec
			sbc #fruit_data
;87c8  2023      jr      nz,#87ed        ; If not zero then jump ahead
			bne not_fruit_data
;
;87ca  210088    ld      hl,#8800	; else if zero then load HL with start of data table for fruit exit
			ldx #FPATH_EXIT_TABLE
setup_fruit_path mx %00
			stx <temp0
;87cd  cdbd94    call    #94bd		; load BC with valued from table based on level
			jsr ChooseMaze
;87d0  69        ld      l,c		; 
;87d1  60        ld      h,b		; copy BC into HL
			tay 					; pointer to paths table, for this level

;87d2  ed5f      ld      a,r		; load A with a random number
			jsr RANDOM
;87d4  e603      and     #03		; mask bits, now between #00 and #03
			and #3

;87d6  47        ld      b,a		; copy to B		
;87d7  87        add     a,a		; A := A*2
;87d8  87        add     a,a		; A := A*2
;87d9  80        add     a,b		; A := A+B (A is now randomly #00, #05, #0A, or #0F)
			pha
			asl
			asl
			adc 1,s
			sta 1,s
;87da  d7        rst     #10		; load A with (HL + A), HL := HL + A
			tya
			adc 1,s
			sta 1,s
			ply
;87db  5f        ld      e,a		; copy to E
;87dc  23        inc     hl		; next table entry
;87dd  56        ld      d,(hl)		; load D with next value from table.  DE now has fruit path address from table.
			lda |0,y
;87de  ed53424c  ld      (#4c42),de	; store DE into #4C42
			sta |PATH
;87e2  23        inc     hl		; next table entry
;87e3  7e        ld      a,(hl)		; load A with next value from table
			lda |2,y
			and #$FF
set_f_count
;87e4  32404c    ld      (#4c40),a	; store into #4C40
			sta |COUNT
;87e7  3e1f      ld      a,#1f		; A := #1F
			lda #$1F
;87e9  32414c    ld      (#4c41),a	; store into #4C41
			sta |BCNT
;87ec  c9        ret     		; return
			rts
;------------------------------------------------------------------------------
;; arrive here from #87C8
;87ed
not_fruit_data mx %00
;87ed  210888    ld      hl,#8808	; load HL with start of table data
			lda #fruit_data
;87f0  22424c    ld      (#4c42),hl	; store 08 88 into the addresses in #4C42 and #4C43
			sta |PATH
;87f3  3e1d      ld      a,#1d		; A := #1D (resets counter)
			lda #$1D
;87f5  c3e487    jp      #87e4		; jump back
			bra set_f_count

;------------------------------------------------------------------------------
;	; fruit path entry lookup table.  referenced in #8784
; 87f8
FPATH_ENTRY_TABLE
;87f8  4f 8b				; #8B4F ; fruit paths for maze 1
			da ent_fpaths_maze1
;87fa  40 8e				; #8E40 ; fruit paths for maze 2
			da ent_fpaths_maze2
;87fc  1a 91				; #911A ; fruit paths for maze 3
			da ent_fpaths_maze3
;87fe  0a 94				; #940A ; fruit paths for maze 4
			da ent_fpaths_maze4

;------------------------------------------------------------------------------
;	; fruit path exit lookup table data used from #87CA
;8800
FPATH_EXIT_TABLE
;8800  82 8B				; #8B82 ; fruit paths for maze 1
			da exit_fpaths_maze1
;8802  73 8E				; #8E73	; fruit paths for maze 2
			da exit_fpaths_maze2
;8804  42 91				; #9142	; fruit paths for maze 3
			da exit_fpaths_maze3
;8806  3c 94				; #943C	; fruit paths for maze 4
			da exit_fpaths_maze4
;
;; data used from #87C1 and #87ED
;
fruit_data
;8808  FA FF 55 55 01 80 AA 02		; fruit path ?
		db $FA,$FF,$55,$55,$01,$80,$AA,$02
;
;------------------------------------------------------------------------------
;; arrive here from #87BC, when fruit exits screen on its own (not eaten)
;8810
fruit_exit_screen mx %00

;8810  3e00      ld      a,#00		; A := #00
;8812  320d4c    ld      (#4c0d),a	; store into fruit sprite entry (clears fruit)
			stz |fruitspritecolor
;8815  c30010    jp      #1000		; jump back to program (clears #4DD4 and returns from sub)
			jmp clear_fruit
;
;; check for fruit being eaten ... jumped from #19AD
;; HL has pacman X,Y
;
;8818: F5	push	af		; Save AF
;8819: ED5BD24D	ld	de,(#4DD2)	; load fruit X position into D, fruit Y position into E
;881D: 7C	ld	a,h		; load A with pacman X position
;881E: 92	sub	d		; subtract fruit X position
;881F: C6 03	add	a,#03		; add margin of error == #03
;8821: FE 06	cp	#06		; X values match within margin ?
;8823: 30 18	jr	nc,#883D	; no , jump back to program
;
;8825: 7D	ld	a,l		; else load A with pacman Y values
;8826: 93	sub	e		; subtract fruit Y position
;8827: C6 03	add	a,#03		; add margin of error
;8829: FE 06	cp	#06		; Y values match within margin?
;882B: 30 10	jr	nc,#883D	; no, jump back to program
;
;; else a fruit is being eaten
;
;882D: 3E 01	ld	a,#01		; load A with #01
;882F: 32 0D 4C	ld	(#4C0D),a	; store into fruit sprite entry
;8832: F1	pop	af		; Restore AF
;8833: C6 02	add	a,#02		; add 2 to A
;8835: 32 0C 4C	ld	(#4C0C),a	; store into fruit sprite number
;8838: D6 02	sub	#02		; sub 2 from A, make A the same as it was
;883A: C3 B2 19	jp	#19B2		; jump back to program for fruit being eaten
;
;883D: F1	pop	af		; Restore AF
;883E: C3 CD 19	jp	#19CD		; jump back to program with no fruit eaten
;
;------------------------------------------------------------------------------
;
;; data used somehow with the fruit
;; called from #8705

bounce_table
;8841
    db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
;8850
    db $FF,$FF,$FF,$00,$00,$FF,$FF,$00,$00,$00,$00,$01,$00,$00,$00,$01
;8860
    db $00,$00,$00,$FF,$FE,$00,$00,$00,$FF,$00,$00,$FF,$FE,$00,$00,$00
;8870
    db $FF,$00,$00,$00,$FF,$00,$00,$00,$FF,$00,$00,$01,$FF,$01,$FF,$00
;8880
    db $00,$00,$00,$00,$00,$FF,$00,$00,$00,$00,$01,$00,$00,$FF,$00,$00
;8890
    db $00,$00,$01,$00,$00,$00,$01,$00,$00,$00,$01,$00,$00,$01,$01,$01
;88A0
    db $01,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01
;88B0
    db $00,$01,$00,$01,$00,$01,$00,$01,$00,$FF,$FF,$FF,$FF,$00,$00,$FF
;88C0
    db $FF

;------------------------------------------------------------------------------
;; pick a quadrant for the destination of a ghost, saved into DE
;9561
pick_quadrant mx %00

;			nop
;			nop
;			nop
;]wait		bra ]wait
;			nop
;			nop
;			nop

;9561  f5        push    af		; save AF
;9562  c5        push    bc		; save BC
;9563  e5        push    hl		; save HL
			phx
			pha

;9564  217895    ld      hl,#9578	; load HL with ghost destination table
			ldx #:destination_table
			stx <temp0
;9567  cdbd94    call    #94bd		; load BC based on level and HL
			jsr ChooseMaze
			pha						; pointer to the destination table

;956a  69        ld      l,c		; 
;956b  60        ld      h,b		; load HL with BC
;956c  ed5f      ld      a,r		; load A with random number from refresh register
;956e  e606      and     #06		; mask bits.  result is either 0,2,4, or 6
			jsr RANDOM
			and #$06
			clc
			adc 1,s
			plx

;9570  d7        rst     #10		; HL := HL + A, A := HL.  loads first value from table
;9571  5f        ld      e,a		; store into E
;9572  23        inc     hl		; next table entry
;9573  56        ld      d,(hl)		; load D with this value
			ldy |0,x

;9574  e1        pop     hl		; restore HL
;9575  c1        pop     bc		; restore BC
;9576  f1        pop     af		; restore AF
;9577  c9        ret     		; return
			pla
			plx
			rts

	; ghost destination table
:destination_table
		da ghost_targets_1 ; #8B2D	; 1st maze
		da ghost_targets_2 ; #8E18	; 2nd maze
		da ghost_targets_3 ; #910A	; 3rd maze
		da ghost_targets_4 ; #9402	; 4th maze


;------------------------------------------------------------------------------
; draws title screen logo and text (sets as tasks).  called from #95F8
; this on pac draws the ghost (logo) and CLYDE" text
;9642
draw_logo_text mx %00
;9642  ef        rst     #28		; insert task to draw text "(C) MIDWAY MFG CO"	
;9643  1c 13				; 
			lda #$131C
			jsr rst28

;9645  ef        rst     #28		; insert task to draw text "1980/1981"
;9646  1c 35				; 
			lda #$351C
			jsr rst28

    ; draws vertical strips of the midway logo starting with the rightmost
;9648  21 9A 42	LD	HL,#429A	; load HL with start of screen location
			ldx #$029A
			lda #$01BF
]loop
			sep #$21
;964b  3ebf      ld      a,#bf		; A := #BF = 1st code for midway logo graphic
;964d  a7        and     a		; clear the carry flag
;964e  111d00    ld      de,#001d	; load DE with offset for each strip
;9651  010004    ld      bc,#0400	; load BC with offset for color grid

;9654  77        ld      (hl),a		; draw first element
			sta |tile_ram,x
;9655  09        add     hl,bc		; add color offset
;9656  3601      ld      (hl),#01	; color first element
			xba
			sta |palette_ram,x
;9658  ed42      sbc     hl,bc		; remove color offset
;965a  23        inc     hl		; next location
;965b  d604      sub     #04		; next element
		    xba
			; c=1
			sbc #$04
;965d  77        ld      (hl),a		; draw 2nd element
			sta |tile_ram+1,x
;965e  09        add     hl,bc		; add color offset
;965f  3601      ld      (hl),#01	; color 2nd element
			xba
			sta |palette_ram+1,x
;9661  ed42      sbc     hl,bc		; remove color offset
;9663  23        inc     hl		; next location
;9664  d604      sub     #04		; next element
			xba
			;sec
			;c=1
			sbc #4
;9666  77        ld      (hl),a		; draw 3rd element
			sta |tile_ram+2,x
;9667  09        add     hl,bc		; add color offset		
;9668  3601      ld      (hl),#01	; color 3rd element
			xba
			sta |palette_ram+2,x
;966a  ed42      sbc     hl,bc		; remove color offset
;966c  23        inc     hl		; next location
;966d  d604      sub     #04		; next element
			xba
			;sec
			;c=1
			sbc #4
;966f  77        ld      (hl),a		; draw 4th element
			sta |tile_ram+3,x
;9670  09        add     hl,bc		; add color offset
;9671  3601      ld      (hl),#01	; color 4th element
			xba
			sta |palette_ram+1,x
;9673  ed42      sbc     hl,bc		; remove color offset
;9675  19        add     hl,de		; next strip
			xba
;9676  c60b      add     a,#0b		; add offset
			;clc
			;adc  #$0B
			;c=1
			adc #$0A ;+1 = #$0B
;9678  febb      cp      #bb		; are we done?
			cmp #$BB
			beq :done
;967a  20d8      jr      nz,#9654        ; No, loop again
			rep #$31
			tay
			txa
			adc #$20
			tax
			tya
			bra ]loop

:done
			rep #$30
;967c  c9        ret     		; return
			rts


;------------------------------------------------------------------------------

; act 2 song
act2_song1
    db  $F1,$02,$F2,$03,$F3,$0F,$F4,$01,$82,$70,$69,$82,$70,$69,$83,$70
    db  $6A,$83,$70,$6A,$82,$70,$69,$82,$70,$69,$89,$8B,$8D,$8E,$FF


; act 2 song
act2_song2
    db $F1,$00,$F2,$02,$F3,$0F,$F4,$00,$42,$50,$4E,$50,$49,$50,$46,$50
    db $4E,$49,$70,$66,$70,$43,$50,$4F,$50,$4A,$50,$47,$50,$4F,$4A,$70
    db $67,$70,$42,$50,$4E,$50,$49,$50,$46,$50,$4E,$49,$70,$66,$70,$45
    db $46,$47,$50,$47,$48,$49,$50,$49,$4A,$4B,$50,$6E,$FF


;------------------------------------------------------------------------------
        ;; channel 2 : jump table to song data
SONG_TABLE_2
    da startup_song2 ; #9695	; startup song
    da act1_song2    ; #96D6	; act 1 song
    da act2_song2    ; #3C58	; act 2 song
    da act3_song2    ; #974F	; act 3 song

        ;; channel 1 : jump table to song data
SONG_TABLE_1
    da startup_song1 ; #96B6	; startup song
    da act1_song1    ; #9719	; act 1 song
    da act2_song1    ; #3BD4	; act 2 song
    da act3_song1    ; #9772	; act 3 song

        ;; channel 3 : jump table to song data (nothing here, 9796 = 0xff)
SONG_TABLE_3
    da empty_song
    da empty_song
    da empty_song
    da empty_song

;!    TITLE!    "SONATA FOR UNACCOMPANIED VIDEO GAME"
startup_song2
    db $f1,$00,$f2,$02,$f3,$0a,$f4,$00,$41,$43,$45,$86,$8a,$88,$8b,$6a
    db $6b,$71,$6a,$88,$8b,$6a,$6b,$71,$6a,$6b,$71,$73,$75,$96,$95,$96
    db $ff

; startup song
startup_song1
    db $f1,$02,$f2,$03,$f3,$0a,$f4,$02,$50,$70,$86,$90,$81,$90,$86,$90
    db $68,$6a,$6b,$68,$6a,$68,$66,$6a,$68,$66,$65,$68,$86,$81,$86
    db $ff

; act 1 song
act1_song2
    db $f1,$00,$f2,$02,$f3,$0a,$f4,$00,$69,$6b,$69,$86,$61,$64,$65,$86
    db $86,$64,$66,$64,$61,$69,$6b,$69,$86,$61,$64,$64,$a1,$70,$71,$74
    db $75,$35,$76,$30,$50,$35,$76,$30,$50,$54,$56,$54,$51,$6b,$69,$6b
    db $69,$6b,$91,$6b,$69,$66,$f2,$01,$74,$76,$74,$71,$74,$71,$6b,$69
    db $a6,$a6,$ff

; act 1,$song
act1_song1
    db $f1,$03,$f2,$03,$f3,$0a,$f4,$02,$70,$66,$70,$46,$50,$86,$90,$70
    db $66,$70,$46,$50,$86,$90,$70,$66,$70,$46,$50,$86,$90,$70,$61,$70
    db $41,$50,$81,$90,$f4,$00,$a6,$a4,$a2,$a1,$f4,$01,$86,$89,$8b,$81
    db $74,$71,$6b,$69,$a6,$ff

; act 3 song

act3_song2
    db $f1,$00,$f2,$02,$f3,$0a,$f4,$00,$65,$64,$65,$88,$67,$88,$61,$63
    db $64,$85,$64,$85,$6a,$69,$6a,$8c,$75,$93,$90,$91,$90,$91,$70,$8a
    db $68,$71,$ff

; act 3,$song
act3_song1
    db $f1,$02,$f2,$03,$f3,$0a,$f4,$02,$65,$90,$68,$70,$68,$67,$66,$65
    db $90,$61,$70,$61,$65,$68,$66,$90,$63,$90,$86,$90,$85,$90,$85,$70
    db $86,$68,$65,$ff

empty_song db $ff


;------------------------------------------------------------------------------
; This is needed to get cutscene sprite frames copied into the hardware
; 9797
intermission_sprite_blit mx %00
;9797  3a004f    ld      a,(#4f00)	; load A with intermission indicator
			lda |is_intermission
;979a  fe00      cp      #00		; is an intermission running ?
;979c  280b      jr      z,#97a9         ; no, skip next 4 steps
			beq :not_intermission

;979e  11024c    ld      de,#4c02	; yes, load destination DE := #4C02
;97a1  21504f    ld      hl,#4f50	; load source HL := #4F50
;97a4  010c00    ld      bc,#000c	; set byte counter to #0C
;97a7  edb0      ldir    		; copy
]src = 0
]dst = 0
			lup 6

			lda |cutscene_SpriteRAM+]src
			and #$FF
			sta |redghostsprite+]dst

			lda |cutscene_SpriteRAM+]src+1
			and #$FF
			sta |redghostcolor+]dst
]src = ]src+2
]dst = ]dst+4
			--^


:not_intermission
;97a9  3a094e    ld      a,(#4e09)	; load A with current player number:  0=P1, 1=P2
;97ac  21724e    ld      hl,#4e72	; load HL with cocktail mode (0=no, 1=yes)
;97af  a6        and     (hl)		; mix together.  Is this 2 player and cocktail mode ?
;97b0  280c      jr      z,#97be         ; no, skip ahead
;
;97b2  3a0a4c    ld      a,(#4c0a)	; yes, load A with mspac sprite number
;97b5  fe3f      cp      #3f		; == #3F ?  - end of death animation?
;97b7  2005      jr      nz,#97be        ; no, skip ahead
;
;97b9  3eff      ld      a,#ff		; yes, A := #FF
;97bb  320a4c    ld      (#4c0a),a	; store into mspac sprite number
;
		; this actually jumps to the process_waves function
;97be  218596    ld      hl,#9685	; HL := #9685
;97c1  c3c42c    jp      #2cc4		; jump back to program
			rts

;------------------------------------------------------------------------------
; Return parity of the 8 bit accumulator
getparity8 mx %10
			pha
			phx
			phy
			sep #$30
			tax
			lda |:parity,x
			lsr    			; return result in C
			rep #$10
			ply
			plx
			pla
			rts
:parity
]var = 0
			lup 256

			db {]var&1}!{{]var/2}&1}!{{]var/4}&1}!{{]var/8}&1}!{{]var/16}&1}!{{]var/32}&1}!{{]var/64}&1}!{{]var/128}&1}

]var = ]var+1
			--^


;------------------------------------------------------------------------------

