;
;  Foenix Bitmap Example in Merlin32
;
; $00:2000 - $00:7FFF are free for application use.
;
        rel     ; relocatable
        lnk     Main.l

        use Util.Macs
		put macros.s
		use keys.i

		; Vicky
		use ../phx/vicky_ii_def.asm
		use ../phx/VKYII_CFP9553_BITMAP_def.asm 
		use ../phx/VKYII_CFP9553_TILEMAP_def.asm
		use ../phx/VKYII_CFP9553_VDMA_def.asm   
		use ../phx/VKYII_CFP9553_SDMA_def.asm   
		use ../phx/VKYII_CFP9553_SPRITE_def.asm 

		; Kernel
		use ../phx/page_00_inc.asm
		use ../phx/kernel_inc.asm

		; Hardware
		use ../phx/rtc_def.asm
		use ../phx/timer_def.asm
		; Fixed Point Math
		use ../phx/Math_def.asm

		; Interrupts
		use ../phx/interrupt_def.asm


		ext logo_pic
		ext decompress_lzsa

		;
		; some mod files
		;
		ext toms_diner

		ext FontInit

        mx %00

;------------------------------------------------------------------------------
; Direct Page Equates
;------------------------------------------------------------------------------

		put dp.i.s
		put mixer.i.s
;
; Decompress to this address
; Temp Buffer for decompressing stuff ~512K here
;
VICKY_DISPLAY_BUFFER  = $100000
; 512k for my copy
;VICKY_OFFSCREEN_IMAGE = VICKY_DISPLAY_BUFFER+{XRES*YRES}
VICKY_OFFSCREEN_IMAGE = $000001
VICKY_WORK_BUFFER     = $180000


; Kernel method
VRAM = $B00000

VRAM_TILE_CAT = $C80000
VRAM_LOGO_MAP = $B80000

; Base Address for Audio
AUDIO_RAM = $80000
;AUDIO_RAM = $E00000

;------------------------------------------------------------------------------
; I like having my own Direct Page
MySTACK = STACK_END ;$FEFF Defined in the page_00_inc.asm

; Video Mode Stuff

XRES = 800
YRES = 600

VIDEO_MODE = $017F  ; -- all the things enabled, 800x600


;------------------------------------------------------------------------------

start   ent             ; make sure start is visible outside the file
        clc
        xce
        sep $35         ; mxci=1
						; keep interrupts off, until we're ready for them
						; yes, they should be off, but hard to say how
						; we got here

		phk
		plb

		; I added this here, to allow iteration to be more stable
		; so when cli happens, we can avoid crashing
		lda #$6B  ; RTL
		sta |VEC_INT00_SOF
		sta |VEC_INT01_SOL
		sta |VEC_INT02_TMR0
		sta |VEC_INT03_TMR1
		sta |VEC_INT04_TMR2


; Default Stack is on top of System Multiply Registers
; So move the stack before proceeding
		rep $31 	 ; mxc = 000

        lda #MySTACK
        tcs

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

;		stz <MOUSE_PTR

        lda #MyDP
        tcd

		stz <SongIsPlaying

		phk
		plb

		; Initialize the uninitialized RAM
		stz |uninitialized_start
		ldx #uninitialized_start
		ldy #uninitialized_start+2
		lda #{uninitialized_end-uninitialized_start}-3
		mvn ^uninitialized_start,^uninitialized_start

;------------------------------------------------------------------------------
; So the user doesn't have to press a key to make the mouse work
;		stz |MOUSE_PTR ; this is fix the mouse MOUSE_IDX or MOUSE_PTR, depending kernel version
;------------------------------------------------------------------------------

		jsl FontInit

		phk
		plb

		;lda #2
		;sta >MOUSE_PTR_CTRL_REG_L
		lda #$FFFF
		sta >MOUSE_PTR_GRAP1_START

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
		;lda #0
		;sta >MOUSE_PTR_CTRL_REG_L
		;lda #1
		;sta >MOUSE_PTR_CTRL_REG_L

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

		phk
		plb
;------------------------------------------------------------------------------

		jsr logo_pic_init

;------------------------------------------------------------------------------

		pea ^toms_diner
		pea toms_diner
		jsl	ModInit

;------------------------------------------------------------------------------
; Mixer things

		ext MIXstartup
		ext MIXshutdown
		ext MIXplaysample
		ext MIXsetvolume


		lda #mixer_dpage	; pass in location of DP memory
		jsl MIXstartup

