;
;  Compressed Image Data
;
        rel     ; relocatable
        lnk     data0.l

        mx %00

;-------------------------------------------------------------------------------

title_pic ent             ; make sure start is visible outside the file
	putbin data\dmania.256
;	putbin data\gold_mask.256









