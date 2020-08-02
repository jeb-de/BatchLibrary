@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

%$LIB_LOAD_ONCE:call "%~d\:fn_LIB_LOAD_ONCE:\..\%~p0\libBase.cmd" "%~f0" :=%

%$DEFINE_MACRO% $isodate
%$DEFINE_MACRO% $date2julian
%$DEFINE_MACRO% $julian2date
%$DEFINE_MACRO% $date2epoch
%$DEFINE_MACRO% $epoch2date

exit /b
:define_$date2epoch
# macro_open / macro_close
set "\n=%%~$=^"":"^^"
%$lib.macrodefine.free% set %%"%%M=%$$_MACRO_BEGIN% %\n%

%$$_MACRO_END%"

%$endlocal% %MACRO_NAME%
exit /b

::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b