;------------------------------------------------------------------------------


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

		jsr ModPlay

		ldy #42			; cursor blink someplace harmless
		ldx #0
		jsr myLOCATE

]main_loop
		jsr WaitVBL

		jsr ReadKeyboard

		ldx #KEY_SPACE
		lda #PlayInstrument
		jsr OnKeyDown

		sei
; grab information, I need so I can update the tracker pattern text
		pei mod_p_current_pattern
		pei mod_p_current_pattern+2
		pei mod_current_row
		pei mod_pattern_index
		cli
; update the tracker pattern text

		ldy #43
		ldx #0
		jsr fastLOCATE

		pla ; pattern_index -- use to highlight the "block"
		pla ; current_row   - would be nice for this to be illustrated, to the left of the notes
		cmp <last_row
		bne :print 			; only print if it needs it, clean up refresh

		plx
		pla
		bra ]main_loop

:print
:pBlockAddress = temp5
:curRow = temp6

		sta <last_row
		sta <:curRow

		plx ; pointer to current row, of 4 commands
		pla

		sta <:pBlockAddress
		stx <:pBlockAddress+2

		ldy #43
		lda #15
		sta <:tCount
		phy
]lp
		jsr PrintPatternRow
		inc <:curRow
		ldx #0
		ply
		iny
		phy
		jsr fastLOCATE
		clc
		lda <:pBlockAddress
		adc #{4*4}			; add rowsize
		sta <:pBlockAddress
		bne :cntu
		inc <:pBlockAddress+2
:cntu
		dec <:tCount
		bpl ]lp
		ply
		bra ]main_loop

;------------------------------------------------------------------------------
; X = Key #
; A = Function to Call
OnKeyDown mx %00
		dec
		pha
		sep #$20
		lda |keyboard,x
		bne :down
		; key is up, don't call
		sta |latch_keys,x
		rep #$30
:latched
		pla
		rts
:down
		cmp |latch_keys,x
		sta |latch_keys,x
		rep #$30
		beq :latched
:KeyIsDown
		rts

;------------------------------------------------------------------------------
; X = Key #
; A = Function to Call
OnKeyUp mx %00
		dec
		pha
		sep #$20
		lda |keyboard,x
		beq :up
		; key is up, don't call
		sta |latch_keys,x
		rep #$30
:latched
		pla
		rts
:up
		cmp |latch_keys,x
		sta |latch_keys,x
		rep #$30
		beq :latched
:KeyIsUp
		rts

;------------------------------------------------------------------------------
PlayInstrument mx %00
		rts

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
; Put DP back at zero while calling out to PUTS
;
fastPUTS  mx %00
		sep #$20
		ldy <pFastPut

		lda |0,x
		beq :done
]lp
		inx
		sta [pFastPut]
		iny
		sty <pFastPut
		lda |0,x
		bne ]lp
:done 
		rep #$30
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

		stz <SongIsPlaying

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

		jsr ModPlayerTick

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
;		sta >$AF1F78
;		sta >$AF1F79

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
ModPlayerTick mx %00
		lda <mod_jiffy
		inc
		cmp <mod_speed
		bcs :next_row
		sta <mod_jiffy
		rts
:next_row
		stz <mod_jiffy

		lda <mod_current_row
		inc
		cmp #64
		bcs :next_pattern
		sta <mod_current_row
		;c=0
		lda <mod_p_current_pattern
		adc #4*4
		sta <mod_p_current_pattern
		bcc :no_carry
		inc <mod_p_current_pattern+2
:no_carry
		rts

:next_pattern
		stz <mod_current_row

		lda <mod_pattern_index
		inc
		cmp <mod_song_length
		bcs :song_done
		sta <mod_pattern_index

		bra ModSetPatternPtr

:song_done
		stz <SongIsPlaying
		rts



;------------------------------------------------------------------------------
; ModPlay (play the current Mod)
;
ModPlay mx %00
; stop existing song
	stz <SongIsPlaying

; Initialize song stuff

	lda #6  ; default speed
	sta <mod_speed
	stz <mod_jiffy

	stz <mod_current_row
	stz <mod_pattern_index
	jsr ModSetPatternPtr

	lda #1
	sta <SongIsPlaying
	rts

