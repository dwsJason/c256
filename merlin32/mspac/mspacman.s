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
        rel     ; relocatable
        lnk     Main.l

        use Util.Macs

; External Addresses

		ext title_pic
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
pixel_buffer = $100000	; need about 120k, put it in memory at 1.25MB mark
			; try to leave room for kernel on a U


; Kernel method
;PUTS = $00101C         ; Print a string to the currently selected channel



VRAM = $B00000

VICKY_BITMAP0 = $000000

; Ms Pacman Memory Defines

]VIDEO_MODE = Mstr_Ctrl_Graph_Mode_En
]VIDEO_MODE = ]VIDEO_MODE+Mstr_Ctrl_TileMap_En
]VIDEO_MODE = ]VIDEO_MODE+Mstr_Ctrl_Sprite_En
]VIDEO_MODE = ]VIDEO_MODE+Mstr_Ctrl_GAMMA_En
]VIDEO_MODE = ]VIDEO_MODE+$100                                       ; +800x600

VICKY_MAP_TILES    = $000000
VICKY_SPRITE_TILES = $010000
VICKY_MAP0         = $020000   			      ; MAP Data for tile map 0
VICKY_MAP1         = VICKY_MAP0+{64*64*2}	      ; MAP Data for tile map 1
VICKY_MAP2         = VICKY_MAP1+{64*64*2}	      ; MAP Data for tile map 2
VICKY_MAP3         = VICKY_MAP2+{64*64*2}	      ; MAP Data for tile map 3

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

		jsr ShowTitlePage

;------------------------------------------------------------------------------
;
		jsr InitMsPacVideo

		; Convert the Tiles so we can see them
		jsr TestTiles

		; Convert the Sprites so we can see them!
		jsr TestSprites

		; Wait 1 second
		lda #60
]lp 		jsr WaitVBL
		dec
		bpl ]lp

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

		jmp JasonTestStuff

;------------------------------------------------------------------------------
;
; Begin Actual MsPacman!!!
;
;------------------------------------------------------------------------------

rst0
		sei					; Disable Interrupts
;		jmp	startuptest

	; rst 38 (vblank)
	; INTERRUPT MODE 1 handler
rst38




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

		bra ]next

end 	bra     end

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
; void decompress_pixels(void* pDestBuffer, void* pC256Bitmap
;
; pea ^p256Image
; pea #p256Image
;
; pea ^pDestBuffer
; pea pDestBuffer
;
; jsl decompress_pixels
;
decompress_pixels mx %00
:pImage = 10
:pDest  = 6
:blobCount = temp5
:zpDest    = temp6
:size      = temp7

		phd 			; preserver DP

		tsc

		sec
		sbc	#256 		; A temporary DP on the stack	
						; which is fine, as long as I stick
						; to the bottom, and don't call too deep

		tcd

		; Destination Buffer Address
		; copy to Direct Page
		lda :pDest,s
		sta <:zpDest
		lda :pDest+2,s
		sta <:zpDest+2

		; Parse Header, Init Chunk Crawler
		lda	:pImage+2,s
		tax
		lda :pImage,s
		jsr	c256Init
		bcs :error

		ldy #8
		lda [pPIXL],y
		sta <:blobCount

		; pPIXL, is the pointer to the PIXL structure
		lda <pPIXL
		adc #10
		sta <pPIXL
		lda <pPIXL+2
		adc #0
		sta <pPIXL+2
]loop
		lda [pPIXL]
		sta <:size	  ; decompressed size
		bne :compressed

		; Raw Data copy of 65636 bytes
		ldy #0
]rawlp
		lda [pPIXL],y
		sta [:zpDest],y
		iny
		iny
		bne ]rawlp

		inc :zpDest+2
		inc <pPIXL+2

		bra :blob

:compressed
		jsr :incpPIXL

		pei <pPIXL+2
		pei <pPIXL
		pei <:zpDest+2
		pei <:zpDest
		jsl decompress_lzsa
:blob
		dec <:blobCount
		beq :done

		inc <:zpDest+2

		clc
		lda <pPIXL
		adc	<:size
		sta <pPIXL
		lda <pPIXL+2
		adc #0
		sta <pPIXL+2
		bra ]loop

:done
:error
	; Copy the Return address + D
		lda 1,s
		sta 9,s
		lda 3,s
		sta 11,s
		lda 4,s
		sta 12,s

		tsc 		   	; pop args off stack
		sec
		sbc #-8
		tcs

		pld 			; restore DP
		rtl
