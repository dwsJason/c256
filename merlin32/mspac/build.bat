..\bin\Merlin32.exe -V ..\bin\Library link.s
..\bin\mappy.exe mspacman.s16_S01_Main_Output.txt $002100 > mspacman.lst
..\bin\omf2hex mspacman.s16 mspacman.hex

run256 mspacman.hex



