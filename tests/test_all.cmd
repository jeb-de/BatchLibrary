@echo off
setlocal EnableDelayedExpansion
REM set ^"$$LIBRARY_NEW_MACRO_HOOK=call "%~d0\:_NEW_MACRO_HOOK:\..\%~pn0""
set LIBRARY_DEBUG=1

set /a libUnittest.verbose=%1+0


set fileCnt=0
for %%F in (test_lib*.cmd  ) DO (
	set "filelist[!fileCnt!]=%%~fF"
	set /a fileCnt+=1
)

set fileIdx=0
setlocal DisableDelayedExpansion

:loop
setlocal EnableDelayedExpansion
if !fileIdx! GEQ !fileCnt! goto :break

echo ------------- Unittest !filelist[%fileIdx%]! -------------
endlocal

setlocal DisableDelayedExpansion
call "%%filelist[%fileIdx%]%%"
endlocal
echo(
set /a fileIdx+=1

goto :loop

:break
echo ... Finished
exit /b

:_NEW_MACRO_DEBUG
FOR %%1 in ("1") DO (
	echo NEWMACRO: %%Z
	if "!!" == "" (
		set "filename=debug_%%Z.EDE"
	) ELSE (
		set "filename=debug_%%Z.DDE"
	)
	setlocal EnableDelayedExpansion
	set "filename=!filename:$=#!"
	set "filename=!filename:\=_!"
	(set %%Z) > "!filename!"
	endlocal
)
exit /b