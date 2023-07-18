;
;  Foenix Bitmap Example in Merlin32
;
; $00:2000 - $00:7FFF are free for application use.
;
        rel     ; relocatable
        lnk     Main.l

        use Util.Macs
		put macros.s
		use keys.i

		; Vicky
		use ../phx/vicky_ii_def.asm
		use ../phx/VKYII_CFP9553_BITMAP_def.asm 
		use ../phx/VKYII_CFP9553_TILEMAP_def.asm
		use ../phx/VKYII_CFP9553_VDMA_def.asm   
		use ../phx/VKYII_CFP9553_SDMA_def.asm   
		use ../phx/VKYII_CFP9553_SPRITE_def.asm 

		; Kernel
		use ../phx/page_00_inc.asm
		use ../phx/kernel_inc.asm

		; Hardware
		use ../phx/rtc_def.asm
		use ../phx/timer_def.asm
		; Fixed Point Math
		use ../phx/Math_def.asm

		; Interrupts
		use ../phx/interrupt_def.asm


		ext logo_pic
		ext pumpbars_pic
		ext sprites_pic
		ext speakers_pic
		ext dancer_sprites
		ext background_pic

		ext decompress_lzsa
		ext MIXFIFO ; for the visualizer

		;
		; some mod files
		;
		ext toms_diner

		ext FontInit

; toggle the original dump code back on, to examine the source info directly from the MOD
OLD_DUMP equ 0

PUMPBARS_X = 208
PUMPBARS_Y = 336
SCOPES_X   = PUMPBARS_X+9
SCOPES_Y   = PUMPBARS_Y+90


        mx %00

;------------------------------------------------------------------------------
; Direct Page Equates
;------------------------------------------------------------------------------

		put dp.i.s
		put mixer.i.s
;
; Decompress to this address
; Temp Buffer for decompressing stuff ~512K here
;
VICKY_DISPLAY_BUFFER  = $100000
; 512k for my copy
;VICKY_OFFSCREEN_IMAGE = VICKY_DISPLAY_BUFFER+{XRES*YRES}
VICKY_OFFSCREEN_IMAGE = $000001
VICKY_WORK_BUFFER     = $180000


; Kernel method
VRAM = $B00000

VRAM_DANCER_SPRITES = $B00000

VRAM_TILE_CAT = $C80000
VRAM_LOGO_MAP = $B80000

VRAM_PUMPBAR_MAP = $B82000  ; LOGO map is like 5K
VRAM_PUMPBAR_CAT  = $C88000  ; until we have catalog packing, this is easier
VRAM_SPEAKERS_MAP = $BA0000
VRAM_SPEAKERS_ANIM_MAP = $BA8000  ; for the uncompressed 224x2816 ,map data
VRAM_SPEAKERS_CAT = $C90000  ; until we have cat packing, uses 3 banks

VRAM_BACKGROUND_MAP = $B88000 ; background map data
VRAM_BACKGROUND_CAT = $CC0000 ; 256K of tiles

; next available is $CC0000

VRAM_OSC_SPRITES  = $C70000 ; OSC visualizer Sprites, 16 sprites, 1K each (32x32)
VRAM_TILE_SPRITES = $C60000 ; 64 pre-made sprites, in the sprites.256 file

; Base Address for Audio
AUDIO_RAM = $80000
;AUDIO_RAM = $E00000

;------------------------------------------------------------------------------
; I like having my own Direct Page
MySTACK = STACK_END ;$FEFF Defined in the page_00_inc.asm

; Video Mode Stuff

XRES = 800
YRES = 600

;VIDEO_MODE = $017F  ; -- all the things enabled, 800x600
VIDEO_MODE = $017E  ; -- all the things enabled, 800x600


;------------------------------------------------------------------------------

start   ent             ; make sure start is visible outside the file
        clc
        xce
        sep $35         ; mxci=1
						; keep interrupts off, until we're ready for them
						; yes, they should be off, but hard to say how
						; we got here

		phk
		plb

		; I added this here, to allow iteration to be more stable
		; so when cli happens, we can avoid crashing
		lda #$6B  ; RTL
		sta |VEC_INT00_SOF
		sta |VEC_INT01_SOL
		sta |VEC_INT02_TMR0
		sta |VEC_INT03_TMR1
		sta |VEC_INT04_TMR2


; Default Stack is on top of System Multiply Registers
; So move the stack before proceeding
		rep $31 	 ; mxc = 000

        lda #MySTACK
        tcs

;		lda #0
;		tcd
		;jsl $10AC ;INITCHLUT	    
		;jsl $10B0 ;INITSUPERIO	    
		;jsl $10B4 ;INITKEYBOARD    
		;jsl $10B8 ;INITMOUSE       
		;jsl $10BC ;INITCURSOR      
		;jsl $10C0 ;INITFONTSET     
		;jsl $10C4 ;INITGAMMATABLE  
		;jsl $10C8 ;INITALLLUT      
		;jsl $10CC ;INITVKYTXTMODE  
		;jsl $10D0 ;INITVKYGRPMODE  
		;jsl $10DC ;INITCODEC

;		stz <MOUSE_PTR

        lda #MyDP
        tcd

		stz <SongIsPlaying

		phk
		plb

		; Initialize the uninitialized RAM
		stz |uninitialized_start
		ldx #uninitialized_start
		ldy #uninitialized_start+2
		lda #{uninitialized_end-uninitialized_start}-3
		mvn ^uninitialized_start,^uninitialized_start

;------------------------------------------------------------------------------
; So the user doesn't have to press a key to make the mouse work
;		stz |MOUSE_PTR ; this is fix the mouse MOUSE_IDX or MOUSE_PTR, depending kernel version
;------------------------------------------------------------------------------

		jsl FontInit

		phk
		plb

		;lda #2
		;sta >MOUSE_PTR_CTRL_REG_L
		lda #$FFFF
		sta >MOUSE_PTR_GRAP1_START

;------------------------------------------------------------------------------
;
; Setup a Jiffy Timer, using Kernel Jump Table
; Trying to be friendly, in case we can friendly exit
;
		jsr InstallJiffy		; SOF timer
		jsr InstallModJiffy     ; 50hz timer

		jsr	WaitVBL

;------------------------------------------------------------------------------
;
;		jsr FadeToBorderColor
;
;------------------------------------------------------------------------------


		lda #VIDEO_MODE  		  	; 800x600 + Gamma + Bitmap_en
		sep #$30
		sta >MASTER_CTRL_REG_L
		xba
		sta >MASTER_CTRL_REG_H

		;lda #BM_Enable
		lda #0
		sta >BM0_CONTROL_REG
		sta >BM1_CONTROL_REG

		lda #<VICKY_DISPLAY_BUFFER
		sta >BM0_START_ADDY_L
		lda #>VICKY_DISPLAY_BUFFER
		sta >BM0_START_ADDY_M
		lda #^VICKY_DISPLAY_BUFFER
		sta >BM0_START_ADDY_H

	    ;
		; Reset Mouse
		;
		;lda #0
		;sta >MOUSE_PTR_CTRL_REG_L
		;lda #1
		;sta >MOUSE_PTR_CTRL_REG_L

		rep #$31
;------------------------------------------------------------------------------
; 		Disable Sprites

		sec
		lda #0
		ldx #8*63  ; sprite offset
]lp		sta >SP00_CONTROL_REG,x
		txa
		sbc #8
		tax
		bpl ]lp

;------------------------------------------------------------------------------

		jsr InitTextMode

		phk
		plb
;------------------------------------------------------------------------------

		jsr logo_pic_init
		jsr pumpbars_pic_init
		jsr sprites_pic_init  ; load sprite tiles, and CLUT
		jsr speakers_pic_init ; load the speaker frames

		jsr background_pic_init ; load the dance floor

		jsr dancer_sprites_init ; 4x216 (map data), 54 frames

;------------------------------------------------------------------------------

		pea ^toms_diner
		pea toms_diner
		jsl	ModInit

;------------------------------------------------------------------------------
; Mixer things

		ext MIXstartup
		ext MIXshutdown
		ext MIXplaysample
		ext MIXsetvolume


		lda #mixer_dpage	; pass in location of DP memory
		jsl MIXstartup

;------------------------------------------------------------------------------


;-------------------------------------------------------------
;
; Debug Dump Some Memory
;
;----------------------------------------------------------
;dump
;:pTemp = 0
;:VOL_TABLES equ $030200  ; 64 Volume tables (256 entries each)
;		lda #:VOL_TABLES
;		sta <:pTemp
;		lda #^:VOL_TABLES
;		sta <:pTemp+2
;
;		ldy #0
;]lp
;		lda [:pTemp],y
;		phy
;		jsr myPRINTAH
;		ldx #:space
;		jsr myPUTS
;		pla
;		inc
;		inc
;		tay
;		and #$1F
;		bne :skipret
;		jsr myPRINTCR
;		phy
;		tya
;		jsr myPRINTAH
;		ldx #:colon
;		jsr myPUTS
;		ply
;:skipret
;		cpy #$8200
;		bne ]lp
;
;:space asc ' '
;		db 0
;:colon asc ': '
;		db 0
;
;		bra	dump

		jsr ModPlay

		ldy #42			; cursor blink someplace harmless
		ldx #0
		jsr myLOCATE

		jsr InitOscSprites

]main_loop
		jsr WaitVBL

		jsr SpeakerRender
		jsr DancerRender

		jsr PumpBarRender
		jsr PeakMeterRender

		jsr UpdateOSC0Sprite
		jsr UpdateOSC0SpriteR
		jsr UpdateOSC1Sprite
		jsr UpdateOSC1SpriteR
		jsr UpdateOSC2Sprite
		jsr UpdateOSC2SpriteR
		jsr UpdateOSC3Sprite
		jsr UpdateOSC3SpriteR

;		jsr PatternRender

		jsr ReadKeyboard

		ldx #KEY_SPACE
		lda #PlayInstrument
		jsr OnKeyDown

		bra ]main_loop

;------------------------------------------------------------------------------
DancerRender mx %00

:xpos = temp0
:ypos = temp1

		ldy #0

		lda <dpJiffy
		and #1
		bne :go

		lda |:frame_num
		inc
		cmp #{216}/4
		bcc :aok
		lda #0
:aok
		sta |:frame_num
:go
		lda |:frame_num
		xba
		lsr
		lsr
		lsr
		tay

		lda #400
		sta <:xpos

		lda #288-128
		sta <:ypos

		clc

]spnum = 0
		lup 16
]xpos = {]spnum&3}*32
]ypos = {]spnum/4}*32

		lda #SPRITE_Enable+SPRITE_LUT5
		sta >SP32_CONTROL_REG+{]spnum*8}

		;lda #0
		;sta >SP32_ADDY_PTR_L+{]spnum*8}

		lda |dancer_map+{]spnum*2},y
		asl
		asl
		sta >SP32_ADDY_PTR_M+{]spnum*8}

		lda <:xpos
		adc #]xpos
		sta >SP32_X_POS_L+{]spnum*8}

		lda <:ypos
		adc #]ypos
		sta >SP32_Y_POS_L+{]spnum*8}
]spnum = ]spnum+1
		--^

		rts
:frame_num dw 0

;------------------------------------------------------------------------------
SpeakerRender mx %00
	
;		php
;		sei
LEFT_SPEAKER_X = 2
LEFT_SPEAKER_Y = 17

		lda |speaker_tick
		inc
		sta |speaker_tick
		and #1
		beq :update
		;rts
:update

		lda |speaker_frame
		inc
		and #$f
		sta |speaker_frame

		asl
		tax
		lda |:source_address,x
		tax ; speaker source address


		

		phkb ^VDMA_CONTROL_REG
		plb

		sep #$20 ; m=1,x=0

		stz |VDMA_CONTROL_REG ; disabled

		lda #VDMA_CTRL_Enable+VDMA_CTRL_1D_2D ; enable
		sta |VDMA_CONTROL_REG

		;ldx #{VRAM_SPEAKERS_ANIM_MAP-VRAM}
		stx |VDMA_SRC_ADDY_L
		lda #^{VRAM_SPEAKERS_ANIM_MAP-VRAM}
		sta |VDMA_SRC_ADDY_H

		ldx #{VRAM_SPEAKERS_MAP-VRAM}+{LEFT_SPEAKER_Y*64*2}+{LEFT_SPEAKER_X*2}
		stx |VDMA_DST_ADDY_L
		lda #^{VRAM_SPEAKERS_MAP-VRAM}
		sta |VDMA_DST_ADDY_H

		ldx #14*2
		stx |VDMA_X_SIZE_L
		ldy #22 ;*2
		sty |VDMA_Y_SIZE_L

		stx |VDMA_SRC_STRIDE_L

		ldx #64*2
		stx |VDMA_DST_STRIDE_L

		lda #VDMA_CTRL_Start_TRF+VDMA_CTRL_Enable+VDMA_CTRL_1D_2D
		sta |VDMA_CONTROL_REG

