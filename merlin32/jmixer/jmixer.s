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

cstr mac
	asc ]1
	db 0
	<<<
;-------------------------------------------------------------------------------
; print X;Y;'CSTRING'
print mac
	ldx #]1
	ldy #]2
	jsr myLOCATE
	ldx #datastr
	jsr myPUTS
	bra skip
datastr cstr ]3
skip
	eom



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

		use mixer.i

        mx %00

; Stuff in other modules
		ext nicefont
		ext shaston

;------------------------------------------------------------------------------
; I like having my own Direct Page
MyDP        = $2000
MidiDP      = $2100 ; Tracks
MidiEventDP = $2200 ; Tracks

; Midi Event Structure
; pMidiData
; DelayTime
; Event

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
temp8          = 58
temp9          = 62
temp10         = 66
temp11         = 70
KBX            = 74
KBY            = 76

dpJiffy       = 128
dpAudioJiffy  = dpJiffy+2

	dum 132
pMidiFileStart ds 4
pMidiFile      ds 4
pMidiName      ds 2
MF_NumTracks   ds 2
MF_Format      ds 2
MF_Division	   ds 2
; Current Track
pTrack		   ds 4
VLQ            ds 4
	dend

;------------------------------------------------------------------------------
; Video Stuff
XRES = 800
YRES = 600

	do XRES=640
VIDEO_MODE = $004F
	else
;VIDEO_MODE = $014F
VIDEO_MODE = $0141
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

		jmp SkipJiffys

;
; As long as the Jiffy's don't move, then I don't have to push the reset
; button, so copy them up here, less likely to move
;

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


SkipJiffys
;------------------------------------------------------------------------------

		lda #VIDEO_MODE  		  	; 800x600 + Gamma + Bitmap_en
		sep #$30
		sta >MASTER_CTRL_REG_L
		xba
		sta >MASTER_CTRL_REG_H

		;lda #BM_Enable
		lda #0
		sta >BM0_CONTROL_REG
		sta >BM1_CONTROL_REG
		sta >TL0_CONTROL_REG
		sta >TL1_CONTROL_REG
		sta >TL2_CONTROL_REG
		sta >TL3_CONTROL_REG


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

		; Init BSS

		stz |GlobalTemp
		ldx #GlobalTemp
		ldy #GlobalTemp+2
		lda #sizeof_BSS-3
		mvn ^GlobalTemp,^GlobalTemp

		; Init Patches BSS
		phb
		lda #0
		sta >Patches
		ldx #Patches
		ldy #Patches+2
		lda #{128*sizeof_inst}-3
		mvn ^Patches,^Patches
		plb

		jsr InitTextMode

		; poke in our favorite GS background color

;		sep #$30
;		lda #$ff
;		sta >BACKGROUND_COLOR_B
;		lda #$22
;		sta >BACKGROUND_COLOR_G
;		sta >BACKGROUND_COLOR_R
;		rep #$31

		; Copy GS colors into the Text Color Memory
		ldx #{16*4}-4
]lp
		lda |gs_colors,x
		sta >BG_CHAR_LUT_PTR,x
		sta >FG_CHAR_LUT_PTR,x
		lda |gs_colors+2,x
		sta >BG_CHAR_LUT_PTR+2,x
		sta >FG_CHAR_LUT_PTR+2,x
		dex
		dex
		dex
		dex
		bpl ]lp

		; Initalize the Color Buffer, so we have White Medium Blue

;		lda #$F6F6
;		ldx #$1FFE
;]lp
;		sta >CS_COLOR_MEM_PTR,x
;		dex
;		dex
;		bpl ]lp
		sep #$30
		lda #$F6        ; white on medium blue
		sta |CURCOLOR
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
		ext midi_oaxelf
		ext midi_axelf2
		ext midi_chess
		ext midi_canon

		; instruments
		ext inst_atmosphere,inst_polysynth,inst_acsnare,inst_ehorn,inst_synbass
		ext inst_strings,inst_cymbal,inst_celesta,inst_bassdrum,inst_sitar,inst_hightom
		ext inst_closehihat,inst_piano,inst_taiko,inst_contrabass,inst_synbrass,inst_snareroll
		ext inst_openhihat,inst_pedalhihat,inst_tambourine,inst_handclap,inst_syndrum,inst_slapbass

NumTracks = MF_NumTracks
Format    = MF_Format

		; Setup pointer to the new midi file
		lda #txt_oaxelf
		sta <pMidiName

		ldx #^midi_oaxelf
		lda #midi_oaxelf
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

:GoodFile

		jsl PrintMidiFileChunk

		ldx #:txt_HeaderGood
		jsr myPUTS

		ldx #txt_Format
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

		ldx #txt_NumTracks
		jsr myPUTS
		lda <NumTracks
		jsr myPrintAI
		jsr myPRINTCR

		ldy #MThd_Division
		lda [pMidiFile],y
		xba
		sta <MF_Division

		ldx #txt_division
		jsr myPUTS

		lda <MF_Division
		jsr myPRINTAH
		jsr myPRINTCR

		lda <MF_Division
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
		asl
		tax
		lda <pMidiFile		; current track pointer
		adc #MTrk_sizeof    ; size of the chunk header
		sta |MidiDP,x     	; Array of track pointers
		lda <pMidiFile+2
		adc #0
		sta |MidiDP+2,x

		; fetch out the length too
		ldy #MTrk_Length+2
		lda [pMidiFile],y
		xba
		sta |MidiDP+4,x
		ldy #MTrk_Length
		lda [pMidiFile],y
		xba
		sta |MidiDP+6,x

		pla
		inc
		cmp <NumTracks
		bcc ]loop

;------------------------------------------------------------------------------

;		lda #$2020
;		ldy #$1010
;		ldx #:TestTitle
;		jsr DrawBox
;
;]lp		bra ]lp
;
;:TestTitle asc 'Test Title'
;		db 0

		jsr DrawFancyScreen

;-----------------------------------------------------------------------------
; start weirdness
; Init the Tracks for play

		jsr InitTrackPointers

;-----------------------------------------------------------------------------
; Do some testing of registers
		do 0
		phd
		pea 0
		pld
		jsl CLRSCREEN ; because the data in the screen is messed up
		ldx #0
		txy
		jsl LOCATE	    ; cursor to top left of the screen

		pea $0100
		pld

		lda #$0080
		sta <ADDER32_A_LL
		sta <UNSIGNED_MULT_A_LO
		stz <ADDER32_A_HL

		stz <UNSIGNED_MULT_B_LO

		stz <ADDER32_B_LL
		stz <ADDER32_B_HL

		lda <ADDER32_A_HL
		jsr myPRINTAH
		lda <ADDER32_A_LL
		jsr myPRINTAH
		jsr myPRINTCR

;		lda <UNSIGNED_MULT_A_HI
;		jsr myPRINTAH
;		lda <UNSIGNED_MULT_A_LO
;		jsr myPRINTAH
;		jsr myPRINTCR


]loop
		lda 1,s
		tcd

		jsr WaitVBL

		pea $0100
		pld

		ldx #0
		ldy #2
		jsr myLOCATE

		lda <ADDER32_R_HL
		jsr myPRINTAH
		lda <ADDER32_R_LL
		jsr myPRINTAH
		jsr myPRINTCR

		lda <ADDER32_R_LL
		ldx <ADDER32_R_HL

		sta <ADDER32_B_LL
		stx <ADDER32_B_HL

		lda <UNSIGNED_MULT_B_LO
		inc
		inc
		sta <UNSIGNED_MULT_B_LO

		sep #$30
		lda |CURCOLOR
		pha
		rep #$30

		lda <UNSIGNED_MULT_AL_LO
		and #$100
		beq :good

		sep #$30
		lda #$F1
		sta |CURCOLOR
		rep #$30

:good
		lda <UNSIGNED_MULT_AH_LO
		jsr myPRINTAH
		lda <UNSIGNED_MULT_AL_LO
		jsr myPRINTAH
		jsr myPRINTCR

		sep #$30
		pla
		sta |CURCOLOR
		rep #$30

		bra ]loop

		fin

