@echo off
echo Session 0 Escalation script
echo By Chris Adams in 2013.
echo.
echo Gives you access to the windows services desktop ("session 0").

@rem BatchGotAdmin - utility to get admin access
@rem Full credit to Evan Greene:
@rem https://sites.google.com/site/eneerge/home/BatchGotAdmin
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

@rem The meaty bit.
>nul 2>&1 sc query cmd || sc create cmd binPath= "cmd /k start" type= interact type= own
>nul 2>&1 sc start cmd
>nul 2>&1 sc delete cmd

echo Create a service called "cmd".
echo This service will kick off a cmd.exe on the session 0 desktop.
echo That cmd.exe launches a second cmd.exe and immediately exits.
echo This dodges the Service Control Manager's timeout-if-no-response logic.
echo You'll see an error saying the service died, this is normal.
echo.
echo Please check the taskbar for the "Interactive Services Detection" window.
echo Check the ui0detect service is running if not.
echo From the command prompt on the services desktop, you will be able
echo to launch anything eg. Notepad or explorer.exe
echo.
echo In Explorer on the services desktop, you may not be able to perform
echo file operations. You can however access files via a File-^>Open dialog,
echo eg. from within Notepad.exe.
echo.
echo Enjoy!
pause