;		nop
;		nop
;		nop
;]wait_done
;		lda |VDMA_STATUS_REG
;		bmi ]wait_done
;		nop
;		stz |VDMA_CONTROL_REG  ; stop

		rep #$31

		plb
;		plp

		rts

SPEAKER_FRAME_SIZE = 14*2*22

:source_address
		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*0}
		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*1}
		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*2}
		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*3}
		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*4}
		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*5}
		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*6}
		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*7}

		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*7}
		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*6}
		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*5}
		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*4}
		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*3}
		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*2}
		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*1}
		da {VRAM_SPEAKERS_ANIM_MAP-VRAM}+{SPEAKER_FRAME_SIZE*0}

;------------------------------------------------------------------------------
PeakMeterRender mx %00

;]YPOS = 512+112
;]XPOS = 192-1

]YPOS = PUMPBARS_Y+105
]XPOS = PUMPBARS_X+39


]sprite_no = 16  ; starting sprite index
]count = 0

		lup 16
		lda |pump_bar_peak_timer+]count
		and #$FF
		beq :disable
		lda |pump_bar_peaks+]count
		and #$FF
		cmp #4
		bcs :not_zero
		lda #4
:not_zero
		cmp #16*2
		bcc :ok
		lda #16*2
:ok
		;asl
		asl
		eor #$FFFF
		dec
		;clc
		adc	#]YPOS
		
		sta >SP00_Y_POS_L+{8*]sprite_no}
		
		lda	#]XPOS+{48*{]count/2}+{{]count&1}*20}}
		sta >SP00_X_POS_L+{8*]sprite_no}

		lda #>{VRAM_TILE_SPRITES-VRAM}
		sta >SP00_ADDY_PTR_M+{8*]sprite_no}

		lda #SPRITE_Enable+SPRITE_LUT1
:disable
		sta >SP00_CONTROL_REG+{8*]sprite_no}


]count = ]count+1
]sprite_no = ]sprite_no+1
		--^

		rts
;------------------------------------------------------------------------------

PumpBarRender mx %00

:pbar = temp0

		php
		sei
]ct = 0
		lup 8
		; Grab Pump Bar Data, with interrupts disabled
		lda |mod_pump_vol+2+{]ct*4}
		xba ; JGA shouldn't need this :-/
		stz |mod_pump_vol+2+{]ct*4}
		sta <:pbar+{]ct*2}
]ct = ]ct+1
		--^

		plp

; crap
		do 0
		ldx #0
		ldy #59
		jsr fastLOCATE

		lda <temp0
		jsr fastHEXWORD
		lda <temp0+2
		jsr fastHEXWORD
		lda <temp1
		jsr fastHEXWORD
		lda <temp1+2
		jsr fastHEXWORD
		lda <temp2
		jsr fastHEXWORD
		lda <temp2+2
		jsr fastHEXWORD
		lda <temp3
		jsr fastHEXWORD
		lda <temp3+2
		jsr fastHEXWORD

		ldx #0
		ldy #60
		jsr fastLOCATE

		lda |pump_bar_levels
		jsr fastHEXWORD
		lda |pump_bar_levels+2
		jsr fastHEXWORD
		lda |pump_bar_levels+4
		jsr fastHEXWORD
		lda |pump_bar_levels+8
		jsr fastHEXWORD
		lda |pump_bar_levels+10
		jsr fastHEXWORD
		fin

;------------------------------------------------------------------------------
; Update the 16 bars, peaks, and timers

		sep #$30

]ct = 0
		lup 16

		lda <:pbar+]ct
		beq :no_new_value

		cmp |pump_bar_levels+]ct
		bcc :no_new_value

		sta |pump_bar_levels+]ct
		cmp |pump_bar_peaks+]ct
		bcc :no_new_value
		sta |pump_bar_peaks+]ct
		lda #20	; hang time
		sta |pump_bar_peak_timer+]ct
:no_new_value
		lda |pump_bar_peak_timer+]ct
		beq :skip_peak_timer
		dec
		sta |pump_bar_peak_timer+]ct
		bne :skip_peak_timer
		;lda |pump_bar_levels+]ct
		stz |pump_bar_peaks+]ct  ; when timer hits zero, so does peak
:skip_peak_timer
		lda |pump_bar_levels+]ct
		beq :skip_level
		dec
		sta |pump_bar_levels+]ct
:skip_level
]ct = ]ct+1
		--^

		rep #$31

; ---- now render 16 pump bars


]ct = 0
		lup 16

		ldy #GRPH_LUT2_PTR+4+{64*]ct}

		lda |pump_bar_levels+]ct
		and #$FF
		lsr
		cmp #15
		bcc :no_clamp
		lda #15
:no_clamp
		asl
		asl			; number of active colors x 4
		pha
		beq :not_active

		dec
		ldx #pump_full_colors
		mvn ^pump_full_colors,^GRPH_LUT2_PTR   ; light up colors
:not_active
		sec
		lda #15*4
		sbc 1,s
		sta 1,s
		pla
		beq :no_empty

		dec
		ldx #pump_empty_colors
		mvn ^pump_empty_colors,^GRPH_LUT2_PTR
:no_empty
]ct = ]ct+1
		phk
		plb
		--^

		rts

;------------------------------------------------------------------------------

PatternRender mx %00
		sei
; grab information, I need so I can update the tracker pattern text
		pei mod_p_current_pattern
		pei mod_p_current_pattern+2
		pei mod_current_row
		pei mod_pattern_index
		cli
; update the tracker pattern text

		ldy #43
		ldx #0
		jsr fastLOCATE

		pla ; pattern_index -- use to highlight the "block"
		pla ; current_row   - would be nice for this to be illustrated, to the left of the notes
		cmp <last_row
		bne :print 			; only print if it needs it, clean up refresh
;		bra :print

		plx
		pla
		rts

:print
:pBlockAddress = temp5
:curRow = temp6

		sta <last_row
		sta <:curRow

		plx ; pointer to current row, of 4 commands
		pla

		sta <:pBlockAddress
		stx <:pBlockAddress+2

		ldy #43
		lda #15
		sta <:tCount
		phy
]lp
		jsr PrintPatternRow
		inc <:curRow
		ldx #0
		ply
		iny
		phy
		jsr fastLOCATE
		clc
		lda <:pBlockAddress
		adc <mod_row_size			; add rowsize
		sta <:pBlockAddress
		bne :cntu
		inc <:pBlockAddress+2
:cntu
		dec <:tCount
		bpl ]lp
		ply
		rts

;------------------------------------------------------------------------------
; X = Key #
; A = Function to Call
OnKeyDown mx %00
		dec
		pha
		sep #$20
		lda |keyboard,x
		bne :down
		; key is up, don't call
		sta |latch_keys,x
		rep #$30
:latched
		pla
		rts
:down
		cmp |latch_keys,x
		sta |latch_keys,x
		rep #$30
		beq :latched
:KeyIsDown
		rts

;------------------------------------------------------------------------------
; X = Key #
; A = Function to Call
OnKeyUp mx %00
		dec
		pha
		sep #$20
		lda |keyboard,x
		beq :up
		; key is up, don't call
		sta |latch_keys,x
		rep #$30
:latched
		pla
		rts
:up
		cmp |latch_keys,x
		sta |latch_keys,x
		rep #$30
		beq :latched
:KeyIsUp
		rts

;------------------------------------------------------------------------------
PlayInstrument mx %00

		ldx #0
		ldy #60
		jsr fastLOCATE
		ldx #:txt_play
		jsr fastPUTS

		lda |:inst_no
		jsr fastHEXBYTE
		lda #' '
		fastPUTC

		lda |:inst_no
		asl
		tax
		lda |inst_address_table,x
		pha
		tax
		jsr fastPUTS

		ldx #:txt_space
		jsr fastPUTS
;-----------------------------------------------------------------

		ply ; mod_instrument pointer

		lda |i_sample_length,y
		ora |i_sample_length+2,y
		beq :no_sample

		ldx #mixer_dpage-MyDP

;		lda #$178 ; 8363 hz, C2
		lda #$059 ; 8363 hz, C2

		php
		sei

		sta <osc_frequency,x  ; frequency

		lda #$0808  		; left/right volume (3f max)
		sta <osc_left_vol,x

		; wave pointer 24.8
		stz <osc_pWave,x
		lda |i_sample_start_addr,y
		sta <osc_pWave+1,x
		lda |i_sample_start_addr+1,y
		sta <osc_pWave+2,x

		; loop address 24.8
		stz <osc_pWaveLoop,x
		lda |i_sample_loop_start,y
		sta <osc_pWaveLoop+1,x
		lda |i_sample_loop_start+1,y
		sta <osc_pWaveLoop+2,x

		; wave end
		stz <osc_pWaveEnd,x
		lda |i_sample_loop_end,y
		sta <osc_pWaveEnd+1,x
		lda |i_sample_loop_end+1,y
		sta <osc_pWaveEnd+2,x

		plp

:no_sample

; increment the instrument number
		lda |:inst_no
		inc
		cmp <mod_num_instruments
		bcc :noclamp
		lda #0
:noclamp
		sta |:inst_no

		rts
:inst_no dw 0

:txt_play cstr 'PLAY INST:'
:txt_space cstr '                      '

;------------------------------------------------------------------------------
;
; Put DP back at zero while calling out to PUTS
;
myPUTS  mx %00
        phd
        lda #0
        tcd
        jsl PUTS
        pld
        rts

;------------------------------------------------------------------------------
;
; Put DP back at zero while calling out to PUTS
;
fastPUTS  mx %00
		sep #$20
		ldy <pFastPut

		lda |0,x
		beq :done
]lp
		inx
		sta [pFastPut]
		iny
		sty <pFastPut
		lda |0,x
		bne ]lp
:done 
		rep #$30
        rts


;------------------------------------------------------------------------------
;
; Put DP back at 0, for Kernel call
;
myPRINTCR mx %00
	    phd
		pea #0
		pld
		jsl PRINTCR
		pld
		rts

;------------------------------------------------------------------------------
;
; Put DP back at 0, for Kernel call
;
myPRINTAI mx %00
	    phd
		pea #0
		pld
		jsl PRINTAI
		pld
		rts

;------------------------------------------------------------------------------
;
; Put DP back at 0, for Kernel call
;
myPRINTAH mx %00
	    ;phd
		;pea #0
		;pld
		;jsl PRINTAH
		;pld
		
		; Kernel function doesn't work

		sep #$30
		xba
		pha
		and #$F0
		lsr
		lsr
		lsr
		lsr
		tax
		pla
		and #$0F
		tay
		lda |:chars,x
		sta |:temp
		lda |:chars,y
		sta |:temp+1
		xba
		pha
		and #$F0
		lsr
		lsr
		lsr
		lsr
		tax
		pla
		and #$0F
		tay
		lda |:chars,x
		sta |:temp+2
		lda |:chars,y
		sta |:temp+3
		rep #$30

		ldx #:temp
		jmp myPUTS

:chars  ASC '0123456789ABCDEF'

:temp	ds  5

;------------------------------------------------------------------------------
;
; Put DP back at 0, for Kernel call
;
myHEXBYTE mx %00
		; Kernel function doesn't work

		sep #$30
		pha
		and #$F0
		lsr
		lsr
		lsr
		lsr
		tax
		pla
		and #$0F
		tay
		lda |:chars,x
		sta |:temp
		lda |:chars,y
		sta |:temp+1
		rep #$30

		ldx #:temp
		jmp myPUTS

:chars  ASC '0123456789ABCDEF'

:temp	ds  3


;------------------------------------------------------------------------------
;
; Put DP back at 0, for Kernel call
;
myLOCATE mx %00
		phd
		pea 0
		pld
		jsl LOCATE
		pld
		rts 


;------------------------------------------------------------------------------
;
; Jiffy Timer Installer, Enabler
; Depends on the Kernel Interrupt Handler
;
InstallJiffy mx %00

; Fuck over the vector

		sei

		lda #$4C	; JMP
;		lda #$5C    ; JML
		sta |VEC_INT00_SOF

		lda #:JiffyTimer
		sta |VEC_INT00_SOF+1

		lda #>:JiffyTimer
		sta |VEC_INT00_SOF+2

; Enable the SOF interrupt

		lda	#FNX0_INT00_SOF
		trb |INT_MASK_REG0

		cli
		rts

:JiffyTimer
		phb
		phk
		plb
		inc |{MyDP+dpJiffy}
		plb
		rtl
