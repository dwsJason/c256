;
;  Jason's Mixer, in Merlin
;
        rel     ; relocatable
        lnk     Main.l

        use Util.Macs

; move macs to move into another file

;
; Misc Macros, that just make things a little easier
;
; nvmx dizc	Status Register
; Processor Status Register (P)
;===================================
;
;Bits  7   6   5   4   3   2   1   0
;                                /---\
;                                I e --- Emulation 0 = Native Mode
;    /---l---l---l---l---l---l---+---I
;    I n I v I m I x I d I i I z I c I
;    \-l-I-l-I-l-I-l-I-l-I-l-I-l-I-l-/
;      I   I   I   I   I   I   I   \-------- Carry 1 = Carry
;      I   I   I   I   I   I   \------------- Zero 1 = Result Zero
;      I   I   I   I   I   \---------- IRQ Disable 1 = Disabled
;      I   I   I   I   \------------- Decimal Mode 1 = Decimal, 0 = Binary
;      I   I   I   \-------- Index Register Select 1 = 8-bit, 0 = 16-bit
;      I   I   \-------- Memory/Accumulator Select 1 = 8-bit, 0 = 16 bit
;      I   \----------------------------- Overflow 1 = Overflow
;      \--------------------------------- Negative 1 = Negative
;

; Long Conditional Branches

beql mac
    bne skip@
    jmp ]1
skip@
    <<<

bnel mac
    beq skip@
    jmp ]1
skip@
    <<<

bccl mac
    bcs skip@
    jmp ]1
skip@
    <<<

bcsl mac
    bcc skip@
    jmp ]1
skip@
    <<<

bpll mac
	bmi skip@
	jmp ]1
skip@
    <<<

bmil mac
	bpl skip@
	jmp ]1
skip@
    <<<

; Macro, for pushing K + Another Bank, using pea command
;
; Allows something like this
;
phkb mac
k@
	db $F4 ; pea
	db ]1  ; target bank
	db ^k@ ; k bank
	<<<

; MouseText
	dum {32+96}
MT_CLOSED_APPLE ds 1
MT_OPEN_APPLE   ds 1
MT_CURSOR       ds 1
MT_HOURGLASS    ds 1
MT_CHECK        ds 1
MT_INV_CHECK    ds 1
MT_INV_CR       ds 1
MT_4BAR         ds 1
MT_LEFT_ARROW   ds 1
MT_DOTDOTDOT    ds 1
MT_DOWN_ARROW   ds 1
MT_UP_ARROW     ds 1
MT_UP_BAR       ds 1
MT_CR           ds 1
MT_VBLOCK       ds 1
MT_SCROLL_LEFT  ds 1
MT_SCROLL_RIGHT ds 1
MT_SCROLL_DOWN  ds 1
MT_SCROLL_UP    ds 1
MT_1BAR         ds 1
MT_LLCORNER     ds 1
MT_RIGHT_ARROW  ds 1
MT_CHECKER1     ds 1
MT_CHECKER2     ds 1
MT_FOLDER1      ds 1
MT_FOLDER2      ds 1
MT_RIGHT_BAR    ds 1
MT_DIAMOND      ds 1
MT_2BAR         ds 1
MT_PLUS         ds 1
MT_CLOSE        ds 1
MT_LEFT_BAR     ds 1
MT_RUN1         ds 1
MT_RUN2         ds 1
	dend


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
MyDP   = $2000
MidiDP = $2100

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

	dum 132
pMidiFileStart ds 4
pMidiFile      ds 4
MF_NumTracks   ds 2
MF_Format      ds 2
	dend

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

		stz |$00E0 ; this is fix the mouse MOUSE_IDX or MOUSE_PTR, depending kernel version

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

		; poke in our favorite GS background color
		sep #$30
		lda #$ff
		sta >BACKGROUND_COLOR_B
		lda #$22
		sta >BACKGROUND_COLOR_G
		sta >BACKGROUND_COLOR_R

		; get the FG color in there too
		lda #$ff
		ldx #{16*4}-1
]lp
		sta >FG_CHAR_LUT_PTR,x
		dex
		bpl ]lp

		rep #$31

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
		cpx #1152
		bcc ]copy

		; set cursor to the Apple IIgs cursor glyph
		sep #$30
		lda #{32+95}
		sta >VKY_TXT_CURSOR_CHAR_REG
		rep #$30

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
		;jsr myPrintAI
		;jsr myPRINTCR

]lp
		jsr WaitVBL
		
		ldx |CURSORX
		ldy |CURSORY
		phy
		phx 	

		ldx #96
		ldy #0
		jsr myLOCATE	    ; cursor to top left of the screen

		lda <dpJiffy
		jsr myPRINTAH

		ldx #96
		ldy #1
		jsr myLOCATE

		lda <dpAudioJiffy
		jsr myPRINTAH

		plx
		ply
		jsr myLOCATE


