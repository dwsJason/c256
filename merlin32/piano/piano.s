;
; Fun Piano Demo, in Merlin32
;
;
; $00:2000 - $00:7FFF are free for application use.
;
        rel     ; relocatable
        lnk     Main.l

		; hardware includes from the kernel source code
		put ..\phx\vicky_ii_def.asm
		put ..\phx\VKYII_CFP9553_TILEMAP_def.asm
		put ..\phx\interrupt_def.asm
		put ..\phx\Math_def.asm

		; kernel things
		put ..\phx\kernel_inc.asm

		; my conventient long branch macros
		use macs.i
		use keys.i
		
		; linked data, and routines
		ext decompress_lzsa
		ext sprites_pic  ; 32x32 nyan cat sprite frames
		ext piano_pic
		ext stars_pic
		ext jr_font_lz

		; instruments
		ext piano_inst
		ext basspull_inst
		ext bassdrum_inst

        mx %00

;------------------------------------------------------------------------------
; Direct Page Equates
;------------------------------------------------------------------------------
		put dp.i.s
		put mixer.i.s
			  
;
; Decompress to this address
;
work_buffer = $100000	; $$TODO Refactor code so this only ever needs 64k
		
; Some HW Addresses - Defines

VRAM = $B00000
VRAM_PIANO_MAP = $B80000  ; smaller
VRAM_STAR_MAP  = $B90000  ; tile map for stars (128k
VRAM_TILE_CAT  = $C80000  ; tile catalog (C8->CF) will be the 8 tile catalogs in succession

;------------------------------------------------------------------------------
; I like having my own Direct Page

start   ent             ; make sure start is visible outside the file
		  
        clc
        xce
        rep $31         ; long MX, and CLC
		sei				; keep interrupts off, until we're ready for them

		; I added this here, to allow iteration to be more stable
		; (if my code had overritten any of these, and now has shifted)
		lda #$6B  ; RTL
		sta >VEC_INT00_SOF
		sta >VEC_INT01_SOL
		sta >VEC_INT02_TMR0
		sta >VEC_INT03_TMR1
		sta >VEC_INT04_TMR2

; Default Stack is on top of System DMA Registers
; So move the stack before proceeding

        lda #$BFFF      ; I really don't know much RAM the kernel is using in bank 0
        tcs

        lda #MyDP
        tcd

		phk
		plb

		; Initialize the uninitialized RAM
		stz |uninitialized_start
		ldx #uninitialized_start
		ldy #uninitialized_start+2
		lda #{uninitialized_end-uninitialized_start}-3
		mvn ^uninitialized_start,^uninitialized_start



		jsr video_init

		jsr font_init

		jsr stars_pic_init
		jsr piano_pic_init

		jsr InstallJiffy

;------------------------------------------------------------------------------
; Initial Static Text
		ldx #1
		txy
		jsr fastLOCATE

		ldx #txt_version
		jsr fastPUTS

		ldx #1
		ldy #3
		jsr fastLOCATE
		ldx #txt_f1
		jsr fastPUTS

		ldx #1
		ldy #73
		jsr fastLOCATE
		
		ldx #txt_lower_notes
		jsr fastPUTS

		ldx #0
		ldy #47
		jsr fastLOCATE
		ldx #txt_instrument
		jsr fastPUTS

		jsr ToggleInstrument
;------------------------------------------------------------------------------
; Mixer things

		ext MIXstartup
		ext MIXshutdown
		ext MIXplaysample
		ext MIXsetvolume


		lda #mixer_dpage	; pass in location of DP memory
		jsl MIXstartup

;------------------------------------------------------------------------------
;
UpdateLoop
		jsr WaitJiffy    ; wait for vblank
		jsr UpdateScroll ; video register updates, things work better during vblank


;----- stuff where VBlank does not matter

		jsr ReadKeyboard

		; needs to happen before the keys are rendered, at the top 2/3rds of the frame
		jsr UpdatePianoKeys

		; Check and Dispatch when F1 is pressed
		ldx #KEY_F1
		lda #ToggleInstrument
		jsr OnKeyDown

		bra UpdateLoop

;------------------------------------------------------------------------------
; X = Key #
; A = Function to Call
OnKeyDown mx %00
		dec
		pha
		sep #$20
		lda |keyboard,x
		bne :down
		; key is up, don't call
		sta |latch_keys,x
		rep #$30
:latched
		pla
		rts
:down
		cmp |latch_keys,x
		sta |latch_keys,x
		rep #$30
		beq :latched
:KeyIsDown
		rts

;------------------------------------------------------------------------------
; X = Key #
; A = Function to Call
OnKeyUp mx %00
		dec
		pha
		sep #$20
		lda |keyboard,x
		beq :up
		; key is up, don't call
		sta |latch_keys,x
		rep #$30
:latched
		pla
		rts
:up
		cmp |latch_keys,x
		sta |latch_keys,x
		rep #$30
		beq :latched
:KeyIsUp
		rts

;------------------------------------------------------------------------------
UpdateScroll mx %00
		; Scroll Horizontal, at 60FPS (silky)
		lda |BG0_SCROLL_X
		inc
		inc
		cmp #1600
		bcc :no_wrap
		lda #0			; wrap back to 0
:no_wrap
		sta |BG0_SCROLL_X
		sta >TL0_WINDOW_X_POS_L
		; end of scroll

		; Do Animation
		dec |ANIM_TIMER
		bpl :anim_done

		lda #8  	   	; update once per 8 frames
		sta |ANIM_TIMER

		lda |ANIM_FRAME_NUMBER
		inc
		cmp #6
		bcc :no_wrap2

		lda #0  ; wrap back to 0
:no_wrap2
		sta |ANIM_FRAME_NUMBER

		asl
		tax
		lda |AnimTable,x
		sta >TL0_WINDOW_Y_POS_L

:anim_done
		rts

BG0_SCROLL_X      dw 0
ANIM_TIMER        dw 0
ANIM_FRAME_NUMBER dw 0

; Vertical Scroll positions, for each frame
AnimTable
		dw 0
		dw 600
		dw 600+600
		dw 600+600+600
		dw 600+600+600+600
		dw 600+600+600+600+600

;------------------------------------------------------------------------------
;
; Put DP back at zero while calling out to PUTS
;
myPUTS  mx %00
        phd
        lda #0
        tcd
        jsl PUTS
        pld
        rts

HelloText asc 'Hello from Merlin32!'
        db 13,0

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

		lda	#FNX0_INT00_SOF
		trb |INT_MASK_REG0

		cli
		rts

;
; dpJiffy is a rolling timer, it can be used to help seed RNG
; or to know how many frames were missed (if you want to know that your
; game is slowing down, and compensate)
;

:JiffyTimer
		phb
		phk
		plb
		php
		rep #$30
		inc |{MyDP+dpJiffy}
		plp
		plb
		rtl

;------------------------------------------------------------------------------
; WaitJiffy
; Preserve all registers
;
WaitJiffy
		pha
		lda <dpJiffy
]lp
		cmp <dpJiffy
		beq ]lp
		pla
		rts


