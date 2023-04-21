;
;  Compressed Image Data
;
        rel     ; relocatable
        lnk     data0.l

        mx %00

;-------------------------------------------------------------------------------

background_pic ent             ; make sure start is visible outside the file
	putbin data\photonix.256

; Mouse Data
mouse_tiles ent
	putbin data\mouse.256   ; 1 tile wide, by a lot of tiles tall

;mouse_map ent
;	putbin data\mouse.lzsa2


