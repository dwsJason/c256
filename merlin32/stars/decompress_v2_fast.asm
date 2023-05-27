; -----------------------------------------------------------------------------
; Decompress raw LZSA2 block.
; Create one with lzsa -r -f2 <original_file> <compressed_file>
;
; in:
; * sourcePtr contains the compressed raw block address
; * destPtr contains the destination buffer address
;
; Backward decompression is not supported
; -----------------------------------------------------------------------------
;
;  Copyright (C) 2019-2021 Emmanuel Marty, Peter Ferrie, Ian Brumby
;
;  This software is provided 'as-is', without any express or implied
;  warranty.  In no event will the authors be held liable for any damages
;  arising from the use of this software.
;
;  Permission is granted to anyone to use this software for any purpose,
;  including commercial applications, and to alter it and redistribute it
;  freely, subject to the following restrictions:
;
;  1. The origin of this software must not be misrepresented; you must not
;     claim that you wrote the original software. If you use this software
;     in a product, an acknowledgment in the product documentation would be
;     appreciated but is not required.
;  2. Altered source versions must be plainly marked as such, and must not be
;     misrepresented as being the original software.
;  3. This notice may not be removed or altered from any source distribution.
; -----------------------------------------------------------------------------


DECOMPRESS_LZSA2	mx %00 			;start

MIN_MATCH_SIZE_V2   equ 2
LITERALS_RUN_LEN_V2 equ 3
MATCH_RUN_LEN_V2    equ 7

sourcePtr  equ 0
destPtr    equ 4
matchPtr   equ 8
NIBBLE     equ	12
SUB_OFFSET equ 14
TOKEN_WORD equ 16

	stz	NIBBLE

DECODE_TOKEN anop

	ldy	#1
	lda	[sourcePtr]	;read token byte: XYZ|LL|MMM
	sta	TOKEN_WORD
	and	#%00011000	;isolate literals count (LL)
	beq	NO_LITERALS	;skip if no literals to copy
	cmp	#%00010000
	beq	COPY_16BIT_LITERAL
	cmp	#%00001000
	beq	COPY_8BIT_LITERAL

;--------------------------------
	lda	NIBBLE	;get extra literals length nibble
	bpl	GETNIBBLE
	and	#$0F
	sta	NIBBLE
	clc
	bra	GOTNIBBLE

GETNIBBLE anop
	lda	TOKEN_WORD+1
	iny
	ora	#$8000
	sta	NIBBLE
	and	#$F0
	lsr
	lsr
	lsr
	lsr

GOTNIBBLE anop		;add nibble to len from token
;--------------------------------
	adc	#LITERALS_RUN_LEN_V2	;carry is clear
	cmp	#LITERALS_RUN_LEN_V2+15
	bcc	PREPARE_COPY_LITERALS_DIRECT	;if less, literals count is complete

	lda	[sourcePtr],y
	iny
	and	#$FF	;get extra byte of variable literals count. carry is always set.
	sbc	#$EE	;overflow?
	bcs	PREPARE_COPY_LITERALS_LARGE	;if so, literals count is large
	and	#$FF
	bra	PREPARE_COPY_LITERALS_DIRECT

COPY_16BIT_LITERAL anop
	lda	[sourcePtr],y
	iny
	iny
	sta	[destPtr]
	lda	destPtr
	adc	#2-1	;carry is set
	sta	destPtr
	bcc	NO_LITERALS
	inc	destPtr+2
	bra	NO_LITERALS

COPY_8BIT_LITERAL anop
	mx %10
	sep #$20
	lda	TOKEN_WORD+1
	iny
	sta	[destPtr]
	rep #$30
	mx %00
	inc	destPtr
	bne	NO_LITERALS
	inc	destPtr+2
	bra	NO_LITERALS

PREPARE_COPY_LITERALS_LARGE anop
	lda	[sourcePtr],y
	iny
	iny	
PREPARE_COPY_LITERALS_DIRECT anop
	tax

COPY_LITERALS anop
	sep #$20 ; short m
	mx %10
	lda	[sourcePtr],y
	sta	[destPtr]
	rep #$30 ;long	m
    mx %00
	inc	destPtr
	bne	CL2
	inc	destPtr+2
CL2	iny
	dex
	bne	COPY_LITERALS

NO_LITERALS anop
	lda	TOKEN_WORD-1	;retrieve token again, but put it in the high 8 bits
	asl
	bcs	REPMATCH_OR_LARGE_OFFSET	;1YZ: rep-match or 13/16 bit offset

	asl			;0YZ: 5 or 9 bit offset
	bcs	OFFSET_9_BIT         

