#!/bin/bash
# === multi_installer.sh - Cleaned Automated installer for security tools and wordlists ===
# Author: Lone Wolf
# Last updated: [25-6-2025]
REAL_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
export HOME=$REAL_HOME

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



mkdir -p "$WORDLIST_DIR" "$TOOLS_DIR" "$PYTHON_VENV"

# === Update System ===
echo -e "${green}Updating and upgrading your OS...${reset}"
sudo apt update -y && sudo apt upgrade -y

# === Install Dependencies ===
echo -e "${green}Installing dependencies...${reset}"
sudo apt install -y python3 python3-pip pipx golang-go git wget unzip perl curl nmap npm nodejs
pipx ensurepath
GOBIN=$(go env GOPATH)/bin
export PATH="$PATH:$GOBIN"

TOOLS=(
  "Install All"
  "Broken-Link-Checker"
  "Searchsploit"
  "assetfinder"
  "gau"
  "httpx"
  "katana"
  "nuclei"
  "subfinder"
  "waybackurls"
  "dnsx"
  "hakrawler"
  "amass"
  "ffuf"
  "gobuster"
  "dalfox"
  "kxss"
  "subzy"
  "S3Scanner"
  "SSTImap"
  "shortscan"
  "gxss"
  "crlfuzz"
  "trufflehog"
  "gf"
  "csrfscan"
  "SSRFscan"
  "dirsearch"
  "corsy"
  "wapiti"
  "sqlmap"
  "arjun"
  "uro"
  "nikto"
  "seclists"
  "coffin-payloads"
  "fuzzdb"
  "Only Wordlists"
  "Only Tools"

)

echo -e "\nAvailable tools to install:"
for i in "${!TOOLS[@]}"; do
  echo "$((i+1)). ${TOOLS[$i]}"
done

read -p $'\nEnter the numbers of the tools you want to install (e.g. 1 3 5): ' -a choices

install_broken_link_checker() {
  
  echo -e "${green}Installing broken-link-checker...${reset}"
  npm install broken-link-checker -g

}
install_searchsploit() {
  echo -e "${green}Installing searchsploit...${reset}"
  git clone https://www.github.com/Err0r-ICA/Searchsploit "$TOOLS_DIR/Searchsploit"
  cd $TOOLS_DIR/Searchsploit 
  bash install.sh
}

install_assetfinder() {
  echo -e "${green}Installing assetfinder...${reset}"
  go install -v github.com/tomnomnom/assetfinder@latest
  sudo mv $GOBIN/assetfinder /usr/bin
}

install_gau() {
  echo -e "${green}Installing gau...${reset}"
  go install -v github.com/lc/gau/v2/cmd/gau@latest
  sudo mv $GOBIN/gau /usr/bin
}

install_httpx() {
  echo -e "${green}Installing httpx...${reset}"
  go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
  sudo mv $GOBIN/httpx /usr/bin
}

install_katana() {
  echo -e "${green}Installing katana...${reset}"
  go install -v github.com/projectdiscovery/katana/cmd/katana@latest
  sudo mv $GOBIN/katana /usr/bin
}

install_nuclei() {
  echo -e "${green}Installing nuclei...${reset}"
  go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
  sudo mv $GOBIN/nuclei /usr/bin
}

install_subfinder() {
  echo -e "${green}Installing subfinder...${reset}"
  go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
  sudo mv $GOBIN/subfinder /usr/bin
}

install_waybackurls() {
  echo -e "${green}Installing waybackurls...${reset}"
  go install -v github.com/tomnomnom/waybackurls@latest
  sudo mv $GOBIN/waybackurls /usr/bin
}

install_dnsx() {
  echo -e "${green}Installing dnsx...${reset}"
  go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
  sudo mv $GOBIN/dnsx /usr/bin
}

install_hakrawler() {
  echo -e "${green}Installing hakrawler...${reset}"
  go install -v github.com/hakluke/hakrawler@latest
  sudo mv $GOBIN/hakrawler /usr/bin
}

install_amass() {
  echo -e "${green}Installing amass...${reset}"
  go install -v github.com/owasp-amass/amass/v4/...@master
  sudo mv $GOBIN/amass /usr/bin
}

install_ffuf() {
  echo -e "${green}Installing ffuf...${reset}"
  go install -v github.com/ffuf/ffuf/v2@latest
  sudo mv $GOBIN/ffuf /usr/bin
}

install_gobuster() {
  echo -e "${green}Installing gobuster...${reset}"
  go install -v github.com/OJ/gobuster/v3@latest
  sudo mv $GOBIN/gobuster /usr/bin
}

install_dalfox() {
  echo -e "${green}Installing dalfox...${reset}"
  go install -v github.com/hahwul/dalfox/v2@latest
  sudo mv $GOBIN/dalfox /usr/bin
}

