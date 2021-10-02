;
; 16-bit 24Khz Stereo Mixer
; Double Shot (store out each result 2x)
;
; I can only guess VBlank is larger in 640 mode
;
; In 640 mode, I can move this many bytes in VRAM during VBLank
; 59*640 = 44160

; In 800 mode
; (27*800) = 21600
;


		use phx/Math_def.asm

		ext dma_table
		ext step_table

FIFO_CAPACITY equ 1024

;
;  Oscillator Definition
;
		dum 0
OSC_ENABLE 		 ds 2
OSC_PLAY_RATE    ds 2   ; 1.0 (0x00.00) is 24Khz (0x02.00) is 12Khz, 3.0=8Khz
OSC_VOLUME_LEFT  ds 2
OSC_VOLUME_RIGHT ds 2
OSC_SAMPLER_ADDR ds 4	; pointer Current Sampling Address
OSC_SAMPLER_END  ds 4   ; ending address of the sample
OSC_SAMPLER_LOOP ds 4	; pointer to loop address (0 if no loop)
OSC_LAST_SAMPLE  ds 2	; last sample read, needed to ramp on disable
OSC_LEFT_FIFO    ds 2   ; Left FIFO Address
OSC_RIGHT_FIFO   ds 2   ; Right FIFO Address

sizeof_OSC				; how many bytes in an oscillator
		dend

;
; Real Time Volume Tables
; 512 bytes at the start of thes following banks
; A Separate Bank for Each Channel
;

Channel0Left  equ $10000
Channel0Right equ $20000

Channel1Left  equ $30000
Channel1Right equ $40000

Channel2Left  equ $50000
Channel2Right equ $60000

Channel3Left  equ $70000
Channel3Right equ $80000

MIXFIFO equ    $020200  ; 1024 entry executable FIFO
VOL_TABLES equ $030200  ; 64 Volume tables (256 entries each)

;------------------------------------------------------------------------------
; Mixer / Oscillator Variables
;
; Give the Mixer it's own Direct Page, why not?

; this works, but I really don't like it
MIXER_RAM ds 511
MIXER_DIRECT_PAGE = {MIXER_RAM+255}&{$FF00}


		dw MIXER_DIRECT_PAGE

		dum 0

mixer_temp0 ds 4
mixer_temp1 ds 4
mixer_temp2 ds 4
mixer_temp3 ds 4
mixer_temp4 ds 4
mixer_temp5 ds 4
mixer_temp6 ds 4
mixer_temp7 ds 4

fifo_head  ds 2     ; insert data here
fifo_tail  ds 2		; execute / pump data here
fifo_count ds 2 	; how much data is loaded

vol0_left   ds 2		; currently loaded volume, channel 0, left
vol0_right  ds 2		; currently loaded volume, channel 0, right

vol1_left   ds 2		; currently loaded volume, channel 1, left
vol1_right  ds 2		; currently loaded volume, channel 1, right

vol2_left   ds 2		; currently loaded volume, channel 2, left
vol2_right  ds 2		; currently loaded volume, channel 2, right

vol3_left   ds 2		; currently loaded volume, channel 3, left
vol3_right  ds 2		; currently loaded volume, channel 3, right

OSC0			  ds 0
OSC0_ENABLE 	  ds 2
OSC0_PLAY_RATE    ds 2   ; 1.0 (0x00.00) is 24Khz (0x02.00) is 12Khz 
OSC0_VOLUME_LEFT  ds 2
OSC0_VOLUME_RIGHT ds 2
OSC0_SAMPLER_ADDR ds 4	; pointer Current Sampling Address
OSC0_SAMPLER_END  ds 4   ; ending address of the sample
OSC0_SAMPLER_LOOP ds 4	; pointer to loop address (0 if no loop)
OSC0_LAST_SAMPLE  ds 2	; last sample read, needed to ramp on disable
OSC0_LEFT_FIFO	  ds 2
OSC0_RIGHT_FIFO   ds 2

OSC1			  ds 0
OSC1_ENABLE 	  ds 2
OSC1_PLAY_RATE    ds 2   ; 1.0 (0x00.00) is 24Khz (0x02.00) is 12Khz 
OSC1_VOLUME_LEFT  ds 2
OSC1_VOLUME_RIGHT ds 2
OSC1_SAMPLER_ADDR ds 4	; pointer Current Sampling Address
OSC1_SAMPLER_END  ds 4   ; ending address of the sample
OSC1_SAMPLER_LOOP ds 4	; pointer to loop address (0 if no loop)
OSC1_LAST_SAMPLE  ds 2	; last sample read, needed to ramp on disable
OSC1_LEFT_FIFO	  ds 2
OSC1_RIGHT_FIFO   ds 2

