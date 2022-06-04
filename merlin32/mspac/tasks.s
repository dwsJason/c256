;
; Ms Pacman Tasks
;

; 23A8
task_table
		da task_clearScreen    ; #23ED ; A=00   ; clears the whole screen if parameter == 0, just the maze if parameter == 1
		da task_colorMaze      ; #24D7 ; A=01	; colors the maze depending on parameter. if parameter == 2, then color maze white
		da task_drawMaze 	   ; #2419 ; A=02	; draws the maze
		da task_drawPellets	   ; #2448 ; A=03	; draws the pellets
		da task_resetMemory    ; #253D ; A=04	; resets a bunch of memories based on parameter 0 or 1
		da task_resetGhostHome ; #268B ; A=05	; resets ghost home counter and if parameter = 1, sets red ghost to chase pac man
		da task_clearColor	   ; #240D ; A=06	; clears the color RAM
		da task_setDemoMode    ; #2698 ; A=07	; set game to demo mode
		da task_redGhostAI 	   ; #2730 ; A=08	; red ghost AI
		da task_pinkGhostAI    ; #276C ; A=09	; pink ghost AI
		da task_blueGhostAI    ; #27A9 ; A=0A	; blue ghost (inky) AI	
		da task_orangeGhostAI  ; #27F1 ; A=0B	; orange ghost AI	
		da task_redGhostRun    ; #283B ; A=0C	; red ghost movement when power pill active
		da task_pinkGhostRun   ; #2865 ; A=0D	; pink ghost movement when power pill active
		da task_blueGhostRun   ; #288F ; A=0E	; blue ghost (inky) movement when power pill active
		da task_orangeGhostRun ; #28B9 ; A=0F	; orange ghost movement when power pill active
		da task_setDifficulty  ; #000D ; A=10	; sets up difficulty
		da task_clearMemory4D  ; #26A2 ; A=11	; clears memories from #4D00 through #4DFF
		da task_setPills 	   ; #24C9 ; A=12	; sets up coded pills and power pills memories
		da task_clearSprites   ; #2A35 ; A=13	; clears the sprites
		da task_copyDips 	   ; #26D0 ; A=14	; checks all dip switches and assigns memories to the settings indicated
		da task_updatePills    ; #2487 ; A=15	; update the current screen pill config to video ram
		da task_incMain        ; #23E8 ; A=16	; increase main subroutine number (#4E04)
		da task_pacmanAI 	   ; #28E3 ; A=17	; controls pac-man AI during demo.  pacman will avoid pink ghost, or chase it when red ghost is edible
		da task_resetScores    ; #2AE0 ; A=18	; draws "high score" and scores.  clears player 1 and 2 scores to zero.
		da task_updateScore    ; #2A5A ; A=19	; update score.  B has code for items scored, draw score on screen, check for high score and extra lives
		da task_drawLives      ; #2B6A ; A=1A	; draws remaining lives at bottom of screen
		da task_drawFruit      ; #2BEA ; A=1B	; draws fruit at bottom right of screen

; OTTOPATCH
;MISCELLANEOUS HACKS THAT OCCUR WHEN PROMPTS ARE WRITTEN.
;!    ORG 23E0H
;!    WORD PROMPTHACKS
		da task_drawText       ; #95E3	; A=1C	; used to draw text and some other functions  ; parameter lookup for text found at #36a5
		da task_drawCredits    ; #2BA1	; A=1D	; write # of credits on screen
		da task_clearActors    ; #2675	; A=1E	; clear fruit, pacman, and all ghosts
		da task_drawExtraLife  ; #26B2	; A=1F	; writes points needed for extra life digits to screen

;------------------------------------------------------------------------------
; task #00, called from #23A7
; 
; #23ED	; A=00	; clears the whole screen if parameter == 0
;               ; just the maze if parameter == 1
task_clearScreen mx %00
		asl
		tax
		jmp (|:switch,x)

:switch	da :ClearScreen		; #23F3   ; Clears entire screen
		da :ClearMaze		; #2400   ; Clears the maze

; clears the entire screen
; 23F3
:ClearScreen mx %00
		lda #$4040			; $40 is clear character
		ldx #1022
]lp
		sta |tile_ram,x 	; Clear the video RAM
		dex
		dex
		bpl ]lp

		rts

; clears the maze only
; 2400
:ClearMaze mx %00
		lda #$4040		  ; Clear Character
		ldx #510
]lp
		sta |tile_ram+64,x
		dex
		dex
		bpl ]lp

		rts

;------------------------------------------------------------------------------
; #2419 ; A=02   ; draws the maze 
task_drawMaze mx %00
		jmp DrawMaze

