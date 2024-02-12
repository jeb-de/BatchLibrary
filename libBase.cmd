@echo off
REM *** Library Version is used to rebuild the minimized version, when changed
set "$lib_version=0.9.1 2020-02-10"

REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

REM *** Reset the errorlevel to 0, to detect if the call to libBase-min.cmd fails
(call )

REM *** Minimized version
%$LIB_LOAD_ONCE:call "%~d0\:$:%$lib_version%:\..\%~p0\libBase-min.cmd" :=%
if errorlevel 1 (
    REM *** No minimized version found, rebuild it
    REM *** Remove all lines beginning with REM or :::, remove empty lines
    REM *** This results into 40% faster load time
    REM *** The first regex-class contains a space and TAB, not optimal, but works!
    findstr /V /R /C:"^[ 	]*REM"  /C:"^ *:::" /C:"^$" "%~f0" > "%~dpn0-min.cmd"
    call :$
)

REM *** Initializing is already done by :$
@exit /b

:$
REM *** This label can only be reached in libBase-min.cmd
REM *** Check for version differences between libBase.cmd and libBase-min.cmd
REM *** In %~0 is the version of libBase.cmd, in $lib_version the one of libBase-min.cmd
FOR /F "tokens=4 delims=:" %%L in ("%~0") DO (
    if "%%L" NEQ "%$lib_version%" (
        REM *** Rebuild required, the minimize must be done from libBase.cmd
        REM *** Restore the lib_version to the one of libBase.cmd
        set "$lib_version=%%L"
        exit /b 2
    )
)

::: Initialize libBase
if defined LIBRARY_DEBUG echo DEBUG: Initializing libBase
call :define_$PCT

REM call :_checkGlobalFORScope
call :define_$lib.macrodefine.free

call :define_$LIB_NEW_MACRO

%$LIB_NEW_MACRO% $LIB_CREATE_TRAMPOLINE

%$LIB_NEW_MACRO% $LIB_LOAD_ONCE
%$LIB_NEW_MACRO% $LIB_INCLUDE

%$LIB_NEW_MACRO% $$endlocalForParam1

REM *** Required for endlocalForParam1
REM *** Fastest way to create a CR
copy /z "%~f0" nul > out.tmp
for /F "delims= " %%C in (out.tmp) do set "$CR=%%C"


REM *****************************************
REM ***** COMPATIBILITY LAYER for lib.macrodefine.disabled AND LOAD_MACRO
call :define_$lib.macrodefine.disabled

%$LIB_NEW_MACRO% $LIB_LOAD_MACRO

REM *** Move to other library, libDebug?
%$LIB_CREATE_TRAMPOLINE% $showVariable

if defined LIBRARY_DEBUG echo DEBUG: Finished initializing libBase

REM *** The init was triggered by a LOAD_ONCE
REM *** Detect the caller and register it
(
    (goto) 2>nul
    setlocal EnableDelayedExpansion
    set "path="
    set "pathExt=;"
    call set "libLoadedVar=$%%~n0.loaded"
    call set "libName=%%~n0"
    FOR /F "tokens=1,2 delims= " %%0 in ("!libLoadedVar! !libName!") DO (
        endlocal
        if defined %%~0 (
            %= library is already loaded, this is UNEXPECTED HERE =%
            echo ERROR: ************************* library is already loaded, this is UNEXPECTED HERE *************************
            exit /b
        ) else (
            REM *** Mark the (libBase) library as loaded
            set "%%~0=1"
        )
    )

)
@exit /b
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

REM *** Remarks for macros:
REM ***  1. To define a macro in a library use:
REM ***         %$LIB_NEW_MACRO% <macroName>
REM ***         This calls a function in the same file, named ":define_<macroName>"
REM ***            The $LIB_NEW_MACRO functions creates for-variables
REM ***            %%$ = <macroname>
REM ***            %%! = Expands to a single !, used for delayed-independent macro definitions
REM ***            %%^ = Expands to a single ^, used for delayed-independent macro definitions

REM ***  2. Defining macros uses a special definition function, with the name :define_<MACRO_NAME>
REM ***        The definition of a macro is done by:
REM ***        %$LIB_NEW_MACRO% <MACRO_NAME>
REM ***        - This calls the :define_<MACRO_NAME>
REM ***        - A debug message can be printed
REM ***        - An $$LIBRARY_NEW_MACRO_HOOK function can be executed (when defined, see 6.)
REM ***        - FOR-variables are defined %%Z=<MACRO_NAME>

REM ??? How to safely create a FOR-variables in a lib.macrodefine.free %%! or %%^: The $FOR macro fails EDE/DDE: %$FOR:param=!%  or %$FOR:param=^%   vs %%! %%^
REM *** Currently using: %$PERCENT%%%!

REM ***        The $lib.macrodefine.disabled-macro disables the delayed expansion and set the MACRO_NAME variable (to the macro name, in this case $MyMacroName)
REM *** :SAMPLE:    :define_$MyMacroName <description of paramters>
REM *** :SAMPLE:    %$MACRO_OPEN% %~1
REM *** :SAMPLE:    set ^"%MACRO_NAME%=for %%# in (1 2) do if %%#==2 (%\n%
REM *** :SAMPLE:        ....
REM *** :SAMPLE:        end of macro
REM *** :SAMPLE:        ) else setlocal EnableDelayedExpansion ^& setlocal ^& set argv= "
REM *** :SAMPLE:
REM *** :SAMPLE:    %$MACRO_CLOSE% %MACRO_NAME%
REM *** :SAMPLE:
REM *** :SAMPLE:    exit /b

