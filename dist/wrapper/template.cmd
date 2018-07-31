@echo off

set OLD_PATH=%%PATH%%
set PATH="%%~dp0\bin";%%PATH%%
set VRTK_DATA_DIR="%%~dp0\%{res_dir}\data"
set VRTK_DIR="%%~dp0"

ruby "%%~dp0\%{src_dir}\bin\vrtk" %%*

set PATH=%%OLD_PATH%%