;------------------------------------------------------------------------------

	put i256.s

;------------------------------------------------------------------------------

video_init mx %00

		; 800x600
		;lda #$100+Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_Bitmap_En+Mstr_Ctrl_GAMMA_En+Mstr_Ctrl_TileMap_En
		lda #$100+Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_GAMMA_En+Mstr_Ctrl_TileMap_En+Mstr_Ctrl_Text_Mode_En+Mstr_Ctrl_Text_Overlay
		sta >MASTER_CTRL_REG_L

		; No Border
		lda #0
		sta >BORDER_X_SIZE    ; also sets the BORDER_Y_SIZE
		
		; Tile maps off
		sta >TL0_CONTROL_REG
		sta >TL1_CONTROL_REG
		sta >TL2_CONTROL_REG
		sta >TL3_CONTROL_REG
		
		; turn on tile map 0, and 1
		lda #TILE_Enable
		sta >TL0_CONTROL_REG
		sta >TL1_CONTROL_REG
		lda #{VRAM_STAR_MAP-VRAM}
		sta >TL0_START_ADDY_L
		lda #^{VRAM_STAR_MAP-VRAM}
		sta >TL0_START_ADDY_H

		lda #{VRAM_PIANO_MAP-VRAM}
		sta >TL1_START_ADDY_L
		lda #^{VRAM_PIANO_MAP-VRAM}
		sta >TL1_START_ADDY_H

		
		lda #0
		sta >TL0_WINDOW_X_POS_L
		sta >TL0_WINDOW_Y_POS_L
		sta >TL1_WINDOW_X_POS_L
		sta >TL1_WINDOW_Y_POS_L