;------------------------------------------------------------------------------
; #2448 ; A=03   ; draws the pellets 
task_drawPellets mx %00
		jmp DrawPills

;------------------------------------------------------------------------------
; #253D ; A=04   ; resets a bunch of memories based on parameter 0 or 1 
task_resetMemory
		rts
;------------------------------------------------------------------------------
; resets ghost home counter and if parameter = 1, sets red ghost to chase pac man 
task_resetGhostHome
		rts
;------------------------------------------------------------------------------
; #240D ; A=06   ; clears the color RAM 
task_clearColor
		rts
;------------------------------------------------------------------------------
; sets demo mode
; #2698 ; A=07   ; set game to demo mode 
task_setDemoMode mx %00
		lda #MS_DEMO
		sta |mainstate
		stz |mainroutine2
		rts
;------------------------------------------------------------------------------
; red ghost logic: (not edible)
; #2730 ; A=08   ; red ghost AI 
task_redGhostAI
		rts
;------------------------------------------------------------------------------
; #276C ; A=09   ; pink ghost AI task_pinkGhostAI
task_pinkGhostAI
		rts
;------------------------------------------------------------------------------
; #27A9 ; A=0A   ; blue ghost (inky) AI   task_orangeGhostAI
task_blueGhostAI
		rts
;------------------------------------------------------------------------------
; #27F1 ; A=0B  ; orange ghost AI    
task_orangeGhostAI
		rts
;------------------------------------------------------------------------------
; #283B ; A=0C   ; red ghost movement when power pill active 
task_redGhostRun
		rts
;------------------------------------------------------------------------------
; #2865 ; A=0D	; pink ghost movement when power pill active
task_pinkGhostRun
		rts
;------------------------------------------------------------------------------
; #288F ; A=0E	; blue ghost (inky) movement when power pill active
task_blueGhostRun
		rts
;------------------------------------------------------------------------------
; #28B9 ; A=0F	; orange ghost movement when power pill active
task_orangeGhostRun
		rts
;------------------------------------------------------------------------------
; #000D ; A=10	; sets up difficulty
task_setDifficulty
		rts
;------------------------------------------------------------------------------
; #26A2 ; A=11	; clears memories from #4D00 through #4DFF
task_clearMemory4D
		rts
;------------------------------------------------------------------------------
; #24C9 ; A=12	; sets up coded pills and power pills memories
task_setPills
		rts
;------------------------------------------------------------------------------
; #2A35 ; A=13	; clears the sprites
task_clearSprites
		rts
;------------------------------------------------------------------------------
; #26D0 ; A=14	; checks all dip switches and assigns memories to the settings indicated
task_copyDips
		rts
;------------------------------------------------------------------------------
; #2487 ; A=15	; update the current screen pill config to video ram
task_updatePills
		rts
;------------------------------------------------------------------------------
; #23E8 ; A=16	; increase main subroutine number (#4E04)
task_incMain
		rts
;------------------------------------------------------------------------------
; #28E3 ; A=17	; controls pac-man AI during demo. 
; pacman will avoid pink ghost, or chase it when red ghost is edible
;
; called from #23A7 for task #17
; arrive here only during demo mode ?
; conrtrols pacman AI during demo mode
; pac-man will avoid the pink ghost normally, except after eating a power pill
; pac-man will chase the pink ghost when the red ghost is blue, even if the pink ghost is not
;
task_pacmanAI mx %00

		lda |redghost_blue
		beq	:not_blue

		; red ghost is blue

		ldx |pacman_demo_tile_y			;4d12;  X contains both tilepos x and tilepos y
		ldy |pinkghost_tile_y 			;4d0c;  Y contains both tilepos x and tilepos y
		lda |wanted_pacman_orientation  ;4d3c; load A with wanted pacman orientation 
:cont
		jsr getBestNewDirection  		;2966; get best new direction 
		sta |wanted_pacman_orientation  ;4d3c; store into wanted pacman orientation 
		stx |wanted_pacman_tile_y       ;4d26; store into wanted pacman tile changes 
		rts 

; pacman will run away from pink ghost

:not_blue

:temp_pacman_y equ temp0
:temp_pacman_x equ temp0+1
:temp_pink_y   equ temp1
:temp_pink_x   equ temp1+1
:result_y      equ temp2
:result_x      equ temp2+1

		; put pink ghost xy, into temp variables
		lda |pinkghost_tile_y
		sta <:temp_pink_y

		; put pacman xy, into temp variables
		lda |pacman_tile_pos_y
		sta <:temp_pacman_y

		asl ; x2  - pacman_y times 2

		sep #$21		; short a, c=1

		sbc <:temp_pink_y
		sta <:result_y

		lda <:temp_pacman_x
		asl  ; x2 - paman_x times 2
		sec
		sbc <:temp_pink_x
		sta <:result_x

		rep #$31 ; long ai, c=0
		ldy <:result_y
		bra :cont

