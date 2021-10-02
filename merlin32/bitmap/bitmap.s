;
;  Foenix Bitmap Example in Merlin32
;
; $00:2000 - $00:7FFF are free for application use.
;
        rel     ; relocatable
        lnk     Main.l

        use Util.Macs

		ext title_pic
		ext decompress_lzsa

        mx %00

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
MyDP = $1F00

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

        ; Fill Frame Buffer with Color index 1
;        lda     #$0101
;        ldx     #0
;]lp
;        stal    $B00000,x
;        stal    $B10000,x
;        stal    $B20000,x
;        stal    $B30000,x
;        stal    $B40000,x
;        stal    $B50000,x
;        stal    $B60000,x
;        stal    $B70000,x
;        inx
;        inx
;        bne ]lp
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