; Hide the Mouse
		sta >MOUSE_PTR_CTRL_REG_L
		
		lda #{VRAM_TILE_CAT-VRAM}
		sta >TILESET0_ADDY_L
		sta >TILESET1_ADDY_L
		sta >TILESET2_ADDY_L
		sta >TILESET3_ADDY_L
		sta >TILESET4_ADDY_L
		sta >TILESET5_ADDY_L
		sta >TILESET6_ADDY_L
		sta >TILESET7_ADDY_L
		lda #^{VRAM_TILE_CAT-VRAM}
		sta >TILESET0_ADDY_H
		inc
		sta >TILESET1_ADDY_H	    ; by placing the next tileset after the first, we expand support to 512 tiles
		inc
		sta >TILESET2_ADDY_H
		inc
		sta >TILESET3_ADDY_H
		inc
		sta >TILESET4_ADDY_H
		inc
		sta >TILESET5_ADDY_H
		inc
		sta >TILESET6_ADDY_H
		inc
		sta >TILESET7_ADDY_H

		rts
;------------------------------------------------------------------------------
stars_pic_init mx %00
;
; Configure the Width and Height of the Tilemap, based on the width
; and height stored in our file
;
		lda #stars_pic
		ldx #^stars_pic
		jsr c256Init

		ldy #8  ; TMAP width offset
		lda [pTMAP],y
		sta >TL0_TOTAL_X_SIZE_L
		iny
		iny     ; TMAP height offset
		lda [pTMAP],y
		inc
		and #$FFFE
		sta >TL0_TOTAL_Y_SIZE_L

;
; Extract CLUT data from the stars image
;
		; source picture
		pea ^stars_pic
		pea stars_pic

		; destination address
		pea ^pal_buffer
		pea pal_buffer

		jsl decompress_clut

        ; Copy the LUT up into the HW
        ldy     #GRPH_LUT0_PTR  ; dest
        ldx     #pal_buffer  	; src
        lda     #1024-1			; length
        mvn     ^pal_buffer,^GRPH_LUT0_PTR    ; src,dest

		phk
		plb

        ; Set Background Color, so the same as LUT entry 0
		sep #$30
        lda	|pal_buffer
        sta >BACKGROUND_COLOR_B ; back
        lda |pal_buffer+1
        sta  >BACKGROUND_COLOR_G ; back
        lda |pal_buffer+2
        sta  >BACKGROUND_COLOR_R ; back
		rep #$30

;
; Extract Tiles Data
;
		; source picture
		pea ^stars_pic
		pea stars_pic

		; destination address
		pea ^work_buffer
		pea work_buffer

		jsl decompress_pixels
		
		; copy to VRAM
		lda #0
		tax
		tay
		dec
		mvn ^work_buffer,^VRAM_TILE_CAT  ; from work buffer, to tile catalog

		phk
		plb

		
;
; Extract Map Data
;
		; source
		pea ^stars_pic
		pea stars_pic
		; dest
		pea ^work_buffer
		pea work_buffer
		
		jsl decompress_map
		
		; copy map data to VRAM		
		lda #0
		tax
		tay
		dec
		mvn ^work_buffer,^VRAM_STAR_MAP
		
		; copy map data to VRAM		
		lda #0
		tax
		tay
		dec
		mvn ^{work_buffer+$10000},^{VRAM_STAR_MAP+$10000}

		phk
		plb		


		rts
