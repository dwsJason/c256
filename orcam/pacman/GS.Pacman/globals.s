;
;  globals.s
;  GS.Pacman
;
;  Created by Peter Hirschberg on 8/19/21.
;Copyright © 2021 Peter Hirschberg. All rights reserved.
;

        case on


globalData data

	aif FMX>0,.GSONLY

BORDER_COLOR_REGISTER   gequ $e0c034
STATE_REGISTER          gequ $e1c068
SCREEN_ADDR             gequ $012000
SCB_BASE                gequ $e19d00
COLOR_TABLE             gequ $e19e00
KEYBOARD                gequ $e0c000
KEYBOARD_STROBE         gequ $e0c010

VERTICAL_COUNTER        gequ $e0c02e
READ_VBL                gequ $e0c019

.GSONLY

	aif FMX<1,.FMXONLY

SCREEN_ADDR             gequ $002000
SCB_BASE                gequ $009d00
COLOR_TABLE             gequ $009e00

GETCH gequ $001048         ; Get a character from the input channel. A=0 and Carry=1 if no data is wating
INITKEYBOARD GEQU $0010B4

.FMXONLY

FILL_MODE               gequ $20

MAZE_OFFSET_X           gequ 24
MAZE_OFFSET_Y           gequ 16


backupStack dc i4'0'
backupDP dc i4'0'


DIRECTION_RIGHT         gequ 0
DIRECTION_DOWN          gequ 1
DIRECTION_LEFT          gequ 2
DIRECTION_UP            gequ 3
DIRECTION_NONE          gequ 4


reverseDirections anop
                    dc i2'DIRECTION_LEFT'
                    dc i2'DIRECTION_UP'
                    dc i2'DIRECTION_RIGHT'
                    dc i2'DIRECTION_DOWN'
                    dc i2'DIRECTION_NONE'

                    
; global speed tables
                    
speedSteps200 anop
        dc i2'4,4,4,4,4,4,4,4,4' ; 32

speedSteps105 anop
        dc i2'2,3,4,3,3,4,3,3,4' ; 29
        
speedSteps100 anop
        dc i2'2,3,4,2,3,4,3,3,4' ; 28

speedSteps95 anop
        dc i2'2,3,4,2,3,4,2,3,3' ; 26

speedSteps90 anop
        dc i2'2,3,3,2,3,4,2,3,3' ; 25

speedSteps85 anop
        dc i2'2,2,4,2,2,4,2,2,4' ; 24

speedSteps80 anop
        dc i2'2,2,3,2,2,4,2,2,3' ; 22

speedSteps75 anop
        dc i2'2,2,2,2,2,2,2,2,2' ; 16

speedSteps60 anop
        dc i2'1,2,1,2,1,2,1,2,2' ; 14

speedSteps55 anop
        dc i2'1,2,1,2,1,2,1,2,1' ; 13
        
speedSteps50 anop
        dc i2'1,2,1,2,1,2,1,2,1' ; 12

speedSteps45 anop
        dc i2'1,2,1,1,1,2,1,1,1' ; 10

speedSteps40 anop
        dc i2'1,1,1,1,1,1,1,1,1' ; 8
        
                    

; table of precomputed screen row offsets

