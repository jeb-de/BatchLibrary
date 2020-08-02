@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

REM *** Library guard, forces to load libBase and prevents multiple loads of the same library
%$LIB_LOAD_ONCE:call "%~d0\:$:\..\%~p0\libBase.cmd" :=%

%$LIB_INCLUDE% libEndlocal

%$LIB_NEW_MACRO% $timeToMs
%$LIB_NEW_MACRO% $diffTime

exit /b

:define_$diffTime

%$lib.macrodefine.free% set ^"%%Z=for %%# in (1 2) do if %%#==2 (%$\n%
	for /F "tokens=1,2,3" %$FOR:param=1% in ("%%!argv%%!") do (%$\n%
		if "%$FOR:param=2%" == "" set "argv=%$FOR:param=1%.start %$FOR:param=1%.stop %$FOR:param=1%.diff" %$\n%
	) %$\n%
	for /F "tokens=1,2,3" %$FOR:param=1% in ("%%!argv%%!") do (%$\n%
%= 		*** remove the local variable "argv" =% %$\n%
		endlocal%$\n%
%= 		*** calculate centi seconds for var1 and var2 =% %$\n%
		if defined %$FOR:param=1% if defined %$FOR:param=2% (%$\n%
			FOR /F "tokens=1-4 delims=:.," %$FOR:param=1% in ("%%!%$FOR:param=1%: =0%%!") DO (%$\n%
				set /a "centiA=(((1%$FOR:param=1%-100)*60+(1%$FOR:param=2%-100))*60+(1%$FOR:param=3%-100))*100+1%$FOR:param=4%-100"%$\n%
			)%$\n%
			FOR /F "tokens=1-4 delims=:.," %$FOR:param=1% in ("%%!%$FOR:param=2%: =0%%!") DO (%$\n%
				set /a "centiB=(((1%$FOR:param=1%-100)*60+(1%$FOR:param=2%-100))*60+(1%$FOR:param=3%-100))*100+1%$FOR:param=4%-100"%$\n%
			)%$\n%
			set /a "diff_ms=(centiB-centiA)*10"%$\n%
		) ELSE set /a diff_ms=0%$\n%
%= 		*** echo or store the result =% %$\n%
		for %%V in (%%!diff_ms%%!) do (%$\n%
			endlocal%$\n%
			if "%%~3" neq "" (%$\n%
				set "%%~3=%%V"%$\n%
			) else echo %%V%$\n%
		)%$\n%
	)%$\n%
) else setlocal EnableDelayedExpansion ^& setlocal ^& set argv= "
exit /b

:define_$timeToMs
%$lib.macrodefine.free% set ^"%%Z=for %%# in (1 2) do if %%#==2 (%$\n%
	for /F "tokens=1,2" %$FOR:param=1% in ("%%!argv%%!") do (%$\n%
%= 		*** remove the local variable "argv" =% %$\n%
		endlocal%$\n%
%= 		*** calculate milli seconds for var1 =% %$\n%
		FOR /F "tokens=1-4 delims=:.," %$FOR:param=1% in ("%%!%$FOR:param=1%: =0%%!") DO (%$\n%
			set /a "millisec=((((1%$FOR:param=1%-100)*60+(1%$FOR:param=2%-100))*60+(1%$FOR:param=3%-100))*100+1%$FOR:param=4%-100)*10"%$\n%
		)%$\n%
%= 		*** echo or store the result =% %$\n%
		for %%V in (%%!millisec%%!) do (%$\n%
			endlocal%$\n%
			if "%%~2" neq "" (%$\n%
				set "%%~2=%%V"%$\n%
			) else echo %%V%$\n%
		)%$\n%
	)%$\n%
) else 	setlocal EnableDelayedExpansion ^& setlocal ^& set argv= "

exit /b

