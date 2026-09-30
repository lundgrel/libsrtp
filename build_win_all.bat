@echo off
rem Builds libsrtp2 for both Win32 and x64 into <root>\assets\<version>\<architecture>
call "%~dp0build_win.bat" Win32
if errorlevel 1 exit /b 1
call "%~dp0build_win.bat" x64
if errorlevel 1 exit /b 1
echo All builds done.
