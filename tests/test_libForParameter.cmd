@echo off
REM *** Trampoline jump for function calls of the form ex. "C:\:libraryFunction:\..\temp\libThisLibraryName.cmd"
FOR /F "tokens=3 delims=:" %%L in ("%~0") DO goto :%%L

setlocal DisableDelayedExpansion
if "%~1" NEQ "" set /a libUnittest.verbose=%1+0
set UT_VERBOSE=1


call libUnittest
call libForParameter
call :test_setup
%$UT_testSuite:(#)ERROR:^ MACRO^ IS^ EMPTY^ IN^ %~0 :=%

exit /b

:testCase_NoFORLoop
%$UT_StartTestCase% %0 "One line commands"

setlocal EnableDelayedExpansion

set "var=Hello world"
set "expect="
%$UT_TEST_PRE% "$parameter.activeList without outer FOR-Loop" 
%$parameter.activeList% result
%$UT_TEST_POST_ASSERT% result expect

%$UT_exitTestCase% %= EXIT =%
::: detector line %~* *** FATAL ERROR: missing parenthesis or exit /b


:testCase_insideFORLoop
%$UT_StartTestCase% %0 "$parameter.activeList inside a FOR-Loops"

set "expect="
%$UT_TEST_PRE% "Inside loop, but no parameters are set"
For /F "tokens=1" %%%esc% in ("!tableESC!") DO (
	%$parameter.activeList% result
)
%$UT_TEST_POST_ASSERT% result expect

%$UT_TEST_PRE% "Inside loop, parameters '@ABCD..XYZ' are set"
For /F "tokens=1-31" %%%esc% in ("%tableESC%") DO ^
For /F "tokens=1-31" %%: in ("%tableColon%") DO ^
For /F "tokens=1-31" %%@ in ("%table@%") DO ^
For /F "tokens=1-31" %%` in ("%tableLower_a%") DO ^
For /F "tokens=1-31" %%@ in ("%table@%") DO ^
For /F "tokens=1-31" %%` in ("%tableLower_a%") DO ^
For /F "tokens=1" %%%esc% in ("!tableESC!") DO (
	%$parameter.activeList% result
)
set "expect=BANG,QUOTE,#,$,Percent,&,',(,),*,+,,,-,.,/,0,1,2,3,4,5,6,7,8,9,:,;,<,=,>,?,@,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,[,\,],CARET,`,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,{,|,},~"
%$UT_TEST_POST_ASSERT% result expect

%$UT_exitTestCase% %= *** EXIT *** =%

:test_setup
setlocal DisableDelayedExpansion
set ^"ascii_chars= !"#$%%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~#"
%$endlocal% ascii_chars

:::: Create variables with content like "[ERR64-@] [ERR65-A] [ERR66-B] ... "
call :createParameterTable tableESC 	 27		%= 27-58 =%
call :createParameterTable tableColon 	 58		%= 58-89 =%
call :createParameterTable table@ 	     64  	%= 64-95 =%
call :createParameterTable tableLower_a 96		%= 97-128 =%

::: We need the ESC char to use it as harmles for-parameter name
for /F "delims=#" %%a in ('prompt #$E# ^& for %%a in ^(1^) do rem') do set "esc=%%a"
for /F "delims=# " %%a in ('prompt #$H# ^& for %%a in ^(1^) do rem') do set "BS=%%a"

exit /b

REM setlocal DisableDelayedExpansion

REM call :parameter.activeList "outside loops"

REM For /F "tokens=1-31" %%%BS% in ("%tableBS%") DO ^
REM For /F "tokens=1-31" %%%esc% in ("%tableESC%") DO ^
REM For /F "tokens=1-31" %%: in ("%tableColon%") DO ^
REM For /F "tokens=1-31" %%@ in ("%table@%") DO ^
REM For /F "tokens=1-31" %%` in ("%tableLower_a%") DO ^
REM For /F "tokens=1" %%1 in ("%table@%") DO ^
REM For /F "tokens=1,2" %%5 in ("%table@%") DO ^
REM For /F "tokens=1" %%%esc% in ("!tableESC!") DO (
	REM call :parameter.activeList "inside loop"
REM )
REM exit /b

:createParameterTable
setlocal EnableDelayedExpansion
set "__tmp="
for /L %%# in (0 1 31) DO (
	set /a asciiCode=%2 + %%#, maxIdx=asciiCode-32
	if !maxIdx! LSS 0 (
		set "char=?"
	) ELSE (
		for %%n in (!maxIdx!) DO set "char=!ascii_chars:~%%n,1!"
	)
	if !asciiCode! == 32 set "char=SPACE"
	if !asciiCode! == 34 set "char=QUOTE"
	REM if !asciiCode! == 94 set "char=CARET"
	set "__tmp=!__tmp! [ERR!asciiCode!-!char!]"
)
set %1=!__tmp!
%$endlocal% %1
exit /b

REM call :test

REM For /F "tokens=1-31" %%%BS% in ("%tableBS%") DO ^
REM For /F "tokens=1-31" %%%esc% in ("%tableESC%") DO ^
REM For /F "tokens=1-31" %%: in ("%tableColon%") DO ^
REM For /F "tokens=1-31" %%@ in ("%table@%") DO ^
REM For /F "tokens=1-31" %%` in ("%tableLower_a%") DO ^
REM For /F "tokens=1" %%%esc% in ("!tableESC!") DO (
	REM call :test
REM )
REM echo END
REM exit /b

REM :test

REM setlocal DisableDelayedExpansion
REM FOR %%a in (1) DO (
REM set "EMPTY="
REM for %%i in (cmd.exe) DO echo ... "%%~$=UNDEF=:$" --------------------------
	REM set "asciiNorm_0x20to_1x3F=%asciiNorm_0x20to_0x3F%"
	REM set "asciiNorm_0x40to_1x5F=%asciiNorm_0x40to_0x5F%"
	REM set "asciiTilde_0x20to_1x3F=%asciiTilde_0x20to_0x3F%"
	REM set "asciiTilde_0x40to_1x5F=%asciiTilde_0x40to_0x5F%"
REM )
REM FOR %%A in (1) DO (
	REM set "asciiNorm_0x60to_1x7F=%asciiNorm_0x60to_0x7F%"
	REM set "asciiTilde_0x60to_1x7F=%asciiTilde_0x60to_0x7F%"
REM )

REM set asciiNorm
REM echo(
REM set asciiTilde
REM echo(
REM echo( ---------------------------
REM exit /b

REM :buildTokens
REM set ^"map=#!"#$%%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~#"
REM setlocal EnableDelayedExpansion

REM set "tmp="
REM REM set ^"percent=%%<nul"
REM set "percent=%%"
REM for /L %%# in (0 1 31) DO (
	REM set /a asciiCode=%2 + %%#, mapIdx=asciiCode-32
	REM for %%A in (!mapIdx!) DO	set "asciiChar=!map:~%%A,1!"
	REM if !asciiCode!==32 set "asciiChar=^^ "
	REM set "tmp=!tmp! %%!asciiChar!"
REM )

REM set "tmp=!tmp:"=""!"
REM (
REM endlocal
REM set "%1=%tmp%"

REM )
REM exit /b