;--------------------------------
	asl			;00Z: 5 bit offset
	bcc	OFFSET5_BIT0_SET
	lda	NIBBLE
	bpl	GETNIBBLE2
	and	#$0F
	sta	NIBBLE
	asl					;nibble -> bits 1-4; 0 -> bit 0
	ora	#$FFE0			;set offset bits 15-5 to 1
	jmp	GOT_OFFSET		;go store low byte of match offset and prepare match

GETNIBBLE2 anop
	lda	[sourcePtr],y
	iny
	ora	#$8000
	sta	NIBBLE
	and	#$F0
	lsr
	lsr
	lsr					;nibble -> bits 1-4; 0 -> bit 0
	ora	#$FFE0			;set offset bits 15-5 to 1
	jmp	GOT_OFFSET		;go store low byte of match offset and prepare match

OFFSET5_BIT0_SET anop
	lda	NIBBLE
	bpl	GETNIBBLE3
	and	#$0F
	sta	NIBBLE
	asl					;nibble -> bits 1-4
	ora	#$FFE1			;set offset bits 15-5 to 1, bit 0 to 1
	bra	GOT_OFFSET		;go store low byte of match offset and prepare match

GETNIBBLE3 anop
	lda	[sourcePtr],y
	iny
	ora	#$8000
	sta	NIBBLE
	and	#$F0
	lsr
	lsr
	lsr
	ora	#$FFE1			;set offset bits 15-5 to 1, bit 0 to 1
	bra	GOT_OFFSET		;go store low byte of match offset and prepare match
;--------------------------------

OFFSET_9_BIT anop		;01Z: 9 bit offset
	asl					;a
	bcc	OFF01Z_SET_BIT8
	lda	[sourcePtr],y
	iny
	and	#$00FF
	ora	#$FE00	;set offset bits 15-9 to 1
	bra	GOT_OFFSET

OFF01Z_SET_BIT8 anop
	lda	[sourcePtr],y
	iny
	ora	#$FF00	;set offset bits 15-8 to 1
	bra	GOT_OFFSET
;--------------------------------

REPMATCH_OR_LARGE_OFFSET anop
	asl			;a	13 bit offset?
	bcs	REPMATCH_OR_16_BIT	;handle rep-match or 16-bit offset if not

;--------------------------------
	asl			;a	10Z: 13 bit offset
	bcc	OFFSET13_BIT0_SET
	lda	NIBBLE
	bpl	GETNIBBLE4
	and	#$0F
	sta	NIBBLE
	asl
	bra	SET_15_13

GETNIBBLE4 anop
	lda	[sourcePtr],y
	iny
	ora	#$8000
	sta	NIBBLE
	and	#$F0
	lsr
	lsr
	lsr
	bra	SET_15_13

OFFSET13_BIT0_SET anop
	lda	NIBBLE
	bpl	GETNIBBLE5
	and	#$0F
	sta	NIBBLE
	sec
	rol
	bra	SET_15_13

GETNIBBLE5 anop
	lda	[sourcePtr],y
	iny
	ora	#$8000
	sta	NIBBLE
	and	#$F0
	lsr
	lsr
	lsr
	ora	#1

SET_15_13 anop
	adc	#$DE	;set bits 15-13 to 1 and subtract 2 (to subtract 512)
	xba
	sep #$20 ;short	m
	mx %10
	lda	[sourcePtr],y
	rep #$30 ;long	m
	mx %00
	iny
	bra	GOT_OFFSET
;--------------------------------

REPMATCH_OR_16_BIT anop		;rep-match or 16 bit offset
	bmi	REP_MATCH			; XYZ=111? reuse previous offset if so (rep-match)
   
	lda	[sourcePtr],y		;110: handle 16 bit offset
	iny
	iny
	xba
GOT_OFFSET anop
	eor	#$FFFF				; TODO: eliminate 2's complement
	inc
	sta	SUB_OFFSET
REP_MATCH anop
	lda	destPtr
	sec
	sbc	SUB_OFFSET
	sta	matchPtr			;store back reference address
	lda	destPtr+2
	sbc	#0
	sta	matchPtr+2

	lda	TOKEN_WORD			;retrieve token again
	and	#%00000111			;isolate match len (MMM)
	adc	#MIN_MATCH_SIZE_V2-1	;carry set
	cmp	#MIN_MATCH_SIZE_V2+MATCH_RUN_LEN_V2
	bcc	PREPARE_COPY_MATCH	;if less, length is directly embedded in token

