#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
echo "
                                    ███████╗██╗   ██╗███████╗ ██████╗██╗  ██╗███████╗ ██████╗██╗  ██╗                                            
                                    ██╔════╝╚██╗ ██╔╝██╔════╝██╔════╝██║  ██║██╔════╝██╔════╝██║ ██╔╝                                            
                                    ███████╗ ╚████╔╝ ███████╗██║     ███████║█████╗  ██║     █████╔╝                                             
                                    ╚════██║  ╚██╔╝  ╚════██║██║     ██╔══██║██╔══╝  ██║     ██╔═██╗                                             
                                    ███████║   ██║   ███████║╚██████╗██║  ██║███████╗╚██████╗██║  ██╗                                            
                                    ╚══════╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝                                            
                                                                                                                                                 
███╗   ███╗ █████╗ ██████╗ ███████╗    ██████╗ ██╗   ██╗    ███████╗███████╗███╗   ██╗███████╗███████╗██╗    ██╗    ██╗██╗  ██╗ ██████╗ ██╗   ██╗
████╗ ████║██╔══██╗██╔══██╗██╔════╝    ██╔══██╗╚██╗ ██╔╝    ██╔════╝██╔════╝████╗  ██║██╔════╝██╔════╝██║    ██║    ██║██║  ██║██╔═══██╗██║   ██║
██╔████╔██║███████║██║  ██║█████╗      ██████╔╝ ╚████╔╝     ███████╗█████╗  ██╔██╗ ██║███████╗█████╗  ██║    ██║ █╗ ██║███████║██║   ██║██║   ██║
██║╚██╔╝██║██╔══██║██║  ██║██╔══╝      ██╔══██╗  ╚██╔╝      ╚════██║██╔══╝  ██║╚██╗██║╚════██║██╔══╝  ██║    ██║███╗██║██╔══██║██║   ██║██║   ██║
██║ ╚═╝ ██║██║  ██║██████╔╝███████╗    ██████╔╝   ██║       ███████║███████╗██║ ╚████║███████║███████╗██║    ╚███╔███╔╝██║  ██║╚██████╔╝╚██████╔╝
╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝    ╚═════╝    ╚═╝       ╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝╚══════╝╚═╝     ╚══╝╚══╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ 
                                                                                                                                                 
                                                         ██╗    ██████╗                                                                          
                                                        ███║   ██╔═████╗                                                                         
                                                        ╚██║   ██║██╔██║                                                                         
                                                         ██║   ████╔╝██║                                                                         
                                                         ██║██╗╚██████╔╝                                                                         
                                                         ╚═╝╚═╝ ╚═════╝                                                                          
                                                                                                                                                 
"

TOOLS_DIR=$HOME/tools
PYTHON_VENV=$HOME/Python-Environments
export WORDLIST_DIR="$TOOLS_DIR/wordlists"

# === Colors ===
green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
reset='\033[0m'

# Broken-Link-Checker
echo -e "${yellow}Checking Broken-Link-Checker...${reset}"
if command -v broken-link-checker >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Searchsploit
echo -e "${yellow}Checking Searchsploit...${reset}"
if command -v searchsploit >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Assetfinder
echo -e "${yellow}Checking Assetfinder...${reset}"
if command -v assetfinder >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Gau
echo -e "${yellow}Checking Gau...${reset}"
if command -v gau >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Httpx
echo -e "${yellow}Checking HTTPx...${reset}"
if command -v httpx >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Katana
echo -e "${yellow}Checking Katana...${reset}"
if command -v katana >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Nuclei
echo -e "${yellow}Checking Nuclei...${reset}"
if command -v nuclei >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Subfinder
echo -e "${yellow}Checking Subfinder...${reset}"
if command -v subfinder >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Waybackurls
echo -e "${yellow}Checking Waybackurls...${reset}"
if command -v waybackurls >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Dnsx
echo -e "${yellow}Checking DNSx...${reset}"
if command -v dnsx >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Hakrawler
echo -e "${yellow}Checking Hakrawler...${reset}"
if command -v hakrawler >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Amass
echo -e "${yellow}Checking Amass...${reset}"
if command -v amass >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Ffuf
echo -e "${yellow}Checking Ffuf...${reset}"
if command -v ffuf >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Gobuster
echo -e "${yellow}Checking GoBuster...${reset}"
if command -v gobuster >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Dalfox
echo -e "${yellow}Checking Dalfox...${reset}"
if command -v dalfox >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi 