install_kxss() {
  echo -e "${green}Installing kxss...${reset}"
  go install -v github.com/Emoe/kxss@latest
  sudo mv $GOBIN/kxss /usr/bin
}

install_subzy() {
  echo -e "${green}Installing subzy...${reset}"
  go install -v github.com/PentestPad/subzy@latest
  sudo mv $GOBIN/subzy /usr/bin
}

install_s3scanner() {
  echo -e "${green}Installing s3scanner...${reset}"
  go install -v github.com/sa7mon/s3scanner@latest
  sudo mv $GOBIN/s3scanner /usr/bin
}

install_sstimap() {
  echo -e "${green}Installing SSTImap...${reset}"
  git clone https://github.com/vladko312/SSTImap.git "$TOOLS_DIR/SSTImap"
  python -m venv "$PYTHON_VENV/sstimap"
  source "$PYTHON_VENV/sstimap/bin/activate"
  pip install -r "$TOOLS_DIR/SSTImap/requirements.txt"
  deactivate
}

install_shortscan() {
  echo -e "${green}Installing shortscan...${reset}"
  go install -v github.com/bitquark/shortscan/cmd/shortscan@latest
  sudo mv $GOBIN/shortscan /usr/bin
}

install_gxss() {
  echo -e "${green}Installing gxss...${reset}"
  go install -v github.com/KathanP19/Gxss@latest
  sudo mv $GOBIN/Gxss /usr/bin
}

install_crlfuzz(){
  echo -e "${green}Installing crlfuzz...${reset}"
  go install -v github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest
  sudo mv $GOBIN/crlfuzz /usr/bin
}

install_trufflehog(){
  echo -e "${green}Installing Trufflehog...${reset}"
  curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin
}

