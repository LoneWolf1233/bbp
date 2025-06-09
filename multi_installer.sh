#!/bin/bash
# === multi_installer.sh - Automated installer for security tools and wordlists ===
# Usage: bash multi_installer.sh [--install|--uninstall|--help]
# Author: Lone Wolf
# Last updated: [1-5-2025]

# === Logging ===
LOGFILE="$HOME/multi_installer.log"
# Progress bar function
progress() {
  local duration=$1
  local message=$2
  local i=0
  tput civis
  echo -ne "$message ["
  while [ $i -lt $duration ]; do
    echo -ne "#"
    sleep 0.1
    ((i++))
  done
  echo -e "] done."
  tput cnorm
}

# Log only echos, suppress command output
#exec > >(awk '/^\033/ {print;fflush();}' | tee -a "$LOGFILE") 2>&1
#set -e
echo -e " 
made by
 _                   __        __    _  __
| |    ___  _ __   __\ \      / /__ | |/ _|
| |   / _ \| '_ \ / _ \ \ /\ / / _ \| | |_
| |__| (_) | | | |  __/\ V  V / (_) | |  _|
|_____\___/|_| |_|\___| \_/\_/ \___/|_|_|"


# === Colors ===
green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
reset='\033[0m'

# === Setup ===
TOOLS_DIR=$HOME/tools
PYTHON_VENV=$HOME/Python-Environments
export WORDLIST_DIR="$TOOLS_DIR/wordlists"
GOBIN=$(go env GOPATH)/bin
mkdir -p "$WORDLIST_DIR"
mkdir -p "$TOOLS_DIR"
mkdir -p "$PYTHON_VENV"

echo -e "${green}Updating and upgrading your OS...${reset}"
sudo apt update -y && sudo apt upgrade -y

echo -e "${green}Installing dependencies...${reset}"
sudo apt install -y python3 python3-pip pipx golang-go git wget unzip perl curl

pipx ensurepath
export PATH="$PATH:$GOBIN"

echo -e "${green}Installing Nmap...${reset}"
sudo apt install -y nmap

echo -e "${green}Installing npm...${reset}"
sudo apt install npm nodejs

echo -e "${green}Installing broken-link-checker...${reset}"
npm install broken-link-checker -g

# === Go Tools Installation ===
declare -A go_tools=(
  [assetfinder]="github.com/tomnomnom/assetfinder@latest"
  [gau]="github.com/lc/gau/v2/cmd/gau@latest"
  [httpx]="github.com/projectdiscovery/httpx/cmd/httpx@latest"
  [katana]="github.com/projectdiscovery/katana/cmd/katana@latest"
  [nuclei]="github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
  [subfinder]="github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
  [waybackurls]="github.com/tomnomnom/waybackurls@latest"
  [dnsx]="github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
  [hakrawler]="github.com/hakluke/hakrawler@latest"
  [amass]="github.com/owasp-amass/amass/v4/...@master"
  [ffuf]="github.com/ffuf/ffuf/v2@latest"
  [gobuster]="github.com/OJ/gobuster/v3@latest"
  [dalfox]="github.com/hahwul/dalfox/v2@latest"
  [kxss]="github.com/Emoe/kxss@latest"
  [subzy]="github.com/PentestPad/subzy@latest"
  [shortscan]="github.com/bitquark/shortscan/cmd/shortscan@latest"
)

echo -e "${yellow}Installing Go-based tools...${reset}"
for tool in "${!go_tools[@]}"; do
  echo -e "${green}Installing $tool...${reset}"
  go install -v "${go_tools[$tool]}"
  sudo mv -f "$GOBIN/$tool" /usr/bin/
done

echo -e "${yellow}Installing CRLF Fuzz...${reset}"
git clone https://github.com/dwisiswant0/crlfuzz "$TOOLS_DIR"
cd "$TOOLS_DIR/"; go install
sudo mv -f "$GOBIN/crlfuzz" /usr/bin/
cd $HOME


#Trufflehog
echo -e "${green}Installing Trufflehog...${reset}"
git clone https://github.com/trufflesecurity/trufflehog.git "$TOOLS_DIR"
cd "$TOOLS_DIR/"; go install
sudo mv -f "$GOBIN/trufflehog" /usr/bin/
cd $HOME




echo -e "${green}Installing gf...${reset}"
go install github.com/tomnomnom/gf@latest
mkdir -p $HOME/.gf

