;
;  Compressed Image Data
;
        rel     ; relocatable
        lnk     rom.l

        mx %00

;-------------------------------------------------------------------------------

rom_5e ent             ; 8x8 Tile ROM
	putbin data\rom\5e

rom_5f ent  	  	   ; 16x16 Sprite ROM
    putbin data\rom\5f











