@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

%$LIB_LOAD_ONCE:call "%~dp0\libBase.cmd" :=%
%$LIB_INCLUDE% libEndlocal

%$LIB_LOAD_MACRO% $getArgumentLine
%$LIB_CREATE_TRAMPOLINE% $arg_parser

exit /b

:define_$alternative_getArgumentLine
REM *** SPECIAL SYNTAX ONLY,
REM *** %:% Necessary for jumpback to the original line
REM *** Can only be used from call stack level 0, and NOT inside code blocks
REM *** %:%%$alternative_getArgumentLine% argv
set ^"$fetchArgs=for %%# in (1 2) do if %%#==2 (%\n%
	goto :_fetch_helper%\n%
) else setlocal EnableDelayedExpansion ^& set argv="

exit /b

:_fetch_helper
REM *** TODO: Check if %0 doesn't start with a colon ":", to ensure this is called from stack level 0
>"%temp%\getArg.txt" < "%temp%\getArg.txt" (
	setlocal DisableDelayedExpansion DisableExtensions
	(set prompt=#)
	echo on
	for %%# in (%%#) do if 1==0 (
		REM
		REM " %* "
	)
	@echo off
	endlocal
	for /F "tokens=1" %%1 in ("!argv!") do (
		set /p "%%1="
		set /p "%%1="
		set /p "%%1="
		set /p "%%1="
		REM *** Remove the 'REM " ' and ' "' from the string
		(echo(!%%1:~7,-3!)
		endlocal
		set /p "%%1="
		set /p "%%1="
	)
)

goto :%%%%$fetchArgs%%


:define_$getArgumentLine
REM Get only the %* arguments with minimal interference
::: Only linefeeds and carriage returns can't be fetched
::: Only linefeeds can create a syntax error
::: return arg=All arguments

REM %$lib.macrodefine.disabled%
REM set "$getArgumentLine=call "%~d0\:_getArgumentLine:\..\%~pnx0""
REM %$endlocal% $getArgumentLine

%$lib.macrodefine.disabled%
set ^"$getArgLine(=for %%# in (1 2) do if %%#==2 (%\n%
	for /F "tokens=1,2,3" %%1 in ("!argv!") do (%\n%
%= 		*** remove the local variable "argv" =% %\n%
		endlocal%\n%
		^>"%temp%\getArg.txt" ^< "%temp%\getArg.txt" (%\n%
			setlocal DisableExtensions %\n%
			(set prompt=#) %\n%
			echo on %\n%
			for %%# in (%%#) do if 1==0 ( %\n%
				REM %\n%
				rem . " %\n%
%$endlocal% $getArgLine(


%$lib.macrodefine.disabled%
set ^"$)getArgLine=. ^%LF%%LF%%\n%
			) %\n%
			echo off %\n%
			endlocal %\n%
			set /p "args=" %\n%
			set /p "args=" %\n%
			set /p "args=" %\n%
			set /p "args=" %\n%
			%= Remove the "REM . " and " ." from the string =%%\n%
			set "args=!args:~7,-4!" %\n%
			%= Left trim the string, avoids spaces when the macro is called with more than one =% %\n%
			for /F "tokens=*" %%L in ("!args!") DO set "args=%%L" %\n%
		) %\n%
		del "%temp%\getArg.txt"%\n%
%= 		*** copy the result =% %\n%
		%$$endlocalForParam1:arg1=args% %\n%
	)%\n%
) else setlocal EnableDelayedExpansion ^& setlocal EnableDelayedExpansion ^& set argv= "

%$endlocal% $)getArgLine
exit /b
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

