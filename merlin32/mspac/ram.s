;------------------------------------------------------------------------------
;
; MsPacman VRAM
;
;------------------------------------------------------------------------------
;
; RAM Shadow, represents actual video hardware in Pacman Arcade machine
;

; - align to 256 bytes  $$TODO put in a macro
;]futz = *
;		ds {{{]futz+$100}&$FF00}-]futz}
; - align to 256 bytes
; $4000
tile_ram    ds 1024
; $4400
palette_ram ds 1024

;
; MsPacman RAM
;

redghostsprite		db 0	;	4c02	red ghost sprite number
redghostcolor		db 0	;	4c03	red ghost color entry
pinkghostsprite		db 0	;	4c04	pink ghost sprite number
pinkghostcolor		db 0	;	4c05	pink ghost color entry
blueghostsprite 	db 0	;	4c06	blue ghost sprite number
blueghostcolor		db 0	;	4c07	blue ghost color entry
orangeghostsprite	db 0	;	4c08	orange ghost sprite number
orangeghostcolor	db 0	;	4c09	orange ghost color entry
pacmansprite		db 0	;	4c0a	pacman sprite number
pacmancolor			db 0	;	4c0b	pacman color entry
fruitsprite			db 0	;	4c0c	fruit sprite number
fruitspritecolor	db 0	;	4c0d	fruit sprite entry

;	4c20	sprite data that goes to the hardware sprite system
;
;	4c22-4c2f sprite positions for spriteram2
;	4c32-4c3f sprite number and color for spriteram
;	
;	4C40-4C41 used for moving fruit positions
; 	4C42-4C43 used to hold address of the fruit path
;	4c44-4c7f unused/unknown
;
; Tasks and Timers
;
;	4c80	\ pointer to the end of the tasks list
;	4c81	/
;	4c82	\ pointer to the beginning of the tasks list
;	4c83	/
;	4c84	8 bit counter (0x00 to 0xff) used by sound routines
;	4c85	8 bit counter (0xff to 0x00) (unused)
;	4c86	counter 0: 0..5 10..15 20..25  ..  90..95 - hundreths
;	4c87	counter 1: 0..9 10..19 20..29  ..  50..59 - seconds
;	4c88	counter 2: 0..9 10..19 20..29  ..  50..59 - minutes
;	4c89	counter 3: 0..9 10..19 20..29  ..  90..99 - hours
;
;	4c8a	number of counter limits changes in this frame (to init time)
;		0x01	1 hundredth
;		0x02	10 hundredths
;		0x03	1 second
;		0x04	10 seconds
;		0x05	1 minute
;		0x06	10 minutes
;		0x07	1 hour
;		0x08	10 hours
;		0x09	100 hours
;	4c8b	random number generation (unused)
;	4c8c	random number generation (unused)
;
;	4c90-4cbf scheduled tasks list (run inside IRQ)
;		16 entries, 3 bytes per entry
;		Format:
;		byte 0: scheduled time
;                        7 6 5 4 3 2 1 0
;                        | | | | | | | |
;                        | | ------------ number of time units to wait
;                        | |
;                        ---------------- time units
;                                                0x40 -> 10 hundredths
;                                                0x80 -> 1 second
;                                                0xc0 -> 10 seconds
;		byte 1: index for the jump table
;		byte 2: parameter for b
;		these tasks are assigned using RST #30, with the three data bytes immediatly after the call used for the timer, index and parameter
;		these tasks are decoded at routine starting at #0221		
;
;	4cc0-4ccf tasks to execute outside of IRQ
;		0xFF fill for empty task
;		16 entries, 2 bytes per entry
;		Format:
;		byte 0: routine number
;		byte 1: parameter
;		these tasks are assigned using RST #28, with the two data bytes immedately after the call used for the routine number and parameter
;		alternately, tasks can be assigned by manually loading B and C with routine and parameter, and then executing call #0042
;		tasks are decoded at routine starting at #238D
;
; Game variables
; ** note - need to be sorted
;
;   4DD2    FRUITP  fruit position
;   4DD4    FVALUE  value of the current fruit (0=no fruit)
;   4C40    COUNT current place in fruit path
;   4E0C    FIRSTF  flag to indicate that first fruit has been released
;   4E0D    SECONDF flag to indicate that second fruit has been eaten
;   4C41    BCNT    current place within bounce
;   4C42    PATH    pointer to the path the fruit is currently following
;   4E0E    DOTSEAT how many dots the current player has eaten
;   4EBC    BNOISE  set bit 5 of BNOISE to make the bounce sound

