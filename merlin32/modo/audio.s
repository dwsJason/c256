// Finished on 1/26,  JIC released March 7-8

                setas
                setxl
                ; Init DAC Interface
                ;Registers0 $AF1900
                ;Bit0 = Enable
                ;Bit1 = Reset FIFO
                ;Bit3:2 = Mode - 00 - 8Bits Mono, 01 - 8Bits Stereo, 10 - 16Bits Mono, 11 - 16Bits Stereo
                LDA #$02               ; Reset FIFO
                STA $AF1900
                LDA #$00                ; UnReset FIFO
                STA $AF1900
                ; Information
                ; The FIFO is 4096 Byte Deep
                ; With a DMA (That is not supported yet) (1 Read, 1 Write) - Fastest Time to fill the FiFo is 572us 
                ; Mode 0: 8Bits Mono -  4096K Samples @ 48Khz - (Can Store 85.33ms of Sound) 5.3 Frames Long 
                ; Mode 1: 8Bits Stereo -  2048K Samples @ 48Khz - (Can Store 42.66ms of Sound) 2.6 Frames Long
                ; Mode 2: 16Bits Mono -  2048K Samples @ 48Khz - (Can Store 42.66ms of Sound)
                ; Mode 3; 16Bits Stereo - 1024K Samples @ 48Khz - (Can Store 21.33ms of Sound) 1.3 Frames Long  Takes 

                LDA #$9                 ; Enable Block and Set for 16Bits Mono 
                STA $AF1900
                setal 
                ; This is the Point where the DATA is, and it is Little Endian (LHLH...)
                LDA #<>SOUND_DAC_TEST + $2C
                STA DAC_DATA_PTR_L
                LDA #`SOUND_DAC_TEST
                STA DAC_DATA_PTR_H
                ; This is the overall Size of the Samples Block in Bytes
                LDA @lSOUND_DAC_TEST + 40
                STA DAC_DATA_SIZ_L
                LDA @lSOUND_DAC_TEST + 40 + $02
                STA DAC_DATA_SIZ_H
LDX #$0000      ; Chunk (2K Byte Size) Counter
                ; The Accumulator is set for 16 bits, the Port can be either 8 or 16, the FIFO will grab both bytes

                LDY #$0000      ; Chunk Byte Counter
                ; This is to charge the FIFO
