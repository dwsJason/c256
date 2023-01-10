;
; Volume Table
;

volume_table
]org = $050200
		lup 127
		adrl ]org
]org = ]org+$200
		--^
]org = $060200
		lup 127
		adrl ]org
]org = ]org+$200
		--^
]org = $070200
		lup 2
		adrl ]org
]org = ]org+$200
		--^

;------------------------------------------------------------------------------

GenerateVolumeTables mx %00

		phd

		pea #$100
		pld

		lda #$100
		sta <SIGNED_MULT_A_LO
:wave = $80
:pTable = $84
]loop
		stz <:wave
		
; pTable, the current volume table
		lda <SIGNED_MULT_A_LO
		asl
		asl
		tax
		lda |volume_table,x
		sta <:pTable
		lda |volume_table+2,x
		sta <:pTable+2

		ldy #0
]in
		lda <:wave
		xba
		asl				; x2 (this is going into the LSB), so LSB goes 0->FF
						; as the MSB goes from 0->7F
						; this also works for negative numbers, pushing out
						; an even spacing accross the entire +/-15 bit range
		ora <:wave
		xba
		sta <SIGNED_MULT_B_LO

		lda <SIGNED_MULT_AL_HI
		cmp #$8000
		ror
		cmp #$8000
		ror
		cmp #$8000
		ror
		cmp #$8000
		ror
		sta [:pTable],y  ; save out the 

		inc <:wave
		iny
		iny
		cpy #$100
		bcc ]in

		dec <SIGNED_MULT_A_LO
		bpl ]loop

		pld
		   
		rts
;------------------------------------------------------------------------------
;
; SetVolume - use DMA to copy volume data into channel
;
; A = Volume
; X = Channel #*4 
;
; Initialization order for DMA registers important, due to overlapping
; registers in the memory map
;
; $$TODO - create DMA Manager, and change this up to use it
;
SetVolume mx %00

		pha

		sep #$20
		lda #0
		sta >SDMA_CTRL_REG0 ; make sure it's off
		lda #SDMA_CTRL0_Enable
		sta >SDMA_CTRL_REG0 ; bring it alive
		rep #$31

		pla
		asl
		asl
		tay
		lda |volume_table,y
		sta >SDMA_SRC_ADDY_L
		lda |volume_table+2,y
		sta >SDMA_SRC_ADDY_H   ; overlaps with dst address

		; Stick in the address of the target
		lda |:vol_table,x
		sta >SDMA_DST_ADDY_L
		lda |:vol_table+2,x
		sta >SDMA_DST_ADDY_H   ; overlaps with size

		lda #$200
		sta >SDMA_SIZE_L
		lda #$0
		sta >SDMA_SIZE_H

		sep #$20
		lda >SDMA_CTRL_REG0
		ORA #SDMA_CTRL0_Start_TRF
		sta >SDMA_CTRL_REG0 	   ; Go!
		nop
		nop
		nop
		nop
		nop
		lda #0
		sta >SDMA_CTRL_REG0
		rep #$31

		rts		

:vol_table
	adrl Channel0Left
	adrl Channel0Right
	adrl Channel1Left
	adrl Channel1Right
	adrl Channel2Left
	adrl Channel2Right
	adrl Channel3Left
	adrl Channel3Right
				 
	adrl Channel4Left
	adrl Channel4Right
	adrl Channel5Left
	adrl Channel5Right
	adrl Channel6Left
	adrl Channel6Right
	adrl Channel7Left
	adrl Channel7Right



;------------------------------------------------------------------------------

