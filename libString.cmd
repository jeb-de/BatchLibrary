@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

%$LIB_LOAD_ONCE:call "%~dp0\libBase.cmd" :=%
%$LIB_INCLUDE% libEndlocal

%$LIB_NEW_MACRO% $strLen
%$LIB_NEW_MACRO% $trim
%$LIB_NEW_MACRO% $rightTrim
%$LIB_NEW_MACRO% $leftTrim
%$LIB_NEW_MACRO% $strNOP
%$LIB_NEW_MACRO% $toUpper
%$LIB_NEW_MACRO% $toLower

exit /b

:define_$strLen <resultVar> <strVar>
REM *** To build a real long string use:
REM *** set "longTest=."
REM *** for /L %%n in (1 1 14) DO (set^ longTest=!longTest:~-4000!!longTest:~-4191!)

REM setlocal DisableDelayedExpansion
%$lib.macrodefine.free% set ^"%%Z=for %$FOR:param=$% in (1 2) do if %$FOR:param=$%==2 (%$\n%
	for /F "tokens=1,2 delims== " %$FOR:param=1% in ("%%!argv%%!") do (%$\n%
%= 		*** remove the local variable "argv" =% %$\n%
		endlocal%$\n%
%= 		*** copy content to temporary variable, the carets are for extended length, up to 8191chars =% %$\n%
		(set%%^^ tmp=%%!%$FOR:param=~2%%%!)%$\n%
		if defined tmp (%$\n%
			set len=1%$\n%
			for %$FOR:param=#% in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (%$\n%
				  if "%%!tmp:~%$FOR:param=#%,1%%!" neq "" (%$\n%
					set /a "len+=%$FOR:param=#%"%$\n%
					set "tmp=%%!tmp:~%$FOR:param=#%%%!"%$\n%
				  )%$\n%
			)%$\n%
		) ELSE set len=0%$\n%
%= 		*** return the result out of scope =% %$\n%
		%= SIMPLE Return =% %$\n%
		for %$FOR:param=V% in (%%!len%%!) do endlocal ^& set "%$FOR:param=~1%=%$FOR:param=V%" %$\n%
	)%$\n%
) else setlocal EnableDelayedExpansion ^& setlocal ^& set argv= "

@exit /b

REM *** To left trim a string, remove all white spaces from the left side
:define_$leftTrim <resultVar> <strVar> [<delimCharacters>]
%$lib.macrodefine.disabled%
@set ^"%MACRO_NAME%=for %%$ in (1 2) do if %%$==2 (%$\n%
	for /F "tokens=1,2,3" %%1 in ("!argv!") do (%$\n%
%= 		*** remove the local variable "argv" =% %$\n%
		endlocal%$\n%
%= 		*** copy content to temporary variable, the carets are for extended length, up to 8191chars =% %$\n%
		if defined %%~2 (%$\n%
			%= *** if arg3 is set to 1, treat CR and LF also as white spaces, else as normal chars *** =% %$\n%
			(set^^ str=!%%~2!)%$\n%
			if "%%~3" == "1" ( %$\n%
				set "CRLF= " %$\n%
			) ELSE ( %$\n%
				set "CRLF=#" %$\n%
			) %$\n%
			set /a headLen=0 %$\n%
%= 			*** Replace CR and LF with space or #, depends on arg3 *** =% %$\n%
			FOR %%R in ("!CRLF!") DO ( %$\n%
				for %%C in ("!$LF!" "!$CR!") DO set "tmp=!str:%%~C=%%~R!" %$\n%
			) %$\n%
			%= replace all ; with #, to avoid the EOL char =% %$\n%
			set "tmp=!tmp:;=#!" %$\n%
			%= *** Binary search for white spaces *** =% %$\n%
			FOR %%n in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do ( %$\n%
%= 				*** left trim, search for spaces *** =% %$\n%
				set /a totalLen=headLen + %%n %$\n%
				for %%P in (!totalLen!) DO set "head=!tmp:~0,%%P!" %$\n%
				set "foundChars=" %$\n%
				FOR /F "tokens=1" %%5 in ("!head!") DO set foundChars=yes %$\n%
				if not defined foundChars ( %$\n%
					%= *** remove <n> more spaces *** = % %$\n%
					set /a headLen+=%%n %$\n%
				) %$\n%
			) %$\n%
			for /f "tokens=1" %%1 in ("!headLen!") do ( %$\n%
				set "str=!str:~%%1!" %$\n%
			) %$\n%
		) ELSE ( %$\n%
			set "str=" %$\n%
			set #1 %$\n%
		) %$\n%
%= 		*** copy the result =% %$\n%
		%$$endlocalForParam1:arg1=str% %$\n%
	)%$\n%
) else 	setlocal EnableDelayedExpansion ^& setlocal EnableDelayedExpansion ^& set argv= "

@%$endlocal% %MACRO_NAME%
@exit /b

