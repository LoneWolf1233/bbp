@echo off
title ToolBox by SenseiWhou
color 0a
echo Creating Directories
md C:\Users\%username%\Bug-Bounty
echo Done
echo Installing prerequisites...

REM Golang 
if exist "C:\Users\%username%\Bug-Bounty\go1.25.0.windows-amd64.msi" (
    echo Setup file already exists... Skipping...
) else (
    echo Downloading Go Language...
    powershell -c "Invoke-WebRequest -Uri 'https://go.dev/dl/go1.25.0.windows-amd64.msi' -OutFile 'C:\Users\%username%\Bug-Bounty\go1.25.0.windows-amd64.msi'"
    echo Done
)
REM === Check if Go is already installed ===
where go >nul 2>nul
if %errorlevel%==0 (
    echo Go is already installed. Skipping...
) else (
    echo Installing Go...
    start /wait "" "C:\Users\%username%\Bug-Bounty\go1.25.0.windows-amd64.msi" /passive
    echo Done
)

REM Python
echo Checking if Python is installed...
where python >nul 2>nul
if %errorlevel%==0 (
    echo Python is already installed
) else (
    echo Downloading and installing Python...
    powershell -c "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe' -OutFile '%USERPROFILE%\Bug-Bounty\python-installer.exe'"
    start /wait "" "%USERPROFILE%\Bug-Bounty\python-installer.exe" /quiet InstallAllUsers=1 PrependPath=1
)

:menu
cls
echo ===========================================
echo                ToolBox
echo             by SenseiWhou
echo ===========================================
echo 1. Install
echo 2. Install
echo 3. Install
echo 4. Install
echo 5. Install
echo 6. Install
echo 7. Install
echo 8. Install
echo 9. Install
echo 10. Install
echo 11. Install
echo 12. Install
echo 13. Install
echo 14. Install
echo 15. Install
echo 16. Install
echo 17. Install
echo 18. Install
echo 19. Install
echo 20. Install
echo 21. Install
echo 22. Install
echo 23. Install
echo 24. Install
echo 25. Install
echo 26. Install
echo 27. Install
echo 28. Install
echo 29. Install
echo 30. Install
echo 31. Install
echo 32. Install
echo 33. Install
echo 34. Install
echo 35. Install
echo 36. Install
echo 37. Install
echo 38. Install
echo 39. Install
echo 40. Install
echo 41. Install
echo 42. Install
echo 43. Install
echo 44. Install
echo 45. Install
echo 46. Install
echo 47. Install
echo 48. Install
echo 49. Install
echo 50. Install
echo ===========================================
set /p choices="Select tools (e.g. 1 2 3): "

REM Handle multiple choices
for %%i in (%choices%) do (
    if %%i ==1 goto
    if %%i ==2 goto
    if %%i ==3 goto
    if %%i ==4 goto
    if %%i ==5 goto
    if %%i ==6 goto
    if %%i ==7 goto
    if %%i ==8 goto
    if %%i ==9 goto
    if %%i ==10 goto
    if %%i ==11 goto
    if %%i ==12 goto
    if %%i ==13 goto
    if %%i ==14 goto
    if %%i ==15 goto
    if %%i ==16 goto
    if %%i ==17 goto
    if %%i ==18 goto
    if %%i ==19 goto
    if %%i ==20 goto
    if %%i ==21 goto
    if %%i ==22 goto
    if %%i ==23 goto
    if %%i ==24 goto
    if %%i ==25 goto
    if %%i ==26 goto
    if %%i ==27 goto
    if %%i ==28 goto
    if %%i ==29 goto
    if %%i ==30 goto
    if %%i ==31 goto
    if %%i ==32 goto
    if %%i ==33 goto
    if %%i ==34 goto
    if %%i ==35 goto
    if %%i ==36 goto
    if %%i ==37 goto
    if %%i ==38 goto
    if %%i ==39 goto
    if %%i ==40 goto
    if %%i ==41 goto
    if %%i ==42 goto
    if %%i ==43 goto
    if %%i ==44 goto
    if %%i ==45 goto
    if %%i ==46 goto
    if %%i ==47 goto
    if %%i ==48 goto
    if %%i ==49 goto
    if %%i ==50 goto
)
pause
goto menu
