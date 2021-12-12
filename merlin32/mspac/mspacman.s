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

beql mac
    bne skip@
    jmp ]1
skip@
    <<<

bnel mac
    beq skip@
    jmp ]1
skip@
    <<<

bccl mac
    bcs skip@
    jmp ]1
skip@
    <<<

bcsl mac
    bcc skip@
    jmp ]1
skip@
    <<<

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
;]VIDEO_MODE = ]VIDEO_MODE+$200                                       ; pixel double/ half resolution

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
		do 0
		; Foenix U - Light Show
		phk
		plb
		ldy #0  ; color table index

		ldx #0  ; led array index
]loop
		jsr WaitVBL
		lda |:colors,y
		sta >$AF4400,x
		lda |:colors+2,y
		sta >$AF4400+2,x

		inx
		inx
		inx
		inx
		cpx #30*4
		bcc ]loop
		ldx #0

		iny
		iny
		iny
		iny
		cpy #8*4
		bcc ]loop
		ldy #0

		jmp ]loop


:colors
		hex FFFFFFFF  ; white
		hex FF0000FF  ; blue
		hex 00FF00FF  ; green
		hex 0000FFFF  ; red
		hex 000000FF  ; black
		hex FFFF00FF  ; blue
		hex FF00FFFF  ; purple
		hex 00FFFFFF  ; yello

		fin


		jmp JasonTestStuff

;------------------------------------------------------------------------------
;
; Begin Actual MsPacman!!!
;
;------------------------------------------------------------------------------

rst0 mx %00
		sei					; Disable Interrupts
;		jmp	startuptest

;;$$TODO, port the rst28 - Add task, with argument
rst28 mx %00
		rts

;;$$TODO, A=TNTM Y=param  TN=Task number, TM=Timer
rst30 mx %00
		rts

	; rst 38 (vblank)
	; INTERRUPT MODE 1 handler
rst38 mx %00
	    rts

