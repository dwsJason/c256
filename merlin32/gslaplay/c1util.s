;
; C256 FMX - C1 Utils
;
; Code fast enough to provide 16 color bitmap
; mode on the FMX, similar to the IIgs
;
; 320x200 16 color index display memory at $002000-$009CFF
; 16 color R4G4B4 format CLUT at $009E00
;
; Done in Bank 0, so that most pea/pei, and DP compiled
; render code can be easily made to run
;
		rel
		lnk c1utils.l

		; Vicky Includes
		use phx/vicky_ii_def.asm
		use phx/VKYII_CFP9553_BITMAP_def.asm 
		use phx/VKYII_CFP9553_TILEMAP_def.asm
		use phx/VKYII_CFP9553_VDMA_def.asm   
		use phx/VKYII_CFP9553_SDMA_def.asm   
		use phx/VKYII_CFP9553_SPRITE_def.asm 

; this works by displaying the same tiles, using
; 2 different palettes, on 2 different background
; planes,  one tiled background displays even columns
; and the other one displays odd columns, they must
; be offset by 1 pixel horizontally for this to work
; unfortunately the bitmap planes, their offset X does
; not work, otherwise this code would be dead-simple
; in comparison to what I have here, where I've broken
; things up into 256 pixel wide tiles

; Important Direct Page Locations
; $$TODO, move these into a shared file
dpJiffy       = 128


;
; Where VRAM is located in CPU Space
;
VRAM = $B00000

C1BUFFER = $002000

;
; Location of the first 128 x 200 pixels
; laid out in TileSet 0 (in 256x256 mode)
;
VICKY_DISPLAY_BUFFER0 = $000000
;
; Location of the second part of our screen
; laid out in TileSet 1 (in 256x256 mode)
;
VICKY_DISPLAY_BUFFER1 = $010000
;
; Map Data for Tile Layer 0
VICKY_TILEMAP0 = $020000
; Map Data for Tile Layer 1
VICKY_TILEMAP1 = $030000

; The size of the memory we are using in the tile
; we need every other column set to zero
TILE_CLEAR_SIZE = 256*200
; Clear the entire map
MAP_CLEAR_SIZE = 32*16*2

;
; Vicky Compatible Map data, used to tell vicky which
; tiles to display on the layer
;
map_data
]var = 0
	lup 13
	dw $000+]var,$001+]var,$002+]var,$003+]var,$004+]var,$005+]var,$006+]var,$007+]var
	dw $008+]var,$009+]var,$00A+]var,$00B+]var,$00C+]var,$00D+]var,$00E+]var,$00F+]var
	dw $100+]var,$101+]var,$102+]var,$103+]var,0,0,0,0
	dw 0,0,0,0,0,0,0,0
]var = ]var+16
	--^

;------------------------------------------------------------------------------
;
; Input GS Color in A 0x0BGR
;
; output 0x00RRGGBB in Direct Page 0
;
GS2FMXcolor mx %00
:rgb	= 0
		pha
		and #$00F		; Blue
		sta <:rgb
		asl
		asl
		asl
		asl
		tsb <:rgb

		; Green
		lda 1,s
		and #$0F0 		; Green
		sta <:rgb+1
		lsr
		lsr
		lsr
		lsr
		tsb <:rgb+1

		; Red
		pla
		and #$F00
		xba
		sta <:rgb+2
		asl
		asl
		asl
		asl
		ora #$FF00   ; Set alpha to 1
		tsb <:rgb+2

		rts

;------------------------------------------------------------------------------
; WaitVBL - wait for VBlank to begin
; Preserve all registers, and processor status
;
WaitVBL
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
; Clut Buffer
;
pal_buffer
		ds 1024

