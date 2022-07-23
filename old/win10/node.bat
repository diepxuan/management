@echo off
set v_params=%*
if exist "%v_params%" (
    @bash -c "node $(wslpath '%v_params%')"
) else (
    @bash -c "node %v_params%"
)