;		bra ]lp

;------------------------------------------------------------------------------
; MIDI dump
; Need to move these into MIDI Lib
		; MIDI Header 1.0
		dum 0
MThd_MT        ds 2
MThd_hd        ds 2
MThd_Length    ds 4
MThd_Format    ds 2
MThd_NumTracks ds 2
MThd_Division  ds 2
sizeof_MThd    ds 0
		dend

	   dum 0
MTrk_MT	ds 2
MTrk_rk ds 2
MTrk_Length ds 4
MTrk_sizeof ds 0
		dend

		ext midi_axelf ; This lives in a different segment

;pMidiFile = temp0
NumTracks = MF_NumTracks
Format    = MF_Format

		; Setup pointer to the new midi file
		ldx #^midi_axelf
		lda #midi_axelf
		stx <pMidiFile+2
		stx <pMidiFileStart+2
		sta <pMidiFile
		sta <pMidiFileStart

		jsl MidiFileValidate
		bccl :GoodFile

		ldx #:txt_invalid_file
		jsr myPUTS

]lp		bra ]lp

:txt_invalid_file asc '!!Error: Midi file has unrecognized header chunk.'
		db 13,0

:txt_HeaderGood asc 'Midi1.0 header looks legit'
		db 13,0

:txt_Format asc 'Format: '
		db 0

:txt_NumTracks asc 'Tracks: '
		db 0

:txt_formats
		da :0
		da :1
		da :2

:0		asc ' Single multi-channel track'
		db 13,0
:1		asc ' One or more simultaneous tracks'
		db 13,0
:2		asc ' One or more sequentially independent single-track patterns'
		db 13,0

:txt_division asc 'Division:'
		db 0


:GoodFile

		jsl PrintMidiFileChunk

		ldx #:txt_HeaderGood
		jsr myPUTS

		ldx #:txt_Format
		jsr myPUTS

		ldy #MThd_Format
		lda [pMidiFile],y
		xba
		sta <Format
		jsr myPrintAI

		lda <Format
		asl
		tax
		lda |:txt_formats,x
		tax
		jsr myPUTS
		jsr myPRINTCR

		ldy #MThd_NumTracks
		lda [pMidiFile],y 
		xba
		sta <NumTracks

		ldx #:txt_NumTracks
		jsr myPUTS
		lda <NumTracks
		jsr myPrintAI
		jsr myPRINTCR

		ldy #MThd_Division
		lda [pMidiFile],y
		xba
		pha

		ldx #:txt_division
		jsr myPUTS

		lda 1,s
		jsr myPRINTAH
		jsr myPRINTCR

		pla
		bpl :ticks
		; else
		; this the SMPTE format / ticks per frame
:ticks
; ticks = division = PPQ
;
; Default Timing is always 4/4 120bpm (tracks can easily change this)
; I'm interested in getting to ticks per second
; 120bpm is 2 beats per second, so ticks * 2 is the number of ticks per second?
;
;The formula is 60000 / (BPM * PPQ) (milliseconds).
;
;Where BPM is the tempo of the track (Beats Per Minute).
;(i.e. a 120 BPM track would have a MIDI time of (60000 / (120 * 192)) or 2.604 ms for 1 tick.
;
;If you don't know the BPM then you'll have to determine that first. MIDI times are entirely dependent on the track tempo.
;
;You need two pieces of information:
;
;PPQ (pulses per quarter note), which is defined in the header of a midi file, once.
;Tempo (in microseconds per quarter note), which is defined by "Set Tempo" meta events and can change during the musical piece.
;Ticks can be converted to playback seconds as follows:
;
;ticks_per_quarter = <PPQ from the header>
;탎_per_quarter = <Tempo in latest Set Tempo event>
;탎_per_tick = 탎_per_quarter / ticks_per_quarter
;seconds_per_tick = 탎_per_tick / 1.000.000
;seconds = ticks * seconds_per_tick
;------------------------------------------------------------------------------

; We need to loop through all the chunks

		lda #0
]loop
		pha

		jsr myPrintAI
		lda #' '
		jsr myPUTC

		jsl MidiFileNextChunk

