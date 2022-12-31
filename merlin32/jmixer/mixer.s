;
;  The actual mixing code
;
		org $0B0000
		dsk mixer.bin
		mx %00
		
		use mixer.i
		 
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
					
;------------------------------------------------------------------------------
					
