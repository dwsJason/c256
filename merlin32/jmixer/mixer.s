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

		 
VOICES   equ 8
DAC_RATE equ 48000

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

; 24Khz + 8 channel
MIXFIFO24_8_start mx %00

	lup 128								  ; 291 (48Khz), 583 (24Khz),875(16Khz)

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

