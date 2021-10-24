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
	case on
	longa on
	longi on

DummyC1 start C1UTIL
	end


; Vicky Includes
*		use phx/vicky_ii_def.asm
*		use phx/VKYII_CFP9553_BITMAP_def.asm 
*		use phx/VKYII_CFP9553_TILEMAP_def.asm
*		use phx/VKYII_CFP9553_VDMA_def.asm   
*		use phx/VKYII_CFP9553_SDMA_def.asm   
*		use phx/VKYII_CFP9553_SPRITE_def.asm 

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
dpJiffy       GEQU 128

;
; VICKY
;
VIDEO_MODE GEQU $0254

MASTER_CTRL_REG_L GEQU $AF0000

;Control Bits Fields
Mstr_Ctrl_Text_Mode_En  GEQU $01       ; Enable the Text Mode
Mstr_Ctrl_Text_Overlay  GEQU $02       ; Enable the Overlay of the text mode on top of Graphic Mode (the Background Color is ignored)
Mstr_Ctrl_Graph_Mode_En GEQU $04       ; Enable the Graphic Mode
Mstr_Ctrl_Bitmap_En     GEQU $08       ; Enable the Bitmap Module In Vicky
Mstr_Ctrl_TileMap_En    GEQU $10       ; Enable the Tile Module in Vicky
Mstr_Ctrl_Sprite_En     GEQU $20       ; Enable the Sprite Module in Vicky
Mstr_Ctrl_GAMMA_En      GEQU $40       ; this Enable the GAMMA correction - The Analog and DVI have different color value, the GAMMA is great to correct the difference
Mstr_Ctrl_Disable_Vid   GEQU $80       ; This will disable the Scanning of the Video hence giving 100% bandwith to the CPU

MASTER_CTRL_REG_H       GEQU $AF0001
Mstr_Ctrl_Video_Mode0   GEQU $01       ; 0 - 640x480 (Clock @ 25.175Mhz), 1 - 800x600 (Clock @ 40Mhz)
Mstr_Ctrl_Video_Mode1   GEQU $02       ; 0 - No Pixel Doubling, 1- Pixel Doubling (Reduce the Pixel Resolution by 2)


Border_Ctrl_Enable      GEQU $01
BORDER_CTRL_REG         GEQU $AF0004 ; Bit[0] - Enable (1 by default)  Bit[4..6]: X Scroll Offset ( Will scroll Left) (Acceptable Value: 0..7)
BORDER_COLOR_B          GEQU $AF0005
BORDER_COLOR_G          GEQU $AF0006
BORDER_COLOR_R          GEQU $AF0007
BORDER_X_SIZE           GEQU $AF0008 ; X-  Values: 0 - 32 (Default: 32)
BORDER_Y_SIZE           GEQU $AF0009 ; Y- Values 0 -32 (Default: 32)

BACKGROUND_COLOR_B      GEQU $AF000D ; When in Graphic Mode, if a pixel is "0" then the Background pixel is chosen
BACKGROUND_COLOR_G      GEQU $AF000E
BACKGROUND_COLOR_R      GEQU $AF000F ;

GRPH_LUT0_PTR GEQU $AF2000
GRPH_LUT1_PTR GEQU $AF2400
;
; Tile Stuff
;
TILE_Enable             GEQU $01

;
;Tile MAP Layer 0 Registers
TL0_CONTROL_REG         GEQU $AF0200       ; Bit[0] - Enable, Bit[3:1] - LUT Select,
TL0_START_ADDY_L        GEQU $AF0201       ; Not USed right now - Starting Address to where is the MAP
TL0_START_ADDY_M        GEQU $AF0202
TL0_START_ADDY_H        GEQU $AF0203
TL0_TOTAL_X_SIZE_L      GEQU $AF0204       ; Size of the Map in X Tile Count [9:0] (1024 Max)
TL0_TOTAL_X_SIZE_H      GEQU $AF0205
TL0_TOTAL_Y_SIZE_L      GEQU $AF0206       ; Size of the Map in Y Tile Count [9:0]
TL0_TOTAL_Y_SIZE_H      GEQU $AF0207
TL0_WINDOW_X_POS_L      GEQU $AF0208       ; Top Left Corner Position of the TileMAp Window in X + Scroll
TL0_WINDOW_X_POS_H      GEQU $AF0209       ; Direction: [14] Scroll: [13:10] Pos: [9:0] in X
TL0_WINDOW_Y_POS_L      GEQU $AF020A       ; Top Left Corner Position of the TileMAp Window in Y
TL0_WINDOW_Y_POS_H      GEQU $AF020B       ; Direction: [14] Scroll: [13:10] Pos: [9:0] in Y
;Tile MAP Layer 1 Registers
TL1_CONTROL_REG         GEQU $AF020C       ; Bit[0] - Enable, Bit[3:1] - LUT Select,
TL1_START_ADDY_L        GEQU $AF020D       ; Not USed right now - Starting Address to where is the MAP
TL1_START_ADDY_M        GEQU $AF020E
TL1_START_ADDY_H        GEQU $AF020F
TL1_TOTAL_X_SIZE_L      GEQU $AF0210       ; Size of the Map in X Tile Count [9:0] (1024 Max)
TL1_TOTAL_X_SIZE_H      GEQU $AF0211
TL1_TOTAL_Y_SIZE_L      GEQU $AF0212       ; Size of the Map in Y Tile Count [9:0]
TL1_TOTAL_Y_SIZE_H      GEQU $AF0213
TL1_WINDOW_X_POS_L      GEQU $AF0214       ; Top Left Corner Position of the TileMAp Window in X + Scroll
TL1_WINDOW_X_POS_H      GEQU $AF0215       ; Direction: [14] Scroll: [13:10] Pos: [9:0] in X
TL1_WINDOW_Y_POS_L      GEQU $AF0216       ; Top Left Corner Position of the TileMAp Window in Y
TL1_WINDOW_Y_POS_H      GEQU $AF0217       ; Direction: [14] Scroll: [13:10] Pos: [9:0] in Y
;Tile MAP Layer 2 Registers
TL2_CONTROL_REG         GEQU $AF0218       ; Bit[0] - Enable, Bit[3:1] - LUT Select,
TL2_START_ADDY_L        GEQU $AF0219       ; Not USed right now - Starting Address to where is the MAP
TL2_START_ADDY_M        GEQU $AF021A
TL2_START_ADDY_H        GEQU $AF021B
TL2_TOTAL_X_SIZE_L      GEQU $AF021C       ; Size of the Map in X Tile Count [9:0] (1024 Max)
TL2_TOTAL_X_SIZE_H      GEQU $AF021D
TL2_TOTAL_Y_SIZE_L      GEQU $AF021E       ; Size of the Map in Y Tile Count [9:0]
TL2_TOTAL_Y_SIZE_H      GEQU $AF021F
TL2_WINDOW_X_POS_L      GEQU $AF0220       ; Top Left Corner Position of the TileMAp Window in X + Scroll
TL2_WINDOW_X_POS_H      GEQU $AF0221       ; Direction: [14] Scroll: [13:10] Pos: [9:0] in X
TL2_WINDOW_Y_POS_L      GEQU $AF0222       ; Top Left Corner Position of the TileMAp Window in Y
TL2_WINDOW_Y_POS_H      GEQU $AF0223       ; Direction: [14] Scroll: [13:10] Pos: [9:0] in Y
;Tile MAP Layer 3 Registers
TL3_CONTROL_REG         GEQU $AF0224       ; Bit[0] - Enable, Bit[3:1] - LUT Select,
TL3_START_ADDY_L        GEQU $AF0225       ; Not USed right now - Starting Address to where is the MAP
TL3_START_ADDY_M        GEQU $AF0226
TL3_START_ADDY_H        GEQU $AF0227
TL3_TOTAL_X_SIZE_L      GEQU $AF0228       ; Size of the Map in X Tile Count [9:0] (1024 Max)
TL3_TOTAL_X_SIZE_H      GEQU $AF0229
TL3_TOTAL_Y_SIZE_L      GEQU $AF022A       ; Size of the Map in Y Tile Count [9:0]
TL3_TOTAL_Y_SIZE_H      GEQU $AF022B
TL3_WINDOW_X_POS_L      GEQU $AF022C       ; Top Left Corner Position of the TileMAp Window in X + Scroll
TL3_WINDOW_X_POS_H      GEQU $AF022D       ; Direction: [14] Scroll: [13:10] Pos: [9:0] in X
TL3_WINDOW_Y_POS_L      GEQU $AF022E       ; Top Left Corner Position of the TileMAp Window in Y
TL3_WINDOW_Y_POS_H      GEQU $AF022F       ; Direction: [14] Scroll: [13:10] Pos: [9:0] in Y

