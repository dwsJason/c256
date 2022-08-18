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
		ext song_adpcm

        mx %00

;
; Decompress to this address
;
pixel_buffer = $300000	; need about 480k, put it in memory at 3MB mark


; Kernel method
PUTS = $00101C         ; Print a string to the currently selected channel

; Some HW Addresses - Defines
MASTER_CTRL_REG_L	    = $AF0000
GRPH_LUT0_PTR		    = $AF2000
GRPH_LUT1_PTR		    = $AF2400

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
temp8          = 58
temp9          = 62
temp10         = 66
; plot-unplot variable
vis_column     = 128
vis_scanline   = 132
vis_jiffy      = 136




start   ent             ; make sure start is visible outside the file
        clc
        xce
        rep $31         ; long MX, and CLC

		stz <vis_column

; Default Stack is on top of System DMA Registers
; So move the stack before proceeding

        lda #$BFFF      ; I really don't know much RAM the kernel is using in bank 0
        tcs

        lda #MyDP
        tcd

		lda #$014C  		  	; 800x600 + Gamma + Bitmap_en
		sta >MASTER_CTRL_REG_L

		sep #$30
		lda #BM_Enable
		sta >BM1_CONTROL_REG

		lda	#VRAM
		sta >BM0_START_ADDY_L
		sta >BM1_START_ADDY_L
		lda #0
		;lda #>VRAM
		sta >BM0_START_ADDY_M
		sta >BM1_START_ADDY_M
		;lda #^VRAM
		lda #0
		sta >BM1_START_ADDY_H
		lda #8
		sta >BM0_START_ADDY_H


		lda #0
		sta >BM0_X_OFFSET
		sta >BM0_Y_OFFSET
		sta >BM1_X_OFFSET
		sta >BM1_Y_OFFSET

		lda #BM_Enable+BM_LUT1
		sta >BM0_CONTROL_REG

		rep #$30
        ; no border
        lda     #0
        stal    $AF0004  ; border control

		; no cursor
		lda #0
		ldx #$1FE
]clear  sta >$AF0500,x
		dex
		dex
		bpl ]clear

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

;------------------------------------------------------------------------------
; poke in a bright green color
		lda #$00
		sta >GRPH_LUT1_PTR
		sta >GRPH_LUT1_PTR+2
		lda #$FF00
		sta >GRPH_LUT1_PTR+4
		sta >GRPH_LUT1_PTR+6

;------------------------------------------------------------------------------
; dim the pal_buffer

		sep #$20
		ldx #1024-1
]dim	lda |pal_buffer,x
		lsr
		lsr
		sta |pal_buffer,x
		dex
		bpl ]dim
		rep #$30

;------------------------------------------------------------------------------

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

		;lda #$FFFF
		;sta >BACKGROUND_COLOR_B
		;sta >BACKGROUND_COLOR_G

;-------------------------------------------------
		lda #0
		tax
		;lda #$01
]clear
		sta >VRAM+$80000,x
		sta >VRAM+$90000,x
		sta >VRAM+$A0000,x
		sta >VRAM+$B0000,x
		sta >VRAM+$C0000,x
		sta >VRAM+$D0000,x
		sta >VRAM+$E0000,x
		sta >VRAM+$F0000,x
		inx
		inx
		bne ]clear

;-------------------------------------------------



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

		pea $AFAF
		plb
		plb

		sep #$30
		lda #2
		sta |$AF1900   ; reset FIFO

		lda #8
		sta |$AF1900

		lda #9
		sta |$AF1900   ; un reset FIFO, 16 Bits Mono, and start playing

		rep #$30

;SONG_LEN = 2527680
SONG_LEN = $269000
CHUNK_SIZE equ 512

:pSource = temp0
:pEnd    = temp1

		lda #song_adpcm
		sta <:pSource
		lda #^song_adpcm
		sta <:pSource+2

		lda #song_adpcm+SONG_LEN
		sta <:pEnd
		clc
		lda <:pSource+2
		adc #^SONG_LEN
		sta <:pEnd+2

]loop
		jsr adpcm_decode_block

		; next block
		clc
		lda <:pSource
		adc #CHUNK_SIZE
		sta <:pSource
		lda <:pSource+2
		adc #0
		sta <:pSource+2

		; $2691C0
		cmp <:pEnd+2
		bcc ]loop
		lda <:pSource
		cmp <:pEnd
		bcc ]loop

		; out of blocks; so start over
		lda #song_adpcm
		sta <:pSource
		lda #^song_adpcm
		sta <:pSource+2
		bra ]loop

;------------------------------------------------------------------------------
StuffSample mx %
		cmp #$8000
		ror
		cmp #$8000
		ror
		cmp #$8000
		ror
		cmp #$8000
		ror
		sta |$AF1908  	; store 2x, because our wave is 24Khz
		sta |$AF1908

		jsr UnPlotPlot

]fifo_wait
		lda |$AF1904	; we wait while the FIFO is almost full
		and #$FFF
		cmp #$FFA
		bcs ]fifo_wait

		rts

