;
; Define the Reset Vector
;
		org $FFFC
		dsk reset.bin

start   ext             ; external label

        da      start   ; define 16 bit address



