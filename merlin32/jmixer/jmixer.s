;
;  Jason's Mixer, in Merlin
;
        rel     ; relocatable
        lnk     Main.l

        use Util.Macs

		; Vicky
		use phx/vicky_ii_def.asm
		use phx/VKYII_CFP9553_BITMAP_def.asm 
		use phx/VKYII_CFP9553_TILEMAP_def.asm
		use phx/VKYII_CFP9553_VDMA_def.asm   
		use phx/VKYII_CFP9553_SDMA_def.asm   
		use phx/VKYII_CFP9553_SPRITE_def.asm 

		; Kernel
		use phx/page_00_inc.asm
		use phx/kernel_inc.asm

		; Fixed Point Math
		use phx/Math_def.asm

		; Interrupts
		use phx/interrupt_def.asm

		; Timers
		use phx/timer_def.asm

        mx %00

; Stuff in other modules
		ext nicefont
		ext shaston

;------------------------------------------------------------------------------
; I like having my own Direct Page
MyDP  = $2000
MySTACK = $EFFF

VICKY_DISPLAY_BUFFER  = $100000

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
dpAudioJiffy  = dpJiffy+2
;------------------------------------------------------------------------------
; Video Stuff
XRES = 800
YRES = 600

	do XRES=640
VIDEO_MODE = $004F
	else
VIDEO_MODE = $014F
	fin
;------------------------------------------------------------------------------


start ent       ; make sure start is visible outside the file
        clc
        xce
		sei
        rep $31 ; long MX, and CLC


; Default Stack is on top of System Multiply Registers
; So move the stack before proceeding

        lda #MySTACK
        tcs

        lda #MyDP
        tcd

		phk
		plb

; Setup a Jiffy Timer, using Kernel Jump Table
; Trying to be friendly, in case we can friendly exit
;
		jsr InstallJiffy	   ; 60hz SOF Timer

		jsr InstallAudioJiffy  ; 50hz timer

		jsr	WaitVBL

;------------------------------------------------------------------------------

		lda #VIDEO_MODE  		  	; 800x600 + Gamma + Bitmap_en
		sep #$30
		sta >MASTER_CTRL_REG_L
		xba
		sta >MASTER_CTRL_REG_H

		;lda #BM_Enable
		lda #0
		sta >BM0_CONTROL_REG

		lda #<VICKY_DISPLAY_BUFFER
		sta >BM0_START_ADDY_L
		lda #>VICKY_DISPLAY_BUFFER
		sta >BM0_START_ADDY_M
		lda #^VICKY_DISPLAY_BUFFER
		sta >BM0_START_ADDY_H

	    ;
		; Reset Mouse
		;
		lda #0
		sta >MOUSE_PTR_CTRL_REG_L
		lda #1
		sta >MOUSE_PTR_CTRL_REG_L

		rep #$31

		jsr InitTextMode

		lda #0
		sta >BM0_X_OFFSET
		sta >BM0_Y_OFFSET
		sta >BM1_CONTROL_REG
;------------------------------------------------------------------------------

		phk
		plb
		lda #0
		ldx #0
]clear  sta >$AF8000,x		; clear font
		inx
		inx
		cpx #$1000
		bcc ]clear

		ldx #0
]copy   ;lda >nicefont,x    ; copy up new glyphs
		lda >shaston,x
		sta >$AF8100,x
		inx
		inx
		cpx #768
		bcc ]copy

;------------------------------------------------------------------------------

main_loop mx %00

		rep #$30

		stz <dpJiffy
		stz <dpAudioJiffy

		jsr myPRINTCR
		lda #$0123
		jsr myPRINTAH
		jsr myPRINTCR
		lda #$1234
		jsr myPRINTAH
		jsr myPRINTCR
		lda #$5678
		jsr myPRINTAH
		jsr myPRINTCR

		;lda #45123
		;jsr myPRINTAI
		;jsr myPRINTCR

]lp
		jsr WaitVBL
		
		ldx |CURSORX
		ldy |CURSORY
		phy
		phx 	

		ldx #96
		ldy #0
		jsl LOCATE	    ; cursor to top left of the screen

		lda <dpJiffy
		jsr myPRINTAH

		ldx #96
		ldy #1
		jsl LOCATE

		lda <dpAudioJiffy
		jsr myPRINTAH

		plx
		ply
		jsl LOCATE


		bra ]lp


;------------------------------------------------------------------------------
; WaitVBL
; Preserve all registers
;
WaitVBL
		pha
		lda <dpJiffy
]lp
		cmp <dpJiffy
		beq ]lp
		pla
		rts

;------------------------------------------------------------------------------
InitTextMode mx %00

		phd
		lda #0
		tcd

		; Fuck, make the text readable
		dec  ; A = 0xFFFF
		sta >$AF1F78
		sta >$AF1F79

;
; Disable the border
;
		sep #$30
		lda	#0
		sta >BORDER_CTRL_REG
		rep #$30


		jsl SETSIZES  ; because we changed the resolution, takes into account border
		jsl CLRSCREEN ; because the data in the screen is messed up

		ldx #0
		txy
		jsl LOCATE	    ; cursor to top left of the screen

		ldx #:Text  ; out a string
		jsl PUTS

		pld
		rts

:Text   asc 'Jason',27,'s Mixer $1234'
		db 13
		asc 'Memory Location:'
		db 0

;------------------------------------------------------------------------------
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
		php
		rep #$30
		inc |{MyDP+dpJiffy}
		plp
		plb
		rtl

