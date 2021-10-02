*
*  Little Hellow World Program, in ORCA/M
*
	case on
	longa on
	longi on


* Kernel method
PUTS GEQU $00101C                 ; Print a string to the currently selected channel


hello	start MAIN                ; make sure start is visible outside the file
        clc
        xce

        rep #$31                  ; long MX, and CLC

        ldx #HelloText
        jsl PUTS

lp		ANOP
        bra lp

HelloText ANOP
		dc c'Hello from ORCA/M!'
        dc h'0d'
		dc h'00'

		end