; CS_TileMAP1_Registers $AF:0280 - $AF:02FF   - TileData
; Tile Set 0 Location info
TILESET0_ADDY_L         GEQU $AF0280   ; Pointer to Tileset 0 [21:0]
TILESET0_ADDY_M         GEQU $AF0281
TILESET0_ADDY_H         GEQU $AF0282
TILESET0_ADDY_CFG       GEQU $AF0283   ; [3] - TileStride256x256
; Tile Set 0 Location info
TILESET1_ADDY_L         GEQU $AF0284
TILESET1_ADDY_M         GEQU $AF0285
TILESET1_ADDY_H         GEQU $AF0286
TILESET1_ADDY_CFG       GEQU $AF0287
; Tile Set 0 Location info
TILESET2_ADDY_L         GEQU $AF0288
TILESET2_ADDY_M         GEQU $AF0289
TILESET2_ADDY_H         GEQU $AF028A
TILESET2_ADDY_CFG       GEQU $AF028B
; Tile Set 0 Location info
TILESET3_ADDY_L         GEQU $AF028C
TILESET3_ADDY_M         GEQU $AF028D
TILESET3_ADDY_H         GEQU $AF028E
TILESET3_ADDY_CFG       GEQU $AF028F
; Tile Set 0 Location info
TILESET4_ADDY_L         GEQU $AF0290
TILESET4_ADDY_M         GEQU $AF0291
TILESET4_ADDY_H         GEQU $AF0292
TILESET4_ADDY_CFG       GEQU $AF0293
; Tile Set 0 Location info
TILESET5_ADDY_L         GEQU $AF0294
TILESET5_ADDY_M         GEQU $AF0295
TILESET5_ADDY_H         GEQU $AF0296
TILESET5_ADDY_CFG       GEQU $AF0297
; Tile Set 0 Location info
TILESET6_ADDY_L         GEQU $AF0298
TILESET6_ADDY_M         GEQU $AF0299
TILESET6_ADDY_H         GEQU $AF029A
TILESET6_ADDY_CFG       GEQU $AF029B
; Tile Set 0 Location info
TILESET7_ADDY_L         GEQU $AF029C
TILESET7_ADDY_M         GEQU $AF029D
TILESET7_ADDY_H         GEQU $AF029E
TILESET7_ADDY_CFG       GEQU $AF029F

;
; VDMA
;
VDMA_CONTROL_REG GEQU $AF0400
VDMA_CTRL_Enable        GEQU $01
VDMA_CTRL_1D_2D         GEQU $02       ; 0 - 1D (Linear) Transfer , 1 - 2D (Block) Transfer
VDMA_CTRL_TRF_Fill      GEQU $04       ; 0 - Transfer Src -> Dst, 1 - Fill Destination with "Byte2Write"
VDMA_CTRL_Int_Enable    GEQU $08       ; Set to 1 to Enable the Generation of Interrupt when the Transfer is over.
VDMA_CTRL_SysRAM_Src    GEQU $10       ; Set to 1 to Indicate that the Source is the System Ram Memory
VDMA_CTRL_SysRAM_Dst    GEQU $20       ; Set to 1 to Indicate that the Destination is the System Ram Memory
VDMA_CTRL_Start_TRF     GEQU $80       ; Set to 1 To Begin Process, Need to Cleared before, you can start another

VDMA_BYTE_2_WRITE       GEQU $AF0401   ; Write Only - Byte to Write in the Fill Function

