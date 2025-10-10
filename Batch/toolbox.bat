@echo off
title ToolBox by SenseiWhou
color 0a
echo Creating Directories
md C:\Users\%username%\Bug-Bounty
md C:\Users\%username%\Bug-Bounty\venvs
md C:\Users\%username%\Bug-Bounty\tools
set "PYTHON_VENV=C:\Users\%username%\Bug-Bounty\venvs"
set "TOOLS_DIR=C:\Users\%username%\Bug-Bounty\tools"
echo Done
echo Installing prerequisites...

REM Golang 
where go >nul 2>nul
if %errorlevel%==0 (
    echo Go is already installed. Skipping...
) else (
    echo Downloading Go Language...
    powershell -c "Invoke-WebRequest -Uri 'https://go.dev/dl/go1.25.0.windows-amd64.msi' -OutFile 'C:\Users\%username%\Bug-Bounty\go1.25.0.windows-amd64.msi'"
    echo Done
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

REM pipx
echo Checking if pipx is installed...
where pipx >nul 2>nul
if %errorlevel%==0 (
    echo pipx is already installed
) else (
    echo Installing pipx...
    pip install --user pipx
    cd %USERPROFILE%\AppData\Roaming\Python\Python312\Scripts
    .\pipx.exe ensurepath
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
echo 23. Install XSStrike
echo 24. Install Wafw00f
echo 25. Install CSRFscan
echo 26. Install SSRFmap
echo 27. Install Dirsearch
echo 28. Install Corsy
echo 29. Install Wapiti
echo 30. Install Paramspider
echo 31. Install SQLmap
echo 32. Install Arjun
echo 33. Install Uro
echo 34. Install Nmap
echo 35. Install QSreplace
echo 36. Install Chaos
echo 37. Install AlterX
echo 38. Install ASNmap
echo 39. Install SecretFinder
echo 40. Install recx
echo 41. Install urlfinder
echo 42. Install linkfinder
echo 43. Install gotator
echo 44. Install Only Tools
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
    if %%i ==23 goto xsstrike
    if %%i ==24 goto wafw00f
    if %%i ==25 goto csrfscan
    if %%i ==26 goto ssrfmap
    if %%i ==27 goto dirsearch
    if %%i ==28 goto corsy
    if %%i ==29 goto wapiti
    if %%i ==30 goto paramspider
    if %%i ==31 goto sqlmap
    if %%i ==32 goto arjun
    if %%i ==33 goto uro
    if %%i ==34 goto nmap
    if %%i ==35 goto qsreplace
    if %%i ==36 goto chaos
    if %%i ==37 goto alterx
    if %%i ==38 goto asnmap
    if %%i ==39 goto secretfinder
    if %%i ==40 goto recx
    if %%i ==41 goto urlfinder
    if %%i ==42 goto linkfinder
    if %%i ==43 goto gotator
    if %%i ==44 goto tools
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

:shortscan
REM === Check if shortscan is installed and install if not ===
cls
where shortscan >nul 2>nul
if %errorlevel%==0 (
    echo shortscan is already installed. Skipping...
) else (
    echo Installing shortscan...
    go install -v github.com/bitquark/shortscan/cmd/shortscan@latest
)

:gxss
REM === Check if gxss is installed and install if not ===
cls
where gxss >nul 2>nul
if %errorlevel%==0 (
    echo gxss is already installed. Skipping...
) else (
    echo Installing gxss...
    go install -v github.com/KathanP19/Gxss@latest
)

:crlfuzz
REM === Check if crlfuzz is installed and install if not ===
cls
where crlfuzz >nul 2>nul
if %errorlevel%==0 (
    echo crlfuzz is already installed. Skipping...
) else (
    echo Installing crlfuzz...
    go install -v github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest
)


:qsreplace
REM === Check if qsreplace is installed and install if not ===
cls
where qsreplace >nul 2>nul
if %errorlevel%==0 (
    echo qsreplace is already installed. Skipping...
) else (
    echo Installing qsreplace...
    go install -v github.com/tomnomnom/qsreplace@latest
)

:chaos
REM === Check if chaos is installed and install if not ===
cls
where chaos >nul 2>nul
if %errorlevel%==0 (
    echo chaos is already installed. Skipping...
) else (
    echo Installing chaos...
    go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest
    echo This tool requires an API key to work properly.
)

:alterx
REM === Check if alterX is installed and install if not ===
cls
where alterx >nul 2>nul
if %errorlevel%==0 (
    echo alterX is already installed. Skipping...
) else (
    echo Installing alterX...
    go install -v github.com/projectdiscovery/alterx/cmd/alterx@latest
)

:gotator
REM === Check if gotator is installed and install if not ===
cls
where gotator >nul 2>nul
if %errorlevel%==0 (
    echo gotator is already installed. Skipping...
) else (
    echo Installing gotator...
    go install -v github.com/Josue87/gotator@latest   
)

:sstimap
cls
echo Checking if SSTImap VENV exists...
:: Check if venv exists and has content
if exist "%PYTHON_VENV%\sstimap" (
    dir "%PYTHON_VENV%\sstimap\" >nul 2>&1
    if errorlevel 1 (
        echo Creating VENV...
        python -m venv "%PYTHON_VENV%\sstimap"
    ) else (
        echo [-] VENV already exists. Skipping Creation...
    )
) 
echo Checking if SSTImap is installed...
:: Check if repo exists
if exist "%TOOLS_DIR%\SSTImap\" (
    dir "%TOOLS_DIR%\SSTImap\" >nul 2>&1
    if errorlevel 1 (
        echo Installing SSTImap...
        git clone https://github.com/vladko312/SSTImap.git "%TOOLS_DIR%\SSTImap"
        call "%PYTHON_VENV%\sstimap\Scripts\activate.bat"
        pip install -r "%TOOLS_DIR%\SSTImap\requirements.txt"
        deactivate  
    ) else (
        echo SSTImap already exists. Skipping Clone...
    )
)

:xsstrike
cls
echo Checking if XSStrike VENV exists...
:: Check if venv exists and has content
if exist "%PYTHON_VENV%\xsstrike" (
    dir "%PYTHON_VENV%\xsstrike\" >nul 2>&1
    if errorlevel 1 (
        echo Creating VENV...
        python -m venv "%PYTHON_VENV%\xsstrike"
    ) else (
        echo [-] VENV already exists. Skipping Creation...
    )
) 
echo Checking if XSStrike is installed...
:: Check if repo exists
if exist "%TOOLS_DIR%\XSStrike\" (
    dir "%TOOLS_DIR%\XSStrike\" >nul 2>&1
    if errorlevel 1 (
        echo Installing XSStrike...
        git clone https://github.com/s0md3v/XSStrike "%TOOLS_DIR%\XSStrike"
        call "%PYTHON_VENV%\xsstrike\Scripts\activate.bat"
        pip install -r "%TOOLS_DIR%\XSStrike\requirements.txt"
        deactivate  
    ) else (
        echo XSStrike already exists. Skipping Clone...
    )
)

