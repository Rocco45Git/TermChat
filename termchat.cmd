@echo off
setlocal EnableDelayedExpansion

set BLOB_URL=https://jsonblob.com/api/jsonBlob/019d61d5-808c-7125-8911-f59a97277d99
set ARCHIVE=%USERPROFILE%\.termchat_local.log
set USER_FILE=%USERPROFILE%\.termchat_user
set BANS=%USERPROFILE%\.termchat_bans.log

if not exist "%ARCHIVE%" type nul > "%ARCHIVE%"
if not exist "%BANS%" type nul > "%BANS%"

:: USERNAME
if not exist "%USER_FILE%" (
:ask
set /p NAME=Choose username: 
if "%NAME%"=="Rocco44" goto ask
echo %NAME%>"%USER_FILE%"
)

set /p USERNAME=<"%USER_FILE%"

:loop

:: FETCH
powershell -Command "(Invoke-RestMethod '%BLOB_URL%').messages" > "%ARCHIVE%"

cls
echo ===== TermChat =====
for /f "usebackq delims=" %%A in ("%ARCHIVE%") do (
    set line=%%A
    if not "!line:~0,1!"=="@" echo !line!
)
echo ====================

:: BAN CHECK
findstr /x "%USERNAME%" "%BANS%" >nul
if %errorlevel%==0 (
    echo You are banned.
    timeout /t 3 >nul
    goto loop
)

set /p MESSAGE=%USERNAME%: 

:: COMMANDS
if "%MESSAGE:~0,1%"=="@" (

    for /f "tokens=1,2" %%A in ("%MESSAGE%") do (
        set CMD=%%A
        set ARG=%%B
    )

    if "%USERNAME%"=="Rocco44 (MOD)" (
        if /i "!CMD!"=="@ban" (
            echo !ARG!>>"%BANS%"
            goto loop
        )
        if /i "!CMD!"=="@unban" (
            powershell -Command "(Get-Content '%BANS%' | Where {$_ -ne '!ARG!'}) | Set-Content '%BANS%'"
            goto loop
        )
    )

    if "%USERNAME%"=="GalixigaGamez (MOD)" (
        if /i "!CMD!"=="@ban" (
            echo !ARG!>>"%BANS%"
            goto loop
        )
        if /i "!CMD!"=="@unban" (
            powershell -Command "(Get-Content '%BANS%' | Where {$_ -ne '!ARG!'}) | Set-Content '%BANS%'"
            goto loop
        )
    )

    if /i "!CMD!"=="@help" (
        echo [AUTOMOD] Commands: @ban @unban @givename @help
        goto loop
    )

    goto loop
)

:: SEND
powershell -Command ^
"$d=Invoke-RestMethod '%BLOB_URL%'; ^
$d.messages += '%USERNAME%: %MESSAGE%'; ^
Invoke-RestMethod -Method Put -Uri '%BLOB_URL%' -Body ($d | ConvertTo-Json -Depth 5) -ContentType 'application/json'"

goto loop
