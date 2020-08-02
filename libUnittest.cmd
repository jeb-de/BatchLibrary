@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

%$LIB_LOAD_ONCE:call "%~dp0\libBase.cmd" "%~f0" :=%
%$LIB_INCLUDE% libEndlocal

if not defined libUnittest.verbose ( set "libUnittest.verbose=1" )

REM  %$LIB_NEW_MACRO%   $UT_testsuite :define_$UT_testsuite
%$LIB_CREATE_TRAMPOLINE% $UT_testsuite :fn_$UT_testsuite "%%%%~f0"

%$LIB_CREATE_TRAMPOLINE% $UT_StartTestCase
%$LIB_NEW_MACRO%   $UT_ExitTestCase
%$LIB_CREATE_TRAMPOLINE% $UT_expectedVar
%$LIB_CREATE_TRAMPOLINE% $UT_format2print

%$LIB_NEW_MACRO% $UT_TEST_PRE
%$LIB_NEW_MACRO% $UT_TEST_POST_ASSERT

exit /b

REM *** Use of the variable libUnittest.verbose:
REM *** set libUnittest.verbose=0  -- Minimal output. One line per testsuite, only failed tests are shown
REM *** set libUnittest.verbose=1  -- Output each testcase
REM *** set libUnittest.verbose=2  -- Output extra debug informations, to find failures in the test code itself

REM *********************************************
REM *** Parameter check
call :table tableBS		 8		%= 8 -39 =%
call :table tableESC 	 27		%= 27-58 =%
call :table tableColon 	 58		%= 58-89 =%
call :table table@ 	     64  	%= 64-95 =%
call :table tableLower_a 97		%= 97-128 =%
@for /f "usebackq delims= " %%C in (`copy /z "%~f0" nul`) do @set "CR=%%C"
(set LF=^

)

For /F "tokens=1-31" %%%BS% in ("%tableBS%") DO ^
For /F "tokens=1-31" %%%esc% in ("%tableESC%") DO ^
For /F "tokens=1-31" %%: in ("%tableColon%") DO ^
For /F "tokens=1-31" %%@ in ("%table@%") DO ^
For /F "tokens=1-31" %%[ in ("%tableLower_a%") DO ^
REM **************************************************

:define_$UT_ExitTestCase
%$lib.macrodefine.disabled% $UT_ExitTestCase

set ^"%MACRO_NAME%=( %\n%
	setlocal EnableDelayedExpansion %\n%
	for /F "tokens=1-3" %%1 in (""!testCnt!" "!testFailed!" "!startTestCaseCheck!"") DO ( %\n%
		endlocal %\n%
		endlocal %\n%
		set "testCnt=%%~1" %\n%
		set "testFailed=%%~2" %\n%
		set "startTestCaseCheck=%%~3" %\n%
		set "exitTestCaseCheck=1" %\n%
	) %\n%
	exit /b %\n%
)"
%$endlocal% %MACRO_NAME%
exit /b
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b


:define_$UT_TEST_PRE
set $UT_SCOPE_DEPTH=4
%$lib.macrodefine.disabled%

set ^"%MACRO_NAME%=for %%$ in (1 2) do if %%$==2 (%\n%
	setlocal EnableDelayedExpansion %\n%
	for /F "tokens=1,2,* delims== " %%1 in ("!$UT_EXP_MODE! !argv!") do (%\n%
		endlocal %\n%
		endlocal %\n%
		if "%%2" NEQ "" set "%%2=[EMPTY]" %\n%
		set "_ut_testname=%%~3" %\n%
		if defined UT_VERBOSE echo(Test: "%%~3" %\n%
		set /a scope_level=0 %\n%
		for /L %%# in (1 1 %$UT_SCOPE_DEPTH%) do ( %\n%
			setlocal %%1DelayedExpansion %\n%
			set /a scope_level+=1 %\n%
		)%\n%
	)%\n%
) else setlocal ^& set argv= "
%$endlocal% %MACRO_NAME%
exit /b
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:define_$UT_TEST_POST_ASSERT
%$lib.macrodefine.disabled%

