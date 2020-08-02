@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

setlocal
if "%~1" NEQ "" set /a libUnittest.verbose=%1+0

call libUnittest
call libArguments

%$UT_testSuite:(echo ERROR: MACRO IS EMPTY)&:=%

exit /b

:argumentTest
set "result=NOT SET"
%$getArgLine(%   %* %$)getArgLine% result
exit /b

:testCase_fullArgs
%$UT_StartTestCase% %0 "Full Args"

set "args=arg1 arg2 arg3"
set "expect=arg1 arg2 arg3"
call :argumentTest %%args%%
%$UT_expectedVar% result expect

set "args=arg1 arg2 arg3"
set "expect=arg1 arg2 arg3"
call :argumentTest %%args%%
%$UT_expectedVar% result expect

set "args=  trim arg1 arg2 arg3  "
set "expect=trim arg1 arg2 arg3"
call :argumentTest %%args%%
%$UT_expectedVar% result expect

set   "args=arg1 caret ^^ percent %% lastArg"
set "expect=!args:^^=^!"
call :argumentTest %%args%%
%$UT_expectedVar% result expect

set   "args=crashArg ^& "amp2 ^&"  lastArg"
set "expect=crashArg & "amp2 ^&"  lastArg"
call :argumentTest %%args%%
%$UT_expectedVar% result expect

%$UT_exitTestCase%