;-----------------------------------------------------------------------------
; Text Code to dump an instrument

		do 0
		ldy #0
]loop	phy
		phd
		pea 0
		pld
		jsl CLRSCREEN ; because the data in the screen is messed up
		ldx #0
		txy
		jsl LOCATE	    ; cursor to top left of the screen
		pld

		ply

		lda |GlobalInstruments,y
		bne :good
		ldx |GlobalInstruments+2,y
		beq :done
:good
		ldx |GlobalInstruments+2,y
		phy

		jsr DumpInstrument

]wait_space
		jsr DebugKeyboard

		lda |keyboard+$39
		and #$FF
		beq ]wait_space

		stz |keyboard+$39 ; clear the space

		ply
		iny
		iny
		iny
		iny
		bra ]loop
:done

]stop	bra ]stop
		fin


;-----------------------------------------------------------------------------
		; Collect data from the .wav files, and convert it into the internal
		; instrument format, in mixer.i.s
		jsr ProcessInstruments

		; Print out and Instrument Summary
		;jsr ShowInstrumentInfo

		do 1
again
		phd

		pea #$100
		pld

		ldx #0
		txy
		jsr myLOCATE

		lda #$100
		sta <SIGNED_MULT_A_LO
:volume = $80
]loop
		stz <:volume
]in
		pld
		phd
		;jsr WaitVBL
		pea #$100
		pld

		lda |CURSORY
		cmp #73
		bcc :fine
		ldx #0
		txy
		jsr myLOCATE
:fine

		lda <:volume
		xba
		ora <:volume
		sta <SIGNED_MULT_B_LO

		lda <SIGNED_MULT_A_LO
		jsr myPRINTAH
		lda #'x'
		jsr myPUTC

		lda <SIGNED_MULT_B_LO
		jsr myPRINTAH

		lda #'='
		jsr myPUTC

		lda <SIGNED_MULT_AL_HI
		cmp #$8000
		ror
		cmp #$8000
		ror
		cmp #$8000
		ror
		cmp #$8000
		ror
		jsr myPRINTAH

		jsr myPRINTCR

		lda <:volume
		inc
		sta <:volume
		cmp #$100
		bcc ]in

		dec <SIGNED_MULT_A_LO
		bpl ]loop

		pld

		jmp again

]stop   bra ]stop
		fin

;-----------------------------------------------------------------------------


		ldx #44
		ldy #8
		jsr DrawPiano

		do 0

		;ldx #$A5 ; light grey, dark gray
		;lda #22
		;jsr ColorKey
		;ldx #$A5 ; light grey, dark gray
		;lda #23
		;jsr ColorKey

		lda #0
]weird
		pha

		jsr WaitVBL
		jsr DebugKeyboard
		jsr WaitVBL
		jsr DebugKeyboard
		jsr WaitVBL
		jsr DebugKeyboard
		jsr WaitVBL
		jsr DebugKeyboard
		lda 1,s
;		ldx #$A5
		ldx #$95
		jsr ColorKey

		jsr WaitVBL
		jsr DebugKeyboard
		jsr WaitVBL
		jsr DebugKeyboard
		jsr WaitVBL
		jsr DebugKeyboard
		jsr WaitVBL
		jsr DebugKeyboard
		lda 1,s
		ldx #$0F
		jsr ColorKey

		pla
		inc
		and #$7F
		bra ]weird
		fin

;-----------------------------------------------------------------------------
; Test Code to dump a track out
		do 0
		phd
		pea 0
		pld
		jsl CLRSCREEN ; because the data in the screen is messed up
		ldx #0
		txy
		jsl LOCATE	    ; cursor to top left of the screen
		pld

		lda #0
		jsr DumpTrack
		fin

;testwait bra testwait
;-----------------------------------------------------------------------------

;]done bra ]done

PlayLoop
; Take Time Elapsed, and process each track
		jsr WaitMidiTimer

		lda #15	; Elapsed time (192*4/50)
		jsr UpdateTracks
		jsr DrawBoxTimes

]lp
		jsr WaitVBL
		jsr DebugKeyboard
		jsr UpdatePianoKeys

; View the keyboard buffer
;		ldx #0
;		ldy #16
;		jsr myLOCATE
;
;		ldx #0
;]debug	lda |keyboard,x
;		xba
;		phx
;		jsr myPRINTAH
;		plx
;		inx
;		inx
;		cpx #48
;		bcc ]debug 

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
; WaitMidiTimer
; Preserve all registers
;
WaitMidiTimer
		pha
		lda <dpAudioJiffy
]lp
		cmp <dpAudioJiffy
		beq ]lp
		pla
		rts

;------------------------------------------------------------------------------
InitTextMode mx %00

		phd
		lda #0
		tcd

		; Fuck, make the text readable
		;dec  ; A = 0xFFFF
		;sta >$AF1F78
		;sta >$AF1F79

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
myPRINTBYTE mx %00
		; Kernel function doesn't work

		sep #$30
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
		rep #$30

		ldx #:temp
		jmp myPUTS

:chars  ASC '0123456789ABCDEF'

:temp	ds  3


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
gs_colors
	adrl $ff000000  ;0 Black
	adrl $ffdd0033	;1 Deep Red
	adrl $ff000099	;2 Dark Blue
	adrl $ffdd22dd	;3 Purple
	adrl $ff007722	;4 Dark Green
	adrl $ff555555	;5 Dark Gray
	adrl $ff2222ff	;6 Medium Blue
	adrl $ff66aaff	;7 Light Blue
	adrl $ff885500	;8 Brown
	adrl $ffff6600	;9 Orange
	adrl $ffaaaaaa	;A Light Gray
	adrl $ffff9988	;B Pink
	adrl $ff00dd00	;C Light Green
	adrl $ffffff00	;D Yellow
	adrl $ff55ff99	;E Aquamarine
	adrl $ffffffff	;F White
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

;------------------------------------------------------------------------------
DrawFancyScreen mx %00

		phd
		pea #0
		pld
		jsl CLRSCREEN

		ldx #0
		txy
		jsl LOCATE

		pld

:columns = 100
:rows    = 75
:buffer = GlobalTemp

; top bar

		lda #MT_RIGHT_BAR
		sta |:buffer
		lda #MT_LEFT_BAR
		sta |:buffer+:columns-1
		stz |:buffer+:columns

		lda #MT_4BAR
		sta |:buffer+1

		lda #:columns-4
		ldx #:buffer+1
		ldy #:buffer+2
		mvn ^:buffer,^:buffer

		sep #$30

		lda #' '
		sta |:buffer+1
		lda #MT_RUN1
		sta |:buffer+2
		lda #MT_RUN2
		sta |:buffer+3
		lda #' '
		sta |:buffer+4

		rep #$30

		ldx #:buffer
		jsr myPUTS

; Bottom Bar
		ldx #1
		ldy #:rows-1
		jsr myLOCATE

		lda #MT_UP_BAR
		sta |:buffer

		lda #:columns-4
		ldx #:buffer
		txy
		iny
		mvn ^:buffer,^:buffer
		stz |:buffer+:columns-2

		ldx #|:buffer
		jsr myPUTS
; re-enforce top bar
		ldx #1
		ldy #1
		jsr myLOCATE
		ldx #|:buffer
		jsr myPUTS

; Divider for the "Top

		ldx #1
		ldy #17
		jsr myLOCATE
		ldx #|:buffer
		jsr myPUTS

; Left
		ldy #1
]lp
		phy
		ldx #0
		jsr myLOCATE

		lda #MT_RIGHT_BAR
		jsr myPUTC
		ply
		iny
		cpy #:rows-1
		bcc ]lp

; Right
		ldy #1
]lp
		phy
		ldx #:columns-1
		jsr myLOCATE

		lda #MT_LEFT_BAR
		jsr myPUTC
		ply
		iny
		cpy #:rows-1
		bcc ]lp

; Title
		ldx #5
		ldy #0
		jsr myLOCATE

		ldx #:Text
		jsr myPUTS

; Song Name

		ldx #6
		ldy #2
		jsr myLOCATE
		ldx #txt_song
		jsr myPUTS

		ldx <pMidiName
		jsr myPUTS

; Format
		ldx #4
		ldy #4
		jsr myLOCATE
		ldx #txt_Format
		jsr myPUTS
		lda <MF_Format
		jsr myPrintAI
