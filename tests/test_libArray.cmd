@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

setlocal
set UT_VERBOSE=1
if "%~1" NEQ "" set /a libUnittest.verbose=%1+0

call libUnittest
call libArray
call libString

%$join% load
%$split% load

%$UT_testSuite:(echo ERROR: MACRO IS EMPTY)&:=%


exit /b

:testSuiteXX
setlocal EnableDelayedExpansion
for /F "delims=#" %%a in ('prompt #$E# ^& for %%a in ^(1^) do rem') do set "esc=%%a"
For /F "tokens=1-31" %%%esc% in ("ERR1 ERR2 ERR3 ERR4 ERR5 ERR6 ERR7 ERR8 ERR9 ERR10 ERR11 ERR12 ERR13 ERR14 ERR15 ERR16 ERR17 ERR18 ERR19 ERR20 ERR21 ERR22 ERR23 ERR24 ERR25 ERR26 ERR27 ERR28 ERR29 ERR30 ERR31") DO ^
For /F "tokens=1-31" %%: in ("ERR1 ERR2 ERR3 ERR4 ERR5 ERR6 ERR7 ERR8 ERR9 ERR10 ERR11 ERR12 ERR13 ERR14 ERR15 ERR16 ERR17 ERR18 ERR19 ERR20 ERR21 ERR22 ERR23 ERR24 ERR25 ERR26 ERR27 ERR28 ERR29 ERR30 ERR31") DO ^
FOR /F %%C in ('findstr /R "^:testCase" "%~f0"') do (
	set "result=unset"
	set /a testCnt=0
	set /a testFailed=0
	set "testName=%%C"
	set "testName=!testName:*_=!"
	set "endlocalCheck="
	call %%C
	if not defined endlocalCheck (
		echo ERROR: *** FATAL *** too many endlocal's called, probably by a macro
	)
	if !errorlevel! EQU 0 (
		set "result=OKAY"
		if !libUnittest.verbose! GEQ 1 echo Result OKAY, Tests: !testCnt!, Failed: !testFailed!
	) ELSE (
		set "result=FAIL"
		echo Result FAIL, Tests: !testCnt!, Failed: !testFailed!
	)
	
	if !libUnittest.verbose! GEQ 1 echo(
	if "result" == "FAIL" goto :exitLoop
)
:exitLoop
exit /b

:###testCase_append
%$UT_StartTestCase% %0 "append"

set /a arr.len=0
set "arr[!arr.len!]=Line1" & set /a arr.len+=1

set "newEntry=Line2"
set "expect=2"
%$UT_TEST_PRE%
%$array.append% arr newEntry
%$UT_TEST_POST_ASSERT% arr.len expect

set "newEntry=Line3"
set "expect=3"
%$UT_TEST_PRE%
%$array.append% arr newEntry
%$UT_TEST_POST_ASSERT% arr.len expect

set "newEntry=Line4"
set "expect=4"
%$UT_TEST_PRE%
%$array.append% arr newEntry
%$UT_TEST_POST_ASSERT% arr.len expect

set "expect=Line1!$LF!Line2!$LF!Line3!$LF!Line4"
%$UT_TEST_PRE%
%$join% resultStr arr
%$UT_TEST_POST_ASSERT% resultStr expect

%$UT_exitTestCase% %= EXIT =%

:testCase_join
%$UT_StartTestCase% %0 "join"

set /a arr.len=0
set "arr[!arr.len!]=Line1" & set /a arr.len+=1
set "arr[!arr.len!]=Line2" & set /a arr.len+=1
set "arr[!arr.len!]=Line3" & set /a arr.len+=1
set "arr[!arr.len!]=Line4" & set /a arr.len+=1
set /a arr.max=arr.len-1

set "delim=,"
set "expect=Line1!delim!Line2!delim!Line3!delim!Line4"
%$UT_TEST_PRE% "Join 4 lines, delim is a comma"
%$join% resultStr arr delim
%$UT_TEST_POST_ASSERT% resultStr expect

set "arr[0]=Line1"
set "arr[1]=Line2"
set "arr[2]=Line3"
set "arr[3]=Line4"
set /a arr.len=4, arr.max=arr.len-1
set "delim=*."

set "expect=Line1!delim!Line2!delim!Line3!delim!Line4"
%$UT_TEST_PRE% "Join 4 lines, delim is a dot"
%$join% resultStr arr delim
%$UT_TEST_POST_ASSERT% resultStr expect

set "arr[0]=Line1"
set "arr[1]=Line2"
set "arr[2]=Line3"
set "arr[3]=Line4"
set /a arr.len=4, arr.max=arr.len-1
set "delim=!$LF!"

set "expect=Line1!delim!Line2!delim!Line3!delim!Line4"
%$UT_TEST_PRE% "Join 4 lines, delim is a line feed"
%$join% resultStr arr delim
%$UT_TEST_POST_ASSERT% resultStr expect

set /a arr.len=0, arr.max=arr.len-1
set "delim=,"
set "expect="
%$UT_TEST_PRE% "Join 0 lines, delim is a comma"
%$join% resultStr arr delim
%$UT_TEST_POST_ASSERT% resultStr expect

set /a arr.len=1, arr.max=arr.len-1
set "arr[0]=;Line1"
set "delim=,"
set "expect=;Line1"
%$UT_TEST_PRE% "Join 1 line, delim is a comma"
%$join% resultStr arr delim
%$UT_TEST_POST_ASSERT% resultStr expect
%$UT_exitTestCase% %= EXIT =%

:testCase_join_8098_chars
%$UT_StartTestCase% %0 "join"
set "str="
for /L %%n in (0 1 89) do set "str=!str!o"

set /a arr.len=89, arr.max=arr.len-1
for /L %%n in (0 1 !arr.max!) do (
	set "arr[%%n]=!str!"
)
	
set "delim=-"
set "expect=8098"
%$UT_TEST_PRE% "Join 89 lines a 90 chars, delim is a sign, len=8098"
%$join% resultStr arr delim
%$strLen% resultLen resultStr
%$UT_TEST_POST_ASSERT% resultLen expect

%$UT_exitTestCase% %= EXIT =%

:testCase_join_up_to_8174_chars
REM *** 8175 chars fails in DDE
REM *** 8177 chars fails in EDE

%$UT_StartTestCase% %0 "join"

set "str="
for /L %%n in (0 1 89) do set "str=!str!o"
set /a arr.len=90, arr.max=arr.len-1
for /L %%n in (0 1 !arr.max!) do (
	set "arr[%%n]=!str!"
)

FOR /L %%# in (70 1 74) do (
	set "arr[89]=!str!XXXXXXXX"	
	set "arr[89]=!arr[89]:~0,%%#!"
	set "delim=-"
	set last_line_len=%%#
	set /a expect=89*91 + last_line_len
	%$UT_TEST_PRE% "Join 90 lines a 90 chars, last line len=!last_line_len!, resultLen=!expect!"
	%$join% resultStr arr delim
	%$strLen% resultLen resultStr
	%$UT_TEST_POST_ASSERT% resultLen expect
)

