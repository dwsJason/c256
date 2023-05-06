;
;  Foenix Mouse Example in Merlin32
;
; $00:2000 - $00:7FFF are free for application use.
;
        rel     ; relocatable
        lnk     Main.l

        use Util.Macs
		put phx\vicky_ii_def.asm
		put phx\VKYII_CFP9553_BITMAP_def.asm
		put phx\VKYII_CFP9553_TILEMAP_def.asm
		
		ext background_pic,mouse_tiles,mouse_map
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
pCLUT          = 38
pPIXL		   = 42
temp5          = 46
temp6		   = 50
temp7          = 54
			  

MOUSE_PTR        = $0000E0
MOUSE_POS_X_LO   = $0000E1
MOUSE_POS_X_HI   = $0000E2
MOUSE_POS_Y_LO   = $0000E3
MOUSE_POS_Y_HI   = $0000E4

;
; Decompress to this address
;
pixel_buffer = $100000	; need about 480k, put it in memory at 1.25MB mark
						; try to leave room for kernel on a U
		
; Kernel method
PUTS = $00101C         ; Print a string to the currently selected channel

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

; Default Stack is on top of System DMA Registers
; So move the stack before proceeding

        lda #$BFFF      ; I really don't know much RAM the kernel is using in bank 0
        tcs

        lda #MyDP
        tcd

		;lda #$014C  		  	; 800x600 + Gamma + Bitmap_en
		lda #$100+Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_Bitmap_En+Mstr_Ctrl_GAMMA_En+Mstr_Ctrl_TileMap_En
;		lda #$100+Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_GAMMA_En+Mstr_Ctrl_TileMap_En
		sta >MASTER_CTRL_REG_L

		lda #BM_Enable
		sta >BM1_CONTROL_REG

		lda	#VRAM
		sta >BM1_START_ADDY_L
		lda #0
		;lda #>VRAM
		sta >BM1_START_ADDY_M
		;lda #^VRAM
		lda #0
		sta >BM1_START_ADDY_H

		lda #0
		sta >BM1_X_OFFSET
		sta >BM1_Y_OFFSET
		sta >BM0_CONTROL_REG  ; disable bitmap 1
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
		
		lda #400
		sta >TL0_WINDOW_X_POS_L
		lda #600
		sta >TL0_WINDOW_Y_POS_L
		
		lda #VRAM_TILE_CAT
		sta >TILESET0_ADDY_L
		sta >TILESET1_ADDY_L
		lda #^{VRAM_TILE_CAT-VRAM}
		sta >TILESET0_ADDY_H
		inc
		sta >TILESET1_ADDY_H
		
;
; Extract CLUT data from the title image
;
		; source picture
		pea ^background_pic
		pea background_pic

		; destination address
		pea ^pal_buffer
		pea pal_buffer

		jsl decompress_clut

        ; Copy over the LUT
        ldy     #GRPH_LUT0_PTR  ; dest
        ldx     #pal_buffer  	; src
        lda     #1024-1			; length
        mvn     ^pal_buffer,^GRPH_LUT0_PTR    ; src,dest

		phk
		plb

        ; Set Background Color
		sep #$30
        lda	|pal_buffer
        sta >BACKGROUND_COLOR_B ; back
        lda |pal_buffer+1
        sta  >BACKGROUND_COLOR_G ; back
        lda |pal_buffer+2
        sta  >BACKGROUND_COLOR_R ; back
		rep #$30


;
; Extract pixels from the title image
;
		; source picture
		pea ^background_pic
		pea background_pic

		; destination address
		pea ^pixel_buffer
		pea pixel_buffer

		jsl decompress_pixels
		
;
; Extract the CLUT from the tile catalog
;
		; source picture
		pea ^mouse_tiles
		pea mouse_tiles

		; destination address
		pea ^pal_buffer
		pea pal_buffer

		jsl decompress_clut
		
        ; Copy over the LUT
        ldy     #GRPH_LUT1_PTR  ; dest
        ldx     #pal_buffer  	; src
        lda     #1024-1			; length
        mvn     ^pal_buffer,^GRPH_LUT1_PTR    ; src,dest

		phk
		plb


		; copy to VRAM
]count = 0
		lup 8
]source = pixel_buffer+{]count*$10000}
]dest   = VRAM+{]count*$10000}
		lda #0
		tax
		tay
		dec
		mvn ^]source,^]dest
]count = ]count+1
		--^

		phk
		plb

		
;
; Extract Pixels from the tile catalog
;
		; source
		pea ^mouse_tiles
		pea mouse_tiles
		; dest
		pea ^pixel_buffer
		pea pixel_buffer
		
		jsl decompress_pixels
		
		; copy to VRAM		
]count = 0
		lup 2
]source = pixel_buffer+{]count*$10000}
]dest   = VRAM_TILE_CAT+{]count*$10000}
		lda #0
		tax
		tay
		dec
		mvn ^]source,^]dest
]count = ]count+1
		--^
		
		phk
		plb		

;
; Decompress STM
;		
		; lzsa2 compressed shit
		pea ^mouse_map
		pea mouse_map
;		; decompress address
		pea ^pixel_buffer
		pea pixel_buffer
;		
		jsl decompress_lzsa
		
;
; Copy the STM data into vram
; lives at VRAM_TILE_MAP
;
; just hard code this, for now, but eventually
; make this part of the .256 picture format
;
; STMP seems to be using 32 bit indices into the catalog
; we need to tone this down to 16 bit
;		
:pSrc = temp0
:pDst = temp1
:width = temp2
:height = temp2+2
:count = temp3
			
	lda #<pixel_buffer
	sta <:pSrc
	lda #^pixel_buffer
	sta <:pSrc+2
	
	lda #<VRAM_TILE_MAP
	sta <:pDst
	lda #^VRAM_TILE_MAP
	sta <:pDst+2
	
	jsr :read16	 ; ST
	jsr :read16  ; MP
	
	; fetch width, height
	jsr :read16
	sta <:width
	sta >TL0_TOTAL_X_SIZE_L
	jsr :read16
	sta <:height
	sta >TL0_TOTAL_Y_SIZE_L
]outloop
	lda <:width
	sta <:count
]line_loop	
	jsr :read16
	ora #$0800  ; LUT1
	jsr :write16
	jsr :read16 ; discard
	
	dec <:count
	bne ]line_loop
	
	dec <:height
	bne ]outloop

	bra :continue

:read16
	lda [:pSrc]
	inc <:pSrc
	inc <:pSrc
	rts
:write16
	sta [:pDst]
	inc <:pDst
	inc <:pDst
	rts

:continue

	cli
	lda #0
	sta >MOUSE_PTR_CTRL_REG_L	

;	jsr InstallJiffy

:mouse_loop
	sec
	lda #800
	sbc >MOUSE_PTR_X_POS_L
	sta >TL0_WINDOW_X_POS_L
	sec
	lda #600
	sbc >MOUSE_PTR_Y_POS_L
	sta >TL0_WINDOW_Y_POS_L
	
	bra :mouse_loop

;-------------------------------------------------------------------------------

end
        bra     end

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

InvalidHeader asc 'Invalid C256 Header Block'
        db 13,0

MissingClut asc 'No CLUT found'
        db 13,0

MissingPixl asc 'No PIXL found'
        db 13,0


;------------------------------------------------------------------------------
;
; Clut Buffer
;
pal_buffer
		ds 1024

;------------------------------------------------------------------------------

	put i256.s
