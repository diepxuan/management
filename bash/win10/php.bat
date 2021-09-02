@echo off
set v_params=%*
if exist "%v_params%" (
    @bash -c "php $(wslpath '%v_params%')"
) else (
    @bash -c "php %v_params%"
)