;------------------------------------------------------------------------------
;
; Audio Jiffy Timer Installer, Enabler
; Depends on the Kernel Interrupt Handler
;
; Currently hijack timer 0, but could work on timer 1
;
;C pseudo code for counting up
;TIMER1_CHARGE_L = 0x00;
;TIMER1_CHARGE_M = 0x00;
;TIMER1_CHARGE_H = 0x00;
;TIMER1_CMP_L = clockValue & 0xFF;
;TIMER1_CMP_M = (clockValue >> 8) & 0xFF;
;TIMER1_CMP_H = (clockValue >> 16) & 0xFF;
;
;TIMER1_CMP_REG = TMR_CMP_RECLR;
;TIMER1_CTRL_REG = TMR_EN | TMR_UPDWN | TMR_SCLR;
;
;C pseudo code for counting down
;TIMER1_CHARGE_L = (clockValue >> 0) & 0xFF;
;TIMER1_CHARGE_M = (clockValue >> 8) & 0xFF;
;TIMER1_CHARGE_H = (clockValue >> 16) & 0xFF;
;TIMER1_CMP_L = 0x00;
;TIMER1_CMP_M = 0x00;
;TIMER1_CMP_H = 0x00;
;
;TIMER1_CMP_REG = TMR_CMP_RELOAD;
;TIMER1_CTRL_REG = TMR_EN | TMR_SLOAD;
;
InstallModJiffy mx %00

; Trying for 50 hz here

:RATE equ {14318180/50}

; Fuck over the vector

		sei

		stz <SongIsPlaying

		lda #$4C	; JMP
		sta |VEC_INT02_TMR0

		lda #:AudioJiffyTimer
		sta |VEC_INT02_TMR0+1

		; Configuring for count up
		sep #$30

		stz |TIMER0_CHARGE_L
		stz |TIMER0_CHARGE_M
		stz |TIMER0_CHARGE_H

		lda #<:RATE
		sta |TIMER0_CMP_L
		lda #>:RATE
		sta |TIMER0_CMP_M
		lda #^:RATE
		sta |TIMER0_CMP_H

		lda #TMR0_CMP_RECLR
		sta |TIMER0_CMP_REG
		lda #TMR0_EN+TMR0_UPDWN+TMR0_SCLR
		sta |TIMER0_CTRL_REG

; Enable the TIME0 interrupt

		lda	#FNX0_INT02_TMR0
		trb |INT_MASK_REG0

		rep #$35  ;mx-i-c = 0

		rts

:AudioJiffyTimer
		phb
		phd
		pha
		phx
		phy
		php

		phk
		plb
		rep #$30
		lda #MyDP
		tcd
		inc <dpAudioJiffy

		jsr AudioTick

		plp
		ply
		plx
		pla
		pld
		plb
		rtl
;------------------------------------------------------------------------------

AudioTick mx %00

		lda <SongIsPlaying
		beq :notPlaying

		jsr ModPlayerTick

:notPlaying

		; Pump the mixer

		rts

;------------------------------------------------------------------------------
; WaitVBL
; Preserve all registers
;
WaitVBL
		pha
		lda <dpJiffy
]lp
		cmp <dpJiffy
		beq ]lp
		pla
		rts

;------------------------------------------------------------------------------
InitTextMode mx %00

		phd
		lda #0
		tcd

		; Fuck, make the text readable
		dec  ; A = 0xFFFF
;		sta >$AF1F78
;		sta >$AF1F79

;
; Disable the border
;
		sep #$30
		lda	#0
		sta >BORDER_CTRL_REG
		rep #$30


		jsl SETSIZES  ; because we changed the resolution, takes into account border
		jsl CLRSCREEN ; because the data in the screen is messed up

		ldx #0
		txy
		jsl LOCATE	    ; cursor to top left of the screen

		ldx #:ModoText  ; out a string
		jsl PUTS

		pld
		rts

:ModoText   asc 'Modo MOD Player'
			db 13
			asc 'Memory Location:'
			db 0

	dum 0
sample_name        ds 22
sample_length      ds 2
sample_fine_tune   ds 1
sample_volume      ds 1
sample_loop_start  ds 2
sample_loop_length ds 2
sizeof_sample      ds 0
	dend

;------------------------------------------------------------------------------
ModPlayerTick mx %00
		lda <mod_jiffy
		inc
		cmp <mod_speed
		bcs :next_row
		sta <mod_jiffy
		rts
:next_row
		stz <mod_jiffy

; interpret mod_p_current_pattern, for simple note events
; this is called during an interrupt, so I'm working with the idea
; that it's safe to modify the oscillators

:note_period = mod_temp0
:note_sample = mod_temp0+2
:effect_no   = mod_temp1
:effect_parm = mod_temp1+2
:break = mod_temp2
:break_row = mod_temp2+2
:osc_x = mod_temp3
:vol   = mod_temp3+2

		stz <:break

		;lda #$2020 ; $$JGA TODO, adjust the volume over in the volume table construction, instead of here
		;sta <:vol

		ldx #mixer_dpage-MyDP
		stx <:osc_x

		ldy #0
]lp
		lda |mod_channel_pan,y
		sta <:vol

		lda [mod_p_current_pattern],y
		sta <:note_sample
		xba
		and #$FFF ; we have the period
		sta <:note_period

		iny
		iny

		lda #$FF0F
		trb <:note_sample

		lda [mod_p_current_pattern],y
		sta <:effect_no

		lsr
		lsr
		lsr
		lsr
		and #$0F
		tsb <:note_sample

		lda <:effect_no
		xba
		and #$ff
		sta <:effect_parm

		lda #$FFF0
		trb <:effect_no
;----------------------------------- what can I do with this stuff?

;     if (SAMPLE > 0) then {
;	  LAST_INSTRUMENT[CHANNEL] = SAMPLE_NUMBER  (we store this for later)
;	  volume[CHANNEL] = default volume of sample SAMPLE_NUMBER
;     }

		lda <:note_sample
		beq :no_note_sample

		sta |mod_last_sample,y

:no_note_sample

;     if (NOTE exists) then {
;	  if (VIBRATO_WAVE_CONTROL = retrig waveform) then {
;		vibrato_position[CHANNEL] = 0 (see SECTION 5.5 about this)
;	  if (TREMOLO_WAVE_CONTROL = retrig waveform) then {
;		tremolo_position[CHANNEL] = 0 (see SECTION 5.8 about this)
;
;	  if (EFFECT does NOT = 3 and EFFECT does NOT = 5) then
;	      frequency[CHANNEL] =
;			FREQ_TAB[NOTE + LAST_INSTRUMENT[CHANNEL]'s finetune]
;     }
;
;     if (EFFECT = 0 and EFFECT_PARAMETER = 0) then goto to SKIP_EFFECTS label
;									    |
;     ....                                                                   ³
;     PROCESS THE NON TICK BASED EFFECTS (see section 5 how to do this)      ³
;     ALSO GRAB PARAMETERS FOR TICK BASED EFFECTS (like porta, vibrato etc)  ³
;     ....                                                                   ³
;									    ³
;label SKIP_EFFECTS:     <-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;
;     if (frequency[CHANNEL] > 0) then SetFrequency(frequency[CHANNEL])
;	 if (NOTE exists) then {
;	  PLAYVOICE (adding sample_offset[CHANNEL] to start address)
;     }
;     move note pointer to next note (ie go forward 4 bytes in pattern buffer)

;		lda <:note_period
;		beql :nothing

		; do some effect stuff here
		lda <:effect_no
		asl
		tax
		jmp (:effect_table,x)

:effect_table
		da :arpeggio		   ;0
		da :porta_up		   ;1
		da :porta_down  	   ;2
		da :porta_to_note      ;3
		da :vibrato 		   ;4
		da :porta_vol_slide    ;5
		da :vibrato_vol_slide  ;6
		da :tremolo 		   ;7
		da :pan 			   ;8
		da :sample_offset      ;9
		da :vol_slide   	   ;A
		da :jump_to_pattern    ;B
		da :set_volume  	   ;C
		da :pattern_break      ;D
		da :E_things  	   	   ;E
		da :set_speed   	   ;F


:arpeggio
:porta_up
:porta_down
:porta_to_note
:vibrato
:porta_vol_slide
:vibrato_vol_slide
:tremolo
		bra :after_effect
:pan
; Dual Mod Player
;00 = far left
;40 = middle
;80 = far right
;A4 = surround *

; FT2 00 = far left, 80 = center, FF = far right

; how can you know?  (I guess I would analyze all the pan settings in the whole)
; tune, ahead of time, and see what the range is.  Yuck
		bra :after_effect
:sample_offset
:vol_slide
:jump_to_pattern
		bra :after_effect
:set_volume
		pei <:vol

		lda <:effect_parm ; 0-$40
		lsr
		cmp #$20
		bcc :vol_range_ok
		lda #$20   ; clamp
:vol_range_ok
		sta <:vol    ; left
		xba
		tsb <:vol    ; right (until we take into account pan)

		pla
		cmp #$0820
		beq :dim_right

		; dim_left
		lsr <:vol
		lsr <:vol

		bra :not_right
:dim_right

		lsr <:vol+1
		lsr <:vol+1

:not_right

		ldx <:osc_x
		lda <:vol  		; left/right volume (3f max)
		sta <osc_left_vol,x
		bra :after_effect

:pattern_break
		inc <:break 	  			; need to break
		lda <:effect_parm
		sta <:break_row 			; skip to this row, with the break
		bra :after_effect
:E_things
		bra :after_effect
:set_speed
		lda <:effect_parm
		cmp #$20
		bcs :BPM  ; this needs to alter the 50hz timer, Beats Per Minute
		sta <mod_speed
		bra :after_effect

:BPM
		; needs to alter timer, skip for now
:after_effect

;NSTC:  (7159090.5  / (:note_period * 2))/24000 into 8.8 fixed result
;        (3579545.25 / :note_period) / 24000

;149.14771875 / :note_period
;38181 / :note_period
		lda <:note_period
		beq :nothing

		sta |UNSIGNED_DIV_DEM_LO

		lda #38181
		sta |UNSIGNED_DIV_NUM_LO

		lda |UNSIGNED_DIV_QUO_LO
		; frequency
		ldx <:osc_x
		sta <osc_frequency,x

		lda <:vol  		; left/right volume (3f max)
		sta <osc_left_vol,x

		;---- start - this might be a good spot to update the pumpbar out

		sta |mod_pump_vol,y

		;---- end - this might be a good spot to update the pumpbar out

		phy  ; need to preserve

		lda |mod_last_sample,y
		and #$1F
		beq :no_sample

		dec
		asl
		tay
		lda |inst_address_table,y
		tay

		lda |i_sample_length,y
		ora |i_sample_length+2,y
		beq :no_sample


		; wave pointer 24.8
		stz <osc_pWave,x
		lda |i_sample_start_addr,y
		sta <osc_pWave+1,x
		lda |i_sample_start_addr+1,y
		sta <osc_pWave+2,x

		; loop address 24.8
		stz <osc_pWaveLoop,x
		lda |i_sample_loop_start,y
		sta <osc_pWaveLoop+1,x
		lda |i_sample_loop_start+1,y
		sta <osc_pWaveLoop+2,x

		; wave end
		stz <osc_pWaveEnd,x
		lda |i_sample_loop_end,y
		sta <osc_pWaveEnd+1,x
		lda |i_sample_loop_end+1,y
		sta <osc_pWaveEnd+2,x

:no_sample
		ply ; restore y

:nothing

		; c=?
		ldx <:osc_x
		clc
		txa
		adc #sizeof_osc  ; next oscillator, for the next track
		tax
		stx <:osc_x

		iny
		iny
		cpy <mod_row_size ; 4*4 or 8*4
		bccl ]lp

; check for break
		lda <:break
		bne :perform_break

; next row, and so on
		lda <mod_current_row
		inc
		cmp #64 ; number of rows in the pattern
		bcs :next_pattern
		sta <mod_current_row
		;c=0
		lda <mod_p_current_pattern
		adc <mod_row_size ;#4*4 or #8*4
		sta <mod_p_current_pattern
		bcc :no_carry
		inc <mod_p_current_pattern+2
:no_carry
		rts

:next_pattern
		stz <mod_current_row

		lda <mod_pattern_index
		inc
		cmp <mod_song_length
		bcs :song_done
		sta <mod_pattern_index

		bra ModSetPatternPtr

:song_done
		stz <SongIsPlaying
		rts

:perform_break
		jsr :next_pattern

		lda <:break_row  ; 16 bytes in a row, for now
		sta <mod_current_row

		asl
		asl
		asl
		asl
		adc <mod_p_current_pattern
		sta <mod_p_current_pattern
		lda <mod_p_current_pattern+2
		adc #0
		sta <mod_p_current_pattern+2

		rts

;------------------------------------------------------------------------------
; ModPlay (play the current Mod)
;
ModPlay mx %00
; stop existing song
	stz <SongIsPlaying

; Initialize song stuff

	lda #6  ; default speed
	sta <mod_speed
	stz <mod_jiffy

	stz <mod_current_row
	stz <mod_pattern_index
	jsr ModSetPatternPtr

	lda #1
	sta <SongIsPlaying
	rts

;------------------------------------------------------------------------------
ModSetPatternPtr mx %00
	ldy <mod_pattern_index
	lda [mod_p_pattern_dir],y
	and #$7F
	asl
	asl
	tax
	lda |mod_patterns,x
	sta <mod_p_current_pattern
	lda |mod_patterns+2,x
	sta <mod_p_current_pattern+2

	rts

;------------------------------------------------------------------------------
; void ModInit(void* pModFile)
;
; pea ^pModFile
; pea #pModFile
;
; jsl ModInit
;
ModInit mx %00
; Stack
:pModInput = 4

; Zero Page
:pMod    = temp0
:pInstruments = temp1
:pPatterns = temp2
:pSamples  = temp3
:loopCount = temp4
:current_y = temp5
:num_patterns = temp5+2

:pInst = temp6   ; used for the extraction over to the mod_instruments, block

	; default table for volume pan, for fake stereo

	lda #$2008
	sta |mod_channel_pan
	sta |mod_channel_pan+{4*3}
	sta |mod_channel_pan+{4*4}
	sta |mod_channel_pan+{4*7}
	lda #$0820
	sta |mod_channel_pan+{4*1}
	sta |mod_channel_pan+{4*2}
	sta |mod_channel_pan+{4*5}
	sta |mod_channel_pan+{4*6}


	; default to a 4 track mod, we have some 8CHN examples, and the mixer
	; can handle them
	lda #4
	sta <mod_num_tracks

	lda #1024   		   ; most common
	sta <mod_pattern_size

	lda #4*4   		   ; most common
	sta <mod_row_size

	stz <SongIsPlaying  ; no ticking

	lda :pModInput,s
	sta <:pMod
	lda :pModInput+2,s
	sta <:pMod+2

	; --- crap out hex Pointer to the mod

	lda <:pMod+2
	jsr myHEXBYTE
	lda <:pMod
	jsr myPRINTAH
	jsr myPRINTCR

	; --- end crap out hex codes

	; Construct the MOD type string, and dump it out on the terminal

	ldy #1080 ; Magic offset
	lda [:pMod],y
	sta |:temp_buffer
	iny
	iny
	lda [:pMod],y
	sta |:temp_buffer+2
	lda #13
	sta |:temp_buffer+4

;--------------------------------------------------- Validate
;What do we support?

	lda |:temp_buffer
	ldx |:temp_buffer+2
	jsr IsSupportedMod
	bcc :yes

	lda <mod_num_instruments
	cmp #15
	bne :boo
; if it's 15 instruments, it's probably an OG Original MOD
	lda #'mo'
	sta |:temp_buffer
	lda #'d '
	sta |:temp_buffer+2
	bra :yes
:boo
	ldx #:txt_unsupported
	jsr myPUTS

:yes
	ldx #:temp_buffer
	jsr myPUTS				; hopefully M.K.

	ldx #:test
	jsr myPUTS

	; --- print out the mod file's name

	ldx <:pMod
	ldy #:mod_name
	lda <:pMod+2
	xba
	sta |:mv+1   ; only works because K=0
	lda #19  ; 20 bytes
:mv
	mvn 0,0
	phk
	plb

	ldx #:mod_name
	jsr myPUTS
	jsr myPRINTCR

	; --- end print out mod file's name

; --- Copy Sample Data into the mod_instruments block

	ldy #20 ; offset to sample information
	sty <:current_y
	stz <:loopCount		; which instrument are we working on

]inst_fetch_loop

	lda <:loopCount
	asl
	tax
	lda |inst_address_table,x
	sta <:pInst			; is the pointer to the current i_ instrument 

; copy the sample name out for the mod, into the i_name

	tay  ; target address

	; c = 0
	lda <:pMod
	adc <:current_y
	tax  ; source address

	lda <:pMod+2
	xba
	sta |:nm_mvn+1

	lda #21    	  ; hard coded length used in MOD files
	phb
:nm_mvn mvn 0,0   ; copy the string
	plb

; advance y
	lda <:current_y
	adc #22  	  ; hard coded length, used in MOD files
	sta <:current_y
	tay

	ldx <:pInst
	lda [:pMod],y
	xba 			  	; endian
	asl 				; length * 4, because our samples are 2x the size of the samples in the mod, and the length in the file is half the size, to save space
	rol |i_sample_length+2,x
	asl
	rol |i_sample_length+2,x
	sta |i_sample_length,x

;PAL:   7093789.2 / (428 * 2) = 8287.14hz
;NSTC:  7159090.5 / (428 * 2) = 8363.42hz

	; set the sample rate

	lda #8363
	sta |i_sample_rate,x

	; set the key, it happens to be C2

	lda #36 ; midi value for C2, probably won't even be used in Modo
	sta |i_key_center,x

	iny
	iny ; now y is pointing at the fine tune

	lda [:pMod],y
	and #$FF
	sta |i_fine_tune,x

	iny ; now y is pointing at the volume

	lda [:pMod],y
	and #$FF
	sta |i_volume,x

	iny ; now y is pointing at the loop start offset
	lda [:pMod],y
	xba           ; adjust for endian
	; just like the length above, we need to multiply by 2 (because in amiga
	; mod file, this value is half what it should be), we need to multiply by 2
	; 1 more time, because our wave data takes 16 bits
	asl
	rol |i_sample_loop_start+2,x
	asl
	rol |i_sample_loop_start+2,x
	sta |i_sample_loop_start,x     	; this just contains the loop start, as an offset for now

	iny
	iny ; now y is pointing at the loop_length
	lda [:pMod],y
	xba
	stz |i_loop,x
	cmp #2
	bcc :no_loop

	inc |i_loop,x  ; mark it as looping

:no_loop

	;asl
	;rol |i_sample_loop_end+2,x
	;asl
	;rol |i_sample_loop_end+2,x
	;sta |i_sample_loop_end,x  	; this is just the loop length at this point, temporary

	iny
	iny
	sty <:current_y

	lda <:loopCount
	inc
	sta <:loopCount
	cmp <mod_num_instruments
	bccl ]inst_fetch_loop

