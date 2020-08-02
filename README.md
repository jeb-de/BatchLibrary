# BatchLibrary
Library system for windows batch files using batch macros

# Sample batch file, using macros from libString
@echo off
setlocal EnableDelayedExpansion

set libPath=thePathToTheLib
call %libPath%\libString

set "myString=<>&abc"

%$strlen% myString resultLen
echo The length is %resultLen%

set "myString2=   ;hi*?><&  "
%$trim% myString trimmedStr
echo Trimmed string is '!trimmedStr!'