VDMA_STATUS_REG         GEQU $AF0401   ; Read only

VDMA_SRC_ADDY_L         GEQU $AF0402   ; Pointer to the Source of the Data to be stransfered
VDMA_SRC_ADDY_M         GEQU $AF0403   ; This needs to be within Vicky's Range ($00_0000 - $3F_0000)
VDMA_SRC_ADDY_H         GEQU $AF0404

VDMA_DST_ADDY_L         GEQU $AF0405   ; Destination Pointer within Vicky's video memory Range
VDMA_DST_ADDY_M         GEQU $AF0406   ; ($00_0000 - $3F_0000)
VDMA_DST_ADDY_H         GEQU $AF0407

; In 1D Transfer Mode
VDMA_SIZE_L             GEQU $AF0408   ; Maximum Value: $40:0000 (4Megs)
VDMA_SIZE_M             GEQU $AF0409
VDMA_SIZE_H             GEQU $AF040A
VDMA_IGNORED            GEQU $AF040B

; In 2D Transfer Mode
VDMA_X_SIZE_L           GEQU $AF0408   ; Maximum Value: 65535
VDMA_X_SIZE_H           GEQU $AF0409
VDMA_Y_SIZE_L           GEQU $AF040A   ; Maximum Value: 65535
VDMA_Y_SIZE_H           GEQU $AF040B

VDMA_SRC_STRIDE_L       GEQU $AF040C   ; Always use an Even Number ( The Engine uses Even Ver of that value)
VDMA_SRC_STRIDE_H       GEQU $AF040D   ;
VDMA_DST_STRIDE_L       GEQU $AF040E   ; Always use an Even Number ( The Engine uses Even Ver of that value)
VDMA_DST_STRIDE_H       GEQU $AF040F   ;


;
; SDMA
;
SDMA_CTRL_REG0 GEQU $AF0420
SDMA_CTRL0_Enable        GEQU $01
SDMA_CTRL0_1D_2D         GEQU $02     ; 0 - 1D (Linear) Transfer , 1 - 2D (Block) Transfer
SDMA_CTRL0_TRF_Fill      GEQU $04     ; 0 - Transfer Src -> Dst, 1 - Fill Destination with "Byte2Write"
SDMA_CTRL0_Int_Enable    GEQU $08     ; Set to 1 to Enable the Generation of Interrupt when the Transfer is over.
SDMA_CTRL0_SysRAM_Src    GEQU $10     ; Set to 1 to Indicate that the Source is the System Ram Memory
SDMA_CTRL0_SysRAM_Dst    GEQU $20     ; Set to 1 to Indicate that the Destination is the System Ram Memory

SDMA_CTRL0_Start_TRF     GEQU $80      ; Set to 1 To Begin Process, Need to Cleared before, you can start another

SDMA_SRC_ADDY_L         GEQU $AF0422   ; Pointer to the Source of the Data to be stransfered
SDMA_SRC_ADDY_M         GEQU $AF0423   ; This needs to be within CPU's system RAM range ($00_0000 - $3F_FFFF)
SDMA_SRC_ADDY_H         GEQU $AF0424

SDMA_DST_ADDY_L         GEQU $AF0425   ; Destination Pointer within CPU's video memory Range
SDMA_DST_ADDY_M         GEQU $AF0426   ; This needs to be within CPU's system RAM range ($00_0000 - $3F_FFFF)
SDMA_DST_ADDY_H         GEQU $AF0427

; In 1D Transfer Mode
SDMA_SIZE_L             GEQU $AF0428   ; Maximum Value: $40:0000 (4Megs)
SDMA_SIZE_M             GEQU $AF0429
SDMA_SIZE_H             GEQU $AF042A
SDMA_IGNORED            GEQU $AF042B

; In 2D Transfer Mode
SDMA_X_SIZE_L           GEQU $AF0428   ; Maximum Value: 65535
SDMA_X_SIZE_H           GEQU $AF0429
SDMA_Y_SIZE_L           GEQU $AF042A   ; Maximum Value: 65535
SDMA_Y_SIZE_H           GEQU $AF042B

SDMA_SRC_STRIDE_L       GEQU $AF042C   ; Always use an Even Number ( The Engine uses Even Ver of that value)
SDMA_SRC_STRIDE_H       GEQU $AF042D   ;
SDMA_DST_STRIDE_L       GEQU $AF042E   ; Always use an Even Number ( The Engine uses Even Ver of that value)
SDMA_DST_STRIDE_H       GEQU $AF042F   ;

SDMA_BYTE_2_WRITE       GEQU $AF0430   ; Write Only - Byte to Write in the Fill Function
SDMA_STATUS_REG         GEQU $AF0430   ; Read only


; Line Interrupt registers

VKY_LINE_IRQ_CTRL_REG   GEQU $AF001B ;[0] - Enable Line 0, [1] -Enable Line 1
VKY_LINE0_CMP_VALUE_LO  GEQU $AF001C ;Write Only [7:0]
VKY_LINE0_CMP_VALUE_HI  GEQU $AF001D ;Write Only [3:0]
VKY_LINE1_CMP_VALUE_LO  GEQU $AF001E ;Write Only [7:0]
VKY_LINE1_CMP_VALUE_HI  GEQU $AF001F ;Write Only [3:0]

; Interrupt DEF

INT_PENDING_REG0 GEQU $000140 ;
; Polarity Set
INT_POL_REG0     GEQU $000144 ;
; Edge Detection Enable
INT_EDGE_REG0    GEQU $000148 ;
; Mask
INT_MASK_REG0    GEQU $00014C ;
; Interrupt Bit Definition
; Register Block 0
FNX0_INT00_SOF        GEQU $01  ;Start of Frame @ 60FPS
FNX0_INT01_SOL        GEQU $02  ;Start of Line (Programmable)
FNX0_INT02_TMR0       GEQU $04  ;Timer 0 Interrupt
FNX0_INT03_TMR1       GEQU $08  ;Timer 1 Interrupt
FNX0_INT04_TMR2       GEQU $10  ;Timer 2 Interrupt
FNX0_INT05_RTC        GEQU $20  ;Real-Time Clock Interrupt
FNX0_INT06_FDC        GEQU $40  ;Floppy Disk Controller
FNX0_INT07_MOUSE      GEQU $80  ; Mouse Interrupt (INT12 in SuperIO IOspace)



