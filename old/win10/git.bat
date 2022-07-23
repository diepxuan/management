@echo off
set v_params=%*
if exist "%v_params%" (
    @bash -c "git $(wslpath '%v_params%')"
) else (
    @bash -c "git %v_params%"
)
