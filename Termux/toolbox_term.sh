#!/bin/bash
# === multi_installer.sh - Cleaned Automated installer for security tools and wordlists for Android's Termux ===
# Author: Sensei Whou
# Last updated: [18-8-2025]
REAL_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
export HOME=$REAL_HOME
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

HOME_V="/data/data/com.termux/files/home/"
# === Logging ===
LOGFILE="$HOME_V/multi_installer.log"

# === Colors ===
green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
reset='\033[0m'

# === Setup ===
TOOLS_DIR=$HOME_V/tools
PYTHON_VENV=$HOME_V/Python-Environments
TERM_PATH=/data/data/com.termux/files/usr/bin
export WORDLIST_DIR="$TOOLS_DIR/wordlists"


echo -e "${green}Creating directories...${reset}"
mkdir -p "$WORDLIST_DIR" "$TOOLS_DIR" "$PYTHON_VENV"

# === Update System ===
echo -e "${green}Updating and upgrading your OS...${reset}"
apt update -y && sudo apt upgrade -y

# === Install Dependencies ===
echo -e "${green}Installing dependencies...${reset}"
apt install -y python3 python3-pip pipx golang-go git wget unzip perl curl npm nodejs jq make gcc
export PATH="$HOME_V/.local/bin:$PATH"
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
  mv $GOBIN/assetfinder $TERM_PATH
}

install_urlfinder() {
  echo -e "${green}Installing urlfinder...${reset}"
  go install -v github.com/projectdiscovery/urlfinder/cmd/urlfinder@latest
   mv $GOBIN/urlfinder $TERM_PATH
}

install_gau() {
  echo -e "${green}Installing gau...${reset}"
  go install -v github.com/lc/gau/v2/cmd/gau@latest
  mv $GOBIN/gau $TERM_PATH
}

install_httpx() {
  echo -e "${green}Installing httpx...${reset}"
  go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
  mv $GOBIN/httpx $TERM_PATH
}

install_katana() {
  echo -e "${green}Installing katana...${reset}"
  go install -v github.com/projectdiscovery/katana/cmd/katana@latest
  mv $GOBIN/katana $TERM_PATH
}

install_nuclei() {
  echo -e "${green}Installing nuclei...${reset}"
  go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
  mv $GOBIN/nuclei $TERM_PATH
}

install_subfinder() {
  echo -e "${green}Installing subfinder...${reset}"
  go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
  mv $GOBIN/subfinder $TERM_PATH
}

install_waybackurls() {
  echo -e "${green}Installing waybackurls...${reset}"
  go install -v github.com/tomnomnom/waybackurls@latest
  mv $GOBIN/waybackurls $TERM_PATH
}

install_dnsx() {
  echo -e "${green}Installing dnsx...${reset}"
  go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
  mv $GOBIN/dnsx $TERM_PATH
}

install_hakrawler() {
  echo -e "${green}Installing hakrawler...${reset}"
  go install -v github.com/hakluke/hakrawler@latest
  mv $GOBIN/hakrawler $TERM_PATH
}

install_amass() {
  echo -e "${green}Installing amass...${reset}"
  go install -v github.com/owasp-amass/amass/v4/...@master
  mv $GOBIN/amass $TERM_PATH
}

install_ffuf() {
  echo -e "${green}Installing ffuf...${reset}"
  go install -v github.com/ffuf/ffuf/v2@latest
  mv $GOBIN/ffuf $TERM_PATH
}

install_gobuster() {
  echo -e "${green}Installing gobuster...${reset}"
  go install -v github.com/OJ/gobuster/v3@latest
  mv $GOBIN/gobuster $TERM_PATH
}

install_dalfox() {
  echo -e "${green}Installing dalfox...${reset}"
  go install -v github.com/hahwul/dalfox/v2@latest
  mv $GOBIN/dalfox $TERM_PATH
}

install_asnmap() {
  echo -e "${green}Installing asnmap...${reset}"
  go install -v github.com/projectdiscovery/asnmap/cmd/asnmap@latest
  mv $GOBIN/asnmap $TERM_PATH
}

install_recx() {
  echo -e "${green} Installing recx...${reset}"
  go install github.com/1hehaq/recx@latest
  mv $GOBIN/recx $TERM_PATH
}

install_kxss() {
  echo -e "${green}Installing kxss...${reset}"
  go install -v github.com/Emoe/kxss@latest
  mv $GOBIN/kxss $TERM_PATH
}

install_subzy() {
  echo -e "${green}Installing subzy...${reset}"
  go install -v github.com/PentestPad/subzy@latest
  mv $GOBIN/subzy $TERM_PATH
}