; Division

		ldx #2
		ldy #6
		jsr myLOCATE
		ldx #txt_division
		jsr myPUTS
		lda <MF_Division
		jsr myPrintAI
; Tracks
		ldx #4
		ldy #8
		jsr myLOCATE
		ldx #txt_NumTracks
		jsr myPUTS
		lda <MF_NumTracks
		jsr myPrintAI

; For Each Track draw a box

:x = temp3
:y = temp3+2
:column = temp4
:row    = temp4+2
:count = temp5
:bcd_track = temp5+2

		;lda #25
		;sta <MF_NumTracks

		lda #1
		sta <:bcd_track

		lda #'1 '
		sta |:track_no+6

		stz <:column
		stz <:row
		stz <:count

		; Start here
		lda #2
		sta <:x
		lda #18
		sta <:y

]box_loop
		lda <:column
		asl
		asl 		 ; x4
		pha
		asl 		 ; x8
		adc 1,s		 ; x12
		adc <:x 	 ; +x
		sta 1,s

		lda <:row
		asl
		asl 	 	; x4
		pha
		asl 		; x8
		adc 1,s 	; x12
		adc <:row   ; x13
		adc <:row   ; x14
		adc <:y 	; +y
		sta 1,s

		pla
		xba
		ora 1,s
		sta 1,s
		pla

		ldy #$0A0C
		ldx #:track_no
		jsr DrawBox

; inc track_no
		sep #$38
		clc
		lda <:bcd_track
		adc #1
		sta <:bcd_track
		cld

		cmp #$10
		bcc :single_digit

		and #$F
		tax
		lda |:text09,x
		sta |:track_no+7

		lda <:bcd_track
		lsr
		lsr
		lsr
		lsr
:single_digit
		tax
		lda :text09,x
		sta |:track_no+6
		rep #$30

; inc column
		lda <:column
		inc
		cmp #8
		bcc :col_good
		inc <:row
		lda #0
:col_good
		sta <:column

		lda <:count
		inc
		cmp <MF_NumTracks
		bcs :done
		sta <:count
		bra ]box_loop
:done
		rts
:Text   asc 'Jason',27,'s MIDI Mixer '
		db 0
:track_no asc 'Track   '
		db 0
:text09 asc '0123456789'

;------------------------------------------------------------------------------
;
; A = Box #
;
LocateTextBox mx %00
:row = temp0
:column = temp0+2
:x = temp1
:y = temp1+2

		pha
		lsr
		lsr
		lsr
		sta <:row
		pla
		and #$7
		sta <:column

		lda #2+1   ; offset to inside the box
		sta <:x
		lda #18+3  ; offset to inside the box
		sta <:y

; X
		lda <:column
		asl
		asl 		 ; x4
		pha
		asl 		 ; x8
		adc 1,s		 ; x12
		adc <:x 	 ; +x
		sta 1,s
		pla
		sta <:x

; Y
		lda <:row
		asl
		asl 	 	; x4
		pha
		asl 		; x8
		adc 1,s 	; x12
		adc <:row   ; x13
		adc <:row   ; x14
		adc <:y 	; +y
		sta 1,s
		pla
		sta <:y

		ldx <:x
		ldy <:y
		jsr myLOCATE

		rts

;------------------------------------------------------------------------------
;
DrawBoxTimes mx %00

:x = temp1
:y = temp1+2

:end_addy = temp2
:delta = temp3

		ldy #0
]loop
		phy
		tya
; Draw the Data Pointer
		jsr LocateTextBox
		inc <:x
		ldx <:x
		ldy <:y
		jsr myLOCATE

		lda 1,s
		asl
		asl
		asl
		tax
		phx

		lda |MidiEventDP+2,x
		jsr myPRINTAH

		plx
		phx

		lda |MidiEventDP,x
		jsr myPRINTAH

; Draw the Length Remaining
		plx
		phx

		; first calculate the delta
		lda |MidiDP,x
		clc
		adc |MidiDP+4,x
		sta <:end_addy
		lda |MidiDP+2,x
		adc |MidiDP+6,x
		sta <:end_addy+2

		sec
		lda <:end_addy
		sbc |MidiEventDP,x
		sta <:delta
		lda <:end_addy+2
		sbc |MidiEventDP+2,x
		sta <:delta+2
		 
		inc <:y
		ldx <:x
		ldy <:y
		jsr myLOCATE
		
		lda <:delta+2
		jsr myPRINTAH
		lda <:delta
		jsr myPRINTAH

; Draw the event wait time
		inc <:y
		ldx <:x
		ldy <:y
		jsr myLOCATE

		plx
		phx

		lda |MidiEventDP+6,x
		jsr myPRINTAH
		plx
		lda |MidiEventDP+4,x
		jsr myPRINTAH

		ply
		iny
		cpy <MF_NumTracks
		bcc ]loop

		rts
;------------------------------------------------------------------------------
ReadVLQ mx %00
:v0 = temp9
:v1 = temp9+2
:v2 = temp10
:v3 = temp10+2

		stz <VLQ
		stz <VLQ+2

		jsr ReadByte
		bit #$80
		beq :oneandone

		and #$7F
		sta <:v3

		jsr ReadByte
		bit #$80
		beq :twoandone

		and #$7f
		sta <:v2

		jsr ReadByte
		bit #$80
		beq :threeandone
		and #$7F
		sta <:v1

		jsr ReadByte
		sta <VLQ

		lda <:v1-1
		lsr
		tsb <VLQ+1
		lda <:v2-1
		lsr
		lsr
		tsb <VLQ+1
		lda <:v3-1
		lsr
		lsr
		lsr
		tsb <VLQ+2
		rts

:threeandone
		lsr <:v3-1
		lsr <:v3-1
		lsr <:v2-1
		ora <:v2-1
		sta <VLQ
		lda <:v3-1
		tsb <VLQ+1
		rts

:twoandone
		lsr <:v3-1
		and #$7F
		ora <:v3-1
		sta <VLQ
		rts

:oneandone
		sta <VLQ
		rts

;------------------------------------------------------------------------------

ReadByte mx %00
		lda [pTrack]
		and #$FF
		inc <pTrack
		bne :done
		inc <pTrack+2
:done
		rts

;------------------------------------------------------------------------------
;
UpdateTrack mx %00

:row = temp0
:col = temp0+1
:x = temp1
:y = temp1+2

:elapsedTime = temp1

		sta <:elapsedTime

		tya
		phy
		jsr LocateTextBox

		clc
		lda <:y
		adc #3
		sta <:y

		ldx <:x
		ldy <:y
		jsr myLOCATE

		ply
		tya

		asl
		asl
		asl
		tax

; update the elapsed time

		sec
		lda |MidiEventDP+4,x
		sbc <:elapsedTime
		sta |MidiEventDP+4,x
		lda |MidiEventDP+6,x
		sbc #0
		sta |MidiEventDP+6,x
		bpl :done

; Elapsed Time is now negative
		; get the track pointer
		lda |MidiEventDP,x
		sta <pTrack
		lda |MidiEventDP+2,x
		sta <pTrack+2

		jsr ReadVLQ

		; add the VLQ to the current elapsed time, carry overfloat
		clc
		lda <VLQ
		adc |MidiEventDP+4,x
		sta |MidiEventDP+4,x
		lda <VLQ+2
		adc |MidiEventDP+6,x
		sta |MidiEventDP+6,x

		; Read the event
		;pei pTrack
		;pei pTrack+2

		phx
		jsr ReadEvent



		plx

		; save back the track pointer
		lda <pTrack
		sta |MidiEventDP,x
		lda <pTrack+2
		sta |MidiEventDP+2,x
:done



		rts


;------------------------------------------------------------------------------
ReadEvent mx %00

:row = temp0
:col = temp0+1
:x = temp1
:y = temp1+2

:event   = temp11
:channel = temp11+2
:keynum   = temp4
:velocity = temp4+2
:connum   = temp4
:polyval  = temp4+2
:conval   = temp4+2
:prognum  = temp4
:chanval  = temp4
:plow     = temp4
:phigh    = temp4+2
:meta_type = temp4



		jsr ReadByte
		sta <:event

		and #$0F
		sta <:channel

		lda <:event
		and #$F0

		lsr
		lsr
		lsr

		tax
		jmp (:table,x)

