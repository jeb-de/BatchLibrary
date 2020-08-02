@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

%$LIB_LOAD_ONCE:call "%~dp0\libBase.cmd" :=%
%$LIB_INCLUDE% libEndlocal

%$LIB_NEW_MACRO% $set

exit /b

:define_$set
%$lib.macrodefine.disabled% $set

set ^"%MACRO_NAME%=FOR /L %%N in (1 1 2) dO IF %%N==2 ( %\n%
    setlocal EnableDelayedExpansion                                 %\n%
    for /f "tokens=1,* delims== " %%1 in ("!argv!") do (            %\n%
        endlocal                                                    %\n%
        endlocal                                                    %\n%
        set "%%~1.Len=0"                                            %\n%
        set "%%~1="                                                 %\n%
        if "!!"=="" (                                               %\n%
            %= Used if delayed expansion is enabled =%              %\n%
                setlocal DisableDelayedExpansion                    %\n%
                for /F "delims=" %%O in ('"%%~2 | findstr /N ^^"') do ( %\n%
                if "!!" NEQ "" (                                    %\n%
                    endlocal                                        %\n%
                    )                                               %\n%
                setlocal DisableDelayedExpansion                    %\n%
                set "line=%%O"                                      %\n%
                setlocal EnableDelayedExpansion                     %\n%
                set pathExt=:                                       %\n%
                set path=;                                          %\n%
                set "line=!line:^=^^!"                              %\n%
                set "line=!line:"=q"^""!"                           %\n%
                call set "line=!$PCT!line:^!=q""^!!$PCT!"           %\n%
                set "line=!line:q""=^!"                             %\n%
                set "line="!line:*:=!""                             %\n%
                for /F %%C in ("!%%~1.Len!") do (                   %\n%
                    FOR /F "delims=" %%L in ("!line!") Do (         %\n%
                        endlocal                                    %\n%
                        endlocal                                    %\n%
                        set "%%~1[%%C]=%%~L" !                      %\n%
                        if %%C == 0 (                               %\n%
                            set "%%~1=%%~L" !                       %\n%
                        ) ELSE (                                    %\n%
                            set "%%~1=!%%~1!!$LF!%%~L" !            %\n%
                        )                                           %\n%
                    )                                               %\n%
                    set /a %%~1.Len+=1                              %\n%
                )                                                   %\n%
            )                                                       %\n%
        ) ELSE (                                                    %\n%
            %= Used if delayed expansion is disabled =%             %\n%
            for /F "delims=" %%O in ('"%%~2 | findstr /N ^^"') do ( %\n%
                setlocal DisableDelayedExpansion                    %\n%
                set "line=%%O"                                      %\n%
                setlocal EnableDelayedExpansion                     %\n%
                set "line="!line:*:=!""                             %\n%
                for /F %%C in ("!%%~1.Len!") DO (                   %\n%
                    FOR /F "delims=" %%L in ("!line!") DO (         %\n%
                        endlocal                                    %\n%
                        endlocal                                    %\n%
                        set "%%~1[%%C]=%%~L"                        %\n%
                    )                                               %\n%
                    set /a %%~1.Len+=1                              %\n%
                )                                                   %\n%
            )                                                       %\n%
        )                                                           %\n%
        set /a %%~1.Max=%%~1.Len-1                                  %\n%
)                                                                   %\n%
    ) else setlocal DisableDelayedExpansion^&set argv= "

%$endlocal% %MACRO_NAME%
exit /b
