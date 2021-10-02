;
;  Compressed Image Data
;
        rel     ; relocatable
        lnk     data0.l

        mx %00

;-------------------------------------------------------------------------------

title_pic ent             ; make sure start is visible outside the file
	putbin data\title.256

rastan_c1 ent
;	putbin data\rastan.c1
;	putbin data\paddler.c1
;	putbin data\vcs.c1
	putbin data\turtle.c1