;	4d00	red ghost Y position (bottom to top = decreases)
;	4d01	red ghost X position (left to right = decreases)
;	4d02	pink ghost Y position (bottom to top = decreases)
;	4d03	pink ghost X position (left to right = decreases)
;	4d04	blue ghost Y position (bottom to top = decreases)
;	4d05	blue ghost X position (left to right = decreases)
;	4d06	orange ghost Y position (bottom to top = decreases)
;	4d07	orange ghost X position (left to right = decreases)
;
;	4d08	pacman Y position
;	4d09	pacman X position
;
;	4d0a	red ghost Y tile pos (mid of tile) (bottom to top = decrease)
;	4d0b	red ghost X tile pos (mid of tile) (left to right = decrease)
;	4d0c	pink ghost Y tile pos (mid of tile) (bottom to top = decrease)
;	4d0d	pink ghost X tile pos (mid of tile) (left to right = decrease)
;	4d0e	blue ghost Y tile pos (mid of tile) (bottom to top = decrease)
;	4d0f	blue ghost X tile pos (mid of tile) (left to right = decrease)
;	4d10	orange ghost Y tile pos (mid of tile) (bottom to top = decrease)
;	4d11	orange ghost X tile pos (mid of tile) (left to right = decrease)
;	4d12	pacman tile pos in demo and cut scenes
;	4d13	pacman tile pos in demo and cut scenes
;
;	for the following, last move was 
;		(A) 0x00 = left/right, 0x01 = down, 0xff = up
;		(B) 0x00 = up/down, 0x01 = left, 0xff = right
;	4d14	red ghost Y tile changes (A)
;	4d15	red ghost X tile changes (B)
;	4d16	pink ghost Y tile changes (A)
;	4d17	pink ghost X tile changes (B)
;	4d18	blue ghost Y tile changes (A)
;	4d19	blue ghost X tile changes (B)
;	4d1a	orange ghost Y tile changes (A)
;	4d1b	orange ghost X tile changes (B)
;	4d1c	pacman Y tile changes (A)
;	4d1d	pacman X tile changes (B)
;
;	4d1e	red ghost y tile changes
;	4d1f	red ghost x tile changes
;	4d20	pink ghost y tile changes
;	4d21	pink ghost x tile changes
;	4d22	blue ghost y tile changes
;	4d23	blue ghost x tile changes
;	4d24	orange ghost y tile changes
;	4d25	orange ghost x tile changes
;	4d26	wanted pacman tile changes
;	4d27	wanted pacman tile changes
;
;		character orientations:
;		0 = right, 1 = down, 2 = left, 3 = up
;	4d28	previous red ghost orientation (stored middle of movement)
;	4d29	previous pink ghost orientation (stored middle of movement)
;	4d2a	previous blue ghost orientation (stored middle of movement)
;	4d2b	previous orange ghost orientation (stored middle of movement)
;	4d2c	red ghost orientation (stored middle of movement)
;	4d2d	pink ghost orientation (stored middle of movement)
;	4d2e	blue ghost orientation (stored middle of movement)
;	4d2f	orange ghost orientation (stored middle of movement)
;
;	4d30	pacman orientation
;
;		these are updated after a move
;	4d31	red ghost Y tile position 2 (See 4d0a)
;	4d32	red ghost X tile position 2 (See 4d0b)
;	4d33	pink ghost Y tile position 2
;	4d34	pink ghost X tile position 2
;	4d35	blue ghost Y tile position 2
;	4d36	blue ghost X tile position 2
;	4d37	orange ghost Y tile position 2
;	4d38	orange ghost X tile position 2
;
;	4d39	pacman Y tile position (0x22..0x3e) (bottom-top = decrease)
;	4d3a	pacman X tile position (0x1e..0x3d) (left-right = decrease)
;
;	4d3c	wanted pacman orientation
;
;	path finding algorithm:
;	4d3b		best orientation found 
;	4d3d		saves the opposite orientation
;	4d3e-4d3f 	saves the current tile position
;	4d40-4d41 	saves the destination tile position
;	4d42-4d43 	temp resulting position
;	4d44-4d45 	minimum distance^2 found
;
;	4dc7		current orientation we're trying
;	4d46-4d85 	speed bit patterns (difficulty dependant)
;	4D46-4D49       speed bit patterns for pacman in normal state
;	4D4A-4D4D       speed bit patterns for pacman in big pill state
;	4D4E-4D51       speed bit patterns for second difficulty flag
;	4D52-4D55       speed bit patterns for first difficulty flag
;	4D56-4D59       speed bit patterns for red ghost normal state
;	4D5A-4D5D       speed bit patterns for red ghost blue state
;	4D5E-4D61       speed bit patterns for red ghost tunnel areas
;	4D62-4D65       speed bit patterns for pink ghost normal state
;	4D66-4D69       speed bit patterns for pink ghost blue state
;	4D6A-4D6D       speed bit patterns for pink ghost tunnel areas
;	4D6E-4D71       speed bit patterns for blue ghost normal state
;	4D72-4D75       speed bit patterns for blue ghost blue state
;	4D76-4D79       speed bit patterns for blue ghost tunnel areas
;	4D7A-4D7D       speed bit patterns for orange ghost normal state
;	4D7E-4D81       speed bit patterns for orange ghost blue state
;	4D82-4D83       speed bit patterns for orange ghost tunnel areas
;
;	4d86-4d93
;	    Difficulty related table. Each entry is 2 bytes, and
;	    contains a counter value.  when the counter at 4DC2
;	    reaches each entry value, the ghosts changes their
;	    orientation and 4DC1 increments it's value to point to
;	    the next entry
;
;	4d94	counter related to ghost movement inside home
;	4d95-4d96 number of units before ghost leaves home (no change w/ pills)
;	4d97-4d98 inactivity counter for units of the above
;
;	4d99 - 4d9c
;	    These values are normally 0, but are changed to 1 when a ghost has
;	    entered a tunnel slowdown area
;	4d99	aux var used by red ghost to check positions
;	4d9a	aux var used by pink ghost to check positions
;	4d9b	aux var used by blue ghost to check positions
;	4d9c	aux var used by orange ghost to check positions
;
;	4d9d	delay to update pacman movement
;		not 0xff - the game doesn't move pacman, but decrements instead
;		0x01	when eating pill
;		0x06	when eating big pill
;		0xff	when not eating a pill
;	4d9e	related to number of pills eaten before last pacman move
;	4d9f	eaten pills counter after pacman has died in a level
;		used to make ghosts go out of home after # pills eaten
;
;		ghost substates:
;		0 = at home
;		1 = going for pac-man
;		2 = crossing the door
;		3 = going to the door
;
;	4da0	red ghost substate (if alive)
;	4da1	pink ghost substate (if alive)
;	4da2	blue ghost substate (if alive)
;	4da3	orange ghost substate (if alive)
;	4da4	# of ghost killed but no collision for yet [0..4]
;	4da5	pacman dead animation state (0 if not dead)
;	4da6	power pill effect (1=active, 0=no effect)
;
;	4da7	red ghost blue flag (0=not blue)
;	4da8	pink ghost blue flag (0=not blue)
;	4da9	blue ghost blue flag (0=not blue)
;	4daa	orange ghost blue flag (0=not blue)
;
;	4dab	killing ghost state
;		0 = nothing
;		1 = kill red ghost
;		2 = kill pink ghost
;		3 = kill blue ghost
;		4 = kill orange ghost
;
;		ghost states:
;		0 = alive
;		1 = dead
;		2 = entering home after being killed
;		3 = go left after entering home after dead (blue)
;		3 = go right after entering home after dead (orange)
;	4dac	red ghost state
;	4dad	pink ghost state
;	4dae	blue ghost state
;	4daf	orange ghost state
;
;	4db0	related to difficulty, appears to be unused 
;
;		with these, if they're set, ghosts change orientation
;	4db1	red ghost change orientation flag
;	4db2	pink ghost change orientation flag
;	4db3	blue ghost change orientation flag
;	4db4	orange ghost change orientation flag
;	4bd5	pacman change orientation flag
;
; Difficulty settings
;
;	4db6	1st difficulty flag (rel 4dbb) (cruise elroy 1)
;		0: red ghost goes to upper right corner on scatter
;		1: red ghost goes for pacman on scatter
;		1: red ghost goes faster
;	4db7	2nd difficulty flag (rel 4dbc) (cruise elroy 2)
;		when set, red uses a faster bit speed pattern
;		0: not set
;		1: faster movement
;	4db8	pink ghost counter to go out of home limit (rel 4e0f)
;	4db9	blue ghost counter to go out of home limit (rel 4e10)
;	4dba	orange ghost counter to go out of home limit (rel 4e11)
;	4dbb	remainder of pills when first diff. flag is set (cruise elroy 1)
;	4dbc	remainder of pills when second diff. flag is set (cruise elroy 2)
;	4dbd-4dbe Time the ghosts stay blue when pacman eats a big pill
;
;	4dbf	1=pacman about to enter a tunnel, otherwise 0
;
; Counters
;
;	4dc0	changes every 8 frames; used for ghost animations
;	4dc1	orientation changes index [0..7]. used to get value 4d86-4d93
;		0: random ghost movement, 1: normal movement (?)
;	4dc2-4dc3 counter related to ghost orientation changes
;	4dc4	counter 0..8 to handle things once every 8 times
;	4dc5-4dc6 counter started after pacman killed
; 	4dc7	counter for current orientation we're trying
;	4dc8	counter used to change ghost colors under big pill effects
;
;	4dc9-4dca pointer to pick a random value from the ROM (routine 2a23)
;
;	4dcb-4dcc counter while ghosts are blue. effect ceases at 0
;	4dce	counter started after insert coin (LED and 1UP/2UP blink)
;	4dcf	counter to handle power pill flashes
;	4dd0	current number of killed ghosts (0..4)	(rel 4da5)
;
;	4dd1	killed ghost animation state
;		if 4da4 != 0:
;			4dd1 = 0: killed, showing points per kill
;			4dd1 = 1: wating
;			4dd1 = 2: clearing killed ghost, changing state to 0
;	4dd2-4dd3 fruit position (sometimes for other sprite)
;
;	4dd4	entry to fruit points or 0 if no fruit
;	4dd6	used for LED state( 1: game waits for 1P/2P start button press)
;
; Main States
;
;	4e00	main routine number
;		0: init
;		1: demo
;		2: coin inserted
;		3: playing
;	4e01	main routine 0, subroutine #
;	4e02	main routine 1, subroutine # (related to blue maze bug)
;	4e03	main routine 2, subroutine #
;	4e04	level state subroutine #
;		3=ghost move, 2=ghost wait for start
;		(set to 2 to pause game)
;
;	4e06	state in first cutscene (pac-man only)
;	4e07	state in second cutscene (pac-man only)
;	4e08	state in third cutscene (pac-man only)
;
;	4e09	current player number:  0=P1, 1=P2
;
;	4e0a-4e0b pointer to current difficulty settings
;
;	4C40	COUNT current place in fruit path
;	4E0C	FIRSTF  flag to indicate that first fruit has been released
;	4E0D	SECONDF flag to indicate that second fruit has been eaten
;	4C41	BCNT	current place within bounce
;	4C42	PATH	pointer to the path the fruit is currently following
;	4E0E	DOTSEAT	how many dots the current player has eaten
;	4EBC	BNOISE	set bit 5 of BNOISE to make the bounce sound
;
;	4e0c	first fruit flag (1 if fruit has appeared)
;	4e0d	second fruit flag (1 if fruit has appeared)
;	4e0e	number of pills eaten in this level
;	4e0f	counter incremented if orange, blue and pink ghosts are home
;		and pacman is eating pills.
;		used to make pink ghost leave home (rel 4db8)
;	4e10	counter incremented if orange, blue and pink ghosts are home
;		and pacman is eating pills.
;		used to make blue ghost leave home (rel 4db9)
;	4e11	counter incremented if orange, blue and pink ghosts are home
;		and pacman is eating pills.
;		used to make orange ghost leave home (rel 4db9)
;	4e12	1 after dying in a level, reset to 0 if ghosts have left home
;		because of 4d9f
;
;------------------------------------------------------------------------------
; Game Variables
;
level dw 0	; 4e13 - current level

