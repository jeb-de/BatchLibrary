@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

%$LIB_LOAD_ONCE:call "%~dp0\libBase.cmd" :=%
%$LIB_INCLUDE% libEndlocal

REM *** @TODO:  Currently only a play field

setlocal
(set LF=^
%=empty=%
)

%$LIB_LOAD_MACRO% $returnVar

set var=orig
setlocal
set var=changed
set ReturnVar
%ReturnVar% var dest
endlocal
set dest
set var
exit /b

:define_$returnVar
setlocal DisableDelayedExpansion
(set LF=^
%=empty=%
)

:endlocal [<level> default=1] [<newName>=]<returnVar> [ [<newName2>=]<returnVar2> ... ]
%$lib.macrodefine.disabled%

%$endlocal% $endlocal
exit /b

REM setlocal DisableDelayedExpansion
call :macroLF


set ^"\n=^^^%LF%%LF%^%LF%%LF%^^"
@for /f "usebackq delims= " %%C in (`copy /z "%~f0" nul`) do @set "CR=%%C"

set ^"ReturnVar=@for %%# in (1 2) do @if %%#==2 @(%\n%
  setlocal EnableDelayedExpansion%\n%
  set/a safeReturn_count=0%\n%
  for %%C in (!args!) do @(%\n%
    set "safeReturn[!safeReturn_count!]=%%~C" ^& set /a safeReturn_count+=1%\n%
  )%\n%
  if not defined safeReturn[2] set "safeReturn[2]=1"%\n%
  set /a safeReturn[2]+=2%\n%
  for /f "delims=" %%V in ("!safeReturn[1]!") do @set "_srTmp=a!%%V!"%\n%
  set ^"_srTmp=!_srTmp:"=""q!"%\n%
  FOR /F %%R in ("!CR! #") DO @set "_srTmp=!_srTmp:%%~R=""r!"%\n%
  FOR %%L in ("!LF!") DO @set "_srTmp=!_srTmp:%%~L=""n!"%\n%
  set "_srTmp=!_srTmp:^=^^!"%\n%
  call set "_srTmp=%%_srTmp:^!=""c^!%%"%\n%
  set "_srTmp=!_srTmp:""c=^!"%\n%
  set ^"_srTmp=!_srTmp:""q="!"%\n%
  for %%L in ("!LF!") do @(%\n%
    for /f "delims=" %%N in (""!safeReturn[0]!"") do @(%\n%
      for /f "delims=" %%E in (""!_srTmp!"") do @(%\n%
        for /l %%n in (1 1 !safeReturn[2]!) do @endlocal%\n%
        if "!" neq "" setlocal enabledelayedexpansion ^& set "_#_$_dis=1"%\n%
        set "%%~N=%%~E" !%\n%
        set "%%~N=!%%~N:""n=%%~L!"%\n%
        FOR /F %%R in ("!CR! #") DO @set "%%~N=!%%~N:""r=%%R!"%\n%
        set "%%~N=!%%~N:~1!"%\n%
        if defined _#_$_dis (%\n%
          for /f delims^^=^^ eol^^=  %%A in (""!%%~N!"") do @(%\n%
            endlocal ^& @set "%%~N=%%~A"%\n%
          )%\n%
        )%\n%
      )%\n%
    )%\n%
  )%\n%
) else @setlocal ^& @set args="

%ReturnVar% ReturnVar ReturnVar
exit /b 0

:xxx
setlocal DisableDelayedExpansion
set LF=^


set ^"\n=^^^%LF%%LF%^%LF%%LF%^^"
%=   I use EDE for EnableDelayeExpansion and DDE for DisableDelayedExpansion =%
set ^"endlocal=for %%# in (1 2) do if %%#==2 (%\n%
   setlocal EnableDelayedExpansion%\n%
 %=       Take all variable names into the varName array       =%%\n%
   set varName_count=0%\n%
   for %%C in (!args!) do set "varName[!varName_count!]=%%~C" ^& set /a varName_count+=1%\n%
 %= Build one variable with a list of set statements for each variable delimited by newlines =%%\n%
 %= The lists looks like --> set result1=myContent\n"set result1=myContent1"\nset result2=content2\nset result2=content2\n     =%%\n%
 %= Each result exists two times, the first for the case returning to DDE, the second for EDE =%%\n%
 %= The correct line will be detected by the (missing) enclosing quotes  =%%\n%
   set "retContent=1!LF!"%\n%
   for /L %%n in (0 1 !varName_count!) do (%\n%
      for /F "delims=" %%C in ("!varName[%%n]!") DO (%\n%
         set "content=!%%C!"%\n%
         set "retContent=!retContent!"set !varName[%%n]!=!content!"!LF!"%\n%
         if defined content (%\n%
 %=      This complex block is only for replacing '!' with '^!'      =%%\n%
 %=    First replacing   '"'->'""q'   '^'->'^^' =%%\n%
         set ^"content_EDE=!content:"=""q!"%\n%
         set "content_EDE=!content_EDE:^=^^!"%\n%
 %= Now it's poosible to use CALL SET and replace '!'->'""e!' =%%\n%
         call set "content_EDE=%%content_EDE:^!=""e^!%%"%\n%
         %= Now it's possible to replace '""e' to '^', this is effectivly '!' -> '^!'  =%%\n%
         set "content_EDE=!content_EDE:""e=^!"%\n%
         %= Now restore the quotes  =%%\n%
         set ^"content_EDE=!content_EDE:""q="!"%\n%
         ) ELSE set "content_EDE="%\n%
         set "retContent=!retContent!set "!varName[%%n]!=!content_EDE!"!LF!"%\n%
      )%\n%
   )%\n%
 %= Now return all variables from retContent over the barrier =%%\n%
   for /F "delims=" %%V in ("!retContent!") DO (%\n%
 %= Only the first line can contain a single 1 =%%\n%
      if "%%V"=="1" (%\n%
 %= We need to call endlocal twice, as there is one more setlocal in the macro itself =%%\n%
         endlocal%\n%
         endlocal%\n%
      ) ELSE (%\n%
 %= This is true in EDE             =%%\n%
         if "!"=="" (%\n%
            if %%V==%%~V (%\n%
               %%V !%\n%
            )%\n%
         ) ELSE IF not %%V==%%~V (%\n%
            %%~V%\n%
         )%\n%
      )%\n%
   )%\n%
 ) else set args="