; --- End - Copy Sample Data into the mod_instruments block


	do OLD_DUMP
	; --- Dump out Sample Information

	ldy #20 ; offset to sample information
	sty <:current_y
	stz <:loopCount

:SampleDumpLoop
	ldy <:current_y
	ldx #0
]lp	lda [:pMod],y
	sta |:sample_name,x
	iny
	iny
	inx
	inx
	cpx #22
	bcc ]lp

	sty <:current_y

; Copy the string over into the instruments array

;	lda <:loopCount
;	asl
;	tax
;	lda |inst_address_table,x
;	tay							; y is the address of our i_name, for our current instrument
;	ldx #:sample_name           ; x is the source address of the instrument string
;	lda #21
;	mvn ^:sample_name,^mod_instruments

	; Current Sample #
	lda <:loopCount
	inc
	jsr myPRINTAH
	ldx #:space
	jsr myPUTS

    ; Current Sample Name
	ldx #:sample_name
	jsr myPUTS
	;ldx #:space
	;jsr myPUTS
	ldy |CURSORY
	ldx #28
	jsr myLOCATE

    ; Sample Length
	ldx #:sample_length
	jsr myPUTS
	ldy <:current_y
	lda [:pMod],y
	xba ;endian
	iny
	iny
	sty <:current_y
	jsr myPRINTAH
	ldx #:space
	jsr myPUTS

	; Fine Tune
	ldx #:fine_tune
	jsr myPUTS
	ldy <:current_y
	lda [:pMod],y
	and #$FF
	iny
	sty <:current_y
	jsr myHEXBYTE
	ldx #:space
	jsr myPUTS

	; Volume
	ldx #:volume
	jsr myPUTS
	ldy <:current_y
	lda [:pMod],y
	and #$FF
	iny
	sty <:current_y
	jsr myHEXBYTE
	ldx #:space
	jsr myPUTS

	; Loop Start
	ldx #:loop_start
	jsr myPUTS
	ldy <:current_y
	lda [:pMod],y
	xba ;endian
	iny
	iny
	sty <:current_y
	jsr myPRINTAH
	ldx #:space
	jsr myPUTS

	; Loop Length
	ldx #:loop_length
	jsr myPUTS
	ldy <:current_y
	lda [:pMod],y
	xba ;endian
	iny
	iny
	sty <:current_y
	jsr myPRINTAH
	ldx #:space
	jsr myPUTS

	jsr myPRINTCR

	lda <:loopCount
	inc
	sta <:loopCount
	cmp <mod_num_instruments
	bccl :SampleDumpLoop
	fin
	; --- end Dump out Sample Information

	ldx #0
	ldy #36
	jsr myLOCATE

	; Song Length
	ldx #:song_len
	jsr myPUTS
	ldy <:current_y
	lda [:pMod],y
	and #$FF
	inc
	sta <mod_song_length
	iny
	iny
	sty <:current_y
	jsr myHEXBYTE
	jsr myPRINTCR

	;save off the pointer to pattern directory
	clc
	lda <:pMod
	adc <:current_y
	sta <mod_p_pattern_dir
	lda <:pMod+2
	adc #0
	sta <mod_p_pattern_dir+2
	; initialize our index
	stz <mod_pattern_index

	; Patterns
	stz <:num_patterns
	stz <:loopCount
]lp
	ldy <:current_y
	lda [:pMod],y
	iny
	sty <:current_y

	; how many total patterns in file?
	and #$00FF
	cmp <:num_patterns
	bcc :no_update
	sta <:num_patterns
:no_update
	pha
	ldx #:space
	jsr myPUTS
	pla
	jsr myHEXBYTE

	lda <:loopCount
	and #$1F
	cmp #$1F
	bne :skip
	jsr myPRINTCR
:skip
	lda <:loopCount
	inc
	sta <:loopCount
	cmp #128
	bcc ]lp

	inc <:num_patterns

; now at position 1080 / M.K.

	ldx #:pattern_count
	jsr myPUTS
	lda <:num_patterns
	jsr myHEXBYTE
	ldx #:space
	jsr myPUTS

;	jsr myPRINTCR

	lda <mod_num_instruments
	cmp #15
	bne :mkmod

	clc
	lda <:pMod
	adc #1080-{16*30}   	 	; old school mod
	bra :oldmod
:mkmod
	; Calculate pPatterns
	clc
	lda <:pMod
	adc #1084					; modern mod
:oldmod
	sta <:pPatterns
	lda <:pMod+2
	adc #0
	sta <:pPatterns+2

	; How Large is a pattern block
	; 4 channels * 4 bytes * 64
	; (1024 * num_patterns)

	; Calculate pSamples
	; First poke in the size of patterns
	stz <:pSamples+2

; pointer to the samples

	ldx <mod_num_tracks

	lda <:num_patterns
	xba  ; x 256
	asl  ; x 512
	rol <:pSamples+2
	asl  ; x 1024
	;sta <:pSamples
	rol <:pSamples+2
	php
	cpx #4
	beq :track_continue  ;4 tracks
	plp
	; 8 tracks
	asl ; x 2048
	rol <:pSamples+2
	php
:track_continue
	plp
	; c=0
	adc <:pPatterns
	sta <:pSamples
	lda <:pPatterns+2
	adc <:pSamples+2
	sta <:pSamples+2


	; print out the pPatterns
	ldx #:txt_pPatterns
	jsr myPUTS

	lda <:pPatterns+2
	jsr myHEXBYTE
	lda <:pPatterns
	jsr myPRINTAH

	ldx #:space
	jsr myPUTS

	; print out the pSamples
	ldx #:txt_pSamples
	jsr myPUTS
	lda <:pSamples+2
	jsr myHEXBYTE
	lda <:pSamples
	jsr myPRINTAH

	jsr myPRINTCR
	;
	; Load Audio into Sound Memory
	; It will follow the same layout as it is in the current
	; memory, using the #define AUDIO_RAM
	; The 8 bit PCM is transformed into a 16 bit memory address
	; that is used to look up volume in the mixer, the VDMA has to work
	; with even strides, so it's "scaling" ability can only work with
	; 16-bit units, so this is sort of a happy serendipity, that this
	; works out well for dynamically applying audio scale
	;

	; Save For Later
	lda |CURSORX
	pha
	lda |CURSORY
	pha
	; place the mem copies on screen next to inst info
	ldy #5
	sty |CURSORY

	clc
	lda <:pMod
	adc #20		; calculate pInstuments
	sta <:pInstruments
	lda <:pMod+2
	adc #0
	sta <:pInstruments+2

