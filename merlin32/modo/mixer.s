;
;  The actual mixing code
;

;		org $0B0000
;		dsk mixer.bin
        rel     ; relocatable
        lnk     mixer.l

        use Util.Macs
		put macros.s
		use mixer.i

		; hardware stuff
		use ../phx/interrupt_def.asm
		use ../phx/Math_def.asm
		use ../phx/Math_Float_def.asm
		use ../phx/timer_def.asm
		use ../phx/VKYII_CFP9553_SDMA_def.asm

		; kernel things
		put ..\phx\kernel_inc.asm


		mx %00

; Dispatch

;
; Be to set A= to an address in bank 0
; for 256 bytes of work memory
;
MIXstartup ent
		jmp Mstartup

MIXshutdown ent 
		jmp Mshutdown

MIXplaysample ent
		jmp Mplaysample

MIXsetvolume ent
		jmp Msetvolume

;------------------------------------------------------------------------------
;
; Initialize all the things
;
; Create Volume Tables
; Set initial volumes on each channel
;
; Initialize silence buffer
; Initialize all oscillators to be playing silence
;
; Load FIFO with silence
;
; Enable DAC
; Pump Data into DAC
;
; Enable the MIXER interrupt, with a 4ms interval (250 interrupts per second)
;
Mstartup mx %00

		sta >pOscillators ; pointer to the work memory

		phb

; clear the silence

		lda #0
		sta >silence
		ldx #silence
		ldy #silence+2
		lda #{silence_end-silence}-3
		mvn ^silence,^silence

		phk
		plb

; zero clear out direct page, oscillators

		ldx |pOscillators
		stz <0,x
		txy
		iny
		iny
		lda #256-3
		mvn 0,0

		phk
		plb

; Initialize Volume Tables
		jsr InitVolumeTables

; Set Initial volumes

		lda #7
		ldx #16 ;32 ; left + right channels set to medium
		;ldy #0
		txy
]lp
		jsl Msetvolume
		dec
		bpl ]lp

; Set Default Freq on each of the 8 channels (to 1.0)
;		nop
;]wait   bra ]wait
;        nop
;
		ldx #7
		lda #$0200  ; 1.0
]lp
		jsl SetChannelFreq
		dex
		bpl ]lp

; Set OSC to default values, playing silence

		phd

		lda |pOscillators
		tcd

		ldx #0	; osc #0
]lp
		lda #silence
		sta <osc_pWave+1,x
		sta <osc_pWaveLoop+1,x
		sta <osc_pWaveEnd+1,x

		lda #^MIXER_WORKRAM
		sta <osc_pWave+3,x
		sta <osc_pWaveLoop+3,x
		sta <osc_pWaveEnd+3,x

		stz <osc_loop_size,x
		stz <osc_loop_size+2,x

		lda #$0200 ; 1.0 - going 9 bits frequency resolution (frequency accrurate to 46.875hz)
		sta <osc_frequency,x
		sta <osc_set_freq,x
		asl
		sta <osc_frame_size+1,x

		lda #$2020  ; 32 + 32, left + right
		sta <osc_left_vol,x
		sta <osc_set_left,x

		txa
		clc
		adc #sizeof_osc
		tax
		cpx #sizeof_osc*VOICES
		bcc ]lp

		do 0
; FPU Initialize, to help with the looping math

		; set for fixed point and divide
		lda #$01F3
		sta >FP_MATH_CTRL0

		; need to do a dummy operation, to sort of unclog
		; any residual values in the system

		lda #$1000
		tax
		sta >FP_MATH_INPUT0_LL
		sta >FP_MATH_INPUT1_LL
		lda #0
		tay
		sta >FP_MATH_INPUT0_HL
		sta >FP_MATH_INPUT1_HL

		txa
		sta >FP_MATH_INPUT0_LL
		tya
		sta >FP_MATH_INPUT0_HL
		txa
		sta >FP_MATH_INPUT1_LL
		tya
		sta >FP_MATH_INPUT1_HL
		fin


; Load Software FIFO

		jsr osc_update

		pld

