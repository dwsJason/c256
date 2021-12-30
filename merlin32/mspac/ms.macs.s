;
; Misc Macros, that just make things a little easier
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


