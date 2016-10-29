
set BUILDEXITCODE=0

cd src

appveyor AddMessage "ultibo screen - pi - kernel.img"
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
call :checkerrorlevel

appveyor AddMessage "ultibo screen - pi2 - kernel7.img"
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
call :checkerrorlevel

if %BUILDEXITCODE% neq 0 (goto :exitbuild)

appveyor AddMessage "zip artifacts"
mkdir output
echo on
xcopy /q  kernel.img output
xcopy /q kernel7.img output
xcopy /q ..\bootfiles\*.* output
cd output
7z a  ..\..\kernel.img.zip  kernel.img  > 7z.log
7z a ..\..\kernel7.img.zip kernel7.img >> 7z.log
7z a ..\..\diskimage.zip *.*           >> 7z.log
cd ..

:exitbuild
exit %BUILDEXITCODE%

:checkerrorlevel
if %ERRORLEVEL% neq 0 (
    set BUILDEXITCODE=1
)
exit /b 0