:incpPIXL
		clc
		lda <pPIXL
		adc #2
		sta <pPIXL
		lda <pPIXL+2
		adc #0
		sta <pPIXL+2
		rts


;------------------------------------------------------------------------------
; void decompress_clut(void* pDestBuffer, void* pC256Bitmap
;
; pea ^p256Image
; pea #p256Image
;
; pea ^pDestBuffer
; pea pDestBuffer
;
; jsl decompress_clut
;
decompress_clut mx %00
:pImage = 10
:pDest  = 6
:colorCount = temp5
:zpDest    = temp6
:size      = temp7

		phd 			; preserver DP

		tsc

		sec
		sbc	#256 		; A temporary DP on the stack
						; which is fine, as long as I stick
						; to the bottom, and don't call too deep

		tcd

		; Destination Buffer Address
		; copy to Direct Page
		lda :pDest,s
		sta <:zpDest
		lda :pDest+2,s
		sta <:zpDest+2

		; Parse Header, Init Chunk Crawler
		lda	:pImage+2,s
		tax
		lda :pImage,s
		jsr	c256Init
		bcs :error

		ldy #8
		lda [pCLUT],y
		sta <:colorCount

		; pCLUT, is the pointer to the CLUT structure
		lda <pCLUT
		adc #10
		sta <pCLUT
		lda <pCLUT+2
		adc #0
		sta <pCLUT+2

		lda <:colorCount
		bmi :compressed

		; raw
		asl
		asl
		;sta <:size  ; size of raw data in bytes
		tay
		beq :done
		dey
		dey
]rawlp
		lda [pCLUT],y
		sta [:zpDest],y
		dey
		dey
		bpl ]rawlp
		bra :done

:compressed

		pei <pCLUT+2
		pei <pCLUT
		pei <:zpDest+2
		pei <:zpDest
		jsl decompress_lzsa

:done
:error

	; Copy the Return address + D
		lda 1,s
		sta 9,s
		lda 3,s
		sta 11,s
		lda 4,s
		sta 12,s

		tsc 		   	; pop args off stack
		sec
		sbc #-8
		tcs

		pld 			; restore DP

		rtl

;------------------------------------------------------------------------------
;
;  FindChunk
;       Inputs:  pData            (pointer to first chunk in the file)
;                i32EOF_Address   (first RAM address past the end of the file)
;
;        AX     'ABCD' - Chunk Name to Find
;
;  Return:  AX   - Pointer to the Chunk
;
FindChunk mx    %00

:pWork  = temp0
:pName  = temp1
:EOF    = i32EOF_Address
:size   = temp2

        sta <:pName
        stx <:pName+2

        lda <pData
        sta <:pWork
        lda <pData+2
        sta <:pWork+2

;  while :pWork < :EOF
]loop
        lda <:pWork+2
        cmp <:EOF+2
        bcc :continue  ; blt
        bne :nullptr   ; bgt
        lda <:pWork
        cmp <:EOF
        bcs :nullptr   ; bge
:continue
        lda [<:pWork]
        cmp <:pName
        bne :nextChunk
        ldy #2
        lda [<:pWork],y
        cmp <:pName+2
        bne :nextChunk

        ; Match found, return with the address
        lda <:pWork
        ldx <:pWork+2
        rts

:nextChunk
        ldy #4
        lda [<:pWork],y
        sta <:size
        iny
        iny
        lda [<:pWork],y
        sta <:size+2

        ; Move pWork to the next Chunk
        clc
        lda <:pWork
        adc <:size
        sta <:pWork
        lda <:pWork+2
        adc <:size+2
        sta <:pWork+2
        
        bra ]loop

:nullptr
        ; Return nullptr
        lda #0
        tax

        rts

;-------------------------------------------------------------------------------
;
;  AX = Pointer to the compressed C256 Image file
;
;  For the Chunk Finder, alignment doesn't matter
;
c256Init mx %00
        sta     <pData
        stx     <pData+2

        jsr     c256ParseHeader
        bcc     :isGood
        ldx     #InvalidHeader
        rts

:isGood
        ; Now pData is supposed to be pointed at the first chunk
        ; And data should be moved out of the header and into the DP
        lda     #'CL'
        ldx     #'UT'
        jsr     FindChunk
        sta     <pCLUT
        stx     <pCLUT+2

        ora     <pCLUT+2
        bne     :hasClut

        ldx     #MissingClut
        sec
        rts