;	4e14	real number of lives
;	4e15	number of lives displayed
;
;	4e16-4e33 0x13 pill data entries. each bit means if a pill is there
;		or not (1=yes 0=no)
;		the pills start at upper right corner, go down, then left.
;		first pill is bit 7 of 4e16
pilldata ds 30
;	4e34-4e37 power pills data entries
powerpills ds 4


;	4e38-4e65 copy of level data (430a-4e37)
;
; coins, credits
;
;	4e66	last 4 SERVICE1 to detect transitions
;	4e67	last 4 COIN2 to detect transitions
;	4e68	last 4 COIN1 to detect transitions
;
;	4e69	coin counter (coin->credts, this gets decremented)
;	4e6a	coin counter timeout, used to write coin counters
;
;		these are copied from the dipswitches
;	4e6b	number of coins per credit
;	4e6c	number of coins inserted
;	4e6d	number of credits per coin
;	4e6e	number of credits, 0xff for free play
;	4e6f	number of lives
;	4e70	number of players (0=1 player, 1=2 players)
;	4e71	bonus/life
;		0x10 = 10000	0x15 = 15000
;		0x20 = 20000	0xff = none
;	4e72	cocktail mode (0=no, 1=yes)
;	4e73-4e74 pointer to difficulty settings
;		4e73: 68=normal 7d=hard checked at start of game
;	4e75	ghost names mode (0 or 1)
;
;		SCORE AABBCC
;	4e80-4e82 score P1	80=CC 81=BB 82=CC
;	4e83	P1 got bonus life?  1=yes
;	4e84-4e86 score P2	84=CC 85=BB 86=CC
;	4e87	P2 got bonus life?  1=yes
;	4e88-4e8a high score	88=CC 89=BB 8A=CC
;
; Sound Registers

        ;; these 16 values are copied to the hardware every vblank interrupt.