:define_$rightTrim <resultVar> <strVar> [<delimCharacters>]
REM *** To right trim a string, remove all white spaces from the right side
REM *** Line feed and carriage returns can also be treated as white spaces

%$lib.macrodefine.disabled%
@set ^"%MACRO_NAME%=for %%$ in (1 2) do if %%$==2 (%$\n%
	for /F "tokens=1,2,3" %%1 in ("!argv!") do (%$\n%
%= 		*** remove the local variable "argv" =% %$\n%
		endlocal%$\n%
%= 		*** copy content to temporary variable, the carets are for extended length, up to 8191chars =% %$\n%
		if defined %%~2 (%$\n%
			%= *** if arg3 is set to 1, treat CR and LF also as white spaces, else as normal chars *** =% %$\n%
			(set^^ str=!%%~2!) %$\n%
			if "%%~3" == "1" ( %$\n%
				set "CRLF= " %$\n%
			) ELSE ( %$\n%
				set "CRLF=#" %$\n%
			) %$\n%
			set /a trailLen=0 %$\n%
%= 			*** Replace CR and LF with space or #, depends on arg3 *** =% %$\n%
			FOR %%R in ("!CRLF!") DO ( %$\n%
				for %%C in ("!$LF!" "!$CR!") DO set "tmp=!str:%%~C=%%~R!" %$\n%
			) %$\n%
			%= replace all ; with #, to avoid the EOL char =% %$\n%
			set "tmp=!tmp:;=#!" %$\n%
			%= *** Binary search for white spaces *** =% %$\n%
			FOR %%n in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do ( %$\n%
				set /a totalLen=trailLen + %%n %$\n%
				for %%7 in (!totalLen!) DO set "tail=!tmp:~-%%7!" %$\n%
					set "foundChars=" %$\n%
					FOR /F "tokens=1" %%8 in ("!tail!") DO set foundChars=yes %$\n%
					if not defined foundChars ( %$\n%
						%= *** remove <n> more spaces *** = % %$\n%
						set /a trailLen+=%%n %$\n%
					) %$\n%
			) %$\n%
			if "!trailLen!" NEQ "0" for %%n in (!trailLen!) do ( %$\n%
				set "str=!%%~2:~0,-%%n!" %$\n%
			) %$\n%
		) ELSE ( %$\n%
			set "str=" %$\n%
		) %$\n%
%= 		*** copy the result =% %$\n%
		%$$endlocalForParam1:arg1=str% %$\n%
	)%$\n%
) else 	setlocal EnableDelayedExpansion ^& setlocal EnableDelayedExpansion ^& set argv= "

@%$endlocal% %MACRO_NAME%
@exit /b

:define_$trim <resultVar> <strVar> [<delimCharacters>]
REM *** To trim a string, remove all white spaces from the left and right side
REM *** Line feed and carriage returns can also be treated as white spaces

%$lib.macrodefine.disabled%
@set ^"%MACRO_NAME%=for %%$ in (1 2) do if %%$==2 (%$\n%
	for /F "tokens=1,2,3" %%1 in ("!argv!") do (%$\n%
%= 		*** remove the local variable "argv" =% %$\n%
		endlocal%$\n%
%= 		*** copy content to temporary variable, the carets are for extended length, up to 8191chars =% %$\n%
		if defined %%~2 (%$\n%
			%= *** if arg3 is set to 1, treat CR and LF also as white spaces, else as normal chars *** =% %$\n%
			(set^^ str=!%%~2!)%$\n%
			if "%%~3" == "1" ( %$\n%
				set "CRLF= " %$\n%
			) ELSE ( %$\n%
				set "CRLF=#" %$\n%
			) %$\n%
			set /a headLen=0 %$\n%
			set /a trailLen=0 %$\n%
%= 			*** Replace CR and LF with space or #, depends on arg3 *** =% %$\n%
			FOR %%R in ("!CRLF!") DO ( %$\n%
				for %%C in ("!$LF!" "!$CR!") DO set "tmp=!str:%%~C=%%~R!" %$\n%
			) %$\n%
			%= replace all ; with #, to avoid the EOL char =% %$\n%
			set "tmp=!tmp:;=#!" %$\n%
			%= *** Binary search for white spaces *** =% %$\n%
			FOR %%n in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do ( %$\n%
%= 				*** left trim, search for spaces *** =% %$\n%
				set /a totalLen=headLen + %%n %$\n%
				for %%7 in (!totalLen!) DO set "head=!tmp:~0,%%7!" %$\n%
				set "foundChars=" %$\n%
				FOR /F "tokens=1" %%8 in ("!head!") DO set foundChars=yes %$\n%
				if not defined foundChars ( %$\n%
					%= *** remove <n> more spaces *** = % %$\n%
					set /a headLen+=%%n %$\n%
				) %$\n%
%= 				*** right trim, search for spaces *** =% %$\n%
				set /a totalLen=trailLen + %%n %$\n%
				for %%7 in (!totalLen!) DO set "tail=!tmp:~-%%7!" %$\n%
				set "foundChars=" %$\n%
				FOR /F "tokens=1" %%8 in ("!tail!") DO set foundChars=yes %$\n%
				if not defined foundChars ( %$\n%
					%= *** remove <n> more spaces *** = % %$\n%
					set /a trailLen+=%%n %$\n%
				) %$\n%
			) %$\n%
			for /f "tokens=1,2" %%1 in ("!headLen! !trailLen!") do ( %$\n%
				if "!trailLen!" EQU "0" ( %$\n%
					set "str=!str:~%%1!" %$\n%
				) ELSE ( %$\n%
					set "str=!str:~%%1,-%%2!" %$\n%
				) %$\n%
			) %$\n%
		) ELSE ( %$\n%
			set "str=" %$\n%
		) %$\n%
%= 		*** copy the result =% %$\n%
		%$$endlocalForParam1:arg1=str% %$\n%
	)%$\n%
) else 	setlocal EnableDelayedExpansion ^& setlocal EnableDelayedExpansion ^& set argv= "