:pVRAM = temp7
:pSamp = temp8
:tCount = temp9
:pTemp = temp9
:pLoop = lzsa_sourcePtr
:pEnd  = lzsa_destPtr
:pSrc  = lzsa_matchPtr

	lda #scratch_ram
	sta <:pTemp


	lda <mod_num_instruments   	 ; up to 31 instruments
	sta <:loopCount
	;
	; TARGET Video RAM Location
	; Trying to go directly to VRAM, even though it doesn't seem
	; reliable
	; 
	lda #AUDIO_RAM
	sta <:pVRAM
	lda #^AUDIO_RAM
	sta <:pVRAM+2
	; Set up pointer to Instrument 0
	lda <:pInstruments
	sta <:pInst
	lda <:pInstruments+2
	sta <:pInst+2
	; Setup pointer to Sample 0
	lda <:pSamples
	sta <:pSamp
	lda <:pSamples+2
	sta <:pSamp+2

]copyloop
	do OLD_DUMP     ; old mod->VRAM table print out
	ldy |CURSORY
	ldx #75
	jsr myLOCATE

	lda <:pSamp+2    	; Sample RAM Address
	jsr myHEXBYTE
	lda <:pSamp
	jsr myPRINTAH
	ldx #:txt_too
	jsr myPUTS
	lda <:pVRAM+2  		; Sample VRAM Address
	jsr myHEXBYTE
	lda <:pVRAM
	jsr myPRINTAH
	jsr myPRINTCR
	fin

	; Save out the start pointers to the wave data, so we can update the mod_instruments when we're done here
	lda <:pVRAM
	sta (:pTemp)
	inc <:pTemp
	inc <:pTemp
	lda <:pVRAM+2
	sta (:pTemp)
	inc <:pTemp
	inc <:pTemp


	ldy #sample_length
	lda [:pInst],y
	beql :skip_empty	; skip, empty entry
	xba					; fix endian
	tax					; x = counter

	; set up the :pLoop
	stz <:pLoop
	stz <:pLoop+2 ; default to no loop

	ldy #sample_loop_start
	lda [:pInst],y
	xba
	bne :itloops

	; maybe it loops
	ldy #sample_loop_length
	lda [:pInst],y
	xba
	cmp #2
	bcc :noloops
	lda #0
:itloops
; A is 1/2 the offset to the loop (there's not enough bits to ASL)

	pha

	; Add it once
	lda <:pVRAM
	adc 1,s
	sta <:pLoop
	lda <:pVRAM+2
	adc #0
	sta <:pLoop+2

	clc
	pla
	; Add it again
	adc <:pLoop
	sta <:pLoop
	lda <:pLoop+2
	adc #0
	sta <:pLoop+2


:noloops

	; :pLoop either points to the source loop address
	;        or :pLoop is nullptr 

	; Actual Data Copy into VRAM

	ldy #0
]waveloop
	lda [:pSamp]
	tay
	and #$FF
	asl 				; c=0
	sta [:pVRAM]

	lda <:pVRAM			; pVRAM+=2
	adc #2
	sta <:pVRAM
	bcc :noover
	inc <:pVRAM+2
:noover
	tya
	xba
	and #$FF
	asl 				; c=0
	sta [:pVRAM]

	lda <:pVRAM			; VRAM+=2
	adc #2
	sta <:pVRAM
	bcc :noover2
	inc <:pVRAM+2
:noover2

	clc
	lda <:pSamp		; pSamp+=2
	adc #2
	sta <:pSamp
	lda #0
	adc <:pSamp+2
	sta <:pSamp+2
	dex 			; via mod spec, the actual length is 2x the recorded length
	bne ]waveloop

;------- the mixer needs some buffer space placed on the end of the sample
; for performance reasons the mixer only checks for loop points every 256
; samples, my back of the envelope math says we need a buffer of 1024 samples
; instruments in a mod will never be played at more than 96Khz
; 1024 samples = 2048 bytes.
;
; I currently only support looping from the end of the wave, back to the loop
; point.  If the sample does not loop, we still need this pad space at the end
; and it needs to be filled with silence (non looping samples still loop, but
; can do so in the silence)
;
	; we need a pointer back to the loop point, and need to perform circular
	; copy to fill in the padding, to make the looping work with my mixer

; -- $$ I just realized this is all broken

	ldx #1024 ; we need 1024 more samples

	; pEnd points at the last sample
	sec
	lda <:pVRAM
	sbc #2
	sta <:pEnd
	lda <:pVRAM+2
	sbc #0
	sta <:pEnd+2

	; :pVRAM points at the location the next sample
	; will be stored

	; :pLoop, points to the loop location

	lda <:pLoop
	ora <:pLoop+2
	bne :loop_not_null

	lda <:pEnd
	sta <:pLoop
	lda <:pEnd+2
	sta <:pLoop+2

:loop_not_null

	lda <:pLoop
	sta <:pSrc
	lda <:pLoop+2
	sta <:pSrc+2

; here we have out sample count in x
; we have valid pointers in
; :pVRAM
; :pLoop
; :pEnd
; :pSrc

]padding_loop
	lda [:pSrc]
	sta [:pVRAM]

; increment output 1 location - straight forward
	clc
	lda <:pVRAM
	adc #2
	sta <:pVRAM
	lda <:pVRAM+2
	adc #0
	sta <:pVRAM+2

; increment source location
	lda <:pSrc
	adc #2
	sta <:pSrc
	lda <:pSrc+2
	adc #0
	sta <:pSrc+2

; if source is > pEnd
; then source = pLoop

	cmp <:pEnd+2
	bcc :pad_continue
	bne :pad_reset

	lda <:pSrc
	cmp <:pEnd
	bcc :pad_continue
	beq :pad_continue

:pad_reset

	lda <:pLoop
	sta <:pSrc
	lda <:pLoop+2
	sta <:pSrc+2

:pad_continue
	dex
	bne ]padding_loop

;$$JGA Temp hack, to keep samples from spanning banks
;$$JGA TODO, REMOVE THIS CODE WHEN BANK SPANNER IS WORKING

	inc <:pVRAM+2
	stz <:pVRAM


:skip_empty

	; next Inst Structure
	clc
	lda <:pInst
	adc #sizeof_sample
	sta <:pInst
	lda #0
	adc <:pInst+2
	sta <:pInst+2

	dec <:loopCount ; loop count
	bnel ]copyloop

; Restore Cursor

	ply
	plx
	jsr myLOCATE
	jsr myPRINTCR

; -----------------------------------------------------------------------------
; init the mod_patterns table
:pCurPattern = lzsa_nibble

	lda <:pPatterns
	sta <:pCurPattern
	lda <:pPatterns+2
	sta <:pCurPattern+2

	clc

	ldx #127
	ldy #0
]lp
	lda <:pCurPattern
	sta |mod_patterns,y
	adc <mod_pattern_size  ; 64*4*4
	sta <:pCurPattern

	lda <:pCurPattern+2
	sta |mod_patterns+2,y
	adc #0
	sta <:pCurPattern+2

	tya
	adc #4
	tay
	dex
	bpl ]lp

; -----------------------------------------------------------------------------
; Print out the contents of a Pattern Block
	do 0
:pBlockAddress = 44

	lda <:pPatterns
	sta <:pBlockAddress
	lda <:pPatterns+2
	sta <:pBlockAddress+2

	lda #15
	sta <:tCount
]lp
	jsr PrintPatternRow
	jsr myPRINTCR
	clc
	lda <:pBlockAddress
	adc <mod_row_size			; add rowsize
	sta <:pBlockAddress
	bne :cntu
	inc <:pBlockAddress+2
:cntu
	dec <:tCount
	bpl ]lp
	fin

; -----------------------------------------------------------------------------

; finish fixing up the mod_instruments
; now that we know where they live in memory

	ldx #mod_instruments-MyDP
	lda #scratch_ram
	sta <:pTemp

	ldy <mod_num_instruments

]loop
	lda (:pTemp)
	inc <:pTemp
	inc <:pTemp
	sta <i_sample_start_addr,x
	lda (:pTemp)
	inc <:pTemp
	inc <:pTemp
	sta <i_sample_start_addr+2,x

	; if the loop start is 0
	lda <i_sample_loop_start,x
	ora <i_sample_loop_start+2,x
	bne :doesloop

	lda <i_loop,x
	bne :doesloop

	; does not loop

	lda <i_sample_length,x
	sta <i_sample_loop_start,x
	lda <i_sample_length+2,x
	sta <i_sample_loop_start+2,x

	; take 2 away from the start
;	sec
;	lda <i_sample_loop_start,x
;	sbc #2
;	sta <i_sample_loop_start,x
;	lda <i_sample_loop_start+2,x
;	sbc #0
;	sta <i_sample_loop_start+2,x



:doesloop
	clc
	lda <i_sample_start_addr,x
	adc <i_sample_loop_start,x
	sta <i_sample_loop_start,x
	lda <i_sample_start_addr+2,x
	adc <i_sample_loop_start+2,x
	sta <i_sample_loop_start+2,x

	clc
	lda <i_sample_start_addr,x
	adc <i_sample_length,x
	sta <i_sample_loop_end,x
	lda <i_sample_start_addr+2,x
	adc <i_sample_length+2,x
	sta <i_sample_loop_end+2,x

	clc
	lda <i_sample_loop_end,x
	adc #1024*2 ; make 4.0 play rate
	sta <:pEnd
	lda <i_sample_loop_end+2,x
	adc #0
	sta <:pEnd+2

	; take 2 away from the loop end
;	sec
;	lda <i_sample_loop_end,x
;	sbc #2
;	sta <i_sample_loop_end,x
;	lda <i_sample_loop_end+2,x
;	sbc #0
;	sta <i_sample_loop_end+2,x

; flag for expensive resampler
	stz <i_sample_spans_bank,x

;	lda <:pEnd+2
	cmp <i_sample_start_addr+2,x
	beq :no_span

	; flag it as spanning bank, expensive resample
	inc <i_sample_spans_bank,x
:no_span
	clc
	txa
	adc #sizeof_inst
	tax
	dey
	bne ]loop

; -----------------------------------------------------------------------------
; alternate instrument dump, based on mod_instruments

	do OLD_DUMP
	else

	ldx #mod_instruments-MyDP
	stx <:pInst

	stz <:loopCount
]loop

	ldx #0
	lda <:loopCount
	clc
	adc #5
	sta <:current_y  ; for y position on the screen in this case

	tay
	jsr fastLOCATE

	lda <:loopCount
	inc
	jsr fastHEXBYTE

	lda #' '
	fastPUTC

	; Instrument name
	clc
	lda <:pInst
	adc #MyDP
	tax
	jsr fastPUTS

	ldy <:current_y
	ldx #28
	jsr fastLOCATE

	; Sample Length in bytes
	ldx #:sample_length
	jsr fastPUTS

	ldx <:pInst
	lda <i_sample_length+2,x
	jsr fastHEXBYTE
	ldx <:pInst
	lda <i_sample_length,x
	jsr fastHEXWORD

	lda #' '
	fastPUTC

	; Fine Tune
	ldx #:fine_tune
	jsr fastPUTS
	ldx <:pInst
	lda <i_fine_tune,x
	jsr fastHEXBYTE
	lda #' '
	fastPUTC

	; Volume
	ldx #:volume
	jsr fastPUTS
	ldx <:pInst
	lda <i_volume,x
	jsr fastHEXBYTE
	;lda #' '
	;fastPUTC

	; Wave Start
	ldx #:sample_start
	jsr fastPUTS
	ldx <:pInst
	lda <i_sample_start_addr+2,x
	jsr fastHEXBYTE
	ldx <:pInst
	lda <i_sample_start_addr,x
	jsr fastHEXWORD 
	lda #' '
	fastPUTC

	; Loop Start
	ldx #:loop_start
	jsr fastPUTS
	ldx <:pInst
	lda <i_sample_loop_start+2,x
	jsr fastHEXBYTE
	ldx <:pInst
	lda <i_sample_loop_start,x
	jsr fastHEXWORD
	;lda #' '
	;fastPUTC

	; end
	ldx #:sample_end
	jsr fastPUTS
	ldx <:pInst
	lda <i_sample_loop_end+2,x
	jsr fastHEXBYTE
	ldx <:pInst
	lda <i_sample_loop_end,x
	jsr fastHEXWORD

	ldx <:pInst
	lda <i_sample_spans_bank,x
	beq :no_bank_problem

	lda #'*'
	fastPUTC

:no_bank_problem

	clc
	lda <:pInst
	adc #sizeof_inst
	sta <:pInst

	lda <:loopCount
	inc
	sta <:loopCount
	cmp <mod_num_instruments
	bccl ]loop

	fin

; -----------------------------------------------------------------------------

; Copy Return Address
	lda 1,s
	sta 5,s
	lda 2,s
	sta 6,s

	pla	; adjust stack
	pla

	rtl

:space asc ' '
	db 0
:sample_start asc ' start:'
	db 0
:sample_end asc ' end:'
	db 0
:sample_length asc 'len:'
	db 0
:fine_tune asc 'tune:'
	db 0
:volume asc 'vol:'
	db 0
:loop_start asc 'loop:'
	db 0
:loop_length asc 'lplen:'
	db 0

:song_len asc 'song length:'
	db 0

:txt_unsupported cstr 'Unsupportted Mod Type:'

:pattern_count asc 'pattern count:'
	db 0

:txt_pPatterns asc 'pPatterns:'
	db 0

:txt_pSamples asc 'pSamples:'
	db 0

:txt_too asc '->'
	db 0

:mod_name ds 21
:sample_name ds 24

:test
	asc '---------------------------------------------------------------------'
	db 13,0

:temp_buffer
	ds 16

;------------------------------------------------------------------------------
; AX = the mod code
IsSupportedMod mx %00
		sta <mod_type_code
		stx <mod_type_code+2

		ldy #31					; most common MOD
		sty <mod_num_instruments

		ldy #4 					; most common
		sty <mod_num_tracks

		ldy #1024   		   ; most common
		sty <mod_pattern_size

		ldy #4*4   		   ; most common
		sty <mod_row_size

		stz <mod_type

		cmp |:mk
		bne :no
		cpx |:mk+2
		bne :no
		clc
		rts
