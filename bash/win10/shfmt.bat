@echo off
set v_params=%*
if exist "%v_params%" (
    @bash -c "shfmt $(wslpath '%v_params%')"
) else (
    @bash -c "shfmt %v_params%"
)
