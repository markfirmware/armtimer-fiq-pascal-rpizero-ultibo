
cd src
del *.exe *.o *.ppu
C:/FPC/3.0.0/bin/i386-win32/fpc ^
 screen.lpr
cd ..

cd src
del *.exe *.o *.ppu
C:\Ultibo\Core\fpc\3.1.1\bin\i386-win32\fpc ^
 -B ^
 -Tultibo ^
 -dBUILD_RPI ^
 -Parm ^
 -CpARMV6 ^
 -WpRPIB ^
 @C:\Ultibo\Core\fpc\3.1.1\bin\i386-win32\RPI.CFG ^
 -O2 ^
 screen.lpr
cd ..

cd src
del *.exe *.o *.ppu
C:\Ultibo\Core\fpc\3.1.1\bin\i386-win32\fpc ^
 -B ^
 -Tultibo ^
 -dBUILD_RPI2 ^
 -Parm ^
 -CpARMV7A ^
 -WpRPI2B ^
 @C:\Ultibo\Core\fpc\3.1.1\bin\i386-win32\RPI2.CFG ^
 -O2 ^
 screen.lpr
cd ..
