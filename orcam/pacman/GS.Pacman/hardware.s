;
;  hardware.s
;  GS.Pacman
;
;  Created by Peter Hirschberg on 8/19/21.
;Copyright © 2021 Peter Hirschberg. All rights reserved.
;


        case on
        mcopy global.macros
        keep global


hardware start
        using globalData



; Set the SCB to fill mode for all 200 screen rows
initSCB entry
        lda #0
        sta rowCounter
        ldx #0
initLoop anop
        lda >SCB_BASE,x
        ora #FILL_MODE
        sta >SCB_BASE,x
        inc rowCounter
        lda rowCounter
        cmp #199
        beq initDone
        inx
        jmp initLoop
initDone anop
        rts



; Thanks to Lucas Scharenbroich for this code ----------------------------------

shadowingOff entry
		aif FMX>0,.GSONLY
        short m
        lda >$E0C035
        ora #$08
        sta >$E0C035
        long m
.GSONLY
        rts


shadowingOn entry
		aif FMX>0,.GSONLY
        short m
        lda >$E0C035
        and #$F7
        sta >$E0C035
        long m
.GSONLY
        rts


interruptsOff entry
		aif FMX>0,.GSONLY
        short m
        sta >$00C004
        sta >$00C002
        long m
        lda EntryStack
        tcs
        lda EntryDP
        tcd
.GSONLY
        cli
        rts

interruptsOn entry
		aif FMX>0,.GSONLY
        tdc
        sta EntryDP
        tsc
        sta EntryStack
.GSONLY
        sei

		aif FMX>0,.GSONLY
        short m
        sta >$00C005
        sta >$00C003
        long m
.GSONLY
        rts



;  ...stuff
;  jsr setR0W1
;  jsr shadowingOff
;  jsr eraseWithBackgroundFromBank00
;  jsr setR1W1
;  jsr drawNewStuffInBank01
;  jsr shadowingOn
;  jsr bitbltDirtyRectangles
;  jsr setR0W0



; Thanks to Jesse Blue for this code ----------------------------------

; during init of your program:
borderInit entry
		aif FMX>0,.GSONLY
        short m
        lda >$00c034 ;black border
        and #$f0
        sta >$00c034
        long m
.GSONLY
        rts

; before you start to erase/draw
borderStart entry
		aif FMX>0,.GSONLY
        short m
        lda >$00c034
        inc a
        sta >$00c034
        long m
.GSONLY
        rts

; at the end of changing pixels on the screen
borderDone entry
		aif FMX>0,.GSONLY
        short m
        lda >$00c034 ;black border
        and #$f0
        sta >$00c034
        long m
.GSONLY
        rts




; Credit for the code below goes to Jeremy Rand - author of BuGS

setupScreen entry
		aif FMX>0,.GSONLY
        lda >BORDER_COLOR_REGISTER
        and #$f0
        sta >BORDER_COLOR_REGISTER
.GSONLY
        sei
        phd
        tsc
        sta backupStack

		aif FMX>0,.GSONLY
        lda >STATE_REGISTER      ; Direct Page and Stack in Bank 01/
        ora #$0030
        sta >STATE_REGISTER
.GSONLY

        ldx #$0000

        lda #$9dfe
        tcs
        ldy #$7e00
nextWord anop
        phx
        dey
        dey
        bpl nextWord

		aif FMX>0,.GSONLY
        lda >STATE_REGISTER
        and #$ffcf
        sta >STATE_REGISTER
.GSONLY
        lda backupStack
        tcs
        pld
        cli

		aif FMX<1,.FMXONLY

;		jsl C1BlitPalettes
;		jsl C1BlitPixels

.FMXONLY

        rts



; Modified to read controls while waiting for VBL
waitForVbl entry
vblLoop1 anop
; On FMX we checkControls, but right now don't wait for vbl
        jsr checkControls

		aif FMX>0,.GSONLY
		short m
		lda #$fe
		cmp >READ_VBL
        long m
		bpl vblLoop1
vblLoop2 anop
        jsr checkControls
        short m
        lda #$fe
		cmp >READ_VBL
        long m
		bmi vblLoop2
.GSONLY

		aif FMX<1,.FMXONLY
;$$JGA TODO, speed up the palette bit, or get rid of it
;		jsl C1BlitPalettes
		jsl C1BlitPixels

.FMXONLY
		rts




backupStack     dc i2'0'

EntryDP dc i2'0'
EntryStack dc i2'0'

StackPtr dc i2'0'

rowCounter dc i2'0'

        end
