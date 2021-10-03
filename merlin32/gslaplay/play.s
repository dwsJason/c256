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
; 512k for my copy
;VICKY_OFFSCREEN_IMAGE = VICKY_DISPLAY_BUFFER+{XRES*YRES}
;VICKY_OFFSCREEN_IMAGE = $000001
;VICKY_WORK_BUFFER     = $180000


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


XRES = 320
YRES = 240

VIDEO_MODE = $024C


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

;------------------------------------------------------------------------------
;
;		jsr FadeToBorderColor
;
;------------------------------------------------------------------------------

		jsr		WaitVBL

		lda #VIDEO_MODE  		  	; 800x600 + Gamma + Bitmap_en
		sep #$30
		sta >MASTER_CTRL_REG_L
		xba
		sta >MASTER_CTRL_REG_H

		lda #BM_Enable+BM_LUT0
		sta >BM0_CONTROL_REG
		lda #BM_Enable+BM_LUT1
		sta >BM1_CONTROL_REG

		lda #<VICKY_DISPLAY_BUFFER
		sta >BM0_START_ADDY_L
		;dec
		sta >BM1_START_ADDY_L
		
		lda #>VICKY_DISPLAY_BUFFER
		sta >BM0_START_ADDY_M
		sta >BM1_START_ADDY_M
		lda #^VICKY_DISPLAY_BUFFER
		sta >BM0_START_ADDY_H
		sta >BM1_START_ADDY_H

		rep #$30
		mx %00

		lda #0
		sta >BM0_X_OFFSET
		sta >BM0_Y_OFFSET
		sta >BM1_X_OFFSET
		sta >BM1_Y_OFFSET

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

		jsr		WaitVBL

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
		mx %00

		do 1  ; comment out using .256 image
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

		jsr WaitVBL

;
; Disable the border
;

		sep #$30
		lda	#0
		sta >BORDER_CTRL_REG
		rep #$30
		mx %00
;-----------------------------------------------------------
;
; Copy the Pixels into Video Memory
		do 1
]count = 0
		lup 2
]source = pixel_buffer+{]count*$10000}
]dest   = {VICKY_DISPLAY_BUFFER+VRAM}+{]count*$10000}
		lda #0
		tax
		tay
		dec
		mvn ^]source,^]dest
]count = ]count+1
		--^

		phk
		plb
		else

PIXSIZE = {320*240}

		pea >SDMA_CTRL_REG0
		plb
		plb

		sep #$20

		; I'm only doing this, because it's the first time
		stz |SDMA_CTRL_REG0
		stz |VDMA_CONTROL_REG


		; activate SDMA circuit, before filling out the parms
		lda #SDMA_CTRL0_Enable+SDMA_CTRL0_SysRAM_Src
		sta |SDMA_CTRL_REG0

		; activate the VDMA circuit, before filling out the parms
		;lda #VDMA_CTRL_Enable+VDMA_CTRL_SysRAM_Src
		sta |VDMA_CONTROL_REG

		; source buffer pointer
		ldx #pixel_buffer
		stx |SDMA_SRC_ADDY_L
		lda #^pixel_buffer
		sta |SDMA_SRC_ADDY_H

		; Destination
		ldx #VICKY_DISPLAY_BUFFER
		stx |VDMA_DST_ADDY_L
		lda #^VICKY_DISPLAY_BUFFER
		sta |VDMA_DST_ADDY_H

		ldX #PIXSIZE
		stx |SDMA_SIZE_L
		stx |VDMA_SIZE_L
		ldx #^PIXSIZE
		stx |SDMA_SIZE_H		; Stef clears both bytes here
		stx |VDMA_SIZE_H

		; Sample code sets stride, but this seems redundant
		ldy #0
		sty |SDMA_SRC_STRIDE_L
		sty |VDMA_DST_STRIDE_L

		jsr WaitVBL

		; Start VDMA First (I guess it waits)
		lda #VDMA_CTRL_Start_TRF
		tsb |VDMA_CONTROL_REG
		;lda #SDMA_CTRL0_Start_TRF
		tsb |SDMA_CTRL_REG0

        NOP ; When the transfer is started the CPU will be put on Hold (RDYn)...
        NOP ; Before it actually gets to stop it will execute a couple more instructions
        NOP ; From that point on, the CPU is halted (keep that in mind) No IRQ will be processed either during that time
        NOP
        NOP


		; There is a DMA FIFO so, SDMA can finish before VDMA
]wait_dma
		lda |VDMA_STATUS_REG
		bmi ]wait_dma

		stz |SDMA_CTRL_REG0
		stz |VDMA_CONTROL_REG

		rep #$31

		phk
		plb
		fin

