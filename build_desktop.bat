@echo off

set OUT_DIR=build
if not exist %OUT_DIR% mkdir %OUT_DIR%

set "flags="

if "%~1"=="--debug" (
    set "flags=-debug"
) else if "%~1"=="--release" (
    set "flags=-o:speed -no-bounds-check -disable-assert -subsystem:windows"
)

odin build source\main_desktop %flags% -strict-style -out:%OUT_DIR%\game_desktop.exe
IF %ERRORLEVEL% NEQ 0 exit /b 1

echo Desktop build created in %OUT_DIR%
