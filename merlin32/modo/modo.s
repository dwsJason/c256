;
;  Foenix Bitmap Example in Merlin32
;
; $00:2000 - $00:7FFF are free for application use.
;
        rel     ; relocatable
        lnk     Main.l

        use Util.Macs
		put macros.s

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
		use phx/page_00_inc.asm
		use phx/kernel_inc.asm
		use phx/rtc_def.asm
		use phx/timer_def.asm

		; Fixed Point Math
		use phx/Math_def.asm


		; Interrupts
		use phx/interrupt_def.asm


		ext title_pic
		ext decompress_lzsa

		;
		; some mod files
		;
		ext toms_diner

		ext MIXER_INIT
		ext MIXER_PUMP

		ext FontInit

        mx %00

;
; Decompress to this address
; Temp Buffer for decompressing stuff ~512K here
;
pixel_buffer = $080000	; need about 480k, put it in memory at 512K mark

VICKY_DISPLAY_BUFFER  = $100000
; 512k for my copy
;VICKY_OFFSCREEN_IMAGE = VICKY_DISPLAY_BUFFER+{XRES*YRES}
VICKY_OFFSCREEN_IMAGE = $000001
VICKY_WORK_BUFFER     = $180000


; Kernel method
VRAM = $B00000

; Base Address for Audio
AUDIO_RAM = $E00000

;------------------------------------------------------------------------------
; I like having my own Direct Page
MyDP  = $2000
MySTACK = STACK_END ;$FEFF $EFFF

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

dpJiffy        = 128
dpAudioJiffy   = 130

SongIsPlaying = 150


XRES = 800
YRES = 600

	do XRES=640
VIDEO_MODE = $007F  ; -- all the things enabled, 640x480
	else
VIDEO_MODE = $017F  ; -- all the things enabled, 800x600
	fin



start   ent             ; make sure start is visible outside the file
        clc
        xce
        rep $31         ; long MX, and CLC

		; I added this here, to allow iteration to be more stable
		; so when cli happens, we can avoid crashing
		lda #$6B  ; RTL
		sta >VEC_INT00_SOF
		sta >VEC_INT02_TMR0


; Default Stack is on top of System Multiply Registers
; So move the stack before proceeding

        lda #MySTACK
        tcs

		phk
		plb

		do 0
		sep #$30
        ; Setup the Interrupt Controller
        ; For Now all Interrupt are Falling Edge Detection (IRQ)
        LDA #$FF
        STA >INT_EDGE_REG0
        STA >INT_EDGE_REG1
        STA >INT_EDGE_REG2
        STA >INT_EDGE_REG3
        ; Mask all Interrupt @ This Point
        STA >INT_MASK_REG0
        STA >INT_MASK_REG1
        STA >INT_MASK_REG2
        STA >INT_MASK_REG3

		;JSL INITRTC
;INITRTC         PHA
;                PHP
;                setas				        ; Just make sure we are in 8bit mode

                LDA #0
                STA >RTC_RATES    ; Set watch dog timer and periodic interrupt rates to 0
                STA >RTC_ENABLE   ; Disable all the alarms and interrupts
                
                LDA >RTC_CTRL      ; Make sure the RTC will continue to tick in battery mode
                ORA #%00000100
                STA >RTC_CTRL

;                PLP
;                PLA
;                RTL


		rep #$30
		fin



		lda #0
		tcd
		;jsl $10AC ;INITCHLUT	    
		;jsl $10B0 ;INITSUPERIO	    
		;jsl $10B4 ;INITKEYBOARD    
		;jsl $10B8 ;INITMOUSE       
		;jsl $10BC ;INITCURSOR      
		;jsl $10C0 ;INITFONTSET     
		;jsl $10C4 ;INITGAMMATABLE  
		;jsl $10C8 ;INITALLLUT      
		;jsl $10CC ;INITVKYTXTMODE  
		;jsl $10D0 ;INITVKYGRPMODE  
		;jsl $10DC ;INITCODEC

		stz <MOUSE_PTR

        lda #MyDP
        tcd

		stz <SongIsPlaying

		phk
		plb

;------------------------------------------------------------------------------
; So the user doesn't have to press a key to make the mouse work
;		stz |MOUSE_PTR ; this is fix the mouse MOUSE_IDX or MOUSE_PTR, depending kernel version
;------------------------------------------------------------------------------

		jsl FontInit

		phk
		plb