REM ***  3. Parameter characters: Use  Do NOT use any of these characters as a FOR parameter: $adfnpstxzADFNPSTXZ
REM ***        Because the FOR-parser does not stop at these characters, if the next character is also a FOR parameter, it takes that one instead
REM ***        The problem occurs, because in any FOR-loop all parameters are visible from a "global" space
REM ***        Use only one or a range of: bc e ghijklm o qr uvw y 0123456789 #<>"&()[]{}=?!%/\+-*,;.:_
REM ***        Sample:
REM ***        For %%.  in (DOTDOT) DO FOR %%n in (myfile) do echo %%~n.
REM ***        Output: "DOTDOT" instead of "myFile."

REM ***  4. Parameter characters: Do NOT use any of these characters as a FOR parameter: $adfnpstxzADFNPSTXZ
REM ***        Because the FOR-parser does not stop at these characters, if the next character is also a FOR parameter, it takes that one instead
REM ***        The problem occurs, because in any FOR-loop all parameters are visible from a "global" space
REM ***        Use only one or a range of: bc e ghijklm o qr uvw y 0123456789 #<>"&()[]{}=?!%/\+-*,;.:_
REM ***        Sample:
REM ***        For %%.  in (DOTDOT) DO FOR %%n in (myfile) do echo %%~n.
REM ***        Output: "DOTDOT" instead of "myFile."