:hasClut
        lda     #'PI'
        ldx     #'XL'
        jsr     FindChunk
        sta     <pPIXL
        stx     <pPIXL+2

        ora     pPIXL+2
        bne     :hasPixl

        ldx     #MissingPixl
        sec
        rts

:hasPixl
        ; c=0 everything is good
        clc
        rts

;-------------------------------------------------------------------------------
; Direct Page Location
; pData should be pointing at the Header
;
;	char 			i,2,5,6;  // 'I','2','5','6'
;
;	unsigned int 	file_length;  // In bytes, including the 16 byte header
;
;	short			version;  // 0x0000 for now
;	short			width;	  // In pixels
;	short			height;	  // In pixels
;   short           reserved;
;
c256ParseHeader mx %00

        ; Check for 'I256'
        lda [pData]
        cmp #'I2'
        bne :BadHeader
        ldy #2

        lda [pData],y
        cmp #'56' 
        bne :BadHeader
        iny
        iny

        ; Copy out FileLength
        lda [pData],y
        sta <i32FileLength
        iny
        iny
        lda [pData],y
        sta <i32FileLength+2
        iny
        iny

        ; Compute the end of file address
        clc
        lda <pData
        adc <i32FileLength
        sta <i32EOF_Address
        lda pData+2
        adc <i32FileLength+2
        sta <i32EOF_Address+2
        bcs :BadHeader          ; overflow on memory address


        ; Look at the File Version
        lda [pData],y
        iny
		iny
        sta <i16Version
		and #$FFFF
        bne :BadHeader  ; only version zero is acceptable

        ; Get the width and height
        lda [pData],y
        sta <i16Width
        iny
        iny
        lda [pData],y
        sta <i16Height
        iny
        iny

        ; Reserved
        iny
        iny

        ; c=0
        tya
        adc <pData
        sta <pData
        lda #0
        adc <pData+2
        sta <pData+2
        ; c=0 mean's there's no error
        rts

:BadHeader
        sec     ; c=1 means there's an error
        rts



;------------------------------------------------------------------------------
;
; Clut Buffer
;
pal_buffer
		ds 1024

;------------------------------------------------------------------------------

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

:JiffyTimer
;		pha					   ; 4
;		lda >{MyDP+dpJiffy}    ; 6
;		inc					   ; 2
;		sta >{MyDP+dpJiffy}    ; 6
;		pla					   ; 5
;		rtl

		phb 				   ; 3
		phk 				   ; 3
		plb 				   ; 4
		inc |{MyDP+dpJiffy}    ; 6
		plb 				   ; 4
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
; Decompress and Display the Title Page
;
ShowTitlePage mx %00

		lda #Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_Bitmap_En+Mstr_Ctrl_GAMMA_En+$100  		  	; 800x600 + Gamma + Bitmap_en
		sta >MASTER_CTRL_REG_L

		lda #BM_Enable
		sta >BM0_CONTROL_REG

		lda	#VICKY_BITMAP0
		sta >BM0_START_ADDY_L
		lda #^VICKY_BITMAP0
		sta >BM0_START_ADDY_H

		lda #0
		sta >BM0_X_OFFSET
		sta >BM0_Y_OFFSET
		sta >BM1_CONTROL_REG

;------------------------------------------------------------------------------

		sta >BORDER_X_SIZE
		sta >BORDER_Y_SIZE

		sta >BORDER_COLOR_B
		sta >BORDER_COLOR_R		; Zero R, and Disable the Blinky Cursor

;------------------------------------------------------------------------------

;
; Extract CLUT data from the title image
;
		; source picture
		pea ^title_pic
		pea title_pic

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
		pea ^title_pic
		pea title_pic

		; destination address
		pea ^pixel_buffer
		pea pixel_buffer

		jsl decompress_pixels

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

;------------------------------------------------------------------------------
; Wait 1 second
		lda #59
]lp 	jsr WaitVBL
		dec
		bpl ]lp
;------------------------------------------------------------------------------

		rts

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

		ldx #Border_Ctrl_Enable
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

		; Set the Background Color
		stz |BACKGROUND_COLOR_B  	 ; Black
		stz |BACKGROUND_COLOR_G

;---------------------------------------------------------

