@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

%$LIB_LOAD_ONCE:call "%~dp0\libBase.cmd" "%~f0" :=%

REM *** $LIB_LOAD_MACRO can't be used here, as it's not defined
REM *** The defintion of LIB_LOAD_MACRO required itself, the $endlocal macro

%$LIB_NEW_MACRO% $endlocal

REM %$LIB_NEW_MACRO% $endlocalLong
exit /b

::: Internal: This function is only needed, if the endlocal destination is DDE and there is at least one line feed present
::: Then a "normal" percent expansion with additional parameter replacements is necessary
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

:fn_$endlocalLongDisabled
setlocal enableDelayedExpansion & set /a scopeDepth+=1
set "p=%% "
set "p=!p:~0,1!"
FOR %%p in (!p!) DO (

	set "rtn1=!%%~7!"
	if defined rtn1 (
		set "rtn=!rtn1:%%p=%%p3!"
		set "rtn=!rtn:""n=%%p~L!"
		set "rtn=!rtn:""r=%%p4!"
		set "rtn1=!rtn:""q=%%p~5!"
	)
	set rtn1

	set "rtn2=!%%~8!"
	if defined rtn2 (
		set "rtn=!rtn2:%%p=%%3!"
		set "rtn=!rtn:""n=%%p~L!"
		set "rtn=!rtn:""r=%%p4!"
		set "rtn2=!rtn:""q=%%p~5!"
	)

	set "rtn3=!%%~9!"
	if defined rtn3 (
		set "rtn=!rtn3:%%p=%%3!"
		set "rtn=!rtn:""n=%%p~L!"
		set "rtn=!rtn:""r=%%p4!"
		set "rtn3=!rtn:""q=%%p~5!"
	)
	echo rtn1 !rtn1:~0,20!
	echo rtn2 !rtn2:~0,20!
	echo rtn3 !rtn3:~0,20!
)
for /f "tokens=1-4" %%3 in (^"%% !$CR! """") do (
  endlocal
  set "%1=%rtn1%%rtn2%%rtn3%"
  exit /b
)

:define_$endlocal
::: Leaves one or more setlocal-scopes, preserves one variable
::: %$endlocal% <variable>
::: %$endlocal% <destVariable>[=]<srcVariable> [endlocalCount]
::: Limits: The maximum length is 8179 characters

%$lib.macrodefine.disabled%

@set ^"%MACRO_NAME%=for %%$ in (1 2) do @if %%$==2 (%\n%
	for /f "tokens=1,2,6 delims== " %%1 in ("!returnVar.args! !returnVar.args!") do @(%\n%
		(set^^^ rtn=!%%2!)%\n%
		if "%%~3" == "" ( set /a endlocalCnt=2 ) ELSE set /a endlocalCnt=%%~3+1%\n%
		if not defined rtn ( %\n%
			for /L %%n in (1 1 !endlocalCnt!) do endlocal%\n%
			set "%%1="%\n%
		) ELSE ( %\n%
			for %%R in ("!$CR!") do @for %%L in ("!$LF!") do @(%\n%
			%= *** Test if LF is present in the string =% %\n%
				if "!rtn:%%~L=!" == "!rtn!" ( %\n%
					%= *** Without LF it's much simpler =% %\n%
					set "foundExclam=0"%\n%
					for /F "tokens=1 delims=!" %%E in (""!rtn!"") DO @if "%%~E" NEQ "" set foundExclam=1 %\n%
					for /f "tokens=1,*" %%D in ("!foundExclam! "!rtn!"") do @( %\n%
						for /L %%n in (1 1 !endlocalCnt!) do @endlocal%\n%
						if "!%%D"=="1" (%\n%
							setlocal DisableDelayedExpansion %\n%
							%= *** NO LF, but found exclam, use EDE, now it's TRICKY escape ! and ^ *=% %\n%
							(set^ rtn=%%~E)%\n%
							setlocal EnableDelayedExpansion %\n%
							set ^"rtn=!rtn:"=""q!"%\n%
							set "rtn=!rtn:%%~R=""r!"%\n%
							set "rtnDis=!rtn!"%\n%
							set "rtn=!rtn:^=^^!"%\n%
							%= *** Disable path search for the SET command *=% %\n%
							set "path="%\n%
							set "pathExt=;"%\n%
							call set "rtn=%$PERCENT%rtn:^!=""c^!%$PERCENT%"%\n%
							set "rtn=!rtn:""c=^!"%\n%
		%= *** Limit of 8179 characters in the FOR /F ***** =% %\n%
		%= *** The limit is an effect of set "<percent><percent>1=<p><p>~F" expansion ***** =% %\n%
							for /f "delims=" %%9 in (""!rtn!"") do @(%\n%
								endlocal%\n%
								endlocal%\n%
								(set^^^ %%1=!=!%%~9)%\n%
								set "%%1=!%%1:""r=%%~R!"%\n%
								set ^"%%1=!%%1:""q="!"%\n%
							) %\n%
						) else (%\n%
							%= *** NO LF, use DDE * =% %\n%
							set "%%1=%%~E"%\n%
						)%\n%
					)%\n%
				) ELSE ( %\n%
					set ^"rtn=!rtn:"=""q!"%\n%
					set "rtn=!rtn:%%~R=""r!"%\n%
					set "rtn=!rtn:%%~L=""n!"%\n%
					set "rtnDis=!rtn!"%\n%
					set "rtn=!rtn:^=^^!"%\n%
					set "path="%\n%
					set "pathExt=;"%\n%
					call set "rtn=%$PERCENT%rtn:^!=""c^!%$PERCENT%"%\n%
					set "rtn=!rtn:""c=^!"%\n%
					for /f "delims=" %%9 in (""!rtnDis!"") do @for /f "delims=" %%E in (""!rtn!"") do @(%\n%
					  for /L %%n in (1 1 !endlocalCnt!) do @endlocal%\n%
 				      if "!!" == "" (%\n%
						set "%%1=%%~E" !!%\n%
						set "%%1=!%%1:""n=%%~L!"%\n%
						set "%%1=!%%1:""r=%%~R!"%\n%
						set ^"%%1=!%%1:""q="!"%\n%
					  ) else (%\n%
						set "%%1=%%~9"%\n%
						call "%~d0\:fn_$endlocalDisabled:\..\%~pn0" %%1%\n%
					  )%\n%
					)%\n%
				)%\n%
			)%\n%
		)%\n%
	)%\n%
) else setlocal EnableDelayedExpansion ^& set returnVar.args="

@%$endlocal% %MACRO_NAME%
@exit /b

:define_$endlocalLong
::: Leaves one or more setlocal-scopes, preserves one variable
::: %$endlocal% <variable>
::: %$endlocal% <destVariable>[=]<srcVariable> [endlocalCount]
::: Limits: The maximum length is 8179 characters
%$lib.macrodefine.disabled%

for /F "usebackq delims= " %%C in (`copy /z "%~f0" nul`) do set "CR=%%C"

set ^"%MACRO_NAME%=for %%# in (1 2) do if %%#==2 (%\n%
	for /f "tokens=1,2,6 delims== " %%1 in ("!returnVar.args! !returnVar.args!") do (%\n%
		(set^ rtn=!%%2!)%\n%
		set "rtn1=!rtn:~0,3000!" %\n%
		set "rtn2=!rtn:~3000,3000!" %\n%
		set "rtn3=!rtn:~6000!" %\n%
		if "%%~3" == "" ( set /a endlocalCnt=2 ) ELSE set /a endlocalCnt=%%~3+1%\n%
		set "path="%\n%
		set "pathExt=;"%\n%
		for %%R in ("!$CR!") do for %%L in ("!$LF!") do (%\n%
			for /L %%n in (1 1 3) DO ( %\n%
				if not defined rtn%%n ( %\n%
					set "LF%%n=0" %\n%
					set "Bang%%n=0" %\n%
					set "rtn%%n=" %\n%
				) ELSE ( %\n%
					set "rtn=!rtn%%n!" %\n%
					%= *** Test if LF is present in the string =% %\n%
					if "!rtn:%%~L=!" == "###!rtn!" ( %\n%
						%= *** Without LF it's much simpler =% %\n%
						set "LF%%n=0"%\n%
						set "Bang%%n=0"%\n%
						for /F "tokens=1 delims=!" %%E in (""!rtn1!"") DO if "%%~E" NEQ "" set "Bang%%n=1" %\n%
					) ELSE ( %\n%
						set "LF%%n=1"%\n%
						set ^"rtn=!rtn:"=""q!"%\n%
						set "rtn=!rtn:%%~R=""r!"%\n%
						set "rtn=!rtn:%%~L=""n!"%\n%
						set "rtnDis%%n=!rtn!"%\n%
						set "rtn=!rtn:^=^^!"%\n%
						%= *** CRITICAL If "<percent><percent>r" exists, the CALL fails *** =% %\n%
						call set "rtn=%%rtn:^!=""c^!%%"%\n%
						set "rtn%%n=!rtn:""c=^!"%\n%
					)%\n%
				)%\n%
			)%\n%
			%= *** Now the transfer out of scope starts *** =% %\n%
			for /F "delims=" %%4 in (""!rtn1!"") DO for /F "delims=" %%5 in (""!rtn2!"") DO for /F "delims=" %%6 in (""!rtn3!"") DO ( %\n%
				for /F "delims=" %%7 in (""!rtnDis1!"") DO for /F "delims=" %%8 in (""!rtnDis2!"") DO for /F "delims=" %%9 in (""!rtnDis3!"") DO ( %\n%
				  for /L %%n in (1 1 !endlocalCnt!) do endlocal%\n%
				  if "!"=="" (%\n%
					%= *** rtn1 ***= % %\n%
					set "%%1.1=%%~4" !%\n%
					if defined %%1.1 ( %\n%
						set "%%1.1=!%%1.1:""n=%%~L!"%\n%
						set "%%1.1=!%%1.1:""r=%%~R!"%\n%
						set ^"%%1.1=!%%1.1:""q="!"%\n%
					) %\n%
					%= *** rtn2 ***= % %\n%
					set "%%1.2=%%~5" !%\n%
					if defined %%1.2 ( %\n%
						set "%%1.2=!%%1.2:""n=%%~L!"%\n%
						set "%%1.2=!%%1.2:""r=%%~R!"%\n%
						set ^"%%1.2=!%%1.2:""q="!"%\n%
					) %\n%
					%= *** rtn3 ***= % %\n%
					set "%%1.3=%%~5" !%\n%
					if defined %%1.3 ( %\n%
						set "%%1.3=!%%1.3:""n=%%~L!"%\n%
						set "%%1.3=!%%1.3:""r=%%~R!"%\n%
						set ^"%%1.3=!%%1.3:""q="!"%\n%
					) %\n%
					%= *** Combine rtn1+rtn2+rtn3 ***= % %\n%
					set "%%1=!%%1.1!!%%1.2!!%%1.3!"%\n%
				  ) else (%\n%
					if "%%F" == "000" ( %\n%
						set "%%1=%%X%%Y%%Z" %\n%
					) ELSE ( %\n%
						set "%%1=%%~D"%\n%
						call "%~d0\:_$endlocalLongDisabled:\..\%~pn0" %%1%\n%
					)%\n%
				  )%\n%
				)%\n%
			)%\n%
		)%\n%
	)%\n%
) else setlocal EnableDelayedExpansion ^& set returnVar.args="

%$endlocal% %MACRO_NAME%

exit /b
