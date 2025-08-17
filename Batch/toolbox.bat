@echo off
echo Creating Directories
md C:\Users\%username%\Bug-Bounty
echo Done
if exist C:\Users\%username%\Bug-Bounty\go1.25.0.windows-amd64.msi (
    echo Setup file already exists... Skipping...
) else (
    echo Downloading Go Language...
    powershell -c "Invoke-WebRequest -Uri 'https://go.dev/dl/go1.25.0.windows-amd64.msi' -OutFile 'C:\Users\%username%\Bug-Bounty\go1.25.0.windows-amd64.msi'"
    echo Done
)


start C:\Users\%username%\Bug-Bounty\go1.25.0.windows-amd64.msi /passive

