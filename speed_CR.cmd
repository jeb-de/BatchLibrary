@echo off
setlocal EnableDelayedExpansion
set /a cycles=%~1+0

if "!cycles!" == "0" set cycles=10

call libTime
call :testSuite
exit /b

:testSuite
FOR /F %%# in ('findstr /R "^:speedtest_*" "%~f0"') do (
	set "testname=%%#                   "
	<nul set /p ".=Speedtest !cycles! for !testname:~0,30! ... "
	set "startTime=!time!"
	call %%#
	set "stopTime=!time!"
	%$diffTime% startTime stopTime diffTime_ms
	set /a cycleTime=diffTime_ms / cycles
	set "strDiffTime=  !diffTime_ms!ms"
	echo !strDiffTime:~-7! .. per cycle !cycleTime!ms
)
exit /b

:speedtest_CreateCR_copy_temp_file
FOR /L %%# in (1 1 %cycles%) DO (
	for /f "usebackq delims= " %%C in (`copy /z "%~f0" nul`) do set "CR=%%C"
)
exit /b

:speedtest_CreateCR_copy
FOR /L %%# in (1 1 %cycles%) DO (
	for /f "delims= " %%C in ('^"copy /z "%~f0" nul^"') do set "CR=%%C"
)
exit /b

:speedtest_CreateCR_replace
FOR /L %%# in (1 1 %cycles%) DO (
	for /f "skip=1" %%C in ('"echo(| replace ? . /w /u"') do set "$CR=%%C"
)
exit /b


:speedtest_CreateCR_BufferLimit
(set LF=^

)
echo(
rem FOR /L %%# in (1 1 %cycles%) DO (

setlocal EnableDelayedExpansion
set x=leer
set "long=."
FOR /L %%n in (1 1 13) DO set "long=!long:~-4000!!long:~-4000!"
set^ x=!long!!long:~-189!1
echo !x!
echo #


echo(
endlocal

)

exit /b
