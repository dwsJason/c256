;
;  Compressed Image Data
;
        rel     ; relocatable
        lnk     data0.l

        mx %00

;-------------------------------------------------------------------------------

sprites_pic ent
	putbin data\sprites.256

logo_pic ent             ; make sure start is visible outside the file
	putbin data\logo.256

pumpbars_pic ent
	putbin data\pumpbars.256



