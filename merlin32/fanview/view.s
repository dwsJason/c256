;
;  Foenix ANim Viewer Program
;
        rel     ; relocatable
        lnk     Main.l

        use Util.Macs

        mx %00

; Kernel method
PUTS = $00101C         ; Print a string to the currently selected channel

; FANM Load Address
FANM_Data = $10000

;-------------------------------------------------------------------------------
MyDP = $1F00

pHeader = $00
pCLUT   = $04
pINIT   = $08
pFRAMES = $0C

; General Work Pointer
pData = $10

; Header Info
i16Version      = $70
i32FileLength   = $72
i32EOF_Address  = $76
i32FrameCount   = $7A
i16Width        = $7E
i16Height       = $80


temp0           = $e0
temp1           = $e4
temp2           = $e8
temp3           = $ec
temp4           = $f0
temp5           = $f4
temp6           = $f8
temp7           = $fc


; Eventually Player will sit in the direct page

start   ent             ; make sure start is visible outside the file
        clc
        xce
        rep $31         ; long MX, and CLC

; Default Stack is on top of System DMA Registers
; So move the stack before proceeding

        lda #$7FFF      ; I really don't know much RAM the kernel is using in bank 0
        tcs

        lda #MyDP
        tcd

        jsr     init

        ; Setup the pointer
        lda     #FANM_Data
        ldx     #^FANM_Data
        jsr     fanmInit
        bcc     :isGood

        jsr     myPUTS  ; Should return with an "error" code

        ldx     #PleaseLoad
        jsr     myPUTS
]end
        bra     ]end

:isGood

        ldx     #SeemsGood
        jsr     myPUTS


;	PushLong #penguin_lz4
;	PushLong #$E12000       ; Graphic Color Palette 0
;	jsl LZ4_Unpack

        jsr     fanmLoadCLUT
;        jsr     fanmLoadINIT

end
        bra     end
SeemsGood asc 'Seems Good'
        db 13,0

*
* int LZ4_Unpack(u8* pDest, u8* pPackedSource);
*

LZ4_Unpack

pDest equ 5
pPackedSource equ 9

    phb
    phk
    plb

    sep #$20
    lda pPackedSource+2,s    ; Pull out the src/dst banks
    xba
    lda pDest+2,s   		 ; Pull out the src/dst banks

    rep #$31
    tax                      ; Temp save in X

    lda pDest,s
    sta LZ4_Dst+1

    lda pPackedSource+1,s    ; address of packed source + 4, is the unpacked len
    sta upl+2
	
    lda pPackedSource,s
    adc #12
    sta upl+1
	
upl lda >0                  ; packed length
	adc #16 				; 16 bytes for packed buffer header
    adc pPackedSource,s 	; start of packed buffer
    tay                     ; y has the pack data stop address
	
    anop ; 1st packed Byte offset
    lda pPackedSource,s     ; skip 16 byte header on the source
    adc #16
    pha
    txa
    plx
	
    jsr ASM_LZ4_Unpack
    tay
	
    anop ; Copy the Return address
    lda 1,s
    sta pPackedSource,s
    lda 3,s
    sta pPackedSource+2,s
		
    tsc
	sec
    sbc #-8
    tcs
    tya    ; return length	

    plb
    rtl

*-------------------------------------------------------------------------------
ASM_LZ4_Unpack   STA  LZ4_Literal_3+1   ; Uncompress a LZ4 Packed Data buffer (64 KB max)
                 SEP  #$20              ; A = Bank Src,Bank Dst
                 STA  LZ4_Match_5+1     ; X = Header Size = 1st Packed Byte offset
                 STA  LZ4_Match_5+2     ; Y = Pack Data Size
                 XBA                    ;  => Return in A the length of unpacked Data
                 STA  LZ4_ReadToken+3   
                 STA  LZ4_Match_1+3     
                 STA  LZ4_GetLength_1+3 
                 REP  #$30 
                 STY  LZ4_Limit+1
*--
LZ4_Dst          LDY  #$0000            ; Init Target unpacked Data offset
LZ4_ReadToken    LDA  >$AA0000,X        ; Read Token Byte
                 INX
                 STA  LZ4_Match_2+1
*----------------
LZ4_Literal      AND  #$00F0            ; >>> Process Literal Bytes <<<
                 BEQ  LZ4_Limit         ; No Literal
                 CMP  #$00F0
                 BNE  LZ4_Literal_1
                 JSR  LZ4_GetLengthLit  ; Compute Literal Length with next bytes
                 BRA  LZ4_Literal_2