; Loop through the chunk itself

		jsl PrintMidiFileChunk

		lda 1,s    			; current track index
		asl
		asl
		tax
		lda <pMidiFile		; current track pointer
		adc #MTrk_sizeof    ; size of the chunk header
		sta |MidiDP,x     	; Array of track pointers
		lda <pMidiFile
		adc #0
		sta |MidiDP+2,x

		pla
		inc
		cmp <NumTracks
		bcc ]loop

;------------------------------------------------------------------------------

		lda #$2020
		ldy #$1010
		ldx #:TestTitle
		jsr DrawBox

]lp		bra ]lp

:TestTitle asc 'Test Title'
		db 0

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
; Put DP back at 0 for kernel call
;
myLOCATE mx %00
		phd
		pea #0
		pld
		jsl LOCATE
		pld
		rts

;------------------------------------------------------------------------------
;
; Put DP back at 0, for Kernel call
;
myPrintAI mx %00

:bcd  = temp0

		php 		 	; preserve P (mxdi)

		pei :bcd		; preserve temp space we're stomping
		pei :bcd+2

		stz <:bcd   	; zero result
		stz <:bcd+2

		sei
		sed   		; does the firmware handle interrupts with D=1?, don't know

		ldx #16

]cnvlp  asl
		tay
		lda <:bcd
		adc <:bcd
		sta <:bcd
		lda <:bcd+2
		adc <:bcd+2
		sta <:bcd+2
		tya
		dex
		bne ]cnvlp

		cld

		sep #$30

		ldx #0     		; output index for text
		lda <:bcd+2 	; only doing 5 digits, and trim leading 0
		and #$0F
		beq :skip1		; trim 0

		tay
		lda |:chars,y   ; not zero, get the char

		sta |:txt,x		; output
		inx
:skip1
		lda <:bcd+1
		lsr
		lsr
		lsr
		lsr
		bne :emit1 	    ; 4th char, output if not zero
		cpx #0
		beq :skip2  	; if nothing output, and zero, trim leading 0
:emit1
		tay
		lda |:chars,y   ; get char

		sta |:txt,x     ; append to string
		inx
:skip2
		lda <:bcd+1
		and #$0F
		bne :emit2 	    ; emit character if not 0
		cpx #0
		beq :skip3  	; trim leading 0
:emit2
		tay
		lda |:chars,y

		sta |:txt,x
		inx
:skip3
		lda <:bcd
		lsr
		lsr
		lsr
		lsr
		bne :emit3
		cpx #0
		beq :skip4
:emit3
		tay
		lda |:chars,y
		sta |:txt,x
		inx
:skip4
		lda <:bcd
		and #$0F
		tay
		lda |:chars,y ; last character is always emit
		sta |:txt,x
		inx
		stz |:txt,x   ; zero terminate

		rep #$30

		pla
		sta <:bcd+2
		pla
		sta <:bcd

		plp


		ldx #:txt
		jmp myPUTS

:chars  ASC '0123456789'

:txt	ds 6

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
;
; Put DP back at zero while calling out to PUTS
;
myPUTC  mx %00
        phd
        pea 0
        pld
        jsl PUTC
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
;
;------------------------------------------------------------------------------
;
;
MidiFileValidate mx %00

		lda [pMidiFile]
		cmp #'MT'
		bne :BadHeader

		ldy #MThd_hd
		lda [pMidiFile],y
		cmp #'hd'
		bne :BadHeader

		ldy #MThd_Length
		lda [pMidiFile],y
		bne :BadHeader

		ldy #MThd_Length+2
		lda [pMidiFile],y
		cmp #$0600
		bne :BadHeader

		clc
		rtl

:BadHeader
		sec
		rtl

;------------------------------------------------------------------------------
; Print everything we know about a chunk
;
PrintMidiFileChunk mx %00

:temp = GlobalTemp

		; start with the address
		lda #'$'
		jsr myPUTC

		lda <pMidiFile+2
		jsr myPRINTAH
		lda <pMidiFile
		jsr myPRINTAH

		lda #':'
		jsr myPUTC

		lda [pMidiFile]
		sta |:temp
		ldy #MTrk_rk
		lda [pMidiFile],y
		sta |:temp+2
		
		lda #8-1
		ldx #:txt_len
		ldy #:temp+4
		mvn ^:txt_len,^:temp

		; zero teminate
		tyx
		stz |0,x

		ldx #:temp
		jsr myPUTS

		ldy #MTrk_Length
		lda [pMidiFile],y
		xba
		jsr myPRINTAH

		ldy #MTrk_Length+2
		lda [pMidiFile],y
		xba
		jsr myPRINTAH
		jsr myPRINTCR

		rtl