:fn_$endlocalDisabled
(setlocal enableDelayedExpansion & set /a scopeDepth+=1
set "rtn=!%1!"
set "rtn=!rtn:%%=%%3!"
set "rtn=!rtn:""n=%%~L!"
set "rtn=!rtn:""r=%%4!"
set "rtn=!rtn:""q=%%~5!"
)
for /f "tokens=1-4" %%3 in (^"%% !$CR! """") do (
  endlocal
  set "%1=%rtn%"
  exit /b
)
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:define_$PCT
::: This defines the $PCT variable containing exactly one percent, this works even inside a FOR-Loop when all possible for-variables are set
::: Here it's an overkill, as for-variable expansion isn't active here
::: Using !$PCT! avoids inaccedtial expansions!
::: Should be used, when CALL is used inside macros to expand percents in the CALL phase, like:
:::     CALL set var=%%varname%%
::: should be written:
:::     CALL set var=!$PCT!!$PCT!secondPhase!$PCT!!$PCT!
::: The first would expand "%%v" when a for-variable %%v exists
set ^"$PCT=%%<nul"
@exit /b
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:define_$lib.macrodefine.free
if defined LIBRARY_DEBUG echo DEBUG: define_$lib.macrodefine.free
::: Macro to define macros without knowing the delayed expansion mode
::: Usage:
::: %$lib.macrodefine.free% set %%Z=...
:::
::: Reserved FOR variables: !^Z
::: %%! - contains one !
::: @TODO: %%" - contains nothing, can be used as a disappearing quote
::: %%^ - results into one caret, attention read the other comments!
::: %%Z - contains the macro name
::: @TODO: Change %%Z to %%$

:::
::: While defining a new macro:
::: - Each bang ! has to be changed to %%!   regex-replace: (?<!%%)! -> %%!

::: - Each caret ^ has to be changed to %%^^ regex-replace: (?<!%%)\^ -> %%^^
::: - If carets are inside quotes replace them only with %%^  .
::: - But be careful only replace carets that should be placed in the macro itself
::: - Carets can also be used for escaping special chars in the definition phase, like ^&, ^<, ^|, ^"

::: - Each for-variable has to be changed to %$FOR:param=<modifiers-and-variable>%, "%% ~dpQ" --> "% $FOR:param=~dpQ%
::: - Avoid WEAK for-variables, weak are "adfnpstxzADFNPSTXZ"
::: - Replacement can be done with a regex-replace %% (?!Z)([\w\d~#$]+)  -> % $FOR:param=\1%

REM *** Defining a line feed for usage while defining macros
(set ^"$\n=^^^
%=empty=%
)

REM *** The $PERCENT variable is used to add a literal % into a macro, for use with FOR-variables
REM *** See also the $FOR variable
REM *** Prevents failures (unwanted expansion) if the for-variable %%1 is defined outside
REM *** set macro=FOR %$PERCENT%1 in (1) Do echo %$PERCENT%1
set "$PERCENT=%%%%~$=_p1_FOR-variable_DOLLAR_is_required_while_MACRO_DEFINITION_=:$"


REM *** The $PERCENT-CALL variable is used to add a literal % into a macro, for use with percent expansion by CALL
REM *** This avoids unwanted expansion of for-variables
REM *** set macro=FOR %%r in (42)
REM ***           call echo %%result%%   -- This expands to "42esult" instead of expanding the result variable
REM ***              call echo %$PERCENT-CALL%result%$PERCENT-CALL%
set "$PERCENT-CALL=%%%%~$==:$%$PERCENT%~$==:$"

REM *** The $FOR-BREAK can be used for the expansion of WEAK for-variables with tilde
REM *** % $FOR:param=~f% % $FOR-BREAK%  (without spaces)
REM *** This works as long as no percent for-variable exists
set "$FOR-BREAK=%%~$==:$%$PERCENT%~$==:$"

REM *** The $FOR variable is used to add a literal FOR-variable patterns into a macro
REM *** This avoids unwanted expansion if the for-variable %%1 is defined outside, while defining a delayed-independent macro
REM ***
REM *** This can also be used for the "weak" For-variable characters, weak are "adfnpstxzADFNPSTXZ"
REM *** FOR %%1 in (fail) do For %%f in ("1") do echo %%~f100Percent
REM *** The modified version works: FOR %%1 in (fail) do For %%f in ("1") do echo %$FOR:param=~f%100Percent
REM ***
REM *** BUT! The weak variables still fails, if the For-variable % exists. Ex. Expression "%~f%%" expect "100%" but expands to "c:\temp\SOMETHING"
REM *** Usage is different than the $PERCENT variable
REM *** %$FOR:param=~dpX%  --- Adds % ~dpX in a safe way
REM *** @ATTENTION: Different behaviour >=WIN7 vs XP, in XP the variable name must not contain spaces(delims)
REM FAILS IN XP: set "$FOR=%%%%~$= F1 FOR-variable DOLLAR is required while MACRO DEFINITION =:$param"
set "$FOR=%%%%~$=_F1_FOR-variable_DOLLAR_is_required_while_MACRO_DEFINITION_=:$param"
set "$FOR-SAFE=%%%%~$=_f2_FOR-variable_DOLLAR_is_required_while_MACRO_DEFINITION_=:$param%%%%~$==:$%$PERCENT%~$=_FOR-variable-SAFE_DOLLAR_is_required_IN_MACRO-CODE=:$"

REM *** Creating %%! and %%^ for defining the $lib.macrodefine.free in a safe way
REM *** The definition is independent of the current delayed expansion mode
REM *** This macro is used later for defining delayed-independent macros
REM *** When using the macro %$lib.macrodefine.free%  ...
REM *** then %%! contains a single !
REM *** %%^ creates a single ^, but it contains "^" in DDE or "^^!=!" in EDE mode
FOR /F "tokens=1 delims== " %%! in ("!=! ^^^!") DO ^
FOR /F %%^^ in ("^ ^^^^%%!=%%!") DO ^
set ^"$lib.macrodefine.free=@FOR /F "tokens=1 delims== " %%%%! in ("%%!=%%! %%^%%^%%^%%!") DO ^
@FOR /F %%%%^^%%^^ in ("%%^ %%^%%^%%^%%^%%^%%!=%%^%%!") DO @"

REM FOR /F "tokens=1" %%! in ("!=! ^^^^^!=:=:") DO ^
REM echo BEFORE: '%%!' & ^
REM FOR /F "tokens=1 delims== " %%! in ("%%%%! 2 3 4 5 6 7") DO ^
REM FOR /F %%^^ in ("%%^") DO ^

REM **** OLD DEPR: if defined LIBRARY_DEBUG echo DEBUG: define_$lib.macrodefine.free_EXT
REM **** OLD DEPR:
REM **** OLD DEPR: FOR %%$ in (1) DO ^
REM **** OLD DEPR: %$lib.macrodefine.free% set ^"$lib.macrodefine.free_EXT=FOR %$FOR:param=$% in (1) DO ^
REM **** OLD DEPR: FOR /F "tokens=1" %%%%! in ("%%!=%%! %%^%%^%%^%%!=:=:") DO ^
REM **** OLD DEPR: FOR /F "tokens=1 delims== " %%%%! in ("%%%%%%!") DO ^
REM **** OLD DEPR: FOR /F %%%%^^%%^^ in ("%%%%^ %%%%^%%^%%^%%^%%^%%!=%%^%%!") DO "

REM *** Variant with disappearing quote, but that results in problems when trying to add literally ... CALL SET "var=%%...%%"
REM set ^"$lib.macrodefine.free=FOR /F "tokens=1,4 delims== " %%%%! in ("%%!=%%! %%^%%^%%^%%!") DO @FOR /F %%%%^^%%^^ in ("%%^ %%^%%^%%^%%^%%^%%!=%%^%%!") DO"
@exit /b
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:_checkGlobalFORScope
if defined LIBRARY_DEBUG echo DEBUG: _checkGlobalFORScope
REM *** Check if the lib was called inside a FOR-loop
REM *** Currently check only if any parameters of "%:#0-9" is used in global scope
FOR %%Q in (1) DO (
    if "%%~$=OKAY=:%%" NEQ "" (
    if "%%~$=OKAY=:#" NEQ "" (
    if "%%~$=OKAY=:0" NEQ "" (
    if "%%~$=OKAY=:1" NEQ "" (
    if "%%~$=OKAY=:2" NEQ "" (
    if "%%~$=OKAY=:3" NEQ "" (
    if "%%~$=OKAY=:4" NEQ "" (
    if "%%~$=OKAY=:5" NEQ "" (
    if "%%~$=OKAY=:6" NEQ "" (
    if "%%~$=OKAY=:7" NEQ "" (
    if "%%~$=OKAY=:8" NEQ "" (
    if "%%~$=OKAY=:9" NEQ "" (
        goto :_break
    ))
    ))))))))))

    setlocal EnableDelayedExpansion
    echo *** FATAL ERROR: ***
    echo *** Library called inside a for loop and special characters are used "!$PCT!:#0-9"
    echo *** HARD STOP
    call :_SyntaxError 2> NULL
)
:_break
@exit /b
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:_SyntaxError
()

REM *** Loads a macro by calling it's :define_<macroName> function
REM *** The definition of a macro can use two different technics
REM ***
REM *** A) Using lib.macrodefine.free_SCOPE_DISABLED, using MACRO_SCOPE_DISABLED
REM ***   Pro:
REM ***            - macro defintion is easier than delayed-independent-definition
REM ***            - for-variables, "!" and "^" can be used without problems
REM ***            - Easier to embedd other macros, like %-$endlocalForParam1:args=str%
REM ***            - Local variables can be used
REM *** Contra:
REM ***            - Slow, the macro has to tranfered back via $endlocal
REM ***
REM *** B) Delayed-independent-definition, using MACRO_DELAY_INDEPENDENT
REM ***   Pro:
REM ***            - Faster, no endlocal required
REM ***   Contra:
REM ***            - Macro definition has to mask all "!" and "^" by %%! and %%^
REM ***            - MACRO_DELAY_INDEPENDENT can't set variables, without polute the gobal variable space

:define_$LIB_NEW_MACRO
::: **** Direct definiton of macros ****
::: This creates the %%Z for-variable with the macro name
::: Then it calls the defining function
REM *** OLD: Support for different :define_function
REM *** OLD: - if "%$FOR:param=~2%" == "" (set "func=:define_%$FOR:param=1%") ELSE (set "func=%$FOR:param=2%") %$\n% .
if defined LIBRARY_DEBUG echo DEBUG: define_$LIB_NEW_MACRO

FOR /F %%^^ in ("^ ^^^^%%!=%%!") DO ^
FOR %%$ in (1) DO %$lib.macrodefine.free% set ^"$LIB_NEW_MACRO=for %$FOR:param=$% in (1 2) do if %$FOR:param=$%==2 (%$\n%
    setlocal EnableDelayedExpansion %$\n%
    for /F "tokens=2,3,*" %$FOR:param=1% in (": %%!argv%%!") do (%$\n%
%=      *** Build the argument list, arg1=macroName, arg2=defining function =% %$\n%
        set "macro_name=%$FOR:param=1%" %$\n%
        set "func=:define_%$FOR:param=1%" %$\n%
        set "define_args=%$FOR:param=3%" %$\n%
    )%$\n%
    FOR /F "tokens=2" %$FOR:param=Z% in (": %%!macro_name%%!") DO ( %$\n%
    REM for /F "tokens=2" %$PCT%%%^^%%^^ in ("CARET-CARET-CARET %%^ free-for-use") DO ( %$\n%
        for /f "tokens=1" %$PCT%%%^^%%! in ("%%!func%%! %%!define_args%%!") DO ( %$\n%
            endlocal %$\n%
            endlocal %$\n%
            REM echo #0  Z=MacroName=%$FOR:param=Z% -   %$\n%
            REM echo #1  Exclam=Cmdline=%$PCT%%%!-   %$\n%
            REM echo #2  %$PCT%%%^^%%^^-   %$\n%
            REM echo #3  %$PCT%%%^^^"-   %$\n%
            if "%LIBRARY_DEBUG%" GTR "0" echo DEBUG LIB_NEW_MACRO: %$FOR:param=Z%, call %$PCT%%%! %$\n%
            FOR %$FOR:param=$% in (1) DO ( %$\n%
                FOR /F %%%%^^%%^^ in ("%%^ %%^%%^%%^%%^%%^%%!=%%^%%!") DO ( %$\n%
					%$$LIBRARY_NEW_MACRO_PRE_HOOK% %$\n%
                    call %$PCT%%%! %$PCT%%%^^^ %$\n%
                ) %$\n%
            ) %$\n%
            if errorlevel 1 (  %$\n%
                echo ERROR: Defining of macro %$FOR:param=Z% failed ^>^&2 %$\n%
                call "%~d0\:fn_$HALT:\..\%~pn0" %$\n%
            ) %$\n%
            if not defined %$FOR:param=Z% (%$\n%
                echo ERROR: Macro %$FOR:param=Z% is not defined ^>^&2 %$\n%
                call "%~d0\:fn_$HALT:\..\%~pn0" %$\n%
            ) %$\n%
            %$$LIBRARY_NEW_MACRO_HOOK% %$\n%
			%$$LIBRARY_NEW_MACRO_POST_HOOK% %$\n%
        ) %$\n%
    ) %$\n%
) else setlocal ^& set argv= "

if defined LIBRARY_DEBUG echo DEBUG: define_$LIB_NEW_MACRO finished

REM *** If no hook then leave
if not defined $$LIBRARY_NEW_MACRO_HOOK (
	exit /b
)

REM *** The hook is a embedded macro, therefor it can't be used directly
REM *** Create a direct-macro variant in _tmp
setlocal
FOR %%$ in (1) DO %$lib.macrodefine.free% set ^"_tmp=%$$LIBRARY_NEW_MACRO_HOOK%"^
FOR /F %%$ IN ("$LIB_NEW_MACRO") do FOR /F %%Z IN ("$LIB_NEW_MACRO") do (
	endlocal
	%_tmp%
)


@exit /b
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:define_$LIB_LOAD_ONCE
@if "%LIBRARY_DEBUG%" GTR "0" (
    set "_LIBRARY_DEBUG1.tmp=call echo DEBUG: Load library %$PERCENT-CALL%~n0, ready it's already loaded"
    set "_LIBRARY_DEBUG2.tmp=call echo DEBUG: Load library %$PERCENT-CALL%~n0"
)
REM
REM   REM *** In debug mode, show the loading of libBase
REM   %_LIBRARY_DEBUG2.tmp%

%$lib.macrodefine.free% set ^"%%Z=FOR %$FOR:param=$% in (1) DO (%$\n%
    setlocal EnableDelayedExpansion                     %$\n%
    set "path="                                         %$\n%
    set "pathExt=;"                                     %$\n%
    call set "libVarname=$%$PERCENT-CALL%~n0.loaded"    %$\n%
    FOR /F "delims=" %$FOR:param=L% in ("%%!libVarname%%!") DO (   %$\n%
        endlocal                                        %$\n%
        if defined %$FOR:param=~L% (                    %$\n%
            %= library is already loaded =%             %$\n%
            %_LIBRARY_DEBUG1.tmp%                       %$\n%
            exit /b                                     %$\n%
        ) else (                                        %$\n%
            set "%$FOR:param=~L%=1"                     %$\n%
            %= library needs to be loaded =%            %$\n%
            %_LIBRARY_DEBUG2.tmp%                       %$\n%
        )                                               %$\n%
    )                                                   %$\n%
) "

@exit /b
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b


:define_$LIB_INCLUDE <libName> [as <alias_name>]
@if "%LIBRARY_DEBUG%" GTR "0" (
    set "_LIBRARY_DEBUG.tmp=echo DEBUG LIB_INCLUDE  : Including Library %$FOR:param=1% from %~dp0%$FOR:param=~n1%.cmd"
    set "_LIBRARY_DEBUG2.tmp=echo DEBUG LIB_INCLUDE  : Finished including Library %$FOR:param=1%"
) ELSE (
    set "_LIBRARY_DEBUG.tmp="
    set "_LIBRARY_DEBUG2.tmp="
)

%$lib.macrodefine.free% set ^"%%Z=@for %$FOR:param=$% in (1 2) do if %$FOR:param=$%==2 (%$\n%
    setlocal EnableDelayedExpansion %$\n%
    for /F "tokens=2,3" %$FOR:param=1% in (": %%!argv%%!") do (%$\n%
        %_LIBRARY_DEBUG.tmp% %$\n%
        set "libName=%$FOR:param=~n1%"  %$\n%
        set "alias=%$FOR:param=2%" %$\n%
        endlocal %$\n%
        endlocal %$\n%
        call "%~dp0%$FOR:param=~n1%.cmd" %$\n%
        %_LIBRARY_DEBUG2.tmp% %$\n%
    )%$\n%
) else setlocal ^& set argv="

@exit /b
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b


::: Creates a trampoline macro
::: The macro will call a function in the original batch
::: That the trampoline works, requires in the destination batch file a line directly after the @echo off:
::: FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L
::: Example1:
::: In "C:\temp\myFile.bat": %$LIB_CREATE_TRAMPOLINE% $myMacro
::: Creates a macro, $myMacro=call "c:\:_$myMacro:\..\\temp\myFile.bat"
:::
::: Example2:
::: In "C:\temp\myFile.bat":
::: %$LIB_CREATE_TRAMPOLINE% $myMacro :otherDestination
::: Creates a macro, $myMacro=call "c:\:otherDestination:\..\\temp\myFile.bat"
:::
::: Example3:
::: In "C:\temp\myFile.bat":
::: %$LIB_CREATE_TRAMPOLINE% $myMacro :otherDestination "%%%%~f0"
::: Creates a macro, $myMacro=call "c:\:otherDestination:\..\\temp\myFile.bat" "%~f0"

REM @Improve: %$LIB_CREATE_TRAMPOLINE% <macro> [--safe-args] [--args-quoted] [--scope=disabled|enabled|caller(default)]
REM - Move all arguments to a for-variable (ex. %%*), when <macroName> is used

:define_$LIB_CREATE_TRAMPOLINE <macroName> [ <:functionName> [<user defined paramter list>]]
@if defined LIBRARY_DEBUG echo DEBUG: %0

%$lib.macrodefine.free% set ^"%%Z=for %$FOR:param=$% in (1 2) do if %$FOR:param=$%==2 (%$\n%
    for /F "tokens=1,2,*" %$FOR:param=1% in ("%%!argv%%!") do (%$\n%
        %_LIBRARY_DEBUG.tmp% %$\n%
        if "%$FOR:param=2%" == "" (set "func=:fn_%$FOR:param=1%") ELSE (set "func=%$FOR:param=2%") %$\n%
        for /F "tokens=1,2,* delims= " %$FOR:param=1% in ("%$FOR:param=1% %%!func%%! %$FOR:param=3%") do (%$\n%
            endlocal %$\n%
            if defined %$FOR:param=1% ( %$\n%
                echo ERROR $LIB_CREATE_TRAMPOLINE: %$FOR:param=1% is already defined. Trampoline missing in "%~f0" ? %$\n%
                call "%~d0\:fn_$HALT:\..\%~pn0" %$\n%
            ) %$\n%
    %=         *** prepare a call function for the trampoline =% %$\n%
            (call set %$FOR:param=1%=call "%$PERCENT-CALL%~d0\%$FOR:param=~2%:\..\%$PERCENT-CALL%~pnx0" %$FOR:param=3%) %$\n%
            if "%LIBRARY_DEBUG%" GTR "0" call echo DEBUG Create-TRAMPOLINE: %$FOR:param=1% to [%$PERCENT-CALL%~n0]%$FOR:param=2%%$\n%
        )%$\n%
    )%$\n%
) else setlocal EnableDelayedExpansion ^& set argv= "

@exit /b
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:define_$$endlocalForParam1
REM *** Warning this can't be used, if the next line is empty
REM *** It escapes the first character from the next line
REM ***
@(set \n=^^^
%=EMPTY=%
)

@(set LF=^
%=empty=%
)

REM *** \macroN is used in macros which are embedded in other macros
REM *** The need to add a two layered line feed
REM *** In the inner macro, line feeds are represented by "^\n\n"
REM *** Because when the inner macro is expanded in a outer macro,
REM *** the inner line feed construct "^\n\n" is expanded to a single "\n"
REM *** The next line is appended automatically (by the ^\n\n construct)
@set ^"\macroN=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^"
@if "!!" == "" (
    REM *** The first Caret has to be <E|DDE>
    REM *** \macroN is static
    REM *** expands always to  ^\n\n
    REM *** \macroN = "^^^\n\n^\n\n" doesn't work, because in EDE it expands to "\n\n"
    REM *** %%^ kann nicht verwendet werden, weil \macroN in lib.macrodefine.free_EXT expandiert wird
    REM ***    Unter lib.macrodefine.free_EXT wird aber "%^" -> "%^" statt zu "^"
    REM HACK HACK HACK
    set ^"\macroN=^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^"

)

REM *** Limit is 8168 characters, longer strings breaks at: for /f "delims=" %%R in (""%%!rtnDis%%!"")
REM ***
REM *** The macro syntax could be extended by
REM *** TODO1: args=<endlocal-count>,variablename
REM *** %endparam:args=2,str%
REM *** set "macro=FOR /F "tokens=1,2 delims=," %%# in ("args") DO for /L %%n in (0 1 %%#) DO echo %%n %%# %%$"
REM ***
REM *** TODO2: enableDelayedExpansion only when necessary, then endlocal-count+1

%$lib.macrodefine.free% set ^"%%Z=REM --- Macro: %%Z %\macroN%
    setlocal EnableDelayedExpansion %\macroN%
    if defined arg1 ( %\macroN%
        (set%%^^ rtn=%%!arg1%%!)%\macroN%
        for %$FOR:param=R% in ("%%!$CR%%!") do for %$FOR:param=L% in ("%%!$LF%%!") do (%\macroN%
%= Prepare rtnDis for disabled context, replace " with ""q, <CR> with ""r <LF> with ""n  =% %\macroN%
            set %%^^^"rtn=%%!rtn:"=""q%%!" %\macroN%
            set "rtn=%%!rtn:%$FOR:param=~R%=""r%%!" %\macroN%
            set "rtn=%%!rtn:%$FOR:param=~L%=""n%%!" %\macroN%
            set "rtnDis=%%!rtn%%!" %\macroN%
%= Prepare rtn for enabled context, like rtnDis and also replace ^ with ^^  and ! with ^!  =% %\macroN%
            set "rtn=%%!rtn:%%^=%%^%%^%%!" %\macroN%
            set "path=" %\macroN%
            set "pathExt=;" %\macroN%
            call set "rtn=%$PERCENT-CALL%rtn:%%^%%!=""c%%^%%!%$PERCENT-CALL%" %\macroN%
            set "rtn=%%!rtn:""c=%%^%%!" %\macroN%
            for /f "delims=" %$FOR:param=Q% in (""%%!rtnDis%%!"") do ( %\macroN%
            for /f "delims=" %$FOR:param=E% in (""%%!rtn%%!"") do ( %\macroN%
                for /L %$FOR:param=#% in (0 1 1) do endlocal %\macroN%
                if "%%!"=="" ( %\macroN%
                    set "%$FOR:param=1%=%$FOR:param=~E%" %%! %\macroN%
                    set "%$FOR:param=1%=%%!%$FOR:param=1%:""n=%$FOR:param=~L%%%!" %\macroN%
                    set "%$FOR:param=1%=%%!%$FOR:param=1%:""r=%$FOR:param=~R%%%!" %\macroN%
                    set %%^^^"%$FOR:param=1%=%%!%$FOR:param=1%:""q="%%!" %\macroN%
                ) else ( %\macroN%
                    set "%$FOR:param=1%=%$FOR:param=~Q%" %\macroN%
                    call "%~d0\:fn_$endlocalDisabled:\..\%~pn0" %$FOR:param=1% %\macroN%
                ) %\macroN%
            )) %\macroN%
        ) %\macroN%
    ) ELSE ( %\macroN%
        for /L %$FOR:param=#% in (0 1 1) do endlocal %\macroN%
        set "%$FOR:param=~1%=" %\macroN%
    ) %\macroN%
REM --- MacroEnd: %%Z %\macroN%
"
@exit /b
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:define_$#FREE-endlocalForParam1
set ^"\macroN=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^"
if "!!" == "" (
    REM *** The first Caret has to be <E|DDE>
    REM *** \macroN is static
    REM *** expands always to  ^\n\n
    REM *** \macroN = "^^^\n\n^\n\n" doesn't work, because in EDE it expands to "\n\n"
    REM *** %%^ kann nicht verwendet werden, weil \macroN in lib.macrodefine.free_EXT expandiert wird
    REM ***    Unter lib.macrodefine.free_EXT wird aber "%^" -> "%^" statt zu "^"
    REM HACK HACK HACK
    set ^"\macroN=^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^"

)

REM *** The macro provides two free for-variables
REM *** %%^ -> %%^
REM *** %%! -> %%!
FOR /F "tokens=1 delims== " %%! in ("!=! ^^^!") DO ^
FOR /F %%^^ in ("^ ^^^^%%!=%%!") DO ^
set ^"$#FREE-lib.macrodefine.free=@FOR /F "tokens=1 delims== " %%%%! in ("%%!=%%! %%^%%^%%^%%!") DO ^
@FOR /F %%%%^^%%^^ in ("%%^ %%^%%^%%^%%^%%^%%!=%%^%%!") DO @"


%$#FREE-lib.macrodefine.free% set ^"%%Z=REM --- Macro: %%Z %\macroN%
    setlocal EnableDelayedExpansion %\macroN%
    if defined arg1 ( %\macroN%
        (set%%^^ rtn=%%!arg1%%!)%\macroN%
        for %$FOR:param=R% in ("%%!$CR%%!") do for %$FOR:param=L% in ("%%!$LF%%!") do (%\macroN%
%= Prepare rtnDis for disabled context, replace " with ""q, <CR> with ""r <LF> with ""n  =% %\macroN%
            set %%^^^"rtn=%%!rtn:"=""q%%!" %\macroN%
            set "rtn=%%!rtn:%$FOR:param=~R%=""r%%!" %\macroN%
            set "rtn=%%!rtn:%$FOR:param=~L%=""n%%!" %\macroN%
            set "rtnDis=%%!rtn%%!" %\macroN%
%= Prepare rtn for enabled context, like rtnDis and also replace ^ with ^^  and ! with ^!  =% %\macroN%
            set "rtn=%%!rtn:%%^=%%^%%^%%!" %\macroN%
            set "path=" %\macroN%
            set "pathExt=;" %\macroN%
            call set "rtn=%$PERCENT-CALL%rtn:%%^%%!=""c%%^%%!%$PERCENT-CALL%" %\macroN%
            set "rtn=%%!rtn:""c=%%^%%!" %\macroN%
            for /f "delims=" %$FOR:param=Q% in (""%%!rtnDis%%!"") do ( %\macroN%
            for /f "delims=" %$FOR:param=E% in (""%%!rtn%%!"") do ( %\macroN%
                for /L %$FOR:param=#% in (0 1 1) do endlocal %\macroN%
                if "%%!"=="" ( %\macroN%
                    set "%$FOR:param=1%=%$FOR:param=~E%" %%! %\macroN%
                    set "%$FOR:param=1%=%%!%$FOR:param=1%:""n=%$FOR:param=~L%%%!" %\macroN%
                    set "%$FOR:param=1%=%%!%$FOR:param=1%:""r=%$FOR:param=~R%%%!" %\macroN%
                    set %%^^^"%$FOR:param=1%=%%!%$FOR:param=1%:""q="%%!" %\macroN%
                ) else ( %\macroN%
                    set "%$FOR:param=1%=%$FOR:param=~Q%" %\macroN%
                    call "%~d0\:fn_$endlocalDisabled:\..\%~pn0" %$FOR:param=1% %\macroN%
                ) %\macroN%
            )) %\macroN%
        ) %\macroN%
    ) ELSE ( %\macroN%
        for /L %$FOR:param=#% in (0 1 1) do endlocal %\macroN%
        set "%$FOR:param=~1%=" %\macroN%
    ) %\macroN%
REM --- MacroEnd: %%Z %\macroN%
"
@exit /b
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b


:fn_$HALT
()
@exit /b

::: @TODO: Move to another lib...
:fn_$showVariable
setlocal EnableDelayedExpansion
(set LF=^
%=empty=%
)
set "content=!%~1!"
FOR %%R in ("!$CR!") DO (
FOR %%L in ("!$LF!") DO (
    set "out=!content!"
    if defined out (
        set "out=!out:\=\\!"
        set "out=!out:%%~R=\r!"
        set "out=!out:%%~L=\n!"
        set "out=!out:    =\t!"
    )
    echo ------------------------------------------------------
    echo # Variable=%~1
    echo "!out!"
    echo ------------------------------------------------------
))
@exit /b

:define_$lib.macrodefine.disabled
if defined LIBRARY_DEBUG echo DEBUG: :define_$lib.macrodefine.disabled

(set $LF=^
%=empty=%
)

REM *** This FOR is used to get an exclamation mark in %%! independent if delayed expansion is enabled or disabled
REM *** The second token %%" contains two quotes "", using the param with tilde, %%~" results in nothing, can be used as disappearing quote
REM
REM *** The block of FOR's is used to build a "debug-parameter in %%5", but only when LIBRARY_DEBUG is defined
REM *** This avoids a helper variable, because a helper variable would change/remain in the global scope

FOR /F "tokens=1,2 delims=:=" %%! in ("!=""=:^^^!:!invisble=!:""") DO (
FOR /F %%$ in ("DOLLAR") DO ^
FOR /F "tokens=1,2" %%5 in ("X %LIBRARY_DEBUG%") DO ^
FOR /F "tokens=2-4" %%5 in ("%%~6 "^;" "" "^;"") DO ^
FOR /F "delims=" %%5 in (^"^
%%~5""^%= ***        Text in case of UNDEFINED *** =%
%= Empty line, used to create a line feed =%
%%~6"CALL echo   ...  lib.macrodefine.disabled %%!MACRO_NAME%%! in [%$PERCENT-CALL%~f0]%$PERCENT-CALL%~0 ""%= *** Text in case when LIBRARY_DEBUG is DEFINED *** =%
) DO ( %= *** End of conditional-for-parameter-block *** =%
        set "$lib.macrodefine.disabled=@setlocal DisableDelayedExpansion & for %$FOR:param=$% in (1 2) do @if %$FOR:param=$%==2 ( %%~"^%$LF%%$LF%^
%%~"                FOR /F "tokens=1" %$FOR:param=1% in ("%%!argv%%! """) DO @( %%~"^%$LF%%$LF%^
%%~"                    if "%$FOR:param=~1%" == "" ( %%~"^%$LF%%$LF%^
%%~"                        call set "MACRO_NAME=%$PERCENT-CALL%0" %%~"^%$LF%%$LF%^
%%~"                        set "MACRO_NAME=%%!MACRO_NAME:*_=%%!" %%~"^%$LF%%$LF%^
%%~"                    ) ELSE ( %%~"^%$LF%%$LF%^
%%~"                        set "MACRO_NAME=%$FOR:param=1%" %%~"^%$LF%%$LF%^
%%~"                    ) %%~"^%$LF%%$LF%^
%%~"                    %%~5 %= optional debug command =% %%~"^%$LF%%$LF%^
%%~"                    For /F "tokens=1" %$FOR:param=1% in ("%%!MACRO_NAME%%! """) DO @( %%~"^%$LF%%$LF%^
%%~"                        endlocal %%~"^%$LF%%$LF%^
%%~"                        set "MACRO_NAME=%$FOR:param=1%" %%~"^%$LF%%$LF%^
%%~"                    ) %%~"^%$LF%%$LF%^
%%~"                ) %%~"^%$LF%%$LF%^
%%~"            ) ELSE setlocal EnableDelayedExpansion & set argv= "
    )
)

