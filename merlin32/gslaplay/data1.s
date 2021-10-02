;
;  Compressed Image Data
;
        rel     ; relocatable
        lnk     data1.l

        mx %00

;-------------------------------------------------------------------------------

movie_data ent             ; make sure start is visible outside the file
	putbin data\steeljoe.gsla