CH1_FREQ0       EQU     4e8c    ; 20 bits
CH1_FREQ1       EQU     4e8d
CH1_FREQ2       EQU     4e8e
CH1_FREQ3       EQU     4e8f
CH1_FREQ4       EQU     4e90
CH1_VOL         EQU     4e91
CH2_FREQ1       EQU     4e92    ; 16 bits
CH2_FREQ2       EQU     4e93
CH2_FREQ3       EQU     4e94
CH2_FREQ4       EQU     4e95
CH2_VOL         EQU     4e96
CH3_FREQ1       EQU     4e97    ; 16 bits
CH3_FREQ2       EQU     4e98
CH3_FREQ3       EQU     4e99
CH3_FREQ4       EQU     4e9a
CH3_VOL         EQU     4e9b

SOUND_COUNTER   EQU     4c84    ; counter, incremented each VBLANK
                                ; (used to adjust sound volume)

EFFECT_TABLE_1  EQU     3b30    ; channel 1 effects. 8 bytes per effect
EFFECT_TABLE_2  EQU     3b40    ; channel 2 effects. 8 bytes per effect
EFFECT_TABLE_3  EQU     3b80    ; channel 3 effects. 8 bytes per effect

;#if MSPACMAN
;SONG_TABLE_1    EQU     9685    ; channel 1 song table
;SONG_TABLE_2    EQU     967d    ; channel 2 song table
;SONG_TABLE_3    EQU     968d    ; channel 3 song table
;#else
;SONG_TABLE_1    EQU     3bc8
;SONG_TABLE_2    EQU     3bcc
;SONG_TABLE_3    EQU     3bd0
;#endif

