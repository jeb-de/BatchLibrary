@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

setlocal
if "%~1" NEQ "" set /a libUnittest.verbose=%1+0

call libUnittest
call libString

%$UT_testSuite:(echo MACRO IS EMPTY)&:=%

exit /b


:testCase_strNOP
%$UT_StartTestCase% %0 "strNOP"
set "var=Hello world 1"

%$UT_TEST_PRE%
%$strNOP% result var
%$UT_TEST_POST_ASSERT% result=var

set "long=."
for /l %%n in (1 1 13) DO set "long=!long:~-4000!!long:~-4000!"
set result=no return
REM Currently limit is 8168
(set^ var=!long:~-8000!!long:~-168!)
(set^ expect=!var!)
%$UT_TEST_PRE%
%$strNOP% result var
%$UT_TEST_POST_ASSERT% result=expect

%$UT_exitTestCase%
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:testCase_Trim
%$UT_StartTestCase% %0 "Trim"

set "var=        Hello world 1  "
set "expect=Hello world 1"
%$UT_TEST_PRE%
%$Trim% result var
%$UT_TEST_POST_ASSERT% result=expect

set "var=!$CR!  Hello world 2 !$CR!"
set "expect=Hello world 2"
%$UT_TEST_PRE%
%$Trim% result var 1
%$UT_TEST_POST_ASSERT% result=expect

set "var=!$CR!!$LF!!$LF!  Hello world 3 !$LF!!$LF!!$CR!!$LF!"
set "expect=Hello world 3"
%$UT_TEST_PRE%
%$Trim% result var 1
%$UT_TEST_POST_ASSERT% result=expect

set "var=!$CR!!$LF!  Hello!$CR!!$LF!world 4 !$CR!!$LF!"
set "expect=Hello!$CR!!$LF!world 4"
%$UT_TEST_PRE%
%$Trim% result var 1
%$UT_TEST_POST_ASSERT% result=expect

set "var=";;;value in quotes;""
set "expect=!var!"
%$UT_TEST_PRE%
%$Trim% result var 1
%$UT_TEST_POST_ASSERT% result=expect

set "var=;;value starting with semi colon"
set "expect=!var!"
%$UT_TEST_PRE%
%$Trim% result var 1
%$UT_TEST_POST_ASSERT% result=expect

set "var=value ending with semi colons;;;"
set "expect=!var!"
%$UT_TEST_PRE%
%$Trim% result var 1
%$UT_TEST_POST_ASSERT% result=expect

set "var="inside quotes""
set "expect=!var!"
%$UT_TEST_PRE%
%$Trim% result var 1
%$UT_TEST_POST_ASSERT% result=expect

set "expect=" Line2        ""
set "var= !expect! "
%$UT_TEST_PRE%
%$Trim% result var 1
%$UT_TEST_POST_ASSERT% result=expect

%$UT_exitTestCase%


:testCase_rightTrim
%$UT_StartTestCase% %0 "rightTrim"

set "var=        Hello world 1 "
set "expect=        Hello world 1"
%$UT_TEST_PRE%
%$rightTrim% result var
%$UT_TEST_POST_ASSERT% result=expect

set "var=Hello world 2 !$CR!"
set "expect=!var!"
%$UT_TEST_PRE%
%$rightTrim% result var 0
%$UT_TEST_POST_ASSERT% result=expect

set "var=Hello world 3 !$CR!"
set "expect=Hello world 3"
%$UT_TEST_PRE%
%$rightTrim% result var 1
%$UT_TEST_POST_ASSERT% result=expect

set "var=;;value starting with semi colon"
set "expect=!var!"
%$UT_TEST_PRE%
%$rightTrim% result var 1
%$UT_TEST_POST_ASSERT% result=expect

set "var=value ending with semi colons;;;"
set "expect=!var!"
%$UT_TEST_PRE%
%$rightTrim% result var 1
%$UT_TEST_POST_ASSERT% result=expect

%$UT_exitTestCase%


:testCase_leftTrim
%$UT_StartTestCase% %0 "leftTrim"
REM set /a scopeDepth=0
REM setlocal EnableDelayedExpansion & set /a scopeDepth+=1
REM setlocal EnableDelayedExpansion & set /a scopeDepth+=1

set "var=        Hello world1  "
set "expect=Hello world1  "
%$UT_TEST_PRE%
%$leftTrim% result var
%$UT_TEST_POST_ASSERT% result=expect

set "var=     "
%$leftTrim% result var
set "expect="
%$UT_TEST_PRE%
%$leftTrim% result var
%$UT_TEST_POST_ASSERT% result=expect