;------------------------------------------------------------------------------
;
; DMA the Data into VRAM
; You know this is going to have a rip in it at 256 pixels horizontally
; and that you will have to recode this to do 1 whole 320 pixel line at a time
; right?
;
C1BlitPixels ent
		mx %00
		phb

		; TODO a macro that will pea the current bank, and the bank I want
		; to save plb, and phk instructions
		pea	{VDMA_CONTROL_REG}/256  ; this works fine with a constant, but not
								; with an ext address
		plb
		plb

]src = 0
]dst = 4
]count = 8

		pei ]src
		pei ]src+2
		pei ]dst
		pei ]dst+2
		pei ]count

]lines = 10
]chunk_size = 128*]lines

		lda #C1BUFFER
		sta <]src
		lda #^C1BUFFER
		sta <]src+2
		lda #VICKY_DISPLAY_BUFFER0
		sta <]dst
		lda #^VICKY_DISPLAY_BUFFER0
		sta <]dst+2

		stz <]count

]looper

		sep #$20														; 3
		; make sure not active  											
		stz |SDMA_CTRL_REG0 											; 4
		stz |VDMA_CONTROL_REG   										; 4

		; activate SDMA
		lda #SDMA_CTRL0_Enable+SDMA_CTRL0_1D_2D+SDMA_CTRL0_SysRAM_Src	; 2
		sta |SDMA_CTRL_REG0												; 4
		; activate VDMA
		lda #VDMA_CTRL_Enable+VDMA_CTRL_1D_2D+VDMA_CTRL_SysRAM_Src  	; 2
		sta |VDMA_CONTROL_REG   										; 4

		; Setup Source Address in RAM
		ldx <]src   													; 4
		stx |SDMA_SRC_ADDY_L											; 5
		lda <]src+2 													; 3
		sta |SDMA_SRC_ADDY_H											; 4

		; Setup Dest Address in VRAM
		ldx <]dst   													; 4
		stx |VDMA_DST_ADDY_L											; 5
		lda <]dst+2 													; 3
		sta |VDMA_DST_ADDY_H											; 4

		; Setup Source Size
		ldx #128														; 3
		stx |SDMA_X_SIZE_L  											; 5
		ldy #]lines 													; 3
		sty |SDMA_Y_SIZE_L  											; 5

		; Setup Destination Size
		ldx #1  														; 3
		stx |VDMA_X_SIZE_L  											; 5
		ldy #]chunk_size												; 3
		sty |VDMA_Y_SIZE_L  											; 5

		; Source Stride in bytes
		ldx #160														; 3
		stx |SDMA_SRC_STRIDE_L  										; 5
		; Dest Stride
		ldx #2  														; 3
		stx |VDMA_DST_STRIDE_L  										; 5

		; Start VDMA First (I guess it waits)
		lda #VDMA_CTRL_Start_TRF   ; 2
		tsb |VDMA_CONTROL_REG      ; 6
		lda #SDMA_CTRL0_Start_TRF  ; 2
		tsb |SDMA_CTRL_REG0 	   ; 6

		; waiting a total of 12 clocks from the VDMA_CONTROL_REG trigger
		NOP ; 2 When the transfer is started the CPU will be put on Hold (RDYn)... 
		NOP ; 2 Before it actually gets to stop it will execute a couple more instructions
		;NOP ; From that point on, the CPU is halted (keep that in mind) No IRQ will be processed either during that time
		;NOP
		;NOP

		; There is a DMA FIFO so, SDMA can finish before VDMA
]wait_dma
		lda |VDMA_STATUS_REG											 ; 4
		bmi ]wait_dma   												 ; 3/2 (Branch/NB)

		stz |SDMA_CTRL_REG0 											 ; 4
		stz |VDMA_CONTROL_REG   										 ; 4

		rep #$31														 ; 3

		lda <]count 													 ; 4
		inc 															 ; 2
		cmp #200/]lines 												 ; 3
		bcs :donedaddy  												 ; 2/3 (NB/Branch)
		sta <]count 													 ; 4

		lda <]src   													 ; 4
		adc	#160*]lines 												 ; 3
		sta <]src   													 ; 4

		lda <]dst   													 ; 4
		adc #256*]lines 												 ; 3
		sta <]dst   													 ; 4

		jmp ]looper 													 ; 3    (about 155+32 clocks to move the data) 187 clocks vs the 256 clocks to use the CPU (still a win)

:donedaddy