set ^"%MACRO_NAME%=for %%$ in (1 2) do if %%$==2 (%\n%
	set /a tmp=testCnt+1 %\n%
	for /F "tokens=1,2 delims== " %%1 in ("!argv!") do (%\n%
		FOR /F "delims=" %%5 in ("!$UT_EXP_MODE! !testName![!tmp!]") DO ( %\n%
			endlocal%\n%
			if "!%%1!" NEQ "!%%2!" ( %\n%
				endlocal %\n%
				call "%~d0\:_UT_TEST_POST_ASSERT_failure:\..\%~pnx0" "%%1" "%%2" %\n%
			) %\n%
			endlocal%\n%
			FOR /L %%# in (%$UT_SCOPE_DEPTH% -1 0) DO ( %\n%
				set "_UT_temp=" %\n%
				set /a "_UT_temp=1 / (scope_level-%%#)" 2^>NUL %\n%
				if defined _UT_temp ( %\n%
					setlocal EnableDelayedExpansion %\n%
					echo ERROR: Scope level is !scope_level!, expected %%# in Test: "!_ut_testname!" %\n%
					exit /b 3 %\n%
				) %\n%
				endlocal %\n%
			) %\n%
			set /a testCnt+=1 %\n%
			setlocal EnableDelayedExpansion %\n%
			break echo     Testcase %%5 %\n%
			endlocal %\n%
		) %\n%
	)%\n%
) else setlocal EnableDelayedExpansion ^& setlocal ^& set argv= "

%$endlocal% %MACRO_NAME%
exit /b
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:_UT_TEST_POST_ASSERT_failure
setlocal EnableDelayedExpansion
echo ERROR: in !testLibraryFile! Testcase !testName![!testCnt!], in Test: "!_ut_testname!"
echo ERROR: Assertion FAILED
%$showVariable% %~1
%$showVariable% %~2
endlocal
(
	(goto) 2>NUL
	FOR /L %%# in (%$UT_SCOPE_DEPTH% -1 0) DO (
		set "_UT_temp="
		set /a "_UT_temp=1 / (scope_level-%%#)" 2>NUL
		if defined _UT_temp (
			echo ERROR: Scope level is !scope_level!, expected %%#
		)
		endlocal
	)
	exit /b 3
)

exit /b
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b


%$endlocal% %MACRO_NAME%
exit /b
REM ----- End of function -----

::: Starts all testcases from a single unittest file
::: Stops when one testcase fails
:fn_$UT_testSuite <filename>
setlocal EnableDelayedExpansion

set "testLibraryFile=%~1"
set /a testCase.success=0
set /a testCase.fail=0
set /a totalTests.success=0
set /a totalTests.fail=0
for /F "delims=#" %%a in ('prompt #$E# ^& for %%a in ^(1^) do rem') do set "UT_ESC=%%a"

