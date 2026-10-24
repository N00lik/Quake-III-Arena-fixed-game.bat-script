:: For correct work lcc.exe, q3asm.exe, q3cpp.exe, q3rcc.exe must exsist in same folder (/game/) with that .bat script
:: Assembled .qvm file gonna be saved to C:\quake3\baseq3\vm folder

@echo off
cd /d "%~dp0"

echo ===================================================
echo  STARTING AUTOMATIC QUAKE 3 COMPILATION
echo  DIRECTORY: %cd%
echo ===================================================

set LIBRARY=
set INCLUDE=
set cc=

if not exist "lcc.exe" echo [ERROR] Missing lcc.exe & pause & exit /b 1
if not exist "q3cpp.exe" echo [ERROR] Missing q3cpp.exe & pause & exit /b 1
if not exist "q3asm.exe" echo [ERROR] Missing q3asm.exe & pause & exit /b 1

set "PATH=%cd%;%PATH%"

if not exist "vm" mkdir vm
if exist "bg_lib.asm" copy /y "bg_lib.asm" "vm\" >nul

cd vm

if not exist "bg_lib.asm" (
    if exist "..\bg_lib.asm" copy /y "..\bg_lib.asm" . >nul
)

set cc=lcc -DQ3_VM -S -Wf-target=bytecode -Wf-g -I..\..\cgame -I..\..\game -I..\..\ui

echo ---------------------------------------------------
echo  [1/2] AUTOMATICALLY COMPILING ALL .C FILES...
echo ---------------------------------------------------

:: Compiling everything exept g_rankings.c
for %%i in (..\*.c) do (
    if /i "%%~nxi"=="g_rankings.c" (
        echo Skipping broken system file: %%~nxi
    ) else (
        echo Compiling %%~nxi...
        %cc% %%i
        if errorlevel 1 goto error
    )
)

echo ---------------------------------------------------
echo  [2/2] BUILDING FINAL QVM FILE...
echo ---------------------------------------------------
q3asm -f ../game
if errorlevel 1 goto error

echo ===================================================
echo  SUCCESS: qagame.qvm created successfully!
echo ===================================================
cd ..
pause
exit /b 0

:error
echo ===================================================
echo  ERROR: Build failed! Check the messages above.
echo ===================================================
cd ..
pause
exit /b 1