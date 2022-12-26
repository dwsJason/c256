..\bin\Merlin32.exe -V ..\bin\Library link.s 
..\bin\omf2hex jmixer jmixer.hex
..\bin\mappy.exe jmixer_S01_Main_Output.txt $003000 > jmixer.lst
..\bin\omf2hex jmixer jmixer.hex

run256 jmixer.hex
