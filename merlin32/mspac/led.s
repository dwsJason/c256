;
; LED Light Show for Foenix U
;
;------------------------------------------------------------------------------

LightShow mx %00

		do 1
		; Foenix U - Light Show
		phk
		plb
		ldy #0  ; color table index

		ldx #0  ; led array index
]loop
		jsr WaitVBL
		lda |:colors,y
		sta >$AF4400,x
		lda |:colors+2,y
		sta >$AF4400+2,x

		inx
		inx
		inx
		inx
		cpx #30*4
		bcc ]loop
		ldx #0

		iny
		iny
		iny
		iny
		cpy #8*4
		bcc ]loop
		ldy #0

		jmp ]loop


:colors
		hex FFFFFFFF  ; white
		hex FF0000FF  ; blue
		hex 00FF00FF  ; green
		hex 0000FFFF  ; red
		hex 000000FF  ; black
		hex FFFF00FF  ; blue
		hex FF00FFFF  ; purple
		hex 00FFFFFF  ; yello

		fin

;------------------------------------------------------------------------------

