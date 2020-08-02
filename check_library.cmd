@echo off
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

echo STARTED %*
setlocal DisableDelayedExpansion
REM *** Options
call :options %*
if defined _store (
	break  > "%temp%\%~n0.tmp"
)
REM ***
set /a step=0

REM *** Check 4 different invokation
echo -------- Checking %library_name% ---------------
if defined _check_syntax (
	call :check_syntax
)

if "%_only_case:1%=1%" == "1" (
	call :testLoadLib DisableDelayedExpansion simple
)

if "%_only_case:2%=2%" == "2" (
	call :testLoadLib EnableDelayedExpansion simple
)

if "%_only_case:3%=3%" == "3" (
	call :testLoadLib DisableDelayedExpansion all-for-variables
)

if "%_only_case:4%=4%" == "4" (
	call :testLoadLib EnableDelayedExpansion all-for-variables
)

if not defined _only_case (
	if defined _store (
		call :check_macro_mode_diff
	)
)

:finish
echo -------- Tests finished -------------------
exit /b

:testLoadLib
set /a step+=1
echo #%step% Load library %library_name% with %1 Type: %2
if "%1"=="DisableDelayedExpansion" (
	set "check_lib_mode=DDE"
) ELSE (
	set "check_lib_mode=EDE"
)
set "check_lib_type=%2"

IF "%2" == "simple" (
	setlocal %1
	call %%library_name%%
) ELSE IF "%2" == "all-for-variables" (
	call :for-variables %1
) ELSE (
	echo ERROR: Unkonw mode "%2"
)

endlocal
exit /b

:for-variables
copy /z "%~f0" nul > out.tmp
for /F "delims= " %%C in (out.tmp) do set "$CR=%%C"

for /F "delims=#" %%a in ('prompt #$E# ^& for %%a in ^(1^) do rem') do set "ESC=%%a"

FOR /F "tokens=1-24" %%a in ("#####-a #####-b #####-c #####-d #####-e #####-f #####-g ####-h #####-i #####-j #####-k #####-l ####-m ####-n ####-o #####-p #####-q #####-r ####-s ####-t ####-u #####-v ######-w ####-x #####-y #####-z") DO ^
FOR /F "tokens=1-24" %%A IN ("#####-A #####-B #####-C #####-D #####-E #####-F #####-G ####-H #####-I #####-J #####-K #####-L ####-M ####-N ####-O #####-P #####-Q #####-R ####-S ####-T ####-U #####-V ######-W ####-X #####-Y #####-Z") DO ^
FOR /F "tokens=1-6" %%: in ("#####-: #####-; #####-< #####-= #####-> #####-? #####-@") DO ^
FOR /F "tokens=1-20" %%! in ("#####EXC #####QUOT #####-# #####-$ #####-PERCENT #####-& #####-' #####-( #####-) #####-* #####-+ #####-, #####-- #####-. #####-/") DO ^
FOR /F "tokens=1-10" %%0 in ("#####0 #####1 #####2 #####3 #####4 #####5 #####6 #####7 #####8 #####9") DO ^
FOR %%^" in (quote-quote#################) DO ^
FOR %%Z in (zzzzzzzzzzzz) DO ^
FOR /F "tokens=1-6" %%%ESC%  in ("####-0x1B ####-0x1C ####-0x1D ####-0x1E ####-0x1F ####-SPACE") DO ^
FOR %%$ in (DOLLAR) DO (
	call :_step2
)

exit /b

:_step2
setlocal %1
call %%library_name%%
exit /b

:check_syntax
REM *** Loads a macro with echo on, this shouldn't output anything
REM *** Then the macro is

set /a step+=1
echo #%step% Syntax check for library %library_name%
echo    Check for errors in macro definitions, and for missing new lines/trailing white spaces/unbalanced quotes

setlocal
set "$FOR=%%%%~$=_F1_FOR-variable_DOLLAR_is_required_while_MACRO_DEFINITION_=:$param"
set "$PERCENT=%%%%~$=_p1_FOR-variable_DOLLAR_is_required_while_MACRO_DEFINITION_=:$"
set "$PERCENT-CALL=%%%%~$==:$%$PERCENT%~$==:$"

set "$$LIBRARY_NEW_MACRO_PRE_HOOK=(call echo #MACRO-DEF-START# %$FOR:param=Z% in "%$PERCENT-CALL%~n0") ^& echo on"
set "$$LIBRARY_NEW_MACRO_POST_HOOK=(echo #MACRO-DEF-END# %$FOR:param=Z%) ^& @echo off ^& call "%~d0\:_SYNTAX_POST_HOOK:\..\%~pnx0" "%$PERCENT-CALL%~f0" "

break > "%temp%\%~n0-macro-output.tmp"
	echo %time% > "%temp%\%~n0-macro-output.tmp"

set "LIBRARY_DEBUG="
set "prompt=#FAIL#$G"

>> "%temp%\%~n0-macro-output.tmp" 2>&1 cmd /V:ON /c "%~dp0\%library_name%"

if %errorlevel% NEQ 0 (
	echo ERROR: %errorlevel% ***************** SYNTAX ***************
)

REM findstr /V /R /C:"^#FAIL#>REM" /C:"^$" "%temp%\%~n0-macro-output.tmp"
findstr /n /R /C:"^#MACRO-ERROR#" "%temp%\%~n0-macro-output.tmp"
endlocal
exit /b

