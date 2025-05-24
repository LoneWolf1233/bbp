#!/bin/bash
set -e
echo -e " 
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
TOOLS_DIR=~/tools
PYTHON_VENV=~/Python-Environments
export WORDLIST_DIR="$TOOL_DIR/wordlists"
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
  
)

echo -e "${yellow}Installing Go-based tools...${reset}"
for tool in "${!go_tools[@]}"; do
  echo -e "${green}Installing $tool...${reset}"
  go install "${go_tools[$tool]}"
  sudo mv -f "$GOBIN/$tool" /usr/bin/
done

# === Python-based Tools ===

#XSStrike
echo "Installing XSStrike in a virtual environment..."
git clone https://github.com/s0md3v/XSStrike.git "$TOOL_DIR/xsstrike"
cd $TOOL_DIR/xsstrike/XSStrike
python3 -m venv ~/$PYTHON_VENV/xsstrike
source ~/$PYTHON_VENV/xsstrike/bin/activate
pip install -r requirements.txt
deactivate
cd ~

#Dirsearch
echo "Installing dirsearch in a virtual environment..."
git clone https://github.com/maurosoria/dirsearch.git "$TOOL_DIR/dirsearch"
cd $TOOL_DIR/dirsearch/dirsearch
python3 -m venv ~/$PYTHON_VENV/dirsearch
source ~/$PYTHON_VENV/dirsearch/bin/activate
pip install -r requirements.txt
deactivate
cd ~

#theHarvester
echo "Installing theHarvester in a virtual environment..."
git clone https://github.com/laramies/theHarvester.git "$TOOL_DIR/theHarvester"
cd "$TOOL_DIR/theHarvester"

python3 -m venv "$PYTHON_VENV/theHarvester"
source "$PYTHON_VENV/theHarvester/bin/activate"

pip install --upgrade pip setuptools
pip install -r requirements/base.txt
pip install -r requirements/dev.txt 2>/dev/null || true

deactivate
cd ~


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
  echo 'alias sqlmap="python3 ~/tools/sqlmap/sqlmap.py"' >> ~/.bashrc
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
  echo 'alias nikto="perl ~/tools/nikto/program/nikto.pl"' >> ~/.bashrc
else
  echo -e "${red}Nikto already exists, skipping...${reset}"
fi

# === Wordlists ===

# SecLists ===
echo "Downloading Seclists..."
git clone https://github.com/danielmiessler/SecLists.git "$TOOL_DIR/seclists"

#FuzzDB
echo "Downloading FuzzDB..."
git clone https://github.com/fuzzdb-project/fuzzdb.git "$TOOL_DIR/FuzzDB"

#Portable-Wordlists
echo "Downloading PayloadsAlltheThings..."
git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git "$TOOL_DIR/PayloadsAllTheThings"



# === Final Output ===
echo -e "${green}All tools installed successfully!${reset}"
echo -e "${yellow}Run 'source ~/.bashrc' or restart your terminal to use the aliases.${reset}"
