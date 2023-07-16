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

dpJiffy ds 2		 ; 60hz tick
dpAudioJiffy ds 2    ; 50hz tick

pFastPut ds 4 ; pointer to the current text buffer address

last_row ds 4

SongIsPlaying ds 2

mod_type_code	      ds 4
mod_type			  ds 2

mod_num_instruments   ds 2
mod_num_tracks        ds 2     ; default to 4
mod_pattern_size      ds 2     ; default to 1024
mod_row_size          ds 2     ; default 16

mod_speed             ds 2     ; default speed is 6
mod_song_length       ds 2     ; length in patterns
mod_p_current_pattern ds 4     ; pointer to the current pattern
mod_p_pattern_dir     ds 4	   ; pointer to directory of patterns
mod_current_row       ds 2     ; current row #
mod_pattern_index     ds 2     ; current index into pattern directory
mod_num_patterns      ds 2     ; total number of patterns
mod_jiffy             ds 2     ; mod player jiffy

mod_temp0			ds 4
mod_temp1           ds 4
mod_temp2			ds 4
mod_temp3			ds 4



		dend

; needed for "quick-ish" print functions
fastPUTC mac
		sta [pFastPut]
		inc <pFastPut
		<<<