:csrfscan
cls
echo Checking if CSRFscan VENV exists...
:: Check if venv exists and has content
if exist "%PYTHON_VENV%\csrfscan" (
    dir "%PYTHON_VENV%\csrfscan\" >nul 2>&1
    if errorlevel 1 (
        echo Creating VENV...
        python -m venv "%PYTHON_VENV%\csrfscan"
    ) else (
        echo [-] VENV already exists. Skipping Creation...
    )
) 
echo Checking if CSRFscan is installed...
:: Check if repo exists
if exist "%TOOLS_DIR%\Bolt\" (
    dir "%TOOLS_DIR%\Bolt\" >nul 2>&1
    if errorlevel 1 (
        echo Installing CSRFscan...
        git clone https://github.com/s0md3v/Bolt "%TOOLS_DIR%\Bolt"
        call "%PYTHON_VENV%\csrfscan\Scripts\activate.bat"
        pip install -r "%TOOLS_DIR%\Bolt\requirements.txt"
        deactivate  
    ) else (
        echo CSRFscan already exists. Skipping Clone...
    )
)

:ssrfmap
cls
echo Checking if SSRFmap VENV exists...
:: Check if venv exists and has content
if exist "%PYTHON_VENV%\ssrfmap" (
    dir "%PYTHON_VENV%\ssrfmap\" >nul 2>&1
    if errorlevel 1 (
        echo Creating VENV...
        python -m venv "%PYTHON_VENV%\ssrfmap"
    ) else (
        echo [-] VENV already exists. Skipping Creation...
    )
) 
echo Checking if SSRFmap is installed...
:: Check if repo exists
if exist "%TOOLS_DIR%\SSRFmap\" (
    dir "%TOOLS_DIR%\SSRFmap\" >nul 2>&1
    if errorlevel 1 (
        echo Installing SSRFmap...
        git clone https://github.com/swisskyrepo/SSRFmap "%TOOLS_DIR%\SSRFmap"
        call "%PYTHON_VENV%\ssrfmap\Scripts\activate.bat"
        pip install -r "%TOOLS_DIR%\ssrfmap\requirements.txt"
        deactivate  
    ) else (
        echo SSRFmap already exists. Skipping Clone...
    )
)