;--------------------------------------------------------

; Wait about 2 seconds
		lda #120
]wait
		jsr WaitVBL
		dec
		bpl ]wait
		fin
;------------------------------------------------------------------------------


:temp = 0

		lda #0
; Convert 16 color from GS format, to FMX
]lp     pha
		asl
		tax
		lda >rastan_c1+$7E00,x
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

;--------------------------------------------------------
;
; Convert the first 16 colors from the pal_buffer
; into grid of colors required to display GS pixel
; directly by the FMX Hardware
;

        ; Set Background Color
	sep #$30
        lda |pal_buffer
        sta >BACKGROUND_COLOR_B ; back
        lda |pal_buffer+1
        sta >BACKGROUND_COLOR_G ; back
        lda |pal_buffer+2
        sta  >BACKGROUND_COLOR_R ; back
	rep #$31
	mx %00

	; Upload the palette 16 times to LUT0
        ; Copy over the LUT
	lda #GRPH_LUT0_PTR
	sta <:temp

	lda #15 ; count
]ploop
	pha

        ;ldy     #GRPH_LUT0_PTR  ; dest
	ldy 	<:temp
        ldx     #pal_buffer  	; src
        lda     #64-1			; length
        mvn     ^pal_buffer,^GRPH_LUT0_PTR    ; src,dest

	lda <:temp
	adc #64   	; c=0
	sta <:temp

	pla
	dec
	bpl ]ploop


;--------------------------
; Upload each color in the palette, 16 times to LUT1
;
; horrible 8 bit version
;
;	pea >GRPH_LUT1_PTR
;	plb
;	plb 
;
;	ldx #0
;	ldy #0
;]boop
;	sep #$20
;	lda >pal_buffer,x
;]offset = 0
;	lup 16
;	sta |GRPH_LUT1_PTR+]offset,y
;]offset = ]offset+4
;	--^
;	lda >pal_buffer+1,x
;]offset = 0
;	lup 16
;	sta |GRPH_LUT1_PTR+]offset+1,y
;]offset = ]offset+4
;	--^
;	lda >pal_buffer+2,x
;]offset = 0
;	lup 16
;	sta |GRPH_LUT1_PTR+]offset+2,y
;]offset = ]offset+4
;	--^
;
;	rep #$31
;	txa
;	adc #4
;	tax
;	tya
;	adc #64
;	tay
;	cpx #64
;	bcs :bdone
;	jmp ]boop
;:bdone


;--------------------------
; this should work, but maybe 16 bit stores don't work to the LUT
;
;	phk
;	plb
;
;	; Upload each color in the palette, 16 times to LUT1
;
	pea >GRPH_LUT1_PTR
	plb
	plb 

	ldx #0
	ldy #0
	clc
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

	phk
	plb

