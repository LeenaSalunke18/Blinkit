@echo off

:: Take and put the Steem username from username.txt and put it in variable %username%
	set /p steemusername=<c:\blinkit\config\username.txt
	
:: put the saved Steem username inside the URL for the GUI to load the avatar image of the user. 
	echo https://steemitimages.com/u/%steemusername%/avatar > "C:\blinkit\config\avatar.txt"
	
	
	