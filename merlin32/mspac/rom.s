;
;  Compressed Image Data
;
        rel     ; relocatable
        lnk     rom.l

        mx %00

;-------------------------------------------------------------------------------

tile_rom ent             ; 8x8 Tile ROM
	putbin data\rom\5e

sprite_rom ent  	  	   ; 16x16 Sprite ROM
    putbin data\rom\5f

color_rom ent
	putbin data\rom\82s123.7f

palette_rom ent
	putbin data\rom\82s126.4a

sound_rom1 ent
	putbin data\rom\82s126.1m

sound_rom2 ent
	putbin data\rom\82s126.3m













