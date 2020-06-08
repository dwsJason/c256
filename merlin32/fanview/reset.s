;
; Define the Reset Vector
;

        rel             ; relocatable
        lnk     reset.l

start   ext             ; external label

        da      start   ; define 16 bit address