OSC2			  ds 0
OSC2_ENABLE 	  ds 2
OSC2_PLAY_RATE    ds 2   ; 1.0 (0x00.00) is 24Khz (0x02.00) is 12Khz 
OSC2_VOLUME_LEFT  ds 2
OSC2_VOLUME_RIGHT ds 2
OSC2_SAMPLER_ADDR ds 4	; pointer Current Sampling Address
OSC2_SAMPLER_END  ds 4   ; ending address of the sample
OSC2_SAMPLER_LOOP ds 4	; pointer to loop address (0 if no loop)
OSC2_LAST_SAMPLE  ds 2	; last sample read, needed to ramp on disable
OSC2_LEFT_FIFO	  ds 2
OSC2_RIGHT_FIFO   ds 2

OSC3			  ds 0
OSC3_ENABLE 	  ds 2
OSC3_PLAY_RATE    ds 2   ; 1.0 (0x01.00) is 24Khz (0x02.00) is 12Khz
OSC3_VOLUME_LEFT  ds 2
OSC3_VOLUME_RIGHT ds 2
OSC3_SAMPLER_ADDR ds 4	; pointer Current Sampling Address
OSC3_SAMPLER_END  ds 4   ; ending address of the sample
OSC3_SAMPLER_LOOP ds 4	; pointer to loop address (0 if no loop)
OSC3_LAST_SAMPLE  ds 2	; last sample read, needed to ramp on disable
OSC3_LEFT_FIFO	  ds 2
OSC3_RIGHT_FIFO   ds 2

sizeof_MIXER_VARS
		dend

		 ERR    {sizeof_MIXER_VARS-1}/256      ; Error if Mixer using too many vars


MIXFIFO24_start mx %00

;	lup 1024

	lda >Channel0Left  ;6        4
	adc >Channel1Left  ;6        4
	adc >Channel2Left  ;6        4
	adc >Channel3Left  ;6        4     ;16
	tax 			   ;2        1     ;17

	lda >Channel0Right ;6        4
	adc >Channel1Right ;6        4
	adc >Channel2Right ;6        4
	adc >Channel3Right ;6        4     ;33

	stx |$1908  	   ;5  Left  3     ;36
	sta |$1908         ;5  Right 3     ;39
	stx |$1908  	   ;5  Left  3     ;42
	sta >$AF1908       ;6  Right 4     ;46 (long to even out the byte count for DMA)

;	^--

MIXFIFO24_end

CH0_OFFSET_LEFT  equ 1
CH0_OFFSET_RIGHT equ 19
CH1_OFFSET_LEFT  equ 5
CH1_OFFSET_RIGHT equ 23
CH2_OFFSET_LEFT  equ 9
CH2_OFFSET_RIGHT equ 27
CH3_OFFSET_LEFT  equ 13
CH3_OFFSET_RIGHT equ 31

; The index into the fifo block per channel, for setting the address
; of DMA Transfers
ChannelOffsetLeft
	dw	CH0_OFFSET_LEFT,CH1_OFFSET_LEFT,CH2_OFFSET_LEFT,CH3_OFFSET_LEFT
ChannelOffsetRight
	dw	CH0_OFFSET_RIGHT,CH1_OFFSET_RIGHT,CH2_OFFSET_RIGHT,CH3_OFFSET_RIGHT

; The offsets to each entry in the FIFO

FIFO_OFFSETS
;]FRAG_SIZE = {MIXFIFO24_end-MIXFIFO24_start} ; sometimes Merlin sucks
]FRAG_SIZE = 46

]offset = MIXFIFO
	lup FIFO_CAPACITY
	dw ]offset
]offset = ]offset+]FRAG_SIZE
	--^


;------------------------------------------------------------------------------
;
; Generate the executable FIFO
; Generate volume tables
; Initialize Mixer Volumes
; Initialize Audio Registers
;
MIXER_INIT ent
	phb

	phk
	plb

	phd
	lda #MIXER_DIRECT_PAGE
	tcd

	jsr GenerateFIFO
	jsr GenerateVolumes