%$UT_exitTestCase% %= EXIT =%

:testCase_split
%$UT_StartTestCase% %0 "split"

REM ***
set "var=Line1!$LF!Line2!$LF!Line3!$LF!Line4!$LF!Line5"
set "expect=5"
%$UT_TEST_PRE% "Split into 5 parts by LF"
%$split% resultArr1 var
%$UT_TEST_POST_ASSERT% resultArr1.len expect

REM ***
set "var="
set "expect=0"
%$UT_TEST_PRE% "empty var, nothing to split"
%$split% resultArr1 var
%$UT_TEST_POST_ASSERT% resultArr1.len expect

REM ***
set "var=;one-part"
set "expect=1"
%$UT_TEST_PRE% "single value, split to 1 part"
%$split% resultArr1 var
%$UT_TEST_POST_ASSERT% resultArr1.len expect

REM ***
set "var=Line1#Line2#Line3#Line4#Line5"
set "delim=#"
set "expect=5"
%$UT_TEST_PRE% "Split into 5 parts by delim=#"
%$split% resultArr1 var delim
%$UT_TEST_POST_ASSERT% resultArr1.len expect

if !libUnittest.verbose! GEQ 2 set resultArr
REM %$UT_TEST_POST_ASSERT% resultStr expect

%$UT_exitTestCase%  %= EXIT =%
