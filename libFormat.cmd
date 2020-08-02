@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

%$LIB_LOAD_ONCE:call "%~dp0\libBase.cmd" "%~f0" :=%

%$LIB_LOAD_MACRO% $string.format

exit /b

:define_$string.format destVar|-o formatStr [parameter-1|...|parameter-n]
:::  -o instead of destVar outputs the formatted string
::: formatStr and parameter-n are variable reference, but when they are enclosed in quotes they are values
:::  $string.format -o "Hello {0}, current time is {1}" "world" time
%$lib.macrodefine.disabled% %~1
set ^"%MACRO_NAME%=for %%# in (1 2) do if %%#==2 (%\n%
	....
	end of macro 
	) else 	setlocal EnableDelayedExpansion ^& setlocal ^& set argv= "

%$MACRO_FINISH% %MACRO_NAME%
exit /b
