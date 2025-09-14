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
echo 1. Install All
echo 2. Install Broken-Link-Checker
echo 3. Install Assetfinder
echo 4. Install Gau
echo 5. Install Httpx
echo 6. Install Katana
echo 7. Install Nuclei
echo 8. Install Subfinder
echo 9. Install Waybackurls
echo 10. Install Dnsx
echo 11. Install Hakrawler
echo 12. Install Amass
echo 13. Install Ffuf
echo 14. Install Gobuster
echo 15. Install Dalfox
echo 16. Install KXSS
echo 17. Install Subzy
echo 18. Install S3Scanner
echo 19. Install SSTImap
echo 20. Install Shortscan
echo 21. Install GXSS
echo 22. Install CRLFuzz
echo 23. Install Trufflehog
echo 24. Install Gf-Patterns
echo 25. Install XSStrike
echo 26. Install Wafw00f
echo 27. Install CSRFscan
echo 28. Install SSRFmap
echo 29. Install Dirsearch
echo 30. Install Corsy
echo 31. Install Wapiti
echo 32. Install Paramspider
echo 33. Install SQLmap
echo 34. Install Arjun
echo 35. Install Uro
echo 36. Install Nikto
echo 37. Install Nmap
echo 38. Install Massdns
echo 39. Install QSreplace
echo 40. Install Chaos
echo 41. Install AlterX
echo 42. Install ASNmap
echo 43. Install SecretFinder
echo 44. Install masscan
echo 45. Install recx
echo 46. Install urlfinder
echo 47. Install linkfinder
echo 48. Install Only Wordlists
echo 49. Install Only Tools
echo ===========================================
set /p choices="Select tools (e.g. 1 2 3): "

REM Handle multiple choices
for %%i in (%choices%) do (
    if %%i ==1 goto install_all
    if %%i ==2 goto broken-link-checker
    if %%i ==3 goto assetfinder
    if %%i ==4 goto gau
    if %%i ==5 goto httpx
    if %%i ==6 goto katana
    if %%i ==7 goto nuclei
    if %%i ==8 goto subfinder
    if %%i ==9 goto waybackurls
    if %%i ==10 goto dnsx
    if %%i ==11 goto hakrawler
    if %%i ==12 goto amass
    if %%i ==13 goto ffuf
    if %%i ==14 goto gobuster
    if %%i ==15 goto dalfox
    if %%i ==16 goto kxss
    if %%i ==17 goto subzy
    if %%i ==18 goto s3scanner
    if %%i ==19 goto sstimap
    if %%i ==20 goto shortscan
    if %%i ==21 goto gxss
    if %%i ==22 goto crlfuzz
    if %%i ==23 goto trufflehog
    if %%i ==24 goto gf_patterns
    if %%i ==25 goto xsstrike
    if %%i ==26 goto wafw00f
    if %%i ==27 goto csrfscan
    if %%i ==28 goto ssrfmap
    if %%i ==29 goto dirsearch
    if %%i ==30 goto corsy
    if %%i ==31 goto wapiti
    if %%i ==32 goto paramspider
    if %%i ==33 goto sqlmap
    if %%i ==34 goto arjun
    if %%i ==35 goto uro
    if %%i ==36 goto nikto
    if %%i ==37 goto nmap
    if %%i ==38 goto massdns
    if %%i ==39 goto qsreplace
    if %%i ==40 goto chaos
    if %%i ==41 goto alterx
    if %%i ==42 goto secretfinder
    if %%i ==43 goto massscan
    if %%i ==44 goto recx 
    if %%i ==45 goto urlfinder
    if %%i ==46 goto linkfinder
    if %%i ==47 goto asnmap
    if %%i ==48 goto wordlists
    if %%i ==49 goto tools
)
pause
goto menu

REM broken-link-checker
REM NodeJS / NPM
:broken-link-checker
cls
if exist "C:\Users\%username%\Bug-Bounty\node-v24.6.0-x64.msi" (
    echo Setup file already exists... Skipping...
) else (
    echo Downloading NodeJs / npm...
    powershell -c "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v24.6.0/node-v24.6.0-x64.msi' -OutFile 'C:\Users\%username%\Bug-Bounty\node-v24.6.0-x64.msi'"
    echo Done
)

REM === Check if npm is already installed and installing if not. ===
where npm >nul 2>nul
if %errorlevel%==0 (
    echo npm is already installed. Skipping...
) else (
    echo Installing npm...
    start /wait "" "C:\Users\%username%\Bug-Bounty\node-v24.6.0-x64.msi" /passive
    echo Done
)

REM === Check if broken-link-checker is already installed and installing if not === 
where broken-link-checker >nul 2>nul
if %errorlevel%==0 (
    echo broken-link-checker is already installed. Skipping...
) else (
    echo Installing Broken-Link-Checker...
    npm install broken-link-checker 
)

:assetfinder
REM === Check if assetfinder is already installed and installing if not. ===
where assetfinder >nul 2>nul
if %errorlevel%==0 (
    echo assetfinder is already installed. Skipping...
) else (
    echo Installing assetfinder...
    go install -v github.com/tomnomnom/assetfinder@latest
)