LZ4_Literal_1    LSR  A                 ; Literal Length use the 4 bit
                 LSR  A
                 LSR  A
                 LSR  A
*--
LZ4_Literal_2    DEC  A                 ; Copy A+1 Bytes
LZ4_Literal_3    MVN  $AA,$BB           ; Copy Literal Bytes from packed data buffer
                 PHK                    ; X and Y are auto incremented
                 PLB
*----------------
LZ4_Limit        CPX  #$AAAA            ; End Of Packed Data buffer ?
                 BEQ  LZ4_End
*----------------
LZ4_Match        TYA                    ; >>> Process Match Bytes <<<
                 SEC
LZ4_Match_1      SBC  >$AA0000,X         ; Match Offset
                 INX
                 INX
                 STA  LZ4_Match_4+1
*--
LZ4_Match_2      LDA  #$0000            ; Current Token Value
                 AND  #$000F
                 CMP  #$000F
                 BNE  LZ4_Match_3
                 JSR  LZ4_GetLengthMat  ; Compute Match Length with next bytes
LZ4_Match_3      CLC
                 ADC  #$0003            ; Minimum Match Length is 4 (-1 for the MVN)
*--
                 PHX
LZ4_Match_4      LDX  #$AAAA            ; Match Byte Offset
LZ4_Match_5      MVN  $BB,$BB           ; Copy Match Bytes from unpacked data buffer
                 PHK                    ; X and Y are auto incremented
                 PLB
                 PLX
*----------------
                 BRA  LZ4_ReadToken
*----------------
LZ4_GetLengthLit LDA  #$000F            ; Compute Variable Length (Literal or Match)
LZ4_GetLengthMat STA  LZ4_GetLength_2+1
LZ4_GetLength_1  LDA  >$AA0000,X         ; Read Length Byte
                 INX
                 AND  #$00FF
                 CMP  #$00FF
                 BNE  LZ4_GetLength_3
                 CLC
LZ4_GetLength_2  ADC  #$000F
                 STA  LZ4_GetLength_2+1
                 BRA  LZ4_GetLength_1
LZ4_GetLength_3  ADC  LZ4_GetLength_2+1
                 RTS
*----------------
LZ4_End          TYA                    ; A = Length of Unpack Data
                 RTS
*-------------------------------------------------------------------------------
;
; Put DP back at zero while calling out to PUTS
;
myPUTS  mx %00
        phd
        lda #0
        tcd
        jsl PUTS
        pld
        rts
;---------------------------------------------------
; --- Space For Stuff I don't care that it's big

init    mx %00

        ldx #VersionText
        jsr myPUTS

        ldx #CheckingText
        jsr myPUTS

        rts    

CheckingText asc 'Checking for FANM at $010000'
        db 13,0

VersionText asc 'Foenix ANim View - Version 0.01'
        db 13,0

PleaseLoad asc 'Please load a Valid FAN file, at $010000'
        db 13,0

InvalidHeader asc 'Invalid FAN Header Block'
        db 13,0

MissingClut asc 'No CLUT found'
        db 13,0

MissingInit asc 'No INITial Frame Data found'
        db 13,0

MissingFrames asc 'No FRAMes Chunk found'
        db 13,0

;-------------------------------------------------------------------------------
;
; pCLUT
;
; Input:  pClut on the DP should point to the CLUT Chunk
;
;  For now, whatever there is for a clut will just go
;  to Graphic Mode Palette 0,  $AF2000
;
;	char		  c,l,u,t;		// 'C','L','U','T'
;	unsigned int  chunk_length; // in bytes, including the 8 bytes header of this chunk
;	unsigned short num_colors;  // number of colors-1, 1-16384 colors
;                                   // %1000_0000_0000_0000, Hi-Bit set indicates
;                                   // LZ4 compression
;                                   // otherwise memcpy (4 * (num_colors+1))
; 
fanmLoadCLUT mx %00
        
;	PushLong #penguin_lz4
;	PushLong #$E12000       ; Graphic Color Palette 0
;	jsl LZ4_Unpack
        ldy #8                  ; skip up to num_colors
        lda [pCLUT]
        
        bpl :uncompressed

        ; LZ4 Compressed
        ; Oh no, the data has no header, want to use the
        ; I only know the uncompressed length version of the function


        rts

:uncompressed
        inc
        asl
        asl
        dec
        tay
        
        lda     pClut
        adc     #10
        tax     ; Source

        tya
        ldy     #<$AF2000
                
        mvn     ^$010000,^$AF2000

        phk
        plb

        rts