install_gf_patterns(){
  echo -e "${green}Installing gf...${reset}"
  go install github.com/tomnomnom/gf@latest
  mkdir -p $HOME/.gf
  echo -e "${green}Downloading gf patterns...${reset}"
  git clone https://github.com/1ndianl33t/Gf-Patterns.git "$WORDLIST_DIR/Gf-Patterns"
  cp "$WORDLIST_DIR/Gf-Patterns"/*.json $HOME/.gf/
  echo 'source $HOME/.gf/gf-completions.bash' >> $HOME/.bashrc
}

install_xsstrike() {
  echo -e "${green}Installing xsstrike...${reset}"
  if [ ! -d "$TOOLS_DIR/XSStrike" ]; then
    git clone https://github.com/s0md3v/XSStrike "$TOOLS_DIR/XSStrike"
    python3 -m venv "$PYTHON_VENV/xsstrike"
    source "$PYTHON_VENV/xsstrike/bin/activate"
    pip install -r "$TOOLS_DIR/XSStrike/requirements.txt"
    deactivate
  else
    echo -e "XSStrike already exists. Skipping..."
  fi
}

install_wafw00f() {
  echo -e "${green}Installing wafw00f...${reset}"
  if [ ! -d "$TOOLS_DIR/wafw00f" ]; then
    git clone https://github.com/EnableSecurity/wafw00f "$TOOLS_DIR/wafw00f"
    python3 -m venv "$PYTHON_VENV/wafw00f"
    source "$PYTHON_VENV/wafw00f/bin/activate"
    pip install -r "$TOOLS_DIR/wafw00f/requirements.txt"
    deactivate
  else
    echo -e "${yellow}Wafw00f already exists. Skipping...${reset}"
  fi
}

install_csrfscan() {
  echo -e "${green}Installing csrfscan...${reset}"
  if [ ! -d "$TOOLS_DIR/Bolt" ]; then
    git clone https://github.com/s0md3v/Bolt "$TOOLS_DIR/Bolt"
    python3 -m venv "$PYTHON_VENV/csrfscan"
    source "$PYTHON_VENV/csrfscan/bin/activate"
    pip install -r "$TOOLS_DIR/Bolt/requirements.txt"
    deactivate
  else
    echo -e "${yellow}CSRFscan already exists. Skipping...${reset}"
  fi
}

install_ssrfmap() {
  echo -e "${green}Installing ssrfmap...${reset}"
  if [ ! -d "$TOOLS_DIR/SSRFmap" ]; then
    git clone https://github.com/swisskyrepo/SSRFmap "$TOOLS_DIR/SSRFmap"
    python3 -m venv "$PYTHON_VENV/ssrfmap"
    source "$PYTHON_VENV/ssrfmap/bin/activate"
    pip install -r "$TOOLS_DIR/SSRFmap/requirements.txt"
    deactivate
  else
    echo -e "${yellow}SSRFmap already exists. Skipping...${reset}"
  fi
}

install_dirsearch() {
  echo -e "${green}Installing dirsearch...${reset}"
  if [ ! -d "$TOOLS_DIR/dirsearch" ]; then
    git clone https://github.com/maurosoria/dirsearch "$TOOLS_DIR/dirsearch"
    python3 -m venv "$PYTHON_VENV/dirsearch"
    source "$PYTHON_VENV/dirsearch/bin/activate"
    pip install -r "$TOOLS_DIR/dirsearch/requirements.txt"
    deactivate
  else
    echo -e "${yellow}Dirsearch already exists. Skipping...${reset}"
  fi
}

install_corsy() {
  echo -e "${green}Installing corsy...${reset}"
  if [ ! -d "$TOOLS_DIR/Corsy" ]; then
    git clone https://github.com/s0md3v/Corsy "$TOOLS_DIR/Corsy"
    python3 -m venv "$PYTHON_VENV/corsy"
    source "$PYTHON_VENV/corsy/bin/activate"
    pip install -r "$TOOLS_DIR/Corsy/requirements.txt"
    deactivate
  else
    echo -e "${yellow}Corsy already exists. Skipping...${reset}"
  fi
}

install_wapiti() {
  echo -e "${green}Installing Wapiti...${reset}"
  pipx install wapiti3 || echo -e "${red}Wapiti may already be installed.${reset}"
}

install_paramspider(){
  echo -e "${yellow}Installing Paramspider...${reset}"
  if [ ! -d "$TOOLS_DIR/paramspider" ]; then
    git clone https://github.com/devanshbatham/paramspider "$TOOLS_DIR/paramspider"
    pipx install "$TOOLS_DIR/paramspider"
  fi
}

install_sqlmap() {
  echo -e "${yellow}Installing SQLmap...${reset}"
  if [ ! -d "$TOOLS_DIR/sqlmap" ]; then
    git clone https://github.com/sqlmapproject/sqlmap "$TOOLS_DIR/sqlmap"
    echo 'alias sqlmap="python3 '$TOOLS_DIR'/sqlmap/sqlmap.py"' >> $HOME/.bashrc
  fi
}

install_arjun() {
  echo -e "${yellow}Installing arjun...${reset}"
  pipx install arjun || echo -e "${red}Arjun may already be installed.${reset}"
}

install_uro() {
  echo -e "${yellow}Installing uro...${reset}"
  pipx install uro || echo -e "${red}Uro may already be installed.${reset}"
}

install_nikto() {
  echo -e "${yellow}Installing Nikto...${reset}"
  if [ ! -d "$TOOLS_DIR/nikto" ]; then
    git clone https://github.com/sullo/nikto "$TOOLS_DIR/nikto"
    echo 'alias nikto="perl $TOOLS_DIR/nikto/program/nikto.pl"' >> $HOME/.bashrc
  else
    echo -e "${red}Nikto already exists, skipping...${reset}"
  fi
}

install_wordlists() {
  echo -e "${yellow}Downloading wordlists...${reset}"
  if [ ! -d "$WORDLIST_DIR/SecLists" ]; then
    git clone https://github.com/danielmiessler/SecLists.git "$WORDLIST_DIR/SecLists"
  else
    echo -e "${red}Seclists already exists. Skipping...${reset}"
  fi
  if [ ! -d "$WORDLIST_DIR/payloads" ]; then
    git clone https://github.com/coffinxp/payloads.git "$WORDLIST_DIR/payloads"
  else
    echo -e "${red}Coffin's payloads alread exist. Skipping...${reset}"
  fi
  if [ ! -d "$WORDLIST_DIR/fuzzdb" ]; then
    git clone https://github.com/fuzzdb-project/fuzzdb.git "$WORDLIST_DIR/fuzzdb"
  else
    echo -e "${red}FuzzDB already exists. Skipping...${reset}"
  fi
  if [ ! -d "$WORDLIST_DIR/PayloadsAllTheThings" ]; then
    git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git "$WORDLIST_DIR/PayloadsAllTheThings"
  else
    echo -e "${red}PayloadsAllTheThings already exists. Skipping...${reset}"
  fi
  if [ ! -d "$WORDLIST_DIR/OneListForAll" ]; then
    git clone https://github.com/six2dez/OneListForAll "$WORDLIST_DIR/OneListForAll"
  else
    echo -e "${red}OneListForAll already exists. Skipping...${reset}"
  fi
  if [ ! -d "$WORDLIST_DIR/dirb" ]; then
    git clone https://github.com/v0re/dirb.git "$WORDLIST_DIR/dirb"
  else
    echo -e "${red}Dirb already exists. Skipping...${reset}"
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
    38) install_wordlists ;;
    39) install_tools_only ;;
    
    *) echo "Invalid choice: $choice" ;;
  esac
done



# === Done ===
echo -e "${green}All tools installed successfully!${reset}"
echo -e "${yellow}Run 'source $HOME/.bashrc' or restart your terminal to use the aliases.${reset}"
