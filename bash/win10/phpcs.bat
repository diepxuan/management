@echo off
set v_params=%*
if exist "%v_params%" (
    @bash -c "phpcs $(wslpath '%v_params%')"
) else (
    @bash -c "phpcs %v_params%"
)