;------------------------------------------------------------------------------
piano_pic_init mx %00
;
; Configure the Width and Height of the Tilemap, based on the width
; and height stored in our file
;

		lda #piano_pic
		ldx #^piano_pic
		jsr c256Init

		ldy #8  ; TMAP width offset
		lda [pTMAP],y
		sta >TL1_TOTAL_X_SIZE_L
		iny
		iny     ; TMAP height offset
		lda [pTMAP],y
		inc
		and #$FFFE
		sta >TL1_TOTAL_Y_SIZE_L


;
; Extract CLUT data from the piano image
;
		; source picture
		pea ^piano_pic
		pea piano_pic

		; destination address
		pea ^pal_buffer
		pea pal_buffer

		jsl decompress_clut

		; Update colors in the LUT with piano keys, so it doesn't look
		; like a rainbow
		ldy #pal_buffer+4
		ldx #piano_colors
		lda #{37*4}-1
		mvn ^piano_colors,^pal_buffer

        ; Copy the LUT up into the HW
        ldy     #GRPH_LUT1_PTR  ; dest
        ldx     #pal_buffer  	; src
        lda     #1024-1			; length
        mvn     ^pal_buffer,^GRPH_LUT0_PTR    ; src,dest

		phk
		plb

;
; Extract Tiles Data
;
		; source picture
		pea ^piano_pic
		pea piano_pic

		; destination address
		pea ^work_buffer
		pea work_buffer

		jsl decompress_pixels
		
		; copy to VRAM
		lda #0
		tax
		tay
		dec
		mvn ^work_buffer,^{VRAM_TILE_CAT+$10000}  ; from work buffer, to tile catalog

		lda #0
		tax
		tay
		dec
		mvn ^{work_buffer+$10000},^{VRAM_TILE_CAT+$20000}  ; from work buffer, to tile catalog

		phk
		plb

		
;
; Extract Map Data
;
		; source
		pea ^piano_pic
		pea piano_pic
		; dest
		pea ^work_buffer
		pea work_buffer
		
		jsl decompress_map

		; Massage Map data a bit
		; we need to set CLUT1, and add 256 to the tiles offset

		; 50x38 tilemap
		; copy map, and fix it
		ldx #{52*40*2}-2
		clc
]lp
		lda >work_buffer,x
		adc #$100+$800			; CLUT1
		sta >VRAM_PIANO_MAP,x
		dex
		dex
		bpl ]lp		


		rts
;------------------------------------------------------------------------------
;
; Load Nicer font in to character memory, clear the TEXT screen, etc.
;
font_init mx %00

		; Decompress the Font
		pea ^jr_font_lz
		pea jr_font_lz

		pea ^work_buffer
		pea work_buffer

		jsl decompress_lzsa

		; Copy the Font into the font glyph area
		ldx #2048-2
]lp
		lda >work_buffer,x
		sta >FONT_MEMORY_BANK0,x
		sta >FONT_MEMORY_BANK1,x
		dex
		dex
		bpl ]lp

		; cursor, and other text buffer "stuff"
		lda #0
		sta >VKY_TXT_CURSOR_CTRL_REG  ; I don't want flashing cursor
		sta >VKY_TXT_START_ADD_PTR    ; I don't understand how this works

		phkb ^CS_TEXT_MEM_PTR
		plb
		; setup colors
		; Copy GS colors into the Text Color Memory
		ldx #{16*4}-4
]lp
		lda >gs_colors,x
		sta |BG_CHAR_LUT_PTR,x
		sta |FG_CHAR_LUT_PTR,x
		lda >gs_colors+2,x
		sta |BG_CHAR_LUT_PTR+2,x
		sta |FG_CHAR_LUT_PTR+2,x
		dex
		dex
		dex
		dex
		bpl ]lp


		; clear out the text memory, and the color memory

		ldx #$2000-2
]lp
		lda #'  '    ; clear with spaces
		sta |CS_TEXT_MEM_PTR,x
		lda #$F6F6   ; white on medium blue
		cpx #100*50  ; top 50 lines are white, below that dark grey
		bcc :white
		lda #$5656   ; dark grey
:white
		sta |CS_COLOR_MEM_PTR,x
		dex
		dex
		bpl ]lp

		plb
		rts