:urlfinder
REM === Check if urlfinder is already installed and installing if not ===
where urlfinder >nul 2>nul
if %errorlevel%==0 (
    echo urlfinder is already installed. Skipping...
) else (
    echo Installing urlfinder...
    go install -v github.com/projectdiscovery/urlfinder/cmd/urlfinder@latest
)

:gau
REM === Check if gau is installed and install if not ===
cls
where gau >nul 2>nul
if %errorlevel%==0 (
    echo gau is already installed. Skipping...
) else (
    echo Installing Gau...
    go install -v github.com/lc/gau/v2/cmd/gau@latest
)

:httpx
REM === Check if httpx is installed and install if not ===
cls
where httpx >nul 2>nul
if %errorlevel%==0 (
    echo httpx is already installed. Skipping...
) else (
    echo Installing httpx...
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
)

:katana
REM === Check if katana is installed and install if not ===
cls
where katana >nul 2>nul
if %errorlevel%==0 (
    echo Katana is already installed. Skipping...
) else (
    echo Installing httpx...
    go install -v github.com/projectdiscovery/katana/cmd/katana@latest
)

:nuclei
REM === Check if nuclei is installed and install if not ===
cls
where nuclei >nul 2>nul
if %errorlevel%==0 (
    echo Nuclei is already installed. Skipping...
) else (
    echo Installing Nuclei...
    go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
)

:subfinder
REM === Check if subfinder is installed and install if not ===
cls
where subfinder >nul 2>nul
if %errorlevel%==0 (
    echo subfinder is already installed. Skipping...
) else (
    echo Installing Subfinder...
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
)

:waybackurls
REM === Check if waybackurls is installed and install if not ===
cls
where waybackurls >nul 2>nul
if %errorlevel%==0 (
    echo waybackurls is already installed. Skipping...
) else (
    echo Installing waybackurls...
    go install -v github.com/tomnomnom/waybackurls@latest
)

:dnsx
REM === Check if dnsx is installed and install if not ===
cls
where dnsx >nul 2>nul
if %errorlevel%==0 (
    echo Dnsx is already installed. Skipping...
) else (
    echo Installing Dnsx...
    go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
)

:hakrawler
REM === Check if hakrawler is installed and install if not ===
cls
where hakrawler >nul 2>nul
if %errorlevel%==0 (
    echo hakrawler is already installed. Skipping...
) else (
    echo Installing Hakrawler...
    go install -v github.com/hakluke/hakrawler@latest
)

:amass
REM === Check if amass is installed and install if not ===
cls
where amass >nul 2>nul
if %errorlevel%==0 (
    echo amass is already installed. Skipping...
) else (
    echo Installing Amass...
    go install -v github.com/owasp-amass/amass/v4/...@master
)

:ffuf
REM === Check if ffuf is installed and install if not ===
cls
where ffuf >nul 2>nul
if %errorlevel%==0 (
    echo ffuf is already installed. Skipping...
) else (
    echo Installing ffuf...
    go install -v github.com/OJ/gobuster/v3@latest   
)

:gobuster
REM === Check if gobuster is installed and install if not ===
cls
where gobuster >nul 2>nul
if %errorlevel%==0 (
    echo gobuster is already installed. Skipping...
) else (
    echo Installing Gobuster...
    go install -v github.com/OJ/gobuster/v3@latest
)

:dalfox
REM === Check if dalfox is installed and install if not ===
cls
where dalfox >nul 2>nul
if %errorlevel%==0 (
    echo dalfox is already installed. Skipping...
) else (
    echo Installing Dalfox...
    go install -v github.com/hahwul/dalfox/v2@latest
)

:asnmap
REM === Check if asnmap is installed and install if not ===
cls
where asnmap >nul 2>nul
if %errorlevel%==0 (
    echo asnmap is already installed. Skipping...
) else (
    echo Installing ASNmap...
    go install -v github.com/projectdiscovery/asnmap/cmd/asnmap@latest   
)

:recx
REM === Check if recx is installed and install if not ===
cls
where recx >nul 2>nul
if %errorlevel%==0 (
    echo recx is already installed. Skipping...
) else (
    echo Installing RecX...
    go install github.com/1hehaq/recx@latest
)

:kxss
REM === Check if kxss is installed and install if not ===
cls
where kxss >nul 2>nul
if %errorlevel%==0 (
    echo kxss is already installed. Skipping...
    go install -v github.com/Emoe/kxss@latest
)

:subzy
REM === Check if subzy is installed and install if not ===
cls
where subzy >nul 2>nul
if %errorlevel%==0 (
    echo subzy is already installed. Skipping...
) else (
    echo Installing Subzy...
    go install -v github.com/PentestPad/subzy@latest
)

:s3scanner
REM === Check if s3scanner is installed and install if not ===
cls
where s3scanner >nul 2>nul
if %errorlevel%==0 (
    echo s3scanner is already installed. Skipping...
) else (
    echo Installing s3scanner...
    go install -v github.com/sa7mon/s3scanner@latest
)










