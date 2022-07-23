@echo off
set v_params=%*
if exist "%v_params%" (
    @bash -c "yarn $(wslpath '%v_params%')"
) else (
    @bash -c "yarn %v_params%"
)
