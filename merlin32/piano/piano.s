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
		put ..\phx\VKYII_CFP9553_SDMA_def.asm
		put ..\phx\VKYII_CFP9553_SPRITE_def.asm
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
		ext yoshi_inst

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
VRAM_NYAN_SPRITES = $C70000  ; Nyan Cat Sprites
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

		jsr sprites_pic_init
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
		ldy #4
		jsr fastLOCATE
		ldx #txt_f2
		jsr fastPUTS

		ldx #1
		ldy #5
		jsr fastLOCATE
		ldx #txt_f3
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

		ldx #4
		ldy #46
		jsr fastLOCATE
		ldx #txt_volume
		jsr fastPUTS


		jsr ToggleInstrument
		jsr ShowVolume

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

		jsr UpdateOAM    ; DMA Sprites


;----- stuff where VBlank does not matter

		jsr ReadKeyboard

		; needs to happen before the keys are rendered, at the top 2/3rds of the frame
		jsr UpdatePianoKeys

		; Check and Dispatch when F1 is pressed
		ldx #KEY_F1
		lda #ToggleInstrument
		jsr OnKeyDown

		ldx #KEY_F2
		lda #VolumeUp
		jsr OnKeyDown

		ldx #KEY_F3
		lda #VolumeDown
		jsr OnKeyDown

		jsr ShowVolume

		jsr UpdateSprites

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
		dum 0
cat_frame ds 2
cat_timer ds 2
cat_x     ds 2
cat_y     ds 2
cat_note  ds 2
sizeof_cat ds 0
		dend


UpdateCats mx %00
		rts

:frames dw 0*1024,1*1024,2*1024,3*1024,4*1024,5*1024
;------------------------------------------------------------------------------
		dum 0
p_frame ds 2
p_timer ds 2
p_x     ds 2
p_y     ds 2
sizeof_particle ds 0
		dend

UpdateParticles mx %00
		rts
:frames dw 6*1024,7*1024,8*1024,9*1024,10*1024,11*1024
;------------------------------------------------------------------------------
UpdateSprites mx %00

		jsr oam_clear
		jsr UpdateCats
		Jsr UpdateParticles

		inc |oam_dirty
		rts

;------------------------------------------------------------------------------
oam_clear mx %00
		phkb ^SP00_CONTROL_REG
		plb
]offset = 0
		lup 64
		stz |SP00_CONTROL_REG+]offset
]offset = ]offset+8
		--^
		plb

		rts
;------------------------------------------------------------------------------
;
UpdateOAM mx %00
		lda |oam_dirty
		bne :update
		rts

:update
		do 0
		ldx #oam_shadow
		ldy #SP00_CONTROL_REG
		lda #7
		mvn ^oam_shadow,^SP00_CONTROL_REG

		phk
		plb
		fin

		do 1
		php
		sei	  ; want to protect against interrupts that do DMA (audio mixer)

		; set B into the same bank as registers
		phkb ^SDMA_CTRL_REG0
		plb

		sep #$10  ; mx=01

		stz |SDMA_CTRL_REG0   ; disable the DMA

		ldx #SDMA_CTRL0_Enable
		stx |SDMA_CTRL_REG0   ; enable the circuit

		lda #SP00_CONTROL_REG
		sta |SDMA_DST_ADDY_L
		ldy #^SP00_CONTROL_REG
		sty |SDMA_DST_ADDY_H

		lda #64*8
		sta |SDMA_SIZE_L
		stz |SDMA_SIZE_H

		lda #oam_shadow
		sta |SDMA_SRC_ADDY_L
		ldy #^oam_shadow
		sty |SDMA_SRC_ADDY_H

		ldx #SDMA_CTRL0_Enable+SDMA_CTRL0_Start_TRF
		stx |SDMA_CTRL_REG0

		nop	; this pains me
		nop
		nop
		nop
		nop

		stz |SDMA_CTRL_REG0   ; disable the DMA

		rep #$31
		plb
		plp
		fin
		rts

