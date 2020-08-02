@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

%$LIB_LOAD_ONCE:call "%~dp0\libBase.cmd" :=%
%$LIB_INCLUDE% libEndlocal

%$LIB_CREATE_TRAMPOLINE% $parameter.activeList

exit /b


::: Function shows all currently used FOR parameter
::: @TODO: improve return array, suppress echo if resultVar exists
:fn_$parameter.activeList <resultVar>
setlocal EnableDelayedExpansion

(set $LF=^
%=EMPTY=%
)
::: This defines the $PCT variable containing exactly one percent, this works even when all possible parameters are set
set ^"$PCT=%%<nul"

::: This is enough here
::: This variable should always be used in code which expects to insert a single percent sign (MACROS with CALL set ... %%myvar%%, or echo 20%%. )
set "$PCT=%%"

::: Build a testall variable to check against all FOR parameters in the ascii range 32-126
set ^"ascii_chars= ^^!"#$%%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^^_`abcdefghijklmnopqrstuvwxyz{|}~"
set "testall="
for /L %%n in (0 1 94) DO (
	set "char=!ascii_chars:~%%n,1!"
	set "testall=!testall!<!char!##!$PCT!~$=OKAY=:!char!->"
)

:: Avoid a wrong expansion for PERCENT in "<% ##% ~$=OKAY=:%%->" it expands "%##" if possible
:: search/replace with "<Percent##% ~$=OKAY=:%%->"
set "testall=!testall:%%#=Percent#!"
set "test.start=%time%"
:: Create an ESCAPE character
for /F "delims=#" %%a in ('prompt #$E# ^& for %%a in ^(1^) do rem') do set "ESC=%%a"

::: The escape character is used as the FOR parameter name to avoid influence of the ascii range 32-126
For /F "tokens=1" %%%ESC% in ("!tableESC!") DO (
	setlocal DisableDelayedExpansion
	set "result=%testall%"
)

setlocal EnableDelayedExpansion

set "parametersFound="
if "!result!" NEQ "!testall!" (
	REM *** Some parameters detected
	set "tmp=!result!"

	REM *** Handle special characters
	set "tmp="!tmp:"=QUOTE!"
	set "tmp=!tmp:<!=<BANG!"
	set "tmp=!tmp:^=CARET!"

	REM set "testall=!testall:""="!"	Nicht wichtig

	REM *** If a parameter [char] is defined, the related expression "<[char]## <PERCENT>~$=OKAY=:[char]-> will be reduced to "<[char]##->"
	REM *** As all parameters are split into separate lines by replacing "->" with '<quote><line feed><quote>'
	REM *** Then only two formats are possible
	REM *** Case 1: Parameter is not defined: "<[char]## <PERCENT>~$=OKAY=:[char]"
	REM *** Case 2: Parameter is defined    : "<[char]##"
	REM *** Case 3: Tilde is defined, parameter is defined, no problem, result is Case2
	REM *** Case 4: Tilde is defined, parameter is not defined, PROBLEM, result is expansion from %%~  and Text "$=OKAY=:[char]"
	REM *** Only in case 2 the "##" are at the end
	for %%L in ("!$LF!") do (
		set cnt=0
		for /F "tokens=* delims=" %%1 in ("!tmp:->="%%~L"!") do (
			set /a idx=17*cnt+1, ascii=cnt+32, cnt+=1		%= Not important =%
			for %%# in (!idx!) do (                         %= Not important =%
				set "expect=!ascii! "!testall:~%%#,1!""     %= Not important =%
			)                                               %= Not important =%
			set "test=%%~1"
			if "!test:~-2!" == "##" (
				REM echo Global FOR loop parameter defined: "!test:~1,-2!"  !expect!
				if defined parametersFound set "parametersFound=!parametersFound!, "
				set "parametersFound=!parametersFound!"!test:~1,-2!""
			)
		)
	)
)
(
	endlocal
	endlocal
	endlocal
	set ^"parametersFound=%parametersFound%"
)

setlocal EnableDelayedExpansion
set cnt=0
set "rawParams="
if defined parametersFound (
	for %%L in ("!$LF!") do FOR /F "delims=" %%L in ("!parametersFound:, =%%~L!") DO (
		set /a cnt+=1
		rem echo Global FOR loop parameter defined: %%L
	)
	set "rawParams=!parametersFound: "=!"
	set "rawParams=!rawParams:",=,!"
	set "rawParams=!rawParams:~1,-1!"
)

if "%1" NEQ "" (
	%$endlocal% %1 rawParams
) ELSE IF defined rawParams (
	echo Found !cnt! defined parameters "!rawParams!"
) ELSE (
	echo No defined parameters found
)

exit /b