; Default the first 4 colors of LUT0

		ldx #0
		clc
]loop
		; Black
		stz |GRPH_LUT0_PTR,x
		stz |GRPH_LUT0_PTR+2,x 

		; Dark Grey
		lda #$5050
		sta |GRPH_LUT0_PTR+4,x 
		sta |GRPH_LUT0_PTR+6,x 

		; Dark Grey
		lda #$A0A0
		sta |GRPH_LUT0_PTR+8,x 
		sta |GRPH_LUT0_PTR+10,x 

		; White
		lda #$FFFF
		sta |GRPH_LUT0_PTR+12,x 
		sta |GRPH_LUT0_PTR+14,x 

		txa
		adc #$400
		tax
		cpx #$2000
		bcc ]loop

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

:pVRAM = temp1
:counter = temp2
:bitcount = temp3

		lda #tile_ram
		sta <:pVRAM

		lda #30 	 	; the output size of the pilldata, also loop counter
		sta <:counter

		lda #PelletTable ; lookup table address
		sta <temp0

		jsr ChooseMaze
		tay 				; pointer to source pellet table

	    ldx #pilldata		; pointer to output pill table data
]lp
		lda #8				; 8 bits in the byte
		sta <:bitcount
]plp
		lda |0,y 			; load the pellet table, adjust offset into vram
		and #$FF
		clc
		adc <:pVRAM
		sta <:pVRAM

		sep #$20			; a short

		lda |0,x			; load A with pill entry
		asl
		bcc :no_pill

		pha

		lda #16 	 		; tile # for a pelette
		sta (:pVRAM)		; draw pill

		pla
:no_pill
	    iny					; next table data
		dec <:bitcount
		rep #$30			; a long again
		bne ]plp

		inx					; next pill entry
		dec <:counter
		bne ]lp

		rts


;------------------------------------------------------------------------------
;
; 246f
DrawPowerPills mx %00

		lda #PowerPelletTable		; Lookup Table Address
		sta <temp0

		jsr ChooseMaze
		tay							; address of pelette table for this map

; Draw 4 Power Pills

		lda |0,y
		tax							; x = vram address
		sep #$20
		lda |powerpills				; first power pill
		sta |0,x					; store to VRAM
		rep #$20

		lda |2,y
		tax							; x = vram address
		sep #$20
		lda |powerpills+1			; 2nd power pill
		sta |0,x					; store to VRAM
		rep #$20

		lda |4,y
		tax							; x = vram address
		sep #$20
		lda |powerpills+2			; 3rd power pill
		sta |0,x					; store to VRAM
		rep #$20

		lda |6,y
		tax							; x = vram address
		sep #$20
		lda |powerpills+3			; 4th power pill
		sta |0,x					; store to VRAM
		rep #$20

		rts

; 24d7
task_colorMaze mx %00
;------------------------------------------------------------------------------
;
; Color the Maze
;
; 24dd
		
ColorMaze mx %00

		jsr GetLevelColor
		; now A has the fill color

;24e1
		ldx #palette_ram+$40  ; location in palette ram

		; mirror color in low and high, for 16 bit stores
		pha
		xba
		ora 1,s
		sta 1,s
		pla

		ldy #100	; storing out 200 times, but 16 bit per store
]lp
		sta |0,x
		inx
		inx
		dey
		bne ]lp
; 24eb

		; color top bar white
		ldx #palette_ram+$3C0
		lda #$0F0F		; white
		ldy #20
]lp
		sta |0,x
		inx
		inx
		dey
		bne ]lp

;$$TODO, finish task business and mark SLOW Areas


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
		da Maze2	; 8bae
		da Maze3	; 8ea8
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

PowerPelletTable
		da Power1   ; #8B35 ; maze 1 power pellet address table 
		da Power2   ; #8E20 ; maze 2 power pellet address table 
		da Power3   ; #9112 ; maze 3 power pellet address table 
		da Power4   ; #93FA ; maze 4 power pellet address table

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


	;; entrance fruit paths for maze 1:  #8b4f - #8b81
;8b4f
		db $63,$8B				; #8B63
		db $13,$94,$0C
		db $68,$8B				; #8B68
		db $22,$94,$F4
		db $71,$8B				; #8B71
		db $27,$4C,$F4
		db $7B,$8B				; #8B7B
		db $1C,$4C,$0C
		db $80,$AA,$AA,$BF,$AA
		db $80,$0A,$54,$55,$55,$55,$FF,$5F,$55
		db $EA,$FF,$57,$55,$F5,$57,$FF,$15,$40,$55
		db $EA,$AF,$02,$EA,$FF,$FF,$AA

	;; exit fruit paths for maze 1