:table
		da :unknown
		da :unknown
		da :unknown
		da :unknown
		da :unknown
		da :unknown
		da :unknown
		da :unknown
		da :note_off	; 0x80
		da :note_on 	; 0x90
		da :polypress   ; 0xA0
		da :control     ; 0xB0
		da :program     ; 0xC0
		da :chanpress   ; 0xD0
		da :pitchbend   ; 0xE0
		da :sysx		; 0xF0

:unknown
		ldx #txt_UNKNOWN
		jsr myPUTS
]stop	bra ]stop

:note_off
		ldx #txt_NOTEOFF
		jsr myPUTS

		jsr ReadByte
		sta <:keynum
		jsr ReadByte
		sta <:velocity
		rts
:note_on
		ldx #txt_NOTEON
		jsr myPUTS

		jsr ReadByte
		sta <:keynum
		jsr ReadByte
		sta <:velocity
		rts
:polypress
		ldx #txt_POLYPRESS
		jsr myPUTS

		jsr ReadByte
		sta <:keynum
		jsr ReadByte
		sta <:velocity
		rts
:control
		ldx #txt_CONTROL
		jsr myPUTS

		jsr ReadByte
		sta <:keynum
		jsr ReadByte
		sta <:velocity
		rts
:program
		ldx #txt_PROGRAM
		jsr myPUTS

		jsr ReadByte
		sta <:prognum
		rts

:chanpress
		ldx #txt_CHANPRESS
		jsr myPUTS

		jsr ReadByte
		sta <:chanval
		rts

:pitchbend
		ldx #txt_PITCHBEND
		jsr myPUTS

		jsr ReadByte
		sta <:plow
		jsr ReadByte
		sta <:phigh
		rts
:sysx
		lda <:event
		cmp #$FF
		beq :meta

		bra :sysx
:meta
		ldx #txt_META
		jsr myPUTS

		jsr ReadByte
		sta <:meta_type
		jsr ReadVLQ

		clc
		lda <pTrack
		adc <VLQ
		sta <pTrack
		lda <pTrack+2
		adc <VLQ+2
		sta <pTrack+2
		rts


;------------------------------------------------------------------------------
; A = elapsed time in ticks
UpdateTracks mx %00

:elapsedtime = temp8

		sta <:elapsedtime

		ldy #0
]lp
		lda <:elapsedtime
		phy
		jsr UpdateTrack
		ply
		iny
		cpy <MF_NumTracks
		bcc ]lp

		rts
;------------------------------------------------------------------------------

txt_song  cstr 'Song: '
txt_NumTracks cstr 'Tracks: '
txt_Format cstr 'Format: '
txt_division cstr 'Division: '
txt_oaxelf cstr  'Old Axel-F'
txt_axelF cstr   'Axel-F    '
txt_axelF2 cstr  'Axel-F 2  '
txt_chess cstr   'Chess     '
txt_canon cstr   'Canon     '

; Midi Event Texts
txt_NOTEON    cstr '  NOTEON  '
txt_NOTEOFF   cstr ' NOTEOFF  '
txt_POLYPRESS cstr 'POLYPRESS '
txt_CONTROL   cstr ' CONTROL  '
txt_PROGRAM   cstr ' PROGRAM  '
txt_CHANPRESS cstr 'CHANPRESS '
txt_PITCHBEND cstr 'PITCHBEND '
txt_SYSEX1    cstr ' SYSEX1   '
txt_SYSEX2    cstr ' SYSEX2   '
txt_META      cstr '  META    '
txt_UNKNOWN   cstr 'UNKNOWN   '

;------------------------------------------------------------------------------
; A=Track number to dump
DumpTrack mx %00

		; Setup a pointer to the current track
		asl
		asl
		asl
		tax
		lda |MidiEventDP,x
		sta <pTrack
		lda |MidiEventDP+2,x
		sta <pTrack+2

]loop
		ldx #MyDP+pTrack
		jsr myPRINTAddress		; Current Address
		lda #':'
		jsr myPUTC

		jsr :PrintVLQ   		; VLQ Bytes at Address

		jsr ReadVLQ 			; Value extraced from VLQ bytes

		lda <VLQ+2
		jsr myPRINTAH
		lda <VLQ
		jsr myPRINTAH
		jsr myPRINTCR

;------------------------------------------------------------------------------

		ldx #MyDP+pTrack
		jsr myPRINTAddress		; Current Address

		lda #':'
		jsr myPUTC

		jsr ReadByte
		pha
		jsr myPRINTBYTE			; Event Byte
		lda #' '
		jsr myPUTC
		
		lda 1,s
		jsr :PrintEventText

		; we need to eat the right number of bytes here to continue
		lda 1,s
		and #$F0
		lsr
		lsr
		lsr
		tax
		pla
		jsr (:events,x)
		bra ]loop

:events
		da :unknown
		da :unknown
		da :unknown
		da :unknown
		da :unknown
		da :unknown
		da :unknown
		da :unknown
		da :note_off	; 0x80
		da :note_on 	; 0x90
		da :polypress   ; 0xA0
		da :control     ; 0xB0
		da :program     ; 0xC0
		da :chanpress   ; 0xD0
		da :pitchbend   ; 0xE0
		da :sysx		; 0xF0

:unknown
]stop	bra ]stop

:note_off
:note_on
		jsr ReadByte   ; key
		jsr myPRINTBYTE
		lda #' '
		jsr myPUTC

		jsr ReadByte  ; velocity
		jsr myPRINTBYTE
		jsr myPRINTCR
		rts

:polypress
		jsr ReadByte  ; key
		jsr myPRINTBYTE
		lda #' '
		jsr myPUTC
		jsr ReadByte  ; poly value
		jsr myPRINTBYTE
		jsr myPRINTCR
		rts

:control
		jsr ReadByte   ; control num
		jsr myPRINTBYTE
		lda #' '
		jsr myPUTC

		jsr ReadByte  ; control value
		jsr myPRINTBYTE
		jsr myPRINTCR
		rts

:program
		jsr ReadByte ; program num
		jsr myPRINTBYTE
		jsr myPRINTCR
		rts

:chanpress
		jsr ReadByte ; channel press
		jsr myPRINTBYTE
		jsr myPRINTCR
		rts

:pitchbend
		jsr ReadByte  ; pitch bend low
		jsr myPRINTBYTE
		lda #' '
		jsr myPUTC
		jsr ReadByte  ; pitch bend high
		jsr myPRINTBYTE
		jsr myPRINTCR
		rts
:sysx
		cmp #$FF
		beq :meta

		bra :sysx
:meta
		jsr ReadByte    ; meta type
		pha
		jsr myPRINTBYTE
		lda #' '
		jsr myPUTC

		jsr :PrintVLQ
		jsr ReadVLQ

		lda <VLQ+2
		jsr myPRINTAH
		lda <VLQ
		jsr myPRINTAH
		jsr myPRINTCR

		clc
		lda <pTrack
		adc <VLQ
		sta <pTrack
		lda <pTrack+2
		adc <VLQ+2
		sta <pTrack+2

		pla
		cmp #$2F ; end of track
		bne :cont
		pla      ; break out of loop
:cont
		rts


:PrintEventText
		and #$F0
		lsr
		lsr
		lsr
		tax
		lda |:ttable,x
		tax
		jsr myPUTS
		rts

:ttable
		da txt_UNKNOWN
		da txt_UNKNOWN
		da txt_UNKNOWN
		da txt_UNKNOWN

		da txt_UNKNOWN
		da txt_UNKNOWN
		da txt_UNKNOWN
		da txt_UNKNOWN

		da txt_NOTEOFF
		da txt_NOTEON
		da txt_POLYPRESS
		da txt_CONTROL

		da txt_PROGRAM
		da txt_CHANPRESS
		da txt_PITCHBEND
		da txt_META


:PrintVLQ

		pei <pTrack
		pei <pTrack+2
]vlqlp
		jsr ReadByte
		pha
		jsr myPRINTBYTE
		lda #' '
		jsr myPUTC
		pla
		bit #$80
		bne ]vlqlp

:VLQ_done
		pla
		sta <pTrack+2
		pla
		sta <pTrack

		rts

