@echo off
:: TermChat Windows - terminal chat, GitHub backend
set REPO_RAW=https://raw.githubusercontent.com/Rocco45Git/TermChat/main/messages.log
set REPO_API=https://api.github.com/repos/Rocco45Git/TermChat/contents/messages.log
set TOKEN_FILE=%USERPROFILE%\.termchat_token
set ARCHIVE=%USERPROFILE%\.termchat_local.log
set USER_FILE=%USERPROFILE%\.termchat_user

:: Username setup
if not exist "%USER_FILE%" (
    :getname
    set /p USERNAME="Choose your username (cannot be Rocco44): "
    if "%USERNAME%"=="Rocco44" (
        echo That username is reserved.
        goto getname
    )
    echo %USERNAME%>%USER_FILE%
)
for /f "delims=" %%u in (%USER_FILE%) do set USERNAME=%%u

:: Ensure archive exists
if not exist "%ARCHIVE%" type nul > "%ARCHIVE%"

:mainloop
cls
echo ------ TermChat ------
powershell -Command "(Invoke-WebRequest %REPO_RAW%).Content" > "%ARCHIVE%.tmp"
type "%ARCHIVE%.tmp" | findstr /v "^@" 
echo ---------------------
set /p MESSAGE="%USERNAME%: "

:: Handle command posts
echo %MESSAGE% | findstr /b "@" >nul
if %ERRORLEVEL%==0 (
    echo Command detected, processing...
    :: Commands would be parsed similarly as in Linux script using PowerShell for API push
    goto mainloop
)

:: Append normal message
powershell -Command "Add-Content -Path '%ARCHIVE%' -Value ('%USERNAME%: %MESSAGE%')"
:: Push message via API (PowerShell curl PUT with token)
goto mainloop