;
; Where VRAM is located in CPU Space
;
VRAM GEQU $B00000

; Location in SRAM
C1BUFFER GEQU $002000

; C1VRAM location
C1VRAM GEQU $100000


;
; Location of the first 128 x 200 pixels
; laid out in TileSet 0 (in 256x256 mode)
;
VICKY_DISPLAY_BUFFER0 GEQU $000000
;
; Location of the second part of our screen
; laid out in TileSet 1 (in 256x256 mode)
;
VICKY_DISPLAY_BUFFER1 GEQU $010000
;
; Map Data for Tile Layer 0
VICKY_TILEMAP0 GEQU $020000
; Map Data for Tile Layer 1
VICKY_TILEMAP1 GEQU $030000

; The size of the memory we are using in the tile
; we need every other column set to zero
TILE_CLEAR_SIZE GEQU 256*200
; Clear the entire map
MAP_CLEAR_SIZE GEQU 32*16*2

;
; Vicky Compatible Map data, used to tell vicky which
; tiles to display on the layer
;
map_data start C1UTIL
; Declare the variables
	lcla &var
	lcla &count
; Initialize values
&var seta 0
&count seta 13
.loop
	dc i'$000+&var,$001+&var,$002+&var,$003+&var,$004+&var,$005+&var,$006+&var,$007+&var'
	dc i'$008+&var,$009+&var,$00A+&var,$00B+&var,$00C+&var,$00D+&var,$00E+&var,$00F+&var'
	dc i'$100+&var,$101+&var,$102+&var,$103+&var,0,0,0,0'
	dc i'0,0,0,0,0,0,0,0'
&var seta &var+16
&count seta &count-1
	aif &count,.loop

;------------------------------------------------------------------------------
;
; Input GS Color in A 0x0BGR
;
; output 0x00RRGGBB in Direct Page 0
;
GS2FMXcolor entry
rgb		equ 0
		pha
		and #$00F		; Blue
		sta <rgb
		asl a
		asl a
		asl a
		asl a
		tsb <rgb

; Green
		lda 1,s
		and #$0F0 		; Green
		sta <rgb+1
		lsr a
		lsr a
		lsr a
		lsr a
		tsb <rgb+1

; Red
		pla
		and #$F00       ; Red
		xba
		sta <rgb+2
		asl a
		asl a
		asl a
		asl a
		ora #$FF00   ; Set alpha to 1
		tsb <rgb+2

		rts

;------------------------------------------------------------------------------
; WaitVBL - wait for VBlank to begin
; Preserve all registers, and processor status
;
WaitVBL anop
		php
		pha
		lda <dpJiffy
wait_lp	anop
		cmp <dpJiffy
		beq wait_lp
		pla
		plp
		rts

;------------------------------------------------------------------------------
;
; Clut Buffer
;
pal_buffer anop
		ds 1024



		aif 1,.COMMENTOUT
;------------------------------------------------------------------------------
;
; DMA the Data into VRAM
; You know this is going to have a rip in it at 256 pixels horizontally
; and that you will have to recode this to do 1 whole 320 pixel line at a time
; right?
;
C1BlitPixels_new entry

;		jsr WaitVBL

		sei

		phb

; TODO a macro that will pea the current bank, and the bank I want
; to save plb, and phk instructions
		pea VDMA_CONTROL_REG|-8

		plb
		plb

;------------------------------------------------------------------------------
; 1D SDMA to 1D VDMA Block Copy

		sep #$20
		longa off

; Disable DMA Circuits
		stz |SDMA_CTRL_REG0
		stz |VDMA_CONTROL_REG

; Enable SDMA Circuit
		lda #SDMA_CTRL0_Enable+SDMA_CTRL0_SysRAM_Src
		sta |SDMA_CTRL_REG0
; Enable VDMA Circuit
;		lda #VRAM_CTRL_Enable+VDMA_CTRL_SysRAM_Src
		sta |VDMA_CONTROL_REG

; Source Address for SDMA
		ldx #C1BUFFER
		stx |SDMA_SRC_ADDY_L
		lda #C1BUFFER|-16
		sta |SDMA_SRC_ADDY_H

; Dest Addres for VDMA
		ldx #C1VRAM
		stx |VDMA_DST_ADDY_L
		lda #C1VRAM|-16
		sta |VDMA_DST_ADDY_H

		ldy #0
		ldx #160*200     ; 160 bytes wide, by 200 lines tall
		stx |SDMA_SIZE_L
		sty |SDMA_SIZE_H

		stx |VDMA_SIZE_L
		sty |VDMA_SIZE_H

		sty |SDMA_SRC_STRIDE_L
		sty |VDMA_DST_STRIDE_L

		lda #VDMA_CTRL_Start_TRF
		tsb |VDMA_CONTROL_REG
;		lda #SDMA_CTRL0_Start_TRF
		tsb |SDMA_CTRL_REG0

		nop
		nop
		nop
		nop
		nop

; There is a DMA FIFO so, SDMA can finish before VDMA
wait_dma anop
		lda |VDMA_STATUS_REG										 ; 4
		bmi wait_dma    											 ; 3/2 (Branch/NB)

		stz |SDMA_CTRL_REG0 										 ; 4
		stz |VDMA_CONTROL_REG   									 ; 4

		rep #$31													 ; 3
		longa on
		longi on

;------------------------------------------------------------------------------
;
; 2D VDMA->2D VDMA Deswizzle
;
;------------------------------------------------------------------------------
src equ 0
dst equ 4
count equ 8

		pei src
		pei src+2
		pei dst
		pei dst+2
		pei count

		lcla &lines
		lcla &chunk_size
&lines seta 1
&chunk_size seta 64*&lines

		lda #C1VRAM
		sta <src
		lda #C1VRAM|-16
		sta <src+2
		lda #VICKY_DISPLAY_BUFFER0
		sta <dst
		lda #VICKY_DISPLAY_BUFFER0|-16
		sta <dst+2

		stz <count