;------------------------------------------------------------------------------
;GS Border Colors
border_colors
 dw $0,$d03,$9,$d2d,$72,$555,$22f,$6af ; Border Colors
 dw $850,$f60,$aaa,$f98,$d0,$ff0,$5f9,$fff
;------------------------------------------------------------------------------
gs_colors
	adrl $ff000000  ;0 Black
	adrl $ffdd0033	;1 Deep Red
	adrl $ff000099	;2 Dark Blue
	adrl $ffdd22dd	;3 Purple
	adrl $ff007722	;4 Dark Green
	adrl $ff555555	;5 Dark Gray
	adrl $ff2222ff	;6 Medium Blue
	adrl $ff66aaff	;7 Light Blue
	adrl $ff885500	;8 Brown
	adrl $ffff6600	;9 Orange
	adrl $ffaaaaaa	;A Light Gray
	adrl $ffff9988	;B Pink
	adrl $ff00dd00	;C Light Green
	adrl $ffffff00	;D Yellow
	adrl $ff55ff99	;E Aquamarine
	adrl $ffffffff	;F White

;------------------------------------------------------------------------------
; 37 keys, so 37 entries here
]WHITE = $fff0f0f0
]BLACK = $ff101010

piano_colors
	lup 3
	adrl ]WHITE,]BLACK,]WHITE,]BLACK,]WHITE,]WHITE,]BLACK,]WHITE,]BLACK,]WHITE,]BLACK,]WHITE
	--^
	adrl ]WHITE

;------------------------------------------------------------------------------
; fast text crap
;------------------------------------------------------------------------------
fastLOCATE mx %00
	tya
	asl  ; c=0
	tay
	txa
	adc |screen_table,y
	sta <pFastPut
	lda #^CS_TEXT_MEM_PTR
	sta <pFastPut+2
	rts

screen_table
]var = CS_TEXT_MEM_PTR
	lup 75
	da ]var
]var = ]var+100
	--^
;------------------------------------------------------------------------------
fastHEXBYTE mx %00
		; Kernel function doesn't work

		sep #$30
		pha
		and #$F0
		lsr
		lsr
		lsr
		lsr
		tax
		pla
		and #$0F
		tay
		lda |:chars,x
		sta |:temp
		lda |:chars,y
		sta |:temp+1
		rep #$30

		lda |:temp
		fastPUTC
		inc <pFastPut
		rts

:chars  ASC '0123456789ABCDEF'

:temp	ds  3

;------------------------------------------------------------------------------
fastPUTS  mx %00
		sep #$20
		ldy <pFastPut

		lda |0,x
		beq :done
]lp
		inx
		sta [pFastPut]
		iny
		sty <pFastPut
		lda |0,x
		bne ]lp
:done 
		rep #$30
        rts
;------------------------------------------------------------------------------
txt_version cstr 'Virtual Piano v0.0.1    Try pressing some keys, QWERTY..ZXC :)'
txt_lower_notes cstr 'C2                              C3                              C4                             C5'
txt_f1 cstr 'F1: Toggle Instrument'
txt_instrument cstr 'INSTRUMENT:'
txt_piano    cstr 'Piano G5    '
txt_basspull cstr 'Bass Pull E2'
txt_bassdrum cstr 'Bass Drum   '
;------------------------------------------------------------------------------
ReadKeyboard mx %00
		phd
		pea 0
		pld

HISTORY_SIZE = 15

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

	; this is he actual keyboard driver, just reflects keystatus
	; into the keyboard array

		sep #$30
		tay
		and #$7F
		tax
		tya
		bpl :keydown
		lda #$00  		; key-up
:keydown
		sta |keyboard,x
		
		tya
		rep #$30

	; end keyboard driver

	; I keep history here, for debugging
		do 1
		ldx |:index     	; current index
		sta |:history,x 	; save in history
		dex
		dex     		; next index
		bpl :continue
		ldx #{HISTORY_SIZE*2}-2 ; index wrap
:continue
		stx |:index     	; save index for next time
		fin

		bra ]key_loop

:exit
		pld

; print out the current history
		do 1