oam_dirty dw 0  ; mark true

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
		lda #$100+Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_GAMMA_En+Mstr_Ctrl_TileMap_En+Mstr_Ctrl_Text_Mode_En+Mstr_Ctrl_Text_Overlay+Mstr_Ctrl_Sprite_En
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
sprites_pic_init mx %00

;
; Extract Tiles Data
;
		; source picture
		pea ^sprites_pic
		pea sprites_pic

		; destination address
		pea ^work_buffer
		pea work_buffer

		jsl decompress_pixels
		
		; copy to VRAM
		lda #0
		tax
		tay
		dec
		mvn ^work_buffer,^VRAM_NYAN_SPRITES  ; from work buffer, to tile catalog

		phk
		plb


;
; Extract CLUT data for the sprites
;
		; source picture
		pea ^sprites_pic
		pea sprites_pic

		; destination address
		pea ^pal_buffer
		pea pal_buffer

		jsl decompress_clut

        ; Copy the LUT up into the HW
        ldy     #GRPH_LUT2_PTR  ; dest
        ldx     #pal_buffer  	; src
        lda     #1024-1			; length
        mvn     ^pal_buffer,^GRPH_LUT2_PTR    ; src,dest

		phk
		plb

; Sprite Test

		jsr oam_clear

		do 0
		lda #$65  		  ; activate with clut 2
		sta |oam_shadow
		stz |oam_shadow+1 ; Sprite ADDY (1024*0)
		lda #^{VRAM_NYAN_SPRITES-VRAM}
		sta |oam_shadow+3
		lda #400
		sta |oam_shadow+4
		lda #300
		sta |oam_shadow+6

		lda #$65
		sta |oam_shadow+8
		lda #1024*7
		sta |oam_shadow+9
		lda #^{VRAM_NYAN_SPRITES-VRAM}
		sta |oam_shadow+3+8
		lda #400
		sta |oam_shadow+4+8
		lda #300
		sta |oam_shadow+6+8
		fin


		inc |oam_dirty  ; so it will upload

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
txt_version cstr 'Virtual Piano v0.0.3    Try pressing some keys, QWERTY..ZXC :)'
txt_lower_notes cstr 'C2                              C3                              C4                             C5'
txt_f1 cstr 'F1: Toggle Instrument'
txt_f2 cstr 'F2: Volume Up'
txt_f3 cstr 'F3: Volume Down'
txt_instrument cstr 'INSTRUMENT:'
txt_volume     cstr     'VOLUME:'
txt_piano    cstr 'Piano G5    '
txt_basspull cstr 'Bass Pull E2'
txt_bassdrum cstr 'Bass Drum   '
txt_yoshi    cstr 'Yoshi       '
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
	lda #]2-1
	jsr PianoKeyUp
	; else keyup
	lda >piano_colors+{]2*4}-4+2
	tay
	lda >piano_colors+{]2*4}-4
	bra store@
keydown@
	lda #]2-1
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
; sizeof_osc = 28, so A x 28
mult_sizeof_osc mx %00
		; sizeof_osc = 28, so A*28
		asl  ; x2
		asl  ; x4
		pha
		asl  ; x8
		asl  ; x16
		asl  ; x32
		sec
		sbc 1,s	; x32-x4 = x28
		sta 1,s
		pla
		rts

;------------------------------------------------------------------------------
; A = note
; return X = mixer_dpage-MyDP+{<channel#>*sizeof_osc}
;  c=0 success
;  c=1 fail
; wrecks Y
FindVoiceKeyDown mx %00
		ldy #VOICES-1
		pha
]lp		lda |voice_status,y
		and #$FF
		beq :found_it
		dey
		bpl ]lp
		pla
		sec		; c=1 is fail  ; no more voices available
		rts
:found_it
		; mark in use
		lda |voice_status,y
		ora 1,s
		sta |voice_status,y

		tya

		jsr mult_sizeof_osc

		clc
		adc #mixer_dpage-MyDP
		tax
		pla
		; c=0 success
		rts