;------------------------------------------------------------------------------
ModSetPatternPtr mx %00
	ldy <mod_pattern_index
	lda [mod_p_pattern_dir],y
	and #$7F
	asl
	asl
	tax
	lda |mod_patterns,x
	sta <mod_p_current_pattern
	lda |mod_patterns+2,x
	sta <mod_p_current_pattern+2

	rts

;------------------------------------------------------------------------------
; void ModInit(void* pModFile)
;
; pea ^pModFile
; pea #pModFile
;
; jsl ModInit
;
ModInit mx %00
; Stack
:pModInput = 4

; Zero Page
:pMod    = temp0
:pInstruments = temp1
:pPatterns = temp2
:pSamples  = temp3
:loopCount = temp4
:current_y = temp5
:num_patterns = temp5+2

:pInst = temp6   ; used for the extraction over to the mod_instruments, block

;:pTemp equ 128

	stz <SongIsPlaying

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

; --- Copy Sample Data into the mod_instruments block

	ldy #20 ; offset to sample information
	sty <:current_y
	stz <:loopCount		; which instrument are we working on

]inst_fetch_loop

	lda <:loopCount
	asl
	tax
	lda |inst_address_table,x
	sta <:pInst			; is the pointer to the current i_ instrument 

; copy the sample name out for the mod, into the i_name

	tay  ; target address

	; c = 0
	lda <:pMod
	adc <:current_y
	tax  ; source address

	lda <:pMod+2
	xba
	sta |:nm_mvn+1

	lda #21    	  ; hard coded length used in MOD files
	phb
:nm_mvn mvn 0,0   ; copy the string
	plb

; advance y
	lda <:current_y
	adc #22  	  ; hard coded length, used in MOD files
	sta <:current_y
	tay

	ldx <:pInst
	lda [:pMod],y
	xba 			  	; endian
	asl 				; length * 4, because our samples are 2x the size of the samples in the mod, and the length in the file is half the size, to save space
	rol |i_sample_length+2,x
	asl
	rol |i_sample_length+2,x
	sta |i_sample_length,x

;PAL:   7093789.2 / (428 * 2) = 8287.14hz
;NSTC:  7159090.5 / (428 * 2) = 8363.42hz

	; set the sample rate

	lda #8363
	sta |i_sample_rate,x

	; set the key, it happens to be C2

	lda #36 ; midi value for C2, probably won't even be used in Modo
	sta |i_key_center,x

	iny
	iny ; now y is pointing at the fine tune

	lda [:pMod],y
	and #$FF
	sta |i_fine_tune,x

	iny ; now y is pointing at the volume

	lda [:pMod],y
	and #$FF
	sta |i_volume,x

	iny ; now y is pointing at the loop start offset
	lda [:pMod],y
	xba           ; adjust for endian
	; just like the length above, we need to multiply by 2 (because in amiga
	; mod file, this value is half what it should be), we need to multiply by 2
	; 1 more time, because our wave data takes 16 bits
	asl
	rol |i_sample_loop_start+2,x
	asl
	rol |i_sample_loop_start+2,x
	sta |i_sample_loop_start,x     	; this just contains the loop start, as an offset for now

	iny
	iny ; now y is pointing at the loop_length
	lda [:pMod],y
	xba
	stz |i_loop,x
	cmp #2
	bcc :no_loop

	inc |i_loop,x  ; mark it as looping

:no_loop

	;asl
	;rol |i_sample_loop_end+2,x
	;asl
	;rol |i_sample_loop_end+2,x
	;sta |i_sample_loop_end,x  	; this is just the loop length at this point, temporary

	iny
	iny
	sty <:current_y

	lda <:loopCount
	inc
	sta <:loopCount
	cmp #31
	bccl ]inst_fetch_loop

; --- End - Copy Sample Data into the mod_instruments block


	do 0
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

; Copy the string over into the instruments array

;	lda <:loopCount
;	asl
;	tax
;	lda |inst_address_table,x
;	tay							; y is the address of our i_name, for our current instrument
;	ldx #:sample_name           ; x is the source address of the instrument string
;	lda #21
;	mvn ^:sample_name,^mod_instruments

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
	bccl :SampleDumpLoop
	fin
	; --- end Dump out Sample Information

	ldx #0
	ldy #36
	jsr myLOCATE

	; Song Length
	ldx #:song_len
	jsr myPUTS
	ldy <:current_y
	lda [:pMod],y
	and #$FF
	inc
	sta <mod_song_length
	iny
	iny
	sty <:current_y
	jsr myHEXBYTE
	jsr myPRINTCR

	;save off the pointer to pattern directory
	clc
	lda <:pMod
	adc <:current_y
	sta <mod_p_pattern_dir
	lda <:pMod+2
	adc #0
	sta <mod_p_pattern_dir+2
	; initialize our index
	stz <mod_pattern_index

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

