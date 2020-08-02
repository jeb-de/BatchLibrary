@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

REM *** Library guard, forces to load libBase and prevents multiple loads of the same library
%$LIB_LOAD_ONCE:call "%~dp0\libBase.cmd" :=%

%$LIB_NEW_MACRO% $absolutePath
%$LIB_NEW_MACRO% $dirname
REM %$LIB_NEW_MACRO% $basename
%$LIB_NEW_MACRO% $relativePath
%$LIB_NEW_MACRO% $isFolder
%$LIB_NEW_MACRO% $isFile
REM %$LIB_NEW_MACRO% $isLink
REM %$LIB_NEW_MACRO% $isUNC
REM %$LIB_NEW_MACRO% $isNetworkPath

::: pathVar has to be a path without filename
::: Returns a normalized absolutePath
::: relative paths are enriched with parts of the current working dir
:define_$absolutePath <resultVar> [<pathVar>|"pathStr"]
%$lib.macrodefine.free% set ^"%%Z=for %$FOR:param=$% in (1 2) do if %$FOR:param=$%==2 (%$\n%
    setlocal EnableDelayedExpansion %$\n%
	for /F "tokens=1,*" %$FOR:param=1% in ("%%!argv%%!") do (%$\n%
        if "%$FOR:param=~2%" == "%$FOR:param=2%" ( %$\n%
			set "pathStr=%%!%$FOR:param=2%%%!" %$\n%
		) ELSE ( %$\n%
			set "pathStr=%$FOR:param=~2%" %$\n%
		) %$\n%
		%= Remove enclosing quotes, can skip, if pathStr is empty or begins with ; =% %$\n%
		FOR /F "delims=" %$FOR:param=2% in ("%%!pathStr%%!") DO set "pathStr=%$FOR:param=~2%" %$\n%
		for /F "delims=" %$FOR:param=2% in (""%%!pathStr%%!\"") Do (  %$\n%
			endlocal %$\n%
			endlocal %$\n%
			set "%$FOR:param=~1%=%$FOR:param=~f2%"  %$\n%
		)  %$\n%
    )%$\n%
) else setlocal ^& set argv= "

exit /b
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

::: filename has to be a path with filename
::: Returns the normalized path to filename
::: relative paths are enriched with parts of the current working dir
:define_$dirname <resultVar> [<pathVar>|"pathStr"]
%$lib.macrodefine.free% set ^"%%Z=for %$FOR:param=$% in (1 2) do if %$FOR:param=$%==2 (%$\n%
    setlocal EnableDelayedExpansion %$\n%
	for /F "tokens=1,*" %$FOR:param=1% in ("%%!argv%%!") do (%$\n%
        if "%$FOR:param=~2%" == "%$FOR:param=2%" ( %$\n%
			set "pathStr=%%!%$FOR:param=2%%%!" %$\n%
		) ELSE ( %$\n%
			set "pathStr=%$FOR:param=~2%" %$\n%
		) %$\n%
		%= Remove enclosing quotes, can skip, if pathStr is empty or begins with ; =% %$\n%
		FOR /F "delims=" %$FOR:param=2% in ("%%!pathStr%%!") DO set "pathStr=%$FOR:param=~2%" %$\n%
		for /F "delims=" %$FOR:param=2% in (""%%!pathStr%%!\"") Do (  %$\n%
			endlocal %$\n%
			endlocal %$\n%
			set "%$FOR:param=~1%=%$FOR:param=~dp2%"  %$\n%
		)  %$\n%
    )%$\n%
) else setlocal ^& set argv= "