:no
		cmp |:8chn
		bne :not_8chn
		cpx |:8chn+2
		bne :not_8chn

		ldy #8  				; 8 tracks
		sty <mod_num_tracks

		ldy #2048               ; 8 tracks 
		sty <mod_pattern_size

		ldy #4*8   		        ; 8 tracks 
		sty <mod_row_size

		clc
		rts
:not_8chn
		sep #$30

		lda <mod_type_code
		jsr :is_letter
		bcs :old_mod

		lda <mod_type_code+1
		jsr :is_letter
		bcs :old_mod

		lda <mod_type_code+2
		jsr :is_letter
		bcs :old_mod

		lda <mod_type_code+3
		jsr :is_letter
		bcc :letters
:old_mod
		lda #15					; really old mod
		sta <mod_num_instruments
:letters
		rep #$30
		sec
		rts

:is_letter mx %11
		cmp #$20
		bcc :not_letter
		cmp #$7F
		bcs :not_letter
		; c=0 -> is letter
		rts
:not_letter
		sec
		rts
;
; if there are no letters here, then it's a 16 instrument mod
; like the BETWEEN.MOD I have
;
:mk asc 'M.K.'

; TBD - I feel like I should be able to support all these
		asc 'M!K!'
		asc '4CHN'
		asc '6CHN'
:8chn	asc '8CHN'
		asc 'FLT4'
		asc 'FLT8'


;------------------------------------------------------------------------------
;
; Place Row Pointer in Location 44
;
PrintPatternRow mx %00
:pRow = temp5
:cur_row = temp6

	lda <:cur_row
	and #$3F
	jsr fastHEXBYTE

	lda #'|'
	fastPUTC

	ldy #2
	lda [:pRow],y
	tax
	lda [:pRow]
	jsr PrintNoteInfo

	lda #'|'
	fastPUTC

	ldy #6
	lda [:pRow],y
	tax
	ldy #4
	lda [:pRow],y
	jsr PrintNoteInfo

	lda #'|'
	fastPUTC

	ldy #10
	lda [:pRow],y
	tax
	ldy #8
	lda [:pRow],y
	jsr PrintNoteInfo

	lda #'|'
	fastPUTC

	ldy #14
	lda [:pRow],y
	tax
	ldy #12
	lda [:pRow],y
	jsr PrintNoteInfo

	ldy <mod_num_tracks
	cpy #4
	beq :done
	lda #'| '
	fastPUTC
;	inc <pFastPut
]offset = 0
	ldy #18+]offset
	lda [:pRow],y
	tax
	ldy #16+]offset
	lda [:pRow],y
	jsr PrintNoteInfo

	lda #'| '
	fastPUTC

]offset = ]offset+4
	ldy #18+]offset
	lda [:pRow],y
	tax
	ldy #16+]offset
	lda [:pRow],y
	jsr PrintNoteInfo

	lda #'| '
	fastPUTC

]offset = ]offset+4

:done
	rts

;------------------------------------------------------------------------------
;
; Print out info about a single note
;
; AX = 4 bytes of the note
;
PrintNoteInfo mx %00
:note   = temp0
:period = temp1
:effect = temp2

	; Save DP locations
	pei :note
	pei :note+2
	pei :period
	pei :effect

	sta <:note
	stx <:note+2

	; Decode the Period
	;sep #$20
	;lsr
	;lsr
	;lsr
	;lsr
	rep #$30
	xba
	and #$0FFF
	sta <:period

	; Convert into Note!

	; Init Note String
	lda #'..'
	ldx #'. '
	ldy #' .'
	sta |:note_string
	stx |:note_string+2
	sta |:note_string+4
	sty |:note_string+6
	stx |:note_string+8
	sta |:note_string+10
	sta |:note_string+12
	stz |:note_string+13

	lda <:period
	beq :no_period

; Find the period index

	;ldx #{12*2*6}-2
	ldx #{12*2*3}-2
]lp
	cmp |:tuning,x
	beq :stop
	bcc :stop
	dex
	dex
	bne ]lp
:stop
; period index, into a note string
	txa
	asl
	tax
	lda |:tuning_str,x
	sta |:note_string
	lda |:tuning_str+2,x
	sta |:note_string+2

:no_period

; Sample #

	lda #0	; clear B (of AB)
	sep #$20
	lda <:note+2
	lsr 			; 4 LSBs of the Sample #
	lsr
	lsr
	lsr
	pha
	lda <:note
	and #$F0  		; 4 MSBs of the Sample #
	ora 1,s
	sta 1,s
	beq :skip_sample
	; fetch char
	lsr
	lsr
	lsr
	lsr
	tax
	lda |:chars,x
	sta |:note_string+4

	lda 1,s
	and #$F
	tax
	lda |:chars,x
	sta |:note_string+5
	;--end
:skip_sample
	pla			; sample #
	beq	:skip_volume

	dec

	rep #$31

	asl
	tax
	lda |inst_address_table,x  ; instrument address
	tax
	lda |i_volume,x			   ; instrument volume

	sep #$30
	tay
	and #$F0
	lsr
	lsr
	lsr
	lsr
	tax
	lda #'v'
	sta |:note_string+6
	lda |:chars,x
	sta |:note_string+7
	tya
	and #$0F
	tax
	lda |:chars,x
	sta |:note_string+8

:skip_volume

	rep #$31

	lda <:note+2
	xba
	and #$FFF
	sta <:effect

	sep #$30
	ora <:effect+1
	beq :skip_effect

	; spit out effect nibbles
	ldx <:effect+1
	lda |:chars,x
	sta |:note_string+10
	lda <:effect
	lsr
	lsr
	lsr
	lsr
	tax
	lda |:chars,x
	sta |:note_string+11
	lda <:effect
	and #$0F
	tax
	lda |:chars,x
	sta |:note_string+12
:skip_effect
	rep #$31


	ldx #:note_string
	jsr fastPUTS

	; Restore DP Locations
	pla
	sta <:effect
	pla
	sta <:period
	pla
	sta <:note+2
	pla 
	sta <:note

	rts

:chars  ASC '0123456789ABCDEF'

:dotdotdot asc '... .. .. ...'
			db 0

:note_string ds 16	; 12 byte, with 0 terminator, simulate output from OpenMPT

:tuning
	dw 856,808,762,720,678,640,604,570,538,508,480,453 ; C-1 to B-1
	dw 428,404,381,360,339,320,302,285,269,254,240,226 ; C-2 to B-2
	dw 214,202,190,180,170,160,151,143,135,127,120,113 ; C-3 to B-3
	dw 214/2,202/2,190/2,180/2,170/2,160/2,151/2,143/2,135/2,127/2,120/2,113/2 ; C-4 to B-4
	dw 214/4,202/4,190/4,180/4,170/4,160/4,151/4,143/4,135/4,127/4,120/4,113/4 ; C-5 to B-5
	dw 214/8,202/8,190/8,180/8,170/8,160/8,151/8,143/8,135/8,127/8,120/8,113/8 ; C-6 to B-6

:tuning_str
	asc 'C-1 C#1 D-1 D#1 E-1 F-1 F#1 G-1 G#1 A-1 A#1 B-1 '
	asc 'C-2 C#2 D-2 D#2 E-2 F-2 F#2 G-2 G#2 A-2 A#2 B-2 '
	asc 'C-3 C#3 D-3 D#3 E-3 F-3 F#3 G-3 G#3 A-3 A#3 B-3 '
	asc 'C-4 C#4 D-4 D#4 E-4 F-4 F#4 G-4 G#4 A-4 A#4 B-4 '
	asc 'C-5 C#5 D-5 D#5 E-5 F-5 F#5 G-5 G#5 A-5 A#5 B-5 '
	asc 'C-6 C#6 D-6 D#6 E-6 F-6 F#6 G-6 G#6 A-6 A#6 B-6 '


;------------------------------------------------------------------------------

mt_PeriodTable
; Tuning -8
	dw 907,856,808,762,720,678,640,604,570,538,508,480
	dw 453,428,404,381,360,339,320,302,285,269,254,240
	dw 226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dw 900,850,802,757,715,675,636,601,567,535,505,477
	dw 450,425,401,379,357,337,318,300,284,268,253,238
	dw 225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dw 894,844,796,752,709,670,632,597,563,532,502,474
	dw 447,422,398,376,355,335,316,298,282,266,251,237
	dw 223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dw 887,838,791,746,704,665,628,592,559,528,498,470
	dw 444,419,395,373,352,332,314,296,280,264,249,235
	dw 222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dw 881,832,785,741,699,660,623,588,555,524,494,467
	dw 441,416,392,370,350,330,312,294,278,262,247,233
	dw 220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dw 875,826,779,736,694,655,619,584,551,520,491,463
	dw 437,413,390,368,347,328,309,292,276,260,245,232
	dw 219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dw 868,820,774,730,689,651,614,580,547,516,487,460
	dw 434,410,387,365,345,325,307,290,274,258,244,230
	dw 217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dw 862,814,768,725,684,646,610,575,543,513,484,457
	dw 431,407,384,363,342,323,305,288,272,256,242,228
	dw 216,203,192,181,171,161,152,144,136,128,121,114

; Tuning 0, Normal
	;    C-1 C#1 D-1 D#1 E-1 F-1 F#1 G-1 G#1 A-1 A#1 B-1
	dw 856,808,762,720,678,640,604,570,538,508,480,453 ; C-1 to B-1
	dw 428,404,381,360,339,320,302,285,269,254,240,226 ; C-2 to B-2
	dw 214,202,190,180,170,160,151,143,135,127,120,113 ; C-3 to B-3

; Tuning 1
	dw 850,802,757,715,674,637,601,567,535,505,477,450 ; same as above
	dw 425,401,379,357,337,318,300,284,268,253,239,225 ; but with
	dw 213,201,189,179,169,159,150,142,134,126,119,113 ; finetune +1
; Tuning 2
	dw 844,796,752,709,670,632,597,563,532,502,474,447 ; etc,
	dw 422,398,376,355,335,316,298,282,266,251,237,224 ; finetune +2
	dw 211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dw 838,791,746,704,665,628,592,559,528,498,470,444
	dw 419,395,373,352,332,314,296,280,264,249,235,222
	dw 209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dw 832,785,741,699,660,623,588,555,524,495,467,441
	dw 416,392,370,350,330,312,294,278,262,247,233,220
	dw 208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dw 826,779,736,694,655,619,584,551,520,491,463,437
	dw 413,390,368,347,328,309,292,276,260,245,232,219
	dw 206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dw 820,774,730,689,651,614,580,547,516,487,460,434
	dw 410,387,365,345,325,307,290,274,258,244,230,217
	dw 205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dw 814,768,725,684,646,610,575,543,513,484,457,431
	dw 407,384,363,342,323,305,288,272,256,242,228,216
	dw 204,192,181,171,161,152,144,136,128,121,114,108

	put colors.s
	put i256.s
	put dma.s

;------------------------------------------------------------------------------
;
; Configure the Oscillator Graphics
; We need 16 sprites, to show off the wave data in the Oscillators
;
InitOscSprites mx %00

:pTile = temp0

; Clear those sprites to transparent
		lda #0
		ldx #32*32*16
]clear
		sta >VRAM_OSC_SPRITES,x
		dex
		dex
		bpl ]clear

		; current background is using LUT0
		; we can use LUT1
		phkb ^SP00_CONTROL_REG
		plb

		ldx #0
]lp
		lda #SPRITE_Enable+SPRITE_LUT1
		sta |SP00_CONTROL_REG,x

		txa     ; x8
		xba 	; x2048
		lsr 	; x1024

		sta |SP00_ADDY_PTR_L,x
;		sta <:pTile
		lda #^{VRAM_OSC_SPRITES-VRAM}
		sta |SP00_ADDY_PTR_H,x
;		lda #^VRAM_OSC_SPRITES
;		sta <:pTile+2

		lda #SCOPES_Y+32
		sta |SP00_Y_POS_L,x
		txa
		
		; I want x40
		;asl
		;asl
		asl  ; x8
		pha
		;asl
		asl  ; x32
		adc 1,s
		sta 1,s
		pla  ; x40

		clc
;		adc #32+80 ; center them
		adc #SCOPES_X+32

		sta |SP00_X_POS_L,x

		;lda #$0101 ; text pixel
		;sta [:pTile]

		clc
		txa
		adc #8  ; next sprite tile
		tax
		cmp #8*16 ; 16 tiles, because we have 8 channels x 2, for stereo
		bcc ]lp

		do 0
; Set some LUT1 Colors
		lda #$FFFF  		 	; color index 1, is white
		sta |GRPH_LUT1_PTR+4
		sta |GRPH_LUT1_PTR+4+2

		lda #$FF00
		stz |GRPH_LUT1_PTR+8
		sta |GRPH_LUT1_PTR+8+2
		fin

	    plb
		rts