;------------------------------------------------------------------------------
; A = note
; return X = mixer_dpage-MyDP+{<channel#>*sizeof_osc}
;  c=0 success
;  c=1 fail
; wrecks Y
FindVoiceKeyUp mx %00
		ldy #VOICES-1
		pha
]lp		lda |voice_status,y
		and #$FF
		cmp 1,s
		beq :found_it
		dey
		bpl ]lp
		pla
		sec		; c=1 is fail
		rts

:found_it
		lda |voice_status,y  ; free the channel
		and #$FF00
		sta |voice_status,y

		tya
		jsr mult_sizeof_osc
		clc
		adc #mixer_dpage-MyDP

		tax

		pla
		;c=0=success
		rts

;------------------------------------------------------------------------------
; stop making noise
PianoKeyUp mx %00
		php
		phb
		phd
		rep #$31

		; A = C2 = 0, then contiguous up to C5
:pInst = temp0
:flags = temp1
:freq  = temp1+2
:note  = temp2
:maxrate = temp2+2
:loop  = temp3
:end   = temp4
:pWave = temp5
:loop_size = temp6
		pha

		phk
		plb
		lda #MyDP
		tcd

		jsr LoadPianoKeyTempVariables

		;lda <:flags
		;and #INST_FLAG_LOOP
		;beq :nothing  
		
		; get note in A
		lda 1,s
		clc
		adc #36 ;-> C2, convert to midi note
		sta 1,s

		jsr FindVoiceKeyUp
		bcs :nothing

		; install silence
		sei

		lda #silence
		sta <osc_pWave+1,x
		sta <osc_pWaveLoop+1,x
		sta <osc_pWaveEnd+1,x

		lda #^MIXER_WORKRAM
		sta <osc_pWave+3,x
		sta <osc_pWaveLoop+3,x
		sta <osc_pWaveEnd+3,x
		stz <osc_loop_size,x
		stz <osc_loop_size+2,x


:nothing
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
:loop_size = temp6
:vol = temp7


		pha

		phk
		plb
		lda #MyDP
		tcd


		jsr LoadPianoKeyTempVariables

		; freq to actual osc freq
		; freq / 24000
		sei                         ; can't have interrupt happen here

		;----------------------------------------------------

		lda |CurrentVolume
		sta |UNSIGNED_MULT_A_LO

		lda 1,s
		tax
		lda |pan_left,x
		and #$FF
		sta |UNSIGNED_MULT_B_LO
		lda |UNSIGNED_MULT_AL_LO
		asl
		asl
		xba
		and #$3F
		sta <:vol

		lda |pan_right,x
		and #$FF
		sta |UNSIGNED_MULT_B_LO
		lda |UNSIGNED_MULT_AL_LO
		asl
		asl
		and #$3F00
		tsb <:vol

		;----------------------------------------------------

		lda <:freq
		sta |UNSIGNED_MULT_A_LO
		;lda #24000
		;sta |UNSIGNED_MULT_B_LO
		lda #$02BB  			 ; $1000000/24000
		sta |UNSIGNED_MULT_B_LO

		;lda |UNSIGNED_MULT_AL_LO
		;sta |$8000
		;lda |UNSIGNED_MULT_AH_LO
		;sta |$8002

		lda |UNSIGNED_MULT_AH_LO
		sta <:freq

		;----------------------------------------------------

		lda 1,s
		clc
		adc #36 ;-> C2
		sta 1,s
		cmp <:note
		beq :freq_good
		bcs :step_up
		; step down
		sec
		lda <:note
		sbc 1,s
		asl
		tax
		lda |pitch_step_down,x
		sta |UNSIGNED_MULT_A_LO
		lda <:freq
		sta |UNSIGNED_MULT_B_LO

		lda |UNSIGNED_MULT_AH_LO
		bra :go

