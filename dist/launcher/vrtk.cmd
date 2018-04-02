@echo off

set OLD_PATH=%PATH%
set PATH=%~dp0\bin

ruby "%~dp0\src\bin\vrtk" %*

set PATH=%OLD_PATH%