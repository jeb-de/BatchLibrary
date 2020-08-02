@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

setlocal
if "%~1" NEQ "" set /a libUnittest.verbose=%1+0

call libUnittest
call libTime

%$UT_testSuite:(echo ERROR: MACRO IS EMPTY)&:=%

exit /b

:testSuite
FOR /L %%n in (1 1 3) do (
	if !libUnittest.verbose! GEQ 1 echo Test%%n:
	call :test%%n
	if !libUnittest.verbose! GEQ 1 echo(
)
exit /b

:testcase_$diffTime
%$UT_StartTestCase% "$diffTime"

setlocal EnableDelayedExpansion 
set "value=12345"
set "start=01:59:07.04"
set "stop= 8:04:55.99"
%$diffTime% start stop result
set "expect=21948950"
%$UT_expectedVar% result expect

%$UT_ExitTestCase%
exit /b

:testcase_$timeToMs
%$UT_StartTestCase% "$timeToMs"

setlocal EnableDelayedExpansion 
set "time_1=01:59:07.04"
set "result="
%$timeToMs% time_1 result
set "expect=7147040"
%$UT_expectedVar% result expect

%$UT_ExitTestCase%
exit /b