:_SYNTAX_POST_HOOK
if "%~n1" == "libBase" exit /b

REM *** Build the executor bat file
REM *** @TODO: Using (goto) technology que to detect if block is correctly closed
FOR %%$ in (1) DO (
	ECHO @echo off
	ECHO echo #MACRO-EXEC-START# %%Z

	ECHO echo on
	ECHO @(
	echo     echo #MACRO-EXEC-SUCCESS#
	echo	 break ^> "%temp%\%~n0-signal.tmp"
	ECHO     exit /b 47
	ECHO(    %%%%Z%%
	ECHO ^)
	ECHO(
	REM echo POST_HOOK: %%Z > CON
) > "%temp%\%~n0-macro-exec.bat"

REM *** Delete signal file
del "%temp%\%~n0-signal.tmp" 2> nul

REM *** Start the executer batch
REM *** That batch only checks if the macro can be expanded without syntax error
REM *** The macro isn't started
cmd /c "%temp%\%~n0-macro-exec.bat"
REM call "%temp%\%~n0-macro-exec.bat" 2> CON

setlocal EnableDelayedExpansion
echo #MACRO-EXEC-ERR# %errorlevel%
if not exist "!temp!\%~n0-signal.tmp" (
	FOR %%$ in (1) DO (
		set ^"text="%%Z" in "%~n1" fails to expands, perhaps a syntax error or not enough closing parenthesis"
		echo #MACRO-ERROR# !text!
		> CON echo ERROR: !text!
	)
)
endlocal
exit /b

:_NEW_MACRO_HOOK
setlocal EnableDelayedExpansion
set "_libName=%~nx1"
if "!_libName!" NEQ "!library_name!" exit /b

setlocal DisableDelayedExpansion
FOR %%1 in ("1") DO (
	set "filename=debug_%%Z.%check_lib_type%.%check_lib_mode%"
	setlocal EnableDelayedExpansion
	set "filename=!filename:$=#!"
	set "filename=!filename:\=_!"
	(set %%Z) > "!filename!"
	(echo(!filename!) >> "%temp%\%~n0.tmp"
	if defined LIBRARY_DEBUG (
		echo ----- NEW_MACRO_HOOK: %%Z  saved to: "!filename!"
	)
	endlocal
)
exit /b

:options
set "$PERCENT=%%%%~$=_p1_FOR-variable_DOLLAR_is_required_while_MACRO_DEFINITION_=:$"
set "$PERCENT-CALL=%%%%~$==:$%$PERCENT%~$==:$"
set "_hook=call "%~d0\:_NEW_MACRO_HOOK:\..\%~pnx0" %$PERCENT-CALL%~f0"

set "_only_case="
set "_store="
set "_check_syntax=1"
set "library_name="
set "LIBRARY_DEBUG="
set "$$LIBRARY_NEW_MACRO_HOOK="

:_option_loop
if "%~1" == "" exit /b

set "arg=%~1"

if "%arg:~0,1%" EQU "-" (

	if "%arg%" == "-v" (
		echo Option: Debug mode on
		set "LIBRARY_DEBUG=1"
	) ELSE if "%arg%" == "--verbose" (
		echo Option: Debug mode on
		set "LIBRARY_DEBUG=1"
	) ELSE if "%arg%" == "--store" (
		echo Option: Store macros to files
		setlocal EnableDelayedExpansion
		for /F "delims=" %%Q in ("!_hook!") DO (
			endlocal
			set "$$LIBRARY_NEW_MACRO_HOOK=%%Q"
		)
		set "_store=1"
	) ELSE if "%arg%" == "--no-syntax" (
		echo Option: Suppress syntax check
		set "_check_syntax="
	) ELSE if "%arg%" == "--case1" (
		echo Option: Only test case1, simple DDE
		set "_only_case=1"
	) ELSE if "%arg%" == "--case3" (
		echo Option: Only test case3, all-for-DDE
		set "_only_case=3"
	) ELSE (
		echo ERROR: Unknown option "%arg%"
		goto :halt
	)
) ELSE (
	echo Lib: %arg%
	set "library_name=%arg%"
)

shift
goto :_option_loop

:halt
()

:check_macro_mode_diff
setlocal EnableDelayedExpansion
set "wildcard=debug_*simple.DDE"
for %%Q in (%wildcard%) do (
	set "f_DDE=%%Q"
	set "f_EDE=%%~nQ.EDE"
	set "foundDifference=0"

	FOR %%Q in (%%~nQ) DO set "f_base=%%~nQ"
	set "f_all_DDE=!f_base!.all-for-variables.DDE"
	set "f_all_EDE=!f_base!.all-for-variables.EDE"

	(call)
	call :isFileDiff "!f_DDE!" "!f_EDE!"
	call :isFileDiff "!f_DDE!" "!f_all_DDE!"
	call :isFileDiff "!f_all_DDE!" "!f_all_EDE!"

    if "!foundDifference!" EQU "0" (
		echo([ 'OKAY' ]; : .. !f_base!
	) ELSE (
		echo([ 'FAIL' ]; diff '!file1!' '!file2!'
	)
)
exit /b

:isFileDiff
if "!foundDifference!" NEQ "0" exit /b
set "file1=%~1"
set "file2=%~2"
(call)
fc /b "!file1!" "!file2!" > NUL

set "foundDifference=!errorlevel!"

exit /B