; Enable DAC

		;phkb ^$AF0000
		;plb

		sep #$30

		lda #2
		sta >$AF1900  ; Reset FIFO
		lda #0
		sta >$AF1900  ; UnReset FIFO

        ; Information
        ; The FIFO is 4096 Byte Deep
        ; With a DMA (That is not supported yet) (1 Read, 1 Write) - Fastest Time to fill the FiFo is 572us 
        ; Mode 0: 8Bits Mono -  4096K Samples @ 48Khz - (Can Store 85.33ms of Sound) 5.3 Frames Long 
        ; Mode 1: 8Bits Stereo -  2048K Samples @ 48Khz - (Can Store 42.66ms of Sound) 2.6 Frames Long
        ; Mode 2: 16Bits Mono -  2048K Samples @ 48Khz - (Can Store 42.66ms of Sound)
        ; Mode 3; 16Bits Stereo - 1024K Samples @ 48Khz - (Can Store 21.33ms of Sound) 1.3 Frames Long  Takes 

		;lda #%1101    ; stereo Mode 3 is where we live, and enable
		;sta |$AF1900
		;sta |$AF1900

		rep #$30

		;plb

; Pump Data into DAC
		; load first half
		jsl MIXFIFO24_8_start

		lda >$AF1904
		and #$FFF
		sta >$300000

		sep #$30
		lda #%1101    ; stereo Mode 3 is where we live, and enable
		sta >$AF1900
		rep #$30

		; load second half
		jsl MIXFIFO24_8_start

		lda >$AF1904
		and #$FFF
		sta >$300002

; Enable the interrupts used to service the OSC + DAC
; 24000 / 256 = 93.75 times per second (this also means our service
; cushion is 10.66ms (good to know), actually an interrupt duty cycle
; of 5ms should be good enough (maybe don't need 4ms fidelity)

		jsr InstallMixerJiffy

		;
		; Errm Gerd
		; 

		plb
		rtl
;------------------------------------------------------------------------------
;
; Unhook/disable the MIXER interrupt
; Disable the DAC
;
Mshutdown mx %00
		rtl
;------------------------------------------------------------------------------
Mplaysample mx %00
		rtl
;------------------------------------------------------------------------------
; MIXsetvolume
;
; Use DMA to change the volume table on an oscillator
;
; A = OSC # 0-7
; X = Left Volume (0-63)
; Y = Right Volume (0-63)
;
Msetvolume mx %00
:osc   = 6
:left  = 4
:right = 2
		phb
		pha
		phx
		phy

		; set B into the same bank as registers
		phkb ^SDMA_CTRL_REG0
		plb

		sep #$10  ; mx=01

		stz |SDMA_CTRL_REG0   ; disable the DMA

		ldx #SDMA_CTRL0_Enable
		stx |SDMA_CTRL_REG0   ; enable the circuit

		; destination address
		;lda :osc,s   A already has the osc#
		xba
		asl
		asl   				   ; x1024

		sta |SDMA_DST_ADDY_L   ; left destination

		lda :left,s            ; volume value
		and #$3F

		; need to multiply by 512
		xba
		asl
		adc #VolumeTables
		sta |SDMA_SRC_ADDY_L

		ldx #^VolumeTables
		stx |SDMA_SRC_ADDY_H
		stx |SDMA_DST_ADDY_H

		lda #512
		sta |SDMA_SIZE_L
		stz |SDMA_SIZE_H

		ldx #SDMA_CTRL0_Enable+SDMA_CTRL0_Start_TRF
		stx |SDMA_CTRL_REG0

		nop	; this pains me
		nop
		nop
		nop
		nop

		stz |SDMA_CTRL_REG0   ; disable the DMA

		ldx #SDMA_CTRL0_Enable
		stx |SDMA_CTRL_REG0   ; enable the circuit

		lda :osc,s   ; OSC #
		xba
		asl
		asl   				   ; x1024
		adc #512
		sta |SDMA_DST_ADDY_L   ; 1024 * osc # + 512 for right channel

		lda :right,s           ; right volume
		and #$3F
		; need to multiply by 512
		xba
		asl
		adc #VolumeTables
		sta |SDMA_SRC_ADDY_L

		ldx #^VolumeTables
		stx |SDMA_SRC_ADDY_H
		stx |SDMA_DST_ADDY_H

		lda #512
		sta |SDMA_SIZE_L
		stz |SDMA_SIZE_H

		ldx #SDMA_CTRL0_Enable+SDMA_CTRL0_Start_TRF
		stx |SDMA_CTRL_REG0

		nop ; why?, it hurts
		nop
		nop
		nop
		nop

		stz |SDMA_CTRL_REG0

		rep #$31

		plb

		ply
		plx
		pla

		plb
		rtl
;------------------------------------------------------------------------------
		
; Unlike NTP, I need / want some bank 0 space		
;------------------------------------------------------------------------------
; We want to be able to use the math coprocessor in page $100 as well
;
pOscillators ds 2  ; 16 bit pointer to the array of oscillators in bank0 
;pMixBuffers  ds 2  ; 16 bit pointer to the mix buffers in bank0
   	
; each oscillator needs 512 bytes of sample space, I want this in bank 0
; also (256 samples)
   	
		
		do 0
; Volume using the hw multiplies, too slow

; Initialize Left/Right FIFOs   	
   	
		lda |osc_left_vol,y
		;and #$00FF
		sta <UNSIGNED_MULT_A_LO
		lda |osc_right_vol,y
		;and #$00FF
		sta <SIGNED_MULT_A_LO
		
		ldx #MixBuffer
]v = 0
]f = 0
		lup 128
		lda <]v,x   					   ;5  ;31
		sta <UNSIGNED_MULT_B_LO 		   ;4
		sta <SIGNED_MULT_B_LO   		   ;4
		lda <UNSIGNED_MULT_AL_HI		   ;4
		sta |left_fifo+]f   			   ;5
		lda <SIGNED_MULT_AL_HI  		   ;4
		sta |right_fifo+]f  			   ;5
]v = ]v+2
]f = ]f+2
		--^
		txa
		clc ; maybe don't need this
		adc #$100
		tax
]v = 0
]f = 256
		lup 128
		lda <]v,x
		sta <UNSIGNED_MULT_B_LO
		sta <SIGNED_MULT_B_LO
		lda <UNSIGNED_MULT_AL_HI
		sta |left_fifo+]f
		lda <SIGNED_MULT_AL_HI
		sta |right_fifo+]f
]v = ]v+2
]f = ]f+2
		--^