;    pea >GRPH_LUT1_PTR
;	plb
;	plb 
;
;
;	ldx	#62
;]plp2
;	lda >pal_buffer,x
;	sta |GRPH_LUT1_PTR+{64*0},x
;	sta |GRPH_LUT1_PTR+{64*1},x
;	sta |GRPH_LUT1_PTR+{64*2},x
;	sta |GRPH_LUT1_PTR+{64*3},x
;	sta |GRPH_LUT1_PTR+{64*4},x
;	sta |GRPH_LUT1_PTR+{64*5},x
;	sta |GRPH_LUT1_PTR+{64*6},x
;	sta |GRPH_LUT1_PTR+{64*7},x
;	sta |GRPH_LUT1_PTR+{64*8},x
;	sta |GRPH_LUT1_PTR+{64*9},x
;	sta |GRPH_LUT1_PTR+{64*10},x
;	sta |GRPH_LUT1_PTR+{64*11},x
;	sta |GRPH_LUT1_PTR+{64*12},x
;	sta |GRPH_LUT1_PTR+{64*13},x
;	sta |GRPH_LUT1_PTR+{64*14},x
;	sta |GRPH_LUT1_PTR+{64*15},x
;	dex
;	dex
;	bpl ]plp2

	phk
	plb

;-------------------------------------------------------------

;        lda #0
;]wow
;	pha
;	jsr		WaitVBL
;	sep #$20
;	mx %10
;	ldx #0
;	lda 1,s
;]fill
;	sta >{VICKY_DISPLAY_BUFFER+VRAM},x
;	inx
;	bne ]fill
;	rep #$20
;	mx %00
;	pla
;	inc
;	bra ]wow


;-------------------------------------------------------------
; Zero out the buffer
	lda #0
	ldx #0
]lp3
	sta >{VICKY_DISPLAY_BUFFER+VRAM},x
	sta >{VICKY_DISPLAY_BUFFER+VRAM+$10000},x
	sta >{VICKY_DISPLAY_BUFFER+VRAM+$20000},x
	sta >{VICKY_DISPLAY_BUFFER+VRAM+$30000},x
	dex
	dex
	bne ]lp3

; non-dma test copy

	nop
	nop
;]boo	bra ]boo
	nop
	nop

	;pea {rastan_c1}/256  ;merlin32 is fucking this up
	;plb
	;plb

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

	else
;------------------------------------------------------------------------------

	do 0
	; TODO a macro that will pea the current bank, and the bank I want
	; to save plb, and phk instructions
	pea	{VDMA_CONTROL_REG}/256  ; this works fine with a constant, but not
								; with an ext address
	plb
	plb

	sep #$20
	; make sure not active
	stz |SDMA_CTRL_REG0
	stz |VDMA_CONTROL_REG

	; activate SDMA
	lda #SDMA_CTRL0_Enable+SDMA_CTRL0_1D_2D+SDMA_CTRL0_SysRAM_Src
	sta |SDMA_CTRL_REG0
	; activate VDMA
	lda #VDMA_CTRL_Enable+VDMA_CTRL_1D_2D+VDMA_CTRL_SysRAM_Src
	sta |VDMA_CONTROL_REG

	; Setup Source Address in RAM
	ldx #rastan_c1
	stx |SDMA_SRC_ADDY_L
	lda #^rastan_c1
	sta |SDMA_SRC_ADDY_H

	; Setup Dest Address in VRAM
	ldx #VICKY_DISPLAY_BUFFER
	stx |VDMA_DST_ADDY_L
	lda #^VICKY_DISPLAY_BUFFER
	sta |VDMA_DST_ADDY_H

	; Setup Source Size
	ldx #128
	stx |SDMA_X_SIZE_L
	ldy #200
	sty |SDMA_Y_SIZE_L

	; Source Stride in bytes
	ldx #160
	stx |SDMA_SRC_STRIDE_L

	; Setup Destination Size
	ldx #1
	stx |VDMA_X_SIZE_L
	ldy #200*128
	sty |VDMA_Y_SIZE_L

	ldx #2
	stx |VDMA_DST_STRIDE_L

;	jsr WaitVBL

	; Start VDMA First (I guess it waits)
	lda #VDMA_CTRL_Start_TRF
	tsb |VDMA_CONTROL_REG
	lda #SDMA_CTRL0_Start_TRF
	tsb |SDMA_CTRL_REG0

    NOP ; When the transfer is started the CPU will be put on Hold (RDYn)...
    NOP ; Before it actually gets to stop it will execute a couple more instructions
    NOP ; From that point on, the CPU is halted (keep that in mind) No IRQ will be processed either during that time
    NOP
    NOP

		; There is a DMA FIFO so, SDMA can finish before VDMA
]wait_dma
	lda |VDMA_STATUS_REG
	bmi ]wait_dma

	stz |SDMA_CTRL_REG0
	stz |VDMA_CONTROL_REG

	rep #$31

	phk
	plb

	else
