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
;]VIDEO_MODE = ]VIDEO_MODE+Mstr_Ctrl_Sprite_En
]VIDEO_MODE = ]VIDEO_MODE+Mstr_Ctrl_GAMMA_En
]VIDEO_MODE = ]VIDEO_MODE+$100                                        ; +800x600

VICKY_MAP_TILES    = $000000
VICKY_SPRITE_TILES = $010000
VICKY_MAP0         = $020000   				; MAP Data for the TileSet

TILE_CLEAR_SIZE = $010000
MAP_CLEAR_SIZE = 64*64*2


;------------------------------------------------------------------------------
; I like having my own Direct Page
MyDP = $100

;------------------------------------------------------------------------------
; Direct Page Equates
		dum $80
lzsa_sourcePtr ds 4
lsza_destPtr   ds 4
lzsa_matchPtr  ds 4
lzsa_nibble    ds 2
lzsa_suboffset ds 2
lzsa_token     ds 2

temp0		   ds 4
temp1          ds 4
temp2   	   ds 4
temp3   	   ds 4
temp4   	   ds 4
temp5          ds 4
temp6		   ds 4
temp7          ds 4


i32EOF_Address ds 4
i32FileLength  ds 4
pData          ds 4
i16Version     ds 2
i16Width       ds 2
i16Height      ds 2
pCLUT          ds 4
pPIXL		   ds 4

dpJiffy        ds 2    ; Jiffy Timer
		dend



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

		; Black
		stz |GRPH_LUT0_PTR
		stz |GRPH_LUT0_PTR+2

		; Dark Grey
		lda #$5050
		sta |GRPH_LUT0_PTR+4
		sta |GRPH_LUT0_PTR+6

		; Dark Grey
		lda #$A0A0
		sta |GRPH_LUT0_PTR+8
		sta |GRPH_LUT0_PTR+10

		; White
		lda #$FFFF
		sta |GRPH_LUT0_PTR+12
		sta |GRPH_LUT0_PTR+14

;---------------------------------------------------------
;
;  Initialize Tile Map
;

		; While Tile planes are active
		ldx #TILE_Enable
		ldy #0
		stx |TL0_CONTROL_REG  	; Tile Plane 0 Enable
		sty |TL1_CONTROL_REG	; Tile Plane 1 Enable
		sty |TL2_CONTROL_REG	; Tile Plane 2 Disable
		sty |TL3_CONTROL_REG	; Tile Plane 3 Disable

		; Map Data Size
		lda #64
		sta |TL0_TOTAL_X_SIZE_L
		sta |TL0_TOTAL_Y_SIZE_L

		; Tile Set Address
		lda #VICKY_MAP_TILES
		sta |TILESET0_ADDY_L
		ldx #^VICKY_MAP_TILES
		stx |TILESET0_ADDY_H

		; Set TileMap 0 Name Data Address
		lda #VICKY_MAP0
		sta |TL0_START_ADDY_L
		ldx #^VICKY_MAP0
		stx |TL0_START_ADDY_H

		; Map display position
		stz |TL0_WINDOW_X_POS_L
		lda #4
		sta |TL0_WINDOW_Y_POS_L

		rep #$30

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
		inx
		inx
		cpx #64*16*2
		bcc ]lp

;		nop
;		nop
;		nop
;:stop   bra :stop
;		nop
;		nop
;		nop

		lda #$0303
		sta >VRAM+VICKY_MAP_TILES
		sta >VRAM+VICKY_MAP_TILES+2
		sta >VRAM+VICKY_MAP_TILES+4
		sta >VRAM+VICKY_MAP_TILES+6
		sta >VRAM+VICKY_MAP_TILES+8
		sta >VRAM+VICKY_MAP_TILES+10
		sta >VRAM+VICKY_MAP_TILES+12
		sta >VRAM+VICKY_MAP_TILES+14

		sta >VRAM+VICKY_MAP_TILES+{16*1}
		sta >VRAM+VICKY_MAP_TILES+{16*1}+14

		sta >VRAM+VICKY_MAP_TILES+{16*2}
		sta >VRAM+VICKY_MAP_TILES+{16*2}+14
		sta >VRAM+VICKY_MAP_TILES+{16*3}
		sta >VRAM+VICKY_MAP_TILES+{16*3}+14
		sta >VRAM+VICKY_MAP_TILES+{16*4}
		sta >VRAM+VICKY_MAP_TILES+{16*4}+14
		sta >VRAM+VICKY_MAP_TILES+{16*5}
		sta >VRAM+VICKY_MAP_TILES+{16*5}+14
		sta >VRAM+VICKY_MAP_TILES+{16*6}
		sta >VRAM+VICKY_MAP_TILES+{16*6}+14

		sta >VRAM+VICKY_MAP_TILES+{16*7}
		sta >VRAM+VICKY_MAP_TILES+{16*7}+14

		sta >VRAM+VICKY_MAP_TILES+{16*8}
		sta >VRAM+VICKY_MAP_TILES+{16*8}+14

		sta >VRAM+VICKY_MAP_TILES+{16*9}
		sta >VRAM+VICKY_MAP_TILES+{16*9}+14

		sta >VRAM+VICKY_MAP_TILES+{16*10}
		sta >VRAM+VICKY_MAP_TILES+{16*10}+14

		sta >VRAM+VICKY_MAP_TILES+{16*11}
		sta >VRAM+VICKY_MAP_TILES+{16*11}+14

		sta >VRAM+VICKY_MAP_TILES+{16*12}
		sta >VRAM+VICKY_MAP_TILES+{16*12}+14

		sta >VRAM+VICKY_MAP_TILES+{16*13}
		sta >VRAM+VICKY_MAP_TILES+{16*13}+14

		sta >VRAM+VICKY_MAP_TILES+{16*14}
		sta >VRAM+VICKY_MAP_TILES+{16*14}+14

		sta >VRAM+VICKY_MAP_TILES+{16*15}
		sta >VRAM+VICKY_MAP_TILES+{16*15}+14

		nop
		nop
		nop
;]wait	bra ]wait
		nop
		nop
		nop

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
]var = 0
	lup 16
	dw $000+]var,$001+]var,$002+]var,$003+]var,$004+]var,$005+]var,$006+]var,$007+]var
	dw $008+]var,$009+]var,$00A+]var,$00B+]var,$00C+]var,$00D+]var,$00E+]var,$00F+]var
	dw 0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0

	dw 0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0

]var = ]var+16
	--^


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