;8b82
		db $94,$8B				; #8B94
		db $14,$00,$00
		db $99,$8B				; #8B99
		db $17,$00,$00
		db $9F,$8B				; #8B9F
		db $1A,$00,$00
		db $A6,$8B				; #8BA6
		db $1D
		db $55,$40,$55,$55,$BF
		db $AA,$80,$AA,$AA,$BF,$AA
		db $AA,$80,$AA,$02,$80,$AA,$AA
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

	;; entrance fruit paths for maze 2:  #8E40-8E72
	;; $$TODO  fix all these address pointers to point to labels

;8e40
		db $54,$8E				; #8E54
		db $13,$C4,$0C
		db $59,$8E				; #8E59
		db $1E,$C4,$F4
		db $61,$8E				; #8E61
		db $26,$14,$F4
		db $6B,$8E				; #8E6B
		db $1D,$14,$0C
		db $02,$AA,$AA,$80,$2A
		db $02,$40,$55,$7F,$55,$15,$50,$05
		db $EA,$FF,$57,$55,$F5,$FF,$57,$7F,$55,$05
		db $EA,$FF,$FF,$FF,$EA,$AF,$AA,$02


	;; exit fruit paths for maze 2
	;; $$TODO  fix all these address pointers to point to labels
;8e73
		db $87,$8E				; #8E87
		db $12,$00,$00
		db $8C,$8E				; #8E8C
		db $1D,$00,$00
		db $94,$8E				; #8E94
		db $21,$00,$00
		db $9D,$8E				; #8E9D
		db $2C,$00,$00,$
		db $55,$7F,$55,$D5,$FF
		db $AA,$BF,$AA,$2A,$A0,$EA,$FF,$FF
		db $AA,$2A,$A0,$02,$00,$00,$A0,$AA,$02
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
		db $2E,$91				; #912E
		db $15,$54,$0C
		db $34,$91				; #9134
		db $1E,$54,$F4
		db $34,$91				; #9134
		db $1E,$54,$F4
		db $3C,$91				; #913C
		db $15,$54,$0C

;912e
		db $EA,$FF,$AB,$FA,$AA,$AA
		db $EA,$FF,$57,$55,$55,$D5,$57,$55
		db $AA,$AA,$BF,$FA

	;; exit fruit paths for maze 3
;9142
		db $56,$91				; #9156
		db $22,$00,$00
		db $5f,$91				; #915F
		db $25,$00,$00
		db $5f,$91				; #915F
		db $25,$00,$00
		db $6f,$91				; #916F
		db $28,$00,$00

;9156
		db $05,$00,$00,$54,$05,$54,$7F,$F5,$0B
		db $0A,$00,$00,$A8,$0A,$A8,$BF,$FA,$AB,$AA,$AA,$82,$AA,$00,$A0,$AA
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
		db $1d,$22				; column 22, row 1D (top right)
		db $40,$20				; column 20, row 40 (bottom right)
		db $1d,$39				; column 39, row 1D (top left)
		db $40,$3b				; column 3B, row 40 (bottom left)

	;; entrance fruit paths for maze 4:  #940A - #943B
;940a
		db $1E,$94				; #941E
		db $14,$8C,$0C
		db $23,$94				; #9423
		db $1D,$8C,$F4
		db $2B,$94				; #942B
		db $2A,$74,$F4
		db $36,$94				; #9436
		db $15,$74,$0C
		db $80,$AA,$BE,$FA,$AA
		db $00,$50,$FD,$55,$F5,$D5,$57,$55
		db $EA,$FF,$57,$D5,$5F,$FD,$15,$50,$01,$50,$55
		db $EA,$AF,$FE,$2A,$A8,$AA


	;; exit fruit paths for maze 4
;943c
		db $50,$94				; #9450
		db $15,$00,$00
		db $56,$94				; #9456
		db $18,$00,$00
		db $5C,$94				; #945C
		db $19,$00,$00	
		db $63,$94				; #9463
		db $1C,$00,$00

		db $55,$50,$41,$55,$FD,$AA
		db $AA,$A0,$82,$AA,$FE,$AA
		db $AA,$AF,$02,$2A,$A0,$AA,$AA
		db $55,$5F,$01,$00,$50,$55,$BF


;
; All the pacman RAM definitions
;
		put ram.s

;
; All the pacman Task functions
;
		put tasks.s

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
BlitMap mx %00

