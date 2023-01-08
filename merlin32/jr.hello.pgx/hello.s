;
; Merlin32 Hello.PGX program, for Jr
;
; To Assemble "merlin32 -v hello.s"
;
		mx %11

		org $0
		dsk hello.pgx
		db 'P','G','X'  ; PGX header
		db $01          ; CPU - unsure
		adr start

		org $2000
                
; Steal 2 bytes on the DP                
pSource = $FB                
CHROUT = $ffd2

start
		lda #<:text   		; Text C String Address
        sta pSource+0       ; Pointer that the print function will use
		lda #>:text
		sta pSource+1

		jsr print

		rts

:text   ASC	'Hello World!'
		db  13,0

;------------------------------------------------------------------------------
;
; pSource (DP Location $FB) points to a 0 terminated string
; Function wrecks A, and Y (CHROUT might wreck X)
;
print
		ldy     #0
]loop   lda     (pSource),y
        beq     :done
        jsr     CHROUT
        iny
        bra     ]loop
:done   rts