;--------------------------------
	lda	NIBBLE				;get extra match length nibble
	bpl	GETNIBBLE6
	and	#$0F
	sta	NIBBLE
	clc
	bra	GOT_EXTRA_MATCH_LEN

GETNIBBLE6 anop
	lda	[sourcePtr],y
	iny
	ora	#$8000
	sta	NIBBLE
	and	#$F0
	lsr
	lsr
	lsr
	lsr

GOT_EXTRA_MATCH_LEN anop
;--------------------------------
	adc	#MIN_MATCH_SIZE_V2+MATCH_RUN_LEN_V2
	cmp	#MIN_MATCH_SIZE_V2+MATCH_RUN_LEN_V2+15
	bcc	PREPARE_COPY_MATCH	;if less, match length is complete

	lda	[sourcePtr],y	;get extra byte of variable match length
	and	#$FF
	iny		;carry is set
	sbc	#$E8	;overflow?
	and	#$FF

PREPARE_COPY_MATCH anop
	tax
	bcc	PREPARE_COPY_MATCH2	;if not, the match length is complete
	beq	DECOMPRESSION_DONE	;if EOD code, bail

	lda	[sourcePtr],y
	iny
	iny
	tax
	clc

PREPARE_COPY_MATCH2 anop
	tya
	adc	sourcePtr
	sta	sourcePtr
	bcc	PREPARE_COPY_MATCH3
	inc	sourcePtr+2

PREPARE_COPY_MATCH3 anop
	ldy	#0
	lda	SUB_OFFSET
	cmp	#1
	beq	SINGLE_BYTE_REPEAT
	txa
	lsr
	bcs	COPY_MATCH_ODD

	tax
COPY_MATCH_LOOP_EVEN anop
	lda	[matchPtr],y	;get two bytes of backreferences
	sta	[destPtr],y
	iny
	iny
	dex
	bne	COPY_MATCH_LOOP_EVEN
	tya
	adc	destPtr
	sta	destPtr
	bcc	DECODE_NEXT_TOKEN
	inc	destPtr+2
	jmp	DECODE_TOKEN

COPY_MATCH_ODD	anop
	beq	COPY_MATCH_SINGLE_BYTE
	tax
COPY_MATCH_LOOP_ODD anop
	lda	[matchPtr],y	;get two bytes of backreferences
	sta	[destPtr],y
	iny
	iny
	dex
	bne	COPY_MATCH_LOOP_ODD
COPY_MATCH_SINGLE_BYTE anop
	sep	#$21
	mx %10
	lda	[matchPtr],y	;get one byte of backreference
	sta	[destPtr],y
	rep #$30
	mx %00
	tya
	adc	destPtr	;carry is set
	sta	destPtr
	bcc	DECODE_NEXT_TOKEN
	inc	destPtr+2
DECODE_NEXT_TOKEN anop
	jmp	DECODE_TOKEN

SINGLE_BYTE_REPEAT anop
	sep #$20 ;short	m
	mx %10
	lda	[matchPtr],y	;get one byte of backreference
SINGLE_BYTE_REPEAT_LOOP anop
	sta	[destPtr],y
	iny
	dex
	bne	SINGLE_BYTE_REPEAT_LOOP
	rep	#$21
	mx %00
	tya
	adc	destPtr ;	carry is clear
	sta	destPtr
	bcc	DECODE_NEXT_TOKEN
	inc	destPtr+2
	jmp	DECODE_TOKEN

DECOMPRESSION_DONE anop
	rts

;	end

;------------------------------------------------------------------------------
; Compatible with ORCA/C calling convention:
;
;		void decompress_lzsa(void* dest, void* src)
;
; pea ^source_address
; pea #source_address
;
; pea ^destination_address
; pea #destination_address
;
; jsl decompress_lzsa
;
;------------------------------------------------------------------------------


decompress_lzsa ent
	mx %00
pDest equ 4
pPackedSource equ 8

	; Setup Source Pointer
	lda pPackedSource,s
	sta <sourcePtr
	lda pPackedSource+2,s
	sta <sourcePtr+2

	; Setup Dest Pointer
	lda pDest,s
	sta <destPtr
	lda pDest+2,s
	sta <destPtr+2

	jsr	DECOMPRESS_LZSA2	; Call the raw data decompressor

	rep #$31
	mx %00

	; Copy the Return address
    lda 1,s
    sta pPackedSource+1,s
    lda 2,s
    sta pPackedSource+2,s

	tsc
	sec
	sbc #-8
	tcs

	rtl

;------------------------------------------------------------------------------