;----------------------------------------------------------------------

burn
	; TODO a macro that will pea the current bank, and the bank I want
	; to save plb, and phk instructions
	pea	{VDMA_CONTROL_REG}/256  ; this works fine with a constant, but not
								; with an ext address
	plb
	plb

]src = 0
]dst = 4
]count = 8

]lines = 10
]chunk_size = 128*]lines

	lda #rastan_c1
	sta <]src
	lda #^rastan_c1
	sta <]src+2
	lda #VICKY_DISPLAY_BUFFER
	sta <]dst
	lda #^VICKY_DISPLAY_BUFFER
	sta <]dst+2

	stz <]count

]looper

	sep #$20   															; 3
	; make sure not active  											
	stz |SDMA_CTRL_REG0 												; 4
	stz |VDMA_CONTROL_REG   											; 4

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
	ldx #128															; 3
	stx |SDMA_X_SIZE_L  												; 5
	ldy #]lines 														; 3
	sty |SDMA_Y_SIZE_L  												; 5
	;ldx #128
	;stx |SDMA_SIZE_L
	;ldx #0
	;stx |SDMA_SIZE_H

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
;	ldx #0
;	stx |VDMA_SRC_STRIDE_L

	;jsr WaitVBL

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

;	jsr WaitVBL

	rep #$31															 ; 3

	lda <]count 														 ; 4
	inc 																 ; 2
	cmp #200/]lines 													 ; 3
	bcs :donedaddy  													 ; 2/3 (B or NB)
	sta <]count 														 ; 4

	lda <]src   														 ; 4
	adc	#160*]lines 													 ; 3
	sta <]src   														 ; 4

	lda <]dst   														 ; 4
	adc #256*]lines 													 ; 3
	sta <]dst   														 ; 4

	jmp ]looper 														 ; 3    (about 155+32 clocks to move the data) 187 clocks vs the 256 clocks to use the CPU (still a win)
																		 ; especially since this number will be magnified 200x


:donedaddy

	; Another Loop for the 32 bytes (64 pixels) that we didn't transfer above


	do 1

]lines = 1
]chunk_size = 32*]lines

	lda #rastan_c1+128
	sta <]src
	lda #^rastan_c1
	sta <]src+2
	lda #VICKY_DISPLAY_BUFFER+$10000
	sta <]dst
	lda #^{VICKY_DISPLAY_BUFFER+$10000}
	sta <]dst+2

	stz <]count

]looper

	sep #$20   															; 3
	; make sure not active  											
	stz |SDMA_CTRL_REG0 												; 4
	stz |VDMA_CONTROL_REG   											; 4

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
	;ldx #128
	;stx |SDMA_SIZE_L
	;ldx #0
	;stx |SDMA_SIZE_H

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
;	ldx #0
;	stx |VDMA_SRC_STRIDE_L

	;jsr WaitVBL

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

;	jsr WaitVBL

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

	fin


	phk
	plb

	fin

	fin

;------------------------------------------------------------------------------


	phk
	plb

	;rep #$31
	mx %00
