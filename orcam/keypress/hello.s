*
*  Little Hellow World Program, in ORCA/M
*
	case on
	longa on
	longi on


* Kernel method
PUTS GEQU $00101C                 ; Print a string to the currently selected channel
GETCH GEQU $001048
PRINTAH GEQU $001080 			  ; Prints hex value in A. Printed value is 2 wide if M flag is 1, 4 wide if M=0
INITKEYBOARD GEQU $0010B4

hello	start MAIN                ; make sure start is visible outside the file
        clc
        xce

        rep #$31                  ; long MX, and CLC

		jsl INITKEYBOARD

        ldx #HelloText
        jsl PUTS

		cli

lp		ANOP
		jsl GETCH
		cmp #0
		beq lp

		jsl PRINTAH

        bra lp

HelloText ANOP
		dc c'Welcome, Type some stuff!'
        dc h'0d'
		dc h'00'

		end




