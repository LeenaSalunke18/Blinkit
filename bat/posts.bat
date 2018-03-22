@echo off    
   
:: Take and put the username from username.txt and put it in variable %username%
	set /p steemusername=<c:\blinkit\config\username.txt
 
:: Get the flashdrive letter set by the user in the Blinkit GUI, stored in \config\ and put it into variable %flashdrive% 
	set /p flashdrive=<c:\blinkit\config\drive.txt

:: Get the Blink length set by the user in the Blinkit GUI, stored in \config\ and put it into variable %blinklength%
	set /p blinklength=<c:\blinkit\config\blinklength.txt
    
:: Colour settings
	set ESC=
	set Red=%ESC%[31m
	set White=%ESC%[37m
	set Green=%ESC%[32m
	set Magenta=%ESC%[35m
	set Blue=%ESC%[94m
   
:: Display welcome message to the user welcome.txt      
	type c:\blinkit\config\welcome.txt
	
	
:: Let the user know that Blinkit is going to watch for Posts by displaying the text:
	echo Blinkit - Steem Account Posts

:: Let the user know a sound is being played by writing the text:
	echo.
	echo %Magenta%Testing %White%Play sound...

:: Play the notification sound that is set for usb stick 1 	  
	set /p sound=<c:\blinkit\config\sound.txt 
	set "file=C:\blinkit\sounds\%sound%"
	( echo Set Sound = CreateObject("WMPlayer.OCX.7"^)
	echo Sound.URL = "%file%"
	echo Sound.Controls.play
	echo do while Sound.currentmedia.duration = 0
	echo wscript.sleep 100
	echo loop
	echo wscript.sleep (int(Sound.currentmedia.duration^)+1^)*1000) >sound.vbs
	start /min sound.vbs
	echo.  
	  
:: Let the user know the led is going to be blinked, on the %flashdrive% letter by displaying the text:  	  
	echo %Magenta%USB Flash Drive: %White%%flashdrive%
	echo.
	echo %Magenta%Testing %White%Blink LED 

:: Blink the LED, by copying the LED file from the Blinkit folder to the USB flashdrive	
	xcopy c:\blinkit\ledfile\ledfile%blinklength%.led %flashdrive%. /Y > nul  
	echo.


::  Download the latest STEEM and SBD Price and put it inside a txt files
	powershell -Command "Invoke-WebRequest https://api.coinmarketcap.com/v1/ticker/steem/ -OutFile C:\blinkit\config\steemprice.txt"
	powershell -Command "Invoke-WebRequest https://api.coinmarketcap.com/v1/ticker/steem-dollars/ -OutFile C:\blinkit\config\sbdprice.txt"

:: Find and display the latest STEEM and SBD Price in USD from the downloaded txt files
	echo Steem Price
	for /F "delims=" %%a in ('findstr /I ""price_usd"" C:\blinkit\config\steemprice.txt') do set "batToolDir0=%%a"
	for /F "delims=" %%a in ('findstr /I ""price_usd"" C:\blinkit\config\sbdprice.txt') do set "batToolDir2=%%a"
	echo %Blue%Steem: 				"%batToolDir0%"
	echo %Blue%Steem Dollar: 			"%batToolDir2%"

:: Update the STEEM and SBD price in USD into txt files for the steem prices in the Blinkit interface
	echo "%batToolDir0%" > "C:\blinkit\config\steempricestriped.txt"
	echo "%batToolDir2%" > "C:\blinkit\config\sbdpricestriped.txt"
	echo.


:: Display Steem username
	echo %White%Steem Username 
	echo %Blue%%steemusername%%White%
	echo.
	  
:: Download the number of Followers from a user inside a txt file
	powershell -Command "Invoke-WebRequest https://api.steem.place/getFollowersCount/?a=%steemusername% -OutFile C:\blinkit\config\displayfollowers.txt"

:: Display the downloaded followers	
	echo %White%Followers%Blue% 
	type C:\blinkit\config\displayfollowers.txt 
	echo.
	  
:: Display the saved Username and Flash drive letter and let the user know that the program is starting to look for new Posts
	echo.
	echo %White%Preparing BlinkIt, 
	echo USB Flash Notifications for %Blue%%steemusername%%White% on USB flash drive: %flashdrive% ...	  
	timeout 4 
	  

:: Blinkit Posts Script

:: Download the number of posts from a steem user, from the Web Api and save it into a txt file
	powershell -Command "Invoke-WebRequest https://api.steem.place/getPostCount/?a=%steemusername% -OutFile C:\blinkit\config\downloadposts.txt"
	
:main   


:: Download the number of posts from a steem user, from the Web Api and save it into a txt file
	powershell -Command "Invoke-WebRequest https://api.steem.place/getPostCount/?a=%steemusername% -OutFile C:\blinkit\config\downloadposts2.txt"
    

:: Compare the 2 downloaded posts txt files if different go to "notification", if the files are the same go to "next"  
    fc C:\blinkit\config\downloadposts.txt C:\blinkit\config\downloadposts2.txt > nul
	if errorlevel 1 goto notification 
	if errorlevel 0 goto next
..		
		
:next
:: let the user know the program is running by displaying the text:   
	echo.
	echo %Magenta%Blinkit is running...
	
:: Download new data to compare, into "download2.txt", and go back to "main" to compare the files again
	powershell -Command "Invoke-WebRequest https://api.steem.place/getPostCount/?a=%steemusername% -OutFile C:\blinkit\config\downloadposts2.txt" 
	goto main

	
:notification
:: Let the user know, there is a new Post! by displaying the text:  
	echo Blinkit is running... %Blue%NEW Post from %steemusername%!
	echo %White%
	echo %Magenta%ACTION LED BLINKED! 
  
:: Let the user know, there is a new Post, and blink the LED by copying the LED file to the flash drive
	xcopy c:\blinkit\ledfile\ledfile%blinklength%.led %flashdrive%. /Y > nul  
	
	call c:\blinkit\bat\blinksonoff.bat 
	
	
	
:: Play the notification sound that is set for usb stick 1 
	start /min sound.vbs
	timeout 1
	echo %White%

:: Download new data to compare, and go back to "main" and continue to look for for new posts.
	powershell -Command "Invoke-WebRequest https://api.steem.place/getPostCount/?a=%steemusername% -OutFile C:\blinkit\config\downloadposts.txt"	
	goto main

	
:: The username.txt must be ASCII encoding more about this here:
:: https://stackoverflow.com/questions/854360/visual-studio-inserts-invalid-characters-in-batch-files
:: https://stackoverflow.com/questions/10024445/encoding-to-be-used-for-ansi-vb-net

	
    