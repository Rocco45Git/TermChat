@echo off
setlocal EnableDelayedExpansion

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
    echo %USERNAME%>"%USER_FILE%"
)

:: Load username
set /p USERNAME=<"%USER_FILE%"

:: MAIN LOOP
:LOOP

:: Fetch messages
powershell -Command "try { (Invoke-WebRequest '%REPO_RAW%' -UseBasicParsing).Content } catch { '' }" > "%ARCHIVE%"

:: Display messages (hide command posts)
cls
echo ----- TermChat -----
for /f "usebackq delims=" %%A in ("%ARCHIVE%") do (
    set line=%%A
    if not "!line:~0,1!"=="@" echo !line!
)
echo --------------------

:: Input
set /p MESSAGE=%USERNAME%: 

:: Check if message starts with @
if "%MESSAGE:~0,1%"=="@" (

    :: Extract command + target
    for /f "tokens=1,2" %%A in ("%MESSAGE%") do (
        set CMD=%%A
        set TARGET=%%B
    )

    :: OWNER CHECK
    if "%USERNAME%"=="Rocco44 (MOD)" (

        if /i "!CMD!"=="@ban" (
            if not "!TARGET!"=="Rocco44" (
                echo !TARGET!>>"%BANS%"
                echo [MOD] !TARGET! banned.
            )
            goto LOOP
        )

        if /i "!CMD!"=="@unban" (
            powershell -Command "(Get-Content '%BANS%' | Where-Object {$_ -ne '!TARGET!'}) | Set-Content '%BANS%'"
            echo [MOD] !TARGET! unbanned.
            goto LOOP
        )
    )

    :: NON-OWNER COMMANDS
    if /i "!CMD!"=="@givename" (
        echo [SYSTEM] Username !TARGET! is now available.
        goto LOOP
    )

    if /i "!CMD!"=="@help" (
        echo [AUTOMOD -> %USERNAME%] Commands: @ban, @unban, @givename, @help
        goto LOOP
    )

    goto LOOP
)

:: Normal message (append locally)
echo %USERNAME%: %MESSAGE%>>"%ARCHIVE%"

goto LOOP
