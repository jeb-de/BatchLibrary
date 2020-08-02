@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

%$LIB_LOAD_ONCE:setlocal EnableDelayedExpansion & call :standalone & call "%~dp0\libBase.cmd" "%~f0" :=%

call libUnittest

call libMacro
call libString
call libTime

%$LIB_LOAD_MACRO% $trimUpperCase

%$UT_testSuite:(echo MACRO IS EMPTY)&:=%

exit /b

:standalone 
::: The test is called directly, no libraries are loaded before
if "%~1" NEQ "" set /a libUnittest.verbose=%1+0
exit /b

:define_$trimUpperCase
%$lib.macrodefine.disabled%
set ^"%MACRO_NAME%=for %%# in (1 2) do if %%#==2 (%\n%
	for /F "tokens=1,2 delims== " %%1 in ("!argv!=!argv!") do (%\n%
		(set^^ str=!%%2!) %\n%
		%$callMacro% $trim strTrim str %\n%
		%$callMacro% $toUpper strUpper strTrim %\n%
%= 		*** copy the result =% %\n%
		%$$endlocalForParam1:arg1=strUpper%
	)%\n%
) else 	setlocal EnableDelayedExpansion ^& setlocal EnableDelayedExpansion ^& set argv= "

%$endlocal% %MACRO_NAME%
exit /b
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b


:testCase_Call_a_macro_from_a_macro
%$UT_StartTestCase% %0 "Call a macro from a macro"

::: #1
set "var=  trim and uppercase   "
%$trimUpperCase% result var
set "expect=TRIM AND UPPERCASE"
%$UT_expectedVar% result expect

%$UT_exitTestCase%
-----------------------
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:testCase_compress
%$UT_StartTestCase% %0 "Compress a macro by trimming all lines"

%$lib.macrodefine.disabled%
set ^"test_macro1=Line1%\n%
	"  Line2  " %\n%
		Line3	%\n%
	Line4	%\n%
	set "pathext=;" %\n%
	."

%$endlocal% test_macro1

::: #1
%$compress% test_macro1
%$UT_format2print% result test_macro1
set "expect=Line1\n"  Line2  "\nLine3\nLine4\nset "pathext=;"\n."
%$UT_expectedVar% result expect

::: #2
echo Test #2
set "var=!expect!"
%$compress% var
%$UT_expectedVar% result expect

::: #3
echo Test #3
set "var=!$compress!"
set "comp1.start=%time%"

%$fast_compress% var
set "comp1.stop=%time%"
ECHO -------------
set "compressed=!var!"
set "comp2.start=%time%"
%$fast_compress% compressed
set "comp2.stop=%time%"
%$UT_expectedVar% compressed var
%$diffTime% comp1
%$diffTime% comp2
echo !comp1.diff!ms !comp2.diff!ms

%$UT_exitTestCase%
-----------------------
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b