;------------------------------------------------------------------------------
; #2AE0 ; A=18	; draws "high score" and scores.  clears player 1 and 2 scores to zero.
task_resetScores
		rts
;------------------------------------------------------------------------------
; #2A5A ; A=19	; update score.  B has code for items scored, draw score on screen, check for high score and extra lives
task_updateScore
		rts
;------------------------------------------------------------------------------
; #2B6A ; A=1A	; draws remaining lives at bottom of screen
task_drawLives
		rts
;------------------------------------------------------------------------------
; #2BEA ; A=1B	; draws fruit at bottom right of screen
task_drawFruit
		rts
;------------------------------------------------------------------------------

; #95E3	; A=1C	; used to draw text and some other functions  ; parameter lookup for text found at #36a5
; A=Argument, string number
task_drawText mx %00
;95E3: 78	ld	a,b		; load A with parameter
;95E4: FE 0A	cp	#0A		; == #0A ?
		tay
		cpy #$0A
		bne :next1
;95e6  cc0b96    call    z,#960b		; Yes, draw the MS PAC MAN graphic which appears between "ADDITIONAL" and "AT 10,000 pts"
		jsr :table_subroutine
:next1
;95e9  fe0b      cp      #0b		; == #0B ?
		cpy #$0B
		bne :next2
;95eb  ccf695    call    z,#95f6		; yes, draw midway logo and copyright text
		jsr :midway_logo
;95ee  fe06      cp      #06		; == #06 ?   ( code for "READY!" )
		cpy #$06
		bne :next3
;95f0  cc3c96    call    z,#963c		; yes, clear the intermission indicator
		jsr clear_intermission
:next3
;95f3  c35e2c    jp      #2c5e		; jump to print routine
		jmp DrawText

:midway_logo	
;95f6  c5        push    bc		; save BC
;95f7  e5        push    hl		; save HL
;95f8  cd4296    call    #9642		; draw the midway logo and copyright text for the 'press start' screen
		jsr	draw_logo_text 
;95fb  e1        pop     hl		; restore HL
;95fc  c1        pop     bc		; resore BC

	; check for dip switch settings if there are extra lives awarded

