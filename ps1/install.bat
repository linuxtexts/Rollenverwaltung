@echo off
echo Copying Rollen folder from V:\#VERKNUEPFUNGEN\Rollen to C:\
echo.

if not exist "V:\#VERKNUEPFUNGEN\Rollen" (
    echo Error: Source folder V:\#VERKNUEPFUNGEN\Rollen does not exist!
    pause
    exit /b 1
)

if not exist "C:\Rollen" (
    echo Creating destination folder C:\Rollen
    mkdir "C:\Rollen"
)


setlocal

set "processName=RoleManager.exe"
set "processPath=C:\Rollen\RoleManager.exe"

REM Check if the process is running
tasklist /FI "IMAGENAME eq %processName%" | find /I "%processName%" >nul
if %ERRORLEVEL%==0 (
    echo The program %processPath% is currently running.
    echo Please close the Program before copying files.
    pause
    REM Recheck after pause
    :waitForClose
    tasklist /FI "IMAGENAME eq %processName%" | find /I "%processName%" >nul
    if %ERRORLEVEL%==0 (
        echo The program is still running. Please close it.
        timeout /t 5 >nul
        goto waitForClose
    )
)



REM Temporarily rename role_config if it exists in destination
if exist "C:\Rollen\role_config" (
    ren "C:\Rollen\role_config" "role_config.bak"
)

REM Copy everything
xcopy /E /I /Y "V:\#VERKNUEPFUNGEN\Rollen\*" "C:\Rollen\"

REM Restore original role_config if it existed
if exist "C:\Rollen\role_config.bak" (
    del "C:\Rollen\role_config"
    ren "C:\Rollen\role_config.bak" "role_config"
)




echo.
echo Copy completed successfully!

echo Creating shortcut on desktop...
xcopy /E /I /Y "V:\#VERKNUEPFUNGEN\Rollen\RoleManager.lnk" "%USERPROFILE%\OneDrive - LCS Consulting und Service GmbH\Desktop"





echo.
echo All operations completed!
pause