:pVRAM = temp7
:pSamp = temp8
:tCount = temp9
:pTemp = temp9
:pLoop = lzsa_sourcePtr
:pEnd  = lzsa_destPtr
:pSrc  = lzsa_matchPtr

	lda #scratch_ram
	sta <:pTemp


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
	do 0     ; old mod->VRAM table print out
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
	fin

	; Save out the start pointers to the wave data, so we can update the mod_instruments when we're done here
	lda <:pVRAM
	sta (:pTemp)
	inc <:pTemp
	inc <:pTemp
	lda <:pVRAM+2
	sta (:pTemp)
	inc <:pTemp
	inc <:pTemp


	ldy #sample_length
	lda [:pInst],y
	beql :skip_empty	; skip, empty entry
	xba					; fix endian
	tax					; x = counter

	; set up the :pLoop
	stz <:pLoop
	stz <:pLoop+2 ; default to no loop

	ldy #sample_loop_start
	lda [:pInst],y
	xba
	bne :itloops

	; maybe it loops
	ldy #sample_loop_length
	lda [:pInst],y
	xba
	cmp #2
	bcc :noloops
	lda #0
:itloops
; A is 1/2 the offset to the loop (there's not enough bits to ASL)

	pha

	; Add it once
	lda <:pVRAM
	adc 1,s
	sta <:pLoop
	lda <:pVRAM+2
	adc #0
	sta <:pLoop+2

	clc
	pla
	; Add it again
	adc <:pLoop
	sta <:pLoop
	lda <:pLoop+2
	adc #0
	sta <:pLoop+2


:noloops

	; :pLoop either points to the source loop address
	;        or :pLoop is nullptr 

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
	dex 			; via mod spec, the actual length is 2x the recorded length
	bne ]waveloop

;------- the mixer needs some buffer space placed on the end of the sample
; for performance reasons the mixer only checks for loop points every 256
; samples, my back of the envelope math says we need a buffer of 1024 samples
; instruments in a mod will never be played at more than 96Khz
; 1024 samples = 2048 bytes.
;
; I currently only support looping from the end of the wave, back to the loop
; point.  If the sample does not loop, we still need this pad space at the end
; and it needs to be filled with silence (non looping samples still loop, but
; can do so in the silence)
;
	; we need a pointer back to the loop point, and need to perform circular
	; copy to fill in the padding, to make the looping work with my mixer

; -- $$ I just realized this is all broken

	ldx #1024 ; we need 1024 more samples

	; pEnd points at the last sample
	sec
	lda <:pVRAM
	sbc #2
	sta <:pEnd
	lda <:pVRAM+2
	sbc #0
	sta <:pEnd+2

	; :pVRAM points at the location the next sample
	; will be stored

	; :pLoop, points to the loop location

	lda <:pLoop
	ora <:pLoop+2
	bne :loop_not_null

	lda <:pEnd
	sta <:pLoop
	lda <:pEnd+2
	sta <:pLoop+2

:loop_not_null

	lda <:pLoop
	sta <:pSrc
	lda <:pLoop+2
	sta <:pSrc+2

; here we have out sample count in x
; we have valid pointers in
; :pVRAM
; :pLoop
; :pEnd
; :pSrc

]padding_loop
	lda [:pSrc]
	sta [:pVRAM]

; increment output 1 location - straight forward
	clc
	lda <:pVRAM
	adc #2
	sta <:pVRAM
	lda <:pVRAM+2
	adc #0
	sta <:pVRAM+2

; increment source location
	lda <:pSrc
	adc #2
	sta <:pSrc
	lda <:pSrc+2
	adc #0
	sta <:pSrc+2

; if source is > pEnd
; then source = pLoop

	cmp <:pEnd+2
	bcc :pad_continue
	bne :pad_reset

	lda <:pSrc
	cmp <:pEnd
	bcc :pad_continue
	beq :pad_continue

