;
; DMA Helper Functions
;
		mx %00

;-------------------------------------------------------------------------------
; KickVRAM2SRAM
;
; PushL Source VRAM Address
; PushL Dest SRAM Address
; PushL Length in Bytes
;
; jsr KickVRAM2SRAM
;
KickVRAM2SRAM mx %00

; 1,s is the return address-1
]length = 3
]dest_address = 7
]src_address = 11

		; Switch into the VDMA Bank
		pea	{VDMA_CONTROL_REG}/256
		plb
		plb

		sep #$14 ; m=0, x=1, sei

		; Activate the SDMA Circuit
		ldx #SDMA_CTRL0_Enable+SDMA_CTRL0_SysRAM_Dst
		stx |SDMA_CTRL_REG0
		; Activate the VDMA Circuit
		ldx #VDMA_CTRL_Enable+VDMA_CTRL_SysRAM_Dst
		stx |VDMA_CONTROL_REG

		; source address
		lda ]src_address,s
		sta |VDMA_SRC_ADDY_L
		lda ]src_address+1,s
		sta |VDMA_SRC_ADDY_L+1

		; dest address
		lda ]dest_address,s
		sta |SDMA_DST_ADDY_L
		lda ]dest_address+1,s
		sta |SDMA_DST_ADDY_L+1

		; length
		lda ]length,s
		sta |VDMA_SIZE_L
		sta |SDMA_SIZE_L
		lda ]length+1,s
		sta |VDMA_SIZE_L+1
		sta |SDMA_SIZE_L+1

		sep #$30

		lda #DMA_CTRL_Start_TRF
		tsb |VDMA_CTRL_REG
		tsb |SDMA_CTRL_REG0
			 ; Sample code does this, with this comment, $$TODO -> change this to poll
		nop  ; When the transfer is started the CPU will be put on Hold (RDYn)...                                         
		nop  ; Before it actually gets to stop it will execute a couple more instructions                                 
		nop  ; From that point on, the CPU is halted (keep that in mind) No IRQ will be processed either during that time 
		nop
		nop

		stz |SDMA_CTRL_REG0
		stz |VDMA_CONTROL_REG

		phk
		plb

		rep #$35 ; mxic=0000
		rts



		



;-------------------------------------------------------------------------------
; Kick2DVDMA
;
; PushL Source VRAM Address
; PushL Dest VRAM Address
; PushW width  in Pixels
; PushW Height in Pixels
;
; PushW Source Stride, in pixels
; PushW Dest Stride
;
; jsr Kick2DVDMA
;
Kick2DVDMA mx %00

; 1,s is the return address-1

]dest_stride   = 3
]source_stride = 5
]height_pixels = 7
]width_pixels  = 9
]dest_addr     = 11
]src_addr      = 15

		; Switch into the VDMA Bank
		pea	{VDMA_CONTROL_REG}/256
		plb
		plb

		do 1
		lda ]src_addr,s
		sta |VDMA_SRC_ADDY_L
		lda ]src_addr+1,s
		sta |VDMA_SRC_ADDY_L+1

		lda ]dest_addr,s
		sta |VDMA_DST_ADDY_L
		lda ]dest_addr+1,s
		sta |VDMA_DST_ADDY_L+1

		lda ]width_pixels,s
		sta |VDMA_X_SIZE_L
		lda ]height_pixels,s
		sta |VDMA_Y_SIZE_L

		lda ]source_stride,s
		sta |VDMA_SRC_STRIDE_L
		lda ]dest_stride,s
		sta |VDMA_DST_STRIDE_L
		sep #$20

		else
		sep #$20
		lda ]src_addr,s
		sta |VDMA_SRC_ADDY_L
		lda ]src_addr+1,s
		sta |VDMA_SRC_ADDY_L+1
		lda ]src-addr+2.s
		sta |VDMA_SRC_ADDY_L+2

		lda ]dest_addr,s
		sta |VDMA_DST_ADDY_L
		lda ]dest_addr+1,s
		sta |VDMA_DST_ADDY_L+1
		lda ]dest_addr+2,s
		sta |VDMA_DST_ADDY_L+2

		lda ]width_pixels,s
		sta |VDMA_X_SIZE_L
		lda ]width_pixels+1,s
		sta |VDMA_X_SIZE_L+1
		 
		lda ]height_pixels,s
		sta |VDMA_Y_SIZE_L
		lda ]height_pixels+1,s
		sta ]VDMA_Y_SIZE_L+1

		lda ]source_stride,s
		sta |VDMA_SRC_STRIDE_L
		lda ]source_stride+1,s
		sta ]VDMA_SRC_STRIDE_L+1

		lda ]dest_stride,s
		sta |VDMA_DST_STRIDE_L
		lda ]dest_stride+1,s
		sta |VDMA_DST_STRIDE_L+1
		fin

		stz |VDMA_CONTROL_REG  ; Clear the TRF

		; Begin 2D DMA
		lda #VDMA_CTRL_Enable+VDMA_CTRL_1D_2D+VDMA_CTRL_Start_TRF
		sta |VDMA_CONTROL_REG

		;rep #$31	; mxc=000

		; Wait for Completion
]wait_dma
		lda |VDMA_STATUS_REG
		bmi	]wait_dma

		rep #$31	; mxc=000

		; fix up stack
		lda 1,s
		sta 17,s

		tsc
		adc #16
		tcs

		; Back to our program bank
		phk
		plb
		rts


