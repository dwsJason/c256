rem
rem GS.Pacman Build.bat for C256
rem 
set CFLAGS="cc=-DFMX=1"
cd GS.Pacman
rmdir /q /s obj
mkdir obj
iix compile -P -I +O main.s keep=obj:main %CFLAGS%
iix compile -P -I +O reset.s keep=obj:reset %CFLAGS%
iix compile -P -I +O c1util.s keep=obj:c1util %CFLAGS%
iix compile -P -I +O alphaSprites.s keep=obj:alphaSprites %CFLAGS%
iix compile -P -I +O collision.s keep=obj:collision %CFLAGS%
iix compile -P -I +O color.s keep=obj:color %CFLAGS%
iix compile -P -I +O controls.s keep=obj:controls %CFLAGS%
iix compile -P -I +O drawAlphaSprites.s keep=obj:drawAlphaSprites %CFLAGS%
iix compile -P -I +O drawSprite.s keep=obj:drawSprite %CFLAGS%
iix compile -P -I +O fruit.s keep=obj:fruit %CFLAGS%
iix compile -P -I +O game.s keep=obj:game %CFLAGS%
iix compile -P -I +O ghosts.s keep=obj:ghosts %CFLAGS%
iix compile -P -I +O globals.s keep=obj:globals %CFLAGS%
iix compile -P -I +O hardware.s keep=obj:hardware %CFLAGS%
iix compile -P -I +O levelDisplay.s keep=obj:levelDisplay %CFLAGS%
iix compile -P -I +O maze.s keep=obj:maze %CFLAGS%
iix compile -P -I +O pac.s keep=obj:pac %CFLAGS%
iix compile -P -I +O score.s keep=obj:score %CFLAGS%
iix compile -P -I +O sound.s keep=obj:sound %CFLAGS%
iix compile -P -I +O sprites.s keep=obj:sprites %CFLAGS%
cd obj
rem iix link main reset alphaSprites collision color controls drawAlphaSprites drawSprite fruit game ghosts globals hardware levelDisplay maze pac score sound sprites c1util keep=pacman.sys16
iix link +L main reset alphaSprites collision color controls drawAlphaSprites drawSprite fruit game ghosts globals hardware levelDisplay maze pac score sound sprites c1util keep=pacman.sys16
cd ..\..
copy /y GS.Pacman\obj\pacman.sys16 .
..\bin\omf2hex pacman.sys16 pacman.hex


