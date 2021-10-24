*
*  Convert the main.c into asm for C256, since I haven't sorted custom
*  C256 Librarys for the ORCA/C
*
*  Lucky, on this project, that there's only this 1 .c file, and it's pretty
*  light on what it's doing
*
	case on
	longa on
	longi on


* Kernel method
PUTS GEQU $00101C                 ; Print a string to the currently selected channel

;
; Interrupt Jump Table
;

VEC_INT00_SOF   GEQU $001700         ; Interrupt routine for Start Of Frame interrupt
VEC_INT01_SOL   GEQU $001704         ; Interrupt routine for Start Of Line interrupt
VEC_INT02_TMR0  GEQU $001708         ; Interrupt routine for Timer0
VEC_INT03_TMR1  GEQU $00170C         ; Interrupt routine for Timer1
VEC_INT04_TMR2  GEQU $001710         ; Interrupt routine for Timer2

FNX0_INT00_SOF	GEQU $000001		 ;Start of Frame @ 60FPS
INT_MASK_REG0   GEQU $00014C


;------------------------------------------------------------------------------
; I like having my own Direct Page
MyDP	GEQU $A000
MySTACK	GEQU $EFFF

; We have to figure out if pacman needs this address or not
dpJiffy	GEQU 128


pacman	start MAIN                ; make sure start is visible outside the file
        clc
        xce

        rep #$31                  ; long MX, and CLC

; Default Stack is on top of System Multiply Registers
; So move the stack before proceeding

        lda #MySTACK
        tcs

;
; Works via Stock Kernel, with DP at 0
;

		jsl INITKEYBOARD

        ldx #HelloText
        jsl PUTS

;
; So we have our own Direct Page that doesn't conflict
; with Kernel
;

        lda #MyDP
        tcd

		phk
		plb
;
; Setup a Jiffy Timer, using Kernel Jump Table
; Trying to be friendly, in case we can friendly exit
;
		jsr InstallJiffy

		jsl C1InitVideo 	; Initialize the FMX Display Hardware

; For now looking to debug these, to make sure ports are ok

		phk
		plb

;		jsl C1BlitPalettes
;		jsl C1BlitPixels
;
;waithere bra waithere

		pea globalData|-8   ; Need to setup the ORCA/C Databank
		plb
		plb

		jsl baseInit		; Pacman Init

		jsl runGameTick		; Pacman Game


lp		ANOP
        bra lp

HelloText ANOP
		dc c'Hello from Pacman!'
        dc h'0d'
		dc h'00'

		end

loadIntroSound start MAIN
loadInterSound entry
loadSiren1Sound entry
loadSiren2Sound entry
loadEatDotSound entry
loadExtraLifeSound entry
loadFruitSound entry
loadGhostScaredSound entry
loadEatGhostSound entry
loadDeathSound entry
		lda 3,s
		sta 1,s
		lda 4,s
		sta 2,s

		pla
		rtl

		end



;------------------------------------------------------------------------------
;
; Jiffy Timer Installer, Enabler
; Depends on the Kernel Interrupt Handler
;
InstallJiffy start MAIN

; Fuck over the vector

		sei

		lda #$4C	; JMP
		sta |VEC_INT00_SOF

		lda #JiffyTimer
		sta |VEC_INT00_SOF+1

; Enable the SOF interrupt

;   	lda #FNX0_INT00_SOF
		lda #1
		trb |INT_MASK_REG0

		cli
		rts

JiffyTimer ANOP
		phb
		phk
		plb
		inc |MyDP+dpJiffy
		plb
		rtl

		end