;------------------------------------------------------------------------------
; Initialize Left/Right FIFOs   	
   	
		lda |osc_left_vol,y
		sta <UNSIGNED_MULT_A_LO
		lda |osc_right_vol,y
		sta <SIGNED_MULT_A_LO
		
		ldx #MixBuffer
]v = 0
]f = 0
		lup 128
		lda <]v,x   			   ;5 ;36
		sta <UNSIGNED_MULT_B_LO    ;4
		sta <SIGNED_MULT_B_LO      ;4
		lda <UNSIGNED_MULT_AL_HI   ;4
		adc |left_fifo+]f   	   ;5
		sta |left_fifo+]f   	   ;5
		lda <SIGNED_MULT_AL_HI     ;4
		adc |right_fifo+]f  	   ;5
		sta |right_fifo+]f  	   ;5
]v = ]v+2
]f = ]f+2
		--^
		txa
		clc   ; 100% needed
		adc #$100
		tax
]v = 0
]f = 256
		lup 128
		lda <]v,x
		sta <UNSIGNED_MULT_B_LO
		sta <SIGNED_MULT_B_LO
		lda <UNSIGNED_MULT_AL_HI
		adc |left_fifo+]f
		sta |left_fifo+]f
		lda <SIGNED_MULT_AL_HI
		adc |right_fifo+]f
		sta |right_fifo+]f
]v = ]v+2
]f = ]f+2
		--^

		fin					

					
;------------------------------------------------------------------------------
					
	do 1
