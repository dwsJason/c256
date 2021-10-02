;
;  Compressed Image Data
;
        rel     ; relocatable
        lnk     data0.l

        mx %00

;-------------------------------------------------------------------------------

title_pic ent             ; make sure start is visible outside the file
;	putbin data\dmania.256
;
bird_pic ent
;	putbin data\Phoenix-Bird-Wallpaper-16.256
gold_mask_pic ent
;	putbin data\gold_mask.256
	putbin data\hsv_color_wheel640.256


