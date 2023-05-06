..\bin\Merlin32.exe -V ..\bin\Library link.s
rem ..\bin\mappy.exe mouse.s16_S01_Main_Output.txt $002100 > mouse.lst
..\bin\omf2hex mouse.s16 mouse.hex
run256 mouse.hex



