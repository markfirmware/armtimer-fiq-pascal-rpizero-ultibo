
cd src

del *.exe *.o *.ppu
C:\Ultibo\Core\fpc\3.1.1\bin\i386-win32\fpc ^
 -B ^
 -Tultibo ^
 -Parm ^
 -CpARMV6 ^
 -WpRPIB ^
 @C:\Ultibo\Core\fpc\3.1.1\bin\i386-win32\RPI.CFG ^
 -O2 ^
 screen.lpr

cd ..