:pad_reset

	lda <:pLoop
	sta <:pSrc
	lda <:pLoop+2
	sta <:pSrc+2

:pad_continue
	dex
	bne ]padding_loop

;$$JGA Temp hack, to keep samples from spanning banks
;$$JGA TODO, REMOVE THIS CODE WHEN BANK SPANNER IS WORKING

	inc <:pVRAM+2
	stz <:pVRAM


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
; init the mod_patterns table
:pCurPattern = 44

	lda <:pPatterns
	sta <:pCurPattern
	lda <:pPatterns+2
	sta <:pCurPattern+2

	clc

	ldx #127
	ldy #0
]lp
	lda <:pCurPattern
	sta |mod_patterns,y
	adc #1024  ; 64*4*4
	sta <:pCurPattern

	lda <:pCurPattern+2
	sta |mod_patterns+2,y
	adc #0
	sta <:pCurPattern+2

	tya
	adc #4
	tay
	dex
	bpl ]lp

; -----------------------------------------------------------------------------
; Print out the contents of a Pattern Block
	do 0
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
	fin

; -----------------------------------------------------------------------------

; finish fixing up the mod_instruments
; now that we know where they live in memory

	ldx #mod_instruments-MyDP
	lda #scratch_ram
	sta <:pTemp

	ldy #31

]loop
	lda (:pTemp)
	inc <:pTemp
	inc <:pTemp
	sta <i_sample_start_addr,x
	lda (:pTemp)
	inc <:pTemp
	inc <:pTemp
	sta <i_sample_start_addr+2,x

	; if the loop start is 0
	lda <i_sample_loop_start,x
	ora <i_sample_loop_start+2,x
	bne :doesloop

	lda <i_loop,x
	bne :doesloop

	; does not loop

	lda <i_sample_length,x
	sta <i_sample_loop_start,x
	lda <i_sample_length+2,x
	sta <i_sample_loop_start+2,x

:doesloop
	clc
	lda <i_sample_start_addr,x
	adc <i_sample_loop_start,x
	sta <i_sample_loop_start,x
	lda <i_sample_start_addr+2,x
	adc <i_sample_loop_start+2,x
	sta <i_sample_loop_start+2,x

	clc
	lda <i_sample_start_addr,x
	adc <i_sample_length,x
	sta <i_sample_loop_end,x
	lda <i_sample_start_addr+2,x
	adc <i_sample_length+2,x
	sta <i_sample_loop_end+2,x

	clc
	lda <i_sample_loop_end,x
	adc #1024*2 ; make 4.0 play rate
	sta <:pEnd
	lda <i_sample_loop_end+2,x
	adc #0
	sta <:pEnd+2

	stz <i_sample_spans_bank,x


;	lda <:pEnd+2
	cmp <i_sample_start_addr+2,x
	beq :no_span

	; flag it as spanning bank, expensive resample
	inc <i_sample_spans_bank,x
:no_span
	clc
	txa
	adc #sizeof_inst
	tax
	dey
	bne ]loop

; -----------------------------------------------------------------------------
; alternate instrument dump, based on mod_instruments

	do 1

	ldx #mod_instruments-MyDP
	stx <:pInst

	stz <:loopCount
]loop

	ldx #0
	lda <:loopCount
	clc
	adc #5
	sta <:current_y  ; for y position on the screen in this case

	tay
	jsr fastLOCATE

	lda <:loopCount
	jsr fastHEXBYTE

	lda #' '
	fastPUTC

	; Instrument name
	clc
	lda <:pInst
	adc #MyDP
	tax
	jsr fastPUTS

	ldy <:current_y
	ldx #28
	jsr fastLOCATE

	; Sample Length in bytes
	ldx #:sample_length
	jsr fastPUTS

	ldx <:pInst
	lda <i_sample_length+2,x
	jsr fastHEXBYTE
	ldx <:pInst
	lda <i_sample_length,x
	jsr fastHEXWORD

	lda #' '
	fastPUTC

	; Fine Tune
	ldx #:fine_tune
	jsr fastPUTS
	ldx <:pInst
	lda <i_fine_tune,x
	jsr fastHEXBYTE
	lda #' '
	fastPUTC

	; Volume
	ldx #:volume
	jsr fastPUTS
	ldx <:pInst
	lda <i_volume,x
	jsr fastHEXBYTE
	;lda #' '
	;fastPUTC

	; Wave Start
	ldx #:sample_start
	jsr fastPUTS
	ldx <:pInst
	lda <i_sample_start_addr+2,x
	jsr fastHEXBYTE
	ldx <:pInst
	lda <i_sample_start_addr,x
	jsr fastHEXWORD 
	lda #' '
	fastPUTC

	; Loop Start
	ldx #:loop_start
	jsr fastPUTS
	ldx <:pInst
	lda <i_sample_loop_start+2,x
	jsr fastHEXBYTE
	ldx <:pInst
	lda <i_sample_loop_start,x
	jsr fastHEXWORD
	;lda #' '
	;fastPUTC

	; end
	ldx #:sample_end
	jsr fastPUTS
	ldx <:pInst
	lda <i_sample_loop_end+2,x
	jsr fastHEXBYTE
	ldx <:pInst
	lda <i_sample_loop_end,x
	jsr fastHEXWORD

	ldx <:pInst
	lda <i_sample_spans_bank,x
	beq :no_bank_problem

	lda #'*'
	fastPUTC