;------------------------------------------------------------------------------
; 512 byte ADPCM block will contain 1017 samples * 1 channels
;
adpcm_decode_block mx %00
:pInBuffer = temp0
:pSource = temp2
:sample  = temp3
:index   = temp4
:chunks  = temp5
:step    = temp6
:delta   = temp7
:invalue = temp8
:step_1  = temp9
:step_2  = temp10


		lda <:pInBuffer
		sta <:pSource
		lda <:pInBuffer+2
		sta <:pSource+2

		stz <:sample+2
		lda [:pSource]
		sta <:sample
		bpl :sample_pos
		dec <:sample+2
:sample_pos

		jsr StuffSample

		jsr :incSource2

		lda [:pSource]
;		and #$FF
;		cmp #88
;		bcc :sta
;		lda #88
;:sta
		sta <:index

		jsr :incSource2

		lda #{CHUNK_SIZE/4}-1 ; 128
		sta <:chunks

]chunks_loop
		ldy #4
]chunk_loop
        ;uint16_t step = step_table [index [ch]], delta = step >> 3;
		jsr :setup_step

        ;if (*inbuf & 1) delta += (step >> 2);
		lda [:pSource]
		jsr :incSource1

		;and #$FF
		sta <:invalue

		bit #1
		beq :not1

		lda <:delta
		clc
		adc <:step_2
		sta <:delta
		lda <:delta+2
		adc #0
		sta <:delta+2

		lda <:invalue
:not1
        ;if (*inbuf & 2) delta += (step >> 1);
		bit #2
		beq :not2

		lda <:delta
		clc
		adc <:step_1
		sta <:delta
		lda <:delta+2
		adc #0
		sta <:delta+2

		lda <:invalue
:not2
        ;if (*inbuf & 4) delta += step;
		bit #4
		beq :not4

		lda <:delta
		clc
		adc <:step
		sta <:delta
		lda <:delta+2
		adc #0
		sta <:delta+2

		lda <:invalue

        ;if (*inbuf & 8)
        ;    pcmdata[ch] -= delta;
        ;else
        ;    pcmdata[ch] += delta;
:not4
		bit #8
		beq :not8

		sec
		lda <:sample
		sbc <:delta
		sta <:sample
		lda <:sample+2
		sbc <:delta+2
		sta <:sample+2

		bra :update_index
:not8
		clc
		lda <:sample
		adc <:delta
		sta <:sample
		lda <:sample+2
		adc <:delta+2
		sta <:sample+2

        ;index[ch] += index_table [*inbuf & 0x7];
:update_index
		lda <:invalue
		and #7
		asl
		tax
		lda >index_table,x
		adc <:index
;       CLIP(index[ch], 0, 88);

		bpl :pos
		lda #0
:pos
		cmp #88
		bcc :ok
		lda #88
:ok
		sta <:index

; sample clip code here
;        CLIP(pcmdata[ch], -32768, 32767);
; in order for this to mean something, I need to increase the :sample to 32 bits
		jsr :clip_sample

		jsr StuffSample

;------------------------------------------------------------------------------

        ;step = step_table [index [ch]]; delta = step >> 3;
		jsr :setup_step

        ;if (*inbuf & 0x10) delta += (step >> 2);
		lda <:invalue
		bit #$10
		beq :no16
		clc
		lda <:delta
		adc <:step_2
		sta <:delta
		lda <:delta+2
		adc #0
		sta <:delta+2

		lda <:invalue
:no16
        ;if (*inbuf & 0x20) delta += (step >> 1);
		bit #$20
		beq :no32
		clc
		lda <:delta
		adc <:step_1
		sta <:delta
		lda <:delta+2
		adc #0
		sta <:delta+2

		lda <:invalue
:no32
        ;if (*inbuf & 0x40) delta += step;
		bit #$40
		beq :no64

		lda <:delta
		clc
		adc <:step
		sta <:delta
		lda <:delta+2
		adc #0
		sta <:delta+2

		lda <:invalue
:no64
        ;if (*inbuf & 0x80)
        ;    pcmdata[ch] -= delta;
        ;else
        ;    pcmdata[ch] += delta;
		bit #$80
		beq :no128

		sec
		lda <:sample
		sbc <:delta
		sta <:sample
		lda <:sample+2
		sbc <:delta+2
		sta <:sample+2

		bra :update_index2
:no128 
		clc
		lda <:sample
		adc <:delta
		sta <:sample
		lda <:sample+2
		adc <:delta+2
		sta <:sample+2

;        index[ch] += index_table [(*inbuf >> 4) & 0x7];
:update_index2
		lda <:invalue
		lsr
		lsr
		lsr
		lsr
		and #7
		asl
		tax
		lda >index_table,x
		adc <:index
;        CLIP(index[ch], 0, 88);
		bpl :pos2
		lda #0
:pos2
		cmp #88
		bcc :isgood
		lda #88
:isgood
		sta <:index
