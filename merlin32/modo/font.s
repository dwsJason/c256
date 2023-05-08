;
; my custom 8x8 font
;
		rel
		lnk font.l

		; Vicky
		use phx/vicky_ii_def.asm


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
		rtl

;------------------------------------------------------------------------------

shaston
	putbin data\Shaston8.font




