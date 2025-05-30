#!/bin/bash
# === multi_installer.sh - Automated installer for security tools and wordlists ===
# Usage: bash multi_installer.sh [--install|--uninstall|--help]
# Author: Lone Wolf
# Last updated: [30-5-2025]


# === Interactive Mode ===
INTERACTIVE=0
ACTION="install"

for arg in "$@"; do
  case $arg in
    --uninstall) ACTION="uninstall"; shift ;;
    --interactive) INTERACTIVE=1; shift ;;
    --help)
      echo "Usage: $0 [--install|--uninstall] [--interactive]"
      exit 0
      ;;
  esac
done

# === Version Check Function ===
check_version() {
  local tool=$1
  local cmd=$2
  local version
  if command -v "$cmd" &>/dev/null; then
    version=$($cmd --version 2>&1 | head -n1)
    echo -e "${green}$tool version:${reset} $version"
  else
    echo -e "${red}$tool not found.${reset}"
  fi
}

# === Uninstall/Cleanup Functionality ===
uninstall_tools() {
  echo -e "${yellow}Uninstalling tools and cleaning up...${reset}"
  # Remove Go tools
  for tool in assetfinder gau httpx katana nuclei subfinder waybackurls dnsx hakrawler amass ffuf gobuster dalfox kxss gf; do
    sudo rm -f /usr/bin/$tool
  done
  # Remove Python virtual environments and tool directories
  rm -rf ~/tools
  rm -rf ~/Python-Environments
  # Remove wordlists
  rm -rf ~/tools/wordlists
  # Remove aliases from .bashrc
  sed -i '/alias sqlmap=/d' ~/.bashrc
  sed -i '/alias nikto=/d' ~/.bashrc
  # Remove gf completions
  sed -i '/gf-completions.bash/d' ~/.bashrc
  # Remove pipx tools
  pipx uninstall arjun || true
  pipx uninstall uro || true
  pipx uninstall paramspider || true
  # Remove log file
  rm -f ~/multi_installer.log
  echo -e "${green}Uninstallation and cleanup complete.${reset}"
}

# === Interactive Prompt ===
prompt_install() {
  echo -e "${yellow}Interactive mode enabled. Select what to install:${reset}"
  declare -A choices
  choices=(
    [nmap]=0 [go_tools]=0 [python_tools]=0 [wordlists]=0 [aliases]=0
  )
  read -p "Install Nmap? (y/n): " yn; [[ $yn =~ ^[Yy]$ ]] && choices[nmap]=1
  read -p "Install Go-based tools? (y/n): " yn; [[ $yn =~ ^[Yy]$ ]] && choices[go_tools]=1
  read -p "Install Python-based tools? (y/n): " yn; [[ $yn =~ ^[Yy]$ ]] && choices[python_tools]=1
  read -p "Download wordlists? (y/n): " yn; [[ $yn =~ ^[Yy]$ ]] && choices[wordlists]=1
  read -p "Add aliases to .bashrc? (y/n): " yn; [[ $yn =~ ^[Yy]$ ]] && choices[aliases]=1
  export CHOICES="${choices[@]}"
}

