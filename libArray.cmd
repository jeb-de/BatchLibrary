@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

REM *** Library guard, forces to load libBase and prevents multiple loads of the same library
%$LIB_LOAD_ONCE:call "%~dp0\libBase.cmd" :=%
%$LIB_INCLUDE% libEndlocal

%$LIB_NEW_MACRO% $split
%$LIB_NEW_MACRO% $join

exit /b

:define_$split <resultArray>[=| ]<stringVar> [<delimCharVariable>] [<combine>]
::: splits the @stringVar into an array (@resultArray)
::: The delimiter can be set (default is line feed)
::: @TODO: Combine (or not) multiple adjacent delimiters
::: @TODO: support characters *?=~
::: @TODO: instead of toggling EDE, count the delimiters and use one FOR /L loop, count=strlen(tmp)-strlen(tmp_without_delims)
::: @TODO: OR toggling EDE only when disabled context
%$lib.macrodefine.free% set ^"%%Z=for %$FOR:param=$% in (1 2) do if %$FOR:param=$%==2 (%$\n%
	for /F "tokens=1,2,3" %$FOR:param=1% in ("%%!argv%%! = = =") do (%$\n%
%= 		*** remove the local variable "argv" =% %$\n%
		endlocal%$\n%
		if defined %$FOR:param=~2% ( %$\n%
			(set%%^^ tmp=%%!%$FOR:param=~2%%%!)%$\n%
			FOR %$FOR:param=L% IN ("%%!$LF%%!") DO (%$\n%
				if defined %$FOR:param=3% (	%$\n%
				%= *** replace delim char with LF *** =% %$\n%
					FOR %$FOR:param=#% in ("%%!%$FOR:param=3%%%!") DO (	%$\n%
						set "tmp=%%!tmp:%$FOR:param=~#%=%$FOR:param=~L%%%!"	%$\n%
					)	%$\n%
				)	%$\n%
%= 		*** prepare content, enclose each line of a multiline variable into quotes =% %$\n%
				set "tmp="%%!tmp:%$FOR:param=~L%="%$FOR:param=~L%"%%!"" %$\n%
				set "%$FOR:param=1%.len=" %$\n%
				for /F "delims=" %$FOR:param=V% in ("%%!tmp%%!") DO ( %$\n%
					if not defined %$FOR:param=1%.len ( %$\n%
						endlocal %$\n%
						set "%$FOR:param=1%.len=0" %$\n%
					) %$\n%
					setlocal EnableDelayedExpansion %$\n%
					for %$FOR:param=n% in (%%!%$FOR:param=1%.len%%!) DO ( %$\n%
						endlocal %$\n%
						(set%%^^ %$FOR:param=1%[%$FOR:param=n%]=%$FOR:param=~V%)%$\n%
						set /a %$FOR:param=1%.len=%$FOR:param=n%+1 %$\n%
					) %$\n%
				) %$\n%
			) %$\n%
		) else ( %$\n%
			endlocal %$\n%
			set /a %$FOR:param=1%.len=0 %$\n%
		) %$\n%
		set /a %$FOR:param=1%.max=%$FOR:param=1%.len-1 %$\n%
%= 		*** result is now in arg1[...], arg1.len and arg1.max =% %$\n%
	)%$\n%
) else 	setlocal EnableDelayedExpansion ^& setlocal ^& set argv= "

%$endlocal% %MACRO_NAME%

exit /b

:define_$join <destVar> <srcArray> [<delimVar>]
%$lib.macrodefine.disabled%

set ^"%MACRO_NAME%=for %%$ in (1 2) do if %%$==2 (%$\n%
	for /F "tokens=1,2,3" %%1 in ("!argv! $LF") do (%$\n%
%= 		*** remove the local variable "argv" =% %$\n%
		endlocal%$\n%
%= 		*** copy content to temporary variable, the carets are for extended length, up to 8191chars =% %$\n%
		set "joined="	%$\n%
		for /L %%n in (0 1 !%%2.max!) DO ( %$\n%
			if %%n == 0 ( %$\n%
				(set^^ joined=!%%~2[%%n]!) %$\n%
			) ELSE ( %$\n%
				(set^^ joined=!joined!!%%~3!!%%~2[%%n]!) %$\n%
			) %$\n%
		) %$\n%
%= 		*** transfer the result out of scope =% %$\n%
		%$$endlocalForParam1:arg1=joined% %$\n%
	)%$\n%
) else 	setlocal EnableDelayedExpansion ^& setlocal ^& set argv= "

%$endlocal% %MACRO_NAME%
exit /b

:define_$array.join <array> <newEntryVar>
%$lib.macrodefine.disabled%

set ^"%MACRO_NAME%=for %%$ in (1 2) do if %%$==2 (%$\n%
	for /F "tokens=1,2,3" %%1 in ("!argv! $LF") do (%$\n%
%= 		*** remove the local variable "argv" =% %$\n%
		endlocal%$\n%
%= 		*** copy content to temporary variable, the carets are for extended length, up to 8191chars =% %$\n%
		(set^^ %%1[!%%1.len!]=!%%2!) %$\n%
%= 		*** transfer the result out of scope =% %$\n%
		%$$returnToParam1:arg1=joined% %%1[!%%1.len!] %$\n%
		set /a %%1.len+=1, %%1.max=%%1.len-1 %$\n%
	)%$\n%
) else 	setlocal EnableDelayedExpansion ^& setlocal ^& set argv= "

%$endlocal% %MACRO_NAME%
exit /b