;------------------------------------------------------------------------------
; now do the 64 pixels on the right
; Another Loop for the 32 bytes (64 pixels) that we didn't transfer above

]lines = 1
]chunk_size = 32*]lines

		lda #C1BUFFER+128
		sta <]src
		lda #^C1BUFFER
		sta <]src+2
		lda #VICKY_DISPLAY_BUFFER1
		sta <]dst
		lda #^{VICKY_DISPLAY_BUFFER1
		sta <]dst+2

		stz <]count

]looper

		sep #$20   															; 3
		; make sure not active  											
		;stz |SDMA_CTRL_REG0 												; 4
		;stz |VDMA_CONTROL_REG   											; 4

		; activate SDMA
		lda #SDMA_CTRL0_Enable+SDMA_CTRL0_1D_2D+SDMA_CTRL0_SysRAM_Src		; 2
		;lda #SDMA_CTRL0_Enable+SDMA_CTRL0_SysRAM_Src
		sta |SDMA_CTRL_REG0 												; 4
		; activate VDMA
		lda #VDMA_CTRL_Enable+VDMA_CTRL_1D_2D+VDMA_CTRL_SysRAM_Src  		; 2
		sta |VDMA_CONTROL_REG   											; 4

		; Setup Source Address in RAM
		ldx <]src   														; 4
		stx |SDMA_SRC_ADDY_L												; 5
		lda <]src+2 														; 3
		sta |SDMA_SRC_ADDY_H												; 4

		; Setup Dest Address in VRAM
		ldx <]dst   														; 4
		stx |VDMA_DST_ADDY_L												; 5
		lda <]dst+2 														; 3
		sta |VDMA_DST_ADDY_H												; 4

		; Setup Source Size
		ldx #32 															; 3
		stx |SDMA_X_SIZE_L  												; 5
		ldy #]lines 														; 3
		sty |SDMA_Y_SIZE_L  												; 5

		; Setup Destination Size
		ldx #1  															; 3
		stx |VDMA_X_SIZE_L  												; 5
		ldy #]chunk_size													; 3
		sty |VDMA_Y_SIZE_L  												; 5

		; Source Stride in bytes
		ldx #160															; 3
		stx |SDMA_SRC_STRIDE_L  											; 5
		; Dest Stride
		ldx #2  															; 3
		stx |VDMA_DST_STRIDE_L  											; 5

		; Start VDMA First (I guess it waits)
		lda #VDMA_CTRL_Start_TRF   ; 2
		tsb |VDMA_CONTROL_REG      ; 6
		lda #SDMA_CTRL0_Start_TRF  ; 2
		tsb |SDMA_CTRL_REG0 	   ; 6

		; waiting a total of 12 clocks from the VDMA_CONTROL_REG trigger
		NOP ; 2 When the transfer is started the CPU will be put on Hold (RDYn)... 
		NOP ; 2 Before it actually gets to stop it will execute a couple more instructions
		;NOP ; From that point on, the CPU is halted (keep that in mind) No IRQ will be processed either during that time
		;NOP
		;NOP

		; There is a DMA FIFO so, SDMA can finish before VDMA
]wait_dma
		lda |VDMA_STATUS_REG											     ; 4
		bmi ]wait_dma   													 ; 3 on branch/ 2 no branch

		stz |SDMA_CTRL_REG0 												 ; 4
		stz |VDMA_CONTROL_REG   											 ; 4

		rep #$31															 ; 3

		lda <]count 														 ; 4
		inc 																 ; 2
		cmp #200/]lines 													 ; 3
		bcs :donemommy  													 ; 2/3 (B or NB)
		sta <]count 														 ; 4

		lda <]src   														 ; 4
		adc	#160*]lines 													 ; 3
		sta <]src   														 ; 4

		lda <]dst   														 ; 4
		adc #256*]lines 													 ; 3
		sta <]dst   														 ; 4

		jmp ]looper 														 ; 3    (about 155+32 clocks to move the data) 187 clocks vs the 256 clocks to use the CPU (still a win)

:donemommy

		pla
		sta <]count
		pla
		sta <]dst+2
		pla
		sta <]dst
		pla
		sta <]src+2
		pla
		sta <]src

		plb
		rtl