;-------------------------------------------------------------------------------
;
;  AX = Pointer to the compressed Anim Data File
;
;  This should be Bank Aligned for the player
;  For the Chunk Finder, alignment doesn't matter
;
fanmInit mx %00
        sta     pData
        stx     pData+2

        jsr     fanmParseHeader
        bcc     :isGood
        ldx     #InvalidHeader
        rts

:isGood
        ; Now pData is supposed to be pointed at the first chunk
        ; And data should be moved out of the header and into the DP
        lda     #'CL'
        ldx     #'UT'
        jsr     FindChunk
        sta     pCLUT
        stx     pCLUT+2

        ora     pCLUT+2
        bne     :hasClut

        ldx     #MissingClut
        sec
        rts

:hasClut
        lda     #'IN'
        ldx     #'IT'
        jsr     FindChunk
        sta     pINIT
        stx     pINIT+2

        ora     pINIT+2
        bne     :hasInit

        ldx     #MissingInit
        sec
        rts

:hasInit

        lda     #'FR'
        ldx     #'AM'
        jsr     FindChunk
        sta     pFRAMES
        stx     pFRAMES+2

        ora     pFRAMES+2
        bne     :hasFrames

        ldx     #MissingFrames
        sec
        rts

:hasFrames
        ; c=0 everything is good
        clc
        rts
;-------------------------------------------------------------------------------
;
;  FindChunk
;       Inputs:  pData            (pointer to first chunk in the file)
;                i32EOF_Address   (first RAM address past the end of the file)
;
;        AX     'ABCD' - Chunk Name to Find
;
;  Return:  AX   - Pointer to the Chunk
;
FindChunk mx    %00

:pWork  = temp0
:pName  = temp1
:EOF    = i32EOF_Address
:size   = temp2

        sta :pName
        stx :pName+2

        lda pData
        sta :pWork
        lda pData+2
        sta :pWork+2

;  while :pWork < :EOF
]loop
        lda :pWork+2
        cmp :EOF+2
        bcc :continue  ; blt
        bne :nullptr   ; bgt
        lda :pWork
        cmp :EOF
        bcs :nullptr   ; bge
:continue
        lda [:pWork]
        cmp :pName
        bne :nextChunk
        ldy #2
        lda [:pWork],y
        cmp :pName+2
        bne :nextChunk

        ; Match found, return with the address
        lda :pWork
        ldx :pWork+2
        rts

:nextChunk
        ldy #4
        lda [:pWork],y
        sta :size
        iny
        iny
        lda [:pWork],y
        sta :size+2

        ; Move pWork to the next Chunk
        clc
        lda :pWork
        adc :size
        sta :pWork
        lda :pWork+2
        adc :size+2
        sta :pWork+2
        
        bra ]loop

:nullptr
        ; Return nullptr
        lda #0
        tax

        rts

;-------------------------------------------------------------------------------
; Direct Page Location
; pData should be pointing at the Header
;
;	char 			f,a,n,m;  // 'F','A','N','M'
;	unsigned char	version;  // 0x00 or 0x80 for Tiled
;	short			width;	  // In pixels
;	short			height;	  // In pixels
;	unsigned int 	file_length;  // In bytes, including the 16 byte header
;
;	unsigned short	frame_count;	// 3 bytes for the frame count
;	unsigned char   frame_count_high;
;
fanmParseHeader mx %00

        ; Check for 'FANM'
        lda [pData]
        cmp #'FA'       ;$4146
        bne :BadHeader
        ldy #2

        lda [pData],y
        cmp #'NM'       ;$4D4E 
        iny
        iny

        ; Look at the File Version
        lda [pData],y
        iny
        and #$ff
        sta i16Version
        and #$7f
        bne :BadHeader  ; only version zero is acceptable

        ; Get the width and height
        lda [pData],y
        sta i16Width
        iny
        iny
        lda [pData],y
        sta i16Height
        iny
        iny

        ; Copy out FileLength
        lda [pData],y
        sta i32FileLength
        iny
        iny
        lda [pData],y
        sta i32FileLength+2
        iny
        iny

        ; Compute the end of file address
        clc
        lda pData
        adc i32FileLength
        sta i32EOF_Address
        lda pData+2
        adc i32FileLength+2
        sta i32EOF_Address+2
        bcs :BadHeader          ; overflow on memory address

        ; Frame Count
        stz i32FrameCount+2
        lda [pData],y
        sta i32FrameCount
        iny
        lda [pData],y
        sta i32FrameCount+1
        iny
        iny

        ; c=0
        tya
        adc pData
        sta pData
        lda #0
        adc pData+2
        sta pData+2
        ; c=0 mean's there's no error
        rts

:BadHeader
        sec     ; c=1 means there's an error
        rts