# ASNmap
echo -e "${yellow}Checking ASNmap...${reset}"
if command -v asnmap >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# KXSS
echo -e "${yellow}Checking kxss...${reset}"
if command -v kxss >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Subzy
echo -e "${yellow}Checking Subzy...${reset}"
if command -v subzy >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# S3scanner
echo -e "${yellow}Checking S3scanner...${reset}"
if command -v s3scanner >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# SSTImap
echo -e "${yellow}Checking SSTImap Venv...${reset}"
if [ -s "$HOME/Python-Environments/sstimap" ]; then
    echo -e "${green} Venv OK!${reset}"
else 
    echo -e "${red} Venv Not Found${reset}"
fi

echo -e "${yellow}Checking SSTImap...${reset}"
if [ -s "$TOOLS_DIR/SSTImap" ]; then
    echo -e "${green} Tool OK!${reset}"
else
    echo -e "${red} Tool Not Found${reset}"
fi

# Shortscan
echo -e "${yellow}Checking shortscan...${reset}"
if command -v shortscan >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Gxss
echo -e "${yellow}Checking Gxss...${reset}"
if command -v Gxss >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# CRLfuzz
echo -e "${yellow}Checking CRLfuzz...${reset}"
if command -v crlfuzz >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Trufflehog
echo -e "${yellow}Checking Trufflehog...${reset}"
if command -v trufflehog >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

# Gf / Gf-Patterns
echo -e "${yellow}Checking GF...${reset}"
if command -v gf >/dev/null 2>&1; then
    echo -e "${green} All Good!!!${reset}"
else
    echo -e "${red} Command Not Found${reset}"
fi

echo -e "${yellow}Checking Gf-Patterns...${reset}"
if [ -s "$HOME/.gf" ]; then
    echo -e "${green} OK!${reset}"
else
    echo -e "${red} Directory Not Found${reset}"
fi

# XSStrike
echo -e "${yellow}Checking XSStrike VENV...${reset}"
if [ -s "$PYTHON_VENV/xsstrike" ]; then
    echo -e "${green} VENV OK!${reset}"
else
    echo -e "${red} VENV Not Found${reset}"
fi

echo -e "${yellow}Checking XSStrike...${reset}"
if [ -s "$TOOLS_DIR/XSStrike" ]; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} XSStrike Not Found${reset}"
fi

# WafW00f
echo -e "${yellow}Checking Wafw00f...${reset}"
if [ -s "$TOOLS_DIR/wafw00f/wafw00f/bin/wafw00f" ]; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} Wafw00f Not Found${reset}"
fi

# CSRFscan
echo -e "${yellow}Checking CSRFscan VENV...${reset}"
if [ -s "$PYTHON_VENV/csrfscan" ]; then
    echo -e "${green} VENV OK!${reset}"
else
    echo -e "${red} VENV Not Found${reset}"
fi

echo -e "${yellow}Checking CSRFscan...${reset}"
if [ -s "$TOOLS_DIR/Bolt" ]; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} CSRFscan Not Found"
fi

# SSRFmap
echo -e "${yellow}Checking SSRFmap VENV...${reset}"
if [ -s "$PYTHON_VENV/ssrfmap" ]; then
    echo -e "${green} VENV OK!${reset}"
else
    echo -e "${red} VENV Not Found${reset}"
fi

echo -e "${yellow}Checking SSRFmap...${reset}"
if [ -s "$TOOLS_DIR/SSRFmap" ]; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} SSRFmap Not Found${reset}"
fi

