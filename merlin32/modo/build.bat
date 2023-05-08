..\bin\Merlin32.exe -V ..\bin\Library link.s 
..\bin\omf2hex modo.s16 modo.hex
..\bin\mappy.exe modo.s16_S01_Main_Output.txt $002100 > modo.lst
run256 modo.hex


