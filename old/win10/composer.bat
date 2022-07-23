@echo off
set v_params=%*
if exist "%v_params%" (
    @bash -c "composer $(wslpath '%v_params%')"
) else (
    @bash -c "composer %v_params%"
)