#Dirsearch
echo -e "${yellow}Checking Dirsearch VENV...${reset}"
if [ -s "$PYTHON_VENV/dirsearch" ]; then
    echo -e "${green} VENV OK!${reset}"
else 
    echo -e "${red} VENV Not Found${reset}"
fi

echo -e "${yellow} Checking Dirsearch...${reset}"
if [ -s "$TOOLS_DIR/dirsearch" ]; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} Dirsearch Not Found${reset}"
fi

echo -e "${yellow} Checking Corsy VENV...${reset}"
if [ -s "$PYTHON_VENV/corsy" ]; then
    echo -e "${green} VENV OK!${reset}"
else
    echo -e "${red} VENV Not Found${reset}"
fi

echo -e "${yellow} Checking Corsy...${reset}"
if [ -s "$TOOLS_DIR/Corsy" ]; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} Corsy Not Found${reset}"
fi

echo -e "${yellow} Checking Wapiti...${reset}"
if command -v wapiti 2>&1; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} Wapiti Not Found${reset}"
fi

echo -e "${yellow} Checking Paramspider...${reset}"
if command -v paramspider 2>&1; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} Paramspider Not Found${reset}"
fi

echo -e "${yellow} Checking SQLmap...${reset}"
if [ -s "$TOOLS_DIR/sqlmap" ] 2>&1; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} SQLmap Not Found${reset}"
fi

echo -e "${yellow} Checking arjun...${reset}"
if command -v arjun 2>&1; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} Arjun Not Found${reset}"
fi

echo -e "${yellow} Checking Nikto...${reset}"
if [ -s "$TOOLS_DIR/nikto" ]; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} Nikto Not Found${reset}"
fi

echo -e "${yellow} Checking Nmap...${reset}"
if command -v nmap 2>&1; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} Nmap Not Found${reset}"
fi

echo -e "${yellow} Checking SecretFinder VENV...${reset}"
if [ -s "$PYTHON_VENV/secretfinder" ]; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} VENV Not Found${reset}"
fi

echo -e "${yellow} Checking SecretFinder...${reset}"
if [ -s "$TOOLS_DIR/secretfinder" ]; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} SecretFinder Not Found${reset}"
fi

echo -e "${yellow} Checking Masscan...${reset}"
if command -v masscan 2>&1; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} Masscan Not Found${reset}"
fi

echo -e "${yellow} Checking QSreplace...${reset}"
if command -v qsreplace 2>&1; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} QSreplace Not Found${reset}"
fi

echo -e "${yellow} Checking Chaos...${reset}"
if command -v chaos 2>&1; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} Chaos Not Found${reset}"
fi

echo -e "${yellow} Checking AlterX...${reset}"
if command -v alterx 2>&1; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} AlterX Not Found${reset}"
fi

echo -e "${yellow} WordList Check Started!${reset}"
echo -e "${yellow} Checking Seclists...${reset}"
if [ -s "$WORDLIST_DIR/SecLists" ]; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} SecLists Not Found${reset}"
fi

echo -e "${yellow} Checking Coffin's Payloads...${reset}"
if [ -s "$WORDLIST_DIR/payloads" ]; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} Coffin's Payloads Not Found${reset}"
fi

echo -e "${yellow} Checking FuzzDB...${reset}"
if [ -s "$WORDLIST_DIR/fuzzdb" ]; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} FuzzDB Not Found${reset}"
fi

echo -e "${yellow} Checking PayloadsAllTheThings...${reset}"
if [ -s "$WORDLIST_DIR/PayloadsAllTheThings" ]; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} PayloadsAllTheThings Not Found${reset}"
fi

echo -e "${yellow} Checking OneListForAll...${reset}"
if [ -s "$WORDLIST_DIR/OneListForAll" ]; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} OneListForAll Not Found${reset}"
fi

echo -e "${yellow} Checking Dirb...${reset}"
if [ -s "$WORDLIST_DIR/dirb" ]; then
    echo -e "${green} All Good!${reset}"
else
    echo -e "${red} Dirb Not Found${reset}"
fi






