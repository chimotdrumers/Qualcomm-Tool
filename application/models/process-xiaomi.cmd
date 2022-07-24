@echo off

:: {###################################################################### ::
:: ########################### XIAOMI PROCESS ############################ ::
:: ####################################################################### ::


:: Get Partition Map
%emmcdl% -p %USBComPort% -f %Loader% -gpt -memoryname %MemoryName% >%cache%\partition
%sleep% 1
echo.
%cecho% {0a}Configuring Device...{0f}   [OK]
echo.


::: Partition Config -> FRP
for /f "delims= " %%a in ('type %cache%\partition^|find "config"') do (
  set "line=%%a"
  set "line=!line:*config =!
  set /a "result_config=!line:~1!" 2>nul
)
IF "%result_config%" == "1" (for /F "Tokens=7 skip=1 " %%b in ('findstr /I "config" %cache%\partition') do (echo.Partition Config Sector    : %%b)
	%sleep% 1
	%emmcdl% -p %USBComPort% -f %Loader% -d config %backup_config% -memoryname %MemoryName% >nul
	%cecho% {0a}Backing-up config...{0f}    [OK]
	echo.
	%emmcdl% -p %USBComPort% -f %Loader% -e config -memoryname %MemoryName% >nul
	%cecho% {0a}Erasing FRP...{0f}          [OK]
	echo.
)


::: Partition Persist -> MiCloud
for /f "delims= " %%c in ('type %cache%\partition^|find "persist"') do (
  set "line=%%c"
  set "line=!line:*persist =!
  set /a "result_persist=!line:~1!" 2>nul
)

IF "%result_persist%" == "1" (for /F "Tokens=7 " %%d in ('findstr /I "persist" %cache%\partition') do (echo.Partition Persist Sector   : %%d)
	%sleep% 1
	%emmcdl% -p %USBComPort% -f %Loader% -d persist %backup_persist%-persist.img -memoryname %MemoryName% >nul
	%cecho% {0a}Backing-up persist...{0f}   [OK]
	echo.
	%emmcdl% -p %USBComPort% -f %Loader% -d persistbak %backup_persistbak%-persistbak.img -memoryname %MemoryName% >nul
	%cecho% {0a}Backing-up persistbak...{0f}[OK]
	echo.
	%emmcdl% -p %USBComPort% -f %Loader% -e persist -memoryname %MemoryName% >nul
	%emmcdl% -p %USBComPort% -f %Loader% -e persistbak -memoryname %MemoryName% >nul
	%cecho% {0a}Erasing MiCloud...{0f}      [OK]
	echo.
)


::: Partition Userdata
for /f "delims= " %%e in ('type %cache%\partition^|find "userdata"') do (
  set "line=%%e"
  set "line=!line:*userdata =!
  set /a "result_userdata=!line:~1!" 2>nul
)
IF "%result_misc%" == "1" (for /F "Tokens=7 " %%f in ('findstr /I "userdata" %cache%\partition') do (echo.Partition Userdata Sector  : %%f
	 %sleep% 1
	 %emmcdl% -p %USBComPort% -f %Loader% -e userdata -memoryname %MemoryName% >nul
	 %cecho% {0a}Erasing Userdata...{0f}     [OK]
	echo.
) ELSE (
	%cecho% {04}Error %MemoryName% damaged! {0f}
	echo.
)


:: Cleanup
call %cleanup%


::: Done
%cecho% {0b}Rebooting Device... {0f}
echo.
%emmcdl% -p %USBComPort% -f %Loader% -x %reboot% -memoryname %MemoryName% >nul
echo.
echo.
pause