:step_up
		sbc <:note
		asl
		tax
		lda |pitch_step_up,x
		sta |UNSIGNED_MULT_A_LO
		lda <:freq
		sta |UNSIGNED_MULT_B_LO
		lda |UNSIGNED_MULT_AL_HI
:go
		sta <:freq
:freq_good
		lda <:freq
		;----------------------------------------------------

		;ldx #mixer_dpage-MyDP+{5*sizeof_osc}  ; channel 3, because why not?
		pha	; save freq
		lda 3,s    ; grab midi note #
		jsr FindVoiceKeyDown
		pla ; restore freq
		bcs :no_voice

		; Freq
		sta <osc_frequency,x  ; frequency request

		lda <:vol   	   	; left + right volume
		sta <osc_left_vol,x
		sta |DebugVolumes

		stz <osc_pWave,x

		; Wave Pointer in 24.8
		lda <:pWave			  ; new wave address
		sta <osc_pWave+1,x
		lda <:pWave+1
		sta <osc_pWave+2,x

		; Loop address in 24.8
		stz <osc_pWaveLoop,x
		lda <:loop
		sta <osc_pWaveLoop+1,x
		lda <:loop+1
		sta <osc_pWaveLoop+2,x

		stz <osc_pWaveEnd,x
		lda <:end
		sta <osc_pWaveEnd+1,x
		lda <:end+1
		sta <osc_pWaveEnd+2,x

		; Loop size in 24.8
		stz <osc_loop_size,x
		lda <:loop_size
		sta <osc_loop_size+1,x
		lda <:loop_size+1
		sta <osc_loop_size+2,x

:no_voice
		pla

		pld
		plb
		plp

		rts

;------------------------------------------------------------------------------
; Pan Table
pan_left
]num_pans = 37
]start = 36

		lup ]num_pans
		db 63*256*]start/{]num_pans*256}
]start = ]start-1
		--^

pan_right
]num_pans = 37
]start = 0

		lup ]num_pans
		db 63*256*]start/{]num_pans*256}
]start = ]start+1
		--^



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
:loop_size = temp6

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

		; set wave pointer
		clc
		lda <:pInst
		adc #jm_sizeof
		sta <:pWave
		lda <:pInst+2
		adc #0
		sta <:pWave+2

;-----------------------------------------

		; correct loop point address
		clc
		lda <:loop
		adc <:pWave
		sta <:loop
		lda <:loop+2
		adc <:pWave+2
		sta <:loop+2

		; wave end address
		clc
		lda <:end
		adc <:pWave
		sta <:end
		lda <:end+2
		adc <:pWave+2
		sta <:end+2

		; loop size
		sec
		lda <:end
		sbc <:loop
		sta <:loop_size
		lda <:end+2
		sbc <:loop+2
		sta <:loop_size+2

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

	da txt_yoshi
	dw INST_FLAG_DRUM
	adrl yoshi_inst

;------------------------------------------------------------------------------
VolumeUp mx %00
	lda |CurrentVolume
	inc
	cmp #64
	bcc :ok
	lda #63
:ok
	sta |CurrentVolume
	bra ShowVolume
;------------------------------------------------------------------------------
VolumeDown mx %00
	dec |CurrentVolume
	bpl :ok
	stz |CurrentVolume
:ok
;	rts
;------------------------------------------------------------------------------

ShowVolume mx %00
	ldx #12
	ldy #46
	jsr fastLOCATE
	lda |CurrentVolume
	jsr fastHEXBYTE

	lda #' '
	fastPUTC

	lda |DebugVolumes
	jsr fastHEXBYTE

	lda #' '
	fastPUTC

	lda |DebugVolumes+1
	jsr fastHEXBYTE

	rts
DebugVolumes dw 0
CurrentVolume dw 16
;------------------------------------------------------------------------------
ToggleInstrument mx %00

:index = CurrentInstrument

	lda |:index
	inc
	cmp #4
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

CurrentInstrument dw 3  ; default to piano