:x = temp0
:y = temp0+2

		ldx #97
		ldy #2
		stx <:x
		sty <:y

		ldy |:index
]loop
		phy
		ldx <:x
		ldy <:y
		jsr fastLOCATE

		ply
		iny
		iny
		cpy #HISTORY_SIZE*2
		bcc :cont2
		ldy #0
:cont2
		cpy |:index
		beq :xit

		lda |:history,y
		phy
		jsr fastHEXBYTE
		ply
		inc <:y

		bra ]loop
:xit

		fin
		rts


:index		dw 0
:last_code	dw 0

:history	ds HISTORY_SIZE*2

;------------------------------------------------------------------------------
;
; For now, reflect appropriate color into the CLUT based on the keys that are
; down.  We do need to know if the key is going up or down, to emit an "event"
; that will be used to start/stop the note for the key
;


CheckKey mac
	mx %01
	ldx <]1
	cpx <{]1+128}
	beq next@
	stx <{]1+128}
	txy
	bne keydown@
	lda #]1-1
	jsr PianoKeyUp
	; else keyup
	lda >piano_colors+{]2*4}-4+2
	tay
	lda >piano_colors+{]2*4}-4
	bra store@
keydown@
	lda #]1-1
	jsr PianoKeyDown
	lda 3,s
	tay
	lda 1,s
store@
	sta |{GRPH_LUT1_PTR+{]2*4}+0}
	sty |{GRPH_LUT1_PTR+{]2*4}+2}
next@
	<<<

UpdatePianoKeys mx %00
	phd

	pea keyboard
	pld

	phkb ^GRPH_LUT1_PTR
	plb

	pea $FFFF
	pea $6600

	; key index, clut index

	sep #$10  ; a long, m short

	CheckKey $0f;$01
	CheckKey $02;$02
	CheckKey $10;$03
	CheckKey $03;$04
	CheckKey $11;$05
	CheckKey $12;$06
	CheckKey $05;$07
	CheckKey $13;$08
	CheckKey $06;$09
	CheckKey $14;$0A
	CheckKey $07;$0B
	CheckKey $15;$0C

	CheckKey $16;$0D
	CheckKey $09;$0E
	CheckKey $17;$0F
	CheckKey $0A;$10
	CheckKey $18;$11
	CheckKey $19;$12
	CheckKey $0C;$13
	CheckKey $1A;$14
	CheckKey $0D;$15
	CheckKey $1B;$16
	CheckKey $0E;$17
	CheckKey $2B;$18

	CheckKey $2C;$19
	CheckKey $1F;$1A
	CheckKey $2D;$1B
	CheckKey $20;$1C
	CheckKey $2E;$1D
	CheckKey $2F;$1E
	CheckKey $22;$1F
	CheckKey $30;$20
	CheckKey $23;$21
	CheckKey $31;$22
	CheckKey $24;$23
	CheckKey $32;$24

	CheckKey $33;$25

	rep #$31
	pla 		; keydown color
	pla

	plb			; b restore
	pld			; d restore
	rts

;------------------------------------------------------------------------------
; stop making noise
PianoKeyUp mx %00
		php
		phb
		phd
		rep #$30

		; A = C2 = 0, then contiguous up to C5
:pInst = temp0
:flags = temp1
:freq  = temp1+2
:note  = temp2
:maxrate = temp2+2
:loop  = temp3
:end   = temp4
:pWave = temp5
		pha

		phk
		plb
		lda #MyDP
		tcd


		jsr LoadPianoKeyTempVariables

		pla

		pld
		plb
		plp

		rts
;------------------------------------------------------------------------------
; make some noise
PianoKeyDown mx %00
		php
		phb
		phd
		rep #$30
		; A = C2 = 0, then contiguous up to C5