set "var=  Line1!CR!***"
set "expect=Line1!CR!***"
%$UT_TEST_PRE%
%$leftTrim% result var
%$UT_TEST_POST_ASSERT% result=expect

set "expect=One ^ caret"
set "var=  !expect!"
%$UT_TEST_PRE%
%$leftTrim% result var
%$UT_TEST_POST_ASSERT% result=expect

set "expect=One quoted "^^" caret"
set "var=  !expect!"
%$UT_TEST_PRE%
%$leftTrim% result var
%$UT_TEST_POST_ASSERT% result=expect

set "expect=One ^! bang"
set "var=  !expect!"
%$UT_TEST_PRE%
%$leftTrim% result var
%$UT_TEST_POST_ASSERT% result=expect

set "expect=One ^! bang and one ^^ caret"
set "var=  !expect!"
%$UT_TEST_PRE%
%$leftTrim% result var
%$UT_TEST_POST_ASSERT% result=expect

set "var=  Line1!$LF! line2 "quote" here"
set "expect=Line1!$LF! line2 "quote" here"
%$UT_TEST_PRE%
%$leftTrim% result var
%$UT_TEST_POST_ASSERT% result=expect

set "var=;;value starting with semi colon"
set "expect=!var!"
%$UT_TEST_PRE%
%$leftTrim% result var 1
%$UT_TEST_POST_ASSERT% result=expect

set "var=value ending with semi colons;;;"
set "expect=!var!"
%$UT_TEST_PRE%
%$leftTrim% result var 1
%$UT_TEST_POST_ASSERT% result=expect

%$UT_exitTestCase%


:testCase_undefVar
%$UT_StartTestCase% %0 "undefined var has length=0"
set "undefVar="
set "expect=0"

%$UT_TEST_PRE%
%$strLen% result undefVar
%$UT_TEST_POST_ASSERT% result=expect

%$UT_exitTestCase%


:testCase_StringsUpTo130chars

%$UT_StartTestCase% %0 "strings up to 130 chars"
set "var="
for /L %%n in (1 1 130) DO (
	set "var=!var!X"
	set "expect=%%n"

	%$UT_TEST_PRE%
	%$strLen% result var
	%$UT_TEST_POST_ASSERT% result=expect
)

%$UT_exitTestCase%


:testCase3
%$UT_StartTestCase% %0 "string length multiples of 31 chars"
set "var="
set /a expectLen=0
for /L %%n in (1 1 200) DO (
	set "var=!var!1234567890123456789012345678901"
	set /a expectLen+=31
	set "expect=!expectLen!"

	%$UT_TEST_PRE%
	%$strLen% result var
	%$UT_TEST_POST_ASSERT% result=expect
)

%$UT_exitTestCase%


:testCase4
%$UT_StartTestCase% %0 "long strings 8188-8191 chars"
set "long=."
for /l %%n in (1 1 13) DO set "long=!long:~-4000!!long:~-4000!"

(set^ longTest=!long!!long:~-185!321)
set "expect=8188"
%$UT_TEST_PRE%
%$strLen% result=longTest
%$UT_TEST_POST_ASSERT% result=expect

(set^ longTest=!long!!long:~-185!4321)
%$UT_TEST_PRE%
%$strLen% result longTest
set "expect=8189"
%$UT_TEST_POST_ASSERT% result=expect

(set^ longTest=!long!!long:~-185!54321)
%$UT_TEST_PRE%
%$strLen% result longTest
set "expect=8190"
%$UT_TEST_POST_ASSERT% result=expect

(set^ longTest=!long!!long:~-185!654321)
%$UT_TEST_PRE%
%$strLen% result longTest
set "expect=8191"
%$UT_TEST_POST_ASSERT% result=expect

%$UT_exitTestCase% %= *** EXIT *** =%

:testCase_toUpper
%$UT_StartTestCase% %0 "toUpper"

set "var=Hello world"
set "expect=HELLO WORLD"
%$UT_TEST_PRE%
%$toUpper% result var
%$UT_TEST_POST_ASSERT% result=expect

%$UT_exitTestCase% %= *** EXIT *** =%


:testCase_toLower
%$UT_StartTestCase% %0 "toLower"

set "var=Hello BIG world"
set "expect=hello big world"
%$UT_TEST_PRE%
%$toLower% result var
%$UT_TEST_POST_ASSERT% result=expect


%$UT_exitTestCase% %= *** EXIT *** =%