txt_invalid_wave cstr 'Invalid WAVE file'
txt_length cstr 'Length='
txt_toolarge cstr 'Wave is too large, must be < 64K'
txt_wavefmt cstr 'WAVEfmt'
txt_type cstr           '            Type='
txt_channels cstr       '        Channels='
txt_samplerate cstr     '      SampleRate='
txt_bytespersample cstr 'Bytes Per Sample='
txt_bitspersample  cstr ' Bits Per Sample='
txt_missingdatablock cstr '!!ERROR - data block is missing'
txt_data_found cstr 'data block found'
txt_missingsample cstr '!!ERROR - sample block is missing'
txt_samplefound cstr 'smpl - block found!'
txt_missingxtra cstr '!!ERROR - xtra block is missing'
txt_xtrafound cstr 'xtra - block found!'
txt_pitch_keycenter cstr 'Pitch Key Center='
txt_loop_mode       cstr '      Loop Mode ='
txt_loop_start      cstr '      Loop Start='
txt_loop_end        cstr '      Loop End  ='
txt_cue_missing     cstr '!!ERROR - cue block is missing'
txt_cue_found       cstr 'cue - block found'
txt_cset_missing    cstr '!!ERROR - CSET block is missing'
txt_list_missing    cstr '!!ERROR - LIST block is missing'
txt_missingname cstr '!!ERROR - Missing INFOINAME/Instrument name'
txt_instname    cstr 'Instrument Name='
txt_loop   cstr 'LOOP   '
txt_single cstr 'SINGLE '



;------------------------------------------------------------------------------
; AX = pInstrument
;
DumpInstrument mx %00
:pInstrument = temp0
:length = temp1

		sta <:pInstrument
		stx <:pInstrument+2

		lda [:pInstrument]
		cmp #'RI'
		beq :good0
:invalid_wave
		ldx #txt_invalid_wave
:too_large
		jsr myPUTS
		rts
:good0
		ldy #2
		lda [:pInstrument],y
		cmp #'FF'
		bne :invalid_wave

		ldy #4
		lda [:pInstrument],y
		sta <:length
		ldy #6
		lda [:pInstrument],y
		sta <:length+2

		ldx #txt_length
		jsr myPUTS
		lda <:length+2
		jsr myPRINTAH
		lda <:length
		jsr myPRINTAH
		jsr myPRINTCR

		ldx #txt_toolarge
		lda <:length+2
		bne :too_large

; So far so good

; next block, I expect 8 bytes, 'WAVEfmt '
		; skip forward
		clc
		lda <:pInstrument
		adc #8
		sta <:pInstrument
		lda <:pInstrument+2
		adc #0
		sta <:pInstrument+2


		jsr :get_word
		cmp #'WA'
		bne :invalid_wave
		jsr :get_word
		cmp #'VE'
		bne :invalid_wave
		jsr :get_word
		cmp #'fm'
		bne :invalid_wave
		jsr :get_word
		cmp #'t '
		bne :invalid_wave

		ldx #txt_wavefmt
		jsr myPUTS
		jsr myPRINTCR

		ldx #txt_length
		jsr myPUTS

		; output length of WAVEfmt block, should be 16
		jsr :get_word
		pha
		jsr :get_word
		jsr myPRINTAH
		pla
		jsr myPRINTAH
		jsr myPRINTCR

		; type, 1 = PCM
		ldx #txt_type
		jsr myPUTS
		jsr :get_word
		jsr myPRINTAH
		jsr myPRINTCR

		; channels - needs to be 1
		ldx #txt_channels
		jsr myPUTS
		jsr :get_word
		jsr myPRINTAH
		jsr myPRINTCR

		ldx #txt_samplerate
		jsr myPUTS
		jsr :get_word
		jsr myPrintAI
		jsr myPRINTCR
		jsr :get_word  ; high part of sample rate

		jsr :get_word  ; sample rate * bits ber sample * channels / 8
		jsr :get_word

		ldx #txt_bytespersample
		jsr myPUTS
		jsr :get_word
		jsr myPrintAI
		jsr myPRINTCR

		ldx #txt_bitspersample
		jsr myPUTS
		jsr :get_word
		jsr myPrintAI
		jsr myPRINTCR

		; I expect 'data' to be next
		; this is out actual wave!
		jsr :get_word
		cmp #'da'
		beq :good2
:missing
		ldx #txt_missingdatablock
		jsr myPUTS

:good2
		jsr :get_word
		cmp #'ta'
		bne :missing

		ldx #txt_data_found
		jsr myPUTS
		jsr myPRINTCR

		jsr :get_word
		sta <:length
		jsr :get_word
		sta <:length+2

		ldx #txt_length
		jsr myPUTS
		lda <:length+2
		jsr myPRINTAH
		lda <:length
		jsr myPRINTAH
		jsr myPRINTCR

		clc
		lda <:pInstrument
		adc <:length
		sta <:pInstrument
		lda <:pInstrument+2
		adc <:length+2
		sta <:pInstrument+2

		jsr :get_word
		cmp #'sm'
		beq :good3
:nosample
		jsr :put_word
		ldx #txt_missingsample
		jsr myPUTS
		jsr myPRINTCR

		jmp :next_block
:good3
		jsr :get_word
		cmp #'pl'
		beq :goodgood

		jsr :put_word
		bra :nosample
:goodgood
		ldx #txt_samplefound
		jsr myPUTS
		jsr myPRINTCR

		jsr :get_word ; 3C
		jsr :get_word ; 00

		pei :pInstrument
		pei :pInstrument+2

; extra important instrument info here

		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??

		ldx #txt_pitch_keycenter
		jsr myPUTS
		jsr :get_word
		jsr myPrintAI
		jsr myPRINTCR
		jsr :get_word ; ??

		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??

		ldx #txt_loop_mode
		jsr myPUTS
		jsr :get_word ; loop type or mode?
		jsr myPrintAI
		jsr myPRINTCR
		jsr :get_word ; ??

		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??

		ldx #txt_loop_start
		jsr myPUTS
		jsr :get_word 	; loop start low
		jsr myPrintAI
		jsr myPRINTCR
		jsr :get_word   ; loop start high

		ldx #txt_loop_end
		jsr myPUTS
		jsr :get_word 	; loop end low
		jsr myPrintAI
		jsr myPRINTCR
		jsr :get_word   ; loop end high

		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??

		pla
		sta <:pInstrument+2
		pla
		sta <:pInstrument
		clc
		adc #$3C
		sta <:pInstrument
		lda <:pInstrument+2
		adc #0
		sta <:pInstrument+2

		; xtra expected next
:next_block
		jsr :get_word
		cmp #'xt'
		beq :good4
:noextra
		ldx #txt_missingxtra
		jsr myPUTS
		jsr myPRINTCR
		rts
:good4
		jsr :get_word
		cmp #'ra'
		bne :noextra

		ldx #txt_xtrafound
		jsr myPUTS
		jsr myPRINTCR

		jsr :skip_block

		; 'cue ' next
		jsr :get_word
		cmp #'cu'
		beq :good5
:nocue
		ldx #txt_cue_missing
		jsr myPUTS
		rts
:good5
		jsr :get_word
		cmp #'e '
		bne :nocue
		ldx #txt_cue_found
		jsr myPUTS
		jsr myPRINTCR

		jsr :skip_block

		; 'CSET' next
		jsr :get_word
		cmp #'CS'
		beq :good6
:noCSET
		ldx #txt_cset_missing
		jsr myPUTS
		rts
:good6
		jsr :get_word
		cmp #'ET'
		bne :noCSET

		jsr :skip_block

		; 'LIST' next
		jsr :get_word
		cmp #'LI'
		beq :good7
:nolist
		ldx #txt_list_missing
		jsr myPUTS
		rts
:good7
		jsr :get_word
		cmp #'ST'
		bne :nolist

; at this point I'm just interesting the instrument name

		jsr :get_word ; list size
		jsr :get_word

; looking for INFOINAM - info instrument name

		jsr :get_word
		cmp #'IN'
		beq :good8
:missingname
		ldx #txt_missingname
		jsr myPUTS
		rts
