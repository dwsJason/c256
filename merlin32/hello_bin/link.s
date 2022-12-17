;
; Merlin32 BIN Linker File
;

;
; You want to use this, so merlin can auto resolve addresses in different
; modules for you
;
		TYP $06
 
; Segment 1
		asm hello.s
 
; Segment 2
        asm reset.s


 