;------------------------------------------------------------------------------
;
; Kick up palettes
;
C1BlitPalettes ent
		mx %00
		phb

; First Convert the palette colors into FMX Format

		phk
		plb

:temp = 0
		pei :temp
		pei :temp+2

		lda #0
; Convert 16 color from GS format, to FMX
]lp     pha
		asl
		tax
		lda >$009E00,x
		jsr GS2FMXcolor
		txa
		asl
		tax
		lda <:temp
		sta |pal_buffer,x
		lda <:temp+2
		sta |pal_buffer+2,x
		pla
		inc
		cmp #16
		bcc ]lp

; Now update the Background Color, so the transparent pixels show the correct
; Color

		lda |pal_buffer
		sta >BACKGROUND_COLOR_B  ; BG
		lda |pal_buffer+1
		sta >BACKGROUND_COLOR_G  ; GR
;--- shared by both lut copys
		pea >GRPH_LUT0_PTR
		plb
		plb 

; Now update the CLUT Memory
; First Do LUT0

		ldx #62
]loop
		lda >pal_buffer,x
		sta |GRPH_LUT0_PTR+{64*0},x
		sta |GRPH_LUT0_PTR+{64*1},x
		sta |GRPH_LUT0_PTR+{64*2},x
		sta |GRPH_LUT0_PTR+{64*3},x
		sta |GRPH_LUT0_PTR+{64*4},x
		sta |GRPH_LUT0_PTR+{64*5},x
		sta |GRPH_LUT0_PTR+{64*6},x
		sta |GRPH_LUT0_PTR+{64*7},x
		sta |GRPH_LUT0_PTR+{64*8},x
		sta |GRPH_LUT0_PTR+{64*9},x
		sta |GRPH_LUT0_PTR+{64*10},x
		sta |GRPH_LUT0_PTR+{64*11},x
		sta |GRPH_LUT0_PTR+{64*12},x
		sta |GRPH_LUT0_PTR+{64*13},x
		sta |GRPH_LUT0_PTR+{64*14},x
		sta |GRPH_LUT0_PTR+{64*15},x
		dex
		dex
		bpl ]loop

; Now Do LUT1

		ldx #0
		ldy #0
		clc  ; c=1 from above
]boop
		lda >pal_buffer,x
]offset = 0
		lup 16
		sta |GRPH_LUT1_PTR+]offset,y
]offset = ]offset+4
		--^
		lda >pal_buffer+2,x
]offset = 0
		lup 16
		sta |GRPH_LUT1_PTR+]offset+2,y
]offset = ]offset+4
		--^
		txa
		adc #4
		tax
		tya
		adc #64
		tay
		cpx #64
		bcc ]boop

		pla
		sta <:temp+2
		pla
		sta <:temp

		plb
		rtl

;------------------------------------------------------------------------------
;
; Initialize Hardware
;
C1InitVideo ent
		mx %00
		phb

