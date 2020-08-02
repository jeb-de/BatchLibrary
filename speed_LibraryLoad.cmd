@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

cls
set "LIBRARY_DEBUG="
set "$$LIBRARY_NEW_MACRO_HOOK="
if "%1" == "--debug" (
	echo Debug mode on
	set "LIBRARY_DEBUG=1"
)
if "%2" == "--store" (
	echo Macros stored to files
	set ^"$$LIBRARY_NEW_MACRO_HOOK=call "%~d0\:_NEW_MACRO_DEBUG:\..\%~pn0""
)
REM call :fill_environment
setlocal DisableDelayedExpansion

call :loadAll
endlocal

setlocal EnableDelayedExpansion
call :loadAll
endlocal
exit /b

:loadAll
echo ---------------------------------------------------------------------------------------------------------------
set "tot.start=%time%"
set "libList="
FOR %%X in (
"libBase"
"libEndlocal"
"libTime" 
"libString"
"libArray"
%="libArguments" =%
) DO (
	echo :loadLib %%~X
	call :loadLib %%~X
)

echo(
for %%L in (%libList%) DO (
	call :showTime %%L %%L
)

set "tot.stop=%time%"

call :showTime TOTAL tot
exit /b

:loadLib
if "%1"=="libEndlocal" set "$libEndlocal.loaded="
set "libList=%libList% %1"
set "%1.start=%time%"
if "%~n1" == "libBase" (
	call %~dp0\%1
) ELSE (
	%$lib_include% %1
)

set "%1.stop=%time%"

exit /b

:showTime
setlocal EnableDelayedExpansion

%$diffTime:echo ERROR: Missing MACRO $diffTime & REM.:=% %2
set "libName=%1                   "
set "duration=   !%2.diff!ms"
echo Library loading %libName:~0,20% : !duration:~-7!
exit /b

:fill_environment
set "long=."
for /l %%n in (1 1 13) DO set "long=!long:~-4000!!long:~-4000!"

for /L %%n in (1 1 20000) DO (
	set "Z_FILL%%n=!long!"
)
exit /b

:_NEW_MACRO_DEBUG
FOR %%1 in ("1") DO (
	echo NEWMACRO: %%Z
	if "!!" == "" (
		set "filename=debug_%%Z.EDE"
	) ELSE (
		set "filename=debug_%%Z.DDE"
	)
	setlocal EnableDelayedExpansion
	set "filename=!filename:$=#!"
	set "filename=!filename:\=_!"
	(set %%Z) > "!filename!"
	endlocal
)
exit /b