; -- Force Volumes to Initialize

	lda #$ffff  		; this sets cached volume tables to impossible values
	sta <vol0_left  	; so the first time oscillators are updated, this will
	sta <vol0_right		; force fresh volume translation tables to be installed
	sta <vol1_left		
	sta <vol1_right
	sta <vol2_left
	sta <vol2_right
	sta <vol3_left
	sta <vol3_right

	; Important Constants used when DMA into FIFO
	; The address offset from the base address, to where the value is stored
	lda #CH0_OFFSET_LEFT
	sta <OSC0_LEFT_FIFO
	lda #CH0_OFFSET_RIGHT
	sta <OSC0_RIGHT_FIFO

	lda #CH1_OFFSET_LEFT
	sta <OSC1_LEFT_FIFO
	lda #CH1_OFFSET_RIGHT
	sta <OSC1_RIGHT_FIFO

	lda #CH2_OFFSET_LEFT
	sta <OSC2_LEFT_FIFO
	lda #CH2_OFFSET_RIGHT
	sta <OSC2_RIGHT_FIFO

	lda #CH3_OFFSET_LEFT
	sta <OSC3_LEFT_FIFO
	lda #CH3_OFFSET_RIGHT
	sta <OSC3_RIGHT_FIFO

	pld
	plb
	rtl

;------------------------------------------------------------------------------
;
; Call this to pump the fifo
;
;  1. Fill empty space in our FIFO up with data
;  2. Dump as much of that data as we can, into the HW FIFO
;
MIXER_PUMP ent
	mx %00

	phb

	phk  			; b in this bank for local variables
	plb

	phd 			; try to keep mixer variables stuck in our own DP
	lda #MIXER_DIRECT_PAGE
	tcd		

	jsr MIXER_OSC	; top of software FIFO

	jsr MIXER_FIFO  ; move as much data as possible into the HW FIFO

	pld
	plb

	rtl

;------------------------------------------------------------------------------
;
; Call this to run the Virtual Oscillators
;
MIXER_OSC mx %00

]lp
	sec
	lda #FIFO_CAPACITY	; max room in the mix
	sbc <fifo_count
	cmp #256
	bcc :skip		; there's not enough room to bring in 256 samples

	; Run Each Oscillator
	; Inject 256 samples at the fifo_head

	ldx #OSC0
	jsr MIXER_RUN_OSC  ; run an OSCILLATOR

	ldx #OSC1
	jsr MIXER_RUN_OSC  ; run an OSCILLATOR

	ldx #OSC2
	jsr MIXER_RUN_OSC  ; run an OSCILLATOR

	ldx #OSC3
	jsr MIXER_RUN_OSC  ; run an OSCILLATOR

	clc
	lda <fifo_head     ; move the FIFO head
	adc #256
	and #FIFO_CAPACITY-1
	sta <fifo_head
	; c = 0
	lda <fifo_count	   ; adjust the FIFO count
	adc #256
	sta <fifo_count

	bra ]lp

:skip
	; update volumes here? maybe better if placed in MIXER_FIFO

	rts

;------------------------------------------------------------------------------
;
; X is pointer to the OSC
;
MIXER_RUN_OSC mx %00

:source_step = mixer_temp0
:new_sample_pointer = mixer_temp1
:pScale = mixer_temp2   		   ; pointer to the scale commands
:count  = mixer_temp3
:y      = mixer_temp3+2
:pDesti = mixer_temp4
:stride = mixer_temp5

	lda <OSC_ENABLE,x
	beq :disabled

	lda <OSC_PLAY_RATE,x
	asl
	adc #step_table-2  	; c=0
	sta |:st+1

:st	lda >step_table 	; self-modified code
	asl
	sta <:source_step	; this is how many bytes the pointer needs to move
						; on the oscillator

	; c=0
	adc <OSC_SAMPLER_ADDR,x
	sta <:new_sample_pointer
	lda #0
	adc <OSC_SAMPLER_ADDR+2,x
	sta <:new_sample_pointer+2

	; new sample pointer is the candidate target
	; as long as it's less than OSC_SAMPLER_END, we're good for simple case

	cmp <OSC_SAMPLER_END+2,x
	bcc :not_end
	bne :past_end

:test_low
	lda <:new_sample_pointer
	cmp <OSC_SAMPLER_ADDR
	bcc :not_end

:past_end
	; We get here, after sampling this frame, we're going to be past the
	; end of our sample, so it needs to end, or it needs to loop
	; in either case, we have a short-fall of samples, so we need to figure
	; out how many samples will be good, based on the data that's available


:not_end

	; The easy case
	jsr	:resample

