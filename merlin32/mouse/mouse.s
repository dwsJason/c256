;
;  Foenix Mouse Example in Merlin32
;
; $00:2000 - $00:7FFF are free for application use.
;
        rel     ; relocatable
        lnk     Main.l

        use Util.Macs

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
			  
;
; Decompress to this address
;
pixel_buffer = $100000	; need about 480k, put it in memory at 1.25MB mark
						; try to leave room for kernel on a U
		
; Kernel method
PUTS = $00101C         ; Print a string to the currently selected channel

; Some HW Addresses - Defines
MASTER_CTRL_REG_L	    = $AF0000
GRPH_LUT0_PTR		    = $AF2000

BM_Enable             = $01

BM_LUT0               = $00 ;
BM_LUT1               = $02 ;
BM_LUT2               = $04 ;
BM_LUT3               = $06 ;
BM_LUT4               = $08 ;
BM_LUT5               = $0A ;
BM_LUT6               = $0C ;
BM_LUT7               = $0E ;

BM_Collision_On       = $40 ; 

; First BitMap Plane
BM0_CONTROL_REG     = $AF0100
BM0_START_ADDY_L    = $AF0101
BM0_START_ADDY_M    = $AF0102
BM0_START_ADDY_H    = $AF0103
BM0_X_OFFSET        = $AF0104   ; Not Implemented
BM0_Y_OFFSET        = $AF0105   ; Not Implemented
BM0_RESERVED_6      = $AF0106
BM0_RESERVED_7      = $AF0107
; Second BitMap Plane
BM1_CONTROL_REG     = $AF0108
BM1_START_ADDY_L    = $AF0109
BM1_START_ADDY_M    = $AF010A
BM1_START_ADDY_H    = $AF010B
BM1_X_OFFSET        = $AF010C   ; Not Implemented
BM1_Y_OFFSET        = $AF010D   ; Not Implemented
BM1_RESERVED_6      = $AF010E
BM1_RESERVED_7      = $AF010F

BACKGROUND_COLOR_B      = $AF000D ; When in Graphic Mode, if a pixel is "0" then the Background pixel is chosen
BACKGROUND_COLOR_G      = $AF000E
BACKGROUND_COLOR_R      = $AF000F ;


VRAM = $B00000

;------------------------------------------------------------------------------
; I like having my own Direct Page
MyDP = $2000

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

		lda #$014C  		  	; 800x600 + Gamma + Bitmap_en
		sta >MASTER_CTRL_REG_L

		lda #BM_Enable
		sta >BM0_CONTROL_REG

		lda	#VRAM
		sta >BM0_START_ADDY_L
		lda #0
		;lda #>VRAM
		sta >BM0_START_ADDY_M
		;lda #^VRAM
		lda #0
		sta >BM0_START_ADDY_H

		lda #0
		sta >BM0_X_OFFSET
		sta >BM0_Y_OFFSET
		sta >BM1_CONTROL_REG

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

:stop   bra :stop


;-------------------------------------------------------------------------------


        ; Set Background Color
        lda     #$00FF
        stal    $AF0008 ; back
        stal    $AF0005 ; border
        lda     #$0000
        stal    $AF000A ; back
        stal    $AF0007 ; border       


        ; graphics + bitmap on
        lda     #$C     ; graph + bitmap
        stal    $AF0000

;        lda     #$00FF  ; blue
;        lda     #$FF00  ; green
		lda		#0
        stal    $AF2004
        lda     #$00FF ; red
;        lda     #$0000
        stal    $AF2006

        ; Clear 4 Palettes worth of colors
        ldy     #<$AF2004  ; Destination
        ldx     #<$AF2000
        lda     #{1023*4}-1
        ;mvn     ^$AF2000,^$AF2004    ; src,dest

        phk
        plb

        ; no border
        lda     #0
        stal    $AF0004  ; border control

        ; bitmap on
        lda     #1
        stal    $AF0140
        ; bitmap at address 0 (0xB00000)
        lda     #0
        stal    $AF0142

        lda     #640
        stal    $AF0144
        lda     #480
        stal    $AF0146

        ; Fill Frame Buffer with Color index 1
        lda     #$0101
        ldx     #0
]lp
        stal    $B00000,x
        stal    $B10000,x
        stal    $B20000,x
        stal    $B30000,x
        stal    $B40000,x
        inx
        inx
        bne ]lp

        ;ldx     #$0000 ;src
        ;ldy     #$0002 ;dst
        ;da     #$fffd
        ;vn     $B0,$B0

        ;lda #$ffff
        ;mvn     $B1,$B1
        ;lda #$ffff
        ;mvn     $B2,$B2
        ;lda #$ffff
        ;mvn     $B3,$B3
        ;lda #$ffff
        ;mvn     $B4,$B4

        phk
        plb



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