:no_bank_problem

	clc
	lda <:pInst
	adc #sizeof_inst
	sta <:pInst

	lda <:loopCount
	inc
	sta <:loopCount
	cmp #31
	bccl ]loop

	fin

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
:sample_start asc ' start:'
	db 0
:sample_end asc ' end:'
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
:pRow = temp5
:cur_row = temp6

	lda <:cur_row
	and #$3F
	jsr fastHEXBYTE

	lda #'|'
	fastPUTC

	ldy #2
	lda [:pRow],y
	tax
	lda [:pRow]
	jsr PrintNoteInfo

	lda #'|'
	fastPUTC

	ldy #6
	lda [:pRow],y
	tax
	ldy #4
	lda [:pRow],y
	jsr PrintNoteInfo

	lda #'|'
	fastPUTC

	ldy #10
	lda [:pRow],y
	tax
	ldy #8
	lda [:pRow],y
	jsr PrintNoteInfo

	lda #'|'
	fastPUTC

	ldy #14
	lda [:pRow],y
	tax
	ldy #12
	lda [:pRow],y
	jsr PrintNoteInfo

	lda #'| '
	fastPUTC
	inc <pFastPut
	rts

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
	;sep #$20
	;lsr
	;lsr
	;lsr
	;lsr
	rep #$30
	xba
	and #$0FFF
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
	jsr fastPUTS

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
	dw 214/2,202/2,190/2,180/2,170/2,160/2,151/2,143/2,135/2,127/2,120/2,113/2 ; C-4 to B-4
	dw 214/4,202/4,190/4,180/4,170/4,160/4,151/4,143/4,135/4,127/4,120/4,113/4 ; C-5 to B-5
	dw 214/8,202/8,190/8,180/8,170/8,160/8,151/8,143/8,135/8,127/8,120/8,113/8 ; C-6 to B-6

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

	put colors.s
	put i256.s
	put dma.s

;------------------------------------------------------------------------------
fastLOCATE mx %00
	tya
	asl  ; c=0
	tay
	txa
	adc |screen_table,y
	sta <pFastPut
	lda #^CS_TEXT_MEM_PTR
	sta <pFastPut+2
	rts

screen_table
]var = CS_TEXT_MEM_PTR
	lup 75
	da ]var
]var = ]var+100
	--^
;------------------------------------------------------------------------------
fastHEXWORD mx %00
		pha
		xba
		jsr fastHEXBYTE
		pla
		; --- fall through
;------------------------------------------------------------------------------
fastHEXBYTE mx %00
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

		lda |:temp
		fastPUTC
		inc <pFastPut
		rts

:chars  ASC '0123456789ABCDEF'

:temp	ds  3

;------------------------------------------------------------------------------

logo_pic_init mx %00

;
; Configure the Width and Height of the Tilemap, based on the width
; and height stored in our file
;

		lda #logo_pic
		ldx #^logo_pic
		jsr c256Init		;$$JGA TODO, make sure better

		; Tile Map Width, and Height

		ldy #8  ; TMAP width offset
		lda [pTMAP],y
		sta >TL3_TOTAL_X_SIZE_L
		iny
		iny     ; TMAP height offset
		lda [pTMAP],y
		inc
		and #$FFFE
		sta >TL3_TOTAL_Y_SIZE_L

