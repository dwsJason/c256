;
;  The actual mixing code
;

;		org $0B0000
;		dsk mixer.bin
        rel     ; relocatable
        lnk     mixer.l

        use Util.Macs
		use macs.i
		use mixer.i
		use ../phx/Math_def.asm

		mx %00

; Dispatch

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

		jsr InitVolumeTables




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
Msetvolume mx %00
		rtl
;------------------------------------------------------------------------------
		
; Unlike NTP, I need / want some bank 0 space		
;------------------------------------------------------------------------------
; We want to be able to use the math coprocessor in page $100 as well
;
pOscillators ds 2  ; 16 bit pointer to the array of oscillators in bank0 
pMixBuffers  ds 2  ; 16 bit pointer to the mix buffers in bank0
   	
; each oscillator needs 512 bytes of sample space, I want this in bank 0
; also (256 samples)
   	
		
		do 0
; Volume using the hw multiplies, too slow

; Initialize Left/Right FIFOs   	
   	
		lda |osc_left_vol,y
		sta <UNSIGNED_MULT_A_LO
		lda |osc_right_vol,y
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

	--^

MIXFIFO24_8_end

    rtl
	fin

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
		
ResampleOSC0 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y
	sta >MIXFIFO24_8_start+1+{]count*45}
	sta >MIXFIFO24_8_start+32+{]count*45}
]count = ]count+1
	--^
	rtl
ResampleOSC1 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y
	sta >MIXFIFO24_8_start+1+{]count*45}+4
	sta >MIXFIFO24_8_start+32+{]count*45}+4
]count = ]count+1
	--^
	rtl
ResampleOSC2 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y
	sta >MIXFIFO24_8_start+1+{]count*45}+8
	sta >MIXFIFO24_8_start+32+{]count*45}+8
]count = ]count+1
	--^
	rtl
ResampleOSC3 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y
	sta >MIXFIFO24_8_start+1+{]count*45}+12
	sta >MIXFIFO24_8_start+32+{]count*45}+12
]count = ]count+1
	--^
	rtl
ResampleOSC4 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y
	sta >MIXFIFO24_8_start+1+{]count*45}+16
	sta >MIXFIFO24_8_start+32+{]count*45}+16
]count = ]count+1
	--^
	rtl
ResampleOSC5 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y
	sta >MIXFIFO24_8_start+1+{]count*45}+20
	sta >MIXFIFO24_8_start+32+{]count*45}+20
]count = ]count+1
	--^
	rtl
ResampleOSC6 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y
	sta >MIXFIFO24_8_start+1+{]count*45}+24
	sta >MIXFIFO24_8_start+32+{]count*45}+24
]count = ]count+1
	--^
	rtl
ResampleOSC7 mx %00
]count = 0
	lup 256
	lda |{0+{]count*2}},y
	sta >MIXFIFO24_8_start+1+{]count*45}+28
	sta >MIXFIFO24_8_start+32+{]count*45}+28
]count = ]count+1
	--^
	rtl

		
;------------------------------------------------------------------------------
; lda #Freq   ; 8.8
; ldx #OSC Number
: 
SetChannelFreq mx %00
SetFrequency mx %00
	phb
	phk
	plb

	phd
	pea $100
	pld

	;;lda #freq ; 8.8
	sta <UNSIGNED_MULT_A_LO

	txa
	asl
	tax
	lda |:osc_table,x
	tax
	
]input = 0
; loop 256 times
]offset = 1
	lup 256
	ldy #]input 				; 3
	sty <UNSIGNED_MULT_B_LO 	; 4
	lda <UNSIGNED_MULT_AL_HI	; 4
	and #$FFFE  				; 3
	sta |]offset+1,x  			; 5   ; 19 * 256 = 4864
]input = ]input+2
]offset = ]offset+11
	--^
	pld
	plb
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

	pei osc_pWave+2
	plb
	plb
	lda <osc_pWave+1
	and #$FFFE
	tay
	jsl ResampleOSC0

	clc
	lda <osc_pWave
	adc <osc_frame_size
	sta <osc_pWave
	lda <osc_pWave+2
	adc <osc_frame_size+2
	sta <osc_pWave+2

	; if pWave >= pWaveEnd
	;    pWave = pLoop + (pWave-pWaveEnd)
	sec
	lda <osc_pWave
	sbc <osc_pWaveEnd
	sta <osc_delta
	lda <osc_pWave+2
	sbc <osc_pWaveEnd+2
	sta <osc_delta
	bmi :next_osc

	clc
	lda <osc_pWaveLoop
	adc <osc_delta
	sta <osc_pWave
	lda <osc_pWaveLoop+2
	adc <osc_delta+2
	sta <osc_pWave+2

:next_osc
	

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
;  Now Generate Volumes 0-64
; (which should work our great, because 4*64 = 256)
; I actually want the highest volume to be 1F.FF, so the 8 values mixed
; End up at FFF8, (I hopefully won't have to worry about overflow)

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
	cmp #$8000
	lsr
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