CHARGE_FIFO_FULL:
                lda [DAC_DATA_PTR_L], y ; with 4096 Values (2048K Samples)
                STA $AF1908
                INY
                INY
                CPY #4096       ; (these are Shorts) Since we are in 16bits Accumulator, how about we save 2K only. :wink:
                BNE CHARGE_FIFO_FULL

                JSR DACDataUpdatePointer ; Add 2048 Bytes
                JSR DACDataUpdatePointer ; Add 2048 Bytes

                INX     ; 1 Chunk
                INX     ; 1 Chunk
                ; Now, let's wait for the FIFO to Empty to the Mid-Level and feed it another 2048 Bytes
                ;$AF1904 -  wrusedw_sig[7:0]
        ;$AF1905 { wrempty_sig, wrfull_sig, 2'b00, wrusedw_sig[11:8]}
KEEP_GOING_TILL_SOUND_IS_OVER:

NOT_READY_2_TRF:
                LDA $AF1904     ; Read the FIFO Status
                AND #$0800      ; Remove All other bits ( I am looking for to get Half Empty )
                CMP #$0800      ; The FIFO Content is Still > 4096;
                BEQ NOT_READY_2_TRF

                LDY #$0000
CHARGE_FIFO_HALF:
                lda [DAC_DATA_PTR_L], y ; with 4096 Values (2048K)
                STA $AF1908
                INY
                INY
                CPY #2048       ; (these are Shorts) Since we are in 16bits Accumulator, how about we save 2K only. :wink:
                BNE CHARGE_FIFO_HALF

                JSR DACDataUpdatePointer ; Add 2048 Bytes (1024 Shorts)

                INX     ; 1 Chunk
                CPX #$104
                BNE KEEP_GOING_TILL_SOUND_IS_OVER;

                RTL
.pend
DACDataUpdatePointer: .proc
                ; We are in Sixteen Bit here
                CLC
                LDA DAC_DATA_PTR_L
                ADC #$0800
                STA DAC_DATA_PTR_L
                BCC WE_ARE_DONE

                INC DAC_DATA_PTR_H

WE_ARE_DONE:
                RTS
               .pend

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Dump_WAV_In_DAC .proc

                setas
                setxl
                ; Init DAC Interface
                ;Registers0 $AF1900
                ;Bit0 = Enable
                ;Bit1 = Reset FIFO
                ;Bit3:2 = Mode - 00 - 8Bits Mono, 01 - 8Bits Stereo, 10 - 16Bits Mono, 11 - 16Bits Stereo                
                LDA #$02               ; Reset FIFO
                STA $AF1900
                LDA #$00                ; UnReset FIFO
                STA $AF1900             
                ; Information
                ; The FIFO is 4096 Byte Deep
                ; With a DMA (That is not supported yet) (1 Read, 1 Write) - Fastest Time to fill the FiFo is 572us 
                ; Mode 0: 8Bits Mono -  4096K Samples @ 48Khz - (Can Store 85.33ms of Sound) 5.3 Frames Long 
                ; Mode 1: 8Bits Stereo -  2048K Samples @ 48Khz - (Can Store 42.66ms of Sound) 2.6 Frames Long
                ; Mode 2: 16Bits Mono -  2048K Samples @ 48Khz - (Can Store 42.66ms of Sound)
                ; Mode 3; 16Bits Stereo - 1024K Samples @ 48Khz - (Can Store 21.33ms of Sound) 1.3 Frames Long  Takes 

                LDA #$9                 ; Enable Block and Set for 16Bits Mono 
                STA $AF1900            
                setal 
                ; This is the Point where the DATA is, and it is Little Endian (LHLH...)
                LDA #<>SOUND_DAC_TEST + $2C
                STA DAC_DATA_PTR_L
                LDA #`SOUND_DAC_TEST
                STA DAC_DATA_PTR_H
                ; This is the overall Size of the Samples Block in Bytes
                LDA @lSOUND_DAC_TEST + 40
                STA DAC_DATA_SIZ_L
                LDA @lSOUND_DAC_TEST + 40 + $02
                STA DAC_DATA_SIZ_H


                LDX #$0000      ; Chunk (2K Byte Size) Counter
                ; The Accumulator is set for 16 bits, the Port can be either 8 or 16, the FIFO will grab both bytes

                LDY #$0000      ; Chunk Byte Counter
                ; This is to charge the FIFO
CHARGE_FIFO_FULL:                
                lda [DAC_DATA_PTR_L], y ; with 4096 Values (2048K Samples)
                STA $AF1908              
                INY
                INY
                CPY #4096       ; (these are Shorts) Since we are in 16bits Accumulator, how about we save 2K only. ;)
                BNE CHARGE_FIFO_FULL

                JSR DACDataUpdatePointer ; Add 2048 Bytes
                JSR DACDataUpdatePointer ; Add 2048 Bytes

                INX     ; 1 Chunk
                INX     ; 1 Chunk
                ; Now, let's wait for the FIFO to Empty to the Mid-Level and feed it another 2048 Bytes
                ;$AF1904 -  wrusedw_sig[7:0]
		;$AF1905 { wrempty_sig, wrfull_sig, 2'b00, wrusedw_sig[11:8]}
KEEP_GOING_TILL_SOUND_IS_OVER:

NOT_READY_2_TRF:                
                LDA $AF1904     ; Read the FIFO Status
                AND #$0800      ; Remove All other bits ( I am looking for to get Half Empty )
                CMP #$0800      ; The FIFO Content is Still > 4096;
                BEQ NOT_READY_2_TRF

                LDY #$0000
CHARGE_FIFO_HALF:                
                lda [DAC_DATA_PTR_L], y ; with 4096 Values (2048K)
                STA $AF1908              
                INY
                INY                
                CPY #2048       ; (these are Shorts) Since we are in 16bits Accumulator, how about we save 2K only. ;)
                BNE CHARGE_FIFO_HALF

                JSR DACDataUpdatePointer ; Add 2048 Bytes (1024 Shorts)

                INX     ; 1 Chunk                
                CPX #$F0 
                BNE KEEP_GOING_TILL_SOUND_IS_OVER;

                LDA #$0                 ; Turn off the DAC Module (no clickety can be heard, I still don't know why it does that)
                STA $AF1900      
                RTL
.pend


DACDataUpdatePointer: .proc
                ; We are in Sixteen Bit here
                CLC
                LDA DAC_DATA_PTR_L
                ADC #$0800
                STA DAC_DATA_PTR_L
                BCC WE_ARE_DONE

                INC DAC_DATA_PTR_H

WE_ARE_DONE:                
                RTS
               .pend