;------------------------------------------------------------------------------
;
; Setup a Jiffy Timer, using Kernel Jump Table
; Trying to be friendly, in case we can friendly exit
;
		jsr InstallJiffy		; SOF timer
		jsr InstallAudioJiffy   ; 50hz timer

		jsr	WaitVBL

;------------------------------------------------------------------------------
;
;		jsr FadeToBorderColor
;
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
;------------------------------------------------------------------------------
; 		Disable Sprites

		sec
		lda #0
		ldx #8*63  ; sprite offset
]lp		sta >SP00_CONTROL_REG,x
		txa
		sbc #8
		tax
		bpl ]lp

;------------------------------------------------------------------------------

		jsr InitTextMode

		lda #0
		sta >BM0_X_OFFSET
		sta >BM0_Y_OFFSET
		sta >BM1_X_OFFSET
		sta >BM1_Y_OFFSET
		sta >TL0_CONTROL_REG
		sta >TL1_CONTROL_REG
		sta >TL2_CONTROL_REG
		sta >TL3_CONTROL_REG

;
; Extract CLUT data from the title image
;
;		; source picture
;		pea ^title_pic
;		pea title_pic
;
;		; destination address
;		pea ^pal_buffer
;		pea pal_buffer
;
;		jsl decompress_clut
;
;		jsr		WaitVBL
;
;        ; Copy over the LUT
;        ldy     #GRPH_LUT0_PTR  ; dest
;        ldx     #pal_buffer  	; src
;        lda     #1024-1			; length
;        mvn     ^pal_buffer,^GRPH_LUT0_PTR    ; src,dest
;
;		phk
;		plb
;
;        ; Set Background Color
;		sep #$30
;        lda	|pal_buffer
;        sta >BACKGROUND_COLOR_B ; back
;        lda |pal_buffer+1
;        sta  >BACKGROUND_COLOR_G ; back
;        lda |pal_buffer+2
;        sta  >BACKGROUND_COLOR_R ; back
;		rep #$30


;;
;; Extract pixels from the title image
;;
;		; source picture
;		pea ^title_pic
;		pea title_pic
;
;		; destination address
;		pea ^pixel_buffer
;		pea pixel_buffer
;
;		jsl decompress_pixels
;
;		jsr WaitVBL

;-----------------------------------------------------------
;
; Copy the Pixels into Video Memory
;
;]count = 0
;		lup 8
;]source = pixel_buffer+{]count*$10000}
;]dest   = {VICKY_DISPLAY_BUFFER+VRAM}+{]count*$10000}
;		lda #0
;		tax
;		tay
;		dec
;		mvn ^]source,^]dest
;]count = ]count+1
;		--^
;
		phk
		plb


;-------------------------------------------------------------
;
; Let's see what we can do with the VDMA Controller
;

; Just a backup copy of the bitmap before we start banging on the frame buffer

		pea ^toms_diner
		pea toms_diner
		jsl	InitMod

		jsl MIXER_INIT

;-------------------------------------------------------------
;
; Debug Dump Some Memory
;
;----------------------------------------------------------
;dump
;:pTemp = 0
;:VOL_TABLES equ $030200  ; 64 Volume tables (256 entries each)
;		lda #:VOL_TABLES
;		sta <:pTemp
;		lda #^:VOL_TABLES
;		sta <:pTemp+2
;
;		ldy #0
;]lp
;		lda [:pTemp],y
;		phy
;		jsr myPRINTAH
;		ldx #:space
;		jsr myPUTS
;		pla
;		inc
;		inc
;		tay
;		and #$1F
;		bne :skipret
;		jsr myPRINTCR
;		phy
;		tya
;		jsr myPRINTAH
;		ldx #:colon
;		jsr myPUTS
;		ply
;:skipret
;		cpy #$8200
;		bne ]lp
;
;:space asc ' '
;		db 0
;:colon asc ': '
;		db 0
;
;		bra	dump


]pump
		jsr WaitVBL