looper  anop

		sep #$20														; 3
		longa off
; make sure not active  											
		stz |VDMA_CONTROL_REG   										; 4

; activate VDMA
		lda #VDMA_CTRL_Enable+VDMA_CTRL_1D_2D						  	; 2
		sta |VDMA_CONTROL_REG   										; 4

; Setup Source Address in RAM
		ldx <src   														; 4
		stx |VDMA_SRC_ADDY_L											; 5
		lda <src+2 														; 3
		sta |VDMA_SRC_ADDY_H											; 4

; Setup Dest Address in VRAM
		ldx <dst   													; 4
		stx |VDMA_DST_ADDY_L											; 5
		lda <dst+2 													; 3
		sta |VDMA_DST_ADDY_H											; 4

; Setup Src/Dst Destination Size
		ldx #1  														; 3
		stx |VDMA_X_SIZE_L  											; 5
		ldy #&chunk_size												; 3
		sty |VDMA_Y_SIZE_L  											; 5

; Source Stride in bytes
		ldx #2															; 3
		stx |VDMA_SRC_STRIDE_L  										; 5
; Dest Stride
		ldx #4  														; 3
		stx |VDMA_DST_STRIDE_L  										; 5

; Start VDMA First (I guess it waits)
		lda #VDMA_CTRL_Start_TRF   ; 2
		tsb |VDMA_CONTROL_REG      ; 6

; waiting a total of 12 clocks from the VDMA_CONTROL_REG trigger
		NOP ; 2 When the transfer is started the CPU will be put on Hold (RDYn)... 
		NOP ; 2 Before it actually gets to stop it will execute a couple more instructions
		NOP ; From that point on, the CPU is halted (keep that in mind) No IRQ will be processed either during that time

; There is a DMA FIFO so, SDMA can finish before VDMA
wait_vdma anop
		lda |VDMA_STATUS_REG										 ; 4
		bmi wait_vdma    											 ; 3/2 (Branch/NB)

		stz |VDMA_CONTROL_REG   									 ; 4

		rep #$31													 ; 3
		longa on
		longi on

		lda <count 													 ; 4
		inc a														 ; 2
		cmp #(200/&lines) 											 ; 3
		bcs donedaddy  											 ; 2/3 (NB/Branch)
		sta <count 													 ; 4

		lda <src   													 ; 4
		adc #(160*&lines)                                            ; 3
		sta <src   													 ; 4

		lda <dst   													 ; 4
		adc #(256*&lines) 											 ; 3
		sta <dst   													 ; 4

		jmp looper 													 ; 3    (about 155+32 clocks to move the data) 187 clocks vs the 256 clocks to use the CPU (still a win)

donedaddy anop

;------------------------------------------------------------------------------
; now do the 64 pixels on the right
; Another Loop for the 32 bytes (64 pixels) that we didn't transfer above

&lines seta 1
&chunk_size seta 16*&lines

		lda #C1VRAM+128
		sta <src
		lda #C1VRAM|-16
		sta <src+2
		lda #VICKY_DISPLAY_BUFFER1
		sta <dst
		lda #VICKY_DISPLAY_BUFFER1|-16
		sta <dst+2

		stz <count

looper2 anop

		sep #$20   															; 3
		longa off
; make sure not active  											
;stz |VDMA_CONTROL_REG   											; 4

; activate VDMA
		lda #VDMA_CTRL_Enable+VDMA_CTRL_1D_2D						  		; 2
		sta |VDMA_CONTROL_REG   											; 4

; Setup Source Address in RAM
		ldx <src   														; 4
		stx |VDMA_SRC_ADDY_L												; 5
		lda <src+2 														; 3
		sta |VDMA_SRC_ADDY_H												; 4

; Setup Dest Address in VRAM
		ldx <dst   														; 4
		stx |VDMA_DST_ADDY_L												; 5
		lda <dst+2 														; 3
		sta |VDMA_DST_ADDY_H												; 4

; Setup Source Destination Size
		ldx #1  															; 3
		stx |VDMA_X_SIZE_L  												; 5
		ldy #&chunk_size													; 3
		sty |VDMA_Y_SIZE_L  												; 5

; Source Stride in bytes
		ldx #2 		 														; 3
		stx |VDMA_SRC_STRIDE_L  											; 5
; Dest Stride
		ldx #4  															; 3
		stx |VDMA_DST_STRIDE_L  											; 5

; Start VDMA First (I guess it waits)
		lda #VDMA_CTRL_Start_TRF   ; 2
		tsb |VDMA_CONTROL_REG      ; 6

; waiting a total of 12 clocks from the VDMA_CONTROL_REG trigger
		NOP ; 2 When the transfer is started the CPU will be put on Hold (RDYn)... 
		NOP ; 2 Before it actually gets to stop it will execute a couple more instructions
		NOP ; From that point on, the CPU is halted (keep that in mind) No IRQ will be processed either during that time

; There is a DMA FIFO so, SDMA can finish before VDMA
wait_vdma2 anop
		lda |VDMA_STATUS_REG											     ; 4
		bmi wait_vdma2   													 ; 3 on branch/ 2 no branch

		stz |VDMA_CONTROL_REG   											 ; 4

		rep #$31															 ; 3
		longa on
		longi on

		lda <count 														 	 ; 4
		inc a																 ; 2
		cmp #(200/&lines) 													 ; 3
		bcs donemommy  													 	 ; 2/3 (B or NB)
		sta <count 														 	 ; 4

		lda <src   														 	 ; 4
		adc #(160*&lines)                                                    ; 3 
		sta <src   														 	 ; 4

		lda <dst   														 	 ; 4
		adc #(256*&lines) 													 ; 3
		sta <dst   														 	 ; 4

		jmp looper2 														 ; 3    (about 155+32 clocks to move the data) 187 clocks vs the 256 clocks to use the CPU (still a win)

donemommy anop

		pla
		sta <count
		pla
		sta <dst+2
		pla
		sta <dst
		pla
		sta <src+2
		pla
		sta <src

		plb

		cli

		rtl

.COMMENTOUT

