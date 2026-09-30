@echo off
rem Builds libsrtp2 as a static library (/MT) with debug info for one architecture.
rem Usage: build_win.bat <Win32|x64>
rem Output: <root>\assets\<version>\<architecture>\{lib,include}
setlocal enableextensions enabledelayedexpansion

set "ARCH=%~1"
if /i "%ARCH%"=="x86"   set "ARCH=Win32"
if /i "%ARCH%"=="Win32" set "ARCH=Win32"
if /i "%ARCH%"=="x64"   set "ARCH=x64"
if not "%ARCH%"=="Win32" if not "%ARCH%"=="x64" (
    echo Usage: %~nx0 ^<Win32^|x64^>
    exit /b 1
)

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

rem --- version from CMakeLists.txt: project(libsrtp2 VERSION x.y.z ...)
set "VERSION="
for /f "tokens=3 delims= " %%V in ('findstr /b /c:"project(libsrtp2 VERSION" "%ROOT%\CMakeLists.txt"') do set "VERSION=%%V"
if not defined VERSION (
    echo Could not determine version from CMakeLists.txt
    exit /b 1
)

rem --- locate cmake (PATH first, then Visual Studio's bundled copy)
set "CMAKE=cmake"
where cmake >nul 2>nul
if errorlevel 1 (
    set "CMAKE="
    for %%E in (Community Professional Enterprise BuildTools) do (
        for %%Y in (2022 18) do (
            if not defined CMAKE if exist "%ProgramFiles%\Microsoft Visual Studio\%%Y\%%E\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe" set "CMAKE=%ProgramFiles%\Microsoft Visual Studio\%%Y\%%E\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
        )
    )
    if not defined CMAKE (
        echo cmake not found
        exit /b 1
    )
)

set "BUILD_DIR=%ROOT%\build\win-%ARCH%"
set "OUT_DIR=%ROOT%\assets\%VERSION%\%ARCH%"

echo === libsrtp2 %VERSION% [%ARCH%] static /MT ===

rem Static CRT, PDB debug info (/Zi) plus /DEBUG at link, optimized release code.
"%CMAKE%" -S "%ROOT%" -B "%BUILD_DIR%" -G "Visual Studio 17 2022" -A %ARCH% ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DLIBSRTP_TEST_APPS=OFF ^
    -DENABLE_WARNINGS_AS_ERRORS=OFF ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
    -DCMAKE_POLICY_DEFAULT_CMP0141=NEW ^
    -DCMAKE_MSVC_DEBUG_INFORMATION_FORMAT=ProgramDatabase
if errorlevel 1 exit /b 1

"%CMAKE%" --build "%BUILD_DIR%" --config Release --target srtp2
if errorlevel 1 exit /b 1

rem --- collect output
if exist "%OUT_DIR%" rmdir /s /q "%OUT_DIR%"
mkdir "%OUT_DIR%\lib" || exit /b 1
mkdir "%OUT_DIR%\include" || exit /b 1

set "LIB_DIR=%BUILD_DIR%\Release"
if not exist "%LIB_DIR%\srtp2.lib" (
    echo srtp2.lib not found in %LIB_DIR%
    exit /b 1
)
copy /y "%LIB_DIR%\srtp2.lib" "%OUT_DIR%\lib\" >nul || exit /b 1
copy /y "%LIB_DIR%\srtp2.pdb" "%OUT_DIR%\lib\" >nul || exit /b 1
copy /y "%ROOT%\include\srtp.h" "%OUT_DIR%\include\" >nul || exit /b 1

echo Output: %OUT_DIR%
endlocal
exit /b 0
