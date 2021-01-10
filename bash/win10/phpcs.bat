@echo off
set v_params=%*
set v_params=%v_params:\=/%
set v_params=%v_params:c:=/mnt/c%
set v_params=%v_params:C:=/mnt/c%
set v_params=%v_params:/mnt/c/Users/ductn/OneDrive/SourceCode/=/var/www/html/%
set v_params=%v_params:"=\"%
@REM echo "phpcs %v_params%"
@bash -c "phpcs %v_params%"
