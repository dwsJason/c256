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
		ldx #1022-128 ;510
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
		ldx #1024-2
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
		lda |blue_ghost_dir
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
		tay

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
task_orangeGhostAI mx %00

;27f1  3ac14d    ld      a,(#4dc1)	; load A with movement indicator
		lda |orientation_changes_index
;27f4  cb47      bit     0,a		; random movement ?
		bit #1
;27f6  c21328    jp      nz,#2813	; no, skip ahead and normal orange ghost AI
		bne :normal_movement

;27f9  3a044e    ld      a,(#4e04)	; load A with level cleared register
		lda |levelstate
;27fc  fe03      cp      #03		; == #03 ?  ( this is always 3 during game)
		cmp #3
;27fe  2013      jr      nz,#2813        ; jump if not 3 to normal orange ghost AI
		bne :normal_movement

; random orange ghost movement
; not really random, the random quadrant gets overridden with the lower left corner
;2800  2a104d    ld      hl,(#4d10)	; load HL with orange ghost position
:go_lower_left
		ldx |orangeghost_tile_y
		lda |orange_ghost_dir
; OTTPATCH
;PATCH TO MAKE THE MONSTERS MOVE RANDOMLY
;ORG 2803H
;CALL R2CORNER
;2803  cd5e95    call    #955e		; pick a random quadrant (why?  DE is loaded new in next step)
		jsr pick_quadrant
;2806  11403b    ld      de,#3b40	; load DE with lower left corner destination
		ldy #$3b40
;2809  cd6629    call    #2966		; get best new direction
		jsr getBestNewDirection
;280c  22244d    ld      (#4d24),hl	; store new orange ghost direction tile changes
		stx |orange_ghost_tchange_y
;280f  322f4d    ld      (#4d2f),a	; store new orange ghost direction 
		sta |orange_ghost_dir
;2812  c9        ret     		; return
		rts

; normal orange ghost movement
:normal_movement
;2813  dd21394d  ld      ix,#4d39	; load IX with pacman Y and X tile position
		ldx #pacman_tile_pos_y
;2817  fd21104d  ld      iy,#4d10	; load IY with orange ghost tile future posiiton
		ldy #orangeghost_tile_y
;281b  cdea29    call    #29ea		; load HL with sum of square of X and Y distances
		jsr sum_dist_squared

;281e  114000    ld      de,#0040	; load DE with offset. #40 is hex for 64 deciamal, which is 8 squared.

    	; hard hack: HACK6
	; 281e  112400    ld      de,#0024
	;

;2821  a7        and     a		; clear carry flag
;2822  ed52      sbc     hl,de		; subtract offset from distance.   is orange ghost getting too close to pac-man?  (<8 units)
;2824  da0028    jp      c,#2800		; yes, jump back and have ghost move toward lower left corner
		cmp #64
		bcc :go_lower_left

;2827  2a104d    ld      hl,(#4d10)	; else load HL with orange ghost future position
		ldx #orangeghost_tile_y
;282a  ed5b394d  ld      de,(#4d39)	; load DE with pac man position
		ldy #pacman_tile_pos_y
;282e  3a2f4d    ld      a,(#4d2f)	; load A with orange ghost direction
		lda |orange_ghost_dir
;2831  cd6629    call    #2966		; get best new direction
		jsr getBestNewDirection
;2834  22244d    ld      (#4d24),hl	; store orange ghost tile changes
		stx |orange_ghost_tchange_y
;2837  322f4d    ld      (#4d2f),a	; store orange ghost direction
		sta |orange_ghost_dir
;283a  c9        ret     		; return
		rts
;------------------------------------------------------------------------------
; #283B ; A=0C   ; red ghost movement when power pill active 
task_redGhostRun mx %00
;283b  3aac4d    ld      a,(#4dac)	; load A with red ghost state
;283e  a7        and     a		; is red ghost alive ?
;283f  ca5528    jp      z,#2855		; yes, skip ahead and give random direction
		lda |redghost_state
		beq :alive

;2842  112c2e    ld      de,#2e2c	; no, load DE with the destination 2E, 2C which is right above the ghost house
		ldy #$2e2c
;2845  2a0a4d    ld      hl,(#4d0a)	; load HL with red ghost tile positions
		ldx |redghost_tile_y
;2848  3a2c4d    ld      a,(#4d2c)	; load A with red ghost direction
		lda |red_ghost_dir
;284b  cd6629    call    #2966		; get best new direction
		jsr getBestNewDirection
;284e  221e4d    ld      (#4d1e),hl	; store new direction tiles for red ghost
		stx |red_ghost_tchange_y
;2851  322c4d    ld      (#4d2c),a	; store new ghost direction
		sta |red_ghost_dir
;2854  c9        ret     		; return
		rts
:alive
;2855  2a0a4d    ld      hl,(#4d0a)	; load HL with red ghost tile positions
		ldx |redghost_tile_y
;2858  3a2c4d    ld      a,(#4d2c)	; load A with red ghost direction
		lda |red_ghost_dir
;285b  cd1e29    call    #291e		; load A and HL with random direction and tile direction
		jsr runAwayGhost

;285e  221e4d    ld      (#4d1e),hl	; store new direction tiles for red ghost
		stx |red_ghost_tchange_y
;2861  322c4d    ld      (#4d2c),a	; store new red ghost direction
		sta |red_ghost_dir
;2864  c9        ret     		; return
		rts
;------------------------------------------------------------------------------
; #2865 ; A=0D	; pink ghost movement when power pill active
; called from #23A7 when task = #0C
; check red ghost movement when power pill active
; check pink ghost
task_pinkGhostRun mx %00
;2865  3aad4d    ld      a,(#4dad)	; load A with pink ghost state
;2868  a7        and     a		; is pink ghost alive ?
;2869  ca7f28    jp      z,#287f		; yes, skip ahead and give random direction
		lda |pinkghost_state
		beq :alive

;286c  112c2e    ld      de,#2e2c	; no, load DE with the destination 2E, 2C which is right above the ghost house 
		ldy #$2e2c
;286f  2a0c4d    ld      hl,(#4d0c)	; load HL with pink ghost tile positions
		ldx |pinkghost_tile_y
;2872  3a2d4d    ld      a,(#4d2d)	; load A with pink ghost direction
		lda |pink_ghost_dir
;2875  cd6629    call    #2966		; get best new direction
		jsr getBestNewDirection

;2878  22204d    ld      (#4d20),hl	; store new direction tiles for pink ghost
		stx |pink_ghost_tchange_y
;287b  322d4d    ld      (#4d2d),a	; store new pink ghost direction
		sta |pink_ghost_dir
;287e  c9        ret     		; return
		rts
:alive
;287f  2a0c4d    ld      hl,(#4d0c)	; load HL with pink ghost tile direction
		ldx |pinkghost_tile_y
;2882  3a2d4d    ld      a,(#4d2d)	; load A with pink ghost orientation
		lda |pink_ghost_dir
;2885  cd1e29    call    #291e		; load A and HL with random direction and tile direction
		jsr runAwayGhost
;2888  22204d    ld      (#4d20),hl	; store new direction tiles for pink ghost
		stx |pink_ghost_tchange_y
;288b  322d4d    ld      (#4d2d),a	; store new pink ghost orientation
		sta |pink_ghost_dir
;288e  c9        ret     		; return
		rts
;------------------------------------------------------------------------------
; check blue ghost (inky)
; #288F ; A=0E	; blue ghost (inky) movement when power pill active
task_blueGhostRun
;288f  3aae4d    ld      a,(#4dae)	; load A with inky state
;2892  a7        and     a		; is inky alive ?
;2893  caa928    jp      z,#28a9		; yes, skip ahead and give random direction
		lda |blueghost_state
		beq :alive

;2896  112c2e    ld      de,#2e2c	; no, load DE with the destination 2E, 2C which is right above the ghost house 
		ldy #$2e2c
;2899  2a0e4d    ld      hl,(#4d0e)	; load HL with inky tile positions
		ldx |blueghost_tile_y
;289c  3a2e4d    ld      a,(#4d2e)	; load A with ink direction
		lda |blue_ghost_dir
;289f  cd6629    call    #2966		; get best new direction
		jsr getBestNewDirection

;28a2  22224d    ld      (#4d22),hl	; store new direction tiles for inky
		stx |blue_ghost_tchange_y
;28a5  322e4d    ld      (#4d2e),a	; store new inky direction
		sta |blue_ghost_dir
;28a8  c9        ret     		; return
		rts
:alive
;28a9  2a0e4d    ld      hl,(#4d0e)	; load HL with inky tile changes
		ldx |blueghost_tile_y
;28ac  3a2e4d    ld      a,(#4d2e)	; load A with inky direction
		lda |blue_ghost_dir
;28af  cd1e29    call    #291e		; load A and HL with random direction and tile direction
		jsr runAwayGhost
;28b2  22224d    ld      (#4d22),hl	; store inky new tile directions
		stx |blue_ghost_tchange_y
;28b5  322e4d    ld      (#4d2e),a	; store new inky direction
		sta |blue_ghost_dir
;28b8  c9        ret     		; return
		rts
;------------------------------------------------------------------------------
; check orange ghost
; #28B9 ; A=0F	; orange ghost movement when power pill active
task_orangeGhostRun
;28b9  3aaf4d    ld      a,(#4daf)	; load A with orange ghost state
;28bc  a7        and     a		; is orange ghost alive ?
;28bd  cad328    jp      z,#28d3		; yes, skip ahead and assign random direction
		lda |orangeghost_state
		beq :alive

;28c0  112c2e    ld      de,#2e2c	; no, load DE with the destination 2E, 2C which is right above the ghost house 
		ldy #$2e2c
;28c3  2a104d    ld      hl,(#4d10)	; load HL with orange ghost tile directions
		ldx |orangeghost_tile_y
;28c6  3a2f4d    ld      a,(#4d2f)	; load A with orange ghost direction
		lda |orange_ghost_dir
;28c9  cd6629    call    #2966		; get best new directions
		jsr getBestNewDirection
;28cc  22244d    ld      (#4d24),hl	; store new orange ghost tile directions
		stx |orange_ghost_tchange_y
;28cf  322f4d    ld      (#4d2f),a	; store new orange ghost direction
		sta |orange_ghost_dir
;28d2  c9        ret     		; return
		rts
:alive
;28d3  2a104d    ld      hl,(#4d10)	; load HL with orange ghost tile directions
		ldx |orangeghost_tile_y
;28d6  3a2f4d    ld      a,(#4d2f)	; load A with orange ghost direction
		lda |orange_ghost_dir
;28d9  cd1e29    call    #291e		; load A and HL with random direction and tile direction
		jsr runAwayGhost
;28dc  22244d    ld      (#4d24),hl	; store new orange ghost tile directions
		stx |orange_ghost_tchange_y
;28df  322f4d    ld      (#4d2f),a	; store new orange ghost direction
		sta |orange_ghost_dir
;28e2  c9        ret     		; return
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
;; Random number generator
;; #2a23 random number generator, only active when ghosts are blue.    
;; n=(n*5+1) && #1fff.  n is used as an address to read a byte from a rom.
;; #4dc9, #4dca=n  and a=rnd number. n is reset to 0 at #26a9 when you die,
;; start of first level, end of every level.  Later a is anded with 3.
;2a23
ROMRANDOM mx %00
		jmp RANDOM
;2a23  2ac94d    ld      hl,(#4dc9)
;2a26  54        ld      d,h
;2a27  5d        ld      e,l
;2a28  29        add     hl,hl
;2a29  29        add     hl,hl
;2a2a  19        add     hl,de
;2a2b  23        inc     hl
;2a2c  7c        ld      a,h
;2a2d  e61f      and     #1f
;2a2f  67        ld      h,a
;2a30  7e        ld      a,(hl)
;2a31  22c94d    ld      (#4dc9),hl
;2a34  c9        ret   

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
;26d0  3a8050    ld      a,(#5080)	; load A with Dip Switch
;26d3  47        ld      b,a		; copy to B
;26d4  e603      and     #03		; mask bits 0000 0011 - is free play set in the DIP ?
;26d6  c2de26    jp      nz,#26de	; no, skip ahead

;26d9  216e4e    ld      hl,#4e6e	; yes, load HL with credit memory address
;26dc  36ff      ld      (hl),#ff	; store #FF to indicate free play
;26de  4f        ld      c,a		; load C with result computed above
;26df  1f        rra     		; roll right = moves bit 0 to the carry bit and carry flag to bit 7
;26e0  ce00      adc     a,#00		; A := #00 plus carry bit
;26e2  326b4e    ld      (#4e6b),a	; store into coins per credit
;26e5  e602      and     #02		; mask bits 0000 0010 
;26e7  a9        xor     c		; XOR with original result.  this will toggle bit 1 on or off
;26e8  326d4e    ld      (#4e6d),a	; store into number of credits per coin

; check dip switches 2 and 3.  number of starting lives per game

;26eb  78        ld      a,b		; load A with Dip Switch original value from #5080
		lda |DSW1
;26ec  0f        rrca    		; 
;26ed  0f        rrca    		; roll right twice
		lsr
		lsr
;26ee  e603      and     #03		; mask bits.  how many pacmen per game?
		and #03

		;$$JGA TEMP ### - until DIPS are wired
		lda #2
		;$$JGA TEMP ###

;26f0  3c        inc     a		; increment
		inc
;26f1  fe04      cp      #04		; == #04 ?  (swtich set of 3 which gives 5 pacmen per game)
		cmp #4
;26f3  2001      jr      nz,#26f6        ; no, skip next step
		bne :store_lives
;26f5  3c        inc     a		; increment
		inc
:store_lives
;26f6  326f4e    ld      (#4e6f),a	; store result into # of pacmen per game
		sta |no_lives

; check dip switches 4 and 5.  points for bonus pac man

;26f9  78        ld      a,b		; load A with Dip switch
		lda |DSW1
;26fa  0f        rrca    
;26fb  0f        rrca    
;26fc  0f        rrca    
;26fd  0f        rrca 			; roll right four times   
		lsr
		lsr
		lsr
		lsr

;26fe  e603      and     #03		; mask bits - checks score for bonus packman
		and #03
;2700  212827    ld      hl,#2728	; load HL with start of table for this option
;2703  d7        rst     #10		; A := (HL + A).  loads A with table value based on dip switch setting
		tax
		lda |:bonus_scores,x
		and #$FF
;2704  32714e    ld      (#4e71),a	; store result into extra life setting
		sta |bonus_life

; check dip switch 7 for ghost names during attract mode

;2707  78        ld      a,b		; load A with Dip Switch
;2708  07        rlca    		; rotate left with bit 7 moved to bit 0
;2709  2f        cpl			; invert A (one's complement)
;270a  e601      and     #01		; mask bits
;270c  32754e    ld      (#4e75),a	; store result into ghost names mode

; check dip switch 6 for difficulty

;270f  78        ld      a,b		; load A with Dip Switch
;2710  07        rlca    
;2711  07        rlca    		; rotate left twice
;2712  2f        cpl     		; invert A
;2713  e601      and     #01		; mask bits
;2715  47        ld      b,a		; copy result to B
;2716  212c27    ld      hl,#272c	; load HL with start address of difficulty table
;2719  df        rst     #18		; HL := HL + A
;271a  22734e    ld      (#4e73),hl	; store into difficulty table lookup

; check bit 7 on IN1 for upright / cocktail

;271d  3a4050    ld      a,(#5040)	; load A with IN1
;2720  07        rlca    		; rotatle left
;2721  2f        cpl     		; invert A
;2722  e601      and     #01		; mask bits
;2724  32724e    ld      (#4e72),a	; store result into cocktail/upright setting
;2727  c9        ret     		; return
		rts
	; data - bonus/life
	; called from #2700
:bonus_scores
;2728  10				; 10,000 points
;2729  15				; 15,000 points
;272A  20				; 20,000 points
;272B  FF				; code for no extra life
		db $10,$15,$20,$ff

	; data - difficulty settings table
	; called from #2716

;272C  68 00				; normal at #0068
;272E  7D 00				; hard at #007D	

		rts
;------------------------------------------------------------------------------
; update the current screen pill config to video ram
; called from #0912
; called from #23A7 as task #15
; #2487 ; A=15	; update the current screen pill config to video ram
task_updatePills mx %00

; This is just like DrawPills, only it encodes the bit field, instead
; of decodes it, required so that between lives the dots on the field
; are preserved


:bitmask = temp 0
:pVRAM = temp1
:counter = temp2
:bitcount = temp3

		lda #tile_ram
		sta <:pVRAM

		lda #30			; the output size of the pilldata, also loop counter
		sta <:counter

		lda #PelletTable	; lookup table address
		sta <temp0

		jsr ChooseMaze
		tay 			; pointer to source pellet table

		ldx #pilldata		; pointer to output pill table data
]lp
		lda #8			; 8 bits in the byte
		sta <:bitcount
]plp
		lda |0,y 		; load the pellet table, adjust offset into vram
		and #$FF
		clc
		adc <:pVRAM
		sta <:pVRAM

		sep #$20		; a short

		lda (:pVRAM)
		cmp #16
		clc
		bne :clc
		sec
:clc
		rol <:bitmask
:no_pill
		iny    			; next table data
		dec <:bitcount
		rep #$30		; a long again
		bne ]plp

		lda <:bitmask ; record the mask into the table
		sta |0,x

		inx			; next pill entry
		dec <:counter
		bne ]lp


	; ms pac man patch for pellet routine
	; jumped from #24b4
	; arrive here after ms. pac has died
	; this sub is identical to subroutine above, except it saves the power pellets instead of drawing them

;9504  211c95    ld      hl,#951c	; load HL with power pellet lookup table
;9507  cdbd94    call    #94bd		; load BC with value based on level from the table
;950a  11344e    ld      de,#4e34	; load DE with pellet graphic table data
;950d  69        ld      l,c		; 
;950e  60        ld      h,b		; HL now has BC = table start

;950f  4e        ld      c,(hl)
;9510  23        inc     hl
;9511  46        ld      b,(hl)		; BC now has screen loaciton of power pellet
;9512  23        inc     hl
;9513  0a        ld      a,(bc)		; load A with power pellet from screen
;9514  12        ld      (de),a		; save into DE
;9515  13        inc     de		; next location
;9516  3e03      ld      a,#03		; A := #03
;9518  a3        and     e		; mask with E
;9519  20f4      jr      nz,#950f        ; if not zero, loop again
;951b  c9        ret     		; return (to #0915)

; Encode the power pills 
		lda #PowerPelletTable	; Lookup Table Address
		sta <temp0

		jsr ChooseMaze
		tay			; address of pelette table for this map

; Draw 4 Power Pills

		lda |0,y
		tax					; x = vram address
		sep #$20        	
		lda |0,x			; load from VRAM
		sta |powerpills		; first power pill
		rep #$20

		lda |2,y
		tax					; x = vram address
		sep #$20
		lda |0,x			; from VRAM
		sta |powerpills+1	; 2nd power pill
		rep #$20

		lda |4,y
		tax					; x = vram address
		sep #$20
		lda |0,x			; from VRAM
		sta |powerpills+2	; 3rd power pill
		rep #$20

		lda |6,y
		tax					; x = vram address
		sep #$20
		lda |0,x			; from VRAM
		sta |powerpills+3	; 4th power pill
		rep #$20

		rts



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

		ldy |pinkghost_tile_y 			;4d0c;  Y contains both tilepos x and tilepos y
:cont
		ldx |pacman_demo_tile_y			;4d12;  X contains both tilepos x and tilepos y
		lda |wanted_pacman_orientation  ;4d3c; load A with wanted pacman orientation 

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
		bra :skip
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

;------------------------------------------------------------------------------
; called from #2A65, #2A9B
; Return address in X
;2b0b
P12ScoreAddress mx %00
;2b0b  3a094e    ld      a,(#4e09)	; load A with current player number:  0=P1, 1=P2
;2b0e  21804e    ld      hl,#4e80	; load HL with player 1 score start address
;2b11  a7        and     a		; is this player 1 ?
;2b12  c8        ret     z		; yes, return

;2b13  21844e    ld      hl,#4e84	; else load HL with player 2 start address
;2b16  c9        ret     		; return
		ldx #p1_score
		lda |player_no
		bne :p2
		rts
:p2
		ldx #p2_score
		rts

;------------------------------------------------------------------------------
; score table
; (Spaeth)
;2b17
ScoreTable
		dw $0010 ; dot        	=   10	0
		dw $0050 ; power pellet	=   50	1
		dw $0200 ; ghost 1    	=  200	2
		dw $0400 ; ghost 2    	=  400	3
		dw $0800 ; ghost 3    	=  800  4
		dw $1600 ; ghost 4    	= 1600	5
		dw $0100 ; Cherry     	=  100	6
		dw $0200 ; Strawberry 	=  200	7	; 300 in pac-man
		dw $0500 ; Orange     	=  500	8
		dw $0700 ; Pretzel    	=  700	9
		dw $1000 ; Apple      	= 1000	a
		dw $2000 ; Pear       	= 2000	b
		dw $5000 ; Banana     	= 5000	c	; 3000 in pac-man
		dw $5000 ; Junior!    	= 5000	d


;------------------------------------------------------------------------------
; arrive here from #1780 when a ghost is eaten. 
; B contains the # of ghosts eaten +1 (2-5)
;
; or arrive from #23A7 for a task
; B is loaded with code of scoring item
; #2A5A ; A=19	; update score.  B has code for items scored, draw score on screen, check for high score and extra lives
;2a5a
update_score mx %00
task_updateScore mx %00
		ldx |mainstate
		cpx #1			; is this the intro mode ?
		bne :continue
		; in intro, so skip
		rts

:continue

; if we probably don't need this yet
	; this updates the score when something is eaten
	; (from the table at 2b17)
	; A is loaded with the code for item eaten
;2a60  21172b    ld      hl,#2b17	; load HL with start of scoring table data
;2a63  df        rst     #18		; load HL with score based on item eaten stored in A
		asl
		tay
;2a64  eb        ex      de,hl		; copy to DE

;2a65  cd0b2b    call    #2b0b		; load HL with score address for current player
		jsr P12ScoreAddress

;2a68  7b        ld      a,e		; load A with low byte of score to add
;2a69  86        add     a,(hl)		; add player's score low byte to A
;2a6a  27        daa     		; decimal adjust
;2a6b  77        ld      (hl),a		; store result into score
;2a6c  23        inc     hl		; next memory, for second byte of score
;2a6d  7a        ld      a,d		; load A with high byte of score to add
;2a6e  8e        adc     a,(hl)		; add with carry players's score second byte to A
;2a6f  27        daa     		; decimal adjust
;2a70  77        ld      (hl),a		; store result into score second byte
;2a71  5f        ld      e,a		; load E with this value as well
;2a72  23        inc     hl		; next memory for third byte of score
;2a73  3e00      ld      a,#00		; A := #00
;2a75  8e        adc     a,(hl)		; add with carry third byte of score into A.  This will only add a carry bit if needed
;2a76  27        daa     		; decimal adjust
;2a77  77        ld      (hl),a		; store result into third byte of score

		sed
		clc

		lda |0,x           ; Player Score
		adc |ScoreTable,y
		sta |0,x
		sep #$20
		lda |2,x
		adc #0
		sta |2,x
		rep #$30
		cld

;2a78  57        ld      d,a		; load D with A.  DE now has third and second bytes of score
;2a79  eb        ex      de,hl		; exchange DE with HL
		lda |1,x

;2a7a  29        add     hl,hl		; double HL
;2a7b  29        add     hl,hl		; double HL
;2a7c  29        add     hl,hl		; double HL
;2a7d  29        add     hl,hl		; HL now has 16 times what it had before
		asl
		asl
		asl
		asl

		pha

		txy
		iny
		iny

;2a7e  3a714e    ld      a,(#4e71)	; load A with bonus life code
;2a81  3d        dec     a		; decrement
;2a82  bc        cp      h		; compare with H.  Is the players score higher than that needed for extra life?
;2a83  dc332b    call    c,#2b33		; if yes, call sub to continue check for extra life
;2a86  cdaf2a    call    #2aaf		; draw player score onscreen
		jsr :DrawScore
;2a89  13        inc     de		; 
;2a8a  13        inc     de
;2a8b  13        inc     de		; DE now has msb byte of player's score

	; check for high score change
		pla

;2a8c  218a4e    ld      hl,#4e8a	; load HL with msb high score ram area
;2a8f  0603      ld      b,#03		; For B = 1 to 3 digits to check

;2a91  1a        ld      a,(de)		; load a with score digit
;2a92  be        cp      (hl)		; compare to high score digit
;2a93  d8        ret     c		; return if high score not beat

;2a94  2005      jr      nz,#2a9b        ; if they are equal, continue, else update the high score
;2a96  1b        dec     de		; next digit
;2a97  2b        dec     hl		; next digit
;2a98  10f7      djnz    #2a91           ; next B
;2a9a  c9        ret     		; return
		rts

	; arrive when player score beats the current high score

;2a9b  cd0b2b    call    #2b0b		; load HL with score address for current player
;2a9e  11884e    ld      de,#4e88	; load DE with lsb high score memory
;2aa1  010300    ld      bc,#0003	; counter  = 3 bytes
;2aa4  edb0      ldir    		; copy score to high score
;2aa6  1b        dec     de		; DE now has high score
;2aa7  010403    ld      bc,#0304	; set up counters
;2aaa  21f243    ld      hl,#43f2	; load HL with start of screen memory for high score
;2aad  180f      jr      #2abe           ; draw high score to screen and return

; called from #2A86
:DrawScore
;2aaf  3a094e    ld      a,(#4e09)	; load A with current player number:  0=P1, 1=P2 
		ldx #tile_ram+$3fc
		lda |player_no
;2ab2  010403    ld      bc,#0304	; load counters
;2ab5  21fc43    ld      hl,#43fc	; screen pos for player 1 score
;2ab8  a7        and     a		; is this player 1 ?
;2ab9  2803      jr      z,#2abe         ; yes, skip ahead
		beq :skip
;2abb  21e943    ld      hl,#43e9	; else load HL with screen pos for player 2 score
		ldx #tile_ram+$3e9
:skip
		lda #$0304
		jmp DrawScore
;------------------------------------------------------------------------------
;2B4A
;  A contains the number of lives on entry here, instead of B
;
DrawExtraLives mx %00
		pha
;2b4a  211a40    ld      hl,#401a	; load HL with start screen location for extra lives
		ldx #tile_ram+$1a
;2b4d  0e05      ld      c,#05		; C := #05.  This counter is used to determine how many blanks to draw
		ldy #5
;2b4f  78        ld      a,b		; load A with B which has number of lives on the screen
;2b50  a7        and     a		; == #00 ?
		lda 1,s
;2b51  280e      jr      z,#2b61         ; yes, skip ahead, nothing to draw
		beq :clear_loop

;2b53  fe06      cp      #06		; >= #06 ?
;2b55  300a      jr      nc,#2b61        ; yes, skip ahead, we can't draw more than 5 extra lives
		cmp #6
		bcs :clear_loop
:draw
;2b57  3e20      ld      a,#20		; A := #20
		lda #$20
;2b59  cd8f2b    call    #2b8f		; draw extra life
		jsr draw4parts

;2b5c  2b        dec     hl		; 
;2b5d  2b        dec     hl		; HL is now 2 less than before.  If another life is to be drawn, it will be in correct location.
		dex
		dex
;2b5e  0d        dec     c		; decrement C 
		dey
		pla
		dec
		pha
;2b5f  10f6      djnz    #2b57           ; Next B
		bne :draw
:clear_loop
;2b61  0d        dec     c		; decrement C.  Are there blank spaces to be drawn next ?
		dey
		bmi :done
;2b62  f8        ret     m		; No, return

;2b63  cd7e2b    call    #2b7e		; Yes, draw blank for the next extra life position
		jsr clear2x2
;2b66  2b        dec     hl		; 
;2b67  2b        dec     hl		; HL is now 2 less for next position if needed
		dex
		dex
;2b68  18f7      jr      #2b61           ; loop again
		bra :clear_loop
:done
		pla
		rts

;------------------------------------------------------------------------------
; #2B6A ; A=1A	; draws remaining lives at bottom of screen
task_drawLives mx %00
;2b6a  3a004e    ld      a,(#4e00)	; load A with game mode
;2b6d  fe01      cp      #01		; == 1 ?  Are we in demo mode?
;2b6f  c8        ret     z		; If yes, return
		lda |mainstate
		cmp #1
		bne :continue
		rts
:continue
;2b70  cdcd2b    call    #2bcd		; colors the bottom two rows of 10 the color 9 (yellow)
;2b73  12 44				; #4412 is starting location for above subroutine
;2B75  09 0A 02				; data used in above subroutine call.  9 is the color, #0A is the length, #02 is the number of rows
		jsr ColorStuff
		da palette_ram+$12
		db $09,$0A,$02

;2b78  21154e    ld      hl,#4e15	; load HL with address of number of lives to display
;2b7b  46        ld      b,(hl)		; load B with number of lives to display
		lda |displayed_lives
;2b7c  18cc      jr      #2b4a           ; draw extra lives on screen and return
;		rts
		bra DrawExtraLives


;------------------------------------------------------------------------------
; Draws colors onscreen for a 2x2 grid.
; It requires that A is loaded with the code for the color,
; and HL is loaded with the memory address of the position on screen where the first color is to be drawn.
; If a clear value is to be drawn, the first address is called (#2B7E). 
; If A is preloaded with a color, then the second address is called (#2B80).
;2B7E
clear2x2 mx %00
;2B7E 3E 40 	LD 	A,#40 		; Used to draw clear value
;2B80 E5 	PUSH 	HL 		; Save HL
;2B81 D5 	PUSH 	DE 		; Save DE
;2B82 77 	LD 	(HL),A 		; Draw color into first part
;2B83 23 	INC 	HL 		; Set location to second part of fruit
;2B84 77 	LD 	(HL),A 		; Draw color into second part
;2B85 11 1F 00 	LD 	DE,#001F 	; Offset is used for third part
;2B88 19 	ADD 	HL,DE 		; Set location to third part of fruit
;2B89 77 	LD 	(HL),A 		; Draw color into third part
;2B8A 23 	INC 	HL 		; Set location to fourth part of fruit
;2B8B 77 	LD 	(HL),A 		; Draw color into fourth part
;2B8C D1 	POP 	DE 		; Restore DE
;2B8D E1 	POP 	HL 		; Restore HL
;2B8E C9 	RET 			; Return
		lda #$4040
clear2x22
		sta |0,x
		sta |32,x
		rts
;------------------------------------------------------------------------------
; Draws the four parts of a fruit onscreen.  Also used to draw extra pac man lives at bottom of screen.
; It requires that A is loaded with the code for the first part of the fruit,
; and HL is loaded with the memory address of the first position on screen where it is to be drawn.
;2B8F
draw4parts mx %00
		sep #$20
;2B8F E5 	PUSH 	HL 		; Save HL
;2B90 D5 	PUSH 	DE 		; Save DE
;2B91 11 1F 00 	LD 	DE,#001F 	; this offset is added later for third part of fruit 
;2B94 77 	LD 	(HL),A 		; Draw first part of fruit code into screen memory
		sta |0,x
;2B95 3C 	INC 	A 		; Point to second part of fruit
		inc
;2B96 23 	INC 	HL 		; Increment screen memory for second part of fruit
;2B97 77 	LD 	(HL),A 		; Draw second part of fruit code into screen memory
		sta |1,x
;2B98 3C 	INC 	A 		; Point to third part of fruit
		inc
;2B99 19 	ADD 	HL,DE 		; Add offset for third part of fruit
;2B9A 77 	LD 	(HL),A 		; Draw third part of fruit code into screen memory
		sta |$20,x
;2B9B 3C 	INC 	A 		; Point to fourth part of fruit
		inc
;2B9C 23 	INC 	HL 		; Increment screen memory for fourth part of fruit
;2B9D 77 	LD 	(HL),A 		; Draw fourth part of fruit code into screen memory
		sta |$21,x
;2B9E D1 	POP 	DE 		; Restore DE
;2B9F E1 	POP 	HL 		; Restore HL
		rep #$30
;2BA0 C9 	RET 			; Return     
		rts
;------------------------------------------------------------------------------

; this subroutine takes 5 bytes after the call and uses them to copy the 3rd byte into several memories
; first 2 bytes are the initial address to copy into 
; called from #2B70 to color the bottom area yellow where extra lives are drawn
ColorStuff mx %00
:fill_value   = temp0
:length_value = temp0+2
:row_count    = temp1
;2bcd  e1        pop     hl		; load HL with address of next data byte in code
		plx
;2bce  5e        ld      e,(hl)		; load E with first byte.  MSB of address to use
;2bcf  23        inc     hl		; next adddress
;2bd0  56        ld      d,(hl)		; load D with second byte.  LSB of address to use
;2bd1  23        inc     hl		; next address
		ldy |1,x		 	; Target Address in Y
;2bd2  4e        ld      c,(hl)		; load C with third byte.  used for data to put into these memories
;2bd3  23        inc     hl		; next address
		lda |3,x
		and #$00FF
		sta <:fill_value

;2bd4  46        ld      b,(hl)		; load B with fourth byte ... used for loop counter
;2bd5  23        inc     hl		; next address
		lda |4,x
		and #$00FF
		sta <:length_value

;2bd6  7e        ld      a,(hl)		; load A with fifth byte.  used for secondary loop counter
;2bd7  23        inc     hl		; next address
		lda |5,x
		and #$00FF
		sta <:row_count
		clc
		txa
		adc #5
;2bd8  e5        push    hl		; push to stack for return address when done
		pha

;2bd9  eb        ex      de,hl		; move DE into HL
;2bda  112000    ld      de,#0020	; load DE with offset value of #20

;2bdd  e5        push    hl		; save HL
;2bde  c5        push    bc		; save BC

;2bdf  71        ld      (hl),c		; store data into memory
;2be0  23        inc     hl		; next address
;2be1  10fc      djnz    #2bdf           ; Next B

;2be3  c1        pop     bc		; restore BC
;2be4  e1        pop     hl		; restore HL
;2be5  19        add     hl,de		; add offset (#20)
;2be6  3d        dec     a		; decrease counter.  are we done ?
;2be7  20f4      jr      nz,#2bdd        ; No, loop again
]outloop
		sep #$20
		ldx <:length_value
		lda <:fill_value
		phy
]inloop
		sta |0,y
		iny
		dex
		bne ]inloop

		rep #$31
		pla
		adc #$20
		tay
		dec <:row_count
		bne ]outloop

;2be9  c9        ret     		; return
		rts

;------------------------------------------------------------------------------
; #2BEA ; A=1B	; draws fruit at bottom right of screen
task_drawFruit mx %00
;2bea  3a004e    ld      a,(#4e00)	; load A with game mode
;2bed  fe01      cp      #01		; is this the attract mode ?
;2bef  c8        ret     z		; yes, return
		lda |mainstate
		cmp #1
		bne :not_demo
; demo mode, return early
		rts
:not_demo
	;; draw the fruit

;2bf0  3a134e    ld      a,(#4e13)	; else Load A with current board level
;2bf3  3c        inc     a		; increment it
		lda |level
		inc

; jumped from #2BF4 for fruit drawing subroutine
; A has the level number
; keeps the fruit level at banana after level 7

;8793 FE 08 	CP 	#08 		; Is Level >= #08 ?
;8795 DA F9 2B 	JP 	C,#2BF9 	; No, return
		cmp #8
		bcc :continue

;8798 3E 07 	LD 	A,#07 		; Yes, set A := #07
;879A C3 F9 2B 	JP 	#2BF9 		; Return
		lda #7

:continue
		pei <temp0
		pei <temp0+2
:temp  = temp0
:pFruit = temp0+2

		pha

		lda #data_fruit_table
		sta <:pFruit

;2BF9 11083B	LD	DE,#3B08 	; Yes, load DE with address of cherry in fruit table
;2BFC 47 	LD	B,A 		; For B = 1 to level number
;2BFD 0E07 	LD	C,#07 		; C is 7 = the total number of locations to draw
		ldy #7
;2BFF 210440 	LD	HL,#4004 	; Load HL with the start of video memory
		ldx #tile_ram+$4
;2C02 1A 	LD	A,(DE) 		; Load A with value from fruit table
;2C03 CD8F2B 	CALL	#2B8F 		; Draw fruit subroutine
]lp
		lda (:pFruit)
		jsr draw4parts

;2C06 3E04 	LD	A,#04 		; 
;2C08 84 	ADD	A,H 		; Add 400 to HL
;2C09 67 	LD	H,A 		; HL now points to color memory
;2C0A 13 	INC	DE 		; DE now points to color code in fruit table
;2C0B 1A 	LD	A,(DE) 		; Load A with color code from fruit table
;2C0C CD802B 	CALL	#2B80 		; Draw color subroutine
		phx
		clc
		txa
		adc #$400
		tax
		inc <:pFruit
		lda (:pFruit)
		and #$FF
		sta <:temp
		xba
		ora <:temp
		jsr clear2x22
;2C0F 3EFC 	LD	A,#FC 		; 
;2C11 84 	ADD	A,H 		; Subtract 4 from H
;2C12 67 	LD	H,A 		; HL now points back to video memory
		plx
;2C13 13 	INC	DE 		; Increase pointer to next fruit in table
		inc <:pFruit
;2C14 23 	INC	HL 		; 
;2C15 23 	INC	HL 		; Next starting point is 2 bytes higher
		inx
		inx
;2C16 0D 	DEC	C 		; Count down how many clears to draw
		dey
;2C17 10E9 	DJNZ	#2C02 		; Next B � loop back and draw next fruit
		pla
		dec
		pha
		bne ]lp
]clear_lp
;2C19 0D 	DEC	C 		; Count down C. Did C just turn negative?
;2C1A F8 	RET	M 		; Yes, return to game, we are done
		dey
		bmi :done

;2C1B CD7E2B 	CALL	#2B7E 		; No, call subroutine to draw a clear
		jsr clear2x2
;2C1E 3E04 	LD	A,#04 		; 
;2C20 84 	ADD	A,H 		;
;2C21 67 	LD	H,A 		; Increase HL by 400 for color value to be cleared
		phx
		clc
		txa
		adc #$400
		tax
;2C22 AF 	XOR	A 		; Load A with 0, the code for black color
		lda #$0000
;2C23 CD802B 	CALL	#2B80 		; Draw color subroutine � draws black color
		jsr clear2x22
;2C26 3EFC 	LD	A,#FC 		; 
;2C28 84 	ADD	A,H 		; Subtract 4 from H
;2C29 67 	LD	H,A 		; HL now points back to video memory
		plx
;2C2A 23 	INC	HL 		;
;2C2B 23 	INC	HL 		; Set next starting point to be 2 bytes more
		inx
		inx
;2C2C 18EB 	JR	#2C19 		; Jump back and draw next clear
		bra ]clear_lp
:done
		pla
		pla
		sta <temp0+2
		pla
		sta <temp0

		rts

;3B08
data_fruit_table
	db $90,$14				; cherry
	db $94,$0F				; strawberry
	db $98,$15				; peach
	db $9C,$07				; pretzel
	db $A0,$14				; apple
	db $A4,$17				; pear
	db $A8,$16				; banana
	db $AC,$16				; key (unused in ms. pac)
	db $00,$00,$00,$00,$00,$00,$00,$00		; unused
	db $00,$00,$00,$00,$00,$00,$00,$00		; unused
	db $00,$00,$9C,$16,$9C,$16,$9C,$16		; unused, pretzels


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
		phy
		jsr	draw_logo_text 
		ply
;95fb  e1        pop     hl		; restore HL
;95fc  c1        pop     bc		; resore BC

	; check for dip switch settings if there are extra lives awarded

;95fd  3a8050    ld      a,(#5080)	; load A with Dip switches
		lda |DSW1
;9600  e630      and     #30		; mask bits
		and #$30
;9602  fe30      cp      #30		; are bits 4 and 5 on ?   This happens when there is no bonus life awarded.
	    tax
		tya
		cpx #$30
;9604  78        ld      a,b		; A := B
;		tya
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
		phy
		phx

;960d  211696    ld      hl,#9616	; load HL with start of table data
		ldx #:mspac_gr_table
;9610  cd2796    call    #9627		; draws the MS PAC MAN graphic which appears between "ADDITIONAL" and "AT 10,000 pts" 
		jsr draw_table
;9613  e1        pop     hl		; restore HL
;9614  c1        pop     bc		; restore BC
		plx
		ply
;9615  c9        ret     		; return
		rts

	; table data, used in sub below to draw MS PAC graphic
	; first byte is color, 2nd byte is graphic code, third & fourth are screen locations
:mspac_gr_table

;9616  09 20 f5 41 			; screen location #41F5
	db $09,$20
	dw tile_ram+$1F5

;961a  09 21 15 42			; screen location #4215
	db $09,$21
	dw tile_ram+$215

;961e  09 22 f6 41 			; screen location #41F6
	db $09,$22
	dw tile_ram+$1F6

;9622  09 23 16 42 			; screen location #4216
	db $09,$23
	dw tile_ram+$216

;9626  ff
	db $ff,$ff

	; subroutine for start button press
	; called from #9610
	; draws the MS PAC MAN which appears between "ADDITIONAL" and "AT 10,000 pts"
draw_table mx %00
;9627  7e        ld      a,(hl)		; load A with table data
]loop
		lda |0,x	 ; $TTCC  ; Tile #, Color#
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
		ldy |2,x                    ; y is the RAM address
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
task_drawExtraLife mx %00
;26b2  dd213641  ld      ix,#4136	; load IX with screen position
		ldx #$136
		sep #$20
;26b6  3a714e    ld      a,(#4e71)	; load A with points needed for bonus life (#10, #15, #20 or #FF)
		lda |bonus_life
;26b9  e60f      and     #0f		; mask out left digit bits
		and #$0F
;26bb  c630      add     a,#30		; add #30, gives ascii code for this digit
		clc
		adc #$30
;26bd  dd7700    ld      (ix+#00),a	; write digit to screen
		sta |tile_ram,x
;26c0  3a714e    ld      a,(#4e71)	; load A with points needed for bonus life (#10, #15, #20 or #FF) 
		lda |bonus_life
;26c3  0f        rrca    
;26c4  0f        rrca    
;26c5  0f        rrca    
;26c6  0f        rrca    		; rotate right 4 times.  A now has the tens digit
		lsr
		lsr
		lsr
		lsr
;26c7  e60f      and     #0f		; mask out left digit bits
		and #$0F
;26c9  c8        ret     z		; return if zero (when would this happen?)
		beq :skip
;26ca  c630      add     a,#30		; add #30, gives ascii code for this digit
;26cc  dd7720    ld      (ix+#20),a	; write digit to screen
		clc
		adc #$30
		sta |tile_ram+$20,x
:skip
		rep #$30
;26cf  c9        ret     		; return
		rts

;------------------------------------------------------------------------------
; called from routines above with HL loaded with ghost position and A loaded with ghost direction
; used when ghosts are blue (edible)
; load A with new direction, and HL with tile offset for this direction
; Input X = hl ; pTile
;       A = A  ; dir
;
; output X = hl  ; tchange
;        A = A   ; dir
;291e
runAwayGhost mx %00
;291e  223e4d    ld      (#4d3e),hl	; store HL into current tile position
		stx |save_current_tile
;2921  ee02      xor     #02		; reverse ghost direction
		eor #$02
;2923  323d4d    ld      (#4d3d),a	; store into the opposite orientation
		sta |opposite_orientation
;2926  cd232a    call    #2a23		; load A with a pseudo random number
		jsr ROMRANDOM
;2929  e603      and     #03		; mask bits, now between 0 and 3
		and #03
;292b  213b4d    ld      hl,#4d3b	; load HL with best orientation found address
;292e  77        ld      (hl),a		; store the random direction
		sta |best_orientation
;292f  87        add     a,a		; A := A * 2
;2930  5f        ld      e,a		; store into E
;2931  1600      ld      d,#00		; D := #00.  DE now has #000X where X is 2 * direction
;2933  dd21ff32  ld      ix,#32ff	; load IX with data - tile differences tables for movements
;2937  dd19      add     ix,de		; IX now has the tile difference address
		asl
		adc #tile_move_table
		tax
;2939  fd213e4d  ld      iy,#4d3e	; load IY with current tile position
:try_again
		ldy #save_current_tile
;293d  3a3d4d    ld      a,(#4d3d)	; load A with opposite direction
;2940  be        cp      (hl)		; is the random direction == opposite direction ?
;2941  ca5729    jp      z,#2957		; yes, skip ahead to choose a new direction
		lda |opposite_orientation
		cmp |best_orientation
		beq :new_direction

;2944  cd0f20    call    #200f		; no, load A with the character in the destination screen position
		phx
		jsr screen_xy
		plx
;2947  e6c0      and     #c0		; mask bits
;2949  d6c0      sub     #c0		; subtract. is there a wall in the way of this direction ?
;294b  280a      jr      z,#2957		; yes, choose a new direction and try again
		and #$C0
		cmp #$C0
		beq :new_direction	; blocked by maze choose a new direction

;294d  dd6e00    ld      l,(ix+#00)	; no, load L with tile offset low byte
;2950  dd6601    ld      h,(ix+#01)	; load H with tile offset high byte
		lda |0,x
		tax
;2953  3a3b4d    ld      a,(#4d3b)	; load A with new direction
		lda |best_orientation
;2956  c9        ret			; return
		rts

; arrive here from #2941 when random direction == opposite direction, or a wall is in the way of the direction computed
:new_direction
;2957  dd23      inc     ix		; 
;2959  dd23      inc     ix		; next direction tile
		inx
		inx
;295b  213b4d    ld      hl,#4d3b	; load HL with best orientation found address
;295e  7e        ld      a,(hl)		; load A with the random direction
;295f  3c        inc     a		; increase
;2960  e603      and     #03		; mask bits to make between #00 and #03, in case #04 was reached it will revert to #00
;2962  77        ld      (hl),a		; store into new random direction
		lda |best_orientation
		inc
		and #03
		sta |best_orientation

;2963  c33d29    jp      #293d		; jump back
		bra :try_again    	; y not preserved, so go back a little further


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

		; need to check to see if the direction is allowed
		; by checking the maze
;298f  cd0020    call    #2000		; no, HL := (IX) + (IY)
		jsr double_add
;2992  22424d    ld      (#4d42),hl	; store into temp position
		sta |temp_position

;2995  cd6500    call    #0065		; convert to screen position
		jsr yx_to_screen

;2998  7e        ld      a,(hl)		; load A with the character in the new position
		sta <temp0
		lda (temp0)

;2999  e6c0      and     #c0		; mask bits
		and #$C0
		cmp #$C0
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
		;bcc :result_is_good
		bpl :result_is_good
		rep #$30

		;eor #$FF
		;inc
		ora #$FF00

:result_is_good
		rep #$30
		jsr squareA
		pha				; save result for later, since we're summing
		lda #0			; clear B
		sep #$21		; short a, c=1
		lda |1,x		; pac x
		sbc |1,y 		; minus ghost x
		;bcc :good
		bpl :good
		rep #$30

		;eor #$FF  		; negate
		;inc
		ora #$FF00
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
		sta <SIGNED_MULT_A_LO
		sta <SIGNED_MULT_B_LO
		lda <SIGNED_MULT_AL_LO
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
