;
;  Little Hellow World Program, in Merlin
;

		org $2000
		dsk main.bin
        mx %00

; Kernel method
PUTS = $00101C                      ; Print a string to the currently selected channel


start ent       ; make sure start is visible outside the file
        clc
        xce

        rep $31 ; long MX, and CLC

        ldx #HelloText
        jsl PUTS

]lp
        bra ]lp

; Latest Kernel doesn't have lowercase?
HelloText asc 'HELLO FROM MERLIN!'
        db 13,0



