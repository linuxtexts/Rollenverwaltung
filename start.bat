@echo off
echo Copying Rollen folder from V:\#VERKNUEPFUNGEN\Rollen to C:\
echo.

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
        timeout /t 3 >nul
        goto waitForClose
    )
	
)


if exist "V:\#VERKNUEPFUNGEN\Rollen" (
    REM Temporarily rename role_config.json if it exists in destination
	if exist "C:\Rollen\role_config.json" (
		ren "C:\Rollen\role_config.json" "role_config.json.bak"
	)

	REM Copy everything
	xcopy /E /I /Y "V:\#VERKNUEPFUNGEN\Rollen\*" "C:\Rollen\"

	REM Restore original role_config if it existed
	if exist "C:\Rollen\role_config.json.bak" (
		del "C:\Rollen\role_config.json"
		ren "C:\Rollen\role_config.json.bak" "role_config.json"
	)
	echo Creating shortcut on desktop...
	xcopy /E /I /Y "V:\#VERKNUEPFUNGEN\Rollen\RoleManager.lnk" "%USERPROFILE%\OneDrive - LCS Consulting und Service GmbH\Desktop"
	echo.
	echo Copy completed successfully!
	echo.
	echo All operations completed!
)


echo RoleManager Starting...
rem powershell -Command "runas /user:immo-nrw\$($env:USERNAME -replace '^[^.]+' , 'admin') 'C:\Rollen\RoleManager.exe'"
powershell -File "C:\Rollen\ps1\start.ps1"