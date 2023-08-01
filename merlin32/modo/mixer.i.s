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

; Reserve 64k, mixer work ram, first 8k is the volume tables
MIXER_WORKRAM = $010000

; If this is defined to 1, then we support waves that cross bank boundaries
; it's a little more expensive, but, it's also really cool
SUPPORT_LARGE_WAVES equ 1


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
; Voice/Oscillator Structure (32 bytes)
;
; 
		dum 0
;osc_type      ds 2
;osc_state     ds 2
osc_pWave     ds 4 ; 24.8 current wave pointer
osc_pWaveLoop ds 4 ; 24.8 location in the wave, to loop too
osc_pWaveEnd  ds 4 ; 24.8 end of wave
osc_frequency ds 2 ; 8.8 frequency
osc_left_vol  ds 1 ; Left Volume
osc_right_vol ds 1 ; Right Volume
; 22
osc_frame_size ds 4 ; 24.8 how many samples will move when we render 256 output samples
osc_loop_size  ds 4 ; 24.8
osc_set_freq   ds 2 
osc_set_left   ds 1
osc_set_right  ds 1

sizeof_osc ds 0  	; needs to be less than 32 (31 or under)
					; so there's room for the temp variables osc_delta

		dend

		dum {sizeof_osc*8}
osc_delta ds 4
osc_log ds 2
		dend


;		do sizeof_osc#32
;		ERROR "Oscillator Struct must be 32 bytes"
;		fin

 
;
; An Instrument Data Structure
; !!NOTE: right now Instrument waves are not allowed to span banks, so are
; !!NOTE: limited to 65536 bytes / (32768 samples)
;
		dum 0
i_name              ds 32   ; this should be 0 terminated, so max len is 31char
i_sample_rate       ds 4    ; sample rate of original wave, maps to i_key_center
i_key_center        ds 2
;i_percussion        ds 2    ; 1 for percussion (this means note # does not matter)
i_fine_tune         ds 2
i_volume            ds 2
;i_percussion_freq   ds 2    ; freq to play percussion note at
i_loop              ds 2    ; 1 for loop, 0 for single shot
i_sample_start_addr ds 4    ; ram start address for sample
i_sample_length     ds 4    ; length in bytes
i_sample_loop_start ds 4    ; address
i_sample_loop_end   ds 4    ; address
i_sample_spans_bank ds 2    ; if this is set, then mixer needs to run slower code that supports spanning banks
;i_space ds 2
sizeof_inst ds 0
		dend

;		do sizeof_inst#64
;		ERROR "Instrument Struct must be 64 bytes"
;		fin

		dum MIXER_WORKRAM
Channel0Left  ds 512
Channel0Right ds 512
Channel1Left  ds 512
Channel1Right ds 512
Channel2Left  ds 512
Channel2Right ds 512
Channel3Left  ds 512
Channel3Right ds 512
				 
Channel4Left  ds 512
Channel4Right ds 512
Channel5Left  ds 512
Channel5Right ds 512
Channel6Left  ds 512
Channel6Right ds 512
Channel7Left  ds 512
Channel7Right ds 512   ; 8k

VolumeTables ds 32768  ; 64 volumes * 512 bytes each, 32k

silence ds 4096        ; silent wave data (default osc instrument)
silence_end ds 0
		dend

; jmixer struct
		dum 0
jmix_jmix        ds 4
jmix_file_length ds 4
jmix_version     ds 2
jmix_freq        ds 2
jmix_note        ds 2
jmix_maxrate     ds 2
jmix_loop_point  ds 4
jmix_end_point   ds 4
jmix_audio_data  ds 0  ; variable length data to fills into the mixer
		dend