;		jsr MIXER_PUMP
		bra ]pump


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
	    ;phd
		;pea #0
		;pld
		;jsl PRINTAH
		;pld
		
		; Kernel function doesn't work

		sep #$30
		xba
		pha
		and #$F0
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
		and #$F0
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
; Put DP back at 0, for Kernel call
;
myHEXBYTE mx %00
		; Kernel function doesn't work

		sep #$30
		pha
		and #$F0
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
myLOCATE mx %00
		phd
		pea 0
		pld
		jsl LOCATE
		pld
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
;		lda #$5C    ; JML
		sta |VEC_INT00_SOF

		lda #:JiffyTimer
		sta |VEC_INT00_SOF+1

		lda #>:JiffyTimer
		sta |VEC_INT00_SOF+2

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
		phd
		pha
		phx
		phy
		php

		phk
		plb
		rep #$30
		lda #MyDP
		tcd
		inc <dpAudioJiffy

		jsr AudioTick


		plp
		ply
		plx
		pla
		pld
		plb
		rtl
;------------------------------------------------------------------------------

AudioTick mx %00

		lda <SongIsPlaying
		beq :notPlaying

:notPlaying

		; Pump the mixer

		rts

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

		ldx #:ModoText  ; out a string
		jsl PUTS

		pld
		rts

:ModoText   asc 'Modo MOD Player'
			db 13
			asc 'Memory Location:'
			db 0

;------------------------------------------------------------------------------
;
; Clut Buffer
;
pal_buffer
		ds 1024


	dum 0
sample_name        ds 22
sample_length      ds 2
sample_fine_tune   ds 1
sample_volume      ds 1
sample_loop_start  ds 2
sample_loop_length ds 2
sizeof_sample      ds 0
	dend

;------------------------------------------------------------------------------
; void InitMod(void* pModFile)
;
; pea ^pModFile
; pea #pModFile
;
; jsl InitMod
;
InitMod mx %00
; Stack
:pModInput = 4

; Zero Page
:pMod    = 0
:pInstruments = 4
:pPatterns = 8
:pSamples  = 12
:loopCount = 16
:current_y = 18
:num_patterns = 20

;:pTemp equ 128

	lda :pModInput,s
	sta <:pMod
	lda :pModInput+2,s
	sta <:pMod+2

	; Construct the MOD type string, and dump it out on the terminal

	ldy #1080 ; Magic offset
	lda [:pMod],y
	sta |:temp_buffer

	; --- crap out hex Pointer to the mod
	phy

	lda <:pMod+2
	jsr myHEXBYTE
	lda <:pMod
	jsr myPRINTAH
	jsr myPRINTCR

	ply
	; --- end crap out hex codes

	iny
	iny
	lda [:pMod],y
	sta |:temp_buffer+2
	lda #13
	sta |:temp_buffer+4

	ldx #:temp_buffer
	jsr myPUTS				; hopefully M.K.

	;$$TODO, Validate

	ldx #:test
	jsr myPUTS

	; --- print out the mod file's name

	ldx <:pMod
	ldy #:mod_name
	lda <:pMod+2
	xba
	sta |:mv+1   ; only works because K=0
	lda #19  ; 20 bytes
:mv
	mvn 0,0
	phk
	plb

	ldx #:mod_name
	jsr myPUTS
	jsr myPRINTCR

	; --- end print out mod file's name

	; --- Dump out Sample Information

	ldy #20 ; offset to sample information
	sty <:current_y
	stz <:loopCount

:SampleDumpLoop
	ldy <:current_y
	ldx #0
]lp	lda [:pMod],y
	sta |:sample_name,x
	iny
	iny
	inx
	inx
	cpx #22
	bcc ]lp

	sty <:current_y

	; Current Sample #
	lda <:loopCount
	jsr myPRINTAH
	ldx #:space
	jsr myPUTS

    ; Current Sample Name
	ldx #:sample_name
	jsr myPUTS
	;ldx #:space
	;jsr myPUTS
	ldy |CURSORY
	ldx #28
	jsr myLOCATE

    ; Sample Length
	ldx #:sample_length
	jsr myPUTS
	ldy <:current_y
	lda [:pMod],y
	xba ;endian
	iny
	iny
	sty <:current_y
	jsr myPRINTAH
	ldx #:space
	jsr myPUTS

	; Fine Tune
	ldx #:fine_tune
	jsr myPUTS
	ldy <:current_y
	lda [:pMod],y
	and #$FF
	iny
	sty <:current_y
	jsr myHEXBYTE
	ldx #:space
	jsr myPUTS

	; Volume
	ldx #:volume
	jsr myPUTS
	ldy <:current_y
	lda [:pMod],y
	and #$FF
	iny
	sty <:current_y
	jsr myHEXBYTE
	ldx #:space
	jsr myPUTS

	; Loop Start
	ldx #:loop_start
	jsr myPUTS
	ldy <:current_y
	lda [:pMod],y
	xba ;endian
	iny
	iny
	sty <:current_y
	jsr myPRINTAH
	ldx #:space
	jsr myPUTS

	; Loop Length
	ldx #:loop_length
	jsr myPUTS
	ldy <:current_y
	lda [:pMod],y
	xba ;endian
	iny
	iny
	sty <:current_y
	jsr myPRINTAH
	ldx #:space
	jsr myPUTS

	jsr myPRINTCR

	lda <:loopCount
	inc
	sta <:loopCount
	cmp #31
	bcs :loopDone
	jmp :SampleDumpLoop

