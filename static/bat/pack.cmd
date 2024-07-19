@echo off 

set target= %~dp0packs\
echo target folder: %target%
set gversion=0000000
set gname=0000000
set coiDir=H:\Work\Projects\html\py
goto :end


:packE
cd pack
cmd /c npm pack 
goto end


:getVersion arg1
set sourceCodeDir=%1
::setlocal enabledelayedexpansion
for /f "usebackq tokens=*" %%i in (`python %coiDir%\app\cl\readPackJson.py -f "%sourceCodeDir%\package.json" -a version`) do (
    set gversion=%%i
)
for /f "usebackq tokens=*" %%i in (`python %coiDir%\app\cl\readPackJson.py -f "%sourceCodeDir%\package.json" -a name`) do (
    set gname=%%i
)
::endlocal 
echo %gname%-%gversion% 
goto :eof


:package arg1
echo PATH:%1 
cd /d %1
call :getVersion %1
cmd /c npm pack
move /Y %gname%-%gversion%.tgz %target%
goto end

:pack6 
call :package %coiDir%\app\co6co-ui\

:pack_right
call :package %coiDir%\app\co6co-ui-right\

:pack_wx
call :package %coiDir%\app\co6co-ui-mp 


:end 
set /p c=e:element-plus:6:co6co	r:co6co-right	wx:co6co-wx: 
if /i "%c%" == "e" goto :packE
if /i "%c%" == "6" goto :pack6
if /i "%c%" == "r" goto :pack_right
if /i "%c%" == "wx" goto :pack_wx
goto end
 