echo -e "${green}Downloading gf patterns...${reset}"
git clone https://github.com/1ndianl33t/Gf-Patterns.git "$WORDLIST_DIR/gf-patterns"
cp "$WORLDLIST_DIR/gf-patterns"/*.json $HOME/.gif/

echo -e "${green}Setting up gf bash completions...${reset}"
echo 'source $HOME/.gf/gf-completions.bash' >> $HOME/.bashrc
source $HOME/.bashrc

# === Python-based Tools ===

#XSStrike
echo -e "${green}Installing XSStrike in a virtual environment...${reset}"
git clone https://github.com/s0md3v/XSStrike.git "$TOOLS_DIR/xsstrike"
python3 -m venv $PYTHON_VENV/xsstrike
source $PYTHON_VENV/xsstrike/bin/activate
pip install -r $TOOLS_DIR/xsstrike/requirements.txt
cd $HOME
deactivate


#WaafW00f
echo -e "${green}Installing waafw00f in a virtual environment...${reset}"
git clone https://github.com/EnableSecurity/wafw00f.git "$TOOLS_DIR/wafw00f"
python3 -m venv $PYTHON_VENV/wafw00f
source $PYTHON_VENV/wafw00f/bin/activate
pip3 install wafw00f
cd $HOME
deactivate


#Ghauri (NEEDS MORE TESTING THOUGH INSTALLATION SEEMS TO BE FUNCTIONING)
echo -e "${green}Installing Ghauri in a virtual environment...${reset}"
git clone https://github.com/r0oth3x49/ghauri.git "$TOOLS_DIR/ghauri"
python3 -m venv $PYTHON_VENV/ghauri
source $PYTHON_VENV/ghauri/bin/activate
pip install setuptools
python3 $TOOLS_DIR/ghauri/setup.py install
deactivate
cd $HOME    


#CSRF Scanner
echo -e "${green}Downloading CSRF Scanner (Bolt)...${reset}"
git clone https://github.com/s0md3v/Bolt "$TOOLS_DIR/csrfscan"
python3 -m venv $PYTHON_VENV/csrfscan
source $PYTHON_VENV/csrfscan/bin/activate
pip install -r $TOOLS_DIR/csrfscan/requirements.txt
deactivate
cd $HOME

#SSRFmap
echo -e "${green}Downloading SSRFmap...${reset}"
git clone https://github.com/swisskyrepo/SSRFmap.git "$TOOLS_DIR/SSRFmap"
python3 -m venv $PYTHON_VENV/ssrfmap
source $PYTHON_VENV/ssrfmap/bin/activate
pip install -r $TOOLS_DIR/SSRFmap/requirements.txt
deactivate
cd $HOME

#TO TEST LATER
#Wapiti
echo -e "${green}Downloading Wapiti...${reset}"
git clone https://github.com/wapiti-scanner/wapiti.git $TOOLS_DIR/wapiti
python3 -m venv $PYTHON_VENV/wapiti
source $PYTHON_VENV/wapiti/bin/activate
pip install .
deactivate
cd $HOME


#Dirsearch
echo -e "${green}Installing dirsearch in a virtual environment...${reset}"
git clone https://github.com/maurosoria/dirsearch.git "$TOOLS_DIR/dirsearch"
python3 -m venv $PYTHON_VENV/dirsearch
source $PYTHON_VENV/dirsearch/bin/activate
pip install -r $TOOLS_DIR/dirsearch/requirements.txt
deactivate
cd $HOME

# Clean up: remove __pycache__ and .git folders to save space
find "$TOOLS_DIR/dirsearch" -type d -name "__pycache__" -exec rm -rf {} +
rm -rf "$TOOLS_DIR/dirsearch/.git"



# Paramspider
echo -e "${yellow}Installing Paramspider...${reset}"
if [ ! -d "$TOOLS_DIR/paramspider" ]; then
  git clone https://github.com/devanshbatham/paramspider "$TOOLS_DIR/paramspider"
  pipx install "$TOOLS_DIR/paramspider"
else
  echo -e "${red}Paramspider already exists, skipping...${reset}"
fi

# SQLmap
echo -e "${yellow}Downloading SQLmap...${reset}"
if [ ! -d "$TOOLS_DIR/sqlmap" ]; then
  git clone https://github.com/sqlmapproject/sqlmap "$TOOLS_DIR/sqlmap"
  echo 'alias sqlmap="python3 $HOME/tools/sqlmap/sqlmap.py"' >> $HOME/.bashrc
else
  echo -e "${red}SQLmap already exists, skipping...${reset}"
fi

# Arjun
echo -e "${yellow}Installing Arjun...${reset}"
pipx install arjun || echo -e "${red}Arjun may already be installed.${reset}"

# Uro
echo -e "${yellow}Installing Uro...${reset}"
pipx install uro || echo -e "${red}Uro may already be installed.${reset}"

# Nikto
echo -e "${yellow}Installing Nikto...${reset}"
if [ ! -d "$TOOLS_DIR/nikto" ]; then
  git clone https://github.com/sullo/nikto "$TOOLS_DIR/nikto"
  echo 'alias nikto="perl $HOME/tools/nikto/program/nikto.pl"' >> $HOME/.bashrc
else
  echo -e "${red}Nikto already exists, skipping...${reset}"
fi

# === Wordlists ===

# SecLists ===
echo -e "${yellow}Downloading Seclists...${reset}"
git clone https://github.com/danielmiessler/SecLists.git "$TOOL_DIR/wordlists/seclists"

#FuzzDB
echo -e "${yellow}Downloading FuzzDB...${reset}"
git clone https://github.com/fuzzdb-project/fuzzdb.git "$TOOL_DIR/wordlists/FuzzDB"

#Portable-Wordlists
echo -e "${yellow}Downloading PayloadsAlltheThings...${reset}"
git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git "$TOOL_DIR/wordlists/PayloadsAllTheThings"

#Dirbuster Wordlist
echo -e "${yellow}Downloading dirbuster wordlist...${reset}"
git clone https://github.com/digination/dirbuster-ng/tree/master/wordlists "$TOOL_DIR/wordlists/dirb"

#OneForAll
echo -e "${yellow}Downloading OneForAll wordlist...${reset}"
git clone https://github.com/six2dez/OneListForAll "$TOOL_DIR/wordlists/oneforall"

# === Final Output ===
echo -e "${green}All tools installed successfully!${reset}"
echo -e "${yellow}Run 'source $HOME/.bashrc' or restart your terminal to use the aliases.${reset}"