:pInst = temp0
:flags = temp1
:freq  = temp1+2
:note  = temp2
:maxrate = temp2+2
:loop  = temp3
:end   = temp4
:pWave = temp5


		pha

		phk
		plb
		lda #MyDP
		tcd


		jsr LoadPianoKeyTempVariables

		; freq to actual osc freq
		; freq / 24000
		sei
		lda <:freq
		sta |UNSIGNED_MULT_A_LO
		;lda #24000
		;sta |UNSIGNED_MULT_B_LO
		lda #$02BB
		sta |UNSIGNED_MULT_B_LO


		lda |UNSIGNED_MULT_AL_LO
		sta |$8000
		lda |UNSIGNED_MULT_AH_LO
		sta |$8002


		lda |UNSIGNED_MULT_AL_HI
		sta <:freq

		pla

		pld
		plb
		plp

		rts


;------------------------------------------------------------------------------
; JMIX header
		dum 0
JMIX           ds 4
jm_file_length ds 4
jm_version     ds 2
jm_freq        ds 2
jm_note        ds 2
jm_maxrate     ds 2
jm_loop_point  ds 4
jm_end_point   ds 4

jm_sizeof	ds 0
		dend

LoadPianoKeyTempVariables mx %00
:pInst = temp0
:flags = temp1
:freq  = temp1+2
:note  = temp2
:maxrate = temp2+2
:loop  = temp3
:end   = temp4
:pWave = temp5

; load up some DP variable with instrument information
		lda |CurrentInstrument
		asl
		asl
		asl
		tax
		lda |instruments+4,x
		sta <:pInst
		lda |instruments+6,x
		sta <:pInst+2

		lda |instruments+2,x
		sta <:flags

; pInst, points at a JMIX instrument

		ldy #jm_freq
		lda [:pInst],y
		sta <:freq

		ldy #jm_note
		lda [:pInst],y
		sta <:note

		ldy #jm_maxrate
		lda [:pInst],y
		sta <:maxrate

		ldy #jm_loop_point
		lda [:pInst],y
		sta <:loop
		ldy #jm_loop_point+2
		lda [:pInst],y
		sta <:loop+2

		ldy #jm_end_point
		lda [:pInst],y
		sta <:end
		ldy #jm_end_point+2
		lda [:pInst],y
		sta <:end+2

		clc
		lda <:pInst
		adc #jm_sizeof
		sta <:pWave
		lda <:pInst+2
		adc #0
		sta <:pWave+2

;-----------------------------------------

		clc
		lda <:loop
		adc <:pInst
		sta <:loop
		lda <:loop+2
		adc <:pInst+2
		sta <:loop+2

		clc
		lda <:end
		adc <:pInst
		sta <:end
		lda <:end+2
		adc <:pInst+2
		sta <:end+2

		rts
;------------------------------------------------------------------------------
;
;

INST_FLAG_LOOP = $0001	; if it loops, we need to stop when key up
INST_FLAG_DRUM = $0002  ; it it's a drum, it always plays the same frequency

instruments
	da txt_piano
	dw INST_FLAG_LOOP
	adrl piano_inst

	da txt_basspull
	dw INST_FLAG_LOOP
	adrl basspull_inst

	da txt_bassdrum
	dw INST_FLAG_DRUM
	adrl bassdrum_inst

;------------------------------------------------------------------------------
ToggleInstrument mx %00

:index = CurrentInstrument

	lda |:index
	inc
	cmp #3
	bcc :ok
	lda #0
:ok sta |:index

	asl
	asl
	asl
	tax
	lda |instruments+0,x

	pha

	ldx #12
	ldy #47
	jsr fastLOCATE

	plx
	jsr fastPUTS

	rts

CurrentInstrument dw 2  ; default to piano

;------------------------------------------------------------------------------

; Non Initialized spaced

	dum *+$2100  ; pirate! (this is cheating, these addresses are not relocatable)
	             ; so org of this file has to be $2100, and if anyone trys to
				 ; move the location, this will break
uninitialized_start ds 0
;------------------------------------------------------------------------------
;
; Clut Buffer
;
pal_buffer
		ds 1024


;Keyboard things
;------------------------------------------------------------------------------
; The status of up to 128 keys on the keyboard
;
		   ds \              ; 256 byte align, for quicker piano update
keyboard   ds 128
piano_keys ds 128

mixer_dpage ds 256		  	 ; mixer gets it's own DP

latch_keys ds 128			; hybrid latch memory


uninitialized_end ds 0
	dend


