;
; C256 FMX Bitmap Example in Merlin32
;
; $00:2000 - $00:7FFF are free for application use.
;
        rel     ; relocatable
        lnk     Main.l

        use Util.Macs

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


		ext rastan_c1
		ext title_pic
		ext decompress_lzsa
		ext movie_data


        mx %00

;
; Decompress to this address
;
pixel_buffer = $180000	; need a little over 64K, put it in memory at 1.5MB
						; avoid stomping kernel on the U

VICKY_DISPLAY_BUFFER  = $000000

; Kernel method
VRAM = $B00000

;------------------------------------------------------------------------------
; I like having my own Direct Page
MyDP  = $A000
MySTACK = $EFFF

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

dpJiffy       = 128


;----------------------------------------------------------------

		ext C1InitVideo
		ext C1BlitPixels
		ext C1BlitPalettes


start   ent             ; make sure start is visible outside the file
        clc
        xce
        rep $31         ; long MX, and CLC

; Default Stack is on top of System Multiply Registers
; So move the stack before proceeding

        lda #MySTACK
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

;		jsr	WaitVBL

		jsl C1InitVideo

; Copy in the demo C1

		lda #$7FFF
		ldx #rastan_c1
		ldy #$2000
		mvn ^rastan_c1,^$002000
		phk
		plb

		jsl C1BlitPalettes

:display_loop

		jsl C1BlitPixels

		bra :display_loop


;-----------------------------------------------------------
;
; Copy the Pixels into Video Memory
;		do 0
;]count = 0
;		lup 2
;]source = pixel_buffer+{]count*$10000}
;]dest   = {VICKY_DISPLAY_BUFFER+VRAM}+{]count*$10000}
;		lda #0
;		tax
;		tay
;		dec
;		mvn ^]source,^]dest
;]count = ]count+1
;		--^
;
;		phk
;		plb
;		else
;
;PIXSIZE = {320*240}
;
;		pea >SDMA_CTRL_REG0
;		plb
;		plb
;
;		sep #$20
;
;		; I'm only doing this, because it's the first time
;		stz |SDMA_CTRL_REG0
;		stz |VDMA_CONTROL_REG
;
;
;		; activate SDMA circuit, before filling out the parms
;		lda #SDMA_CTRL0_Enable+SDMA_CTRL0_SysRAM_Src
;		sta |SDMA_CTRL_REG0
;
;		; activate the VDMA circuit, before filling out the parms
;		;lda #VDMA_CTRL_Enable+VDMA_CTRL_SysRAM_Src
;		sta |VDMA_CONTROL_REG
;
;		; source buffer pointer
;		ldx #pixel_buffer
;		stx |SDMA_SRC_ADDY_L
;		lda #^pixel_buffer
;		sta |SDMA_SRC_ADDY_H
;
;		; Destination
;		ldx #VICKY_DISPLAY_BUFFER
;		stx |VDMA_DST_ADDY_L
;		lda #^VICKY_DISPLAY_BUFFER
;		sta |VDMA_DST_ADDY_H
;
;		ldX #PIXSIZE
;		stx |SDMA_SIZE_L
;		stx |VDMA_SIZE_L
;		ldx #^PIXSIZE
;		stx |SDMA_SIZE_H		; Stef clears both bytes here
;		stx |VDMA_SIZE_H
;
;		; Sample code sets stride, but this seems redundant
;		ldy #0
;		sty |SDMA_SRC_STRIDE_L
;		sty |VDMA_DST_STRIDE_L
;
;		jsr WaitVBL
;
;		; Start VDMA First (I guess it waits)
;		lda #VDMA_CTRL_Start_TRF
;		tsb |VDMA_CONTROL_REG
;		;lda #SDMA_CTRL0_Start_TRF
;		tsb |SDMA_CTRL_REG0
;
;        NOP ; When the transfer is started the CPU will be put on Hold (RDYn)...
;        NOP ; Before it actually gets to stop it will execute a couple more instructions
;        NOP ; From that point on, the CPU is halted (keep that in mind) No IRQ will be processed either during that time
;        NOP
;        NOP
;
;
;		; There is a DMA FIFO so, SDMA can finish before VDMA
;]wait_dma
;		lda |VDMA_STATUS_REG
;		bmi ]wait_dma
;
;		stz |SDMA_CTRL_REG0
;		stz |VDMA_CONTROL_REG
;
;		rep #$31
;
;		phk
;		plb
;		fin

;--------------------------------------------------------

;; Wait about 2 seconds
;		lda #120
;]wait
;		jsr WaitVBL
;		dec
;		bpl ]wait
;------------------------------------------------------------------------------

;  Setup for using the bitmap buffers
;  Since bitmap buffers offset X doesn't
;  work, and bitmap buffers cannot start on an odd
;  address, this does not work
;	sep #$20
;
;	lda #^rastan_c1
;	pha
;	plb
;
;	mx %10
;	ldy #0
;	tyx
;]lp4   	lda |rastan_c1,y
;	sta >{VICKY_DISPLAY_BUFFER+VRAM+1},x
;	iny
;	inx
;	inx
;	cpy #{160*200}
;	bcc ]lp4

;	rep #$30
;	mx %00

;	phk
;	plb

;------------------------------------------------------------------------------
;
;   Convert the 160x200 byte GS Buffer, into 128x200 tiles
;
	do 0    ; CPU COPY
	pea >rastan_c1
	plb
	plb


	ldy #rastan_c1
	ldx #0
	pea #199
]lp
	sep #$20
	mx %10
]src = 0
]dst = VICKY_DISPLAY_BUFFER+VRAM
	lup 128
	lda |]src,y
	sta >]dst,x
]src = ]src+1
]dst = ]dst+2
	--^
	rep #$31
	mx %00
	pla
	dec
	bmi :done
	pha
	tya
	adc #160
	tay
	txa
	adc #256
	tax
	sep #$20
	jmp ]lp