:dirsearch
cls
echo Checking if Dirsearch VENV exists...
:: Check if venv exists and has content
if exist "%PYTHON_VENV%\dirsearch" (
    dir "%PYTHON_VENV%\dirsearch\" >nul 2>&1
    if errorlevel 1 (
        echo Creating VENV...
        python -m venv "%PYTHON_VENV%\dirsearch"
    ) else (
        echo [-] VENV already exists. Skipping Creation...
    )
) 
echo Checking if Dirsearch is installed...
:: Check if repo exists
if exist "%TOOLS_DIR%\dirsearch\" (
    dir "%TOOLS_DIR%\dirsearch\" >nul 2>&1
    if errorlevel 1 (
        echo Installing Dirsearch...
        git clone https://github.com/maurosoria/dirsearch "%TOOLS_DIR%\dirsearch"
        call "%PYTHON_VENV%\dirsearch\Scripts\activate.bat"
        pip install -r "%TOOLS_DIR%\dirsearch\requirements.txt"
        deactivate  
    ) else (
        echo Dirsearch already exists. Skipping Clone...
    )
)

:corsy
cls
echo Checking if Corsy VENV exists...
:: Check if venv exists and has content
if exist "%PYTHON_VENV%\corsy" (
    dir "%PYTHON_VENV%\corsy\" >nul 2>&1
    if errorlevel 1 (
        echo Creating VENV...
        python -m venv "%PYTHON_VENV%\corsy"
    ) else (
        echo [-] VENV already exists. Skipping Creation...
    )
) 
echo Checking if Corsy is installed...
:: Check if repo exists
if exist "%TOOLS_DIR%\Corsy\" (
    dir "%TOOLS_DIR%\Corsy\" >nul 2>&1
    if errorlevel 1 (
        echo Installing Corsy...
        git clone https://github.com/s0md3v/Corsy "%TOOLS_DIR%\Corsy"
        call "%PYTHON_VENV%\corsy\Scripts\activate.bat"
        pip install -r "%TOOLS_DIR%\Corsy\requirements.txt"
        deactivate  
    ) else (
        echo Corsy already exists. Skipping Clone...
    )
)

:linkfinder
cls
echo Checking if LinkFinder VENV exists...
:: Check if venv exists and has content
if exist "%PYTHON_VENV%\linkfinder" (
    dir "%PYTHON_VENV%\linkfinder\" >nul 2>&1
    if errorlevel 1 (
        echo Creating VENV...
        python -m venv "%PYTHON_VENV%\linkfinder"
    ) else (
        echo [-] VENV already exists. Skipping Creation...
    )
) 
echo Checking if linkfinder is installed...
:: Check if repo exists
call "%PYTHON_VENV%\linkfinder\Scripts\activate.bat
where linkfinder >nul 2>nul
if %errorlevel%==0 (
    echo LinkFinder is already installed. Skipping...
    deactivate
) else (
    echo Installing linkfinder...
    pip install --upgrade pip setuptools
    pip install git+https://github.com/GerbenJavado/LinkFinder.git
    deactivate 
)

