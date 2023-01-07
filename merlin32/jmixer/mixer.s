;
;  The actual mixing code
;

;		org $0B0000
;		dsk mixer.bin
        rel     ; relocatable
        lnk     Main.l

        use Util.Macs
		use mixer.i
		use phx/Math_def.asm

		mx %00


; Dispatch

MIXstartup    jmp Mstartup
MIXshutdown   jmp Mshutdown
MIXplaysample jmp Mplaysample
MIXsetvolume  jmp Msetvolume

Mstartup mx %00
		rtl
Mshutdown mx %00
		rtl
Mplaysample mx %00
		rtl
Msetvolume mx %00
		rtl
		
; Unlike NTP, I need / want some bank 0 space		
;------------------------------------------------------------------------------
; We want to be able to use the math coprocessor in page $100 as well
;
pOscillators ds 2  ; 16 bit pointer to the array of oscillators in bank0 
pMixBuffers  ds 2  ; 17 bit pointer to the mix buffers in bank0
   	
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
					
Channel0Left  = $020000
Channel0Right = $030000
Channel1Left  = $040000
Channel1Right = $050000
Channel2Left  = $060000
Channel2Right = $070000
Channel3Left  = $080000
Channel3Right = $090000
				 
Channel4Left  = $0A0000
Channel4Right = $0B0000
Channel5Left  = $0C0000
Channel5Right = $0E0000
Channel6Left  = $0E0000
Channel6Right = $0F0000
Channel7Left  = $100000
Channel7Right = $110000
				 
   
	do 0
; 24Khz + 4 channel   
MIXFIFO24_start mx %00

	lup 256								  ; 291 (48Khz), 583 (24Khz),875(16Khz)

	lda >Channel0Left  ;6        
	adc >Channel1Left  ;6        
	adc >Channel2Left  ;6        
	adc >Channel3Left  ;6
	tax 			   ;2   ; 26

	lda >Channel0Right ;6
	adc >Channel1Right ;6
	adc >Channel2Right ;6
	adc >Channel3Right ;6   ; 24

	stx |$1908  	   ;5  
	sta |$1908         ;5  
	stx |$1908  	   ;5  
	sta |$1908         ;5   ; 20 = total 70

	--^
MIXFIFO24_end
	rts
	fin

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

    rts
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


	lda #freq ; 8.8
	sta <UNSIGNED_MULT_A_LO
	
	ldy #0
; loop 256 times	
	iny 						; 2
	sty <UNSIGNED_MULT_B_LO 	; 4
	lda <UNSIGNED_MULT_AL_HI	; 4
	sta |RESAMPLER  			; 5   ; 11 * 256 = 2816
; --^
	
	
	lda #volume ; 0-255
	sta <SIGNED_MULT_A_LO
	
	; short index
	iny 					 ; 2
	sty <SIGNED_MULT_B_LO    ; 3
	sty <SIGNED_MULT_B_HI    ; 3
	lda <SIGNED_MULT_AH_LO   ; 4
	sta |volume 			 ; 5   ; 17 * 256 = 4352, with DMA this could be under 600 clocks, so we need to use DMA
	
	
		
	
	