;------------------------------------------------------------------------------
;
;Pitch Tables
;------------
;Pitch up 1 step = 1.059463
;Pitch down 1 step = 0.943874
;
;Step Up Table in 8.8 format
pitch_step_up
;step=  0  1.000
	dw $0100
;step=  1  1.059
	dw $010f
;step=  2  1.122
	dw $011f
;step=  3  1.189
	dw $0130
;step=  4  1.260
	dw $0142
;step=  5  1.335
	dw $0155
;step=  6  1.414
	dw $016a
;step=  7  1.498
	dw $017f
;step=  8  1.587
	dw $0196
;step=  9  1.682
	dw $01ae
;step= 10  1.782
	dw $01c8
;step= 11  1.888
	dw $01e3
;step= 12  2.000
	dw $0200
;step= 13  2.119
	dw $021e
;step= 14  2.245
	dw $023e
;step= 15  2.378
	dw $0260
;step= 16  2.520
	dw $0285
;step= 17  2.670
	dw $02ab
;step= 18  2.828
	dw $02d4
;step= 19  2.997
	dw $02ff
;step= 20  3.175
	dw $032c
;step= 21  3.364
	dw $035d
;step= 22  3.564
	dw $0390
;step= 23  3.776
	dw $03c6
;step= 24  4.000
	dw $0400
;step= 25  4.238
	dw $043c
;step= 26  4.490
	dw $047d
;step= 27  4.757
	dw $04c1
;step= 28  5.040
	dw $050a
;step= 29  5.339
	dw $0556
;step= 30  5.657
	dw $05a8
;step= 31  5.993
	dw $05fe
;step= 32  6.350
	dw $0659
;step= 33  6.727
	dw $06ba
;step= 34  7.127
	dw $0720
;step= 35  7.551
	dw $078d
;step= 36  8.000
	dw $0800
;step= 37  8.476
	dw $0879
;step= 38  8.980
	dw $08fa
;step= 39  9.514
	dw $0983
;step= 40  10.079
	dw $0a14
;step= 41  10.679
	dw $0aad
;step= 42  11.314
	dw $0b50
;step= 43  11.986
	dw $0bfc
;step= 44  12.699
	dw $0cb3
;step= 45  13.454
	dw $0d74
;step= 46  14.254
	dw $0e41
;step= 47  15.102
	dw $0f1a
;step= 48  16.000
	dw $1000
;step= 49  16.951
	dw $10f3
;step= 50  17.959
	dw $11f5
;step= 51  19.027
	dw $1307
;step= 52  20.159
	dw $1428
;step= 53  21.357
	dw $155b
;step= 54  22.627
	dw $16a0
;step= 55  23.973
	dw $17f9
;step= 56  25.398
	dw $1966
;step= 57  26.909
	dw $1ae8
;step= 58  28.509
	dw $1c82
;step= 59  30.204
	dw $1e34
;step= 60  32.000
	dw $2000
;step= 61  33.903
	dw $21e7
;step= 62  35.919
	dw $23eb
;step= 63  38.055
	dw $260e
;step= 64  40.318
	dw $2851
;step= 65  42.715
	dw $2ab7
;step= 66  45.255
	dw $2d41
;step= 67  47.946
	dw $2ff2
;step= 68  50.797
	dw $32cc
;step= 69  53.818
	dw $35d1
;step= 70  57.018
	dw $3904
;step= 71  60.408
	dw $3c68
;step= 72  64.000
	dw $4000
;step= 73  67.806
	dw $43ce
;step= 74  71.838
	dw $47d6
;step= 75  76.110
	dw $4c1c
;step= 76  80.635
	dw $50a2
;step= 77  85.430
	dw $556e
;step= 78  90.510
	dw $5a82
;step= 79  95.892
	dw $5fe4
;step= 80  101.594
	dw $6598
;step= 81  107.635
	dw $6ba2
;step= 82  114.035
	dw $7209
;step= 83  120.816
	dw $78d0
;step= 84  128.001
	dw $8000