:txt_len asc ' Length='
		db 0

;------------------------------------------------------------------------------
;
;  Advance pMidiFile to Next Chunk
;
;
MidiFileNextChunk mx %00

		ldy #MThd_Length+2
		lda [pMidiFile],y
		xba 			 	; low 16 bits, endian corrected
		clc
		adc <pMidiFile
		pha
		ldy #MThd_Length
		lda [pMidiFile],y   ; high 16 bits
		xba					; endian corrected
		adc <pMidiFile+2
		sta <pMidiFile+2
		pla
		sta <pMidiFile

		; Add the 8 bytes that are not included
		clc
		lda <pMidiFile
		adc #MTrk_sizeof	; 8 bytes not included
		sta <pMidiFile
		lda <pMidiFile+2
		adc #0
		sta <pMidiFile+2

		rtl

;------------------------------------------------------------------------------
;GS Border Colors
border_colors
 dw $0,$d03,$9,$d2d,$72,$555,$22f,$6af ; Border Colors
 dw $850,$f60,$aaa,$f98,$d0,$ff0,$5f9,$fff
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
;
; Draw Mouse Box
;
; A = XY    ; X + Y position
; Y = WH    ; Width + Height
; X = Title ; pointer to a title string
DrawBox mx %00
:x = temp0
:y = temp0+2
:width = temp1
:height = temp1+2
:pTitle = temp2
:temp = GlobalTemp

		pha
		and #$FF
		sta <:x
		pla
		xba
		and #$FF
		sta <:y

		tya
		and #$FF
		sta <:width
		tya
		xba
		and #$FF
		sta <:height

		stx <:pTitle

		ldx <:x
		ldy <:y
		jsr myLOCATE

; first draw a top bar

		sep #$30
		lda #'_'
		ldx <:width
		dex
		stz |:temp,x
		dex
		bmi :done_top_bar
]lp		sta |:temp,x
		dex
		bne ]lp

		lda #' '
		sta |:temp,x

:done_top_bar
		rep #$30
		ldx #:temp
		jsr myPUTS

; next line
		ldy <:y
		iny
		sty <:y
		ldx <:x
		jsr myLOCATE

		ldx #:left_str
		jsr myPUTS

		ldx <:pTitle
		jsr myPUTS

		clc
		lda <:x
		adc <:width
		dec
		tax
		ldy <:y
		jsr myLOCATE
		ldx #:right_str
		jsr myPUTS

; next line
		ldy <:y
		iny
		sty <:y
		ldx <:x
		jsr myLOCATE

		sep #$30
		lda #MT_LEFT_BAR
		ldx <:width
		stz |:temp,x
		dex
		sta |:temp,x
		dex
		bmi :done_under_bar
		lda #MT_UP_BAR
]lp 	sta |:temp,x
		dex
		bne ]lp

		lda #MT_RIGHT_BAR
		sta |:temp,x

:done_under_bar
		rep #$30

		ldx #:temp
		jsr myPUTS

]lp
; next line
		ldy <:y
		iny
		sty <:y
		ldx <:x
		jsr myLOCATE

		ldx #:left_str
		jsr myPUTS

		clc
		lda <:x
		adc <:width
		dec
		tax
		ldy <:y
		jsr myLOCATE
		ldx #:right_str
		jsr myPUTS

		dec <:height
		bne ]lp

; next line
		ldy <:y
		iny
		sty <:y
		ldx <:x
		jsr myLOCATE

; bottom bar
		sep #$30
		lda #MT_UP_BAR
		ldx <:width
		dex
		bmi :done_bot_bar
		stz |:temp,x
		dex
		bmi :done_bot_bar
]lp		sta |:temp,x
		dex
		bne ]lp

		lda #' '
		sta |:temp,x

:done_bot_bar
		rep #$30
		ldx #:temp
		jsr myPUTS

		rts
:left_str db MT_RIGHT_BAR,' ',0
:right_str db MT_LEFT_BAR,0

GlobalTemp ds 1024