:wapiti
cls
where wapiti >nul 2>nul
if %errorlevel%==0 (
    echo Wapiti is already installed. Skipping...
) else (
    echo Installing Wapiti...
    pipx install wapiti3
)

:paramspider
cls
where paramspider >nul 2>nul
if %errorlevel%==0 (
    echo Paramspider is already installed. Skipping...
) else (
    echo Installing Paramspider...
    git clone https://github.com/devanshbatham/paramspider "%TOOLS_DIR%/paramspider"
    pipx install %TOOLS_DIR%\paramspider
)

:sqlmap
cls
echo Checking if SQLmap is installed...
if exist %TOOLS_DIR%\sqlmap (
    dir "%TOOLS_DIR%\sqlmap\" >nul 2>&1
    if %errorlevel%==1 (
        echo Installing SQLmap...
        git clone https://github.com/sqlmapproject/sqlmap "%TOOLS_DIR%\sqlmap"
    )
)

:arjun
cls
echo Checking if arjun is installed...
where arjun >nul 2>nul
if %errorlevel%==0 (
    echo Arjun is already installed. Skipping
) else (
    echo Installing Arjun...
    pipx install arjun
)

:uro
cls
echo Checking if Uro is installed...
where uro >nul 2>nul
if %errorlevel%==0 (
    echo Uro is already installed. Skipping
) else (
    echo Installing Uro...
    pipx install uro
)

:nmap
cls
echo Checking if nmap is installed...
where nmap >nul 2>nul
if %errorlevel%==0 (
    echo Nmap is already installed
) else (
    echo Downloading and installing Nmap...
    powershell -c "Invoke-WebRequest -Uri 'https://nmap.org/dist/nmap-7.98-setup.exe' -OutFile '%USERPROFILE%\Bug-Bounty\nmap-7.98-setup.exe'"
    start /wait "" "%USERPROFILE%\Bug-Bounty\nmap-7.98-setup.exe" /quiet InstallAllUsers=1 PrependPath=1
)

:secretfinder
cls
echo Checking if SecretFinder VENV exists...
:: Check if venv exists and has content
if exist "%PYTHON_VENV%\secretfinder" (
    dir "%PYTHON_VENV%\secretfinder\" >nul 2>&1
    if errorlevel 1 (
        echo Creating VENV...
        python -m venv "%PYTHON_VENV%\secretfinder"
    ) else (
        echo [-] VENV already exists. Skipping Creation...
    )
) 
echo Checking if SecretFinder is installed...
:: Check if repo exists
if exist "%TOOLS_DIR%\SecretFinder\" (
    dir "%TOOLS_DIR%\SecretFinder\" >nul 2>&1
    if errorlevel 1 (
        echo Installing SecretFinder...
        git clone https://github.com/m4ll0k/SecretFinder.git "%TOOLS_DIR%\SecretFinder"
        call "%PYTHON_VENV%\secretfinder\Scripts\activate.bat"
        pip install -r "%TOOLS_DIR%\SecretFinder\requirements.txt"
        deactivate  
    ) else (
        echo SecretFinder already exists. Skipping...
    )
)

:dnsgen
cls
echo Checking if dnsgen VENV exists...
:: Check if venv exists and has content
if exist "%PYTHON_VENV%\dnsgen" (
    dir "%PYTHON_VENV%\dnsgen\" >nul 2>&1
    if errorlevel 1 (
        echo Creating VENV...
        python -m venv "%PYTHON_VENV%\dnsgen"
    ) else (
        echo VENV already exists. Skipping Creation...
    )
) 
echo Checking if dnsgen is installed...
call "%PYTHON_VENV%\dnsgen\Scripts\activate.bat
where dnsgen >nul 2>nul
if %errorlevel%==0 (
    echo Dnsgen is already installed. Skipping...
) else (
    echo Installing DNSgen...
    python -m pip install dnsgen
    deactivate
)