install_s3scanner() {
  echo -e "${green}Installing s3scanner...${reset}"
  go install -v github.com/sa7mon/s3scanner@latest
  mv $GOBIN/s3scanner $TERM_PATH
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
  mv $GOBIN/shortscan $TERM_PATH
}

install_gxss() {
  echo -e "${green}Installing gxss...${reset}"
  go install -v github.com/KathanP19/Gxss@latest
  mv $GOBIN/Gxss $TERM_PATH
}

install_crlfuzz(){
  echo -e "${green}Installing crlfuzz...${reset}"
  go install -v github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest
  mv $GOBIN/crlfuzz $TERM_PATH
}

install_trufflehog(){
  echo -e "${green}Installing Trufflehog...${reset}"
  curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin
}

install_gf_patterns(){
  echo -e "${green}Installing gf...${reset}"
  go install github.com/tomnomnom/gf@latest
  sudo mv $GOBIN/gf $TERM_PATH
  mkdir -p $HOME_V/.gf
  echo -e "${green}Downloading gf patterns...${reset}"
  git clone https://github.com/1ndianl33t/Gf-Patterns.git "$WORDLIST_DIR/Gf-Patterns"
  cp "$WORDLIST_DIR/Gf-Patterns"/*.json $HOME_V/.gf/
  echo 'source $HOME_V/.gf/gf-completions.bash' >> $HOME_V/.bashrc
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
  pip3 install wafw00f
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

install_linkfinder() {
  echo -e "${green}Installing linkfinder...${reset}"
  if [ ! -d "$TOOLS_DIR/LinkFinder" ]; then
    python3 -m venv "$PYTHON_VENV/linkfinder"
    source "$PYTHON_VENV/linkfinder/bin/activate"
    pip install --upgrade pip setuptools
    pip install git+https://github.com/GerbenJavado/LinkFinder.git
    echo 'alias linkfinder="/home/sensei/Python-Environments/linkfinder/bin/python -m linkfinder"' >> $HOME_V/.bashrc
    deactivate
  else
    echo -e "${yellow}LinkFinder already exists. Skipping...${reset}"
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
    echo 'alias sqlmap="python3 '$TOOLS_DIR'/sqlmap/sqlmap.py"' >> $HOME_V/.bashrc
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
    echo 'alias nikto="perl $TOOLS_DIR/nikto/program/nikto.pl"' >> $REAL_HOME/.bashrc
  else
    echo -e "${red}Nikto already exists, skipping...${reset}"
  fi
}

install_nmap() {
  echo -e "${yellow}Installing nmap...${reset}"
  sudo apt install nmap -y
}

install_massdns() {
  echo -e "${yellow}Installing massdns...${reset}"
  git clone https://github.com/blechschmidt/massdns.git "$TOOLS_DIR/massdns"
  cd massdns
  make
}

install_secretfinder() {
  echo -e "${yellow}Installing secretfinder...${reset}"
  git clone https://github.com/m4ll0k/SecretFinder.git "$TOOLS_DIR/secretfinder"
  python3 -m venv "$PYTHON_VENV/secretfinder"
  source "$PYTHON_VENV/secretfinder/bin/activate"
  pip install -r "$TOOLS_DIR/secretfinder/requirements.txt"
  deactivate
}

install_masscan() {
  echo -e "${green}Installing masscan...${reset}"
  git clone https://github.com/robertdavidgraham/masscan "$TOOLS_DIR/masscan"
  cd "$TOOLS_DIR/masscan"
  make
  make install
  cd $REAL_HOME
}

install_qsreplace() {
  echo -e "${yellow}Installing qsreplace...${reset}"
  go install -v github.com/tomnomnom/qsreplace@latest
  mv $GOBIN/qsreplace $TERM_PATH
}

install_chaos() {
  echo -e "${green}Installing chaos...${reset}"
  go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest
  mv $GOBIN/chaos $TERM_PATH
  echo -e "${yellow}This tool requires an API key to work properly.${reset}"
}

install_alterx() {
  echo -e "${green}Installing alterx...${reset}"
  go install -v github.com/projectdiscovery/alterx/cmd/alterx@latest
  mv $GOBIN/alterx $TERM_PATH
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
    49) install_wordlists ;;
    50) install_tools_only ;;
    
    *) echo -e "${red}Invalid choice: $choice${reset}" ;;
  esac
done



# === Done ===
echo -e "${green}All tools installed successfully!${reset}"
echo -e "${yellow}Run 'source $HOME_V/.bashrc' or restart your terminal to use the aliases.${reset}"