REM *** Here a special for-parameter %%<ESC> is used to avoid interference with some tests
REM *** Else, the test_libForParameter would fail, because it detects all FOR-parameters in the ASCII range 32-126
FOR /F %%%UT_ESC% in ('findstr /I /R "^:testCase_" "%~1"') do (
	set "result=[result not set]"
	set /a testCnt=0
	set /a testFailed=0
	set "testName=%%%UT_ESC%"
	set "testName=!testName:*_=!"
	set "startTestCaseCheck="
	set "exitTestCaseCheck="

	if !libUnittest.verbose! GEQ 4 (
	echo sub
		call :strongSeparation "%~f1" "%%%UT_ESC%"
	) ELSE (
		REM *** Direct call
		set "$UT_EXP_MODE=Disable"
		call "%~d1\%%%UT_ESC%:\..\%~pnx1"
		set "$UT_EXP_MODE=Enable"
		call "%~d1\%%%UT_ESC%:\..\%~pnx1"
	)
	set "errorCode=!errorlevel!"
	set /a totalTests.success+=testCnt
	set /a totalTests.fail+=testFailed
	if not defined startTestCaseCheck (
		echo ERROR: in %~f1 %%%UT_ESC%
		echo ERROR: *** FATAL *** startTestCaseCheck is not set, probably $UT_StartTestCase missing
		set errorCode=1
	) ELSE 	if not defined exitTestCaseCheck (
		echo ERROR: in %~f1 %%%UT_ESC%
		echo ERROR: *** FATAL *** exitTestCaseCheck is not set, probably $UT_exitTestCase missing
		set errorCode=1
	)

	if !errorCode! EQU 0 (
		set /a testCase.success+=1
		set "result=OKAY"
		if !libUnittest.verbose! GEQ 1 (
			echo Result !result!, Failed: !testFailed! Tests: !testCnt!
			echo(
		)
	) ELSE (
		set /a testCase.fail+=1
		set "result=FAIL"
		echo Result !result!, Failed: !testFailed! Tests: !testCnt!
		echo(
	)
	if "result" == "FAIL" goto :exitLoop
)
echo Testcase !testCase.success!/!testCase.fail! (succ/failed), Total tests: !totalTests.success!/!totalTests.fail! (succ/failed), %~f1
exit /b

:exitLoop
echo !testCnt! tests okay, !testFailed! failed, %~f1
echo ERROR in testcase detected
exit /b
REM ----- End of function -----

::: Used to
:strongSeparation "DestinationFile" "TestName"
echo Starting subprocess
cmd /c "%~d1\%~2:\..\%~pnx1"
echo return from subprocess
exit /b

:fn_$UT_expectedVar
setlocal EnableDelayedExpansion
set /a testCnt+=1
set "received=!%~1!"
set "expected=!%~2!"
if "!received!" EQU "!expected!" (
	if !libUnittest.verbose! GEQ 2 (
		call :fn_$UT_format2print printReceived received
		if defined printReceived if "!printReceived:~50,1!" NEQ "" set "printReceived=!printReceived:~0,50!..."
		echo Testcase !testName![!testCnt!] OKAY "!printReceived!"
	)
	set "errorcode="
) ELSE (
	call :fn_$UT_format2print printReceived received
	call :fn_$UT_format2print printExpected expected
	echo Test !testName![!testCnt!] stops by unexpected result
	echo - received "!printReceived!"
	echo - expected "!printExpected!"
	set /a testFailed+=1
	set errorcode=1
)

(
	REM *** Cancel all
	endlocal
	endlocal
	endlocal
	endlocal
	if defined cancel ( goto ) 2> nul
	REM ( goto ) 2> nul
	set "testCnt=%testCnt%"
	set "testFailed=%testFailed%"
	set "startTestCaseCheck=%startTestCaseCheck%"
	set "exitTestCaseCheck=1"
	exit /b %errorcode%
)
exit /b

:fn_$UT_StartTestCase
if "!$UT_EXP_MODE!" EQU "Enable" (
	set "_test_mode=EDE"
) ELSE (
	set "_test_mode=dde"
)
if !libUnittest.verbose! GEQ 1 (
	for /F "tokens=4 delims=:_" %%# in ("%~1") do (
		echo -------- Test case %%#, "%~2" Mode: %_test_mode% --------
	)
)
set "startTestCaseCheck=1"
REM set /a scope_level+=1
REM setlocal
REM set /a scope_level+=1
exit /b

:fn_$UT_format2print
rem setlocal EnableDelayedExpansion
(set LF=^
%=empty=%
)
set "content=!%~2!"

if defined content (
FOR %%L in ("!$LF!") DO (
FOR %%C in ("!$CR!") DO (
	set "content=!content:%%~L=\n!"
	set "content=!content:%%~C=\r!"
	set "content=!content:	=\t!"
)
)
)
set "%~1=!content!"
exit /b
REM FOR /F "delims=" %%V in (""!content!"") DO (
	REM endlocal
	REM set "%~1=%%~V"
	REM exit /b
REM )
