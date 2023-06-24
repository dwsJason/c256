;
; my custom 8x8 font
;
		rel
		lnk font.l

		; Vicky
		use ../phx/vicky_ii_def.asm
		use ../phx/page_00_inc.asm
		put macros.s

		mx %00
;------------------------------------------------------------------------------

FontInit ent
		; copy up a font

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
]copy  	; copy up new glyphs
		lda |shaston,x
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
		cpx #100*50  ; top 50 lines are white, below that dark grey
		bcc :white
		lda #$5656   ; dark grey
:white
		sta |CS_COLOR_MEM_PTR,x
		dex
		dex
		bpl ]lp

		plb

		lda >gs_colors+{4*6}
		sta >BACKGROUND_COLOR_B
		lda >gs_colors+{4*6}+1
		sta >BACKGROUND_COLOR_G

		php

		sep #$30
		lda #$F6
		sta >CURCOLOR

		plp
		mx %00
		rtl

;------------------------------------------------------------------------------

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

shaston
	putbin data\Shaston8.font