;------------------------------------------------------------------------------
UpdateOSC0Sprite mx %00
; MIXFIFO - Here we go
; VRAM_OSC_SPRITES, here's where the 32x32 sprite lives

		lda #0     ; erase
		jsr :draw
		; update to new positions

]count = 0
]outcount = 0
		lup 32
		lda >MIXFIFO+5+{]count*77}
		clc
		adc #$100
		and #$1E0
		;lsr 	; 255

		; 0=255, we want 0-31
		;lsr  ;127 
		;lsr  ;63
		;lsr  ;31

		; I think a 512 entry lookup table might be faster
		; now I need this x32
		;asl
		;asl
		;asl
		;asl
		asl
		adc #VRAM_OSC_SPRITES+]outcount
		sta |:draw+7+{]outcount*3}
]count = ]count+8
]outcount = ]outcount+1
		--^   	

		lda #1
		; drop down to draw the new positions
:draw
		phkb ^VRAM_OSC_SPRITES
		plb
		sep #$20
		lup 32
		sta |0 
		--^
		rep #$30
		plb
		rts

;------------------------------------------------------------------------------
UpdateOSC0SpriteR mx %00
; MIXFIFO - Here we go
; VRAM_OSC_SPRITES, here's where the 32x32 sprite lives

		lda #0     ; erase
		jsr :draw
		; update to new positions

]count = 0
]outcount = 0
		lup 32
		lda >MIXFIFO+38+{]count*77}
		clc
		adc #$100
		and #$1E0
		;lsr
		;lsr
		adc #{8*32}
		;lsr 	; 255

		; 0=255, we want 0-31
		;lsr  ;127 
		;lsr  ;63
		;lsr  ;31

		; I think a 512 entry lookup table might be faster
		; now I need this x32
		;asl
		;asl
		;asl
		;asl
		;asl
		adc #VRAM_OSC_SPRITES+]outcount+{32*32*1}
		sta |:draw+7+{]outcount*3}
]count = ]count+8
]outcount = ]outcount+1
		--^   	

		lda #2
		; drop down to draw the new positions
:draw
		phkb ^VRAM_OSC_SPRITES
		plb
		sep #$20
		lup 32
		sta |0 
		--^
		rep #$30
		plb
		rts

;------------------------------------------------------------------------------
UpdateOSC1Sprite mx %00
; MIXFIFO - Here we go
; VRAM_OSC_SPRITES, here's where the 32x32 sprite lives

		lda #0     ; erase
		jsr :draw
		; update to new positions

]count = 0
]outcount = 0
		lup 32
		lda >MIXFIFO+5+{]count*77}+4
		clc
		adc #$100
		and #$1E0
		;lsr 	; 255
		adc #{8*32}

		; 0=255, we want 0-31
		;lsr  ;127 
		;lsr  ;63
		;lsr  ;31

		; I think a 512 entry lookup table might be faster
		; now I need this x32
		;asl
		;asl
		;asl
		;asl
		;asl
		adc #VRAM_OSC_SPRITES+]outcount+{32*32*2}
		sta |:draw+7+{]outcount*3}
]count = ]count+8
]outcount = ]outcount+1
		--^   	

		lda #1
		; drop down to draw the new positions
:draw
		phkb ^VRAM_OSC_SPRITES
		plb
		sep #$20
		lup 32
		sta |0 
		--^
		rep #$30
		plb
		rts
;------------------------------------------------------------------------------
UpdateOSC1SpriteR mx %00
; MIXFIFO - Here we go
; VRAM_OSC_SPRITES, here's where the 32x32 sprite lives

		lda #0     ; erase
		jsr :draw
		; update to new positions

]count = 0
]outcount = 0
		lup 32
		lda >MIXFIFO+38+{]count*77}+4
		clc
		adc #$100
		and #$1E0
		;lsr 	; 255

		; 0=255, we want 0-31
		;lsr  ;127 
		;lsr  ;63
		;lsr  ;31

		; I think a 512 entry lookup table might be faster
		; now I need this x32
		;asl
		;asl
		;asl
		;asl
		asl
		adc #VRAM_OSC_SPRITES+]outcount+{32*32*3}
		sta |:draw+7+{]outcount*3}
]count = ]count+8
]outcount = ]outcount+1
		--^   	

		lda #2
		; drop down to draw the new positions
:draw
		phkb ^VRAM_OSC_SPRITES
		plb
		sep #$20
		lup 32
		sta |0 
		--^
		rep #$30
		plb
		rts
;------------------------------------------------------------------------------
UpdateOSC2Sprite mx %00
; MIXFIFO - Here we go
; VRAM_OSC_SPRITES, here's where the 32x32 sprite lives

		lda #0     ; erase
		jsr :draw
		; update to new positions

]count = 0
]outcount = 0
		lup 32
		lda >MIXFIFO+5+{]count*77}+8
		clc
		adc #$100
		and #$1E0
		;lsr 	; 255
		adc #32*8 ; recenter

		; 0=255, we want 0-31
		;lsr  ;127 
		;lsr  ;63
		;lsr  ;31

		; I think a 512 entry lookup table might be faster
		; now I need this x32
		;asl
		;asl
		;asl
		;asl
		;asl
		adc #VRAM_OSC_SPRITES+]outcount+{32*32*4}
		sta |:draw+7+{]outcount*3}
]count = ]count+8
]outcount = ]outcount+1
		--^   	

		lda #1
		; drop down to draw the new positions
:draw
		phkb ^VRAM_OSC_SPRITES
		plb
		sep #$20
		lup 32
		sta |0 
		--^
		rep #$30
		plb
		rts
;------------------------------------------------------------------------------
UpdateOSC2SpriteR mx %00
; MIXFIFO - Here we go
; VRAM_OSC_SPRITES, here's where the 32x32 sprite lives

		lda #0     ; erase
		jsr :draw
		; update to new positions

]count = 0
]outcount = 0
		lup 32
		lda >MIXFIFO+38+{]count*77}+8
		clc
		adc #$100
		and #$1E0
		;lsr 	; 255

		; 0=255, we want 0-31
		;lsr  ;127 
		;lsr  ;63
		;lsr  ;31

		; I think a 512 entry lookup table might be faster
		; now I need this x32
		;asl
		;asl
		;asl
		;asl
		asl
		;adc #32*8  ; recenter
		adc #VRAM_OSC_SPRITES+]outcount+{32*32*5}
		sta |:draw+7+{]outcount*3}
]count = ]count+8
]outcount = ]outcount+1
		--^   	

		lda #2
		; drop down to draw the new positions
:draw
		phkb ^VRAM_OSC_SPRITES
		plb
		sep #$20
		lup 32
		sta |0 
		--^
		rep #$30
		plb
		rts
;------------------------------------------------------------------------------
UpdateOSC3Sprite mx %00
; MIXFIFO - Here we go
; VRAM_OSC_SPRITES, here's where the 32x32 sprite lives

		lda #0     ; erase
		jsr :draw
		; update to new positions

]count = 0
]outcount = 0
		lup 32
		lda >MIXFIFO+5+{]count*77}+12
		clc
		adc #$100
		and #$1E0
		;lsr 	; 255

		; 0=255, we want 0-31
		;lsr  ;127 
		;lsr  ;63
		;lsr  ;31

		; I think a 512 entry lookup table might be faster
		; now I need this x32
		;asl
		;asl
		;asl
		;asl
		asl
		adc #VRAM_OSC_SPRITES+]outcount+{32*32*6}
		sta |:draw+7+{]outcount*3}
]count = ]count+8
]outcount = ]outcount+1
		--^   	

		lda #1
		; drop down to draw the new positions
:draw
		phkb ^VRAM_OSC_SPRITES
		plb
		sep #$20
		lup 32
		sta |0 
		--^
		rep #$30
		plb
		rts
;------------------------------------------------------------------------------
UpdateOSC3SpriteR mx %00
; MIXFIFO - Here we go
; VRAM_OSC_SPRITES, here's where the 32x32 sprite lives

		lda #0     ; erase
		jsr :draw
		; update to new positions

]count = 0
]outcount = 0
		lup 32
		lda >MIXFIFO+38+{]count*77}+12
		clc
		adc #$100
		and #$1E0
		;lsr 	; 255

		; 0=255, we want 0-31
		;lsr  ;127 
		;lsr  ;63
		;lsr  ;31

		; I think a 512 entry lookup table might be faster
		; now I need this x32
		;asl
		;asl
		;asl
		;asl
		;asl
		adc #32*8
		adc #VRAM_OSC_SPRITES+]outcount+{32*32*7}
		sta |:draw+7+{]outcount*3}
]count = ]count+8
]outcount = ]outcount+1
		--^   	

		lda #2
		; drop down to draw the new positions
:draw
		phkb ^VRAM_OSC_SPRITES
		plb
		sep #$20
		lup 32
		sta |0 
		--^
		rep #$30
		plb
		rts
;------------------------------------------------------------------------------
fastLOCATE mx %00
	tya
	asl  ; c=0
	tay
	txa
	adc |screen_table,y
	sta <pFastPut
	lda #^CS_TEXT_MEM_PTR
	sta <pFastPut+2
	rts

screen_table
]var = CS_TEXT_MEM_PTR
	lup 75
	da ]var
]var = ]var+100
	--^
;------------------------------------------------------------------------------
fastHEXWORD mx %00
		pha
		xba
		jsr fastHEXBYTE
		pla
		; --- fall through
;------------------------------------------------------------------------------
fastHEXBYTE mx %00
		; Kernel function doesn't work

		sep #$30
		pha
		and #$F0
		lsr
		lsr
		lsr
		lsr
		tax
		pla
		and #$0F
		tay
		lda |:chars,x
		sta |:temp
		lda |:chars,y
		sta |:temp+1
		rep #$30

		lda |:temp
		fastPUTC
		inc <pFastPut
		rts

:chars  ASC '0123456789ABCDEF'

:temp	ds  3

;------------------------------------------------------------------------------
sprites_pic_init mx %00

		; source image
		pea ^sprites_pic
		pea sprites_pic

		; dest address			; Testing new smart decompress
		pea ^GRPH_LUT1_PTR
		pea GRPH_LUT1_PTR

		jsl decompress_clut

		; source picture
		pea ^sprites_pic
		pea sprites_pic

		; destination address
		pea ^VRAM_TILE_SPRITES
		pea VRAM_TILE_SPRITES

		jsl decompress_pixels

		rts

;------------------------------------------------------------------------------

speakers_pic_init mx %00

		pea ^speakers_pic
		pea speakers_pic

		pea ^GRPH_LUT3_PTR
		pea GRPH_LUT3_PTR

		jsl decompress_clut

		pea ^speakers_pic
		pea speakers_pic

		pea ^VRAM_SPEAKERS_CAT
		pea VRAM_SPEAKERS_CAT

		jsl decompress_pixels

		pea ^speakers_pic
		pea speakers_pic

		;pea ^VRAM_SPEAKERS_ANIM_MAP
		;pea VRAM_SPEAKERS_ANIM_MAP
		pea ^WORKRAM
		pea WORKRAM
		; anim map is 224(14)x2816(176) (about 10k)
		jsl decompress_map

; assign LUT3, and copy to VRAM
		ldx #{28*176*2}-2
		clc
]lp		lda >WORKRAM,x
		adc #256+{3*$800}  ; start with tile 512, and add bits for LUT3
		sta >VRAM_SPEAKERS_ANIM_MAP,x
		dex
		dex
		bpl ]lp

; let's make up a BG3, that can scroll a bit
; we need 800+32+32 x 600 + 32 + 32
;  864 x 664, or 54x42
;  why not just make it 64x64, so math is easy (8KB), 1024 pixels

		ldx #{64*64*2}-2
		lda #256+{3*$800}  ; zero tile
]lp		sta >VRAM_SPEAKERS_MAP,x
		dex
		dex
		bpl ]lp

;
; Setup Scroll Registers etc
;
		sep #$30
		lda #TILE_Enable
		sta >TL1_CONTROL_REG
		lda #^{VRAM_SPEAKERS_MAP-VRAM}
		sta >TL1_START_ADDY_H
		rep #$30
		lda #{VRAM_SPEAKERS_MAP-VRAM}
		sta >TL1_START_ADDY_L

		lda #16
		sta >TL1_WINDOW_X_POS_L
		sta >TL1_WINDOW_Y_POS_L

		lda #64
		sta >TL1_TOTAL_X_SIZE_L
		sta >TL1_TOTAL_Y_SIZE_L

		rts


;------------------------------------------------------------------------------
dancer_sprites_init mx %00

		pea ^dancer_sprites
		pea dancer_sprites

		pea ^GRPH_LUT5_PTR
		pea GRPH_LUT5_PTR

		jsl decompress_clut

		pea ^dancer_sprites
		pea dancer_sprites

		pea ^VRAM_DANCER_SPRITES
		pea VRAM_DANCER_SPRITES

		jsl decompress_pixels

		pea ^dancer_sprites
		pea dancer_sprites

		pea ^dancer_map
		pea dancer_map

		jsl decompress_map

		rts 