;step= 85  135.612
	dw $879c
;step= 86  143.676
	dw $8fac
;step= 87  152.219
	dw $9838
;step= 88  161.271
	dw $a145
;step= 89  170.860
	dw $aadc
;step= 90  181.020
	dw $b505
;step= 91  191.784
	dw $bfc8
;step= 92  203.188
	dw $cb30
;step= 93  215.270
	dw $d745
;step= 94  228.071
	dw $e412
;step= 95  241.633
	dw $f1a2
;step= 96  256.001 10000
;step= 97  271.224 10f39
;step= 98  287.352 11f5a
;step= 99  304.438 13070
;step=100  322.541 1428a
;step=101  341.721 155b8
;step=102  362.040 16a0a
;step=103  383.568 17f91
;step=104  406.377 19660
;step=105  430.541 1ae8a
;step=106  456.142 1c824
;step=107  483.266 1e344
;step=108  512.003 20000
;step=109  542.448 21e72
;step=110  574.703 23eb4
;step=111  608.877 260e0
;step=112  645.083 28515
;step=113  683.442 2ab71
;step=114  724.081 2d414
;step=115  767.137 2ff23
;step=116  812.754 32cc0
;step=117  861.083 35d15
;step=118  912.285 39049
;step=119  966.533 3c688
;step=120  1024.006 40001
;step=121  1084.896 43ce5
;step=122  1149.408 47d68
;step=123  1217.755 4c1c1
;step=124  1290.167 50a2a
;step=125  1366.884 556e2
;step=126  1448.163 5a829
;step=127  1534.276 5fe46
;step=128  1625.508 65982

;Step Down Table
; this is in the format 0.16 (for more precision)
pitch_step_down
;step=-  0  1.000 
	dw $0000
;step=-  1  0.944
	dw $f1a1
;step=-  2  0.891
	dw $e411
;step=-  3  0.841
	dw $d744
;step=-  4  0.794
	dw $cb2f
;step=-  5  0.749
	dw $bfc8
;step=-  6  0.707
	dw $b504
;step=-  7  0.667
	dw $aadc
;step=-  8  0.630
	dw $a145
;step=-  9  0.595
	dw $9837
;step=- 10  0.561
	dw $8fac
;step=- 11  0.530
	dw $879c
;step=- 12  0.500
	dw $7fff
;step=- 13  0.472
	dw $78d0
;step=- 14  0.445
	dw $7208
;step=- 15  0.420
	dw $6ba2
;step=- 16  0.397
	dw $6597
;step=- 17  0.375
	dw $5fe4
;step=- 18  0.354
	dw $5a82
;step=- 19  0.334
	dw $556e
;step=- 20  0.315
	dw $50a2
;step=- 21  0.297
	dw $4c1b
;step=- 22  0.281
	dw $47d6
;step=- 23  0.265
	dw $43ce
;step=- 24  0.250
	dw $3fff
;step=- 25  0.236
	dw $3c68
;step=- 26  0.223
	dw $3904
;step=- 27  0.210
	dw $35d1
;step=- 28  0.198
	dw $32cb
;step=- 29  0.187
	dw $2ff2
;step=- 30  0.177
	dw $2d41
;step=- 31  0.167
	dw $2ab7
;step=- 32  0.157
	dw $2851
;step=- 33  0.149
	dw $260d
;step=- 34  0.140
	dw $23eb
;step=- 35  0.132
	dw $21e7
;step=- 36  0.125
	dw $1fff
;step=- 37  0.118
	dw $1e34
;step=- 38  0.111
	dw $1c82
;step=- 39  0.105
	dw $1ae8
;step=- 40  0.099
	dw $1965
;step=- 41  0.094
	dw $17f9
;step=- 42  0.088
	dw $16a0
;step=- 43  0.083
	dw $155b
;step=- 44  0.079
	dw $1428
;step=- 45  0.074
	dw $1306
;step=- 46  0.070
	dw $11f5