::: Can't work this way
::: goto doesn't work here, but is needed to expand %1 multiple times, after shift
:define_$getArgv
%$lib.macrodefine.disabled%
set ^"$getArgv(=for %%# in (1 2) do if %%#==2 (%\n%
	for /F "tokens=1,2,3" %%1 in ("!argv!") do (%\n%
%= 		*** remove the local variable "argv" =% %\n%
		endlocal%\n%
		^>"%temp%\getArg.txt" ^< "%temp%\getArg.txt" (%\n%
			setlocal DisableExtensions %\n%
			(set prompt=#) %\n%
			echo on %\n%
			for %%# in (%%#) do rem . "

%$endlocal% $getArgv(

%$lib.macrodefine.disabled%
set ^"$)getArgv=. ^%LF%%LF%%\n%
			echo off %\n%
			endlocal %\n%
			set /p "args=" %\n%
			set /p "args=" %\n%
			%= Left trim the string =%%\n%
			set "args=!args:~7,-4!" %\n%
			for /F "tokens=*" %%L in ("!args!") DO set "args=%%L" %\n%
			set args %\n%
		) %\n%
		del "%temp%\getArg.txt"%\n%
%= 		*** copy the result =% %\n%
		%$$endlocalForParam1:arg1=args%
	)%\n%
) else setlocal EnableDelayedExpansion ^& setlocal EnableDelayedExpansion ^& set argv= "

%$endlocal% $)getArgv
exit /b
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:__experimental
::: Get all arguments with minimal interference
::: Only linefeeds and carriage returns can't be fetched
::: Only linefeeds can create a syntax error
::: return arg=All arguments, arg1..arg<n>=A single argument
setlocal EnableDelayedExpansion
set "argCnt="
:_getArgs
>"%temp%\getArg.txt" <"%temp%\getArg.txt" (
  setlocal DisableExtensions
  (set prompt=#)
  echo on
  if defined argCnt (
	for %%# in (%%#) do rem . %1.
  ) ELSE (
	for %%# in (%%#) do rem . %*.
  )
  echo off
  endlocal

  set /p "arg%argCnt%="
  set /p "arg%argCnt%="
  set "arg%argCnt%=!arg%argCnt%:~7,-2!"
  if defined arg%argCnt% (
	if defined argCnt (
		shift /1
	)
    set /a argCnt+=1
    goto :_getArgs
  ) else set /a argCnt-=1
)
del "%temp%\getArg.txt"
goto :initCallBack
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:prepareArgument
::: Convert a string, so it can be used as an argument for calling a program
set "var=!%~2!"
if defined var (
	set "var=!var:^=^^!"
	set "var=!var:&=^&!"
	set "var=!var:|=^|!"
	set "var=!var:>=^>!"
	set "var=!var:<=^<!"
	set "var=%var%"
)
set "%~1=!var!"
exit /b
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:fn_$arg_parser arg_line
REM *** @TODO: ENDLOCAL all arg-... variables
::: Output arg0, ..., arg<n> and arg.len
::: arg0 ... arg<n> contains unquoted arguments
::: an argument that contains only one quote (last character in line) is treated as quoted  arg=" -> arg=<empty>, arg.quoted=1
::: arg0.quoted contains 1 if the argument was quoted
::: \ escapes the next character (also inside quotes), can escape delimiters outside quotes, can escape quotes
::: Only \" is replaced to a single quote ", all other \<char> are unchanged

(set^ arg_line=!%1!)
call :strlen arg_len arg_line
set /a arg_len-=1
echo !arg_len! !arg_line!
set "quoted="
rem set "escapeChar="   --- "Say: \"Hello\" to frank\n"
set /a arg.len=0
set "arg0="
for /L %%I in (0 1 !arg_len!) DO (
	for %%# in (!arg.len!) DO  (
		set "char=!arg_line:~%%I,1!"
		set "isDelim="

		if "!escapeChar!!char!" == ^""" set "quoted=!quoted:~,0!"

		REM echo %%I: "!char!" quote: !quote!
		%= only outside quotes =%
		%= check if char is a delim =%
		FOR /F "tokens=1,2 delims=, %TAB%" %%D in ("isDelim!char!NO") DO (
			if "%%D" == "isDelim" (
				set isDelim=1
			)
		)

		REM *** Split arguments by not escaped delimiter
		if "!isDelim!,!quoted!,!escapeChar!" == "1,," (
			REM *** Finalize arg, test if arg is quoted
			if defined arg%%# (
				set arg%%#.quoted=
				REM echo    #in %%# "!arg%%#:~,1!!arg%%#:~-1!"
				if "!arg%%#:~,1!!arg%%#:~-1!" == """" (
					if "!arg%%#:~-2,-1!" NEQ "\" (
						set arg%%#.quoted=1
						set "arg%%#=!arg%%#:~1,-1!"
					)
				)
				if defined arg%%# (
					set ^"arg%%#=!arg%%#:"\"="!"
				)
				set /a arg.len+=1
			)
		)

		if defined escapeChar (
			set "escapeChar="
			if "!char!" EQU ^""" (
				REM *** Replace escaped quotes with "\" that can be safely detected and replaced later
				set "char="\""
			) ELSE IF defined isDelim (
				set "isDelim="
			) ELSE (
				set "char=\!char!"
			)
		) ELSE if "!char!" == "\" set "escapeChar=\"

		if defined quoted set "isDelim="

		REM *** Append char to arg
		if "!isDelim!!escapeChar!" == "" (
			set "arg%%#=!arg%%#!!char!"
		)
	)
)

for %%# in (!arg.len!) DO (
	REM *** Last character is \
	if defined escapeChar (
		set "arg%%#=!arg%%#!\"
	)

	REM *** Duplicated code
	REM *** Finalize arg, test if arg is quoted
	if defined arg%%# (
		set arg%%#.quoted=
		echo out %%# "!arg%%#:~,1!!arg%%#:~-1!"
		if "!arg%%#:~,1!!arg%%#:~-1!" == """" (
			if "!arg%%#:~-2,-1!" NEQ "\" (
				set arg%%#.quoted=1
				set "arg%%#=!arg%%#:~1,-1!"
			)
		)
		if defined arg%%# (
			set ^"arg%%#=!arg%%#:"\"="!"
		)
		set /a arg.len+=1
	)
)
REM *** Create a second variable with name "arg.max", useful for FOR loops
set /a arg.max=!arg.len!-1

exit /b
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b