; 24Khz + 8 channel
MIXFIFO24_8_start mx %00

	phkb ^$AF1900
	plb


	; 19733 bytes (this is better than the the one below), because
	; it can have more bits of resolution in the audio, potentially up to 15 bit
	; if we want to pay the time to alter 64K of data to adjust the volume 
	; we'll have to time the volume setting with 8 bit, and consider going
	; to 9 or 10 bit resolution
	lup 256								  ; 291 (48Khz), 583 (24Khz),875(16Khz)

	lda >Channel0Left  ;6        
	adc >Channel1Left  ;6        
	adc >Channel2Left  ;6        
	adc >Channel3Left  ;6
	adc >Channel4Left  ;6
	adc >Channel5Left  ;6
	adc >Channel6Left  ;6
	adc >Channel7Left  ;6
	tax 			   ;2   ; 50

	lda >Channel0Right ;6
	adc >Channel1Right ;6
	adc >Channel2Right ;6
	adc >Channel3Right ;6
	adc >Channel4Right ;6
	adc >Channel5Right ;6
	adc >Channel6Right ;6
	adc >Channel7Right ;6   ; 48

	stx |$1908  	   ;5
	sta |$1908         ;5  
	stx |$1908  	   ;5  
	sta |$1908         ;5   ; 20 = total 118
	;jsr FIFO_RECORD

	--^

MIXFIFO24_8_end

	plb

    rtl
	fin

; DEBUG BANK
DEBUG_RAM = $300000

FIFO_RECORD
	sta |$1908
:st	sta >DEBUG_RAM
	lda >:st+1
	inc
	inc
	sta >:st+1
	rts



	do 0
	; this is like 17940 bytes
; 24Khz + 8 channel
MIXFIFO24_8_start mx %00

	lup 256								  ; 291 (48Khz), 583 (24Khz),875(16Khz)

	lda |Channel0Left  ;5        
	adc |Channel1Left  ;5        
	adc |Channel2Left  ;5        
	adc |Channel3Left  ;5
	adc |Channel4Left  ;5
	adc |Channel5Left  ;5
	adc |Channel6Left  ;5
	adc |Channel7Left  ;5
	tax 			   ;2   ; 42

	lda |Channel0Right ;5
	adc |Channel1Right ;5
	adc |Channel2Right ;5
	adc |Channel3Right ;5
	adc |Channel4Right ;5
	adc |Channel5Right ;5
	adc |Channel6Right ;5
	adc |Channel7Right ;5   ; 40
	tay 			   ;2   ; 42

	txa 			   ;2
	sta >$1908  	   ;6  
	tya 			   ;2
	sta >$1908         ;6  
	txa 			   ;2
	sta >$1908  	   ;6
	tya 			   ;2
	sta >$1908         ;6   ; 32 = total 116

	--^

MIXFIFO24_8_end
	fin

; channel resampler will work something like this
; At lower rates, we can, maybe peep-hole optmize the loads
; the code gen itself will be faster if we don't (might be worth it, to chisel away the clocks)
;	lda |0,y            ; 5
;	sta >left_chx,x 	; 6
;	sta >right_chx,x	; 6 17 (x8 = 136)  (116+136 = 252)   (~87% duty cycle, 48Khz) (43% at 24Khz) (28% at 16Khz)

; 3+4+4 = 11 bytes * 256 = 2816/$B00 (so $B01 as minimum, up $17/23 in 64K of RAM)
; 128 volume tables in 64K

	
	do 0 ; this is implemented with pre-made tables, and uses DMA when volumes are set
	lda #volume ; 0-255
	sta <SIGNED_MULT_A_LO
	
	; short index
	iny 					 ; 2
	sty <SIGNED_MULT_B_LO    ; 3
	sty <SIGNED_MULT_B_HI    ; 3
	lda <SIGNED_MULT_AH_LO   ; 4
	sta |volume 			 ; 5   ; 17 * 256 = 4352, with DMA this could be under 600 clocks, so we need to use DMA
	
	fin	
		
;
; These all store sample data into the mixer
; I know it could be quicker, by placing all the volume tables into different banks
; could save 6 clocks per OSC, per sample (Which adds up really fast)
;
		
ResampleOSC0 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y
	ora #Channel0Left    ; left
	sta >MIXFIFO24_8_start+5+{]count*77}
	ora #Channel0Right    ; right
	sta >MIXFIFO24_8_start+38+{]count*77}
]count = ]count+1
	--^
	rtl
ResampleOSC1 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y
	ora #Channel1Left    ; left
	sta >MIXFIFO24_8_start+5+{]count*77}+4
	ora #Channel1Right    ; right
	sta >MIXFIFO24_8_start+38+{]count*77}+4
]count = ]count+1
	--^
	rtl
