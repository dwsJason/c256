;
; Piano Demo Direct Page Allocations
;
		mx %00

MyDP = $2000

		dum 0

temp0 ds 4
temp1 ds 4
temp2 ds 4
temp3 ds 4
temp4 ds 4
temp5 ds 4
temp6 ds 4
temp7 ds 4
temp8 ds 4
temp9 ds 4

lzsa_sourcePtr ds 4
lzsa_destPtr   ds 4
lzsa_matchPtr  ds 4
lzsa_nibble    ds 2
lzsa_suboffset ds 2
lzsa_token     ds 2


i32EOF_Address ds 4
i32FileLength  ds 4
pData          ds 4
i16Version     ds 2
i16Width       ds 2
i16Height      ds 2
pCLUT          ds 4  ; pointer to CLUT Structure
pPIXL		   ds 4  ; pointer to PIXL Structure
pTMAP          ds 4  ; pointer to TMAP Structure

dpJiffy ds 2

		dend

