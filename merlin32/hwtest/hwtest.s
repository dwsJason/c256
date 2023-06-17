;
; Fun hwtest Demo, in Merlin32
;
;
; $00:2000 - $00:7FFF are free for application use.
;
        rel     ; relocatable
        lnk     Main.l

		; hardware includes from the kernel source code
		put ..\phx\vicky_ii_def.asm
		put ..\phx\VKYII_CFP9553_SDMA_def.asm
		put ..\phx\VKYII_CFP9553_SPRITE_def.asm
		put ..\phx\VKYII_CFP9553_TILEMAP_def.asm
		put ..\phx\interrupt_def.asm
		use ../phx/timer_def.asm
		put ..\phx\Math_def.asm

		; kernel things
		put ..\phx\kernel_inc.asm

		; my conventient long branch macros
		use macs.i
		
		; linked data, and routines
		ext decompress_lzsa
		ext jr_font_lz

        mx %00

;------------------------------------------------------------------------------
; Direct Page Equates
;------------------------------------------------------------------------------
		put dp.i.s
			  
			  
CLOCKS_PER_SECOND equ 14318180
			  
;
; Decompress to this address
;
work_buffer = $100000	; $$TODO Refactor code so this only ever needs 64k
		
; Some HW Addresses - Defines

VRAM = $B00000

;------------------------------------------------------------------------------
; I like having my own Direct Page

start   ent             ; make sure start is visible outside the file
		  
        clc
        xce
        rep $31         ; long MX, and CLC
		sei				; keep interrupts off, until we're ready for them

		; I added this here, to allow iteration to be more stable
		; (if my code had overritten any of these, and now has shifted)
		lda #$6B  ; RTL
		sta >VEC_INT00_SOF
		sta >VEC_INT01_SOL
		sta >VEC_INT02_TMR0
		sta >VEC_INT03_TMR1
		sta >VEC_INT04_TMR2

		lda #$FF
		sta >INT_MASK_REG0
		sta >INT_MASK_REG1
		sta >INT_MASK_REG2
		sta >INT_MASK_REG3


; Default Stack is on top of System DMA Registers
; So move the stack before proceeding

        lda #$BFFF      ; I really don't know much RAM the kernel is using in bank 0
        tcs

        lda #MyDP
        tcd

		stz <dpJiffy
		stz <dpTimer0
		stz <dpTimer1
		stz <dpTimer2

		phk
		plb

		; Initialize the uninitialized RAM
		stz |uninitialized_start
		ldx #uninitialized_start
		ldy #uninitialized_start+2
		lda #{uninitialized_end-uninitialized_start}-3
		mvn ^uninitialized_start,^uninitialized_start

		jsr video_init

		jsr font_init

		jsr InstallJiffy
		jsr InstallTimer0
		jsr InstallTimer1

;------------------------------------------------------------------------------
; Initial Static Text
		ldx #13
		ldy #1
		jsr fastLOCATE

		ldx #txt_version
		jsr fastPUTS

		ldx #1
		ldy #19
		jsr fastLOCATE
		ldx #txt_xlabel
		jsr fastPUTS

		ldx #1
		ldy #20
		jsr fastLOCATE

		ldx #txt_labels
		jsr fastPUTS


;------------------------------------------------------------------------------

		jsr DisableTimer0
		jsr DisableTimer1

		ldx #6
		ldy #6
		jsr fastLOCATE

		ldx #txt_test_sof
		jsr fastPUTS

		cli

		lda #CLOCKS_PER_SECOND
		sta <temp0
		lda #^CLOCKS_PER_SECOND
		sta <temp0+2


		ldy <dpJiffy
]loop
		lda <temp0
		ora <temp0+2
		beq :fail

		cpy <dpJiffy
		bne :pass

		dec <temp0
		bne ]loop

		dec <temp0+2
		bne ]loop

:fail
		ldx #txt_fail
		bra :next
:pass
		ldx #txt_ok
:next
		jsr fastPUTS

;------------------------------------------------------------------------------
UpdateLoop
		bra UpdateLoop

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

HelloText asc 'Hello from Merlin32!'
        db 13,0

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

;		cli
		rts

