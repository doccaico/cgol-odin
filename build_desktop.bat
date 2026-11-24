@echo off

set OUT_DIR=build
if not exist %OUT_DIR% mkdir %OUT_DIR%

set "flags="

if "%~1"=="--debug" (
    set "flags=-debug"
) else if "%~1"=="--check" (
    odin check ^
        source ^
        source\main_desktop ^
        source\main_web ^
        -workspace -debug -no-entry-point -vet -vet-style -strict-style
    if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
    echo 💓 Check passed with no errors or warnings! 💓
    exit /b 0
) else if "%~1"=="--release" (
    set "flags=-o:speed -no-bounds-check -disable-assert -subsystem:windows"
)

odin build source\main_desktop %flags% -out:%OUT_DIR%\game_desktop.exe
if %ERRORLEVEL% NEQ 0 exit /b 1

echo Desktop build created in %OUT_DIR%