:loopDone

	; --- end Dump out Sample Information

	; Song Length
	ldx #:song_len
	jsr myPUTS
	ldy <:current_y
	lda [:pMod],y
	and #$FF
	iny
	iny
	sty <:current_y
	jsr myHEXBYTE
	jsr myPRINTCR

	; Patterns
	stz <:num_patterns
	stz <:loopCount
]lp
	ldy <:current_y
	lda [:pMod],y
	iny
	sty <:current_y

	; how many total patterns in file?
	and #$00FF
	cmp <:num_patterns
	bcc :no_update
	sta <:num_patterns
:no_update
	pha
	ldx #:space
	jsr myPUTS
	pla
	jsr myHEXBYTE

	lda <:loopCount
	and #$1F
	cmp #$1F
	bne :skip
	jsr myPRINTCR
:skip
	lda <:loopCount
	inc
	sta <:loopCount
	cmp #128
	bcc ]lp

	inc <:num_patterns

; now at position 1080 / M.K.

	ldx #:pattern_count
	jsr myPUTS
	lda <:num_patterns
	jsr myHEXBYTE
	ldx #:space
	jsr myPUTS

;	jsr myPRINTCR

	; Calculate pPatterns
	clc
	lda <:pMod
	adc #1084
	sta <:pPatterns
	lda <:pMod+2
	adc #0
	sta <:pPatterns+2

	; How Large is a pattern block
	; 4 channels * 4 bytes * 64
	; (1024 * num_patterns)

	; Calculate pSamples
	; First poke in the size of patterns
	stz <:pSamples+2

	lda <:num_patterns
	xba  ; x 256
	asl  ; x 512
	rol <:pSamples+2
	asl  ; x 1024
	;sta <:pSamples
	rol <:pSamples+2

	; c=0
	adc <:pPatterns
	sta <:pSamples
	lda <:pPatterns+2
	adc <:pSamples+2
	sta <:pSamples+2


	; print out the pPatterns
	ldx #:txt_pPatterns
	jsr myPUTS

	lda <:pPatterns+2
	jsr myHEXBYTE
	lda <:pPatterns
	jsr myPRINTAH

	ldx #:space
	jsr myPUTS

	; print out the pSamples
	ldx #:txt_pSamples
	jsr myPUTS
	lda <:pSamples+2
	jsr myHEXBYTE
	lda <:pSamples
	jsr myPRINTAH

	jsr myPRINTCR
	;
	; Load Audio into Sound Memory
	; It will follow the same layout as it is in the current
	; memory, using the #define AUDIO_RAM
	; The 8 bit PCM is transformed into a 16 bit memory address
	; that is used to look up volume in the mixer, the VDMA has to work
	; with even strides, so it's "scaling" ability can only work with
	; 16-bit units, so this is sort of a happy serendipity, that this
	; works out well for dynamically applying audio scale
	;

	; Save For Later
	lda |CURSORX
	pha
	lda |CURSORY
	pha
	; place the mem copies on screen next to inst info
	ldy #5
	sty |CURSORY

	clc
	lda <:pMod
	adc #20		; calculate pInstuments
	sta <:pInstruments
	lda <:pMod+2
	adc #0
	sta <:pInstruments+2