;
; Extract CLUT data from the piano image
;

		; source image
		pea ^logo_pic
		pea logo_pic

		; dest address			; Testing new smart decompress
		pea ^GRPH_LUT0_PTR
		pea GRPH_LUT0_PTR

		jsl decompress_clut

;
; Extract Tiles Data
;

		; source picture
		pea ^logo_pic
		pea logo_pic

		; destination address
		pea ^VRAM_TILE_CAT
		pea VRAM_TILE_CAT

		jsl decompress_pixels

;
; Extract Map Data
;

		; source picture
		pea ^logo_pic
		pea logo_pic

		; destination address
		pea ^VRAM_LOGO_MAP
		pea VRAM_LOGO_MAP

		jsl decompress_map

;
; Set Scroll Registers, and enable TL3
;

		lda #0
		; Tile maps off
		sta >TL0_CONTROL_REG
		sta >TL1_CONTROL_REG
		sta >TL2_CONTROL_REG
		sta >TL3_CONTROL_REG
		
		; turn on tile map 3
		lda #TILE_Enable
		sta >TL3_CONTROL_REG
		lda #{VRAM_LOGO_MAP-VRAM}
		sta >TL3_START_ADDY_L
		sep #$30
		lda #^{VRAM_LOGO_MAP-VRAM}
		sta >TL3_START_ADDY_H
		rep #$30
		
		lda #0
		sta >TL0_WINDOW_X_POS_L
		sta >TL0_WINDOW_Y_POS_L
		sta >TL1_WINDOW_X_POS_L
		sta >TL1_WINDOW_Y_POS_L
		sta >TL2_WINDOW_X_POS_L
		sta >TL2_WINDOW_Y_POS_L

		sta >TL3_WINDOW_X_POS_L
		lda #24
		sta >TL3_WINDOW_Y_POS_L

		; catalog data
		lda #{VRAM_TILE_CAT-VRAM}
		sta >TILESET0_ADDY_L
		sta >TILESET1_ADDY_L
		sta >TILESET2_ADDY_L
		sta >TILESET3_ADDY_L
		sta >TILESET4_ADDY_L
		sta >TILESET5_ADDY_L
		sta >TILESET6_ADDY_L
		sta >TILESET7_ADDY_L
		lda #^{VRAM_TILE_CAT-VRAM}
		sta >TILESET0_ADDY_H
		inc
		sta >TILESET1_ADDY_H	    ; by placing the next tileset after the first, we expand support to 512 tiles
		inc
		sta >TILESET2_ADDY_H
		inc
		sta >TILESET3_ADDY_H
		inc
		sta >TILESET4_ADDY_H
		inc
		sta >TILESET5_ADDY_H
		inc
		sta >TILESET6_ADDY_H
		inc
		sta >TILESET7_ADDY_H


		rts

;------------------------------------------------------------------------------
ReadKeyboard mx %00
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

	; this is he actual keyboard driver, just reflects keystatus
	; into the keyboard array

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

	; end keyboard driver

	; I keep history here, for debugging
		do 1
		ldx |:index     	; current index
		sta |:history,x 	; save in history
		dex
		dex     		; next index
		bpl :continue
		ldx #{HISTORY_SIZE*2}-2 ; index wrap
:continue
		stx |:index     	; save index for next time
		fin

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
		jsr fastLOCATE

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
		jsr fastHEXBYTE
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
inst_address_table
]index = 0
		lup 32
		da mod_instruments+{]index*sizeof_inst}
]index = ]index+1
		--^
;------------------------------------------------------------------------------

; Non Initialized spaced

	dum *+$2100  ; pirate! (this is cheating, these addresses are not relocatable)
	             ; so org of this file has to be $2100, and if anyone trys to
				 ; move the location, this will break
uninitialized_start ds 0
;------------------------------------------------------------------------------
;
; Clut Buffer
;
pal_buffer
		ds 1024

	        ds \             ; 256 byte align, for quicker piano update
mixer_dpage ds 256		  	 ; mixer gets it's own DP

keyboard   ds 128
latch_keys ds 128			 ; hybrid latch memory

mod_instruments ds sizeof_inst*32  ; Really a normal mod only has 31 of them

;
; Precomputed pointers to patterns
;
mod_patterns
	ds 128*4

scratch_ram ds 1024

uninitialized_end ds 0
	dend

