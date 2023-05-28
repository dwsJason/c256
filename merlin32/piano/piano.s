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

		; kernel things
		put ..\phx\kernel_inc.asm

		; my conventient long branch macros
		put macs.i.s
		
		; linked data, and routines
		ext decompress_lzsa
		ext piano_pic
		ext stars_pic

        mx %00

;------------------------------------------------------------------------------
; Direct Page Equates
;------------------------------------------------------------------------------
		put dp.i.s
			  
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

; Default Stack is on top of System DMA Registers
; So move the stack before proceeding

        lda #$BFFF      ; I really don't know much RAM the kernel is using in bank 0
        tcs

        lda #MyDP
        tcd

		jsr video_init

		jsr stars_pic_init
		jsr piano_pic_init

		jsr InstallJiffy

;
;------------------------------------------------------------------------------
;
UpdateLoop
		jsr WaitJiffy   ; wait for vblank

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
		bra UpdateLoop

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
;
; Clut Buffer
;
pal_buffer
		ds 1024

;------------------------------------------------------------------------------

	put i256.s

;------------------------------------------------------------------------------

video_init mx %00

		; 800x600
		;lda #$100+Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_Bitmap_En+Mstr_Ctrl_GAMMA_En+Mstr_Ctrl_TileMap_En
		lda #$100+Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_GAMMA_En+Mstr_Ctrl_TileMap_En
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
; Extract CLUT data from the stars image
;
		; source picture
		pea ^piano_pic
		pea piano_pic

		; destination address
		pea ^pal_buffer
		pea pal_buffer

		jsl decompress_clut

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