;95fd  3a8050    ld      a,(#5080)	; load A with Dip switches
		lda |DSW1
;9600  e630      and     #30		; mask bits
		and #$30
;9602  fe30      cp      #30		; are bits 4 and 5 on ?   This happens when there is no bonus life awarded.
		cmp #$30
;9604  78        ld      a,b		; A := B
		tya
		bne :rts
;9605  c0        ret     nz		; no, return

;9606  3e20      ld      a,#20		; yes, A := #20
		lda #$20
;9608  0620      ld      b,#20		; B := #20
		tay
;960a  c9        ret     		; return (to #95EE)
:rts
		rts

	; table subroutine
:table_subroutine

;960b  c5        push    bc		; save BC
;960c  e5        push    hl		; save HL
;960d  211696    ld      hl,#9616	; load HL with start of table data
		ldx #:mspac_gr_table
;9610  cd2796    call    #9627		; draws the MS PAC MAN graphic which appears between "ADDITIONAL" and "AT 10,000 pts" 
;9613  e1        pop     hl		; restore HL
;9614  c1        pop     bc		; restore BC
;9615  c9        ret     		; return
		rts

	; table data, used in sub below to draw MS PAC graphic
	; first byte is color, 2nd byte is graphic code, third & fourth are screen locations
:mspac_gr_table

9616  09 20 f5 41 			; screen location #41F5
961a  09 21 15 42			; screen location #4215
961e  09 22 f6 41 			; screen location #41F6
9622  09 23 16 42 			; screen location #4216
9626  ff

	; subroutine for start button press
	; called from #9610
	; draws the MS PAC MAN which appears between "ADDITIONAL" and "AT 10,000 pts"
draw_table mx %00

9627  7e        ld      a,(hl)		; load A with table data
9628  feff      cp      #ff		; are we done?
962a  280f      jr      z,#963b         ; yes, return
962c  47        ld      b,a		; else load B with this first data byte
962d  23        inc     hl		; next table entry
962e  7e        ld      a,(hl)		; load A with next data
962f  23        inc     hl		; next table entry
9630  5e        ld      e,(hl)		; load E with next data
9631  23        inc     hl		; next table entry
9632  56        ld      d,(hl)		; load D with next data
9633  12        ld      (de),a		; Draws element to screen
9634  78        ld      a,b		; load A with B
9635  cbd2      set     2,d		; set bit 2 of D.  changes DE to color grid
9637  12        ld      (de),a		; store A into color grid
9638  23        inc     hl		; next table entry
9639  18ec      jr      #9627           ; loop again
963b  c9        ret     		; return

	; called from #95F0.  clears intermission indicator
clear_intermission mx %00
;963c  3e00      ld      a,#00		; A := #00
;963e  32004f    ld      (#4f00),a	; clear the intermission indicator
		stz |is_intermission

;9641  c9        ret     		; return
		rts

;------------------------------------------------------------------------------
; #2BA1	; A=1D	; write # of credits on screen
task_drawCredits
		rts
;------------------------------------------------------------------------------
; #2675	; A=1E	; clear fruit, pacman, and all ghosts
task_clearActors mx %00
		stz |fruit_y
		stz |pacman_y

clear_ghosts
		stz |red_ghost_y
		stz |pink_ghost_y
		stz |blue_ghost_y
		stz |orange_ghost_y
		rts
;------------------------------------------------------------------------------
; #26B2	; A=1F	; writes points needed for extra life digits to screen
task_drawExtraLife
		rts
;------------------------------------------------------------------------------
; distance check - used for ghost logic and for pacman logic in the demo
;
; this subroutine determines the best direction to take based upon the input.
; Y (DE) is preloaded with the destination tile
; X (HL) is preloaded with the current position tile
; A is preloaded with the current direction of the ghost
;
; the output is the best new direction which is stored into A
; and the best new tile changes stored into HL (X)
; 2966
getBestNewDirection mx %00
		stx |save_current_tile
		sty |save_dest_tile
		sta |best_orientation

		eor #$0002		; flip bit 1 of the direction
		sta |opposite_orientation  ; this will never be allowed

		lda #$FFFF
		sta |min_distance2	; min distance^2 found

		ldx #tile_move_table
		ldy #save_current_tile

		stz	|current_try_orientation
:try_again
		lda |opposite_orientation
		cmp |current_try_orientation
		beq :try_next

		phx
		phy

		ldx #save_dest_tile
		ldy #temp_position
;29ab
		jsr sum_dist_squared  ; 29ea

		ply
		plx

		cmp |min_distance2
		bcs	:try_next

		sta |min_distance2

		lda |current_try_orientation
		sta |best_orientation

;29c6
:try_next
		inx
		inx		; next direction tile difference

		inc |current_try_orientation

		lda #4
		cmp |current_try_orientation
		bne :try_again

		lda |best_orientation  ; load A with best direction
		asl					   ; a*2
		tay
		lda |tile_move_table,y
		tax					   ; return move direction in X
		tya
		lsr					   ; orientation in A
		rts

;------------------------------------------------------------------------------
; sub called for orange ghost logic and during distance check
; loads HL with the sum of the square of the X and Y distances between pac and ghost
; 29ea
; sum dist squared
sum_dist_squared mx %00
		lda #0			; clear B
		sep #$21		; short a, c=1
		lda |0,x		; pac y
		sbc |0,y		; minus ghost y
		bcc :result_is_good

		eor #$FF
		inc

:result_is_good
		rep #$30
		jsr squareA
		pha				; save result for later, since we're summing
		lda #0			; clear B
		sep #$21		; short a, c=1
		lda |1,x		; pac x
		sbc |1,y 		; minus ghost x
		bcc :good

		eor #$FF  		; negate
		inc
:good
		rep #$31		; long ai c=0
		jsr squareA

		adc 1,s
		sta 1,s
		pla

		rts

;------------------------------------------------------------------------------
; Take number in A, and return value Squared
; 29F9
squareA mx %00
		sta <UNSIGNED_MULT_A_LO
		sta <UNSIGNED_MULT_B_LO
		lda <UNSIGNED_MULT_AL_LO
		rts

;------------------------------------------------------------------------------
; arrive here from #1780 when a ghost is eaten. 
; B contains the # of ghosts eaten +1 (2-5)
;
; or arrive from #23A7 for a task
; B is loaded with code of scoring item
;2a5a
update_score mx %00
		lda |mainstate
		cmp #1			; is this the intro mode ?
		bne :continue
		; in intro, so skip
		rts

:continue

; if we probably don't need this yet

		rts

;------------------------------------------------------------------------------
; data - tile differences tables for movements
; 32ff
tile_move_table
move_right
		db 0,-1			; move right
move_down
		db 1,0			; move down
move_left
		db 0,1			; move left
move_up
		db -1,0			; move up

; second copy for speed, or for overflow when blue ghosts random directions aren't allowed
; 3307

		db 0,-1			; move right
		db 1,0			; move down
		db 0,1			; move left
		db -1,0			; move up

;------------------------------------------------------------------------------
