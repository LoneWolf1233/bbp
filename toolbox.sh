#!/bin/bash
# === multi_installer.sh - Cleaned Automated installer for security tools and wordlists ===
# Author: Sensei Whou
# Last updated: [21-8-2025]
REAL_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
export HOME=$REAL_HOME
clear
echo "
                                            ████████╗ ██████╗  ██████╗ ██╗     ██████╗  ██████╗ ██╗  ██╗                                         
                                            ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔══██╗██╔═══██╗╚██╗██╔╝                                         
                                               ██║   ██║   ██║██║   ██║██║     ██████╔╝██║   ██║ ╚███╔╝                                          
                                               ██║   ██║   ██║██║   ██║██║     ██╔══██╗██║   ██║ ██╔██╗                                          
                                               ██║   ╚██████╔╝╚██████╔╝███████╗██████╔╝╚██████╔╝██╔╝ ██╗                                         
                                               ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝                                         
                                                                                                                                                 
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
# ADD OPTIONS (GETOPTS)!
# ORGANIZE THE TOOLS BETTER

# === Logging ===
LOGFILE="$HOME/multi_installer.log"

# === Colors ===
green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
reset='\033[0m'

# === Setup ===
TOOLS_DIR=$HOME/tools
PYTHON_VENV=$HOME/Python-Environments
export WORDLIST_DIR="$TOOLS_DIR/wordlists"

echo -e "${green}Creating directories...${reset}"
mkdir -p "$WORDLIST_DIR" "$TOOLS_DIR" "$PYTHON_VENV"

# === Update System ===
echo -e "${green}Updating and upgrading your OS...${reset}"
sudo apt update -y && sudo apt upgrade -y

# === Install Dependencies ===
echo -e "${green}Installing dependencies...${reset}"
sudo apt install -y python3 python3-venv python3-pip pipx golang-go git wget unzip perl curl npm nodejs jq make gcc
export PATH="$HOME/.local/bin:$PATH"
GOBIN=$(go env GOPATH)/bin
export PATH="$PATH:$GOBIN"

TOOLS=(
  "Install All"
  "Broken-Link-Checker"
  "Searchsploit"
  "Assetfinder"
  "Gau"
  "Httpx"
  "Katana"
  "Nuclei"
  "Subfinder"
  "Waybackurls"
  "Dnsx"
  "Hakrawler"
  "Amass"
  "Ffuf"
  "Gobuster"
  "Dalfox"
  "KXSS"
  "Subzy"
  "S3Scanner"
  "SSTImap"
  "Shortscan"
  "GXSS"
  "CRLFuzz"
  "Trufflehog"
  "Gf-Patterns"
  "XSStrike"
  "WafW00f"
  "CSRFscan"
  "SSRFmap"
  "Dirsearch"
  "Corsy"
  "Wapiti"
  "Paramspider"
  "SQLmap"
  "Arjun"
  "Uro"
  "Nikto"
  "Nmap"
  "Massdns"
  "QSreplace"
  "Chaos"
  "AlterX"
  "ASNmap"
  "SecretFinder"
  "masscan"
  "recx"
  "urlfinder"
  "linkfinder"
  "dnsgen"
  "gotator"
  "urlscan"
  "4-ZERO-3"
  "virustotal urls"
  "Only Wordlists"
  "Only Tools"

)

echo -e "\nAvailable tools to install:"
for i in "${!TOOLS[@]}"; do
  echo "$((i+1)). ${TOOLS[$i]}"
done

