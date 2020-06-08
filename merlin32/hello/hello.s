;
;  Little Hellow World Program, in Merlin
;
        rel     ; relocatable
        lnk     Main.l

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

HelloText asc 'Hello from Merlin!'
        db 13,0