exit /b
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:define_$relativePath <resultVar> [<pathVar>|"pathStr"] [<basePathVar>|"basePathStr"]]
%$lib.macrodefine.free% set ^"%%Z=for %$FOR:param=$% in (1 2) do if %$FOR:param=$%==2 (%$\n%
    setlocal EnableDelayedExpansion %$\n%
	for /F "tokens=1,2,3" %$FOR:param=1% in ("%%!argv%%!") do (%$\n%
		%= *** Exract arg2=pathVar/pathStr =% %$\n%
        if "%$FOR:param=~2%" == "%$FOR:param=2%" ( %$\n%
			set "pathStr=%%!%$FOR:param=2%%%!" %$\n%
		) ELSE ( %$\n%
			set "pathStr=%$FOR:param=~2%" %$\n%
		) %$\n%
		%= Remove enclosing quotes, can skip, if pathStr is empty or begins with ; =% %$\n%
		FOR /F "delims=" %$FOR:param=2% in ("%%!pathStr%%!") DO set "pathStr=%$FOR:param=~2%" %$\n%
		for /F "delims=" %$FOR:param=2% in (""%%!pathStr%%!\"") Do (  %$\n%
		%= *** Exract arg3=basePathVar/basePathStr/<current workdir> =% %$\n%
        if "%$FOR:param=~3%" == "%$FOR:param=3%" ( %$\n%
			set "basePathStr=%%!%$FOR:param=3%%%!" %$\n%
			if not defined set "basePathStr=%%!cd%%!"
		) ELSE ( %$\n%
			set "basePathStr=%$FOR:param=~3%" %$\n%
		) %$\n%
echo #1 %$FOR:param=1%, %$FOR:param=2%, %$FOR:param=3%,  %$\n%
		for /F "tokens=2,3 delims=<" %$FOR:param=2% in ("-<%%!pathStr%%!<%%!basePathStr%%!") Do (  %$\n%
			set "relpath=%$FOR:param=~f2%" %$\n%
			set "relpath=%%!relpath:%$FOR:param=~3%=%%!" %$\n%
			for /F "delims=" %$FOR:param=2% in (""%%!relpath%%!"") DO ( %$\n%
				endlocal %$\n%
				endlocal %$\n%
echo #2 %$FOR:param=1%, %$FOR:param=2%, %$FOR:param=3%,  %$\n%
				set "%$FOR:param=~1%=%$FOR:param=~f2%"  %$\n%
			) %$\n%
		)  %$\n%
    )%$\n%
) else setlocal ^& set argv= "


exit /b
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:define_$isFolder <resultVar> <folderVar>|"folderStr"
%$lib.macrodefine.free% set ^"%%Z=for %$FOR:param=$% in (1 2) do if %$FOR:param=$%==2 (%$\n%
    setlocal EnableDelayedExpansion %$\n%
	for /F "tokens=1,*" %$FOR:param=1% in ("%%!argv%%!") do (%$\n%
        if "%$FOR:param=~2%" == "%$FOR:param=2%" ( %$\n%
			set "pathStr=%%!%$FOR:param=2%%%!" %$\n%
		) ELSE ( %$\n%
			set "pathStr=%$FOR:param=~2%" %$\n%
		) %$\n%
		%= Remove enclosing quotes, can skip, if pathStr is empty or begins with ; =% %$\n%
		FOR /F "delims=" %$FOR:param=2% in ("%%!pathStr%%!") DO set "pathStr=%$FOR:param=~2%" %$\n%
		FOR /F "delims=" %$FOR:param=2% in (""%%!pathStr%%!"") DO ( %$\n%
			FOR /F "delims=d" %$FOR:param=3% in ("""%$FOR:param=~a2%#Fail") DO ( %$\n%
				FOR /F "tokens=2" %$FOR:param=4% IN ("%$FOR:param=~3% 0 1") DO ( %$\n%
					endlocal %$\n%
					endlocal %$\n%
					set /a %$FOR:param=1%=%$FOR:param=4% %$\n%
				)%$\n%
			)%$\n%
		)%$\n%
	)%$\n%
) else setlocal ^& set argv= "
exit /b
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b

:define_$isFile <filenameVar>
%$lib.macrodefine.free% set ^"%%Z=for %$FOR:param=$% in (1 2) do if %$FOR:param=$%==2 (%$\n%
    setlocal EnableDelayedExpansion %$\n%
	for /F "tokens=1,*" %$FOR:param=1% in ("%%!argv%%!") do (%$\n%
        if "%$FOR:param=~2%" == "%$FOR:param=2%" ( %$\n%
			set "pathStr=%%!%$FOR:param=2%%%!" %$\n%
		) ELSE ( %$\n%
			set "pathStr=%$FOR:param=~2%" %$\n%
		) %$\n%
		%= Remove enclosing quotes, can skip, if pathStr is empty or begins with ; =% %$\n%
		FOR /F "delims=" %$FOR:param=2% in ("%%!pathStr%%!") DO set "pathStr=%$FOR:param=~2%" %$\n%
		FOR /F "delims=" %$FOR:param=2% in (""%%!pathStr%%!"") DO ( %$\n%
			FOR /F "delims=d" %$FOR:param=3% in (""%$FOR:param=~a2%"") DO ( %$\n%
				FOR /F "tokens=2" %$FOR:param=4% IN ("%$FOR:param=~3% 1 0") DO ( %$\n%
					endlocal %$\n%
					endlocal %$\n%
					set /a %$FOR:param=1%=%$FOR:param=4% %$\n%
				)%$\n%
			)%$\n%
		)%$\n%
	)%$\n%
) else setlocal ^& set argv= "
exit /b
::: End of function detector line %~* *** FATAL ERROR: missing parenthesis or exit /b