CH1_E_NUM       EQU     4e9c    ; effects to play sequentially (bitmask)
CH1_E_1         EQU     4e9d    ; unused
CH1_E_CUR_BIT   EQU     4e9e    ; current effect
CH1_E_TABLE0    EQU     4e9f    ; table of parameters, initially copied from ROM
CH1_E_TABLE1    EQU     4ea0
CH1_E_TABLE2    EQU     4ea1
CH1_E_TABLE3    EQU     4ea2
CH1_E_TABLE4    EQU     4ea3
CH1_E_TABLE5    EQU     4ea4
CH1_E_TABLE6    EQU     4ea5
CH1_E_TABLE7    EQU     4ea6
CH1_E_TYPE      EQU     4ea7
CH1_E_DURATION  EQU     4ea8
CH1_E_DIR       EQU     4ea9
CH1_E_BASE_FREQ EQU     4eaa
CH1_E_VOL       EQU     4eab

; 4EAC repeats the above for channel 2
; 4EBC repeats the above for channel 3

CH1_W_NUM       EQU     4ecc    ; wave to play (bitmask)
CH1_W_1         EQU     4ecd    ; unused
CH1_W_CUR_BIT   EQU     4ece    ; current wave
CH1_W_SEL       EQU     4ecf
CH1_W_4         EQU     4ed0
CH1_W_5         EQU     4ed1
CH1_W_OFFSET1   EQU     4ed2    ; address in ROM to find the next byte
CH1_W_OFFSET2   EQU     4ed3    ; (16 bits)
CH1_W_8         EQU     4ed4
CH1_W_9         EQU     4ed5
CH1_W_A         EQU     4ed6
CH1_W_TYPE      EQU     4ed7
CH1_W_DURATION  EQU     4ed8
CH1_W_DIR       EQU     4ed9
CH1_W_BASE_FREQ EQU     4eda
CH1_W_VOL       EQU     4edb
;
; 4EDC repeats the above for channel 2
; 4EEC repeats the above for channel 3
;
;
; Runtime
;
;	4F00		Is set to 1 during intermissions and parts of the attract mode, otherwise 0
;	4F01-4FBF	Stack
;	4FC0-4FEF	Unused
;	4FF0-4FFF	Sprite RAM