:good8
		jsr :get_word
		cmp #'FO'
		bne :missingname

		jsr :get_word
		cmp #'IN'
		bne :missingname

		jsr :get_word
		cmp #'AM'
		bne :missingname

		jsr :get_word 	; length of the name
		jsr :get_word

		; now pInstrument is pointing a the name
		sep #$20
		ldx #$FFFF
		txy
]lp
		inx
		iny
		lda [:pInstrument],y
		sta |GlobalTemp,x
		bne ]lp

		rep #$30

		ldx #txt_instname
		jsr myPUTS

		ldx #GlobalTemp
		jsr myPUTS

		jsr myPRINTCR

		rts

:put_word
		dec <:pInstrument
		dec <:pInstrument
		rts

:get_word
		lda [:pInstrument]
		inc <:pInstrument
		inc <:pInstrument
		rts

:skip_block
		jsr :get_word ; 16
		pha
		jsr :get_word
		tax
		clc
		pla
		adc <:pInstrument
		sta <:pInstrument
		txa
		adc <:pInstrument+2
		sta <:pInstrument+2
		rts


;------------------------------------------------------------------------------
myPRINTAddress mx %00
		phx
		lda #'$'
		jsr myPUTC
		plx
		phx
		lda |2,x
		jsr myPRINTBYTE
		plx
		lda |0,x
		jsr myPRINTAH

		rts

;------------------------------------------------------------------------------

GlobalSongTable
		adrl midi_oaxelf
		adrl midi_axelf
		adrl midi_axelf2
		adrl midi_chess
		adrl midi_canon

GlobalSongNameTable
		da txt_oaxelf
		da txt_axelF
		da txt_axelF2
		da txt_chess
		da txt_canon

GlobalInstruments
		adrl inst_atmosphere,inst_polysynth,inst_acsnare,inst_ehorn,inst_synbass
		adrl inst_strings,inst_cymbal,inst_celesta,inst_bassdrum,inst_sitar,inst_hightom
		adrl inst_closehihat,inst_piano,inst_taiko,inst_contrabass,inst_synbrass,inst_snareroll
		adrl inst_openhihat,inst_pedalhihat,inst_tambourine,inst_handclap,inst_syndrum,inst_slapbass
		adrl 0

;------------------------------------------------------------------------------
ColorKey mx %00
:pColor = temp0
:key    = temp1
:fg     = temp2
:bg     = temp2+2

		cmp #21
		bcs :ok1
		rts			; invalid range
:ok1
		cmp #109
		bcc :ok2
		rts         ; invalid range
:ok2
		sec
		sbc #21
		sta <:key   ; save this

		txa
		and #$F0
		sta <:fg
		txa
		and #$0F
		sta <:bg

		lda |CURSORX
		pha
		lda |CURSORY
		pha

		ldx <KBX
		ldy <KBY
		jsr myLOCATE

		lda |COLORPOS
		sta <:pColor
		lda |COLORPOS+2
		sta <:pColor+2

		ldx <:key
		lda |:column,x
		and #$FF
		clc
		adc <:pColor
		sta <:pColor

		lda |key_height_table,x
		and #$FF
		tax
		cmp #5
		bcs :normal
		; sharps
]lp
		jsr :grayfg
		dex
		bne ]lp
		bra :done


:normal
		jsr :graybg
		dex
		bne :normal
:done
		ply
		plx
		jsr myLOCATE

		rts

:grayfg
		sep #$20
		lda [:pColor]
		and #$0F
		ora <:fg ; light grey
		sta [:pColor]
		rep #$31
		lda <:pColor
		adc #100
		sta <:pColor
		rts

:graybg
		sep #$20
		lda [:pColor]
		and #$F0
		ora <:bg ; dark grey
		sta [:pColor]
		rep #$31
		lda <:pColor
		adc #100
		sta <:pColor
		rts


:column
		db 0,1,1
]var = 0
		lup 7
		db 2+]var,3+]var,3+]var,4+]var,4+]var,5+]var,6+]var,6+]var,7+]var,7+]var,8+]var,8+]var
]var = ]var+7
		--^
		db 2+49
		
key_height_table
		db 6,4,6
		db 6,4,6,4,6,6,4,6,4,6,4,6
		db 6,4,6,4,6,6,4,6,4,6,4,6
		db 6,4,6,4,6,6,4,6,4,6,4,6
		db 6,4,6,4,6,6,4,6,4,6,4,6
		db 6,4,6,4,6,6,4,6,4,6,4,6
		db 6,4,6,4,6,6,4,6,4,6,4,6
		db 6,4,6,4,6,6,4,6,4,6,4,6
		db 6

;------------------------------------------------------------------------------
; Draw an 88 key keyboard, with mouse text?
;
KEYS equ 52
DrawPiano mx %00

		stx <KBX
		sty <KBY

:x = temp0
:y = temp0+2

		stx <:x
		sty <:y
		jsr myLOCATE

; Draw the Top of the keyboard

;		lda #'__'
;		ldx #KEYS-2
;]lp     sta |GlobalTemp,x
;		dex
;		dex
;		bpl ]lp

;		stz |GlobalTemp+KEYS

;		ldx #GlobalTemp
;		jsr myPUTS
;		inc <:y

		; Take the keybord to be white on black
		sep #$30
		lda |CURCOLOR
		pha
		lda #$0F  ; black on white
		sta |CURCOLOR
		rep #$30


; Draw a Row with Sharps
		jsr :locate
		jsr :fill_left_bars
		jsr :fill_sharps
		ldx #GlobalTemp
		jsr myPUTS
		inc <:y
		jsr :locate
		ldx #GlobalTemp
		jsr myPUTS
		inc <:y
		jsr :locate
		ldx #GlobalTemp
		jsr myPUTS
		inc <:y
		jsr :locate
		ldx #GlobalTemp
		jsr myPUTS

; Draw a native row, no sharps
		jsr :native_row
; another row
		jsr :locate
		ldx #GlobalTemp
		jsr myPUTS
		inc <:y

; Draw the Bottom of the keyboard

		jsr :locate

		lda #MT_LLCORNER+{MT_LLCORNER*256}
		ldx #KEYS-2
]lp     sta |GlobalTemp,x
		dex
		dex
		bpl ]lp

		;lda #MT_LEFT_BAR
		;sta |GlobalTemp+KEYS
		stz |GlobalTemp+KEYS

		ldx #GlobalTemp
		jsr myPUTS
		inc <:y

	    ; restore color
		sep #$30
		pla
		sta |CURCOLOR
		rep #$30

; Draw the C keys
		jsr :locate
		jsr :fill_c_keys
		ldx #|GlobalTemp
		jsr myPUTS
		inc <:y

; Draw the Octaves
		jsr :locate
		jsr :fill_octaves
		ldx #|GlobalTemp
		jsr myPUTS
		inc <:y

		rts

:native_row
		jsr :locate
		jsr :fill_left_bars
		inc <:y
		rts

:fill_left_bars
		lda #MT_LEFT_BAR+{MT_LEFT_BAR*256}
		ldx #KEYS-2
]lp     sta |GlobalTemp,x
		dex
		dex
		bpl ]lp

		;lda #MT_LEFT_BAR
		;sta |GlobalTemp+KEYS
		stz |GlobalTemp+KEYS
		rts

:locate
		ldx <:x
		ldy <:y
		jmp myLOCATE

:fill_sharps
		ldy #{KEYS/7}
		ldx #0
		txa
		sep #$20
		clc
]loop
		lda #MT_VBLOCK
		sta |GlobalTemp+1,x ;B1
		sta |GlobalTemp+3,x ;D1
		sta |GlobalTemp+4,x ;E1
		sta |GlobalTemp+6,x ;G1
		sta |GlobalTemp+7,x ;A2
		txa
		adc #7
		tax
		dey
		bne ]loop

		lda #MT_VBLOCK
		sta |GlobalTemp+1,x ;B8

		rep #$30
		rts
:fill_octaves
		jsr :fill_spaces

		ldy #{KEYS/7}+1
		ldx #0
		txa
		sep #$20
		clc
		lda #'0'
]loop
		inc
		sta |GlobalTemp+2,x ; C1
		pha
		txa
		adc #7
		tax
		pla
		dey
		bne ]loop

		rep #$30

		rts

