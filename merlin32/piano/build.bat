rem Assemble
..\bin\Merlin32.exe -V ..\bin\Library link.s
rem Source Level Debugging file for FoenixIDE
..\bin\mappy.exe piano.s16_S01_Main_Output.txt $002100 > piano.lst
rem Generate a hex file for the C256
..\bin\omf2hex piano.s16 piano.hex
rem Run the hex on the hardware, so we can see it go
run256 piano.hex