:done
	mx %00
	ldy #rastan_c1+128
	ldx #0
	pea #199
]lp
	sep #$20
	mx %10
]src = 0
]dst = VICKY_DISPLAY_BUFFER+VRAM+$10000
	lup 32
	lda |]src,y
	sta >]dst,x
]src = ]src+1
]dst = ]dst+2
	--^
	rep #$31
	mx %00
	pla
	dec
	bmi :done2
	pha
	tya
	adc #160
	tay
	txa
	adc #256
	tax
	sep #$20
	jmp ]lp
	mx %00
:done2

	fin
;------------------------------------------------------------------------------

	phk
	plb

	rep #$31
	mx %00

;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
;
:stop   bra :stop

;-------------------------------------------------------------------------------
; Kick2DVDMA
;
; PushL Source VRAM Address
; PushL Dest VRAM Address
; PushW width  in Pixels
; PushW Height in Pixels
;
; PushW Source Stride, in pixels
; PushW Dest Stride
;
; jsr Kick2DVDMA
;
Kick2DVDMA mx %00

; 1,s is the return address-1

]dest_stride   = 3
]source_stride = 5
]height_pixels = 7
]width_pixels  = 9
]dest_addr     = 11
]src_addr      = 15

		; Switch into the VDMA Bank
		pea	{VDMA_CONTROL_REG}/256
		plb
		plb

		do 1
		lda ]src_addr,s
		sta |VDMA_SRC_ADDY_L
		lda ]src_addr+1,s
		sta |VDMA_SRC_ADDY_L+1

		lda ]dest_addr,s
		sta |VDMA_DST_ADDY_L
		lda ]dest_addr+1,s
		sta |VDMA_DST_ADDY_L+1

		lda ]width_pixels,s
		sta |VDMA_X_SIZE_L
		lda ]height_pixels,s
		sta |VDMA_Y_SIZE_L

		lda ]source_stride,s
		sta |VDMA_SRC_STRIDE_L
		lda ]dest_stride,s
		sta |VDMA_DST_STRIDE_L
		sep #$20

		else
		sep #$20
		lda ]src_addr,s
		sta |VDMA_SRC_ADDY_L
		lda ]src_addr+1,s
		sta |VDMA_SRC_ADDY_L+1
		lda ]src-addr+2.s
		sta |VDMA_SRC_ADDY_L+2

		lda ]dest_addr,s
		sta |VDMA_DST_ADDY_L
		lda ]dest_addr+1,s
		sta |VDMA_DST_ADDY_L+1
		lda ]dest_addr+2,s
		sta |VDMA_DST_ADDY_L+2

		lda ]width_pixels,s
		sta |VDMA_X_SIZE_L
		lda ]width_pixels+1,s
		sta |VDMA_X_SIZE_L+1
		 
		lda ]height_pixels,s
		sta |VDMA_Y_SIZE_L
		lda ]height_pixels+1,s
		sta ]VDMA_Y_SIZE_L+1

		lda ]source_stride,s
		sta |VDMA_SRC_STRIDE_L
		lda ]source_stride+1,s
		sta ]VDMA_SRC_STRIDE_L+1

		lda ]dest_stride,s
		sta |VDMA_DST_STRIDE_L
		lda ]dest_stride+1,s
		sta |VDMA_DST_STRIDE_L+1
		fin

		stz |VDMA_CONTROL_REG  ; Clear the TRF

		; Begin 2D DMA
		lda #VDMA_CTRL_Enable+VDMA_CTRL_1D_2D+VDMA_CTRL_Start_TRF
		sta |VDMA_CONTROL_REG

		;rep #$31	; mxc=000

		; Wait for Completion
]wait_dma
		lda |VDMA_STATUS_REG
		bmi	]wait_dma

		rep #$31	; mxc=000

		; fix up stack
		lda 1,s
		sta 17,s

		tsc
		adc #16
		tcs

		; Back to our program bank
		phk
		plb
		rts


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
		phb
		phk
		plb
		inc |{MyDP+dpJiffy}
		plb
		rtl


;; Maintain Vector
;;		sei
;;
;;; Only install, if not already installed
;;		lda	|VEC_INT00_SOF+1
;;
;;		cmp #:JiffyTimer
;;		bne :onward
;;
;;		lda |VEC_INT00_SOF+2
;;		cmp #>:JiffyTimer
;;		beq :already_installed
;;
;;
;;:onward
;;		lda	|VEC_INT00_SOF
;;		sta |:hook
;;		lda |VEC_INT00_SOF+2
;;		sta |:hook+2
;;		
;;		lda #:JiffyTimer
;;		sta |VEC_INT00_SOF+1
;;		lda #>:JiffyTimer
;;		sta |VEC_INT00_SOF+2
;;
;;:already_installed
;;
;;; Make sure the JiffyTime is running
;;
;;; Enable the SOF interrupt
;;
;;		lda	#FNX0_INT00_SOF
;;		trb |INT_MASK_REG0
;;
;;		cli
;;		rts
;;
;;:JiffyTimer
;;		phb
;;		phk
;;		plb
;;		inc |{MyDP+dpJiffy}
;;		plb
;;:hook
;;		jml $000000


;------------------------------------------------------------------------------
; WaitVBL
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

