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