;------------------------------------------------------------------------------
;
; Audio Jiffy Timer Installer, Enabler
; Depends on the Kernel Interrupt Handler
;
; Currently hijack timer 0, but could work on timer 1
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
InstallAudioJiffy mx %00

; Trying for 50 hz here

:RATE equ {14318180/50}

; Fuck over the vector

		sei

		lda #$4C	; JMP
		sta |VEC_INT02_TMR0

		lda #:AudioJiffyTimer
		sta |VEC_INT02_TMR0+1

		; Configuring for count up
		sep #$30

		stz |TIMER0_CHARGE_L
		stz |TIMER0_CHARGE_M
		stz |TIMER0_CHARGE_H

		lda #<:RATE
		sta |TIMER0_CMP_L
		lda #>:RATE
		sta |TIMER0_CMP_M
		lda #^:RATE
		sta |TIMER0_CMP_H

		lda #TMR0_CMP_RECLR
		sta |TIMER0_CMP_REG
		lda #TMR0_EN+TMR0_UPDWN+TMR0_SCLR
		sta |TIMER0_CTRL_REG

; Enable the TIME0 interrupt

		lda	#FNX0_INT02_TMR0
		trb |INT_MASK_REG0

		rep #$35  ;mx-i-c = 0

		rts

:AudioJiffyTimer
		phb
		phk
		plb
		php
		rep #$30
		inc |{MyDP+dpAudioJiffy}
		plp
		plb
		rtl

;------------------------------------------------------------------------------
;
; Put DP back at 0, for Kernel call
;
myPRINTCR mx %00
	    phd
		pea #0
		pld
		jsl PRINTCR
		pld
		rts

;------------------------------------------------------------------------------
;
; Put DP back at 0, for Kernel call
;
myPRINTAI mx %00
	    phd
		pea #0
		pld
		jsl PRINTAI
		pld
		rts

;------------------------------------------------------------------------------
;
; Put DP back at 0, for Kernel call
;
myPRINTAH mx %00
		; Kernel function doesn't work

		sep #$30
		xba
		pha
		lsr
		lsr
		lsr
		lsr
		tax
		pla
		and #$0F
		tay
		lda |:chars,x
		sta |:temp
		lda |:chars,y
		sta |:temp+1
		xba
		pha
		lsr
		lsr
		lsr
		lsr
		tax
		pla
		and #$0F
		tay
		lda |:chars,x
		sta |:temp+2
		lda |:chars,y
		sta |:temp+3
		rep #$30

		ldx #:temp
		jmp myPUTS

:chars  ASC '0123456789ABCDEF'

:temp	ds  5

;------------------------------------------------------------------------------
;
; Put DP back at zero while calling out to PUTS
;
myPUTS  mx %00
        phd
        lda #0
        tcd
		;php
		;sei
        jsl PUTS
		;plp
        pld
        rts

;------------------------------------------------------------------------------
	do 0
TrackSampler mx %00

		; version 1
		lda >pSample,x     ; 6  	; 43
		asl 			   ; 2
		and #$1FF   	   ; 3
		sta <SampleData    ; 4

		lda <pSample	   ; 4
		adc <iRate  	   ; 4
		sta <pSample	   ; 4
		lda <pSample+2     ; 4 
		adc <iRate+2	   ; 4
		sta <pSample+2     ; 4
		ldx <pSample+1     ; 4

		; version 2 	   ; 32 clocks
		ldx |offset,y      ; 5
		lda >pSample,x     ; 6
		asl 			   ; 2
		and #$1FF   	   ; 3
		sta |output,y      ; 5

		iny 	  ;2
		iny 	  ;2
		cpy #512  ;3
		bne ]lp   ;4 

		; version 3
		ldy #offset 	  ; 3  ; 18
		lda [pSample],y   ; 7
		asl 			  ; 2
		and #$1FF   	  ; 3
		sta <output,x     ; 5
	fin



;------------------------------------------------------------------------------
;
;         Table 2: Summary of MIDI Note Numbers for Different Octaves
; (adapted from "MIDI by the Numbers" by D. Valenti - Electronic Musician 2/88)
;
;
;Octave||                     Note Numbers
;   #  ||
;      || C   | C#  | D   | D#  | E   | F   | F#  | G   | G#  | A   | A#  | B
;------------------------------------------------------------------------------
;   0  ||   0 |   1 |   2 |   3 |   4 |   5 |   6 |   7 |   8 |   9 |  10 |  11
;   1  ||  12 |  13 |  14 |  15 |  16 |  17 |  18 |  19 |  20 |  21 |  22 |  23
;   2  ||  24 |  25 |  26 |  27 |  28 |  29 |  30 |  31 |  32 |  33 |  34 |  35
;   3  ||  36 |  37 |  38 |  39 |  40 |  41 |  42 |  43 |  44 |  45 |  46 |  47
;   4  ||  48 |  49 |  50 |  51 |  52 |  53 |  54 |  55 |  56 |  57 |  58 |  59
;   5  ||  60 |  61 |  62 |  63 |  64 |  65 |  66 |  67 |  68 |  69 |  70 |  71
;   6  ||  72 |  73 |  74 |  75 |  76 |  77 |  78 |  79 |  80 |  81 |  82 |  83
;   7  ||  84 |  85 |  86 |  87 |  88 |  89 |  90 |  91 |  92 |  93 |  94 |  95
;   8  ||  96 |  97 |  98 |  99 | 100 | 101 | 102 | 103 | 104 | 105 | 106 | 107
;   9  || 108 | 109 | 110 | 111 | 112 | 113 | 114 | 115 | 116 | 117 | 118 | 119
;  10  || 120 | 121 | 122 | 123 | 124 | 125 | 126 | 127 |
;
