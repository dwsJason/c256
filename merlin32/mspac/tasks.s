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
; called from #23A7 for task #04
; resets a bunch of memories to predefined values
; #253D ; A=04   ; resets a bunch of memories based on parameter 0 or 1 
task_resetMemory mx %00
	; A=Argument
;253d  dd21004c  ld      ix,#4c00
;2541  dd360220  ld      (ix+#02),#20	; set red ghost sprite
		ldx #$20
		stx |redghostsprite
;2545  dd360420  ld      (ix+#04),#20	; set pink ghost sprite
		stx |pinkghostsprite
;2549  dd360620  ld      (ix+#06),#20	; set inky sprite
		stx |blueghostsprite
;254d  dd360820  ld      (ix+#08),#20	; set orange ghost sprite
		stx |orangeghostsprite
;2551  dd360a2c  ld      (ix+#0a),#2c	; set ms pac sprite
		;ldx #$2c
		;ldx #$80+$2F
		ldx #$35
		stx |pacmansprite
;2555  dd360c3f  ld      (ix+#0c),#3f	; set fruit sprite
		ldx #$3f
		stx |fruitsprite
;2559  dd360301  ld      (ix+#03),#01	; set red ghost color
		ldx #$01
		stx |redghostcolor
;255d  dd360503  ld      (ix+#05),#03	; set pink ghost color
		ldx #$03
		stx |pinkghostcolor
;2561  dd360705  ld      (ix+#07),#05	; set inky color
		ldx #$05
		stx |blueghostcolor
;2565  dd360907  ld      (ix+#09),#07	; set orange ghost color
		ldx #$07
		stx |orangeghostcolor
;2569  dd360b09  ld      (ix+#0b),#09	; set ms pac color
		ldx #$09
		stx |pacmancolor
;256d  dd360d00  ld      (ix+#0d),#00	; set fruit color
		stz |fruitspritecolor

;2571  78        ld      a,b		; load task parameter
;2572  a7        and     a		; == #00 ?
		tax
;2573  c20f26    jp      nz,#260f	; no, skip ahead
		beq :position_reset
		rts

:position_reset
		; Put everyone in their start positions
		; why isn't this a table?

;2576  216480    ld      hl,#8064
;2579  22004d    ld      (#4d00),hl	; set red ghost position
		lda #$8064
		sta |red_ghost_y

;257c  217c80    ld      hl,#807c
;257f  22024d    ld      (#4d02),hl	; set pink ghost position
		lda #$807C
		sta |pink_ghost_y

;2582  217c90    ld      hl,#907c
;2585  22044d    ld      (#4d04),hl	; set inky position
		lda #$907c
		sta |blue_ghost_y

;2588  217c70    ld      hl,#707c
;258b  22064d    ld      (#4d06),hl	; set orange ghost position
		lda #$707c
		sta |orange_ghost_y

;258e  21c480    ld      hl,#80c4
;2591  22084d    ld      (#4d08),hl	; set ms pac position
		lda #$80c4
		sta |pacman_y

;2594  212c2e    ld      hl,#2e2c
;2597  220a4d    ld      (#4d0a),hl	; set red ghost tile position
;259a  22314d    ld      (#4d31),hl	; set red ghost tile position 2
		lda #$2e2c
		sta |redghost_tile_y
		sta |red_tile_y_2

;259d  212f2e    ld      hl,#2e2f
;25a0  220c4d    ld      (#4d0c),hl	; set pink ghost tile position
;25a3  22334d    ld      (#4d33),hl	; set pink ghost tile position 2
		lda #$2e2f
		sta |pinkghost_tile_y
		sta |pink_tile_y_2

;25a6  212f30    ld      hl,#302f
;25a9  220e4d    ld      (#4d0e),hl	; set inky tile position
;25ac  22354d    ld      (#4d35),hl	; set inky tile position 2
		lda #$302f
		sta |blueghost_tile_y
		sta |blue_tile_y_2

;25af  212f2c    ld      hl,#2c2f
;25b2  22104d    ld      (#4d10),hl	; set orange ghost tile position
;25b5  22374d    ld      (#4d37),hl	; set orange ghost tile position 2
		lda #$2c2f
		sta |orangeghost_tile_y
		sta |orange_tile_y_2

;25b8  21382e    ld      hl,#2e38
;25bb  22124d    ld      (#4d12),hl	; set pacman tile position
;25be  22394d    ld      (#4d39),hl	; set pacman tile position 2
		lda #$2e38
		sta |pacman_demo_tile_y
		sta |pacman_tile_pos_y

;25c1  210001    ld      hl,#0100
;25c4  22144d    ld      (#4d14),hl	; set red ghost tile changes
;25c7  221e4d    ld      (#4d1e),hl	; set red ghost tile changes 2
		lda #$0100
		sta |red_ghost_tchangeA_y
		sta |red_ghost_tchange_y

;25ca  210100    ld      hl,#0001
;25cd  22164d    ld      (#4d16),hl	; set pink ghost tile changes
;25d0  22204d    ld      (#4d20),hl	; set pink ghost tile changes 2
		lda #$0001
		sta |pink_ghost_tchangeA_y
		sta |pink_ghost_tchange_y

;25d3  21ff00    ld      hl,#00ff
;25d6  22184d    ld      (#4d18),hl	; set inky tile changes
;25d9  22224d    ld      (#4d22),hl	; set inky tile changes 2
		lda #$00ff
		sta |blue_ghost_tchangeA_y
		sta |blue_ghost_tchange_y

;25dc  21ff00    ld      hl,#00ff
;25df  221a4d    ld      (#4d1a),hl	; set orange ghost tile changes
;25e2  22244d    ld      (#4d24),hl	; set orange ghost tile changes 2
		lda #$00ff
		sta |orange_ghost_tchangeA_y
		sta |orange_ghost_tchange_y

;25e5  210001    ld      hl,#0100
;25e8  221c4d    ld      (#4d1c),hl	; set pacman tile changes
;25eb  22264d    ld      (#4d26),hl	; set pacman tile changes 2
		lda #$0100
		sta |pacman_tchangeA_y
		sta |wanted_pacman_tile_y

;25ee  210201    ld      hl,#0102
;25f1  22284d    ld      (#4d28),hl	; set previous red and pink ghost orientation
;25f4  222c4d    ld      (#4d2c),hl	; set red and pink ghost orientation
		lda #$0002
		sta |prev_red_ghost_dir
		sta |red_ghost_dir
		lda #$0001
		sta |prev_pink_ghost_dir
		sta |pink_ghost_dir

;25f7  210303    ld      hl,#0303
		lda #$0003

;25fa  222a4d    ld      (#4d2a),hl	; set previous blue and orange ghost orientation
		sta |prev_blue_ghost_dir
		sta |prev_orange_ghost_dir
;25fd  222e4d    ld      (#4d2e),hl	; set blue and orange ghost orientation
		sta |blue_ghost_dir
		sta |orange_ghost_dir

;2600  3e02      ld      a,#02
		lda #$0002
;2602  32304d    ld      (#4d30),a	; set pacman orientation
		sta |pacman_dir
;2605  323c4d    ld      (#4d3c),a	; set wanted pacman orientation
		sta |wanted_pacman_orientation
;2608  210000    ld      hl,#0000
;260b  22d24d    ld      (#4dd2),hl	; set fruit position
		stz |fruit_y
;260e  c9        ret     		; return
		rts
;------------------------------------------------------------------------------
; resets ghost home counter and if parameter = 1, sets red ghost to chase pac man 
; task #05 called from #23A7
; #268B ; A = 5
task_resetGhostHome mx %00
;268b  3e55      ld      a,#55
;268d  32944d    ld      (#4d94),a	; store #55 into counter related to ghost movement inside home
		ldx #$55
		stx |home_counter0

;2690  05        dec     b		; check parameter
;2691  c8        ret     z		; return if parameter == #00
		dec
		beq :rts

;2692  3e01      ld      a,#01
;2694  32a04d    ld      (#4da0),a	; else store #01 into red ghost substate.  makes red ghost chase pac man.
		lda #1
		sta |red_substate	; going to pacman

;2697  c9        ret     		; return
:rts
		rts
;------------------------------------------------------------------------------
; #240D ; A=06   ; clears the color RAM 
task_clearColor mx %00
;240d  af        xor     a		; A := #00
;240e  010400    ld      bc,#0004	; set up counters
;2411  210044    ld      hl,#4400	; load hL with start of color ram
;2414  cf        rst     #8		; clear color ram
;2415  0d        dec     c		; loop done ?
;2416  20fc      jr      nz,#2414        ; no, loop again
;2418  c9        ret    			; return
		ldx #1024-3
]lp
		stz |palette_ram,x
		dex
		dex
		bpl ]lp

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
task_redGhostAI mx %00
;2730  3ac14d    ld      a,(#4dc1)	; load A with movement indicator .  0= random movement , 1= normal movement
		lda |orientation_changes_index
;2733  cb47      bit     0,a		; random movement ?
		bit #1
;2735  c25827    jp      nz,#2758	; no, jump to get normal red movement
		bne :normal_movement

;2738  3ab64d    ld      a,(#4db6)	; yes, load A with red ghost mode 0=normal  1= faster ghost,most dots
;273b  a7        and     a		; faster mode ?
;273c  201a      jr      nz,#2758        ; yes, get norm red direction
		lda |red_difficulty0
		bne :normal_movement

;273e  3a044e    ld      a,(#4e04)	; no, load A with game mode (3=ghost move, 2=ghost wait for start) (when is this 2 ???)
		lda |levelstate
;2741  fe03      cp      #03		; is this normal game mode ?
		cmp #3
;2743  2013      jr      nz,#2758        ; no, get normal red direction
		bne :normal_movement

; random red ghost directions

;2745  2a0a4d    ld      hl,(#4d0a)	; yes, load HL with red ghost location  YY XX
		ldx |redghost_tile_y
;2748  3a2c4d    ld      a,(#4d2c)	; load A with red ghost direction
		lda |red_ghost_dir

; OTTPATCH
;PATCH TO MAKE THE MONSTERS MOVE RANDOMLY
;ORG 274BH
;CALL RCORNER
;274b  cd6195    call    #9561		; load DE with a (random ?) quadrant for the destination
		jsr pick_quadrant

;274e  cd6629    call    #2966		; get dir. by finding shortest distance
		jsr getBestNewDirection
;2751  221e4d    ld      (#4d1e),hl	; store red ghost movement offsets
		stx |red_ghost_tchange_y
;2754  322c4d    ld      (#4d2c),a	; store red ghost direction
		sta |red_ghost_dir
;2757  c9        ret     		; return
		rts

; normal movement get direction for red ghost
:normal_movement
;2758  2a0a4d    ld      hl,(#4d0a)	; load HL with red ghost location  YY XX
		ldx |redghost_tile_y
;275b  ed5b394d  ld      de,(#4d39)	; load DE with ms pac location YY XX
		ldy |pacman_tile_pos_y
;275f  3a2c4d    ld      a,(#4d2c)	; load A with red ghost current direction
		lda |red_ghost_dir
;2762  cd6629    call    #2966		; get best new dir. by finding shortest distance
		jsr getBestNewDirection
;2765  221e4d    ld      (#4d1e),hl	; store red ghost tile changes
		stx |red_ghost_tchange_y
;2768  322c4d    ld      (#4d2c),a	; store red ghost direction
		sta |red_ghost_dir
;276b  c9        ret     		; return
		rts
;------------------------------------------------------------------------------
; red ghost logic: (not edible)
; pink ghost AI start
; #276C ; A=09   ; pink ghost AI task_pinkGhostAI
task_pinkGhostAI mx %00
;276c  3ac14d    ld      a,(#4dc1)	; load A with movement indicator
		lda |orientation_changes_index
;276f  cb47      bit     0,a		; random movement ?
		bit #1
;2771  c28e27    jp      nz,#278e	; no, skip ahead and do pink ghost AI
		bne :normal_movement
;2774  3a044e    ld      a,(#4e04)	; yes, load A with level cleared register
;2777  fe03      cp      #03		; == # 03 ? (why?  when game is played, this is always 3 ???)
;2779  2013      jr      nz,#278e        ; no, skip ahead and do pink ghost AI (never will take this route??)
		lda |levelstate
		cmp #3
		bne :normal_movement

; pink ghost random movement

;277b  2a0c4d    ld      hl,(#4d0c)	; else load HL with pink ghost position
		ldx |pinkghost_tile_y
;277e  3a2d4d    ld      a,(#4d2d)	; load A with pink ghost direction
		lda |pink_ghost_dir

; OTTPATCH
;PATCH TO MAKE THE MONSTERS MOVE RANDOMLY
;ORG 2781H
;CALL RCORNER
;2781  cd6195    call    #9561		; call new code to pick a location to move toward ?
		jsr pick_quadrant
;2784  cd6629    call    #2966		; get new direction by finding shortest distance
		jsr getBestNewDirection
;2787  22204d    ld      (#4d20),hl	; store new pink ghost Y and X tile changes
		stx |pink_ghost_tchange_y
;278a  322d4d    ld      (#4d2d),a	; store new pink ghost direction
		sta |pink_ghost_dir
;278d  c9        ret     		; return
		rts

; pink ghost normal movement
:normal_movement
;278e  ed5b394d  ld      de,(#4d39)	; load DE with pac man position
;2792  2a1c4d    ld      hl,(#4d1c)	; load HL with pac man direction
		lda |pacman_tchangeA_y

	; hard hack: HACK6
	; 2795  00        nop

;2795  29        add     hl,hl		; HL := HL * 2
		asl
;2796  29        add     hl,hl		; HL := HL * 2
		asl
;2797  19        add     hl,de		; add direction to position
		clc
		adc |pacman_tile_pos_y ; 4d39
;2798  eb        ex      de,hl		; copy to DE
		tay
;2799  2a0c4d    ld      hl,(#4d0c)	; load HL with pink ghost position
		ldx |pinkghost_tile_y
;279c  3a2d4d    ld      a,(#4d2d)	; load A with pink ghost direction
		lda |pink_ghost_dir
;279f  cd6629    call    #2966		; compute best new directions
		jsr getBestNewDirection
;27a2  22204d    ld      (#4d20),hl	; store new ping ghost Y and X tile changes
		stx |pink_ghost_tchange_y
;27a5  322d4d    ld      (#4d2d),a	; store new pink ghost direction
		sta |pink_ghost_dir
;27a8  c9        ret     		; return
		rts
;------------------------------------------------------------------------------
; blue ghost (inky) AI
; #27A9 ; A=0A   ; blue ghost (inky)
task_blueGhostAI mx %00
;27a9  3ac14d    ld      a,(#4dc1)	; load A with movement indicator
		lda |orientation_changes_index
;27ac  cb47      bit     0,a		; random movement ?
		bit #1
;27ae  c2cb27    jp      nz,#27cb	; no ,skip ahead and do normal inky ghost AI
		bne :normal_movement

;27b1  3a044e    ld      a,(#4e04)	; yes, load A with level cleared register
;27b4  fe03      cp      #03		; == # 03 ?  (this always 3 during a game ... ?)
;27b6  2013      jr      nz,#27cb        ; jump if not 3 ahead to do normal AI
		lda |levelstate
		cmp #3
		bne :normal_movement

; random (?) blue ghost (inky) movement

;27b8  2a0e4d    ld      hl,(#4d0e)	; load HL with inky position
		ldx |blueghost_tile_y

; OTTPATCH
;PATCH TO MAKE THE MONSTERS MOVE RANDOMLY
;ORG 2781H
;CALL RCORNER
;27bb  cd5995    call    #9559		; pick a random quadrant (why ??? DE is loaded new in next step)
;27be  114020    ld      de,#2040	; load DE with lower right corner destination
		ldy #$2040
;27c1  cd6629    call    #2966		; get best new direction
		jsr getBestNewDirection

;27c4  22224d    ld      (#4d22),hl	; store new direction into inky's tile changes
		stx |blue_ghost_tchange_y
;27c7  322e4d    ld      (#4d2e),a	; store inky's new direction
		sta |blue_ghost_dir
;27ca  c9        ret     		; return
		rts

; normal blue ghost (inky) movement
:normal_movement

;27cb  ed4b0a4d  ld      bc,(#4d0a)	; load BC with red ghost position (X, Y)
;27cf  ed5b394d  ld      de,(#4d39)	; load DE with pac man position
;27d3  2a1c4d    ld      hl,(#4d1c)	; load HL with pacman direction 
		lda |pacman_tchangeA_y
					; H loads with (0 = facing up or down, 01 = facing left, FF = facing right)
					; L loads with (0= facing left or right, 01 = facing down, FF = facing up)
;27d6  29        add     hl,hl		; HL := HL * 2
		asl
;27d7  19        add     hl,de		; add result to pac position.  this now has the position 2 in front of pac
		clc
		adc |pacman_tile_pos_y
		sep #$20
;27d8  7d        ld      a,l		; load A with computed Y position
;27d9  87        add     a,a		; A := A * 2
		asl
;27da  91        sub     c		; subtract red ghost Y position
		sec
		sbc |redghost_tile_y
;27db  6f        ld      l,a		; save result into L
;27dc  7c        ld      a,h		; load A with computed X position
		xba
;27dd  87        add     a,a		; A := A * 2
		asl
;27de  90        sub     b		; subract red ghost X position
		sec
		sbc |redghost_tile_x
;27df  67        ld      h,a		; save result into H
;27e0  eb        ex      de,hl		; save total result into DE
		xba
		rep #$30

;27e1  2a0e4d    ld      hl,(#4d0e)	; load HL with blue ghost (Inky) position
		ldx |blueghost_tile_y
;27e4  3a2e4d    ld      a,(#4d2e)	; load A with blue ghost (Inky) direction
		lda |blue_ghost_dir
;27e7  cd6629    call    #2966		; get best new direction
		jsr getBestNewDirection
;27ea  22224d    ld      (#4d22),hl	; Store blue ghost (inky) y tile changes
		stx |blue_ghost_tchange_y
;27ed  322e4d    ld      (#4d2e),a	; store new blue direction
		sta |blue_ghost_dir
;27f0  c9        ret   			; return  
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
;task_setDifficulty mx %00
;		rts
;------------------------------------------------------------------------------
; #26A2 ; A=11	; clears memories from #4D00 through #4DFF
task_clearMemory4D mx %00
		phb

		stz |cutscene_positions
		ldx #cutscene_positions+1
		ldy #cutscene_positions+2
		lda #{mainstate-cutscene_positions}-3
		mvn ^cutscene_positions,^cutscene_positions

		plb
		rts
;------------------------------------------------------------------------------
; #24C9 ; A=12	; sets up coded pills and power pills memories
task_setPills mx %00
		jmp ResetPills
;------------------------------------------------------------------------------
; this is not named correctly at all, it's storing in the tile_ram
; not into sprite ram
; #2A35 ; A=13	; clears the sprites
task_clearSprites mx %00
;2a35  114040    ld      de,#4040
		ldx #$0040
;2a38  21c043    ld      hl,#43c0
;2a3b  a7        and     a
;2a3c  ed52      sbc     hl,de
;2a3e  c8        ret     z
		sep #$20
]loop
;2a3f  1a        ld      a,(de)
;2a40  fe10      cp      #10
;2a42  ca532a    jp      z,#2a53
		lda |tile_ram,x
		cmp #$10
		beq :clear

;2a45  fe12      cp      #12
;2a47  ca532a    jp      z,#2a53
		cmp #$12
		beq :clear

;2a4a  fe14      cp      #14
;2a4c  ca532a    jp      z,#2a53
		cmp #$14
		beq :clear
;2a4f  13        inc     de
;2a50  c3382a    jp      #2a38
		bra :skip
:clear
;2a53  3e40      ld      a,#40
		lda #$40
;2a55  12        ld      (de),a
		sta |tile_ram,x
;2a56  13        inc     de
:skip
		inx
		cpx #$3C0
		bne ]loop
;2a57  c3382a    jp      #2a38
		rep #$30
		rts
;------------------------------------------------------------------------------
; #26D0 ; A=14	; checks all dip switches and assigns memories to the settings indicated
task_copyDips mx %00
		rts
;------------------------------------------------------------------------------
; #2487 ; A=15	; update the current screen pill config to video ram
task_updatePills mx %00
		rts
;------------------------------------------------------------------------------
; #23E8 ; A=16	; increase main subroutine number (#4E04)
task_incMain mx %00
		inc |levelstate
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
;; draw the score to the screen
; DE has the address of msb of the score
; Y = DE
; HL has starting screen position
; X = HL
; B has #03, and C has #04 or #06
; A = BC
; 2abe
DrawScore mx %00
:C equ temp0
:B equ temp0+1

		pei temp0

		sta <:C

		sep #$20    ;mx = 10, short a, long xy
;2abe  1a        ld      a,(de)		; load A with byte of score
]loop
		lda |0,y
;2abf  0f        rrca    
;2ac0  0f        rrca    
;2ac1  0f        rrca    
;2ac2  0f        rrca 			; roll right 4 times through carry flag, result is digits transposed (eg. 82 converts to #28)
		lsr
		lsr
		lsr
		lsr
;2ac3  cdce2a    call    #2ace		; drawtens digit to screen
		jsr :draw_digit

;2ac6  1a        ld      a,(de)		; load A with byte of score
		lda |0,y
;2ac7  cdce2a    call    #2ace		; draw ones digit to screen
		jsr :draw_digit

;2aca  1b        dec     de		; next score digit
		dey

;2acb  10f1      djnz    #2abe           ; loop 3 times
		dec <:B
		bne ]loop

;2acd  c9        ret     		; return
		rep #$30
		pla
		sta <temp0
		rts
:draw_digit mx %10
;2ace  e60f      and     #0f		; mask out left 4 bits to zero
		and #$0F
;2ad0  2804      jr      z,#2ad6         ; result zero?  yes, skip next 2 steps
		beq :is_zero

;2ad2  0e00      ld      c,#00		; C := #00
;2ad4  1807      jr      #2add           ; skip ahead
		stz <:C

:is_zero
;2ad6  79        ld      a,c		; load A with C
;2ad7  a7        and     a		; == #00 ?
		lda <:C
;2ad8  2803      jr      z,#2add         ; yes, skip ahead
		beq :skip

;2ada  3e40      ld      a,#40		; else A := #40
		lda #$40
;2adc  0d        dec     c		; decrement C
		dec <:C
:skip
;2add  77        ld      (hl),a		; draw score to screen
		sta |0,x
;2ade  2b        dec     hl		; next screen position
		dex
;2adf  c9        ret     		; return
		rts

;------------------------------------------------------------------------------
; #2AE0 ; A=18	; draws "high score" and scores.  clears player 1 and 2 scores to zero.
task_resetScores mx %00
;2ae0  0600      ld      b,#00		; B := #00
		ldy #0
;2ae2  cd5e2c    call    #2c5e		; print HIGH SCORE
		jsr DrawText

;2ae5  af        xor     a		; A := #00
;2ae6  21804e    ld      hl,#4e80	; load HL with player 1 score start address
;2ae9  0608      ld      b,#08		; set counter to 8
;2aeb  cf        rst     #8		; clear player 1 and player 2 scores to zero
		stz |p1_score
		stz |p1_score+2
		stz |p2_score
		stz |p2_score+2

;2aec  010403    ld      bc,#0304	; load BC with counters
		lda #$0304
;2aef  11824e    ld      de,#4e82	; load DE with p1 msb of score
		ldy #p1_score+2
;2af2  21fc43    ld      hl,#43fc	; load HL with screen pos for p1 current score
		ldx #tile_ram+$3fc
;2af5  cdbe2a    call    #2abe		; draw score to screen
		jsr DrawScore

;2af8  010403    ld      bc,#0304	; load BC with counters
;2afb  11864e    ld      de,#4e86	; load DE with player 2 address
		ldy #p2_score+2
;2afe  21e943    ld      hl,#43e9	; load HL with screen pos for player 2 score
		ldx #tile_ram+$3e9

;2b01  3a704e    ld      a,(#4e70)	; load A with number of players (0=1 player, 1=2 players)
;2b04  a7        and     a		; is this a 1 player game?
;2b05  20b7      jr      nz,#2abe        ; no, draw player 2 score and return

		lda |no_players
		beq :useC6
		lda #$0304
		bra DrawScore
:useC6
;2b07  0e06      ld      c,#06		; else C := #06
		lda #$0306
;2b09  18b3      jr      #2abe           ; draw player 2 score and return
		bra DrawScore

; called from #2A65, #2A9B

;2b0b  3a094e    ld      a,(#4e09)	; load A with current player number:  0=P1, 1=P2
;2b0e  21804e    ld      hl,#4e80	; load HL with player 1 score start address
;2b11  a7        and     a		; is this player 1 ?
;2b12  c8        ret     z		; yes, return

;2b13  21844e    ld      hl,#4e84	; else load HL with player 2 start address
;2b16  c9        ret     		; return
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
:next2
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

;9616  09 20 f5 41 			; screen location #41F5
	db $09,$20
	dw tile_ram+$1F5

;961a  09 21 15 42			; screen location #4215
	db $09,$22
	dw tile_ram+$215

;961e  09 22 f6 41 			; screen location #41F6
	db $09,$22
	dw tile_ram+$1F6

;9622  09 23 16 42 			; screen location #4216
	db $09,$23
	dw tile_ram+$216

;9626  ff
	db $ffff

	; subroutine for start button press
	; called from #9610
	; draws the MS PAC MAN which appears between "ADDITIONAL" and "AT 10,000 pts"
draw_table mx %00
;9627  7e        ld      a,(hl)		; load A with table data
]loop
		lda |0,x
;9628  feff      cp      #ff		; are we done?
		cmp #$FFFF
;962a  280f      jr      z,#963b         ; yes, return
		beq :done
;962c  47        ld      b,a		; else load B with this first data byte
;962d  23        inc     hl		; next table entry
;962e  7e        ld      a,(hl)		; load A with next data
;962f  23        inc     hl		; next table entry
;9630  5e        ld      e,(hl)		; load E with next data
;9631  23        inc     hl		; next table entry
;9632  56        ld      d,(hl)		; load D with next data
		ldy |2,x
;9633  12        ld      (de),a		; Draws element to screen
		sep #$20
		sta |$400,y		; stores out the color data into the palette_ram
;9634  78        ld      a,b		; load A with B
;9635  cbd2      set     2,d		; set bit 2 of D.  changes DE to color grid
;9637  12        ld      (de),a		; store A into color grid
;9638  23        inc     hl		; next table entry
		xba
		sta |0,y		; stores out the graphic character number

		rep #$31
		txa
		adc #4
		tax

;9639  18ec      jr      #9627           ; loop again
		bra ]loop
:done
;963b  c9        ret     		; return
		rts

	; called from #95F0.  clears intermission indicator
clear_intermission mx %00
;963c  3e00      ld      a,#00		; A := #00
;963e  32004f    ld      (#4f00),a	; clear the intermission indicator
		stz |is_intermission

;9641  c9        ret     		; return
		rts

;------------------------------------------------------------------------------
; #2BA1	; A=1D	; write # of credits on screen
task_drawCredits mx %00

;		nop
;		nop
;		nop
;]wait   bra ]wait
;		nop
;		nop
;		nop

;2ba1  3a6e4e    ld      a,(#4e6e)	; load A with number of credits in ram
;2ba4  feff      cp      #ff		; set for free play?
;2ba6  2005      jr      nz,#2bad        ; no? then skip ahead
		lda |no_credits
		bpl :not_free

;2ba8  0602      ld      b,#02		; load code for "FREE PLAY"
;2baa  c35e2c    jp      #2c5e		; print FREE PLAY and return from sub
		ldy #2						; "FREE PLAY"
		jmp DrawText

:not_free
;2bad  0601      ld      b,#01		; else load code for "CREDIT"
		ldy #1						; "CREDIT"
;2baf  cd5e2c    call    #2c5e		; print "CREDIT" on screen
		jsr DrawText

		sep #$20
;2bb2  3a6e4e    ld      a,(#4e6e)	; load A with number of credits in ram
		lda |no_credits
;2bb5  e6f0      and     #f0		; mask bits.  is it bigger than 9?
		and #$F0
;2bb7  2809      jr      z,#2bc2         ; yes, only draw 1 position
		beq :one_digit
;2bb9  0f        rrca  			; else ...  
;2bba  0f        rrca    		;
;2bbb  0f        rrca    		; 
;2bbc  0f        rrca    		; rotate right 4 times, which moves the 10's digit to the 1's digit
		lsr
		lsr
		lsr
		lsr
;2bbd  c630      add     a,#30		; Add #30 to account for ascii code for numbers
		ora #$30
;2bbf  323440    ld      (#4034),a	; put tens digit for number of credits on screen
		sta |tile_ram+$34
:one_digit
;2bc2  3a6e4e    ld      a,(#4e6e)	; load A with number of credits in ram
		lda |no_credits
;2bc5  e60f      and     #0f		; mask out high bits.  result is between 0 and 9
		and #$0F
;2bc7  c630      add     a,#30		; Add #30 to account for ascii code for numbers
		ora #$30
;2bc9  323340    ld      (#4033),a	; put 1's digit number of credits on screen
		sta |tile_ram+$33
		rep #$31
;2bcc  c9        ret     		; return
		rts
;------------------------------------------------------------------------------
; #2675	; A=1E	; clear fruit, pacman, and all ghosts
task_clearActors mx %00
		stz |fruit_y
		stz |pacman_y

;267e
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