:fill_c_keys
		jsr :fill_spaces

		ldy #{KEYS/7}+1
		ldx #0
		txa
		sep #$20
		clc
]clp
		lda #'c'
		sta |GlobalTemp+2,x ; C1
		txa
		adc #7
		tax
		dey
		bne ]clp

		rep #$30

		rts

:fill_spaces
		lda #'  '
		ldx #KEYS-2
]lp     sta |GlobalTemp,x
		dex
		dex
		bpl ]lp

		stz |GlobalTemp+KEYS
		rts


;------------------------------------------------------------------------------
;
; The status of up to 128 keys on the keyboard
;
keyboard ds 128
piano_keys ds 128

;------------------------------------------------------------------------------

DebugKeyboard mx %00
		phd
		pea 0
		pld

HISTORY_SIZE = 15

	; Collect Scancodes, but only when they change
	; place into a history buffer
	; print out the history buffer onto the screen
	; for the world to see
]key_loop
		jsl GETSCANCODE
		and #$FF
		beq :exit
		cmp |:last_code
		beq :exit       	; duplicate code, so ignore

		sta |:last_code		; last code, for the duplicate check

	; hack in the actual keyboard driver?

		sep #$30
		tay
		and #$7F
		tax
		tya
		bpl :keydown
		lda #$00  		; key-up
:keydown
		sta |keyboard,x
		
		tya
		rep #$30

	; done with the hack

		ldx |:index     	; current index
		sta |:history,x 	; save in history
		dex
		dex     		; next index
		bpl :continue
		ldx #{HISTORY_SIZE*2}-2 ; index wrap
:continue
		stx |:index     	; save index for next time

		bra ]key_loop

:exit
		pld

; print out the current history
		do 1
:x = temp0
:y = temp0+2

		ldx #97
		ldy #2
		stx <:x
		sty <:y

		ldy |:index
]loop
		phy
		ldx <:x
		ldy <:y
		jsr myLOCATE

		ply
		iny
		iny
		cpy #HISTORY_SIZE*2
		bcc :cont2
		ldy #0
:cont2
		cpy |:index
		beq :xit

		lda |:history,y
		phy
		jsr myPRINTBYTE
		ply
		inc <:y

		bra ]loop
:xit

		fin
		rts


:index		dw 0
:last_code	dw 0

:history	ds HISTORY_SIZE*2

;------------------------------------------------------------------------------

UpdatePianoKeys mx %00

;		$22 -> map to C4 -> 60/$3C
		ldy #$22-4
		ldx #60-4
		sep #$20
]loop1
		lda |keyboard,y
		cmp |piano_keys,x
		beq :next

		sta |piano_keys,x

		and #$ff
		beq :erase

		; Show
		phy
		phx

		rep #$30
		txa 	  ; key
		ldx #$95  ; colors
		jsr ColorKey
		sep #$20
		plx
		ply
		bra :next

:erase
		phy
		phx
		rep #$30
		txa
		ldx #$0F
		jsr ColorKey
		sep #$20
		plx
		ply
:next
		inx
		iny
		cpy #$29
		bcc ]loop1

		rep #$30
		rts

;------------------------------------------------------------------------------
; Init the Tracks for play
InitTrackPointers mx %00
		ldy <MF_NumTracks

		phd
		pea MidiEventDP
		pld

		dey
]lp
		tya
		asl
		asl
		asl
		tax

		lda |MidiDP,x
		sta <MidiEventDP,x
		lda |MidiDP+2,x
		sta <MidiEventDP+2,x
		stz <MidiEventDP+4,x
		stz <MidiEventDP+6,x

		dey
		bpl ]lp
		pld

		rts

;------------------------------------------------------------------------------
;
;  Pump Mixer
;
;PumpMixer mx %00
;		lda <bMixerEnabled
;		beq :enabled
;
;:enabled

;------------------------------------------------------------------------------
; Process Instruments
;
; Go through the list of GlobalInstruments, collecting all the instrument
; playback information, into the Patches Array
;
; Also, process each instrument (convert the 16 bit sample data into volume
; indices for the mixer)
;
ProcessInstruments mx %00

:InstrumentNum  = temp0
:pInstrumentOut = temp1

		stz <:InstrumentNum
]loop
		lda <:InstrumentNum
		asl
		asl
		tay  ; For the lookup table
		lda <:InstrumentNum
		xba
		lsr
		lsr
		adc #Patches
		sta <:pInstrumentOut
		lda #^Patches
		sta <:pInstrumentOut+2


		lda |GlobalInstruments,y
		ora |GlobalInstruments+2,y
		beq :finished

		lda |GlobalInstruments,y
		ldx |GlobalInstruments+2,y

		jsr GetInstrumentData

		inc <:InstrumentNum

		bra ]loop

:finished

;------------------------------------------------------------------------------
; now loop through and fix the Samples so they will work with our mixer

:pPatch = temp0
:pSample = temp1
:len     = temp2

		lda #Patches
		sta <:pPatch
		ldx #^Patches
		stx <:pPatch+2
]lp
		ldy #i_sample_rate
		lda [:pPatch],y
		beq :donedone
		
		ldy #i_sample_start_addr
		lda [:pPatch],y
		sta <:pSample
		ldy #i_sample_start_addr+2
		lda [:pPatch],y
		sta <:pSample+2
		
		ldy #i_sample_length
		lda [:pPatch],y
		sta <:len
		
		ldy #0
]modlp
		lda [:pSample],y
		cmp #$8000
		rol
		xba
		and #$01FE
		sta [:pSample],y
		
		iny
		iny
		cpy <:len
		bcc ]modlp
		
		clc
		lda <:pPatch
		adc #sizeof_inst
		sta <:pPatch
		bra ]lp
		
:donedone		

		rts

;------------------------------------------------------------------------------
; I'd like this to be nice, but right now, I just want it to work, and do
; something else, so first pass is not Nice
GetInstrumentData mx %00
:InstrumentNum  = temp0
:pInstrumentOut = temp1
:pWaveFile      = temp2

:length         = temp3

:inst_temp = GlobalTemp

		sta <:pWaveFile
		stx <:pWaveFile+2

; Zero out the Instrument Data, so anything we don't fill in, is just 0
; probably not needed
		phb
		lda #0
		sta [:pInstrumentOut],y

		ldx <:pInstrumentOut
		txy
		iny
		iny

		lda <:pInstrumentOut+2
		xba
		ora <:pInstrumentOut+2
		sta |:mvn+1

		lda #sizeof_inst-3
:mvn	mvn 0,0

		plb

		; Zero temp instrument
		stz |:inst_temp
		ldx #:inst_temp
		ldy #:inst_temp+2
		lda #sizeof_inst-3
		mvn ^:inst_temp,^:inst_temp

;-- ugly cut paste
 
		lda [:pWaveFile]
		cmp #'RI'
		beq :good0
:invalid_wave
:too_large
		rts
:good0
		ldy #2
		lda [:pWaveFile],y
		cmp #'FF'
		bne :invalid_wave

		ldy #4
		lda [:pWaveFile],y
		sta <:length
		ldy #6
		lda [:pWaveFile],y
		sta <:length+2

		lda <:length+2
		bne :too_large

; So far so good

; next block, I expect 8 bytes, 'WAVEfmt '
		; skip forward
		clc
		lda <:pWaveFile
		adc #8
		sta <:pWaveFile
		lda <:pWaveFile+2
		adc #0
		sta <:pWaveFile+2

		jsr :get_word
		cmp #'WA'
		bne :invalid_wave
		jsr :get_word
		cmp #'VE'
		bne :invalid_wave
		jsr :get_word
		cmp #'fm'
		bne :invalid_wave
		jsr :get_word
		cmp #'t '
		bne :invalid_wave

		; output length of WAVEfmt block, should be 16
		jsr :get_word
		jsr :get_word

		; type, 1 = PCM
		jsr :get_word

		; channels - needs to be 1
		jsr :get_word

		jsr :get_word
		sta |:inst_temp+i_sample_rate
		jsr :get_word  ; high part of sample rate $$JGA TODO, might need to support this
		sta |:inst_temp+i_sample_rate+2

		jsr :get_word  ; sample rate * bits ber sample * channels / 8
		jsr :get_word

		jsr :get_word ; bytes per sample (better be 2)

		jsr :get_word ; bits per sample (should be 16)

		; I expect 'data' to be next
		; this is out actual wave!
		jsr :get_word
		cmp #'da'
		beq :good2