;        // How many source samples are we going to traverse?
;        if ((srcSamples + CurrentSample Pointer) < Sample End Pointer)
;        {
;           // Easy Case, get the Samples
;           // Adjust SrcPointer
;           // Store Last Sample into the Last Sample Read Register
;        }
;        else
;        {
;           if (Sample Loop Pointer)
;           {
;                //Looping
;                // Read all the Remaining samples, up to the Sample End Pointer
;                // Adjust Sample Pointer to Loop Start
;                // Adjust Samples Required (down from 256 to whatever is remaining)
;                // goto loop:
;           }
;           else
;           {
;                // not looping
;                // Read all the remaining samples, up to the Sample End Pointer
;                // for whatever is remaining, just duplicate the last sample
;                // enough times to fill out 256 samples
;           }
;        }

;
; When disabled fill with a constant, but with each fill, move 50%
; closer to 0 (eventually hit 0), this might help with clicks, will have to
; listen to see if its "good enough"
;
:disabled

	lda <OSC_LAST_SAMPLE,x
	beq :constant_fill

	cmp #256  ; because this is an index into a table
	bcs :negative

	; positive, so easy
	lsr
	and #!1					; keep lsb clear, index even
	sta <OSC_LAST_SAMPLE,x
	bra :constant_fill

:negative

	ora #$FF00
	sec
	ror
	and #%1_1111_1110    ; keep index even
	sta <OSC_LAST_SAMPLE,x

	cmp #510		 	 ; take -1 to 0
	bne :constant_fill
	lda #0
	sta <OSC_LAST_SAMPLE,x

:constant_fill

	; use 2D DMA here, with a constant fill, to get 256 samples
	; placed into the FIFO, place them at the fifo_head

	; just inline here, because lazy

	; Switch into SDMA Register Bank
	pea SDMA_CTRL_REG0/256
	plb
	plb

	; Fill the Left Channel
	jsr :dma_fill  		; fill the low byte

	lda <OSC_LAST_SAMPLE+1,x

	inc <FIFO_OFFSETS,x
	jsr :dma_fill     	; fill the high byte
	dec <FIFO_OFFSETS,x

	; Now the right channel
	inx
	inx
	lda <OSC_LAST_SAMPLE-2,x
	jsr :dma_fill	 	; low byte right

	lda <OSC_LAST_SAMPLE-2+1,x
	inc <FIFO_OFFSETS-2,x
	jsr :dma_fill
	dex
	dex
	dec <FIFO_OFFSETS,x

	phk
	plb

	rts


:dma_fill mx %00
	sta |SDMA_BYTE_2_WRITE

FRAG_SIZE = {MIXFIFO24_end-MIXFIFO24_start}

	lda #FRAG_SIZE
	sta |SDMA_DST_STRIDE_L

	lda <fifo_head
	asl
	txy
	tax
	lda >FIFO_OFFSETS,x
	tyx
	adc <OSC_LEFT_FIFO,x

	sta |SDMA_DST_ADDY_L
	lda #^MIXFIFO
	sta |SDMA_DST_ADDY_H

	lda #1
	sta |SDMA_X_SIZE_L
	lda #256
	sta |SDMA_Y_SIZE_L

	lda #]FRAG_SIZE
	sta |SDMA_DST_STRIDE_L

	sep #$20
	stz |SDMA_CTRL_REG0

	lda #SDMA_CTRL0_Enable+SDMA_CTRL0_1D_2D+SDMA_CTRL0_TRF_Fill+SDMA_CTRL0_Start_TRF
	sta |SDMA_CTRL_REG0

	rep #$31 ; mxc = 0

	rts

;------------------------------------------------------------------------------

:resample mx %00

	; Maybe we can refactor this, so that it's fetched when the PLAY_RATE
	; is set, instead of every call

	lda <OSC_PLAY_RATE,x
	txy
	asl
	tax
	lda >dma_table-2,x
	sta <:pScale
	tyx
	lda #^dma_table
	sta <:pScale+2
	; :pScale

	lda [:pScale]
	beq :no_scale

	jsr :scaleUpCopy

:no_scale

	rts