;
; dpJiffy is a rolling timer, it can be used to help seed RNG
; or to know how many frames were missed (if you want to know that your
; game is slowing down, and compensate)
;

:JiffyTimer
		phb
		phk
		plb
		php
		phd
		rep #$30
		pea MyDP
		pld

		pei pFastPut
		pei pFastPut+2

		inc <dpJiffy

		; so we can visualize the counter
		ldx #5
		ldy #20
		jsr fastLOCATE

		lda <dpJiffy
		jsr fastHEXWORD

		ldx #17
		ldy #20
		jsr fastLOCATE
		lda <dpTimer0
		jsr fastHEXWORD

		ldx #29
		ldy #20
		jsr fastLOCATE
		lda <dpTimer1
		jsr fastHEXWORD

		ldx #41
		ldy #20
		jsr fastLOCATE
		lda <dpTimer2
;		jsr fastHEXWORD


		pla
		sta <pFastPut+2
		pla
		sta <pFastPut

		pld
		plp
		plb
		rtl

;------------------------------------------------------------------------------
InstallTimer0 mx %00

:RATE equ 14318180/120

		sei

		lda #$5C
		sta |VEC_INT02_TMR0

		lda #:timer0
		sta |VEC_INT02_TMR0+1

		lda #>:timer0
		sta |VEC_INT02_TMR0+2

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

		lda	#FNX0_INT02_TMR0
		trb |INT_MASK_REG0

		rep #$31

		rts
:timer0
		php
		phd
		pea MyDP
		pld
		rep #$30
		inc <dpTimer0
		pld
		plp
		rtl

;------------------------------------------------------------------------------
DisableTimer0 mx %00
		php
		sei

		sep #$30
		stz |TIMER0_CTRL_REG
		lda #FNX0_INT02_TMR0
		tsb |INT_MASK_REG0

		lda >INT_PENDING_REG0
		and #FNX0_INT02_TMR0
		sta >INT_PENDING_REG0

		plp
		rts

;------------------------------------------------------------------------------
InstallTimer1 mx %00

:RATE equ 14318180/240

		sei

		lda #$5C
		sta |VEC_INT03_TMR1

		lda #:timer1
		sta |VEC_INT03_TMR1+1

		lda #>:timer1
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

		lda	#FNX0_INT03_TMR1
		trb |INT_MASK_REG0

		rep #$31

		rts
:timer1
		php
		phd
		pea MyDP
		pld
		rep #$30
		inc <dpTimer1
		pld
		plp
		rtl

;------------------------------------------------------------------------------
DisableTimer1 mx %00
		php
		sei

		sep #$30
		stz |TIMER1_CTRL_REG
		lda #FNX0_INT03_TMR1
		tsb |INT_MASK_REG0

		lda >INT_PENDING_REG0
		and #FNX0_INT03_TMR1
		sta >INT_PENDING_REG0

		plp
		rts


;------------------------------------------------------------------------------
InstallTimer2 mx %00

:RATE equ 14318180/480

		sei

		lda #$5C
		sta |VEC_INT04_TMR2

		lda #:timer2
		sta |VEC_INT04_TMR2+1

		lda #>:timer2
		sta |VEC_INT04_TMR2+2

		sep #$30

		stz |TIMER2_CHARGE_L
		stz |TIMER2_CHARGE_M
		stz |TIMER2_CHARGE_H

		lda #<:RATE
		sta |TIMER2_CMP_L
		lda #>:RATE
		sta |TIMER2_CMP_M
		lda #^:RATE
		sta |TIMER2_CMP_H

		lda #TMR2_CMP_RECLR
		sta |TIMER2_CMP_REG
		lda #TMR2_EN+TMR2_UPDWN+TMR2_SCLR
		sta |TIMER2_CTRL_REG

		lda	#FNX0_INT04_TMR2
		;trb |INT_MASK_REG0

		rep #$31

		rts
:timer2
		php
		phd
		pea MyDP
		pld
		rep #$30
		inc <dpTimer2
		pld
		plp
		rtl


;------------------------------------------------------------------------------
; WaitJiffy
; Preserve all registers
;
WaitJiffy
		pha
		lda <dpJiffy
]lp
		cmp <dpJiffy
		beq ]lp
		pla
		rts