screenRowOffsets    dc i2'$0000'
                    dc i2'$00a0'
                    dc i2'$0140'
                    dc i2'$01e0'
                    dc i2'$0280'
                    dc i2'$0320'
                    dc i2'$03c0'
                    dc i2'$0460'
                    dc i2'$0500'
                    dc i2'$05a0'
                    dc i2'$0640'
                    dc i2'$06e0'
                    dc i2'$0780'
                    dc i2'$0820'
                    dc i2'$08c0'
                    dc i2'$0960'
                    dc i2'$0a00'
                    dc i2'$0aa0'
                    dc i2'$0b40'
                    dc i2'$0be0'
                    dc i2'$0c80'
                    dc i2'$0d20'
                    dc i2'$0dc0'
                    dc i2'$0e60'
                    dc i2'$0f00'
                    dc i2'$0fa0'
                    dc i2'$1040'
                    dc i2'$10e0'
                    dc i2'$1180'
                    dc i2'$1220'
                    dc i2'$12c0'
                    dc i2'$1360'
                    dc i2'$1400'
                    dc i2'$14a0'
                    dc i2'$1540'
                    dc i2'$15e0'
                    dc i2'$1680'
                    dc i2'$1720'
                    dc i2'$17c0'
                    dc i2'$1860'
                    dc i2'$1900'
                    dc i2'$19a0'
                    dc i2'$1a40'
                    dc i2'$1ae0'
                    dc i2'$1b80'
                    dc i2'$1c20'
                    dc i2'$1cc0'
                    dc i2'$1d60'
                    dc i2'$1e00'
                    dc i2'$1ea0'
                    dc i2'$1f40'
                    dc i2'$1fe0'
                    dc i2'$2080'
                    dc i2'$2120'
                    dc i2'$21c0'
                    dc i2'$2260'
                    dc i2'$2300'
                    dc i2'$23a0'
                    dc i2'$2440'
                    dc i2'$24e0'
                    dc i2'$2580'
                    dc i2'$2620'
                    dc i2'$26c0'
                    dc i2'$2760'
                    dc i2'$2800'
                    dc i2'$28a0'
                    dc i2'$2940'
                    dc i2'$29e0'
                    dc i2'$2a80'
                    dc i2'$2b20'
                    dc i2'$2bc0'
                    dc i2'$2c60'
                    dc i2'$2d00'
                    dc i2'$2da0'
                    dc i2'$2e40'
                    dc i2'$2ee0'
                    dc i2'$2f80'
                    dc i2'$3020'
                    dc i2'$30c0'
                    dc i2'$3160'
                    dc i2'$3200'
                    dc i2'$32a0'
                    dc i2'$3340'
                    dc i2'$33e0'
                    dc i2'$3480'
                    dc i2'$3520'
                    dc i2'$35c0'
                    dc i2'$3660'
                    dc i2'$3700'
                    dc i2'$37a0'
                    dc i2'$3840'
                    dc i2'$38e0'
                    dc i2'$3980'
                    dc i2'$3a20'
                    dc i2'$3ac0'
                    dc i2'$3b60'
                    dc i2'$3c00'
                    dc i2'$3ca0'
                    dc i2'$3d40'
                    dc i2'$3de0'
                    dc i2'$3e80'
                    dc i2'$3f20'
                    dc i2'$3fc0'
                    dc i2'$4060'
                    dc i2'$4100'
                    dc i2'$41a0'
                    dc i2'$4240'
                    dc i2'$42e0'
                    dc i2'$4380'
                    dc i2'$4420'
                    dc i2'$44c0'
                    dc i2'$4560'
                    dc i2'$4600'
                    dc i2'$46a0'
                    dc i2'$4740'
                    dc i2'$47e0'
                    dc i2'$4880'
                    dc i2'$4920'
                    dc i2'$49c0'
                    dc i2'$4a60'
                    dc i2'$4b00'
                    dc i2'$4ba0'
                    dc i2'$4c40'
                    dc i2'$4ce0'
                    dc i2'$4d80'
                    dc i2'$4e20'
                    dc i2'$4ec0'
                    dc i2'$4f60'
                    dc i2'$5000'
                    dc i2'$50a0'
                    dc i2'$5140'
                    dc i2'$51e0'
                    dc i2'$5280'
                    dc i2'$5320'
                    dc i2'$53c0'
                    dc i2'$5460'
                    dc i2'$5500'
                    dc i2'$55a0'
                    dc i2'$5640'
                    dc i2'$56e0'
                    dc i2'$5780'
                    dc i2'$5820'
                    dc i2'$58c0'
                    dc i2'$5960'
                    dc i2'$5a00'
                    dc i2'$5aa0'
                    dc i2'$5b40'
                    dc i2'$5be0'
                    dc i2'$5c80'
                    dc i2'$5d20'
                    dc i2'$5dc0'
                    dc i2'$5e60'
                    dc i2'$5f00'
                    dc i2'$5fa0'
                    dc i2'$6040'
                    dc i2'$60e0'
                    dc i2'$6180'
                    dc i2'$6220'
                    dc i2'$62c0'
                    dc i2'$6360'
                    dc i2'$6400'
                    dc i2'$64a0'
                    dc i2'$6540'
                    dc i2'$65e0'
                    dc i2'$6680'
                    dc i2'$6720'
                    dc i2'$67c0'
                    dc i2'$6860'
                    dc i2'$6900'
                    dc i2'$69a0'
                    dc i2'$6a40'
                    dc i2'$6ae0'
                    dc i2'$6b80'
                    dc i2'$6c20'
                    dc i2'$6cc0'
                    dc i2'$6d60'
                    dc i2'$6e00'
                    dc i2'$6ea0'
                    dc i2'$6f40'
                    dc i2'$6fe0'
                    dc i2'$7080'
                    dc i2'$7120'
                    dc i2'$71c0'
                    dc i2'$7260'
                    dc i2'$7300'
                    dc i2'$73a0'
                    dc i2'$7440'
                    dc i2'$74e0'
                    dc i2'$7580'
                    dc i2'$7620'
                    dc i2'$76c0'
                    dc i2'$7760'
                    dc i2'$7800'
                    dc i2'$78a0'
                    dc i2'$7940'
                    dc i2'$79e0'
                    dc i2'$7a80'
                    dc i2'$7b20'
                    dc i2'$7bc0'
                    dc i2'$7c60'


        end