ResampleOSC2 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y
	ora #Channel2Left    ; left
	sta >MIXFIFO24_8_start+5+{]count*77}+8
	ora #Channel2Right    ; right
	sta >MIXFIFO24_8_start+38+{]count*77}+8
]count = ]count+1
	--^
	rtl
ResampleOSC3 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y
	ora #Channel3Left    ; left
	sta >MIXFIFO24_8_start+5+{]count*77}+12
	ora #Channel3Right    ; right
	sta >MIXFIFO24_8_start+38+{]count*77}+12
]count = ]count+1
	--^
	rtl
ResampleOSC4 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y
	ora #Channel4Left    ; left
	sta >MIXFIFO24_8_start+5+{]count*77}+16
	ora #Channel4Right    ; right
	sta >MIXFIFO24_8_start+38+{]count*77}+16
]count = ]count+1
	--^
	rtl
ResampleOSC5 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y
	ora #Channel5Left    ; left
	sta >MIXFIFO24_8_start+5+{]count*77}+20
	ora #Channel5Right    ; right
	sta >MIXFIFO24_8_start+38+{]count*77}+20
]count = ]count+1
	--^
	rtl
ResampleOSC6 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y
	ora #Channel6Left    ; left
	sta >MIXFIFO24_8_start+5+{]count*77}+24
	ora #Channel6Right    ; right
	sta >MIXFIFO24_8_start+38+{]count*77}+24
]count = ]count+1
	--^
	rtl
ResampleOSC7 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y   					   ; 3b
	ora #Channel7Left    ; left 				   ; 3b
	sta >MIXFIFO24_8_start+5+{]count*77}+28 	   ; 4b 
	ora #Channel7Right    ; right   			   ; 3b
	sta >MIXFIFO24_8_start+38+{]count*77}+28	   ; 4b
]count = ]count+1
	--^
	rtl

		
;------------------------------------------------------------------------------
; lda #Freq   ; 7.9 fixed point
; ldx #OSC Number
; 
SetChannelFreq mx %00
SetFrequency mx %00

	pha
	phx
	phy

	phb
	phk
	plb

	phd
	pea $100
	pld

	; A = Freq in 7.9 fixed point format (24000/512) = 46.875
	;
	; I think it's possible to squeeze 4 more bits out of here, but it will
	; slow this function down, since I would be able to read raw bytes
	;
	; Here's what we theoretically would get, just by fixing this function:
	;  
	; 6.10 would give us (24000/1024)  = 23.437 hz
	; 5.11 would give us (24000/2048)  = 11.71  hz
	; 4.12 would give us (24000/4096)  =  5.85  hz
	; 3.13 would give us (24000/8192)  =  2.93  hz
	; 2.14 would give us (24000/16384) =  1.46  hz
	sta <UNSIGNED_MULT_A_LO

	txa
	asl
	tax
	lda |:osc_table,x
	tax

	ldy #$FFFF
	
; loop 256 times
]offset = 0
	lup 256
	iny 						; 2
	sty <UNSIGNED_MULT_B_LO 	; 4
	lda <UNSIGNED_MULT_AL_HI	; 4
	and #$FFFE  				; 3
	sta |]offset+1,x  			; 5   ; 19 * 256 = 4864
]offset = ]offset+17
	--^
	pld
	plb

	ply
	plx
	pla
	rtl
		
:osc_table
	da ResampleOSC0		
	da ResampleOSC1		
	da ResampleOSC2		
	da ResampleOSC3		
	da ResampleOSC4		
	da ResampleOSC5		
	da ResampleOSC6		
	da ResampleOSC7
			
;------------------------------------------------------------------------------
; 4096 - bytes   - for the 24Khz mixer, we push 2048 bytes at a time (for 48khz mixer, we push 1024)
;												(8*256)(256 samples), (need 400 every 16.6ms) (256 every 10.6ms, so probably need 5ms interrupts or 4ms)
;	while FIFO < 3072
	  ; run the mixer/FIFO
	  ; run resamplers
	
	; check for freq changes + apply
	; check for vol changes + apply
	 

;------------------------------------------------------------------------------
;
; Call the ResampleCode (get wave data into the mixer)
;
osc_update mx %00

