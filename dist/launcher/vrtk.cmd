@echo off

set OLD_PATH=%PATH%
set PATH="%~dp0\bin";%PATH%
set VRTK_DATA_DIR="%~dp0\data"

ruby "%~dp0\src\bin\vrtk" %*

set PATH=%OLD_PATH%