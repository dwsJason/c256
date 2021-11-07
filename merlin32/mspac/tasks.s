;
; Ms Pacman Tasks
;

; 23A8
task_table
		da task_clearScreen    ; #23ED ; A=00  ; clears the whole screen if parameter == 0, just the maze if parameter == 1
		da task_colorMaze      ; #24D7 ; A=01	; colors the maze depending on parameter. if parameter == 2, then color maze white
		da task_drawMaze 	   ; #2419 ; A=02	; draws the maze
		da task_drawPellets	   ; #2448 ; A=03	; draws the pellets
		da task_resetMemory    ; #253D ; A=04	; resets a bunch of memories based on parameter 0 or 1
		da task_resetGhostHome ; #268B	; A=05	; resets ghost home counter and if parameter = 1, sets red ghost to chase pac man
		da task_clearColor	   ; #240D	; A=06	; clears the color RAM
		da task_setDemoMode    ; #2698	; A=07	; set game to demo mode
		da task_redGhostAI 	   ; #2730	; A=08	; red ghost AI
		da task_pinkGhostAI    ; #276C	; A=09	; pink ghost AI
		da task_blueGhostAI    ; #27A9	; A=0A	; blue ghost (inky) AI	
		da task_orangeGhostAI  ; #27F1	; A=0B	; orange ghost AI	
		da task_redGhostRun    ; #283B	; A=0C	; red ghost movement when power pill active
		da task_pinkGhostRun   ; #2865	; A=0D	; pink ghost movement when power pill active
		da task_blueGhostRun   ; #288F	; A=0E	; blue ghost (inky) movement when power pill active
		da task_orangeGhostRun ; #28B9	; A=0F	; orange ghost movement when power pill active
		da task_setDifficulty  ; #000D	; A=10	; sets up difficulty
		da task_clearMemory4D  ; #26A2	; A=11	; clears memories from #4D00 through #4DFF
		da task_setPills 	   ; #24C9	; A=12	; sets up coded pills and power pills memories
		da task_clearSprites   ; #2A35	; A=13	; clears the sprites
		da task_copyDips 	   ; #26D0	; A=14	; checks all dip switches and assigns memories to the settings indicated
		da task_updatePills    ; #2487	; A=15	; update the current screen pill config to video ram
		da task_incMain        ; #23E8	; A=16	; increase main subroutine number (#4E04)
		da task_pacmanAI 	   ; #28E3	; A=17	; controls pac-man AI during demo.  pacman will avoid pink ghost, or chase it when red ghost is edible
		da task_resetScores    ; #2AE0	; A=18	; draws "high score" and scores.  clears player 1 and 2 scores to zero.
		da task_updateScore    ; #2A5A	; A=19	; update score.  B has code for items scored, draw score on screen, check for high score and extra lives
		da task_drawLives      ; #2B6A	; A=1A	; draws remaining lives at bottom of screen
		da task_drawFruit      ; #2BEA	; A=1B	; draws fruit at bottom right of screen

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

task_drawMaze
task_drawPellets
task_resetMemory
task_resetGhostHome
task_clearColor
task_setDemoMode
task_redGhostAI
task_pinkGhostAI
task_blueGhostAI
task_orangeGhostAI
task_redGhostRun
task_pinkGhostRun
task_blueGhostRun
task_orangeGhostRun
task_setDifficulty
task_clearMemory4D
task_setPills
task_clearSprites
task_copyDips
task_updatePills
task_incMain
task_pacmanAI
task_resetScores
task_updateScore
task_drawLives
task_drawFruit
task_drawText
task_drawCredits
task_clearActors
task_drawExtraLife
		rts