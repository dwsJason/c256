;
; VDMA Tables, used for scaling the audio
;
	rel
	lnk magic.l

dma_table ent
	putbin data\magic.bin

;
; How many source samples per step
;
step_table ent
]index = 1
	lup 16*256
	dw	65536/]index
]index = ]index+1 
	--^