# === Main Control ===
if [[ "$ACTION" == "uninstall" ]]; then
  if [[ $INTERACTIVE -eq 1 ]]; then
    read -p "Are you sure you want to uninstall all tools and clean up? (y/n): " yn
    [[ $yn =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
  fi
  uninstall_tools
  exit 0
fi

if [[ $INTERACTIVE -eq 1 ]]; then
  prompt_install
fi

# === Version Checks (examples, add more as needed) ===
echo -e "${yellow}Checking versions of key tools...${reset}"
check_version "Go" go
check_version "Python3" python3
check_version "pipx" pipx
check_version "Nmap" nmap



# === Strict Mode ===
set -euo pipefail
IFS=$'\n\t'

# === Root Check ===
if [[ $EUID -ne 0 ]]; then
  echo -e "\033[0;31m[!] Please run as root (sudo).\033[0m"
  exit 1
fi

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
exec > >(awk '/^\033/ {print;fflush();}' | tee -a "$LOGFILE") 2>&1
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

echo -e "${green}Installing Nmap...${reset}"
sudo apt install -y nmap

echo "Installing npm..."
sudo apt install npm nodejs

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
  [shortscan]="go install github.com/bitquark/shortscan/cmd/shortscan@latest"
)

echo -e "${yellow}Installing Go-based tools...${reset}"
for tool in "${!go_tools[@]}"; do
  echo -e "${green}Installing $tool...${reset}"
  go install -v "${go_tools[$tool]}"
  sudo mv -f "$GOBIN/$tool" /usr/bin/
done

#Trufflehog
echo "Installing Trufflehog..."
git clone https://github.com/trufflesecurity/trufflehog.git "$TOOLS_DIR"
cd "$TOOLS_DIR/trufflehog"; go install

echo "Installing gf..."
go install github.com/tomnomnom/gf@latest
mkdir -p ~/.gf

echo "Downloading gf patterns..."
git clone https://github.com/1ndianl33t/Gf-Patterns.git "$WORDLIST_DIR/gf-patterns"
cp "$WORLDLIST_DIR/gf-patterns"/*.json ~/.gif/

echo "Setting up gf bash completions..."
echo 'source ~/.gf/gf-completions.bash' >> ~/.bashrc
source ~/.bashrc

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

#WaafW00f
echo "Installing waafw00f in a virtual environment..."
git clone https://github.com/EnableSecurity/wafw00f.git "$TOOL_DIR"
cd $TOOL_DIR/wafw00f/
python3 -m venv ~/$PYTHON_VENV/wafw00f
source ~/$PYTHON_VENV/wafw00f/bin/activate
pip3 install wafw00f
deactivate
cd ~


#CSRF Scanner
echo "Downloading CSRF Scanner (Bolt)..."
git clone https://github.com/s0md3v/Bolt "$TOOL_DIR/CSRFScan"
cd $TOOL_DIR/CSRFScan/Bolt
python3 -m venv ~/$PYTHON_VENV/csrfscan
source ~/$PYTHON_VENV/csrfscan/bin/activate
pip install -r requirements.txt
deactivate
cd ~

#SSRFmap
echo "Downloading SSRFmap..."
git clone https://github.com/swisskyrepo/SSRFmap.git "$TOOL_DIR/SSRFmap"
cd $TOOL_DIR/SSRFmap/SSRFmap
python3 -m venv ~/$PYTHON_VENV/ssrfmap
source ~/$PYTHON_VENV/ssrfmap/bin/activate
pip install -r requirements.txt
deactivate
cd ~

#Wapiti
echo ""Downloading Wapiti..."
git clone https://github.com/wapiti-scanner/wapiti.git $TOOL_DIR/
cd $TOOL_DIR/wapiti_scanner
python3 -m venv ~/$PYTHON_VENV/wapiti
source ~/$PYTHON_VENV/wapiti/bin/activate
pip install .
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
# Clean up: remove __pycache__ and .git folders to save space
find "$TOOLS_DIR/dirsearch" -type d -name "__pycache__" -exec rm -rf {} +
rm -rf "$TOOLS_DIR/dirsearch/.git"

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
git clone https://github.com/danielmiessler/SecLists.git "$TOOL_DIR/wordlists/seclists"

#FuzzDB
echo "Downloading FuzzDB..."
git clone https://github.com/fuzzdb-project/fuzzdb.git "$TOOL_DIR/wordlists/FuzzDB"

#Portable-Wordlists
echo "Downloading PayloadsAlltheThings..."
git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git "$TOOL_DIR/wordlists/PayloadsAllTheThings"

#Dirbuster Wordlist
echo "Downloading dirbuster wordlist"
git clone https://github.com/digination/dirbuster-ng/tree/master/wordlists "$TOOL_DIR/wordlists/dirb"

#OneForAll
echo "Downloading OneForAll wordlist..."
git clone https://github.com/six2dez/OneListForAll "$TOOL_DIR/wordlists/oneforall"

# === Final Output ===
echo -e "${green}All tools installed successfully!${reset}"
echo -e "${yellow}Run 'source ~/.bashrc' or restart your terminal to use the aliases.${reset}"