:missing
		rts

:good2
		jsr :get_word
		cmp #'ta'
		bne :missing

		jsr :get_word
		sta <:length
		sta |:inst_temp+i_sample_length
		jsr :get_word
		sta <:length+2
		sta |:inst_temp+i_sample_length+2

		lda <:pWaveFile
		sta |:inst_temp+i_sample_start_addr
		lda <:pWaveFile+2
		sta |:inst_temp+i_sample_start_addr+2


		; skip ove the wave data
		clc
		lda <:pWaveFile
		adc <:length
		sta <:pWaveFile
		lda <:pWaveFile+2
		adc <:length+2
		sta <:pWaveFile+2

		jsr :get_word
		cmp #'sm'
		beq :good3
:nosample
		jsr :put_word

		jmp :next_block
:good3
		jsr :get_word
		cmp #'pl'
		beq :goodgood

		jsr :put_word
		bra :nosample
:goodgood
		jsr :get_word ; 3C
		jsr :get_word ; 00

		pei :pWaveFile
		pei :pWaveFile+2

; extra important instrument info here

		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??

		jsr :get_word
		sta |:inst_temp+i_key_center

		jsr :get_word ; ??

		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??

		jsr :get_word ; loop type or mode?
		sta |:inst_temp+i_loop

		jsr :get_word ; ??

		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??

		jsr :get_word 	; loop start low
		sta |:inst_temp+i_sample_loop_start
		jsr :get_word   ; loop start high
		sta |:inst_temp+i_sample_loop_start+2

		asl |:inst_temp+i_sample_loop_start
		rol |:inst_temp+i_sample_loop_start+2

		clc
		lda |:inst_temp+i_sample_loop_start
		adc |:inst_temp+i_sample_start_addr
		sta |:inst_temp+i_sample_loop_start
		lda |:inst_temp+i_sample_loop_start+2
		adc |:inst_temp+i_sample_start_addr+2
		sta |:inst_temp+i_sample_loop_start+2


		jsr :get_word 	; loop end low
		sta |:inst_temp+i_sample_loop_end
		jsr :get_word   ; loop end high
		sta |:inst_temp+i_sample_loop_end+2

		asl |:inst_temp+i_sample_loop_end
		rol |:inst_temp+i_sample_loop_end+2

		clc
		lda |:inst_temp+i_sample_loop_end
		adc |:inst_temp+i_sample_start_addr
		sta |:inst_temp+i_sample_loop_end
		lda |:inst_temp+i_sample_loop_end+2
		adc |:inst_temp+i_sample_start_addr+2
		sta |:inst_temp+i_sample_loop_end+2


		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??
		jsr :get_word ; ??

		pla
		sta <:pWaveFile+2
		pla
		sta <:pWaveFile
		clc
		adc #$3C
		sta <:pWaveFile
		lda <:pWaveFile+2
		adc #0
		sta <:pWaveFile+2

		; xtra expected next
:next_block
		jsr :get_word
		cmp #'xt'
		beq :good4
:noextra
		rts
:good4
		jsr :get_word
		cmp #'ra'
		bne :noextra

		jsr :skip_block

		; 'cue ' next
		jsr :get_word
		cmp #'cu'
		beq :good5
:nocue
		rts
:good5
		jsr :get_word
		cmp #'e '
		bne :nocue

		jsr :skip_block

		; 'CSET' next
		jsr :get_word
		cmp #'CS'
		beq :good6
:noCSET
		rts
:good6
		jsr :get_word
		cmp #'ET'
		bne :noCSET

		jsr :skip_block

		; 'LIST' next
		jsr :get_word
		cmp #'LI'
		beq :good7
:nolist
		rts
:good7
		jsr :get_word
		cmp #'ST'
		bne :nolist

; at this point I'm just interesting the instrument name

		jsr :get_word ; list size
		jsr :get_word

; looking for INFOINAM - info instrument name

		jsr :get_word
		cmp #'IN'
		beq :good8
:missingname
		rts
:good8
		jsr :get_word
		cmp #'FO'
		bne :missingname

		jsr :get_word
		cmp #'IN'
		bne :missingname

		jsr :get_word
		cmp #'AM'
		bne :missingname

		jsr :get_word 	; length of the name
		jsr :get_word

		; now pWaveFile is pointing a the name
		sep #$20
		ldx #$FFFF
		txy
]lp
		inx
		iny
		cpx #31
		beq :crop
		lda [:pWaveFile],y
		sta |:inst_temp+i_name,x
		bne ]lp
:crop
		rep #$30

; We either get the name, or we get nothing!
; $$JGA TODO Fix this to work like the 256 bitmap
; chunk loader, where chunk order won't matter
; and chunks be optional

		phb
		ldx #:inst_temp
		ldy <:pInstrumentOut

		lda <:pInstrumentOut+2
		sta :mvn2+1
		lda #sizeof_inst-1
:mvn2	mvn 0,0
		plb

		rts

:put_word
		dec <:pWaveFile
		dec <:pWaveFile
		rts

:get_word
		lda [:pWaveFile]
		inc <:pWaveFile
		inc <:pWaveFile
		rts

:skip_block
		jsr :get_word ; 16
		pha
		jsr :get_word
		tax
		clc
		pla
		adc <:pWaveFile
		sta <:pWaveFile
		txa
		adc <:pWaveFile+2
		sta <:pWaveFile+2
		rts

;------------------------------------------------------------------------------
ShowInstrumentInfo mx %00
:pPatch = temp0
:NAMESIZE = 16

		lda #Patches
		sta <:pPatch
		ldx #^Patches
		stx <:pPatch+2

]lp
		ldy #i_sample_rate
		lda [:pPatch],y
		beq :done

		lda <:pPatch+2
		xba
		sta |:mvn+1

		ldy #GlobalTemp
		ldx <:pPatch
		lda #sizeof_inst+1
:mvn    mvn 0,0

; copy stuff into local buffer, so it's easier to use the print functions

		jsr myPRINTCR

		ldy #GlobalTemp
		jsr :PrintInfo

		clc
		lda <:pPatch
		adc #sizeof_inst
		sta <:pPatch
		bra ]lp

:done
		rts

:PrintInfo

		phy
		tyx
		jsr myPUTS

		ldy |CURSORY
		ldx #:NAMESIZE
		jsr myLOCATE

		lda #' '
		jsr myPUTC

		ply
		phy

		lda |i_sample_rate,y
		jsr myPrintAI

		ply
		phy
		ldy |CURSORY
		ldx #:NAMESIZE+7
		jsr myLOCATE

		ply
		phy

		lda |i_key_center,y
		jsr myPrintAI

		ldy |CURSORY
		ldx #:NAMESIZE+6+4
		jsr myLOCATE

		ply
		phy
		ldx #txt_loop
		lda |i_loop,y
		bne :loop
		ldx #txt_single
:loop
		jsr myPUTS

		lda 1,s
		clc
		adc #i_sample_start_addr
		tax
		jsr myPRINTAddress

		lda #' '
		jsr myPUTC

		ply
		phy
		lda |i_sample_length,y
		jsr myPRINTAH

		lda #' '
		jsr myPUTC

		lda 1,s
		clc
		adc #i_sample_loop_start
		tax
		jsr myPRINTAddress

		lda #' '
		jsr myPUTC

		lda 1,s
		clc
		adc #i_sample_loop_end
		tax
		jsr myPRINTAddress

		ply
		rts


;------------------------------------------------------------------------------


;		do *>#$5000
;ERROR   asc "PROGRAM IS TOO LARGE, ADJUST BSS ADDRESS BEYOND $8000"
;		fin
;------------------------------------------------------------------------------
; Uninitialized memory, so it doesn't take up space in the exe
	DUM $8000
start_BSS
; Align to page
	ds \,0
GlobalTemp ds 1024
Voices ds {VOICES*sizeof_osc}  ; 8*32
end_BSS
sizeof_BSS = {end_BSS-start_BSS}
	DEND
;------------------------------------------------------------------------------

	DUM $050200
Patches ds {128*sizeof_inst}   ; 128*64 ; put this in a different bank
	DEND
;------------------------------------------------------------------------------