read -p $'\nEnter the numbers of the tools you want to install (e.g. 1 3 5): ' -a choices
num_choice=0
total_tools=$(echo ${#choices[@]})
echo "You chose $total_tools tool/s to install."


install_broken_link_checker() {
  clear
  echo "${green} [~] Checking if broken-link-checker is installed..."
  if command -v broken-link-checker >/dev/null 2>&1; then
    echo -e "${red} [!] Broken-link-checker already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing broken-link-checker...${reset}"
    npm install broken-link-checker -g
  fi

}
install_searchsploit() {
  clear
  echo "${yellow} [~] Checking if searchsploit is installed..."
  if command -v searchsploit >/dev/null 2>&1; then
    echo -e "${red} [!] Searchsploit already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing searchsploit...${reset}"
    git clone https://www.github.com/Err0r-ICA/Searchsploit "$TOOLS_DIR/Searchsploit"
    cd $TOOLS_DIR/Searchsploit 
    bash install.sh
  fi
}

install_assetfinder() {
  clear
  echo "${yellow} [~] Checking if assetfinder is installed...${reset}"
  if command -v assetfinder >/dev/null 2>&1; then
    echo -e "${red} [-] Assetfinder already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing assetfinder...${reset}"
    go install -v github.com/tomnomnom/assetfinder@latest
    sudo mv $GOBIN/assetfinder /usr/bin
  fi
}

install_urlfinder() {
  clear
  echo "${yellow} [~] Checking if broken-link-checker is installed...${reset}"
  if command -v assetfinder >/dev/null 2>&1; then
    echo "${red} [-] Urlfinder already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing urlfinder...${reset}"
    go install -v github.com/projectdiscovery/urlfinder/cmd/urlfinder@latest
    sudo mv $GOBIN/urlfinder /usr/bin
  fi
}

install_gau() {
  clear
  echo "${yellow} [~] Checking if gau is installed...${reset}"
  if command -v gau >/dev/null 2>&1; then
    echo "${red} [-] Gau already exists. Skipping...${reset}"
  else  
    echo -e "${green}[+] Installing gau...${reset}"
    go install -v github.com/lc/gau/v2/cmd/gau@latest
    sudo mv $GOBIN/gau /usr/bin
  fi
}

install_httpx() {
  clear
  echo "${yellow} [~] Checking if httpx is installed...${reset}"
  if command -v httpx >/dev/null 2>&1; then
    echo "${red} [-] Httpx already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing httpx...${reset}"
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
    sudo mv $GOBIN/httpx /usr/bin
  fi
}

install_katana() {
  clear
  echo "${yellow} [~] Checking if katana is installed...${reset}"
  if command -v katana >/dev/null 2>&1; then
    echo "${red} [-] Katana already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing katana...${reset}"
    go install -v github.com/projectdiscovery/katana/cmd/katana@latest
    sudo mv $GOBIN/katana /usr/bin
  fi
}

install_nuclei() {
  clear
  echo "${yellow} [~] Checking if nuclei is installed...${reset}"
  if command -v nuclei >/dev/null 2>&1; then
    echo "${red} [-] Nuclei already exists. Skipping... ${reset}"
  else
    echo -e "${green} [+] Installing nuclei...${reset}"
    go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
    sudo mv $GOBIN/nuclei /usr/bin
  fi
}

install_subfinder() {
  clear
  echo "${yellow} [~] Checking if subfinder is installed...${reset}"
  if command -v subfinder >/dev/null 2>&1; then
    echo -e "${red} [-] Subfinder already exists. Skipping....${reset}"
  else
    echo -e "${green}[+] Installing subfinder...${reset}"
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    sudo mv $GOBIN/subfinder /usr/bin
  fi
}

install_waybackurls() {
  clear
  echo "${yellow} [~] Checking if waybackurls is installed... ${reset}"
  if command -v waybackurls >/dev/null 2>&1; then
    echo -e "${red} [-] Waybackurls already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing waybackurls...${reset}"
    go install -v github.com/tomnomnom/waybackurls@latest
    sudo mv $GOBIN/waybackurls /usr/bin
  fi
}

install_dnsx() {
  clear
  echo "${yellow} [~] Checking if dnsx is installed... ${reset}"
  if command -v dnsx >/dev/null 2>&1; then
    echo "${red} [-] Dnsx already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing dnsx...${reset}"
    go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
    sudo mv $GOBIN/dnsx /usr/bin
  fi
}

install_hakrawler() {
  clear
  echo "${yellow} [~] Checking if hakrawler is installed...${reset}"
  if command -v hakrawler >/dev/null 2>&1; then
    echo "${red} [-] Hakrawler already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing hakrawler...${reset}"
    go install -v github.com/hakluke/hakrawler@latest
    sudo mv $GOBIN/hakrawler /usr/bin
  fi
}

install_amass() {
  clear
  echo "${yellow} [~] Checking if amass is installed...${reset}"
  if command -v amass >/dev/null 2>&1; then
    echo -e "${red} [-] Amass already exists. Skipping...${reset}"
  else  
    echo -e "${green} [+] Installing amass ${reset}"
    go install -v github.com/owasp-amass/amass/v4/...@master
    sudo mv $GOBIN/amass /usr/bin
  fi
}

install_ffuf() {
  clear
  echo "${yellow} [~] Checking if ffuf is installed...${reset}"
  if command -v ffuf >/dev/null 2>&1; then
    echo -e "${red} [-] Ffuf already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing ffuf...${reset}"
    go install -v github.com/ffuf/ffuf/v2@latest
    sudo mv $GOBIN/ffuf /usr/bin
  fi
}

install_gobuster() {
  clear
  echo "${yellow} [~] Checking if gobuster is installed...${reset}"
  if command -v gobuster >/dev/null 2>&1; then 
    echo -e "${red} [-] Gobuster already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing gobuster...${reset}"
    go install -v github.com/OJ/gobuster/v3@latest
    sudo mv $GOBIN/gobuster /usr/bin
  fi
}

install_dalfox() {
  clear
  echo "${yellow} [~] Checking if dalfox is installed...${reset}"
  if command -v dalfox >/dev/null 2>&1; then
    echo -e "${red} [-] Dalfox already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing dalfox...${reset}"
    go install -v github.com/hahwul/dalfox/v2@latest
    sudo mv $GOBIN/dalfox /usr/bin
  fi
}

install_asnmap() {
  clear
  echo "${yellow} [~] Checking if asnmap is installed...${reset}"
  if command -v asnmap >/dev/null 2>&1; then
    echo -e "${red} [-] Asnmap already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing asnmap...${reset}"
    go install -v github.com/projectdiscovery/asnmap/cmd/asnmap@latest
    sudo mv $GOBIN/asnmap /usr/bin
  fi
}

install_recx() {
  clear
  echo "${yellow} [~] Checking if recx is installed...${reset}"
  if command -v recx >/dev/null 2>&1; then
    echo -e "${red} [-] Recx already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing recx...${reset}"
    go install github.com/1hehaq/recx@latest
    sudo mv $GOBIN/recx /usr/bin
  fi
}

install_kxss() {
  clear
  echo "${yellow} [~] Checking if kxss is installed...${reset}"
  if command -v kxss >/dev/null 2>&1; then
    echo -e "${red} [-] Kxss already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing kxss...${reset}"
    go install -v github.com/Emoe/kxss@latest
    sudo mv $GOBIN/kxss /usr/bin
  fi
}

install_subzy() {
  clear
  echo "${yellow} [~] Checking if subzy is installed...${reset}"
  if command -v subzy >/dev/null 2>&1; then
    echo -e "${red} [-] Subzy already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing subzy...${reset}"
    go install -v github.com/PentestPad/subzy@latest
    sudo mv $GOBIN/subzy /usr/bin
  fi
}

install_s3scanner() {
  clear
  echo "${yellow} [~] Checking if s3scanner is installed...${reset}"
  if command -v s3scanner >/dev/null 2>&1; then
    echo -e "${red} [-] S3scanner already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing s3scanner...${reset}"
    go install -v github.com/sa7mon/s3scanner@latest
    sudo mv $GOBIN/s3scanner /usr/bin
  fi
}

install_sstimap() {
  clear
  echo -e "${yellow}[~] Checking if SSTImap VENV exists...${reset}"

  # VENV check
  if [ -d "$PYTHON_VENV/sstimap" ] && [ "$(ls -A "$PYTHON_VENV/sstimap")" ]; then
    echo -e "${red}[-] VENV already exists. Skipping creation...${reset}"
  else
    echo -e "${green} [+] Creating VENV...${reset}"
    python3 -m venv "$PYTHON_VENV/sstimap"
  fi

  # Tool check
  echo -e "${yellow}[~] Checking if SSTImap is installed...${reset}"
  if [ -d "$TOOLS_DIR/SSTImap" ] && [ "$(ls -A "$TOOLS_DIR/SSTImap")" ]; then
    echo -e "${red}[-] SSTImap already exists. Skipping clone...${reset}"
  else
    echo -e "${green}[+] Installing SSTImap...${reset}"
    git clone https://github.com/vladko312/SSTImap.git "$TOOLS_DIR/SSTImap"
     # Install dependencies
    source "$PYTHON_VENV/sstimap/bin/activate"
    pip install -r "$TOOLS_DIR/SSTImap/requirements.txt"
    deactivate
  fi 
}


install_shortscan() {
  clear
  echo -e "${yellow} [~] Checking if shortscan is installed...${reset}"
  if command -v shortscan >/dev/null 2>&1; then
    echo -e "${red} [-] Shortscan already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing shortscan...${reset}"
    go install -v github.com/bitquark/shortscan/cmd/shortscan@latest
    sudo mv $GOBIN/shortscan /usr/bin
  fi
}

install_gxss() {
  clear
  echo -e "${yellow} [~] Checking if gxss is installed...${reset}"
  if command -v gxss >/dev/null 2>&1; then
    echo -e "${red} [-] GXSS already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing gxss...${reset}"
    go install -v github.com/KathanP19/Gxss@latest
    sudo mv $GOBIN/Gxss /usr/bin
  fi
}

install_crlfuzz(){
  clear
  echo -e "${yellow} [~] Checking if crlfuzz is installed...${reset}"
  if command -v crlfuzz >/dev/null 2>&1; then
    echo -e "${red} [-] CRLfuzz already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing crlfuzz...${reset}"
    go install -v github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest
    sudo mv $GOBIN/crlfuzz /usr/bin
  fi
}

install_trufflehog(){
  clear
  echo -e "${yellow} [~] Checking if trufflehog is installed...${reset}"
  if command -v trufflehog >/dev/null 2>&1; then
    echo -e "${red} [-] Trufflehog already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing Trufflehog...${reset}"
    curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin
  fi
}

install_gf_patterns(){
  clear
  echo -e "${yellow} [~] Checking if gf (command/binary) is installed...${reset}"
  if command -v gf >/dev/null 2>&1; then
    echo -e "${red} [-] Gf command already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing gf...${reset}"
    go install github.com/tomnomnom/gf@latest
    sudo mv $GOBIN/gf /usr/bin
  fi
  echo -e "${yellow} [~] Checking if gf-patterns (wordlist/patterns) exists...${reset}"
  if [ -d "$HOME/.gf" ] && [ "$(ls -A "$HOME/.gf")" ]; then
    echo -e "${red}[-] Gf-Patterns already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing Gf-Patterns...${reset}"
    mkdir -p $HOME/.gf
    echo -e "${green}Downloading gf patterns...${reset}"
    git clone https://github.com/coffinxp/GFpattren.git "$WORDLIST_DIR/Gf-Patterns"
    cp "$WORDLIST_DIR/Gf-Patterns"/*.json $HOME/.gf/
    echo 'source $HOME/.gf/gf-completions.bash' >> $HOME/.bashrc
  fi
}

install_xsstrike() {
  clear
  echo -e "${yellow}[~] Checking if XSStrike VENV exists...${reset}"
  # VENV check
  if [ -d "$PYTHON_VENV/xsstrike" ] && [ "$(ls -A "$PYTHON_VENV/xsstrike")" ]; then
    echo -e "${red}[-] VENV already exists. Skipping creation...${reset}"
  else
    echo -e "${green} [+] Creating VENV...${reset}"
    python3 -m venv "$PYTHON_VENV/xsstrike"
  fi
  # Tool check
  echo -e "${yellow} [~] Checking if XSStrike is installed...${reset}"
  if [ -d "$TOOLS_DIR/XSStrike" ] && [ "$(ls -A "$TOOLS_DIR/XSStrike")" ]; then
    echo -e "${red}[-] XSStrike already exists. Skipping clone...${reset}"
  else
    echo -e "${green}[+] Installing XSStrike...${reset}"
    git clone https://github.com/s0md3v/XSStrike "$TOOLS_DIR/XSStrike"
  # Install dependencies
    source "$PYTHON_VENV/xsstrike/bin/activate"
    pip install -r "$TOOLS_DIR/XSStrike/requirements.txt"
    deactivate
  fi 
}

install_wafw00f() {
  clear
  echo -e "${yellow}[~] Checking if wafw00f is installed... ${reset}"
  if command -v wafw00f >/dev/null 2>&1; then
    echo -e "${red}[-] Wafw00f already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing wafw00f...${reset}"
    sudo apt-get install wafw00f
  fi
}

install_csrfscan() {
  clear
  echo -e "${yellow}[~] Checking if CSRFscan VENV exists...${reset}"
  # VENV check
  if [ -d "$PYTHON_VENV/csrfscan" ] && [ "$(ls -A "$PYTHON_VENV/csrfscan")" ]; then
    echo -e "${red}[-] VENV already exists. Skipping creation...${reset}"
  else
    echo -e "${green} [+] Creating VENV...${reset}"
    python3 -m venv "$PYTHON_VENV/csrfscan"
  fi
  # Tool check
  echo -e "${yellow} [~] Checking if CSRFscan is installed...${reset}"
  if [ -d "$TOOLS_DIR/Bolt" ] && [ "$(ls -A "$TOOLS_DIR/Bolt")" ]; then
    echo -e "${red}[-] CSRFscan already exists. Skipping clone...${reset}"
  else
    echo -e "${green}[+] Installing CSRFscan...${reset}"
    git clone https://github.com/s0md3v/Bolt "$TOOLS_DIR/Bolt"
  # Install dependencies
    source "$PYTHON_VENV/csrfscan/bin/activate"
    pip install -r "$TOOLS_DIR/Bolt/requirements.txt"
    deactivate
  fi
}

install_ssrfmap() {
  clear
  echo -e "${yellow}[~] Checking if SSRFmap VENV exists...${reset}"
  # VENV check
  if [ -d "$PYTHON_VENV/ssrfmap" ] && [ "$(ls -A "$PYTHON_VENV/ssrfmap")" ]; then
    echo -e "${red}[-] VENV already exists. Skipping creation...${reset}"
  else
    echo -e "${green} [+] Creating VENV...${reset}"
    python3 -m venv "$PYTHON_VENV/ssrfmap"
  fi
  # Tool check
  echo -e "${yellow} [~] Checking if SSRFmap is installed... ${reset}"
  if [ -d "$TOOLS_DIR/SSRFmap" ] && [ "$(ls -A "$TOOLS_DIR/SSRFmap")" ]; then
    echo -e "${red}[-] SSRFmap already exists. Skipping clone...${reset}"
  else
    echo -e "${green}[+] Installing SSRFmap...${reset}"
    git clone https://github.com/swisskyrepo/SSRFmap "$TOOLS_DIR/SSRFmap"
  # Install dependencies
    source "$PYTHON_VENV/ssrfmap/bin/activate"
    pip install -r "$TOOLS_DIR/SSRFmap/requirements.txt"
    deactivate
  fi
}

install_dirsearch() {
  clear
  echo -e "${yellow}[~] Checking if Dirsearch VENV exists...${reset}"
  # VENV check
  if [ -d "$PYTHON_VENV/dirsearch" ] && [ "$(ls -A "$PYTHON_VENV/dirsearch")" ]; then
    echo -e "${red}[-] VENV already exists. Skipping creation...${reset}"
  else
    echo -e "${green}[+] Creating VENV...${reset}"
    python3 -m venv "$PYTHON_VENV/dirsearch"
  fi
  # Tool check
  echo -e "${yellow} [~] Checking if Dirsearch is installed...${reset}"
  if [ -d "$TOOLS_DIR/dirsearch" ] && [ "$(ls -A "$TOOLS_DIR/dirsearch")" ]; then
    echo -e "${red}[-] Dirsearch already exists. Skipping clone...${reset}"
  else
    echo -e "${green}[+] Installing Dirsearch...${reset}"
    git clone https://github.com/maurosoria/dirsearch "$TOOLS_DIR/dirsearch"
  # Install dependencies
    source "$PYTHON_VENV/dirseach/bin/activate"
    pip install -r "$TOOLS_DIR/dirsearch/requirements.txt"
    deactivate
  fi
}

install_corsy() {
  clear
  echo -e "${yellow}[~] Checking if Corsy VENV exists...${reset}"
  # VENV check
  if [ -d "$PYTHON_VENV/corsy" ] && [ "$(ls -A "$PYTHON_VENV/corsy")" ]; then
    echo -e "${red}[-] VENV already exists. Skipping creation...${reset}"
  else
    echo -e "${green} [+] Creating VENV...${reset}"
    python3 -m venv "$PYTHON_VENV/corsy"
  fi
  # Tool check
  echo -e "${yellow}[~] Checking if Corsy is installed...${reset}"
  if [ -d "$TOOLS_DIR/Corsy" ] && [ "$(ls -A "$TOOLS_DIR/Corsy")" ]; then
    echo -e "${red}[-] Corsy already exists. Skipping clone...${reset}"
  else
    echo -e "${green}[+] Installing Corsy...${reset}"
    git clone https://github.com/s0md3v/Corsy "$TOOLS_DIR/Corsy"
  # Install dependencies
    source "$PYTHON_VENV/corsy/bin/activate"
    pip install -r "$TOOLS_DIR/Corsy/requirements.txt"
    deactivate
  fi
}

install_linkfinder() {
  clear
  echo -e "${yellow}[~] Checking if Linkfinder VENV exists...${reset}"
  # VENV check
  if [ -d "$PYTHON_VENV/linkfinder" ] && [ "$(ls -A "$PYTHON_VENV/linkfinder")" ]; then
    echo -e "${red}[-] VENV already exists. Skipping creation...${reset}"
  else
    echo -e "${green}[+] Creating VENV...${reset}"
    python3 -m venv "$PYTHON_VENV/linkfinder"
  fi
  # Tool check
  if grep -q 'alias linkfinder="/home/sensei/Python-Environments/linkfinder/bin/python -m linkfinder"' "$REAL_HOME/.bashrc"; then
    echo -e "${red}[-] Linkfinder already exists. Skipping clone...${reset}"
  else
    echo -e "${green}[+] Installing linkfinder...${reset}"
    python3 -m venv "$PYTHON_VENV/linkfinder"
    source "$PYTHON_VENV/linkfinder/bin/activate"
    pip install --upgrade pip setuptools
    pip install git+https://github.com/GerbenJavado/LinkFinder.git
    echo 'alias linkfinder="/home/sensei/Python-Environments/linkfinder/bin/python -m linkfinder"' >> $HOME/.bashrc
    deactivate
  fi
}

install_wapiti() {
  clear
  echo -e "${yellow} [+] Checking if wapiti is installed...${reset}"
  if command -v wapiti >/dev/null 2>&1; then
    echo -e "${yellow}[!] Wapiti already exists. Skipping...${reset}"
  else
    echo -e "${green}Installing Wapiti...${reset}"
    pipx install wapiti3 
  fi
}

install_paramspider(){
  clear
  echo -e "${yellow} [~] Checking if paramspider is installed...${reset}"
  if [ -d "$TOOLS_DIR/paramspider" ] && [ "$(ls -A "$TOOLS_DIR/paramspider")" ]; then
    echo -e "${red} [-] Paramspider is already installed. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing Paramspider...${reset}"
    git clone https://github.com/devanshbatham/paramspider "$TOOLS_DIR/paramspider"
    pipx install "$TOOLS_DIR/paramspider"
  fi
}

install_sqlmap() {
  clear
  echo -e "${yellow} [~] Checking if SQLmap is installed...${reset}"
  if [ -d "$TOOLS_DIR/sqlmap" ] && [ "$(ls -A "$TOOLS_DIR/paramspider")" ]; then
    echo -e "${red} [-] SQLmap is already installed. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing SQLmap...${reset}"
    git clone https://github.com/sqlmapproject/sqlmap "$TOOLS_DIR/sqlmap"
    echo 'alias sqlmap="python3 '$TOOLS_DIR'/sqlmap/sqlmap.py"' >> $HOME/.bashrc
  fi
}

install_arjun() {
  clear
  echo -e "${yellow}[~] Checking if arjun is installed...${reset}"
  if command -v arjun >/dev/null 2>&1; then
    echo -e "${red} [-] Arjun already exists.${reset}"
  else
    echo -e "${green} [+] Installing Arjun..."
    pipx install arjun 
  fi
}

install_uro() {
  clear
  echo -e "${yellow} [~] Checking if uro is installed...${reset}"
  if command -v uro >/dev/null 2>&1; then
    echo -e "${red} [-] Uro is already installed. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing uro...${reset}"
    pipx install uro
  fi
}

install_nikto() {
  clear
  echo -e "${yellow} [~] Checking if nikto is installed...${reset}"
  if [ -d "$TOOLS_DIR/nikto" ]  && [ "$(ls -A "$TOOLS_DIR/nikto")" ]; then
    echo -e "${red} [-] Nikto already exists, skipping...${reset}"
  else
    echo -e "${green} [+] Installing nikto...${reset}"
    git clone https://github.com/sullo/nikto "$TOOLS_DIR/nikto"
    echo 'alias nikto="perl $TOOLS_DIR/nikto/program/nikto.pl"' >> $REAL_HOME/.bashrc  
  fi
}

install_nmap() {
  clear
  echo -e "${yellow} [~] Checking if nmap is installed...${reset}"
  if command -v nmap >/dev/null 2>&1; then
    echo -e "${red} [-] Nmap already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing nmap...${reset}"
    sudo apt install nmap -y
  fi
}

install_massdns() {
  clear
  echo -e "${yellow} [~] Checking if massdns is installed...${reset}"
  if command -v massdns >/dev/null 2>&1; then
    echo -e "${red} [-] Massdns already exists. Skipping...${reset}"
  else
    echo -e "${yellow} [+] Installing massdns...${reset}"
    git clone https://github.com/blechschmidt/massdns.git "$TOOLS_DIR/massdns"
    cd massdns
    make
  fi
}

install_secretfinder() {
  clear
  echo -e "${yellow} [~] Checking if Secretfinder VENV exists...${reset}"
  if [ -d "$PYTHON_VENV/secretfinder" ]  && [ "$(ls -A "$PYTHON_VENV/secretfinder")" ]; then
    echo -e "${red} [-] VENV exists. Skipping VENV creation...${reset}"
  else
    echo -e "${green} [+] Creating VENV...${reset}"
    python3 -m venv "$PYTHON_VENV/secretfinder"
  fi
  
  echo -e "${yellow} [~] Checking if SecretFinder is installed...${reset}"
  if [ -d "$TOOLS_DIR/secretfinder" ]  && [ "$(ls -A "$TOOLS_DIR/secretfinder")" ]; then
    echo -e "${red} [-] Secretfinder already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing SecretFinder...${reset}"
    git clone https://github.com/m4ll0k/SecretFinder.git "$TOOLS_DIR/secretfinder"
    source "$PYTHON_VENV/secretfinder/bin/activate"
    pip install -r "$TOOLS_DIR/secretfinder/requirements.txt"
    deactivate
  fi
}

install_masscan() {
  clear
  echo -e "${yellow} [~] Checking if masscan is already installed...${reset}"
  if command -v masscan >/dev/null 2>&1; then
    echo -e "${red} [-] Masscan is installed. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing masscan...${reset}"
    git clone https://github.com/robertdavidgraham/masscan "$TOOLS_DIR/masscan"
    cd "$TOOLS_DIR/masscan"
    make
    make install
    cd $REAL_HOME
  fi
}

install_qsreplace() {
  clear
  echo -e "${yellow} [~] Checking if qsreplace is installed...${reset}"
  if command -v qsreplace >/dev/null 2>&1; then
    echo -e "${red} [-] Qsreplace is installed. Skipping...${reset}" 
  else
    echo -e "${green} [+] Installing qsreplace...${reset}"
    go install -v github.com/tomnomnom/qsreplace@latest
    sudo mv $GOBIN/qsreplace /usr/bin
  fi
}

install_chaos() {
  clear
  echo -e "${yellow} [~] Checking if chaos is installed...${reset}"
  if command -v chaos >/dev/null 2>&1; then
    echo -e "${red} [-] Chaos is installed. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing chaos...${reset}"
    go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest
    sudo mv $GOBIN/chaos /usr/bin
    echo -e "${yellow} [~] This tool requires an API key to work properly.${reset}"
  fi
}

install_alterx() {
  echo -e "${yellow} [~] Checking if alterx is installed...${reset}"
  if command -v alterx >/dev/null 2>&1; then
    echo -e "${red} [-] AlterX is installed. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing alterx...${reset}"
    go install -v github.com/projectdiscovery/alterx/cmd/alterx@latest
    sudo mv $GOBIN/alterx /usr/bin
  fi
}

install_dnsgen() {
  echo -e "${yellow} [~] Checking if dnsgen VENV exists....${reset}"
  if [ -d "$PYTHON_VENV/dnsgen" ]  && [ "$(ls -A "$PYTHON_VENV/dnsgen")" ]; then 
    echo -e "${red} [-] DnsGen VENV exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Creating VENV... ${reset}"
    python3 -m venv "$PYTHON_VENV/dnsgen"
  fi
  echo -e "${yellow} [~] Checking if dnsgen is installed...${reset}"
  source "$PYTHON_VENV/dnsgen/bin/activate"
  if command -v dnsgen >/dev/null 2>&1; then
    echo -e "${red} [-] DnsGen exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing DNSgen"
    python3 -m pip install dnsgen
    deactivate
  fi
}

install_gotator() {
  echo -e "${yellow} [~] Checking if gotator is installed...${reset}"
  if command -v gotator >/dev/null 2>&1; then
    echo -e "${red} [-] Gotator exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing Gotator...${reset}"
    go install -v github.com/Josue87/gotator@latest
    sudo mv $GOBIN/gotator /usr/bin
  fi
}

install_urlscan() {
  echo -e "${yellow} [~] Checking if urlscan is installed...${reset}"
  if [ -f "$TOOLS_DIR/urlscan.py" ]; then
    echo -e "${red} [-] Urlscan is already installed. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing urlscan...${reset}"
    cd "$TOOLS_DIR"
    wget https://github.com/coffinxp/scripts/blob/main/urlscan.py
    cd $HOME
    echo "${yellow}REMINDER! This tool requires a URLscan API key to function properly. Please add it to urlscan.py. ${reset}"
    ((num_choice++))
  fi
}

install_virustotal_urls() {
  echo -e "${yellow} [~] Checking if VirusTotal-URLs is installed...${reset}"
  if [ -f "$TOOLS_DIR/virustotal" ]; then
    echo -e "${red} [-] VirusTotal-URLs is installed...${reset}"
  else
    echo -e "${green} [+] Installing VirusTotal-URLs...${reset}"
    cd "$TOOLS_DIR"
    wget https://github.com/coffinxp/scripts/blob/main/virustotal.sh
    cd "$HOME"
    echo "${yellow}REMINDER! This tool requires THREE VirusTotal API keys to function properly. Please add them to virustotal.sh.${reset}"
    ((num_choice++))
  fi
}

install_4_ZERO_3() {
  echo -e "${yellow} [~] Checking if 4-ZERO-3 is installed...${reset}"
  if [ -f "$TOOLS_DIR/4-ZERO-3/403-bypass.sh" ]; then
    echo -e "${red} [-] 4-ZERO-3 is installed. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing 4-ZERO-3...${reset}"
    git clone https://github.com/Dheerajmadhukar/4-ZERO-3.git "$TOOLS_DIR/4-ZERO-3"
    ((num_choice++))
  fi
}


install_wordlists() {
  echo -e "${yellow} [+] Downloading wordlists...${reset}"
  if [ -d "$WORDLIST_DIR/SecLists" ] && [ "$(ls -A "$WORDLIST_DIR/SecLists")" ]; then
    echo -e "${red} [-] Seclists already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Downloading SecLists...${reset}"
    git clone https://github.com/danielmiessler/SecLists.git "$WORDLIST_DIR/SecLists"
  fi
  if [ -d "$WORDLIST_DIR/payloads" ] && [ "$(ls -A "$WORDLIST_DIR/payloads")" ]; then
    echo -e "${red} [-] Coffin's Payloads alread exist. Skipping...${reset}"
  else
    echo -e "${green} [+] Downloading Coffin's Payloads...${reset}"
    git clone https://github.com/coffinxp/payloads.git "$WORDLIST_DIR/payloads"
  fi
  if [ -d "$WORDLIST_DIR/fuzzdb" ] && [ "$(ls -A "$WORDLIST_DIR/fuzzdb")" ]; then
    echo -e "${red} [-] FuzzDB already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Downloading FuzzDB...${reset}"
    git clone https://github.com/fuzzdb-project/fuzzdb.git "$WORDLIST_DIR/fuzzdb"
  fi
  if [ -d "$WORDLIST_DIR/PayloadsAllTheThings" ] && [ "$(ls -A "$WORDLIST_DIR/PayloadsAllTheThings")" ]; then
    echo -e "${red} [-] PayloadsAllTheThings already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Downloading PayloadsAllTheThings...${reset}"
    git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git "$WORDLIST_DIR/PayloadsAllTheThings"
  fi
  if [ -d "$WORDLIST_DIR/OneListForAll" ] && [ "$(ls -A "$WORDLIST_DIR/OneListForAll")" ]; then
    echo -e "${red} [-] OneListForAll already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Downloading OneListForAll...${reset}"
    git clone https://github.com/six2dez/OneListForAll "$WORDLIST_DIR/OneListForAll"
  fi
  if [ -d "$WORDLIST_DIR/dirb" ] && [ "$(ls -A "$WORDLIST_DIR/PayloadsAllTheThings")" ]; then
    echo -e "${red} [-] Dirb already exists. Skipping...${reset}"  
  else
    echo -e "${green} [+] Downloading Dirb...${reset}"
    git clone https://github.com/v0re/dirb.git "$WORDLIST_DIR/dirb"
  fi
}

install_tools_only() {
  echo -e "${yellow}Installing only tools. (no wordlists)"
  install_broken_link_checker
  install_searchsploit
  install_assetfinder
  install_gau
  install_httpx
  install_katana
  install_nuclei
  install_subfinder
  install_waybackurls
  install_dnsx
  install_hakrawler
  install_amass
  install_ffuf
  install_gobuster
  install_dalfox
  install_kxss
  install_subzy
  install_s3scanner
  install_sstimap
  install_shortscan
  install_gxss
  install_crlfuzz
  install_trufflehog
  install_gf_patterns
  install_xsstrike
  install_wafw00f
  install_csrfscan
  install_ssrfmap
  install_dirsearch
  install_corsy
  install_wapiti
  install_paramspider
  install_sqlmap
  install_arjun
  install_uro
  install_nikto
  install_nmap
  install_massdns
  install_qsreplace
  install_chaos
  install_alterx
  install_asnmap
  install_masscan
  install_recx
  install_urlfinder
  install_linkfinder
  install_dnsgen
  install_gotator
  install_urlscan
  install_virustotal_urls
  install_4_ZERO_3
}

install_all() {
  echo -e "${yellow}Installing all tools and wordlists...${reset}"
  install_broken_link_checker
  install_searchsploit
  install_assetfinder
  install_gau
  install_httpx
  install_katana
  install_nuclei
  install_subfinder
  install_waybackurls
  install_dnsx
  install_hakrawler
  install_amass
  install_ffuf
  install_gobuster
  install_dalfox
  install_kxss
  install_subzy
  install_s3scanner
  install_sstimap
  install_shortscan
  install_gxss
  install_crlfuzz
  install_trufflehog
  install_gf_patterns
  install_xsstrike
  install_wafw00f
  install_csrfscan
  install_ssrfmap
  install_dirsearch
  install_corsy
  install_wapiti
  install_paramspider
  install_sqlmap
  install_arjun
  install_uro
  install_nikto
  install_nmap
  install_massdns
  install_qsreplace
  install_chaos
  install_alterx
  install_asnmap
  install_secretfinder
  install_masscan
  install_recx
  install_urlfinder
  install_linkfinder
  install_dnsgen
  install_gotator
  install_urlscan
  install_virustotal_urls
  install_4_ZERO_3
  install_wordlists
}

for choice in "${choices[@]}"; do
  case $choice in
    1) install_all ;;
    2) install_broken_link_checker ;;
    3) install_searchsploit ;;
    4) install_assetfinder ;;
    5) install_gau ;;
    6) install_httpx ;;
    7) install_katana ;;
    8) install_nuclei ;;
    9) install_subfinder ;;
    10) install_waybackurls ;;
    11) install_dnsx ;;
    12) install_hakrawler ;;
    13) install_amass ;;
    14) install_ffuf ;;
    15) install_gobuster ;;
    16) install_dalfox ;;
    17) install_kxss ;;
    18) install_subzy ;;
    19) install_s3scanner ;;
    20) install_sstimap ;;
    21) install_shortscan ;;
    22) install_gxss ;;
    23) install_crlfuzz ;;
    24) install_trufflehog ;;
    25) install_gf_patterns ;;
    26) install_xsstrike ;;
    27) install_wafw00f ;;
    28) install_csrfscan ;;
    29) install_ssrfmap ;;
    30) install_dirsearch ;;
    31) install_corsy ;;
    32) install_wapiti ;;
    33) install_paramspider ;;
    34) install_sqlmap ;;
    35) install_arjun ;;
    36) install_uro ;;
    37) install_nikto ;;
    38) install_nmap ;;
    39) install_massdns ;;
    40) install_qsreplace ;;
    41) install_chaos ;;
    42) install_alterx ;;
    43) install_asnmap ;;
    44) install_secretfinder ;;
    45) install_masscan ;;
    46) install_recx ;;
    47) install_urlfinder ;;
    48) install_linkfinder ;;
    49) install_dnsgen ;;
    50) install_gotator ;;
    51) install_urlscan ;;
    52) install_virustotal_urls ;;
    53) install_4_ZERO_3 ;;
    54) install_wordlists ;;
    55) install_tools_only ;;
    
    *) echo -e "${red}Invalid choice: $choice${reset}" ;;
  esac
done



# === Done ===
echo -e "${green} $num_choice/$total_tools installed successfully!${reset}"
echo -e "${yellow}Run 'source $HOME/.bashrc' or restart your terminal to use the aliases.${reset}"