:pInst = 28
:pVRAM = 32
:pSamp = 36
:tCount = 40

	lda #31 	   	 ; up to 31 instruments
	sta <:loopCount
	;
	; TARGET Video RAM Location
	; Trying to go directly to VRAM, even though it doesn't seem
	; reliable
	; 
	lda #AUDIO_RAM
	sta <:pVRAM
	lda #^AUDIO_RAM
	sta <:pVRAM+2
	; Set up pointer to Instrument 0
	lda <:pInstruments
	sta <:pInst
	lda <:pInstruments+2
	sta <:pInst+2
	; Setup pointer to Sample 0
	lda <:pSamples
	sta <:pSamp
	lda <:pSamples+2
	sta <:pSamp+2

]copyloop
	ldy |CURSORY
	ldx #75
	jsr myLOCATE

	lda <:pSamp+2    	; Sample RAM Address
	jsr myHEXBYTE
	lda <:pSamp
	jsr myPRINTAH
	ldx #:txt_too
	jsr myPUTS
	lda <:pVRAM+2  		; Sample VRAM Address
	jsr myHEXBYTE
	lda <:pVRAM
	jsr myPRINTAH
	jsr myPRINTCR


	ldy #sample_length
	lda [:pInst],y
	beq :skip_empty		; skip, empty entry
	xba					; fix endian
	tax					; x = counter

	; Actual Data Copy into VRAM

	ldy #0
]waveloop
	lda [:pSamp]
	tay
	and #$FF
	asl 				; c=0
	sta [:pVRAM]

	lda <:pVRAM			; pVRAM+=2
	adc #2
	sta <:pVRAM
	bcc :noover
	inc <:pVRAM+2
:noover
	tya
	xba
	and #$FF
	asl 				; c=0
	sta [:pVRAM]

	lda <:pVRAM			; VRAM+=2
	adc #2
	sta <:pVRAM
	bcc :noover2
	inc <:pVRAM+2
:noover2

	clc
	lda <:pSamp		; pSamp+=2
	adc #2
	sta <:pSamp
	lda #0
	adc <:pSamp+2
	sta <:pSamp+2
	dex
	beq :wavedone
	dex
	bne ]waveloop

:wavedone


:skip_empty

	; next Inst Structure
	clc
	lda <:pInst
	adc #sizeof_sample
	sta <:pInst
	lda #0
	adc <:pInst+2
	sta <:pInst+2

	dec <:loopCount ; loop count
	bnel ]copyloop

; Restore Cursor

	ply
	plx
	jsr myLOCATE
	jsr myPRINTCR

; -----------------------------------------------------------------------------
; Print out the contents of a Pattern Block

:pBlockAddress = 44

	lda <:pPatterns
	sta <:pBlockAddress
	lda <:pPatterns+2
	sta <:pBlockAddress+2

	lda #15
	sta <:tCount
]lp
	jsr PrintPatternRow
	jsr myPRINTCR
	clc
	lda <:pBlockAddress
	adc #{4*4}			; add rowsize
	sta <:pBlockAddress
	bne :cntu
	inc <:pBlockAddress+2
:cntu
	dec <:tCount
	bpl ]lp

; -----------------------------------------------------------------------------

; Copy Return Address
	lda 1,s
	sta 5,s
	lda 2,s
	sta 6,s

	pla	; adjust stack
	pla

	rtl

:space asc ' '
	db 0

:sample_length asc 'len:'
	db 0
:fine_tune asc 'tune:'
	db 0
:volume asc 'vol:'
	db 0
:loop_start asc 'loop:'
	db 0
:loop_length asc 'lplen:'
	db 0

:song_len asc 'song length:'
	db 0

:pattern_count asc 'pattern count:'
	db 0

:txt_pPatterns asc 'pPatterns:'
	db 0

:txt_pSamples asc 'pSamples:'
	db 0

:txt_too asc '->'
	db 0

:mod_name ds 21
:sample_name ds 24

:test
	asc '---------------------------------------------------------------------'
	db 13,0

:temp_buffer
	ds 16

;------------------------------------------------------------------------------
;
; Place Row Pointer in Location 44
;
PrintPatternRow mx %00
:pRow = 44

	ldx #:div
	jsr myPUTS

	ldy #2
	lda [:pRow],y
	tax
	lda [:pRow]
	jsr PrintNoteInfo

	ldx #:div
	jsr myPUTS

	ldy #6
	lda [:pRow],y
	tax
	ldy #4
	lda [:pRow],y
	jsr PrintNoteInfo

	ldx #:div
	jsr myPUTS

	ldy #10
	lda [:pRow],y
	tax
	ldy #8
	lda [:pRow],y
	jsr PrintNoteInfo

	ldx #:div
	jsr myPUTS

	ldy #14
	lda [:pRow],y
	tax
	ldy #12
	lda [:pRow],y
	jsr PrintNoteInfo

	ldx #:div
	jmp myPUTS
	;rts