;step=- 47  0.066
	dw $10f3
;step=- 48  0.062
	dw $0fff
;step=- 49  0.059
	dw $0f1a
;step=- 50  0.056
	dw $0e41
;step=- 51  0.053
	dw $0d74
;step=- 52  0.050
	dw $0cb2
;step=- 53  0.047
	dw $0bfc
;step=- 54  0.044
	dw $0b50
;step=- 55  0.042
	dw $0aad
;step=- 56  0.039
	dw $0a14
;step=- 57  0.037
	dw $0983
;step=- 58  0.035
	dw $08fa
;step=- 59  0.033
	dw $0879
;step=- 60  0.031
	dw $07ff
;step=- 61  0.029
	dw $078d
;step=- 62  0.028
	dw $0720
;step=- 63  0.026
	dw $06ba
;step=- 64  0.025
	dw $0659
;step=- 65  0.023
	dw $05fe
;step=- 66  0.022
	dw $05a8
;step=- 67  0.021
	dw $0556
;step=- 68  0.020
	dw $050a
;step=- 69  0.019
	dw $04c1
;step=- 70  0.018
	dw $047d
;step=- 71  0.017
	dw $043c
;step=- 72  0.016
	dw $03ff
;step=- 73  0.015
	dw $03c6
;step=- 74  0.014
	dw $0390
;step=- 75  0.013
	dw $035d
;step=- 76  0.012
	dw $032c
;step=- 77  0.012
	dw $02ff
;step=- 78  0.011
	dw $02d4
;step=- 79  0.010
	dw $02ab
;step=- 80  0.010
	dw $0285
;step=- 81  0.009
	dw $0260
;step=- 82  0.009
	dw $023e
;step=- 83  0.008
	dw $021e
;step=- 84  0.008
	dw $01ff
;step=- 85  0.007
	dw $01e3
;step=- 86  0.007
	dw $01c8
;step=- 87  0.007
	dw $01ae
;step=- 88  0.006
	dw $0196
;step=- 89  0.006
	dw $017f
;step=- 90  0.006
	dw $016a
;step=- 91  0.005
	dw $0155
;step=- 92  0.005
	dw $0142
;step=- 93  0.005
	dw $0130
;step=- 94  0.004
	dw $011f
;step=- 95  0.004
	dw $010f
;step=- 96  0.004
	dw $00ff
;step=- 97  0.004
	dw $00f1
;step=- 98  0.003
	dw $00e4
;step=- 99  0.003
	dw $00d7
;step=-100  0.003
	dw $00cb
;step=-101  0.003
	dw $00bf
;step=-102  0.003
	dw $00b5
;step=-103  0.003
	dw $00aa
;step=-104  0.002
	dw $00a1
;step=-105  0.002
	dw $0098
;step=-106  0.002
	dw $008f
;step=-107  0.002
	dw $0087
;step=-108  0.002
	dw $007f
;step=-109  0.002
	dw $0078
;step=-110  0.002
	dw $0072
;step=-111  0.002
	dw $006b
;step=-112  0.002
	dw $0065
;step=-113  0.001
	dw $005f
;step=-114  0.001
	dw $005a
;step=-115  0.001
	dw $0055
;step=-116  0.001
	dw $0050
;step=-117  0.001
	dw $004c
;step=-118  0.001
	dw $0047
;step=-119  0.001
	dw $0043
;step=-120  0.001
	dw $003f
;step=-121  0.001
	dw $003c
;step=-122  0.001
	dw $0039
;step=-123  0.001
	dw $0035
;step=-124  0.001
	dw $0032
;step=-125  0.001
	dw $002f
;step=-126  0.001
	dw $002d
;step=-127  0.001
	dw $002a
;step=-128  0.001
	dw $0028

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

voice_status ds VOICES      ; a byte for each voice, 0 means available

oam_shadow ds 8*64			; 64 sprite objects

num_cats ds 2
num_particles ds 2

uninitialized_end ds 0
	dend


