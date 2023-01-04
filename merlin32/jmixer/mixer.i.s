;
; Include File, that you need when using the mixer
;

; Numbers are all fixed point, so 8.8 is a 16 bit number where the high byte
; is the integer number, and the low 8 bits is fraction

; 24.8, is a 32 bit value where the upper 3 bytes is a full 24 bit 65816 address
; and the lower 8 bits is a fraction, used for scaling the sample to different
; frequencies
; !!!NOTE: for performance reasons, I'm not planning on supporting data that
; crosses banks, for very large waves, something outside the mixer will have
; to handle the complexity
;

VOICES   equ 8
DAC_RATE equ 24000

; Enum for Oscillator types
		dum 0
ot_pcm8    ds 1  	; 8 bit  mono pcm, MOD compatible
ot_pcm     ds 1 	; 16 bit mono pcm, GM/SF2 usually contain this type
ot_adpcm   ds 1 	; 16 bit compressed source
ot_brr     ds 1 	; SNES SPU format
        dend

; Enum for Oscillator States
		dum 0
os_stopped            ds 1
os_playing_singleshot ds 1
os_playing_looped     ds 1
		dend
;
;
; Voice/Oscillator Structure
;
; 
		dum 0
osc_type      ds 2
osc_state     ds 2
osc_pWave     ds 4 ; 24.8 current wave pointer
osc_pWaveLoop ds 4 ; 24.8 location in the wave, to loop too
osc_pWaveEnd  ds 4 ; 24.8 end of wave
osc_frequency ds 2 ; 8.8 frequency
osc_left_vol  ds 2 ; Left Volume
osc_right_vol ds 2 ; Right Volume
; 22
osc_frame_size ds 4 
osc_reserved  ds 6 ; pad the oscillator out to 32 bytes

		dend
		 