XRES = 320
YRES = 240
; 320 x 240, Tile Map Engine enabled
VIDEO_MODE = $0254

		jsr WaitVBL

		; Get B into bank $AF, for shorter Vicky Access
		pea >MASTER_CTRL_REG_L
		plb
		plb

		lda #VIDEO_MODE
		sta |MASTER_CTRL_REG_L

		sep #$10
		ldx #TILE_Enable
		ldy #0
		stx |TL0_CONTROL_REG  	; Tile Plane 0 Enable
		stx |TL1_CONTROL_REG	; Tile Plane 1 Enable
		sty |TL2_CONTROL_REG	; Tile Plane 2 Disable
		sty |TL3_CONTROL_REG	; Tile Plane 3 Disable

		; 320 pixels, needs 20 tiles in width
		; We need a few more than that, so we can set scroll registers
		; offset from each other
		; make the map 32 tiles wide, so power of 2
		lda #32
		sta |TL0_TOTAL_X_SIZE_L
		sta |TL1_TOTAL_X_SIZE_L
		; 200 pixels tall, needs 12.5 tiles height
		; we also need some extra tiles to center the image
		; on the screen, make it 16 tiles tall, so power of 2
		lda #16 ; I know could be LSR
		sta |TL0_TOTAL_Y_SIZE_L
		sta |TL1_TOTAL_Y_SIZE_L

		; Set TileSet 0 Start Address + 256 Stride Mode
		lda #<VICKY_DISPLAY_BUFFER0
		sta |TILESET0_ADDY_L
		ldx #^VICKY_DISPLAY_BUFFER0
		stx |TILESET0_ADDY_H
		; Set TileSet 1 Start Address + 256 Stride Mode
		lda #<VICKY_DISPLAY_BUFFER1
		sta |TILESET1_ADDY_L
		ldx #^VICKY_DISPLAY_BUFFER1
		stx |TILESET1_ADDY_H
		; 256 pixel stride mode
		ldx #8
		stx |TILESET0_ADDY_CFG
		stx |TILESET1_ADDY_CFG

		; Set TileMap 0 Start Address
		lda #VICKY_TILEMAP0
		sta |TL0_START_ADDY_L
		ldx #^VICKY_TILEMAP0
		stx |TL0_START_ADDY_H
		; Set TileMap 1 Start Address
		lda #VICKY_TILEMAP1
		sta |TL1_START_ADDY_L
		ldx #^VICKY_TILEMAP1
		stx |TL1_START_ADDY_H

		; Set Scroll Positions of the Maps
		; Map 0 Position
		lda #15
		sta |TL0_WINDOW_X_POS_L
		lda #12
		sta |TL0_WINDOW_Y_POS_L
		; Map 1 Position
		lda #16
		sta |TL1_WINDOW_X_POS_L
		lda #12
		sta |TL1_WINDOW_Y_POS_L

		; Border thing? Hide Garbage pixels
		ldx #Border_Ctrl_Enable
		stx |BORDER_CTRL_REG
		ldx #64
		stx |BORDER_COLOR_B
		sty |BORDER_COLOR_G
		sty |BORDER_COLOR_R
		sty |BORDER_X_SIZE
		ldx #20
		stx |BORDER_Y_SIZE

;-----------------------------------------------

		rep #$30
		do 1
		; Clear Tile Catalog 0
		pea #VICKY_DISPLAY_BUFFER0
		pea #^VICKY_DISPLAY_BUFFER0

		pea #TILE_CLEAR_SIZE
		pea #^TILE_CLEAR_SIZE

		jsr vmemset0

		; Clear Tile Catalog 1
		pea #^VICKY_DISPLAY_BUFFER1
		pea #VICKY_DISPLAY_BUFFER1

		pea #^TILE_CLEAR_SIZE
		pea #TILE_CLEAR_SIZE

		jsr vmemset0

		; Clear Tile Map 0
		pea #^VICKY_TILEMAP0
		pea #VICKY_TILEMAP0

		pea #^MAP_CLEAR_SIZE
		pea #MAP_CLEAR_SIZE
		
		jsr vmemset0

		; Clear Tile Map 1
		pea #^VICKY_TILEMAP1
		pea #VICKY_TILEMAP1

		pea #^MAP_CLEAR_SIZE
		pea #MAP_CLEAR_SIZE
		
		jsr vmemset0
		fin

		do 0

		ldx #0
		lda #0
]clear
		sta >VICKY_DISPLAY_BUFFER0+VRAM,x
		sta >VICKY_DISPLAY_BUFFER1+VRAM,x
		sta >VICKY_TILEMAP0+VRAM,x
		sta >VICKY_TILEMAP1+VRAM,x
		inx
		inx
		cpx #200*256
		bcc ]clear

		fin

;-----------------------------------------------
; Copy map data to VRAM

		phk
		plb

		ldx #0
]lp
		lda |map_data,x
		sta >VICKY_TILEMAP0+VRAM+{64*2}+4,x
		ora #$800  ; setup the next palette
		sta >VICKY_TILEMAP1+VRAM+{64*2}+4,x
		inx
		inx
		cpx #32*13*2
		bcc ]lp

		
		plb
		rtl
		
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
 