;------------------------------------------------------------------------------
;
; DMA the Data into VRAM
; You know this is going to have a rip in it at 256 pixels horizontally
; and that you will have to recode this to do 1 whole 320 pixel line at a time
; right?
;
;     This is commented back in
		aif 0,.C1COMMENTEDOUT
C1BlitPixels entry

;		jsr WaitVBL

		sei

		sep #$30
		longa off
		longi off

		lda #$FF
		sta >BORDER_COLOR_B
		sta >BORDER_COLOR_G
		sta >BORDER_COLOR_R


; Enable Line Interrupt
		lda #1
		sta >VKY_LINE_IRQ_CTRL_REG

		lda #200
		sta >VKY_LINE0_CMP_VALUE_LO
		lda #0
		sta >VKY_LINE0_CMP_VALUE_HI

		lda >INT_MASK_REG0
		and #%11111101
		sta >INT_MASK_REG0

; Clear Line Interrupt
		lda #2
		sta >INT_PENDING_REG0

; Wait for Line interrupt
waitforline anop
		lda >INT_PENDING_REG0
		and #2
		beq waitforline

; Clear Line Interrupt
		sta >INT_PENDING_REG0

		lda #$00
		sta >BORDER_COLOR_B
		sta >BORDER_COLOR_G
;sta >BORDER_COLOR_R

;       Video Off
		lda #$80
		sta >MASTER_CTRL_REG_L


;		lda #200
;		sta >VKY_LINE0_CMP_VALUE_LO
;
;; Wait for Line interrupt
;waitforline2 anop
;		lda >INT_PENDING_REG0
;		and #2
;		beq waitforline2
;
;; Clear Line Interrupt
;		sta >INT_PENDING_REG0
;
;		lda #$00
;		sta >BORDER_COLOR_R
;
;;       Video On
;		lda #VIDEO_MODE
;		sta >MASTER_CTRL_REG_L

;
;       Video Off
;		lda >MASTER_CTRL_REG_L
;		ora #$80
;		sta >MASTER_CTRL_REG_L
;
;		ldx #0
;loop	dex
;		bne loop
;
;		and #$7F
;		sta >MASTER_CTRL_REG_L
;
		rep #$30
		longa on
		longi on

		phb

; TODO a macro that will pea the current bank, and the bank I want
; to save plb, and phk instructions
		pea VDMA_CONTROL_REG|-8

		plb
		plb

src equ 0
dst equ 4
count equ 8

		pei src
		pei src+2
		pei dst
		pei dst+2
		pei count

		lcla &lines
		lcla &chunk_size
&lines seta 100
&chunk_size seta 128*&lines

		lda #C1BUFFER
		sta <src
		lda #C1BUFFER|-16
		sta <src+2
		lda #VICKY_DISPLAY_BUFFER0
		sta <dst
		lda #VICKY_DISPLAY_BUFFER0|-16
		sta <dst+2

		stz <count

looper  anop

		sep #$20														; 3
		longa off
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
		ldx <src   													; 4
		stx |SDMA_SRC_ADDY_L											; 5
		lda <src+2 													; 3
		sta |SDMA_SRC_ADDY_H											; 4

; Setup Dest Address in VRAM
		ldx <dst   													; 4
		stx |VDMA_DST_ADDY_L											; 5
		lda <dst+2 													; 3
		sta |VDMA_DST_ADDY_H											; 4

; Setup Source Size
		ldx #128														; 3
		stx |SDMA_X_SIZE_L  											; 5
		ldy #&lines 													; 3
		sty |SDMA_Y_SIZE_L  											; 5

; Setup Destination Size
		ldx #1  														; 3
		stx |VDMA_X_SIZE_L  											; 5
		ldy #&chunk_size												; 3
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
		NOP ; From that point on, the CPU is halted (keep that in mind) No IRQ will be processed either during that time
		NOP
		NOP

; There is a DMA FIFO so, SDMA can finish before VDMA
wait_dma anop
		lda |VDMA_STATUS_REG										 ; 4
		bmi wait_dma    											 ; 3/2 (Branch/NB)

		stz |SDMA_CTRL_REG0 										 ; 4
		stz |VDMA_CONTROL_REG   									 ; 4

		rep #$31													 ; 3
		longa on
		longi on

		lda <count 													 ; 4
		inc a														 ; 2
		cmp #(100/&lines) 											 ; 3
		bcs donedaddy  											 ; 2/3 (NB/Branch)
		sta <count 													 ; 4

		lda <src   													 ; 4
		adc #(160*&lines)                                            ; 3
		sta <src   													 ; 4

		lda <dst   													 ; 4
		adc #(256*&lines) 											 ; 3
		sta <dst   													 ; 4

		jmp looper 													 ; 3    (about 155+32 clocks to move the data) 187 clocks vs the 256 clocks to use the CPU (still a win)

donedaddy anop

