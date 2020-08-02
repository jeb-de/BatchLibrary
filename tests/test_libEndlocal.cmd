@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

setlocal DisableDelayedExpansion
if "%~1" NEQ "" set /a libUnittest.verbose=%1+0

call libUnittest
call libEndlocal
call libTime
call libString

call :setup1
setlocal enabledelayedexpansion
call :setup2


%$UT_testSuite:(echo ERROR: MACRO IS EMPTY)&:=%
exit /b

:setup1
set /a test_cnt=0

set /a n+=1
set "test[%n%]=^a!"^^b12345"

set /a n+=1
set "test[%n%]=bang ! only"
set /a n+=1
set "test[%n%]=caret ^ only"
set /a n+=1
set "test[%n%]=bang !, caret^ and amp &"
set /a n+=1
set "test[%n%]="
set /a n+=1
set "test[%n%]===Equals"
@rem        &"&^&!!!^^%^!
set /a n+=1
set test[%n%]=^&"&^&!!!^^%%^!
exit /b

:setup2
REM for /L %%n in (1 1 9) do set "test[1]=!test[1]!!test[1]!"

REM set "test[1]=!test[1]!!test[1]:~-10!"

set /a n+=1
set "test[%n%]=^!^<>|&!CR!!LF!"
set "test[%n%]=all specials !test[%n%]!"!test[%n%]!"

set /a n+=1
set "test[%n%]=Hello &^^ "^^^^  ^&" world^!!CR!*!LF!X"
set /a n+=1
set "test[%n%]=Line1!LF!Line2!LF!"
set /a n+=1
set "test[%n%]=Line1!CR!!LF!Line2!CR!"

set /a n+=1
set "longTest=."
for /L %%n in (1 1 14) DO (set^ longTest=!longTest:~-4000!!longTest:~-4000!)
(set^ test[%n%]=!longTest!!longTest:~-179!)
exit /b

:Testcase_EndlocalToBoth
%$UT_StartTestCase%
setlocal EnableDelayedExpansion

for /L %%n in (1 1 %n%) do (
	set "testVar=test[%%n]"
	%$UT_format2print% printableContent !testVar!
	%$strLen% !testVar! len
	if !libUnittest.verbose! GEQ 1 (
		echo --- !testVar! ---    text[!len!]='!printableContent:~0,70!'
	)
	call :Test_context Disable Disable !testVar!
	call :Test_context Enable Enable !testVar!
	if !libUnittest.verbose! GEQ 2 echo(
)
%$UT_ExitTestCase%
exit /b

:Test_context
setlocal EnableDelayedExpansion
set "startTime=%time%"

for /L %%n in ( 1 1 1 ) DO (
	set "result=not set by macro"
	set scopeDepth=0
	call :startTest %1 %2 %3
	set "errorCode=!errorLevel!"
	if "!errorCode!" NEQ "0" goto :break
)
:break
set "stopTime=%time%"
%$diffTime% startTime stopTime duration_ms

REM Output the result

if !libUnittest.verbose! GEQ 2 (
	set "format1=  %2 (#!test_cnt!)               "
	set "format2=%1/%2  "
	if "!errorCode!" == "0" (
	   set "postfix=   OK !duration_ms! ms"
	   echo !format1:~0,15! !postfix!
	) ELSE (
		set "postfix=<FAIL>"
	   echo !format1:~0,15! !postfix!
	   ( goto ) 2>nul
	   ( goto ) 2>nul
	   exit /b
	   
	)
)

for /F "tokens=1-3" %%1 in (""!testCnt!" "!testFailed!" "!startTestCaseCheck!"") DO ( 
	endlocal 
	endlocal 
	set "testCnt=%%~1" 
	set "testFailed=%%~2" 
	set "startTestCaseCheck=%%~3" 
	set "exitTestCaseCheck=1" 
) 
exit /b


:startTest
for /L %%n in (1 1 4) do (
	setlocal EnableDelayedExpansion & set /a scopeDepth+=1
)

setlocal %2DelayedExpansion & set /a scopeDepth+=1
setlocal %2DelayedExpansion & set /a scopeDepth+=1
REM echo %2DelayedExpansion

%$endlocal% result=%3

setlocal EnableDelayedExpansion
if "%scopeDepth%" NEQ "5" (
	echo *** ERROR: scopeDepth=%scopeDepth%, that is unexpected
	set errorCode=2
) ELSE (
	set "expect=!%~3!"
	%$UT_expectedVar% result expect
REM if "!result!" NEQ "!%~3!" (
	REM %$UT_format2print% printable result
	REM echo *** ERROR: result FAIL  '!printable!'
	REM set errorCode=1
)
REM endlocal
REM endlocal

if "!errorCode!" == "0" (
	REM *** Double check if scopeDepth is correct
	if "%scopeDepth%" NEQ "4" (
		echo *** ERROR: scopeDepth=%scopeDepth%, that is unexpected
		set errorCode=3
	)
)
(
	setlocal EnableDelayedExpansion
	for /F "tokens=1-3" %%1 in (""!testCnt!" "!testFailed!" "!startTestCaseCheck!"") DO ( 
		for /L %%n in (1 1 10) do endlocal
		set "testCnt=%%~1" 
		set "testFailed=%%~2" 
		set "startTestCaseCheck=%%~3" 
		set "exitTestCaseCheck=1" 
	) 
)

exit /b %errorCode%
