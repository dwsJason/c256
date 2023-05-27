;
; Search for UpdateLoop
;

;
;  Foenix Stars Example in Merlin32
;
; $00:2000 - $00:7FFF are free for application use.
;
        rel     ; relocatable
        lnk     Main.l

		; hardware includes from the kernel source code
		put phx\vicky_ii_def.asm
		put phx\VKYII_CFP9553_TILEMAP_def.asm
		put phx\interrupt_def.asm

		; kernel things
		put phx\kernel_inc.asm
		
		ext decompress_lzsa

        mx %00

;------------------------------------------------------------------------------
; Direct Page Equates
lzsa_sourcePtr = 0
lsza_destPtr   = 4
lzsa_matchPtr  = 8
lzsa_nibble    = 12
lzsa_suboffset = 14
lzsa_token     = 16

temp0	= 0
temp1   = 4
temp2   = 8
temp3   = 12
temp4   = 16

i32EOF_Address = 20
i32FileLength  = 24
pData          = 28
i16Version     = 32
i16Width       = 34
i16Height      = 36
pCLUT          = 38  ; pointer to CLUT Structure
pPIXL		   = 42  ; pointer to PIXL Structure
pTMAP          = 46  ; pointer to TMAP Structure
temp5          = 50
temp6		   = 54
temp7          = 58
temp8          = 62


			  
;
; Decompress to this address
;
work_buffer = $100000	; need only about 11K of temp room for this demo
						; just picking a place way out in RAM
		
; Some HW Addresses - Defines

VRAM = $B00000
VRAM_TILE_MAP = $B80000  ; tile map
VRAM_TILE_CAT = $B90000  ; tile catalog

;------------------------------------------------------------------------------
; I like having my own Direct Page
MyDP = $2000
dpJiffy       = 128

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

		; Put the system into 320x240 mode, with only TileMaps enabled
		lda #$200+Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_GAMMA_En+Mstr_Ctrl_TileMap_En
		sta >MASTER_CTRL_REG_L

		; No Border
		lda #0
		sta >BORDER_X_SIZE    ; also sets the BORDER_Y_SIZE
		
		; Tile maps off
		sta >TL0_CONTROL_REG
		sta >TL1_CONTROL_REG
		sta >TL2_CONTROL_REG
		sta >TL3_CONTROL_REG
		
		; turn on tile map 0, and see what happens
		lda #TILE_Enable
		sta >TL0_CONTROL_REG
		lda #<VRAM_TILE_MAP
		sta >TL0_START_ADDY_L
		lda #^{VRAM_TILE_MAP-VRAM}
		sta >TL0_START_ADDY_H
		
		lda #0
		sta >TL0_WINDOW_X_POS_L
		lda #16						; 16 here to skip over our "Tile catalog" at the top of the image
		sta >TL0_WINDOW_Y_POS_L
		
		lda #VRAM_TILE_CAT
		sta >TILESET0_ADDY_L
		sta >TILESET1_ADDY_L
		lda #^{VRAM_TILE_CAT-VRAM}
		sta >TILESET0_ADDY_H
		inc
		sta >TILESET1_ADDY_H	    ; by placing the next tileset after the first, we expand support to 512 tiles

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
; Extract CLUT data from the title image
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
		mvn ^work_buffer,^VRAM_TILE_MAP
		
		phk
		plb		

		jsr InstallJiffy

;
;------------------------------------------------------------------------------
;
UpdateLoop
		jsr WaitJiffy   ; wait for vblank

		; Scroll Horizontal, at 60FPS (silky)
		lda |BG0_SCROLL_X
		inc
		cmp #640
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
		dw 16
		dw 16+240
		dw 16+240+240
		dw 16+240+240+240
		dw 16+240+240+240+240
		dw 16+240+240+240+240+240

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

stars_pic
	putbin data\stars.256

