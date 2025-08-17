@echo off
powershell -c "Invoke-WebRequest -Uri 'https://www.google.com/chrome/next-steps.html?statcb=1&installdataindex=empty&defaultbrowser=0#' -OutFile 'chrome.exe'"