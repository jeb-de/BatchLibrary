@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

setlocal
if "%~1" NEQ "" set /a libUnittest.verbose=%1+0

call libUnittest
call libArray
call libSubstitution

%$UT_testSuite:(#)ERROR:^ MACRO^ IS^ EMPTY^ IN^ %~0 :=%

exit /b

:testcase_SubstitutionOneLine
%$UT_StartTestCase% "One line commands"

:: #1
%$set% result="cd"
set "expect=%cd%"
%$UT_expectedVar% result expect

:: #2
%$set% result="call "%~d0\:_createOneLine1:\..\%~pnx0""
set "expect=This is one line"
%$UT_expectedVar% result expect

:: #3
%$set% result="call "%~d0\:_createLineWithSpecials:\..\%~pnx0""
set "expect=One line with bang ^!, caret ^^ and specials &%%|<>"
setlocal DisableDelayedExpansion
%$UT_expectedVar% result expect

%$UT_exitTestCase% %= EXIT =%
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:testcase_SubstitutionMultiline
%$UT_StartTestCase% "Multi line commands"

:: #1
%$set% result="ver"
for /F "delims=" %%L in ('ver') do set "expect=\n%%L"
set "delim=\n"
%$join% joinedStr result delim
%$UT_expectedVar% joinedStr expect

:: #2
%$set% result="call "%~d0\:_createMultiline1:\..\%~pnx0""
set "expect=Line1\nLine2\nLine3"
set "delim=\n"
%$join% joinedStr result delim
%$UT_expectedVar% joinedStr expect



%$UT_exitTestCase% %= EXIT =%
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b



:_createOneLine1
(echo This is one line)
exit /b

:_createLineWithSpecials
setlocal EnableDelayedExpansion
set "var=One line with bang ^!, caret ^^ and specials &%%|<>"
(echo !var!)
exit /b

:_createMultiline1
(echo Line1)
(echo Line2)
(echo Line3)
exit /b