sizeof_resampler = ResampleOSC1-ResampleOSC0
]offset = 0
]osc    = 0

	lup 8

	lda <osc_frequency+]offset
	cmp <osc_set_freq+]offset
	beq freq_ok

	sta <osc_set_freq+]offset
	asl
	sta <osc_frame_size+1+]offset

	lsr
	ldx #]osc
	jsl SetChannelFreq   ; is there time to do 8 of these at once?  Doubt it.

freq_ok
	pei osc_pWave+2+]offset
	plb
	plb
	lda <osc_pWave+1+]offset 
	and #$FFFE
	tay
	jsl ResampleOSC0+{]osc*sizeof_resampler}

	clc
	lda <osc_pWave+]offset 
	adc <osc_frame_size+]offset 
	sta <osc_pWave+]offset 
	lda <osc_pWave+2+]offset 
	adc <osc_frame_size+2+]offset 
	sta <osc_pWave+2+]offset 

	; if pWave >= pWaveEnd
	;    pWave = pLoop + (pWave-pWaveEnd)
	sec
	lda <osc_pWave+]offset 
	sbc <osc_pWaveEnd+]offset 
	sta <osc_delta
	lda <osc_pWave+2+]offset 
	sbc <osc_pWaveEnd+2+]offset 
	sta <osc_delta+2
	bmi vol_update

	; we're past the end of the wave
	; so now we have to go to
	; loop point + (delta % loop size), so annoying
	lda <osc_loop_size+]offset
	ora <osc_loop_size+2+]offset
	bne do_mod
	stz <osc_delta
	stz <osc_delta+2
	bra mod_done
do_mod
	; if the loop size is >= delta, then no mod
	lda <osc_delta+2
	cmp <osc_loop_size+2+]offset
	bcc mod_done  ; no mod
	bne mod
	lda <osc_delta
	cmp <osc_loop_size+]offset
	bcc mod_done	; no mod
	beq mod_done	; no mod
mod
	; $$TODO, we have to do some real math here
	; delta will never be larger than 4096
	; still we must do loop size / delta
	; and alter the delta, so it matches the remainder

	; I feel like this is not going to work.
	lda <osc_loop_size+1+]offset
	sta >UNSIGNED_DIV_DEM_LO
	lda <osc_delta+1
	sta >UNSIGNED_DIV_NUM_LO
	lda >UNSIGNED_DIV_REM_LO
	sta <osc_delta+1


mod_done
	clc
	lda <osc_pWaveLoop+]offset 
	adc <osc_delta
	sta <osc_pWave+]offset 
	lda <osc_pWaveLoop+2+]offset 
	adc <osc_delta+2
	sta <osc_pWave+2+]offset 
vol_update
	; slip volume updates into here
	lda <osc_left_vol+]offset
	cmp <osc_set_left+]offset
	beq next_osc
	sta <osc_set_left+]offset

	tax
	xba
	tay
	lda #]osc
	jsl Msetvolume

next_osc

]osc = ]osc+1
]offset = ]offset+28
	--^
	rts

;------------------------------------------------------------------------------
;
; Setup 64 pre-made volume tables
;
InitVolumeTables mx %00
:temp equ 0
		pei :temp

		phkb ^VolumeTables
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
		sta |VolumeTables,x
		dex
		dex
		dec <:temp
		bpl ]lp

; Initialize all 65 entries of the volume tables
; to full Volume

		; Overlap copy to make 64 more
		ldx #VolumeTables
		ldy #{VolumeTables+512}
		lda #{63*512}-1        ; length, uses overlapping copy
		mvn ^VolumeTables,^VolumeTables
		; leaves B where we want

; ----------------------------
;
; Now Generate Volumes 0-64
; I actually want the highest volume to be FFF, so the 8 values mixed
; End up at 7FF8, (I hopefully won't have to worry about overflow)
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

		lda |VolumeTables,x   		; Existing 16 bit SEXT Volume
		sta <SIGNED_MULT_B_LO

		lda <SIGNED_MULT_AL_LO		; Assumes I don't have to keep reseting input
		cmp #$8000  				; scale down, so we can mix 8 of them at full blast
		ror
		sta |VolumeTables,x

		inx
		inx

		dey
		bpl ]inner_loop

		;pla
		lda <SIGNED_MULT_A_LO
		inc
		cmp #64
		bcc ]outer_loop

		phk		; restore Data Bank
		plb

		pld		; restore D-Page

