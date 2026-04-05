@echo off
:: TermChat Windows - anonymous, GitHub public repo, seamless cross-platform

setlocal enabledelayedexpansion

:: Config
set REPO_RAW=https://raw.githubusercontent.com/Rocco45Git/TermChat/main/messages.log
set ARCHIVE=%USERPROFILE%\.termchat_local.log
set USER_FILE=%USERPROFILE%\.termchat_user
set BANS=%USERPROFILE%\.termchat_bans.log

:: Setup files
if not exist "%ARCHIVE%" type nul > "%ARCHIVE%"
if not exist "%BANS%" type nul > "%BANS%"

:: Username setup
if not exist "%USER_FILE%" (
    :GETNAME
    set /p USERNAME=Choose your username (cannot be Rocco44 unless owner patch): 
    if "%USERNAME%"=="Rocco44" (
        echo That username is reserved.
        goto GETNAME
    )
    echo %USERNAME%>%USER_FILE%
)
for /f "delims=" %%u in (%USER_FILE%) do set USERNAME=%%u

:: Fetch messages from GitHub
:FETCH
powershell -Command "(Invoke-WebRequest %REPO_RAW%).Content" > "%ARCHIVE%.tmp"
move /Y "%ARCHIVE%.tmp" "%ARCHIVE%" >nul

:: Display messages excluding hidden posts
cls
echo ----- TermChat -----
for /f "usebackq tokens=*" %%m in ("%ARCHIVE%") do (
    set line=%%m
    if not "!line:~0,1!"=="@" echo !line!
)
echo -------------------

:: Main input loop
:INPUT
set /p MESSAGE=%USERNAME%: 

:: Check if command
set firstchar=%MESSAGE:~0,1%
if "%firstchar%"=="@" (
    set CMD=%MESSAGE:~0,7%
    if /i "!CMD!"=="@ban " (
        if "%USERNAME%"=="Rocco44 (MOD)" (
            for /f "tokens=2" %%t in ("!MESSAGE!") do echo %%t>>"%BANS%"
            echo [MOD] %%t banned.
        ) else echo Only the owner can ban.
        goto FETCH
    )
    if /i "!CMD!"=="@unban" (
        if "%USERNAME%"=="Rocco44 (MOD)" (
            for /f "tokens=2" %%t in ("!MESSAGE!") do (
                powershell -Command "(Get-Content '%BANS%' | Where-Object {$_ -ne '%%t'}) | Set-Content '%BANS%'"
            )
            echo [MOD] User unbanned.
        ) else echo Only the owner can unban.
        goto FETCH
    )
    if /i "!CMD!"=="@givenn" (
        for /f "tokens=2" %%n in ("!MESSAGE!") do echo [SYSTEM] Username %%n is now available.
        goto FETCH
    )
    if /i "!CMD!"=="@help  " (
        echo [AUTOMOD] Commands: @ban, @unban, @givename, @help, hidden posts start with @
        goto FETCH
    )
    goto FETCH
)

:: Normal message
echo %USERNAME%: %MESSAGE%>>"%ARCHIVE%"
goto FETCH