:div asc '|'
	 db 0

;------------------------------------------------------------------------------
;
; Print out info about a single note
;
; AX = 4 bytes of the note
;
PrintNoteInfo mx %00
:note   = 64
:period = 68
:effect = 70

	; Save DP locations
	pei :note
	pei :note+2
	pei :period
	pei :effect

	sta <:note
	stx <:note+2

	; Decode the Period
	xba
	and #$FFF
	sta <:period

	; Convert into Note!

	; Init Note String
	lda #'..'
	ldx #'. '
	ldy #' .'
	sta |:note_string
	stx |:note_string+2
	sta |:note_string+4
	sty |:note_string+6
	stx |:note_string+8
	sta |:note_string+10
	sta |:note_string+12
	stz |:note_string+13

	lda <:period
	beq :no_period

; Find the period index

	;ldx #{12*2*6}-2
	ldx #{12*2*3}-2
]lp
	cmp |:tuning,x
	beq :stop
	bcc :stop
	dex
	dex
	bne ]lp
:stop
; period index, into a note string
	txa
	asl
	tax
	lda |:tuning_str,x
	sta |:note_string
	lda |:tuning_str+2,x
	sta |:note_string+2

:no_period

; Sample #

	lda #0	; clear B (of AB)
	sep #$20
	lda <:note+2
	lsr 			; 4 LSBs of the Sample #
	lsr
	lsr
	lsr
	pha
	lda <:note
	and #$F0  		; 4 MSBs of the Sample #
	ora 1,s
	sta 1,s
	beq :skip_sample
	; fetch char
	lsr
	lsr
	lsr
	lsr
	tax
	lda |:chars,x
	sta |:note_string+4

	lda 1,s
	and #$F
	tax
	lda |:chars,x
	sta |:note_string+5
	;--end
:skip_sample
	pla			; sample #
	beq	:skip_volume

	dec

	rep #$31

	; multiply x30, for index into sample definition
	asl	; x2
	pha
	asl
	asl
	asl
	asl ; 32
	sec
	sbc 1,s ; (32x - 2x = 30x)
	sta 1,s

:pInstruments = 4
:pInst = 28

	clc
	pla
	adc <:pInstruments
	sta <:pInst
	lda #0
	adc <:pInstruments+2
	sta <:pInst+2

	sep #$30
	ldy #sample_volume
	lda [:pInst],y
	and #$FF
	tay
	and #$F0
	lsr
	lsr
	lsr
	lsr
	tax
	lda #'v'
	sta |:note_string+6
	lda |:chars,x
	sta |:note_string+7
	tya
	and #$0F
	tax
	lda |:chars,x
	sta |:note_string+8

:skip_volume

	rep #$31

	lda <:note+2
	xba
	and #$FFF
	sta <:effect

	sep #$30
	ora <:effect+1
	beq :skip_effect

	; spit out effect nibbles
	ldx <:effect+1
	lda |:chars,x
	sta |:note_string+10
	lda <:effect
	lsr
	lsr
	lsr
	lsr
	tax
	lda |:chars,x
	sta |:note_string+11
	lda <:effect
	and #$0F
	tax
	lda |:chars,x
	sta |:note_string+12
:skip_effect
	rep #$31


	ldx #:note_string
	jsr myPUTS

	; Restore DP Locations
	pla
	sta <:effect
	pla
	sta <:period
	pla
	sta <:note+2
	pla 
	sta <:note

	rts

:chars  ASC '0123456789ABCDEF'

:dotdotdot asc '... .. .. ...'
			db 0

:note_string ds 16	; 12 byte, with 0 terminator, simulate output from OpenMPT

:tuning
	dw 856,808,762,720,678,640,604,570,538,508,480,453 ; C-1 to B-1
	dw 428,404,381,360,339,320,302,285,269,254,240,226 ; C-2 to B-2
	dw 214,202,190,180,170,160,151,143,135,127,120,113 ; C-3 to B-3