;;------------------------------------------------------------------------------
;; now do the 64 pixels on the right
;; Another Loop for the 32 bytes (64 pixels) that we didn't transfer above
;
;&lines seta 1
;&chunk_size seta 32*&lines
;
;		lda #C1BUFFER+128
;		sta <src
;		lda #C1BUFFER|-16
;		sta <src+2
;		lda #VICKY_DISPLAY_BUFFER1
;		sta <dst
;		lda #VICKY_DISPLAY_BUFFER1|-16
;		sta <dst+2
;
;		stz <count
;
;looper2 anop
;
;		sep #$20   															; 3
;		longa off
;; make sure not active  											
;;stz |SDMA_CTRL_REG0 												; 4
;;stz |VDMA_CONTROL_REG   											; 4
;
;; activate SDMA
;		lda #SDMA_CTRL0_Enable+SDMA_CTRL0_1D_2D+SDMA_CTRL0_SysRAM_Src		; 2
;;lda #SDMA_CTRL0_Enable+SDMA_CTRL0_SysRAM_Src
;		sta |SDMA_CTRL_REG0 												; 4
;; activate VDMA
;		lda #VDMA_CTRL_Enable+VDMA_CTRL_1D_2D+VDMA_CTRL_SysRAM_Src  		; 2
;		sta |VDMA_CONTROL_REG   											; 4
;
;; Setup Source Address in RAM
;		ldx <src   														; 4
;		stx |SDMA_SRC_ADDY_L												; 5
;		lda <src+2 														; 3
;		sta |SDMA_SRC_ADDY_H												; 4
;
;; Setup Dest Address in VRAM
;		ldx <dst   														; 4
;		stx |VDMA_DST_ADDY_L												; 5
;		lda <dst+2 														; 3
;		sta |VDMA_DST_ADDY_H												; 4
;
;; Setup Source Size
;		ldx #32 															; 3
;		stx |SDMA_X_SIZE_L  												; 5
;		ldy #&lines 														; 3
;		sty |SDMA_Y_SIZE_L  												; 5
;
;; Setup Destination Size
;		ldx #1  															; 3
;		stx |VDMA_X_SIZE_L  												; 5
;		ldy #&chunk_size													; 3
;		sty |VDMA_Y_SIZE_L  												; 5
;
;; Source Stride in bytes
;		ldx #160															; 3
;		stx |SDMA_SRC_STRIDE_L  											; 5
;; Dest Stride
;		ldx #2  															; 3
;		stx |VDMA_DST_STRIDE_L  											; 5
;
;; Start VDMA First (I guess it waits)
;		lda #VDMA_CTRL_Start_TRF   ; 2
;		tsb |VDMA_CONTROL_REG      ; 6
;		lda #SDMA_CTRL0_Start_TRF  ; 2
;		tsb |SDMA_CTRL_REG0 	   ; 6
;
;; waiting a total of 12 clocks from the VDMA_CONTROL_REG trigger
;		NOP ; 2 When the transfer is started the CPU will be put on Hold (RDYn)... 
;		NOP ; 2 Before it actually gets to stop it will execute a couple more instructions
;		NOP ; From that point on, the CPU is halted (keep that in mind) No IRQ will be processed either during that time
;		NOP
;		NOP
;
;; There is a DMA FIFO so, SDMA can finish before VDMA
;wait_dma2 anop
;		lda |VDMA_STATUS_REG											     ; 4
;		bmi wait_dma2   													 ; 3 on branch/ 2 no branch
;
;		stz |SDMA_CTRL_REG0 												 ; 4
;		stz |VDMA_CONTROL_REG   											 ; 4
;
;		rep #$31															 ; 3
;		longa on
;		longi on
;
;		lda <count 														 ; 4
;		inc a																 ; 2
;		cmp #(200/&lines) 													 ; 3
;		bcs donemommy  													 ; 2/3 (B or NB)
;		sta <count 														 ; 4
;
;		lda <src   														 ; 4
;		adc #(160*&lines)                                                    ; 3 
;		sta <src   														 ; 4
;
;		lda <dst   														 ; 4
;		adc #(256*&lines) 													 ; 3
;		sta <dst   														 ; 4
;
;		jmp looper2 														 ; 3    (about 155+32 clocks to move the data) 187 clocks vs the 256 clocks to use the CPU (still a win)
;
;donemommy anop

		pla
		sta <count
		pla
		sta <dst+2
		pla
		sta <dst
		pla
		sta <src+2
		pla
		sta <src

		plb


		sep #$30
		longa off
		longi off

; 		No Line Interrupt
		lda #0
		sta >VKY_LINE_IRQ_CTRL_REG
;
		lda >INT_MASK_REG0
		ora #$02
		sta >INT_MASK_REG0

; Clear Line Interrupt
		lda #2
		sta >INT_PENDING_REG0

;       Video On
		lda #VIDEO_MODE
		sta >MASTER_CTRL_REG_L

		rep #$30
		longa on
		longi on

		cli

		rtl

.C1COMMENTEDOUT

;------------------------------------------------------------------------------
;
; Kick up palettes
;
C1BlitPalettes entry
		phb

; First Convert the palette colors into FMX Format

		phk
		plb

temp equ 0
		pei temp
		pei temp+2

		lda #0
; Convert 16 color from GS format, to FMX
pal_lp  pha
		asl a
		tax
		lda >$009E00,x
		jsr GS2FMXcolor
		txa
		asl a
		tax
		lda <temp
		sta |pal_buffer,x
		lda <temp+2
		sta |pal_buffer+2,x
		pla
		inc a
		cmp #16
		bcc pal_lp

; Now update the Background Color, so the transparent pixels show the correct
; Color

		lda |pal_buffer
		sta >BACKGROUND_COLOR_B  ; BG
		lda |pal_buffer+1
		sta >BACKGROUND_COLOR_G  ; GR
;--- shared by both lut copys
		pea GRPH_LUT0_PTR|-8
		plb
		plb 

; Now update the CLUT Memory
; First Do LUT0

		ldx #62
lut0_loop anop
		lda >pal_buffer,x
		sta |GRPH_LUT0_PTR+(64*0),x
		sta |GRPH_LUT0_PTR+(64*1),x
		sta |GRPH_LUT0_PTR+(64*2),x
		sta |GRPH_LUT0_PTR+(64*3),x
		sta |GRPH_LUT0_PTR+(64*4),x
		sta |GRPH_LUT0_PTR+(64*5),x
		sta |GRPH_LUT0_PTR+(64*6),x
		sta |GRPH_LUT0_PTR+(64*7),x
		sta |GRPH_LUT0_PTR+(64*8),x
		sta |GRPH_LUT0_PTR+(64*9),x
		sta |GRPH_LUT0_PTR+(64*10),x
		sta |GRPH_LUT0_PTR+(64*11),x
		sta |GRPH_LUT0_PTR+(64*12),x
		sta |GRPH_LUT0_PTR+(64*13),x
		sta |GRPH_LUT0_PTR+(64*14),x
		sta |GRPH_LUT0_PTR+(64*15),x
		dex
		dex
		bpl lut0_loop

; Now Do LUT1

		ldx #0
		ldy #0
		clc  ; c=1 from above
		lcla &offset
;		lcla &count
lut1_loop anop
		lda >pal_buffer,x
&offset seta 0
&count seta 16
.lup
		sta |GRPH_LUT1_PTR+&offset,y
