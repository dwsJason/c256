;
; Merlin32 OMF Linker File
;

;
; This doesn't make a lot of sense for a tiny program, but as a program
; starts spanning multiple banks, this makes more sense
; eventually, I want to do an OMF loader for the C256, until then
; I've got my OMF2Hex tool, which does a very similar thing
;

        dsk     hello   ; Program File Name
        typ     $B3     ; S16, GS/OS Application
        ;xpl    ; For ~ExpressLoad
        
 
; Segment 1
 
        asm     hello.s         ; sourcefile
        ds      0               ; extra 0's to add to the segment
        knd     #$1100          ; Type and Attr ($11=Static+Bank Relative,$00=Code)
        ali     none            ; Boundary Alignment
        lna     Hello.S16       ; Load Name ('Hello.S16') 
        sna     Main            ; Segment Name ('Main')
 
; Segment 2

        asm     reset.s         ; sourcefile
        ds      0               ; extra 0's to add to the segment
        knd     $1100           ; Type and Attr ($11=Static+Bank Relative,$00=Code)
        ali     none            ; Boundary Alignment
        lna     Hello.S16       ; Load Name ('Hello.S16') 
        sna     reset            ; Segment Name ('reset')

 