:row_offset = temp0
:cursor	    = temp1
:count      = temp2

		lda #$3A0
		sta <:row_offset

		ldy #tile_ram
		ldx #64*6+{{25-14}*2}+2

]row_loop

		sta <:cursor

		lda #28
		sta <:count

]col_loop

		lda (:cursor),y
		and #$FF

		sta >VRAM+VICKY_MAP0,x
		inx
		inx

		; increment cursor
		sec
		lda <:cursor
		sbc #$20
		sta <:cursor

		dec <:count
		bne	]col_loop

		; adjust destination in tile map
		txa
		; c=0
		clc
		adc #{64*2}-{28*2}
		tax

		lda <:row_offset
		inc
		sta <:row_offset
		cmp #$3C0
		bcc ]row_loop

;------------------------------------------------------------------------------
; temp test code

		lda |level
		ldx #VICKY_MAP0+{64*2}+4
		jsr PrintHex

		rts

;------------------------------------------------------------------------------

PrintHex 	mx %00

		phb
		pea >{VRAM+VICKY_MAP0}
		plb
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
LOOP
	STA DECWORK
	ADC DECWORK
	ROL DECOUT
	ASL HEXIN
	BNE LOOP
	CLD
	RTS

;------------------------------------------------------------------------------
;
; demo or game is playing
;
; 08CD;
game_playing mx %00
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

;08f4  cd420c    call    #0c42		; adjust movement of ghosts if moving out of ghost house
;08f7  cd230e    call    #0e23		; change animation of ghosts every 8th frame
;08fa  cd360e    call    #0e36		; periodically reverse ghost direction based on difficulty (only when energizer not active)
;08fd  cdc30a    call    #0ac3		; handle ghost flashing and colors when power pills are eaten
;0900  cdd60b    call    #0bd6		; color dead ghosts the correct colors
;0903  cd0d0c    call    #0c0d		; handle power pill (dot) flashes
;0906  cd6c0e    call    #0e6c		; change the background sound based on # of pills eaten
;0909: CD AD 0E	 call	#0EAD		; check for fruit to come out.  (new ms. pac sub actually at #86EE.)
;090C: C9	ret			; return ( to #0195 )

	    rts

;------------------------------------------------------------------------------
; called from #052C, #052F, #08EB and #08EE 
; 1017
pm1017      mx %00

	    jsr	mspac_death_update

	    lda |pacman_dead_state	; skip out early if dead squence playing
	    bne :continue

	    rts

:continue

	    jsr eatghosts		; check for ghosts being eaten and set ghost states accordingly
;1022  cd9410    call    #1094		; check for red ghost state and do things if not alive
;1025  cd9e10    call    #109e		; check for pink ghost state and do things if not alive
;1028  cda810    call    #10a8		; check for blue ghost (inky) state and do things if not alive
;102b  cdb410    call    #10b4		; check for orange ghost state and do things if not alive
;102e  3aa44d    ld      a,(#4da4)	; load A with # of ghost killed but no collision for yet [0..4]
;1031  a7        and     a		; == #00 ?
;1032  ca3910    jp      z,#1039		; yes, skip ahead
;
;1035  cd3512    call    #1235		; no, call this sub
;1038  c9        ret     		; and return
;
;1039  cd1d17    call    #171d		; check for collision with regular ghosts
;103c  cd8917    call    #1789		; check for collision with blue ghosts
;103f  3aa44d    ld      a,(#4da4)	; load A with # of ghost killed but no collision for yet [0..4]
;1042  a7        and     a		; is there a collsion ?
;1043  c0        ret     nz		; yes, return
;
;1044  cd0618    call    #1806		; handle all pac-man movement
;1047  cd361b    call    #1b36		; control movement for red ghost
;104a  cd4b1c    call    #1c4b		; control movement for pink ghost
;104d  cd221d    call    #1d22		; control movement for blue ghost (inky)
;1050  cdf91d    call    #1df9		; control movement for orange ghost
;1053  3a044e    ld      a,(#4e04)	; load A with level state subroutine #
;1056  fe03      cp      #03		; is a game being played ?
;1058  c0        ret     nz		; no, return
;
;1059  cd7613    call    #1376		; control blue ghost timer and reset ghosts when it is over or when pac eats all blue ghosts
;105c  cd6920    call    #2069		; check for pink ghost to leave the ghost house
;105f  cd8c20    call    #208c		; check for blue ghost (inky) to leave the ghost house
;1062  cdaf20    call    #20af		; check for orange ghost to leave the ghost house

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
; arrive here from call at #08F1
; 13dd
ghosthouse mx %00
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
	    txa
	    cmp |pacman_dead_counter
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