;------------------------------------------------------------------------------
background_pic_init mx %00

; This is going to replace the logo pic, re-use TL3, maybe I'll
; sort a way to toggle between this, and the original logo

		lda #background_pic
		ldx #^background_pic
		jsr c256Init		;$$JGA TODO, make sure better

		; Tile Map Width, and Height

		ldy #8  ; TMAP width offset
		lda [pTMAP],y
		sta >TL3_TOTAL_X_SIZE_L
		iny
		iny     ; TMAP height offset
		lda [pTMAP],y
		inc
		and #$FFFE
		sta >TL3_TOTAL_Y_SIZE_L

;
; Extract CLUT data 
;

		; source image
		pea ^background_pic
		pea background_pic

		; dest address			; Testing new smart decompress
		pea ^GRPH_LUT4_PTR
		pea GRPH_LUT4_PTR

		jsl decompress_clut

		; source image
		pea ^background_pic
		pea background_pic

		; dest address			; Testing new smart decompress
		pea ^WORKRAM
		pea WORKRAM

		jsl decompress_clut

	; background color
		lda >WORKRAM
		sta >BACKGROUND_COLOR_B
		sep #$30
		lda >WORKRAM+2
		sta >BACKGROUND_COLOR_R
		rep #$30


;
; Extract Tiles Data
;

		; source picture
		pea ^background_pic
		pea background_pic

		; destination address
		pea ^VRAM_BACKGROUND_CAT
		pea VRAM_BACKGROUND_CAT

		jsl decompress_pixels

;
; Extract Map Data
;

		; source picture
		pea ^background_pic
		pea background_pic

		; destination address
		;pea ^VRAM_PUMPBAR_MAP
		;pea VRAM_PUMPBAR_MAP
		pea ^WORKRAM
		pea WORKRAM

		jsl decompress_map

; 100x75 is the size of this thng
; massage the map data, and store in VRAM

		ldx #{52*40*2}-2
		clc
]lp		lda >WORKRAM,x
		adc #1024+{4*$800}  ; add 256 to start a tile 256, and add bits to enable LUT2
		sta >VRAM_BACKGROUND_MAP,x
		dex
		dex
		bpl ]lp

		; turn on tile map 3
		lda #TILE_Enable
		sta >TL3_CONTROL_REG
		lda #{VRAM_BACKGROUND_MAP-VRAM}
		sta >TL3_START_ADDY_L
		sep #$30
		lda #^{VRAM_BACKGROUND_MAP-VRAM}
		sta >TL3_START_ADDY_H
		rep #$30

		lda #0
		sta >TL3_WINDOW_X_POS_L
		lda #16
		sta >TL3_WINDOW_Y_POS_L

; catalog data inherited
		rts
;------------------------------------------------------------------------------

logo_pic_init mx %00

;
; Configure the Width and Height of the Tilemap, based on the width
; and height stored in our file
;

		lda #logo_pic
		ldx #^logo_pic
		jsr c256Init		;$$JGA TODO, make sure better

		; Tile Map Width, and Height

		ldy #8  ; TMAP width offset
		lda [pTMAP],y
		sta >TL3_TOTAL_X_SIZE_L
		iny
		iny     ; TMAP height offset
		lda [pTMAP],y
		inc
		and #$FFFE
		sta >TL3_TOTAL_Y_SIZE_L

;
; Extract CLUT data from the piano image
;

		; source image
		pea ^logo_pic
		pea logo_pic

		; dest address			; Testing new smart decompress
		pea ^GRPH_LUT0_PTR
		pea GRPH_LUT0_PTR

		jsl decompress_clut

;
; Extract Tiles Data
;

		; source picture
		pea ^logo_pic
		pea logo_pic

		; destination address
		pea ^VRAM_TILE_CAT
		pea VRAM_TILE_CAT

		jsl decompress_pixels

;
; Extract Map Data
;

		; source picture
		pea ^logo_pic
		pea logo_pic

		; destination address
		pea ^VRAM_LOGO_MAP
		pea VRAM_LOGO_MAP

		jsl decompress_map

;
; Set Scroll Registers, and enable TL3
;

		lda #0
		; Tile maps off
		sta >TL0_CONTROL_REG
		sta >TL1_CONTROL_REG
		sta >TL2_CONTROL_REG
		sta >TL3_CONTROL_REG
		
		; turn on tile map 3
		lda #TILE_Enable
		sta >TL3_CONTROL_REG
		lda #{VRAM_LOGO_MAP-VRAM}
		sta >TL3_START_ADDY_L
		sep #$30
		lda #^{VRAM_LOGO_MAP-VRAM}
		sta >TL3_START_ADDY_H
		rep #$30
		
		lda #0
		sta >TL0_WINDOW_X_POS_L
		sta >TL0_WINDOW_Y_POS_L
		sta >TL1_WINDOW_X_POS_L
		sta >TL1_WINDOW_Y_POS_L
		sta >TL2_WINDOW_X_POS_L
		sta >TL2_WINDOW_Y_POS_L

		sta >TL3_WINDOW_X_POS_L
		lda #24
		sta >TL3_WINDOW_Y_POS_L

		; catalog data
		lda #{VRAM_TILE_CAT-VRAM}
		sta >TILESET0_ADDY_L
		sta >TILESET1_ADDY_L
		sta >TILESET2_ADDY_L
		sta >TILESET3_ADDY_L
		sta >TILESET4_ADDY_L
		sta >TILESET5_ADDY_L
		sta >TILESET6_ADDY_L
		sta >TILESET7_ADDY_L
		lda #^{VRAM_TILE_CAT-VRAM}
		sta >TILESET0_ADDY_H
		inc
		sta >TILESET1_ADDY_H	    ; by placing the next tileset after the first, we expand support to 512 tiles
		inc
		sta >TILESET2_ADDY_H
		inc
		sta >TILESET3_ADDY_H
		inc
		sta >TILESET4_ADDY_H
		inc
		sta >TILESET5_ADDY_H
		inc
		sta >TILESET6_ADDY_H
		inc
		sta >TILESET7_ADDY_H


		rts

;------------------------------------------------------------------------------

pumpbars_pic_init mx %00

;
; Configure the Width and Height of the Tilemap, based on the width
; and height stored in our file
;

		lda #pumpbars_pic
		ldx #^pumpbars_pic
		jsr c256Init		;$$JGA TODO, make sure better

		; Tile Map Width, and Height

		ldy #8  ; TMAP width offset
		lda [pTMAP],y
		sta >TL2_TOTAL_X_SIZE_L
		iny
		iny     ; TMAP height offset
		lda [pTMAP],y
		inc
		and #$FFFE
		sta >TL2_TOTAL_Y_SIZE_L

;
; Extract CLUT data from the piano image
;

		; source image
		pea ^pumpbars_pic
		pea pumpbars_pic

		; dest address			; Testing new smart decompress
		pea ^GRPH_LUT2_PTR
		pea GRPH_LUT2_PTR

		jsl decompress_clut

;
; Extract Tiles Data
;

		; source picture
		pea ^pumpbars_pic
		pea pumpbars_pic

		; destination address
		pea ^VRAM_PUMPBAR_CAT
		pea VRAM_PUMPBAR_CAT

		jsl decompress_pixels

;
; Extract Map Data
;

		; source picture
		pea ^pumpbars_pic
		pea pumpbars_pic

		; destination address
		;pea ^VRAM_PUMPBAR_MAP
		;pea VRAM_PUMPBAR_MAP
		pea ^WORKRAM
		pea WORKRAM

		jsl decompress_map

; 100x75 is the size of this thng
; massage the map data, and store in VRAM

		ldx #{100*75*2}-2
		clc
]lp		lda >WORKRAM,x
		adc #128+{2*$800}  ; add 256 to start a tile 256, and add bits to enable LUT2
		sta >VRAM_PUMPBAR_MAP,x
		dex
		dex
		bpl ]lp
;
; Set Scroll Registers, and enable TL2
;

		; turn on tile map 2
		sep #$30
		lda #TILE_Enable
		sta >TL2_CONTROL_REG

		lda #^{VRAM_PUMPBAR_MAP-VRAM}
		sta >TL2_START_ADDY_H
		rep #$30
		lda #{VRAM_PUMPBAR_MAP-VRAM}
		sta >TL2_START_ADDY_L
		
		;lda #256
		lda #408-PUMPBARS_X
		sta >TL2_WINDOW_X_POS_L
		;lda #16
		lda #535-PUMPBARS_Y
		sta >TL2_WINDOW_Y_POS_L

		; catalog data
		;lda #{VRAM_PUMPBAR_CAT-VRAM}
		;sta >TILESET1_ADDY_L
		;lda #^{VRAM_PUMPBAR_CAT-VRAM}
		;sta >TILESET1_ADDY_H
		rts


;------------------------------------------------------------------------------
ReadKeyboard mx %00
		phd
		pea 0
		pld

HISTORY_SIZE = 15

	; Collect Scancodes, but only when they change
	; place into a history buffer
	; print out the history buffer onto the screen
	; for the world to see
]key_loop
		jsl GETSCANCODE
		and #$FF
		beq :exit
		cmp |:last_code
		beq :exit       	; duplicate code, so ignore

		sta |:last_code		; last code, for the duplicate check

	; this is he actual keyboard driver, just reflects keystatus
	; into the keyboard array

		sep #$30
		tay
		and #$7F
		tax
		tya
		bpl :keydown
		lda #$00  		; key-up
:keydown
		sta |keyboard,x
		
		tya
		rep #$30

	; end keyboard driver

	; I keep history here, for debugging
		do 1
		ldx |:index     	; current index
		sta |:history,x 	; save in history
		dex
		dex     		; next index
		bpl :continue
		ldx #{HISTORY_SIZE*2}-2 ; index wrap
:continue
		stx |:index     	; save index for next time
		fin

		bra ]key_loop

:exit
		pld

; print out the current history
		do 1
:x = temp0
:y = temp0+2

		ldx #97
		ldy #2
		stx <:x
		sty <:y

		ldy |:index
]loop
		phy
		ldx <:x
		ldy <:y
		jsr fastLOCATE

		ply
		iny
		iny
		cpy #HISTORY_SIZE*2
		bcc :cont2
		ldy #0
:cont2
		cpy |:index
		beq :xit

		lda |:history,y
		phy
		jsr fastHEXBYTE
		ply
		inc <:y

		bra ]loop
:xit

		fin
		rts


:index		dw 0
:last_code	dw 0

:history	ds HISTORY_SIZE*2

;------------------------------------------------------------------------------
inst_address_table
]index = 0
		lup 32
		da mod_instruments+{]index*sizeof_inst}
]index = ]index+1
		--^
;------------------------------------------------------------------------------

pump_full_colors
		adrl $FF18FF18    		; Green
		adrl $FF18FF18
		adrl $FF18FF18
		adrl $FF18FF18

		adrl $FF18FF18
		adrl $FF18FF18
		adrl $FF18FF18
		adrl $FF18FF18

		adrl $FF18FF18
		adrl $FF18FF18
		adrl $FF18FF18
		adrl $FFFF1818			; Red

		adrl $FFFF1818
		adrl $FFFF1818
		adrl $FFFF1818
		adrl $FFFF1818

pump_empty_colors
		adrl $FF202020			; grey
		adrl $FF202020
		adrl $FF202020
		adrl $FF202020

		adrl $FF202020
		adrl $FF202020
		adrl $FF202020
		adrl $FF202020

		adrl $FF202020
		adrl $FF202020
		adrl $FF202020
		adrl $FF202020

		adrl $FF202020
		adrl $FF202020
		adrl $FF202020
		adrl $FF202020


;------------------------------------------------------------------------------

; Non Initialized spaced

	dum *+$2100  ; pirate! (this is cheating, these addresses are not relocatable)
	             ; so org of this file has to be $2100, and if anyone trys to
				 ; move the location, this will break
uninitialized_start ds 0
;------------------------------------------------------------------------------
;
; Clut Buffer
;
pal_buffer
		ds 1024

	        ds \             ; 256 byte align, for quicker piano update
mixer_dpage ds 256		  	 ; mixer gets it's own DP

keyboard   ds 128
latch_keys ds 128			 ; hybrid latch memory

mod_instruments ds sizeof_inst*32  ; Really a normal mod only has 31 of them

;
; Precomputed pointers to patterns
;
mod_patterns
	ds 128*4

scratch_ram ds 1024

mod_last_sample ds 4*8 ; up to 8 channels
mod_channel_pan ds 4*8 ; up to 8 channels
mod_pump_vol    ds 4*8 ; up to 8 channels, pump bar data

		ds 256

pump_bar_levels ds 2*8 	   ; for current rendering
pump_bar_peaks  ds 2*8 	   ; peaks hang on for 1 second
pump_bar_peak_timer ds 2*8 ; peak gets cleared to 0, when timer hits 0

speaker_tick  ds 2
speaker_frame ds 2

dancer_map ds 2*4*216 ; 1728 bytes

uninitialized_end ds 0
	dend

