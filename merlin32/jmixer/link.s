;
; Merlin32 OMF Linker File
;

;
; This doesn't make a lot of sense for a tiny program, but as a program
; starts spanning multiple banks, this makes more sense
; eventually, I want to do an OMF loader for the C256, until then
; I've got my OMF2Hex tool, which does a very similar thing
;

        dsk     jmixer   ; Program File Name
        typ     $B3      ; S16, GS/OS Application
        ;xpl    ; For ~ExpressLoad
        
 
; Segment 1
 
        asm     jmixer.s        ; sourcefile
        ds      0               ; extra 0's to add to the segment
        knd     #$1100          ; Type and Attr ($11=Static+Bank Relative,$00=Code)
        ali     none            ; Boundary Alignment
        lna     jmixer.S16      ; Load Name ('jmixer.S16') 
        sna     Main            ; Segment Name ('Main')
 
; Segment 2

        asm     reset.s         ; sourcefile
        ds      0               ; extra 0's to add to the segment
        knd     $1100           ; Type and Attr ($11=Static+Bank Relative,$00=Code)
        ali     none            ; Boundary Alignment
        lna     jmixer.S16      ; Load Name ('jmixer.S16') 
        sna     reset           ; Segment Name ('reset')

; Segment 3

        asm     font.s          ; sourcefile
        ds      0               ; extra 0's to add to the segment
        knd     $1100           ; Type and Attr ($11=Static+Bank Relative,$00=Code)
        ali     none            ; Boundary Alignment
        lna     jmixer.S16      ; Load Name ('jmixer.S16') 
        sna     font            ; Segment Name ('font')

; Segment 4

		asm		axelf.s			; sourcefile
        ds      0               ; extra 0's to add to the segment
        knd     $1100           ; Type and Attr ($11=Static+Bank Relative,$00=Code)
        ali     none            ; Boundary Alignment
        lna     jmixer.S16      ; Load Name ('jmixer.S16') 
        sna     axelf           ; Segment Name ('axelf')

; Segment 5

		asm		axelf2.s		; sourcefile
        ds      0               ; extra 0's to add to the segment
        knd     $1100           ; Type and Attr ($11=Static+Bank Relative,$00=Code)
        ali     none            ; Boundary Alignment
        lna     jmixer.S16      ; Load Name ('jmixer.S16') 
        sna     axelf2          ; Segment Name ('axelf')

; Segment 6

		asm		axelf3.s		; sourcefile
        ds      0               ; extra 0's to add to the segment
        knd     $1100           ; Type and Attr ($11=Static+Bank Relative,$00=Code)
        ali     none            ; Boundary Alignment
        lna     jmixer.S16      ; Load Name ('jmixer.S16') 
        sna     axelf3          ; Segment Name ('axelf')


; Segment 7

		asm		canon.s			; sourcefile
        ds      0               ; extra 0's to add to the segment
        knd     $1100           ; Type and Attr ($11=Static+Bank Relative,$00=Code)
        ali     none            ; Boundary Alignment
        lna     jmixer.S16      ; Load Name ('jmixer.S16') 
        sna     canon           ; Segment Name ('canon')

; Segment 8

		asm		chess.s			; sourcefile
        ds      0               ; extra 0's to add to the segment
        knd     $1100           ; Type and Attr ($11=Static+Bank Relative,$00=Code)
        ali     none            ; Boundary Alignment
        lna     jmixer.S16      ; Load Name ('jmixer.S16') 
        sna     chess           ; Segment Name ('chess')

; Segment 9

		asm		insts.s			; sourcefile
        ds      0               ; extra 0's to add to the segment
        knd     $1100           ; Type and Attr ($11=Static+Bank Relative,$00=Code)
        ali     none            ; Boundary Alignment
        lna     jmixer.S16      ; Load Name ('jmixer.S16') 
        sna     insts           ; Segment Name ('insts')

		