;-----------------------
; restore stuff

		plb
		pla
		sta <:temp
		rts
;------------------------------------------------------------------------------
; (leave timer 0 for actual trackers)
; Currently hijack timer 1, but could work on timer 0
;
;C pseudo code for counting up
;TIMER1_CHARGE_L = 0x00;
;TIMER1_CHARGE_M = 0x00;
;TIMER1_CHARGE_H = 0x00;
;TIMER1_CMP_L = clockValue & 0xFF;
;TIMER1_CMP_M = (clockValue >> 8) & 0xFF;
;TIMER1_CMP_H = (clockValue >> 16) & 0xFF;
;
;TIMER1_CMP_REG = TMR_CMP_RECLR;
;TIMER1_CTRL_REG = TMR_EN | TMR_UPDWN | TMR_SCLR;
;
;C pseudo code for counting down
;TIMER1_CHARGE_L = (clockValue >> 0) & 0xFF;
;TIMER1_CHARGE_M = (clockValue >> 8) & 0xFF;
;TIMER1_CHARGE_H = (clockValue >> 16) & 0xFF;
;TIMER1_CMP_L = 0x00;
;TIMER1_CMP_M = 0x00;
;TIMER1_CMP_H = 0x00;
;
;TIMER1_CMP_REG = TMR_CMP_RELOAD;
;TIMER1_CTRL_REG = TMR_EN | TMR_SLOAD;
;
InstallMixerJiffy mx %00

; Enable the interrupts used to service the OSC + DAC
; 24000 / 256 = 93.75 times per second (this also means our service
; cushion is 10.66ms (good to know), actually an interrupt duty cycle
; of 5ms should be good enough (maybe don't need 4ms fidelity)

; trying for a 5ms cadence here
; 1000/5 = 200s interrupt per second
; interrupt have overhead, so in theory
; 200hz interrupts (187.5 might also be ok)
;:RATE equ {14318180/400}
:RATE equ 76363   ; 187.5 times per second

; The reason I want this 2x the rate, is that the FIFO always needs something
; left in the tank.  Anytime it hit's empty, it will hurt my ears.

		php
		sei

		phkb 0
		plb

		; jump vector hooked up

		lda #$5C
		sta |VEC_INT03_TMR1

		lda #MixerService
		sta |VEC_INT03_TMR1+1
		lda #>MixerService
		sta |VEC_INT03_TMR1+2

		sep #$30

		stz |TIMER1_CHARGE_L
		stz |TIMER1_CHARGE_M
		stz |TIMER1_CHARGE_H

		lda #<:RATE
		sta |TIMER1_CMP_L
		lda #>:RATE
		sta |TIMER1_CMP_M
		lda #^:RATE
		sta |TIMER1_CMP_H

		lda #TMR1_CMP_RECLR
		sta |TIMER1_CMP_REG
		lda #TMR1_EN+TMR1_UPDWN+TMR1_SCLR
		sta |TIMER1_CTRL_REG

; Enable the TIME1 interrupt

		lda	#FNX0_INT03_TMR1
		trb |INT_MASK_REG0

		rep #$31

		plb
		plp

		rts

;------------------------------------------------------------------------------
MixerService mx %00
		php
		rep #$30
:check
		lda >$AF1904 ; Read the FIFO Status
;		bmi :break
;		and #$FFF    ; We dump in 256 samples at a time
;		beq :break
;
;		cmp #$980
		             ; our samples are 8 bytes each, so 2048 bytes
;		bcc :work
		and #$800
		beq :work

		plp
		rtl
:work
		; dump data into the HW FIFO
		phb
		jsl MIXFIFO24_8_start
		phd

		; b will get set above, but what if that changes?
		phk
		plb

		lda |pOscillators
		tcd

;
; honor any wave pointer update requests
;

		jsr osc_update	; grab sample data, for the "software fifo"

; honor frequency change requests
; (since volume uses DMA, it can happen "immediately")

		pld
		plb
		;bra :check 

		plp
		rtl

;------------------------------------------------------------------------------

