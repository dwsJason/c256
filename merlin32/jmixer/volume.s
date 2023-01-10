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
		ora <:wave
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
		
