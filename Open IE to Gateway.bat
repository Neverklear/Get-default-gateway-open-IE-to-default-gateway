@echo off
setlocal

REM Read the username and password from files
set /p username=<username.txt
set /p password=<password.txt

REM Get the default gateway IP address
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "Default Gateway"') do set gateway=%%a
set gateway=%gateway:~1%

REM Open Internet Explorer to the default gateway, with the username and password fields pre-filled
start iexplore.exe http://%gateway% -k -nomerge -noframemerging -nohome "javascript:void(document.getElementById('username').value='%username%');void(document.getElementById('password').value='%password%');document.forms[0].submit();"

REM Wait for the login page to load
ping 127.0.0.1 -n 5 > nul

REM Check if the "Submit" button is available and click it
echo Checking for Submit button...
IECapt --url=http://%gateway% --out=output.png
find "Submit" output.png > nul
if %errorlevel%==0 (
  echo Submit button found. Clicking...
  start iexplore.exe http://%gateway% -k -nomerge -noframemerging -nohome "javascript:void(document.getElementsByTagName('input')[0].click());"
) else (
  echo Submit button not found. Checking for Login button...
  find "Login" output.png > nul
  if %errorlevel%==0 (
    echo Login button found. Clicking...
    start iexplore.exe http://%gateway% -k -nomerge -noframemerging -nohome "javascript:void(document.getElementsByTagName('input')[0].click());"
  ) else (
    echo Login button not found. Login failed.
  )
)

REM Cleanup
del output.png

endlocal