;;$$TODO - Task
;; A=00TN, Y=param
;0042
task_add mx %00
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
;	short		version;      // 0x0000 for now
;	short		width;	      // In pixels
;	short		height;	      // In pixels
;   	short           reserved;
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
;0909: CDAD0E	 call	 #0EAD		; check for fruit to come out.  (new ms. pac sub actually at #86EE.)

	    rts   			; return ( to #0195 ) 

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
	    beq :rts
;
;1044  cd0618    call    #1806		; handle all pac-man movement
	    jsr pacman_movement
;1047  cd361b    call    #1b36		; control movement for red ghost
	    jsr control_red
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
	    sec
	    sbc #$8064
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
	    sta |blueghost_state
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
	    bne :next
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

;1272  21d14d    ld      hl,#4dd1	; load HL with killed ghost animation state
;1275  34        inc     (hl)		; increase to next type
	    inc |dead_ghost_anim_state
;1276  c9        ret     		; return
	    rts

; arrive here when score for eating a ghost is set to dissapear
:next
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

; else arrive here when eating a blue ghost

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
	    bcc :check_blue
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
	    bcs :collided

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
	    bcc :check_pink
;
;17c4  3a054d    ld      a,(#4d05)	; yes, load A with inky's X position
	    lda |blue_ghost_x
;17c7  dd9601    sub     (ix+#01)	; subtract pacman's X position
	    sbc |pacman_x
;17ca  b9        cp      c		; <= #04 ?
	    cmp #4
;17cb  da6317    jp      c,#1763		; yes, jump back and set collision
	    bcs :collided

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
	    bcc :check_red
;
;17de  3a034d    ld      a,(#4d03)	; yes, load A with pink ghost X position
	    lda |pink_ghost_x
;17e1  dd9601    sub     (ix+#01)	; subtract pacman's X position
	    sbc |pacman_x
;17e4  b9        cp      c		; <= #04 ?
	    cmp #4
;17e5  da6317    jp      c,#1763		; yes, jump back and set collision
	    bcs :collided
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
	    bcc :red_dead
;
;17f8  3a014d    ld      a,(#4d01)	; yes, load A with red ghost X position
	    lda |red_ghost_x
;17fb  dd9601    sub     (ix+#01)	; subtract pacman's X position
	    sbc |pacman_x
;17fe  b9        cp      c		; <= #04 ?
	    cmp #4
;17ff  da6317    jp      c,#1763		; yes, jump back and set collision
	    bcs :collided
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
;1806  219d4d    ld      hl,#4d9d	; load HL with address of delay to update pacman movement
;1809  3eff      ld      a,#ff		; A := #FF = code for no delay
	    lda |move_delay


	; Hack code:
	; 1809  c3c01f	jp	#1fc0		; Intermission fast fix ; HACK8 (1 of 3)
	; 1809  c3d01f	jp	#1fd0		; P1P2 cheat  ; HACK3
	; 1809  c34c0f	jp	#0f4c		; pause cheat ; HACK5
	; end hack code


;180b  be        cp      (hl)		; is pacman slow due to the eating of a pill ?
	    cmp #$ffff

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
	    beq :no_delay
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
	    asl
;181c  224c4d    ld      (#4d4c),hl	; store result
	    sta |speedbit_bigpill+2
;181f  2a4a4d    ld      hl,(#4d4a)	; load HL with speed bit patterns for pacman in power pill state (high bytes)
	    lda |speedbit_bigpill
;1822  ed6a      adc     hl,hl		; double, with the carry = we have doubled the speed
	    asl
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
	    asl
;1833  22484d    ld      (#4d48),hl	; store result
	    sta |speedbit_normal+2
;1836  2a464d    ld      hl,(#4d46)	; load HL with speed for pacman in normal state (high bytes)
	    lda |speedbit_normal
;1839  ed6a      adc     hl,hl		; double with carry
	    asl
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
	    bcs :yes_tunnel

;185b  7e        ld      a,(hl)		; load A with pacman X tile position
	    lda |pacman_tile_pos_x
	    and #$FF
;185c  063b      ld      b,#3b		; B := #3B
;185e  90        sub     b		; subtract. is pacman pas the left edge of the screen?
	    cmp #$3B
;185f  3003      jr      nc,#1864        ; yes, skip ahead to handle tunnel movement
	    ;bcc :yes_tunnel
;1861  c3ab18    jp      #18ab		; no tunnel movement.  jump ahead to handle normal movement
	    bcs :normal_move

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
	    bcsl :demo_mode

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
		bccl :demo_mode

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
		bcs :corner_from_down

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
		bcs :corner_from_right

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
movement_check equ *
;1985  22084d    ld      (#4d08),hl	; store the new sprite position into pacman position
		lda <temp0
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
	    bcc :return

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
	    bcc :return

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
	    tay
	    lda #$19
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
	    lsr
	    tay
	    lda #$19

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
	    bcs :other_sound

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
:rts	    rts
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
	    asl |speedbit_red_tunnel
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
	    asl |speedbit_red_blue
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
	    asl |speedbit_difficult2
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
	    asl |speedbit_difficult
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
	    asl speedbit_red_normal
;1bd3  d0        ret     nc		; no, return
	    bcc :rts

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
	    beq :jump_ahead
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
	    lda #$0008
	    jsr rst28

:is_on_edge
;1c19  cdfe1e    call    #1efe		; check for and handle red ghost direction reversals
	    jsr check_reverse_red

;1c1c  dd211e4d  ld      ix,#4d1e	; load IX with red ghost tile changes
	    ldx #red_ghost_tchange_y
;1c20  fd210a4d  ld      iy,#4d0a	; load IY with red ghost tile position
	    ldx #redghost_tile_y
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
	    jsr |spr_to_tile
;1c47  22314d    ld      (#4d31),hl	; store into red ghost tile position 2 
	    sta |red_tile_y_2
;1c4a  c9        ret			; return
	    rts

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

;1d22  3aa24d    ld      a,(#4da2)	; load A with blue ghost (inky) substate
;1d25  fe01      cp      #01		; is blue ghost at home ?
;1d27  c0        ret     nz		; yes, return

;1d28  3aae4d    ld      a,(#4dae)	; else load A with blue ghost (inky) state
;1d2b  a7        and     a		; is inky alive ?
;1d2c  c0        ret     nz		; no, return

;1d2d  2a354d    ld      hl,(#4d35)	; load HL with inky tile position 2
;1d30  019b4d    ld      bc,#4d9b	; load BC with address of aux var used by inky to check positions
;1d33  cd5a20    call    #205a		; check to see if inky has entered a tunnel slowdown area
;1d36  3a9b4d    ld      a,(#4d9b)	; load A with aux var used by inky to check positions
;1d39  a7        and     a		; is inky in a tunnel slowdown area?
;1d3a  ca541d    jp      z,#1d54		; no, skip ahead

;1d3d  2a784d    ld      hl,(#4d78)	; yes, load HL with speed bit patterns for inky tunnel areas
;1d40  29        add     hl,hl		; double it
;1d41  22784d    ld      (#4d78),hl	; store result
;1d44  2a764d    ld      hl,(#4d76)	; load HL with speed bit patterns for inky tunnel areas
;1d47  ed6a      adc     hl,hl		; double it
;1d49  22764d    ld      (#4d76),hl	; store result.  have we exceeded the threshold?
;1d4c  d0        ret     nc		; no, return

;1d4d  21784d    ld      hl,#4d78	; yes, load HL with address of speed bit patterns for inky tunnel areas
;1d50  34        inc     (hl)		; increase
;1d51  c3861d    jp      #1d86		; skip ahead

;1d54  3aa94d    ld      a,(#4da9)	; load A with inky blue flag
;1d57  a7        and     a		; is inky edible ?
;1d58  ca721d    jp      z,#1d72		; no, skip ahead

;1d5b  2a744d    ld      hl,(#4d74)	; yes, load HL with speed bit patterns for inky in blue state
;1d5e  29        add     hl,hl		; double it
;1d5f  22744d    ld      (#4d74),hl	; store result
;1d62  2a724d    ld      hl,(#4d72)	; load HL with speed bit patterns for inky in blue state
;1d65  ed6a      adc     hl,hl		; double it
;1d67  22724d    ld      (#4d72),hl	; store result.  have we exceeded the threshold?
;1d6a  d0        ret     nc		; no, return

;1d6b  21744d    ld      hl,#4d74	; yes, load HL with speed bit patterns for inky in blue state
;1d6e  34        inc     (hl)		; increase
;1d6f  c3861d    jp      #1d86		; jump ahead

;1d72  2a704d    ld      hl,(#4d70)	; load HL with speed bit patterns for inky normal state
;1d75  29        add     hl,hl		; double it
;1d76  22704d    ld      (#4d70),hl	; store result
;1d79  2a6e4d    ld      hl,(#4d6e)	; load HL with speed bit patterns for inky normal state
;1d7c  ed6a      adc     hl,hl		; double it
;1d7e  226e4d    ld      (#4d6e),hl	; store result. have we exceeded the threshold ?
;1d81  d0        ret     nc		; no, return

;1d82  21704d    ld      hl,#4d70	; yes, load HL with speed bit patterns for inky normal state
;1d85  34        inc     (hl)		; increase


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

;1df9  3aa34d    ld      a,(#4da3)	; load A with orange ghost substate
;1dfc  fe01      cp      #01		; is orange ghost at home ?
;1dfe  c0        ret     nz		; yes, return
;
;1dff  3aaf4d    ld      a,(#4daf)	; else load A with orange ghost state
;1e02  a7        and     a		; is orange ghost alive ?
;1e03  c0        ret     nz		; no, return
;
;1e04  2a374d    ld      hl,(#4d37)	; load HL with orange ghost tile position 2
;1e07  019c4d    ld      bc,#4d9c	; load BC with address of aux var used by orange ghost to check positions
;1e0a  cd5a20    call    #205a		; check to see if orange ghost has entered a tunnel slowdown area
;1e0d  3a9c4d    ld      a,(#4d9c)	; load A with aux var used by orange ghost to check positions
;1e10  a7        and     a		; is the orange ghost in a tunnel slowdown area?
;1e11  ca2b1e    jp      z,#1e2b		; no, skip ahead
;
;1e14  2a844d    ld      hl,(#4d84)	; yes, load HL with speed bit patterns for orange ghost tunnel areas
;1e17  29        add     hl,hl		; double it
;1e18  22844d    ld      (#4d84),hl	; store result
;1e1b  2a824d    ld      hl,(#4d82)	; load HL with speed bit patterns for orange ghost tunnel areas
;1e1e  ed6a      adc     hl,hl		; double it
;1e20  22824d    ld      (#4d82),hl	; store result.  have we exceeded the threshold?
;1e23  d0        ret     nc		; no, return
;
;1e24  21844d    ld      hl,#4d84	; yes, load HL with speed bit patterns for orange ghost tunnel areas
;1e27  34        inc     (hl)		; increase
;1e28  c35d1e    jp      #1e5d		; skip ahead
;
;1e2b  3aaa4d    ld      a,(#4daa)	; load A with orange ghost blue flag
;1e2e  a7        and     a		; is the orange ghost blue ( edible ) ?
;1e2f  ca491e    jp      z,#1e49		; no, skip ahead
;
;1e32  2a804d    ld      hl,(#4d80)	; yes, load HL with speed bit patterns for orange ghost blue state
;1e35  29        add     hl,hl		; double it
;1e36  22804d    ld      (#4d80),hl	; store result
;1e39  2a7e4d    ld      hl,(#4d7e)	; load HL with speed bit patterns for orange ghost blue state
;1e3c  ed6a      adc     hl,hl		; double it
;1e3e  227e4d    ld      (#4d7e),hl	; store result.  have we exceeded the threshold ?
;1e41  d0        ret     nc		; no, return
;
;1e42  21804d    ld      hl,#4d80	; yes, load HL with speed bit patterns for orange ghost blue state
;1e45  34        inc     (hl)		; increase 
;1e46  c35d1e    jp      #1e5d		; skip ahead
;
;1e49  2a7c4d    ld      hl,(#4d7c)	; load HL with speed bit patterns for orange ghost normal state
;1e4c  29        add     hl,hl		; double it
;1e4d  227c4d    ld      (#4d7c),hl	; store result
;1e50  2a7a4d    ld      hl,(#4d7a)	; load HL with speed bit patterns for orange ghost normal state
;1e53  ed6a      adc     hl,hl		; double it
;1e55  227a4d    ld      (#4d7a),hl	; store result.  have we exceeded the threshold ?
;1e58  d0        ret     nc		; no, return
;
;1e59  217c4d    ld      hl,#4d7c	; yes, load HL with speed bit patterns for orange ghost normal state
;1e5c  34        inc     (hl)		; increase

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
	    bcs :sec

;1ef3  7e        ld      a,(hl)		; else load A with ghost/pacman tile X position
	    lda |pacman_x,x
;1ef4  063b      ld      b,#3b		; B := #3B
;1ef6  90        sub     b		; subtract.  is the ghost/pacman on the far left edge?
	    sec
	    sbc #$3b
;1ef7  d2fc1e    jp      nc,#1efc	; yes, set carry flag and return
	    bcc :sec
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
	    adc |1,y
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
	    stz <:b
;2039: CB 24         sla  h		; shift left through carry flag.  mult by 2
;203B: CB 24         sla  h
;203D: CB 24         sla  h
;203F: CB 24         sla  h	 
	    asl
	    asl
	    asl
	    asl
;2041: CB 10         rl   b
	    rol <:b
;2043: CB 24         sla  h
	    asl
;2045: CB 10         rl   b
	    rol <:b
;2047: 4C            ld   c,h
	    lda <:hl+1
	    sta <:bc+1
;2048: 26 00         ld   h,#00
	    stz <:hl+1

	    rep #$31 ; mxc = 000
;204A: 09            add  hl,bc		; add into HL
	    lda <:hl
	    adc <:bc
;204B: 01 40 40      ld   bc,#4040	; load BC with grid offset
;204E: 09            add  hl,bc		; add into HL
	    clc
	    adc #tile_ram+$40
;204F: C1            pop  bc		; restore BC
;2050: F1            pop  af		; restore AF
;2051: C9            ret			; return    
	    rts

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
	    lda |0,y
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
	    bcs :rts

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
	    bcs :rts

;2102  3e01      ld      a,#01		; yes, A := #01
	    lda #1
;2104  32b74d    ld      (#4db7),a	; set 2nd difficulty flag
	    sta |red_difficulty1
:rts
;2107  c9        ret     		; return
	    rts
;------------------------------------------------------------------------------

