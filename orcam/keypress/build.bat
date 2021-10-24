iix compile -P -I +O hello.s keep=hello
iix compile -P -I +O reset.s keep=reset
iix link hello reset keep=hello.sys16
..\bin\omf2hex hello.sys16 hello.hex