;------------------------------------------------------------------------------
:scaleUpCopy mx %00
	tay
	and #$ff
	sta <:count		; multiply count
	asl
	sta <:stride	; bytes stride for the amplification
	tya
	xba
	and #$ff		
	sta <:y			; number of lines

	pea VDMA_CONTROL_REG/256  ; maybe could pack target bank, and k into this
	plb
	plb

	; Dest Pointer for scale, is 0x200000
	stz <:pDesti
	ldy #0
	lda #$20
	sta <:pDesti+2

]scale_loop

	; DMA Source
	lda <OSC_SAMPLER_ADDR,x
	sta |VDMA_SRC_ADDY_L
	lda <OSC_SAMPLER_ADDR+1,x
	sta |VDMA_SRC_ADDY_L+1
	; DMA Dest
	;lda <:pDesti
	;sta |VDMA_DST_ADDY_L
	sty |VDMA_DST_ADDY_L
	lda <:pDesti+1
	sta |VDMA_DST_ADDY_L+1

	lda #2
	sta |VDMA_X_SIZE_L
	sta |VDMA_SRC_STRIDE_L
	lda <:y
	sta |VDMA_Y_SIZE_L

	lda <:stride
	sta |VDMA_DST_STRIDE_L

	sep #$20
	stz |VDMA_CONTROL_REG

	; Begin 2D DMA
	lda #VDMA_CTRL_Enable+VDMA_CTRL_1D_2D+VDMA_CTRL_Start_TRF
	sta |VDMA_CONTROL_REG

		; Wait for Completion
]wait_dma
	lda |VDMA_STATUS_REG
	bmi	]wait_dma

	rep #$31

	iny
	iny
	; inc <:pDesti
	dec <:count

	bne ]scale_loop

	phk
	plb

	rts
;------------------------------------------------------------------------------
;
MIXER_FIFO mx %00
	; 1. update the volume tables
	; 2. dump as many samples as we are able into the HW FIFO
	rts


;------------------------------------------------------------------------------
;
;
MIXER_SHUTDOWN ent
	rtl

;------------------------------------------------------------------------------
;
; Generate the unrolled code, that we'll use to make 
;
GenerateFIFO mx %00

	;@TODO Convert to DMA
;FRAG_SIZE = {MIXFIFO24_end-MIXFIFO24_start}
	; Copy initial code fragment

	ldx #MIXFIFO24_start	 ; src
	ldy #MIXFIFO			 ; dst
	lda #FRAG_SIZE-1		 ; len - 1 
	mvn ^MIXFIFO24_start,^MIXFIFO

	; Overlap copy to make 1024 more
	ldx #MIXFIFO
	; y should already be fine
	lda #{FRAG_SIZE*1024}-1   ; this creates 1 extra, I don't care
	mvn ^MIXFIFO,^MIXFIFO

	; Add a Jump to loop the thing
	lda #$4C	; JMP MIXFIFO (at the end)
	sta |MIXFIFO+{1024*FRAG_SIZE}
	lda #MIXFIFO
	sta |MIXFIFO+{1024*FRAG_SIZE}+1

	phk
	plb



	rts

;------------------------------------------------------------------------------
;
; Generate the Volume tables
; 
GenerateVolumes mx %00

:temp equ 0

	pei :temp

	; Switch into VOL_TABLE data bank
	pea >VOL_TABLES
	plb
	plb

; Initialize the full volume Table

	ldx #510
	lda #$FF
	sta <:temp
]lp
	lda <:temp
	cmp #$0080
	bcc :pos
	ora #$FF00
:pos
	sta |VOL_TABLES,x
	dex
	dex
	dec <:temp
	bpl ]lp

; Initialize all 65 entries of the volume tables
; to full Volume

	; Overlap copy to make 64 more
	ldx #VOL_TABLES
	ldy #{VOL_TABLES+512}
	lda #{64*512}-1        ; length, uses overlapping copy
	mvn ^VOL_TABLES,^VOL_TABLES

; early exit
;	phk
;	plb

;	pla
;	sta <:temp
;	rts

	; Conveniently leaves the B where we want it

; ----------------------------
;
;  Now Generate Volumes 0-64
; (which should work our great, because 4*64 = 256)
; I actually want the highest volume to be 3F.FF, so the 4 values mixed
; End up at FFFC, (I hopefully won't have to worry about overflow)

	phd
	lda #$100  ; Put the DPage on Top of the Maths co-processor
	tcd


	ldy #0	; y = Volume Table #
	tyx     ; x = Volume Table Index offset
	tya

]outer_loop

	sta <SIGNED_MULT_A_LO
	;pha

	ldy #255

]inner_loop

	;lda 1,s
	;sta <SIGNED_MULT_A_LO

	lda |VOL_TABLES,x   		; Existing 16 bit SEXT Volume
	sta <SIGNED_MULT_B_LO

	lda <SIGNED_MULT_AL_LO		; Assumes I don't have to keep reseting input
	sta |VOL_TABLES,x

	inx
	inx

	dey
	bpl ]inner_loop

	;pla
	lda <SIGNED_MULT_A_LO
	inc
	cmp #65
	bcc ]outer_loop

	phk		; restore Data Bank
	plb

	pld		; restore D-Page

; ----------------------------
	pla
	sta <:temp

	rts


;------------------------------------------------------------------------------

