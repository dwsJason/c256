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
		jsr InstallJiffy
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


        ldx #HelloText
        jsl PUTS

		phk
		plb
		lda #0
		ldx #0
]clear  sta >$AF8000,x
		inx
		inx
		cpx #$1000
		bcc ]clear

		ldx #0
]copy   ;lda >nicefont,x
		lda >shaston,x
		sta >$AF8100,x
		inx
		inx
		cpx #768
		bcc ]copy

]lp
        bra ]lp

HelloText asc "Hello from J-Mixer!"
        db 13,0



;------------------------------------------------------------------------------
; WaitVBL
; Preserve all registers
;
WaitVBL
		pha
		stz <dpJiffy
]lp
		lda <dpJiffy
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

:Text   asc 'Jason''s Mixer'
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
		inc |{MyDP+dpJiffy}
		plb
		rtl

;------------------------------------------------------------------------------

