@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

setlocal
if "%~1" NEQ "" set /a libUnittest.verbose=%1+0

call %~dp0\..\libBase
%$LIB_INCLUDE% libUnittest
%$LIB_INCLUDE% libFile

%$UT_testSuite:(echo MACRO IS EMPTY)&:=%

exit /b

:testcase_absolutePath
%$UT_StartTestCase% %0 "%0"

set "input=%~dp0"
set "expect=%~dp0"
%$UT_TEST_PRE% "Absolute path shouldn't be modified"
%$absolutePath% result input
%$UT_TEST_POST_ASSERT% result=expect

set "input=%~d0\someDir1\someDir2\..\..\%~p0\someDir3\someDir4\..\.."
set "expect=%~dp0"
%$UT_TEST_PRE% "Absolute path with dots should be normalized"
%$absolutePath% result input
%$UT_TEST_POST_ASSERT% result=expect

set "input=."
set "expect=%__CD__%"
%$UT_TEST_PRE% "Relative path should be result into this "
%$absolutePath% result input
%$UT_TEST_POST_ASSERT% result=expect

set "input=%~dp0"
set "expect=%~dp0"
%$UT_TEST_PRE% "Absolute path shouldn't be modified"
%$absolutePath% result input
%$UT_TEST_POST_ASSERT% result=expect

set "input="
set "expect=%__CD__:~0,3%"
%$UT_TEST_PRE% "Nothing results into <current drive>:\"
%$absolutePath% result input
%$UT_TEST_POST_ASSERT% result=expect

%$UT_exitTestCase% %= *** EXIT *** =%
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:testcase_relativePath
%$UT_StartTestCase% %0 "%0"

set "input=%~dp0"
set "expect=%~dp0"
%$UT_TEST_PRE% "Absolute path shouldn't be modified"
%$relativePath% result input
%$UT_TEST_POST_ASSERT% result=expect

set "input=%~d0\someDir1\someDir2\..\..\%~p0\someDir3\someDir4\..\.."
set "expect=%~dp0"
%$UT_TEST_PRE% "Absolute path with dots should be normalized"
%$relativePath% result input
%$UT_TEST_POST_ASSERT% result=expect

set "input=."
set "expect=%__CD__%"
%$UT_TEST_PRE% "Relative path should be result into this "
%$relativePath% result input
%$UT_TEST_POST_ASSERT% result=expect

set "input=%~dp0"
set "expect=%~dp0"
%$UT_TEST_PRE% "Absolute path shouldn't be modified"
%$relativePath% result input
%$UT_TEST_POST_ASSERT% result=expect

set "input="
set "expect=%__CD__:~0,3%"
%$UT_TEST_PRE% "Nothing results into <current drive>:\"
%$relativePath% result input
%$UT_TEST_POST_ASSERT% result=expect

%$UT_exitTestCase% %= *** EXIT *** =%
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:testcase_isFolder
%$UT_StartTestCase% %0 "%0"

set "input=%~dp0"
set "expect=1"
%$UT_TEST_PRE% "Check if the batch-path a folder, variable used"
%$isFolder% result input
%$UT_TEST_POST_ASSERT% result=expect

set "input=%~dp0\NOT-A-PATH::"
set "expect=0"
%$UT_TEST_PRE% "Check invalid path, variable used"
%$isFolder% result input
%$UT_TEST_POST_ASSERT% result=expect

set "input="
set "expect=0"
%$UT_TEST_PRE% "Check empty path: Is not a folder, variable used"
%$isFolder% result input
%$UT_TEST_POST_ASSERT% result=expect

set "expect=1"
%$UT_TEST_PRE% "Check if the batch-path a folder, STRING used"
%$isFolder% result "%~dp0"
%$UT_TEST_POST_ASSERT% result=expect

%$UT_exitTestCase% %= *** EXIT *** =%
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:testcase_isFile
%$UT_StartTestCase% %0 "%0"

set "input=%~dp0"
set "expect=0"
set result=FAIL
%$UT_TEST_PRE% "Check if the batch-path a folder, variable used"
%$isFile% result input
%$UT_TEST_POST_ASSERT% result=expect

set "input=%~f0"
set "expect=1"
%$UT_TEST_PRE% "Check this file, variable used"
%$isFile% result input
%$UT_TEST_POST_ASSERT% result=expect

set "input="%~f0""
set "expect=1"
%$UT_TEST_PRE% "Check this quoted file, variable used"
%$isFile% result input
%$UT_TEST_POST_ASSERT% result=expect

set "input="
set "expect=0"
%$UT_TEST_PRE% "Check empty file: Is not a file, variable used"
%$isFile% result input
%$UT_TEST_POST_ASSERT% result=expect

set "expect=1"
%$UT_TEST_PRE% "Check this file, STRING used"
%$isFile% result "%~f0"
%$UT_TEST_POST_ASSERT% result=expect

%$UT_exitTestCase% %= *** EXIT *** =%
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b