;	dw 214/2,202/2,190/2,180/2,170/2,160/2,151/2,143/2,135/2,127/2,120/2,113/2 ; C-4 to B-4
;	dw 214/4,202/4,190/4,180/4,170/4,160/4,151/4,143/4,135/4,127/4,120/4,113/4 ; C-5 to B-5
;	dw 214/8,202/8,190/8,180/8,170/8,160/8,151/8,143/8,135/8,127/8,120/8,113/8 ; C-6 to B-6

:tuning_str
	asc 'C-1 C#1 D-1 D#1 E-1 F-1 F#1 G-1 G#1 A-1 A#1 B-1 '
	asc 'C-2 C#2 D-2 D#2 E-2 F-2 F#2 G-2 G#2 A-2 A#2 B-2 '
	asc 'C-3 C#3 D-3 D#3 E-3 F-3 F#3 G-3 G#3 A-3 A#3 B-3 '
	asc 'C-4 C#4 D-4 D#4 E-4 F-4 F#4 G-4 G#4 A-4 A#4 B-4 '
	asc 'C-5 C#5 D-5 D#5 E-5 F-5 F#5 G-5 G#5 A-5 A#5 B-5 '
	asc 'C-6 C#6 D-6 D#6 E-6 F-6 F#6 G-6 G#6 A-6 A#6 B-6 '


;------------------------------------------------------------------------------

mt_PeriodTable
; Tuning -8
	dw 907,856,808,762,720,678,640,604,570,538,508,480
	dw 453,428,404,381,360,339,320,302,285,269,254,240
	dw 226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dw 900,850,802,757,715,675,636,601,567,535,505,477
	dw 450,425,401,379,357,337,318,300,284,268,253,238
	dw 225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dw 894,844,796,752,709,670,632,597,563,532,502,474
	dw 447,422,398,376,355,335,316,298,282,266,251,237
	dw 223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dw 887,838,791,746,704,665,628,592,559,528,498,470
	dw 444,419,395,373,352,332,314,296,280,264,249,235
	dw 222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dw 881,832,785,741,699,660,623,588,555,524,494,467
	dw 441,416,392,370,350,330,312,294,278,262,247,233
	dw 220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dw 875,826,779,736,694,655,619,584,551,520,491,463
	dw 437,413,390,368,347,328,309,292,276,260,245,232
	dw 219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dw 868,820,774,730,689,651,614,580,547,516,487,460
	dw 434,410,387,365,345,325,307,290,274,258,244,230
	dw 217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dw 862,814,768,725,684,646,610,575,543,513,484,457
	dw 431,407,384,363,342,323,305,288,272,256,242,228
	dw 216,203,192,181,171,161,152,144,136,128,121,114

; Tuning 0, Normal
	;    C-1 C#1 D-1 D#1 E-1 F-1 F#1 G-1 G#1 A-1 A#1 B-1
	dw 856,808,762,720,678,640,604,570,538,508,480,453 ; C-1 to B-1
	dw 428,404,381,360,339,320,302,285,269,254,240,226 ; C-2 to B-2
	dw 214,202,190,180,170,160,151,143,135,127,120,113 ; C-3 to B-3

; Tuning 1
	dw 850,802,757,715,674,637,601,567,535,505,477,450 ; same as above
	dw 425,401,379,357,337,318,300,284,268,253,239,225 ; but with
	dw 213,201,189,179,169,159,150,142,134,126,119,113 ; finetune +1
; Tuning 2
	dw 844,796,752,709,670,632,597,563,532,502,474,447 ; etc,
	dw 422,398,376,355,335,316,298,282,266,251,237,224 ; finetune +2
	dw 211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dw 838,791,746,704,665,628,592,559,528,498,470,444
	dw 419,395,373,352,332,314,296,280,264,249,235,222
	dw 209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dw 832,785,741,699,660,623,588,555,524,495,467,441
	dw 416,392,370,350,330,312,294,278,262,247,233,220
	dw 208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dw 826,779,736,694,655,619,584,551,520,491,463,437
	dw 413,390,368,347,328,309,292,276,260,245,232,219
	dw 206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dw 820,774,730,689,651,614,580,547,516,487,460,434
	dw 410,387,365,345,325,307,290,274,258,244,230,217
	dw 205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dw 814,768,725,684,646,610,575,543,513,484,457,431
	dw 407,384,363,342,323,305,288,272,256,242,228,216
	dw 204,192,181,171,161,152,144,136,128,121,114,108


	put mixer.s
	put colors.s
	put i256.s
	put dma.s