&offset seta &offset+4
&count seta &count-1
		aif &count,.lup

		lda >pal_buffer+2,x
&offset seta 0
&count seta 16
.lup2
		sta |GRPH_LUT1_PTR+&offset+2,y
&offset seta &offset+4
&count seta &count-1
		aif &count,.lup2

		txa
		adc #4
		tax
		tya
		adc #64
		tay
		cpx #64
		bcc lut1_loop

		pla
		sta <temp+2
		pla
		sta <temp

		plb
		rtl

;------------------------------------------------------------------------------
;
; Initialize Hardware
;
C1InitVideo entry
		phb

XRES equ 320
YRES equ 240
; 320 x 240, Tile Map Engine enabled
;VIDEO_MODE = $0254

		jsr WaitVBL

; Get B into bank $AF, for shorter Vicky Access
		pea |MASTER_CTRL_REG_L|-8
		plb
		plb

		lda #VIDEO_MODE
		sta |MASTER_CTRL_REG_L

		sep #$10
		longi off
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
		lda #VICKY_DISPLAY_BUFFER0
		sta |TILESET0_ADDY_L
		ldx #VICKY_DISPLAY_BUFFER0|-16
		stx |TILESET0_ADDY_H
; Set TileSet 1 Start Address + 256 Stride Mode
		lda #VICKY_DISPLAY_BUFFER1
		sta |TILESET1_ADDY_L
		ldx #VICKY_DISPLAY_BUFFER1|-16
		stx |TILESET1_ADDY_H
; 256 pixel stride mode
		ldx #8
		stx |TILESET0_ADDY_CFG
		stx |TILESET1_ADDY_CFG

; Set TileMap 0 Start Address
		lda #VICKY_TILEMAP0
		sta |TL0_START_ADDY_L
		ldx #VICKY_TILEMAP0|-16
		stx |TL0_START_ADDY_H
; Set TileMap 1 Start Address
		lda #VICKY_TILEMAP1
		sta |TL1_START_ADDY_L
		ldx #VICKY_TILEMAP1|-16
		stx |TL1_START_ADDY_H

; Set Scroll Positions of the Maps
; Map 0 Position
		lda #15
		sta |TL0_WINDOW_X_POS_L
		lda #12    ;+20
		sta |TL0_WINDOW_Y_POS_L
; Map 1 Position
		lda #16
		sta |TL1_WINDOW_X_POS_L
		lda #12    ;+20
		sta |TL1_WINDOW_Y_POS_L

; Border thing? Hide Garbage pixels
		ldx #Border_Ctrl_Enable
		stx |BORDER_CTRL_REG
		ldx #64
		stx |BORDER_COLOR_B
		sty |BORDER_COLOR_G
		sty |BORDER_COLOR_R
		ldx #8
		stx |BORDER_X_SIZE
		ldx #20
		stx |BORDER_Y_SIZE

;-----------------------------------------------

		rep #$30
		longa on
		longi on

; Clear Tile Catalog 0
		pea VICKY_DISPLAY_BUFFER0|-16
		pea VICKY_DISPLAY_BUFFER0

		pea TILE_CLEAR_SIZE|-16
		pea TILE_CLEAR_SIZE

		jsr vmemset0

; Clear Tile Catalog 1
		pea VICKY_DISPLAY_BUFFER1|-16
		pea VICKY_DISPLAY_BUFFER1

		pea TILE_CLEAR_SIZE|-16
		pea TILE_CLEAR_SIZE

		jsr vmemset0

; Clear Tile Map 0
		pea VICKY_TILEMAP0|-16
		pea VICKY_TILEMAP0

		pea MAP_CLEAR_SIZE|-16
		pea MAP_CLEAR_SIZE
		
		jsr vmemset0

; Clear Tile Map 1
		pea VICKY_TILEMAP1|-16
		pea VICKY_TILEMAP1

		pea MAP_CLEAR_SIZE|-16
		pea MAP_CLEAR_SIZE
		
		jsr vmemset0

;		do 0
;
;		ldx #0
;		lda #0
;]clear
;		sta >VICKY_DISPLAY_BUFFER0+VRAM,x
;		sta >VICKY_DISPLAY_BUFFER1+VRAM,x
;		sta >VICKY_TILEMAP0+VRAM,x
;		sta >VICKY_TILEMAP1+VRAM,x
;		inx
;		inx
;		cpx #200*256
;		bcc ]clear
;
;		fin

;-----------------------------------------------
; Copy map data to VRAM

		phk
		plb

		ldx #0
map_loop anop
		lda |map_data,x
		sta >VICKY_TILEMAP0+VRAM+(64*2)+4,x
		ora #$800                              ; setup the next palette
		sta >VICKY_TILEMAP1+VRAM+(64*2)+4,x
		inx
		inx
		cpx #32*13*2
		bcc map_loop

		
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
vmemset0 anop

size_bytes equ 3
dest_addr equ 7

; switch into the VDMA Bank
		pea VDMA_CONTROL_REG|-8
		plb
		plb

		stz |VDMA_CONTROL_REG ; Disable DMA, set Fill Byte to 00

		sep #$10
		longi off

; Activate VDMA Circuit
		ldx #VDMA_CTRL_Enable+VDMA_CTRL_TRF_Fill
		stx |VDMA_CONTROL_REG

; Setup the Destination address
		lda dest_addr,s
		sta |VDMA_DST_ADDY_L
		lda dest_addr+1,s
		sta |VDMA_DST_ADDY_L+1

; set the length
		lda size_bytes,s
		sta |VDMA_SIZE_L
		lda size_bytes+2,s
		sta |VDMA_SIZE_L+2

		ldx #VDMA_CTRL_Enable+VDMA_CTRL_TRF_Fill+VDMA_CTRL_Start_TRF
		stx |VDMA_CONTROL_REG  ; kick the dma

		nop
		nop
		nop
		nop

vwait_dma anop
		ldx |VDMA_STATUS_REG
		bmi vwait_dma

		ldx #0  			   ; done
		stx |VDMA_CONTROL_REG

		rep #$31    ; mxc=000
		longi on
		longa on

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
		end
;------------------------------------------------------------------------------