;        CLIP(pcmdata[ch], -32768, 32767);
		jsr :clip_sample

		jsr StuffSample

		dey
		beq :done
		jmp ]chunk_loop
:done
		dec <:chunks
		beq :donedone
		jmp ]chunks_loop
:donedone
		rts


:incSource2
		inc <:pSource
		bne :incSource1
		inc <:pSource+2 ; wrap

:incSource1
		inc <:pSource
		bne :next
		inc <:pSource+2 ; wrap bank
:next
		rts

        ;uint16_t step = step_table [index [ch]], delta = step >> 3;
:setup_step
		lda <:index
		asl
		tax
		stz <:delta+2
		lda >step_table,x
		sta <:step

		lsr
		sta <:step_1

		lsr
		sta <:step_2

		lsr 
		sta <:delta

		rts

:clip_sample
		lda <:sample+2
		bpl :pos_clip
:neg_clip
		inc
		beq :n2
		lda #$FFFF
		sta <:sample+2
		lda #$8000
		sta <:sample
		rts

:n2
		lda #$FFFF
		sta <:sample+2
		lda <:sample
		cmp #$8000
		bcs :rts
		lda #$8000
		sta <:sample
		rts

:pos_clip
		beq :p2
		stz <:sample+2
		lda #$7FFF
		sta <:sample
		rts
:p2
		stz <:sample+2
		lda <:sample
		cmp #$8000
		bcc :rts
		lda #$7FFF
		sta <:sample
:rts
		rts



;:clip_sample
;		lda <:sample+2
;		bpl :pos_clip
;		inc
;		beq :neg_sample_good
;:neg_clip
;		lda #$FFFF
;		sta <:sample+2
;		lda #$8000
;		sta <:sample
;		rts
;
;:pos_clip
;		beq :sample_pos_good
;		stz <:sample+2
;		lda #$7FFF
;		sta <:sample
;		rts
;
;:neg_sample_good
;		lda <:sample
;		rts
;
;:sample_pos_good
;		lda <:sample
;		rts


;/* step table[89] */
step_table
	dw 7,8,9,10,11,12,13,14,
	dw 16,17,19,21,23,25,28,31,
	dw 34,37,41,45,50,55,60,66,
	dw 73,80,88,97,107,118,130,143,
	dw 157,173,190,209,230,253,279,307,
	dw 337,371,408,449,494,544,598,658,
	dw 724,796,876,963,1060,1166,1282,1411,
	dw 1552,1707,1878,2066,2272,2499,2749,3024,
	dw 3327,3660,4026,4428,4871,5358,5894,6484,
	dw 7132,7845,8630,9493,10442,11487,12635,13899,
	dw 15289,16818,18500,20350,22385,24623,27086,29794,
    dw 32767

;/* step index tables */
index_table
;    /* adpcm data size is 4 */
    dw -1,-1,-1,-1,2,4,6,8


;------------------------------------------------------------------------------


		do 0
		; play a raw sample loop
		rep #$30
:pSource = temp0

		lda #song_adpcm
		sta <:pSource
		lda #^song_adpcm
		sta <:pSource+2
]loop
		lda [:pSource]
		cmp #$8000
		ror
		cmp #$8000
		ror
		sta |$AF1908
		sta |$AF1908

		inc <:pSource
		inc <:pSource
		bne :no_wrap
		inc <:pSource+2  ; wrap to next bank
:no_wrap
]fifo_wait
		lda |$AF1904
		and #$800
		cmp #$800
		bcs ]fifo_wait

		bra ]loop
		fin

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

; scanline table
scanlines
]addy = VRAM+$080000
		lup 600
		adrl ]addy
]addy = ]addy+800
		--^
;------------------------------------------------------------------------------
; Called with signed 16 bit sample data
UnPlotPlot mx %00

		asl
		asl
		asl
;		asl

		phb
		phy
		phx
		pha

		;inc <vis_jiffy
		;lda <vis_jiffy
		;and #1
		;bne :skip

		phk
		plb

		lda <vis_column
		tay
		asl
		tax
		lda |:history,x
		sta <vis_scanline
		lda |:history+2,x
		sta <vis_scanline+2

		; erase
		lda #0
		sta [vis_scanline],y

		lda 1,s
		xba
		cmp #$8000
		and #$FF
		rol
		cmp #$100
		bcc :ok2
		ora #$FF00
:ok2
		clc
		adc #300

		asl
		asl
		tax
		lda |scanlines,x
		sta <vis_scanline
		lda |scanlines+2,x
		sta <vis_scanline+2

		lda #$0101
		sta [vis_scanline],y

		lda <vis_column
		asl
		tax
		lda <vis_scanline
		sta |:history,x
		lda <vis_scanline+2
		sta |:history+2,x

		iny
		iny
		cpy #800
		bcc :ok
		ldy #0
:ok
		sty <vis_column

:skip
		pla
		plx
		ply
		plb
		rts

:history
		lup 400
		adrl VRAM+$080000
		--^

;------------------------------------------------------------------------------