;------------------------------------------------------------------------------

video_init mx %00

		; 400x300
		lda #$300+Mstr_Ctrl_GAMMA_En+Mstr_Ctrl_Text_Mode_En+Mstr_Ctrl_Text_Overlay
		sta >MASTER_CTRL_REG_L

		; No Border
		lda #0
		sta >BORDER_X_SIZE    ; also sets the BORDER_Y_SIZE
		
		; Tile maps off
		sta >TL0_CONTROL_REG
		sta >TL1_CONTROL_REG
		sta >TL2_CONTROL_REG
		sta >TL3_CONTROL_REG
		
; Hide the Mouse
		sta >MOUSE_PTR_CTRL_REG_L

		rts
;------------------------------------------------------------------------------
;
; Load F256Jr font in to character memory, clear the TEXT screen, etc.
; Probably this should just be the official C256 font
;
font_init mx %00

		; Decompress the Font
		pea ^jr_font_lz
		pea jr_font_lz

		pea ^work_buffer
		pea work_buffer

		jsl decompress_lzsa

		; Copy the Font into the font glyph area
		ldx #2048-2
]lp
		lda >work_buffer,x
		sta >FONT_MEMORY_BANK0,x
		sta >FONT_MEMORY_BANK1,x
		dex
		dex
		bpl ]lp

		; cursor, and other text buffer "stuff"
		lda #0
		sta >VKY_TXT_CURSOR_CTRL_REG  ; I don't want flashing cursor
		sta >VKY_TXT_START_ADD_PTR    ; I don't understand how this works

		phkb ^CS_TEXT_MEM_PTR
		plb
		; setup colors
		; Copy GS colors into the Text Color Memory
		ldx #{16*4}-4
]lp
		lda >gs_colors,x
		sta |BG_CHAR_LUT_PTR,x
		sta |FG_CHAR_LUT_PTR,x
		lda >gs_colors+2,x
		sta |BG_CHAR_LUT_PTR+2,x
		sta |FG_CHAR_LUT_PTR+2,x
		dex
		dex
		dex
		dex
		bpl ]lp


		; clear out the text memory, and the color memory

		ldx #$2000-2
]lp
		lda #'  '    ; clear with spaces
		sta |CS_TEXT_MEM_PTR,x
		lda #$F6F6   ; white on medium blue
		sta |CS_COLOR_MEM_PTR,x
		dex
		dex
		bpl ]lp

		plb
		rts

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

; blueprint blue
; this.BlueButton.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(17)))), ((int)(((byte)(110)))), ((int)(((byte)(169)))));
bp_blue adrl $ff116EA9


;------------------------------------------------------------------------------
; fast text crap
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
	lup 38
	da ]var
]var = ]var+50
	--^
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
fastHEXWORD mx %00
		pha
		xba
		jsr fastHEXBYTE
		pla
		bra fastHEXBYTE

;------------------------------------------------------------------------------
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
txt_version cstr 'C256 Mini Interrupt Test'
;txt_labels  cstr 'SOF:     TIMER0:     TIMER1:     TIMER2:'
;txt_xlabel  cstr ' 1X        2X          4x          8X'

txt_labels  cstr 'SOF:     TIMER0:     TIMER1:'
txt_xlabel  cstr ' 1X        2X          4x'

txt_test_sof  cstr 'TESTING  SOF:'
txt_test_tmr0 cstr 'TESTING TMR0:'
txt_test_tmr1 cstr 'TESTING TMR1:'

txt_ok   cstr 'OK'
txt_fail cstr 'FAIL'

;------------------------------------------------------------------------------

; Non Initialized spaced

	dum *+$2100  ; pirate! (this is cheating, these addresses are not relocatable)
	             ; so org of this file has to be $2100, and if anyone trys to
				 ; move the location, this will break
uninitialized_start ds 0
;------------------------------------------------------------------------------
;
; Clut Buffer, we don't even need this, but it's nice to have something here
; so that if we decide we need some variables, they don't have to increase
; the size of our executable
;
pal_buffer
		ds 1024

uninitialized_end ds 0
	dend


