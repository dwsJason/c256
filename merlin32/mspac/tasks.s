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
task_drawText
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