@exit /b

        set "$lib.macrodefine.disabled=setlocal DisableDelayedExpansion & for %FOR:param=$% in (1 2) do if %FOR:param=$%==2 ( %%~"^%$LF%%$LF%^
%%~"                FOR /F "tokens=1" %$FOR:param=1% in ("%%!argv%%! """) DO ( %%~"^%$LF%%$LF%^
%%~"                    if "%$FOR:param=~1%" == "" ( %%~"^%$LF%%$LF%^
%%~"                        call set "MACRO_NAME=%$PERCENT-CALL%0" %%~"^%$LF%%$LF%^
%%~"                        set "MACRO_NAME=%%!MACRO_NAME:*_=%%!" %%~"^%$LF%%$LF%^
%%~"                    ) ELSE ( %%~"^%$LF%%$LF%^
%%~"                        set "MACRO_NAME=%$FOR:param=1%" %%~"^%$LF%%$LF%^
%%~"                    ) %%~"^%$LF%%$LF%^
%%~"                    %%~5 %= optional debug command =% %%~"^%$LF%%$LF%^
%%~"                    For /F "tokens=1" %$FOR:param=1% in ("%%!MACRO_NAME%%! """) DO ( %%~"^%$LF%%$LF%^
%%~"                        endlocal %%~"^%$LF%%$LF%^
%%~"                        set "MACRO_NAME=%$FOR:param=1%" %%~"^%$LF%%$LF%^
%%~"                    ) %%~"^%$LF%%$LF%^
%%~"                ) %%~"^%$LF%%$LF%^
%%~"            ) ELSE setlocal EnableDelayedExpansion & set argv= "

:define_$LIB_LOAD_MACRO <macroName> [<:definingFunction>]

%$lib.macrodefine.free% set ^"%%Z=for %$FOR:param=$% in (1 2) do if %$FOR:param=$%==2 (%\n%
    for /F "tokens=1,2,*" %$FOR:param=1% in ("%%!argv%%!") do (%\n%
%=        *** Build the argument list, arg1=macroName, arg2=defining function =% %\n%
        if "%$FOR:param=~2%" == "" (set "func=:define_%$FOR:param=1%") ELSE (set "func=%$FOR:param=2%") %\n%
        for /F "tokens=1,2,* delims= " %$FOR:param=1% in ("%$FOR:param=1% %%!func%%! %$FOR:param=3%") do (%\n%
            endlocal %\n%
            REM if "%LIBRARY_DEBUG%" GTR "0" %\n%
            echo DEPRICATED LIB_LOAD_MACRO: %$FOR:param=1% %\n%
            call %$FOR:param=2% %$FOR:param=3% %\n%
        ) %\n%
    )%\n%
) else     setlocal EnableDelayedExpansion ^& set argv= "

@exit /b
REM ----- End of function -----
