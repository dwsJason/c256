rem Assemble
..\bin\Merlin32.exe -V ..\bin\Library link.s
rem Source Level Debugging file for FoenixIDE
..\bin\mappy.exe stars.s16_S01_Main_Output.txt $002100 > stars.lst
rem Generate a hex file for the C256
..\bin\omf2hex stars.s16 stars.hex
rem Run the hex on the hardware, so we can see it go
run256 stars.hex