;------------------------------------------------------------------------------
; configure the display system to make use the tilemap system

	lda #$254 ; 320x240, tilemap engine
	sep #$30
	mx %11
	sta >MASTER_CTRL_REG_L
	xba
	sta >MASTER_CTRL_REG_H

	lda #TILE_Enable
	sta >TL0_CONTROL_REG
	sta >TL1_CONTROL_REG
	lda #0
	sta >TL2_CONTROL_REG
	sta >TL3_CONTROL_REG

	lda #32
	sta >TL0_TOTAL_X_SIZE_L
	sta >TL1_TOTAL_X_SIZE_L
	lda #0
	sta >TL0_TOTAL_X_SIZE_H
	sta >TL1_TOTAL_X_SIZE_H

	lda #16
	sta >TL0_TOTAL_Y_SIZE_L
	sta >TL1_TOTAL_Y_SIZE_L
	lda #0
	sta >TL0_TOTAL_Y_SIZE_H
	sta >TL1_TOTAL_Y_SIZE_H

	sta >TL0_WINDOW_X_POS_L
	sta >TL0_WINDOW_X_POS_H
	sta >TL0_WINDOW_Y_POS_L
	sta >TL0_WINDOW_Y_POS_H
	sta >TL1_WINDOW_X_POS_L
	sta >TL1_WINDOW_X_POS_H
	sta >TL1_WINDOW_Y_POS_L
	sta >TL1_WINDOW_Y_POS_H

	lda #0

	sta >TL0_START_ADDY_L
	sta >TL0_START_ADDY_M
	sta >TL1_START_ADDY_L
	sta >TL1_START_ADDY_M

	sta >TILESET0_ADDY_L
	sta >TILESET0_ADDY_M
	sta >TILESET0_ADDY_H

	sta >TILESET1_ADDY_L
	sta >TILESET1_ADDY_M
	lda #1
	sta >TILESET1_ADDY_H

	;lda #$40
	;sta >TL1_WINDOW_X_POS_H
	lda #16
	sta >TL1_WINDOW_X_POS_L
	lda #15
	sta >TL0_WINDOW_X_POS_L

	; center the 320x200 bitmap
	lda #12
	sta >TL0_WINDOW_Y_POS_L
	sta >TL1_WINDOW_Y_POS_L
	;lda #12*2
	;sta >TL0_WINDOW_Y_POS_H
	;sta >TL1_WINDOW_Y_POS_H


	lda #8
	sta >TILESET0_ADDY_CFG
	sta >TILESET1_ADDY_CFG

	lda #2
	sta >TL0_START_ADDY_H
	inc
	sta >TL1_START_ADDY_H

	; Border thing? Hide Garbage pixels
	lda #Border_Ctrl_Enable
	sta >BORDER_CTRL_REG
	lda #64
	sta >BORDER_COLOR_B
	lda #0
	sta >BORDER_COLOR_G
	sta >BORDER_COLOR_R
	sta >BORDER_X_SIZE
	lda #20
	sta >BORDER_Y_SIZE

	rep #$30
	mx %00

	phk
	plb

; Copy map data to VRAM

	ldx #0
]lp
	lda |map_data,x
	sta >VICKY_DISPLAY_BUFFER+VRAM+$20000+{64*2}+4,x
	ora #$800
	sta >VICKY_DISPLAY_BUFFER+VRAM+$30000+{64*2}+4,x
	inx
	inx
	cpx #32*13*2
	bcc ]lp

;	jmp burn

;------------------------------------------------------------------------------
;
:stop   bra :stop


		sep #$30
		mx %11
		ldx #TILE_Enable
		ldy #0
]loop
		jsr		WaitVBL
		txa
		sta >TL0_CONTROL_REG
		sta >TL1_CONTROL_REG

		jsr		WaitVBL
		tya
		sta >TL0_CONTROL_REG

		jsr		WaitVBL
		sta >TL1_CONTROL_REG
		txa
		sta >TL0_CONTROL_REG
		jmp 	]loop

		rep #$30
		mx %00
:stop   bra :stop


map_data
]var = 0
	lup 13
	dw $000+]var,$001+]var,$002+]var,$003+]var,$004+]var,$005+]var,$006+]var,$007+]var
	dw $008+]var,$009+]var,$00A+]var,$00B+]var,$00C+]var,$00D+]var,$00E+]var,$00F+]var
	dw $100+]var,$101+]var,$102+]var,$103+]var,0,0,0,0
	dw 0,0,0,0,0,0,0,0
]var = ]var+16
	--^

;---------------------------------
;
; Input GS Color 0x0BGR output 0x00RRGGBB
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