@%$endlocal% %MACRO_NAME%
@exit /b

:define_$strNOP
::: Limits: The maximum length is 8179 characters (limited by $$endlocalForParam1)

%$lib.macrodefine.disabled%

@SET "DEBUG_SCOPE_DEPTH= ^& set /a scopeDepth+=1"
@set ^"%MACRO_NAME%=for %%$ in (1 2) do if %%$==2 (%$\n%
	for /F "tokens=1,2" %%1 in ("!argv!") do (%$\n%
%= 		*** remove the local variable "argv" =% %$\n%
		endlocal%$\n%
%= 		*** copy variable content to V, the carets are for extended length > 8189 chars =% %$\n%
		(set^^^ str=!%%~2!)%$\n%
		%$$endlocalForParam1:arg1=str% %$\n%
	)%$\n%
) else 	setlocal EnableDelayedExpansion%DEBUG_SCOPE_DEPTH% ^& setlocal EnableDelayedExpansion%DEBUG_SCOPE_DEPTH% ^& set argv= "

@%$endlocal% %MACRO_NAME%
@exit /b

:define_$toLower <resultVar>=<strVar>
::: toLower <strVar>	- Stores the result in the same variable
%$lib.macrodefine.disabled%

@set ^"%MACRO_NAME%=for %%$ in (1 2) do if %%$==2 (%$\n%
	for /F "tokens=1,2 delims== " %%1 in ("!argv! !argv!") do (%$\n%
%= 		*** remove the local variable "argv" =% %$\n%
		endlocal%$\n%
%= 		*** copy content to temporary variable, the carets are for extended length, up to 8191chars =% %$\n%
		if defined %%~2 (%$\n%
			(set^^ str=!%%~2!) %$\n%
			for %%C in ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i"   %$\n%
					"J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r"       %$\n%
					"S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z" "Ä=ä"       %$\n%
					"Ö=ö" "Ü=ü") do (                                           %$\n%
				(set^^ str=!str:%%~C!)										%$\n%
			)%$\n%
		) ELSE ( %$\n%
			set "str=" %$\n%
		) %$\n%
		%$$endlocalForParam1:arg1=str% %$\n%
	)%$\n%
) else 	setlocal EnableDelayedExpansion ^& setlocal EnableDelayedExpansion ^& set argv= "

@%$endlocal% %MACRO_NAME%
@exit /b

:define_$toUpper <resultVar>=<strVar>
::: toUpper <strVar>	- Stores the result in the same variable
%$lib.macrodefine.disabled%

@set ^"%MACRO_NAME%=for %%$ in (1 2) do if %%$==2 (%$\n%
	for /F "tokens=1,2 delims== " %%1 in ("!argv! !argv!") do (%$\n%
%= 		*** remove the local variable "argv" =% %$\n%
		endlocal%$\n%
%= 		*** copy content to temporary variable, the carets are for extended length, up to 8191chars =% %$\n%
		if defined %%~2 (%$\n%
			(set^^ str=!%%~2!)%$\n%
			for %%C in ("A=A" "B=B" "C=C" "D=D" "E=E" "F=F" "G=G" "H=H" "I=I"   %$\n%
					"J=J" "K=K" "L=L" "M=M" "N=N" "O=O" "P=P" "Q=Q" "R=R"       %$\n%
					"S=S" "T=T" "U=U" "V=V" "W=W" "X=X" "Y=Y" "Z=Z" "Ä=Ä"       %$\n%
					"Ö=Ö" "Ü=Ü") do (                                           %$\n%
				(set^^ str=!str:%%~C!)										%$\n%
			)%$\n%
		) ELSE ( %$\n%
			set "str=" %$\n%
		) %$\n%
		%$$endlocalForParam1:arg1=str% %$\n%
	)%$\n%
) else 	setlocal EnableDelayedExpansion ^& setlocal EnableDelayedExpansion ^& set argv= "

@%$endlocal% %MACRO_NAME%
@exit /b
