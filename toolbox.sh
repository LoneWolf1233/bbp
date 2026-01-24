#!/bin/bash
# === multi_installer.sh - Cleaned Automated installer for security tools and wordlists ===
# Author: Sensei Whou
# Last updated: [21-8-2025]
REAL_HOME=$(getent passwd "${SUDO_USER:-$USER}" 2>/dev/null | cut -d: -f6 || echo "$HOME")
export HOME="$REAL_HOME"
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
# Initialize GOBIN only if go is available
if command -v go >/dev/null 2>&1; then
    GOBIN=$(go env GOPATH 2>/dev/null || echo "$HOME/go")/bin
    export PATH="$PATH:$GOBIN"
else
    GOBIN="$HOME/go/bin"
    export PATH="$PATH:$GOBIN"
fi

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
total_tools=${#choices[@]}
echo "You chose $total_tools tool/s to install."


install_broken_link_checker() {
  clear
  echo -e "${green} [~] Checking if broken-link-checker is installed...${reset}"
  if command -v broken-link-checker >/dev/null 2>&1; then
    echo -e "${red} [!] Broken-link-checker already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing broken-link-checker...${reset}"
    if npm install broken-link-checker -g >/dev/null 2>&1; then
      ((num_choice++))
    fi
  fi
}
install_searchsploit() {
  clear
  echo -e "${yellow} [~] Checking if searchsploit is installed...${reset}"
  if command -v searchsploit >/dev/null 2>&1; then
    echo -e "${red} [!] Searchsploit already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing searchsploit...${reset}"
    if git clone https://www.github.com/Err0r-ICA/Searchsploit "$TOOLS_DIR/Searchsploit" 2>/dev/null; then
      cd "$TOOLS_DIR/Searchsploit" || return
      if [ -f "install.sh" ]; then
        if bash install.sh >/dev/null 2>&1; then
          ((num_choice++))
        fi
      else
        echo -e "${red} [!] install.sh not found${reset}"
      fi
      cd "$HOME" || return
    else
      echo -e "${red} [!] Failed to clone Searchsploit repository${reset}"
    fi
  fi
}

install_assetfinder() {
  clear
  echo -e "${yellow} [~] Checking if assetfinder is installed...${reset}"
  if command -v assetfinder >/dev/null 2>&1; then
    echo -e "${red} [-] Assetfinder already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing assetfinder...${reset}"
    if go install -v github.com/tomnomnom/assetfinder@latest 2>/dev/null; then
      if [ -f "$GOBIN/assetfinder" ]; then
        if sudo mv "$GOBIN/assetfinder" /usr/bin/ 2>/dev/null || cp "$GOBIN/assetfinder" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install assetfinder${reset}"
    fi
  fi
}

install_urlfinder() {
  clear
  echo -e "${yellow} [~] Checking if urlfinder is installed...${reset}"
  if command -v urlfinder >/dev/null 2>&1; then
    echo -e "${red} [-] Urlfinder already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing urlfinder...${reset}"
    if go install -v github.com/projectdiscovery/urlfinder/cmd/urlfinder@latest 2>/dev/null; then
      if [ -f "$GOBIN/urlfinder" ]; then
        if sudo mv "$GOBIN/urlfinder" /usr/bin/ 2>/dev/null || cp "$GOBIN/urlfinder" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install urlfinder${reset}"
    fi
  fi
}

install_gau() {
  clear
  echo -e "${yellow} [~] Checking if gau is installed...${reset}"
  if command -v gau >/dev/null 2>&1; then
    echo -e "${red} [-] Gau already exists. Skipping...${reset}"
  else  
    echo -e "${green}[+] Installing gau...${reset}"
    if go install -v github.com/lc/gau/v2/cmd/gau@latest 2>/dev/null; then
      if [ -f "$GOBIN/gau" ]; then
        if sudo mv "$GOBIN/gau" /usr/bin/ 2>/dev/null || cp "$GOBIN/gau" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install gau${reset}"
    fi
  fi
}

install_httpx() {
  clear
  echo -e "${yellow} [~] Checking if httpx is installed...${reset}"
  if command -v httpx >/dev/null 2>&1; then
    echo -e "${red} [-] Httpx already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing httpx...${reset}"
    if go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest 2>/dev/null; then
      if [ -f "$GOBIN/httpx" ]; then
        if sudo mv "$GOBIN/httpx" /usr/bin/ 2>/dev/null || cp "$GOBIN/httpx" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install httpx${reset}"
    fi
  fi
}

install_katana() {
  clear
  echo -e "${yellow} [~] Checking if katana is installed...${reset}"
  if command -v katana >/dev/null 2>&1; then
    echo -e "${red} [-] Katana already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing katana...${reset}"
    if go install -v github.com/projectdiscovery/katana/cmd/katana@latest 2>/dev/null; then
      if [ -f "$GOBIN/katana" ]; then
        if sudo mv "$GOBIN/katana" /usr/bin/ 2>/dev/null || cp "$GOBIN/katana" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install katana${reset}"
    fi
  fi
}

install_nuclei() {
  clear
  echo -e "${yellow} [~] Checking if nuclei is installed...${reset}"
  if command -v nuclei >/dev/null 2>&1; then
    echo -e "${red} [-] Nuclei already exists. Skipping... ${reset}"
  else
    echo -e "${green} [+] Installing nuclei...${reset}"
    if go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest 2>/dev/null; then
      if [ -f "$GOBIN/nuclei" ]; then
        if sudo mv "$GOBIN/nuclei" /usr/bin/ 2>/dev/null || cp "$GOBIN/nuclei" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install nuclei${reset}"
    fi
  fi
}

install_subfinder() {
  clear
  echo -e "${yellow} [~] Checking if subfinder is installed...${reset}"
  if command -v subfinder >/dev/null 2>&1; then
    echo -e "${red} [-] Subfinder already exists. Skipping....${reset}"
  else
    echo -e "${green}[+] Installing subfinder...${reset}"
    if go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest 2>/dev/null; then
      if [ -f "$GOBIN/subfinder" ]; then
        if sudo mv "$GOBIN/subfinder" /usr/bin/ 2>/dev/null || cp "$GOBIN/subfinder" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install subfinder${reset}"
    fi
  fi
}

install_waybackurls() {
  clear
  echo -e "${yellow} [~] Checking if waybackurls is installed... ${reset}"
  if command -v waybackurls >/dev/null 2>&1; then
    echo -e "${red} [-] Waybackurls already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing waybackurls...${reset}"
    if go install -v github.com/tomnomnom/waybackurls@latest 2>/dev/null; then
      if [ -f "$GOBIN/waybackurls" ]; then
        if sudo mv "$GOBIN/waybackurls" /usr/bin/ 2>/dev/null || cp "$GOBIN/waybackurls" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install waybackurls${reset}"
    fi
  fi
}

install_dnsx() {
  clear
  echo -e "${yellow} [~] Checking if dnsx is installed... ${reset}"
  if command -v dnsx >/dev/null 2>&1; then
    echo -e "${red} [-] Dnsx already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing dnsx...${reset}"
    if go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest 2>/dev/null; then
      if [ -f "$GOBIN/dnsx" ]; then
        if sudo mv "$GOBIN/dnsx" /usr/bin/ 2>/dev/null || cp "$GOBIN/dnsx" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install dnsx${reset}"
    fi
  fi
}

install_hakrawler() {
  clear
  echo -e "${yellow} [~] Checking if hakrawler is installed...${reset}"
  if command -v hakrawler >/dev/null 2>&1; then
    echo -e "${red} [-] Hakrawler already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing hakrawler...${reset}"
    if go install -v github.com/hakluke/hakrawler@latest 2>/dev/null; then
      if [ -f "$GOBIN/hakrawler" ]; then
        if sudo mv "$GOBIN/hakrawler" /usr/bin/ 2>/dev/null || cp "$GOBIN/hakrawler" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install hakrawler${reset}"
    fi
  fi
}

install_amass() {
  clear
  echo -e "${yellow} [~] Checking if amass is installed...${reset}"
  if command -v amass >/dev/null 2>&1; then
    echo -e "${red} [-] Amass already exists. Skipping...${reset}"
  else  
    echo -e "${green} [+] Installing amass ${reset}"
    if go install -v github.com/owasp-amass/amass/v4/...@master 2>/dev/null; then
      if [ -f "$GOBIN/amass" ]; then
        if sudo mv "$GOBIN/amass" /usr/bin/ 2>/dev/null || cp "$GOBIN/amass" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install amass${reset}"
    fi
  fi
}

install_ffuf() {
  clear
  echo -e "${yellow} [~] Checking if ffuf is installed...${reset}"
  if command -v ffuf >/dev/null 2>&1; then
    echo -e "${red} [-] Ffuf already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing ffuf...${reset}"
    if go install -v github.com/ffuf/ffuf/v2@latest 2>/dev/null; then
      if [ -f "$GOBIN/ffuf" ]; then
        if sudo mv "$GOBIN/ffuf" /usr/bin/ 2>/dev/null || cp "$GOBIN/ffuf" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install ffuf${reset}"
    fi
  fi
}

install_gobuster() {
  clear
  echo -e "${yellow} [~] Checking if gobuster is installed...${reset}"
  if command -v gobuster >/dev/null 2>&1; then 
    echo -e "${red} [-] Gobuster already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing gobuster...${reset}"
    if go install -v github.com/OJ/gobuster/v3@latest 2>/dev/null; then
      if [ -f "$GOBIN/gobuster" ]; then
        if sudo mv "$GOBIN/gobuster" /usr/bin/ 2>/dev/null || cp "$GOBIN/gobuster" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install gobuster${reset}"
    fi
  fi
}

install_dalfox() {
  clear
  echo -e "${yellow} [~] Checking if dalfox is installed...${reset}"
  if command -v dalfox >/dev/null 2>&1; then
    echo -e "${red} [-] Dalfox already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing dalfox...${reset}"
    if go install -v github.com/hahwul/dalfox/v2@latest 2>/dev/null; then
      if [ -f "$GOBIN/dalfox" ]; then
        if sudo mv "$GOBIN/dalfox" /usr/bin/ 2>/dev/null || cp "$GOBIN/dalfox" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install dalfox${reset}"
    fi
  fi
}

install_asnmap() {
  clear
  echo -e "${yellow} [~] Checking if asnmap is installed...${reset}"
  if command -v asnmap >/dev/null 2>&1; then
    echo -e "${red} [-] Asnmap already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing asnmap...${reset}"
    if go install -v github.com/projectdiscovery/asnmap/cmd/asnmap@latest 2>/dev/null; then
      if [ -f "$GOBIN/asnmap" ]; then
        if sudo mv "$GOBIN/asnmap" /usr/bin/ 2>/dev/null || cp "$GOBIN/asnmap" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install asnmap${reset}"
    fi
  fi
}

install_recx() {
  clear
  echo -e "${yellow} [~] Checking if recx is installed...${reset}"
  if command -v recx >/dev/null 2>&1; then
    echo -e "${red} [-] Recx already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing recx...${reset}"
    if go install github.com/1hehaq/recx@latest 2>/dev/null; then
      if [ -f "$GOBIN/recx" ]; then
        if sudo mv "$GOBIN/recx" /usr/bin/ 2>/dev/null || cp "$GOBIN/recx" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install recx${reset}"
    fi
  fi
}

install_kxss() {
  clear
  echo -e "${yellow} [~] Checking if kxss is installed...${reset}"
  if command -v kxss >/dev/null 2>&1; then
    echo -e "${red} [-] Kxss already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing kxss...${reset}"
    if go install -v github.com/Emoe/kxss@latest 2>/dev/null; then
      if [ -f "$GOBIN/kxss" ]; then
        if sudo mv "$GOBIN/kxss" /usr/bin/ 2>/dev/null || cp "$GOBIN/kxss" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install kxss${reset}"
    fi
  fi
}

install_subzy() {
  clear
  echo -e "${yellow} [~] Checking if subzy is installed...${reset}"
  if command -v subzy >/dev/null 2>&1; then
    echo -e "${red} [-] Subzy already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing subzy...${reset}"
    if go install -v github.com/PentestPad/subzy@latest 2>/dev/null; then
      if [ -f "$GOBIN/subzy" ]; then
        if sudo mv "$GOBIN/subzy" /usr/bin/ 2>/dev/null || cp "$GOBIN/subzy" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install subzy${reset}"
    fi
  fi
}

install_s3scanner() {
  clear
  echo -e "${yellow} [~] Checking if s3scanner is installed...${reset}"
  if command -v s3scanner >/dev/null 2>&1; then
    echo -e "${red} [-] S3scanner already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing s3scanner...${reset}"
    if go install -v github.com/sa7mon/s3scanner@latest 2>/dev/null; then
      if [ -f "$GOBIN/s3scanner" ]; then
        if sudo mv "$GOBIN/s3scanner" /usr/bin/ 2>/dev/null || cp "$GOBIN/s3scanner" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install s3scanner${reset}"
    fi
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
    if git clone https://github.com/vladko312/SSTImap.git "$TOOLS_DIR/SSTImap" 2>/dev/null; then
      # Install dependencies
      if [ -f "$PYTHON_VENV/sstimap/bin/activate" ]; then
        # shellcheck source=/dev/null
        source "$PYTHON_VENV/sstimap/bin/activate"
        if pip install -r "$TOOLS_DIR/SSTImap/requirements.txt" >/dev/null 2>&1; then
          ((num_choice++))
        fi
        deactivate 2>/dev/null || true
      fi
    else
      echo -e "${red} [!] Failed to clone SSTImap repository${reset}"
    fi
  fi 
}


install_shortscan() {
  clear
  echo -e "${yellow} [~] Checking if shortscan is installed...${reset}"
  if command -v shortscan >/dev/null 2>&1; then
    echo -e "${red} [-] Shortscan already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing shortscan...${reset}"
    if go install -v github.com/bitquark/shortscan/cmd/shortscan@latest 2>/dev/null; then
      if [ -f "$GOBIN/shortscan" ]; then
        if sudo mv "$GOBIN/shortscan" /usr/bin/ 2>/dev/null || cp "$GOBIN/shortscan" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install shortscan${reset}"
    fi
  fi
}

install_gxss() {
  clear
  echo -e "${yellow} [~] Checking if gxss is installed...${reset}"
  if command -v gxss >/dev/null 2>&1; then
    echo -e "${red} [-] GXSS already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing gxss...${reset}"
    if go install -v github.com/KathanP19/Gxss@latest 2>/dev/null; then
      # The binary might be named Gxss or gxss depending on the repo
      if [ -f "$GOBIN/Gxss" ]; then
        if sudo mv "$GOBIN/Gxss" /usr/bin/gxss 2>/dev/null || cp "$GOBIN/Gxss" "$HOME/.local/bin/gxss" 2>/dev/null; then
          ((num_choice++))
        fi
      elif [ -f "$GOBIN/gxss" ]; then
        if sudo mv "$GOBIN/gxss" /usr/bin/ 2>/dev/null || cp "$GOBIN/gxss" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install gxss${reset}"
    fi
  fi
}

install_crlfuzz(){
  clear
  echo -e "${yellow} [~] Checking if crlfuzz is installed...${reset}"
  if command -v crlfuzz >/dev/null 2>&1; then
    echo -e "${red} [-] CRLfuzz already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing crlfuzz...${reset}"
    if go install -v github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest 2>/dev/null; then
      if [ -f "$GOBIN/crlfuzz" ]; then
        if sudo mv "$GOBIN/crlfuzz" /usr/bin/ 2>/dev/null || cp "$GOBIN/crlfuzz" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install crlfuzz${reset}"
    fi
  fi
}

install_trufflehog(){
  clear
  echo -e "${yellow} [~] Checking if trufflehog is installed...${reset}"
  if command -v trufflehog >/dev/null 2>&1; then
    echo -e "${red} [-] Trufflehog already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing Trufflehog...${reset}"
    if curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin >/dev/null 2>&1; then
      ((num_choice++))
    else
      echo -e "${red} [!] Failed to install trufflehog${reset}"
    fi
  fi
}

install_gf_patterns(){
  clear
  echo -e "${yellow} [~] Checking if gf (command/binary) is installed...${reset}"
  if command -v gf >/dev/null 2>&1; then
    echo -e "${red} [-] Gf command already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing gf...${reset}"
    if go install github.com/tomnomnom/gf@latest 2>/dev/null; then
      if [ -f "$GOBIN/gf" ]; then
        if sudo mv "$GOBIN/gf" /usr/bin/ 2>/dev/null || cp "$GOBIN/gf" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install gf${reset}"
    fi
  fi
  echo -e "${yellow} [~] Checking if gf-patterns (wordlist/patterns) exists...${reset}"
  if [ -d "$HOME/.gf" ] && [ "$(ls -A "$HOME/.gf" 2>/dev/null)" ]; then
    echo -e "${red}[-] Gf-Patterns already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing Gf-Patterns...${reset}"
    mkdir -p "$HOME/.gf"
    echo -e "${green}Downloading gf patterns...${reset}"
    if git clone https://github.com/coffinxp/GFpattren.git "$WORDLIST_DIR/Gf-Patterns" 2>/dev/null; then
      if [ -d "$WORDLIST_DIR/Gf-Patterns" ]; then
        # Copy JSON files if they exist
        if ls "$WORDLIST_DIR/Gf-Patterns"/*.json >/dev/null 2>&1; then
          cp "$WORDLIST_DIR/Gf-Patterns"/*.json "$HOME/.gf/" 2>/dev/null || true
        fi
        # Add completions if file exists
        if [ -f "$HOME/.gf/gf-completions.bash" ]; then
          if ! grep -qF "gf-completions.bash" "$HOME/.bashrc" 2>/dev/null; then
            echo "source \$HOME/.gf/gf-completions.bash" >> "$HOME/.bashrc"
          fi
        fi
      fi
    else
      echo -e "${red} [!] Failed to clone GF patterns repository${reset}"
    fi
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
    if git clone https://github.com/s0md3v/XSStrike "$TOOLS_DIR/XSStrike" 2>/dev/null; then
      # Install dependencies
      if [ -f "$PYTHON_VENV/xsstrike/bin/activate" ]; then
        # shellcheck source=/dev/null
        source "$PYTHON_VENV/xsstrike/bin/activate"
        if pip install -r "$TOOLS_DIR/XSStrike/requirements.txt" >/dev/null 2>&1; then
          ((num_choice++))
        fi
        deactivate 2>/dev/null || true
      fi
    else
      echo -e "${red} [!] Failed to clone XSStrike repository${reset}"
    fi
  fi 
}

install_wafw00f() {
  clear
  echo -e "${yellow}[~] Checking if wafw00f is installed... ${reset}"
  if command -v wafw00f >/dev/null 2>&1; then
    echo -e "${red}[-] Wafw00f already exists. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing wafw00f...${reset}"
    if sudo apt-get install -y wafw00f >/dev/null 2>&1; then
      ((num_choice++))
    else
      echo -e "${red} [!] Failed to install wafw00f${reset}"
    fi
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
    if git clone https://github.com/s0md3v/Bolt "$TOOLS_DIR/Bolt" 2>/dev/null; then
      # Install dependencies
      if [ -f "$PYTHON_VENV/csrfscan/bin/activate" ]; then
        # shellcheck source=/dev/null
        source "$PYTHON_VENV/csrfscan/bin/activate"
        if pip install -r "$TOOLS_DIR/Bolt/requirements.txt" >/dev/null 2>&1; then
          ((num_choice++))
        fi
        deactivate 2>/dev/null || true
      fi
    else
      echo -e "${red} [!] Failed to clone CSRFscan repository${reset}"
    fi
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
    if git clone https://github.com/swisskyrepo/SSRFmap "$TOOLS_DIR/SSRFmap" 2>/dev/null; then
      # Install dependencies
      if [ -f "$PYTHON_VENV/ssrfmap/bin/activate" ]; then
        # shellcheck source=/dev/null
        source "$PYTHON_VENV/ssrfmap/bin/activate"
        if pip install -r "$TOOLS_DIR/SSRFmap/requirements.txt" >/dev/null 2>&1; then
          ((num_choice++))
        fi
        deactivate 2>/dev/null || true
      fi
    else
      echo -e "${red} [!] Failed to clone SSRFmap repository${reset}"
    fi
  fi
}

install_dirsearch() {
  clear
  echo -e "${yellow}[~] Checking if Dirsearch VENV exists...${reset}"
  # VENV check
  if [ -d "$PYTHON_VENV/dirsearch" ] && [ "$(ls -A "$PYTHON_VENV/dirsearch" 2>/dev/null)" ]; then
    echo -e "${red}[-] VENV already exists. Skipping creation...${reset}"
  else
    echo -e "${green}[+] Creating VENV...${reset}"
    python3 -m venv "$PYTHON_VENV/dirsearch" 2>/dev/null || {
      echo -e "${red} [!] Failed to create VENV${reset}"
      return
    }
  fi
  # Tool check
  echo -e "${yellow} [~] Checking if Dirsearch is installed...${reset}"
  if [ -d "$TOOLS_DIR/dirsearch" ] && [ "$(ls -A "$TOOLS_DIR/dirsearch" 2>/dev/null)" ]; then
    echo -e "${red}[-] Dirsearch already exists. Skipping clone...${reset}"
  else
    echo -e "${green}[+] Installing Dirsearch...${reset}"
    if git clone https://github.com/maurosoria/dirsearch "$TOOLS_DIR/dirsearch" 2>/dev/null; then
      # Install dependencies
      if [ -f "$PYTHON_VENV/dirsearch/bin/activate" ]; then
        # shellcheck source=/dev/null
        source "$PYTHON_VENV/dirsearch/bin/activate"
        if [ -f "$TOOLS_DIR/dirsearch/requirements.txt" ]; then
          if pip install -r "$TOOLS_DIR/dirsearch/requirements.txt" >/dev/null 2>&1; then
            ((num_choice++))
          fi
        fi
        deactivate 2>/dev/null || true
      fi
    else
      echo -e "${red} [!] Failed to clone dirsearch repository${reset}"
    fi
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
    if git clone https://github.com/s0md3v/Corsy "$TOOLS_DIR/Corsy" 2>/dev/null; then
      # Install dependencies
      if [ -f "$PYTHON_VENV/corsy/bin/activate" ]; then
        # shellcheck source=/dev/null
        source "$PYTHON_VENV/corsy/bin/activate"
        if pip install -r "$TOOLS_DIR/Corsy/requirements.txt" >/dev/null 2>&1; then
          ((num_choice++))
        fi
        deactivate 2>/dev/null || true
      fi
    else
      echo -e "${red} [!] Failed to clone Corsy repository${reset}"
    fi
  fi
}

install_linkfinder() {
  clear
  echo -e "${yellow}[~] Checking if Linkfinder VENV exists...${reset}"
  # VENV check
  if [ -d "$PYTHON_VENV/linkfinder" ] && [ "$(ls -A "$PYTHON_VENV/linkfinder" 2>/dev/null)" ]; then
    echo -e "${red}[-] VENV already exists. Skipping creation...${reset}"
  else
    echo -e "${green}[+] Creating VENV...${reset}"
    python3 -m venv "$PYTHON_VENV/linkfinder" 2>/dev/null || {
      echo -e "${red} [!] Failed to create VENV${reset}"
      return
    }
  fi
  # Tool check
  local linkfinder_alias="alias linkfinder=\"$PYTHON_VENV/linkfinder/bin/python -m linkfinder\""
  if grep -qF "linkfinder" "$REAL_HOME/.bashrc" 2>/dev/null; then
    echo -e "${red}[-] Linkfinder already exists. Skipping installation...${reset}"
  else
    echo -e "${green}[+] Installing linkfinder...${reset}"
    if [ -f "$PYTHON_VENV/linkfinder/bin/activate" ]; then
      # shellcheck source=/dev/null
      source "$PYTHON_VENV/linkfinder/bin/activate"
      pip install --upgrade pip setuptools >/dev/null 2>&1 || true
      if pip install git+https://github.com/GerbenJavado/LinkFinder.git >/dev/null 2>&1; then
        echo "$linkfinder_alias" >> "$REAL_HOME/.bashrc"
        echo -e "${green}[+] Linkfinder installed successfully${reset}"
        ((num_choice++))
      else
        echo -e "${red} [!] Failed to install linkfinder${reset}"
      fi
      deactivate 2>/dev/null || true
    fi
  fi
}

install_wapiti() {
  clear
  echo -e "${yellow} [+] Checking if wapiti is installed...${reset}"
  if command -v wapiti >/dev/null 2>&1; then
    echo -e "${yellow}[!] Wapiti already exists. Skipping...${reset}"
  else
    echo -e "${green}Installing Wapiti...${reset}"
    if command -v pipx >/dev/null 2>&1; then
      if pipx install wapiti3 2>/dev/null; then
        ((num_choice++))
      else
        echo -e "${red} [!] Failed to install wapiti3 with pipx. Trying pip...${reset}"
        if pip install wapiti3 2>/dev/null; then
          ((num_choice++))
        else
          echo -e "${red} [!] Failed to install wapiti3${reset}"
        fi
      fi
    else
      if pip install wapiti3 2>/dev/null; then
        ((num_choice++))
      else
        echo -e "${red} [!] Failed to install wapiti3${reset}"
      fi
    fi
  fi
}

install_paramspider(){
  clear
  echo -e "${yellow} [~] Checking if paramspider is installed...${reset}"
  if [ -d "$TOOLS_DIR/paramspider" ] && [ "$(ls -A "$TOOLS_DIR/paramspider" 2>/dev/null)" ]; then
    echo -e "${red} [-] Paramspider is already installed. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing Paramspider...${reset}"
    if git clone https://github.com/devanshbatham/paramspider "$TOOLS_DIR/paramspider" 2>/dev/null; then
      # Paramspider can be run directly with python, or install via pip
      if command -v pipx >/dev/null 2>&1; then
        # Try to install as editable package if setup.py exists
        if [ -f "$TOOLS_DIR/paramspider/setup.py" ]; then
          if pipx install -e "$TOOLS_DIR/paramspider" 2>/dev/null; then
            ((num_choice++))
          else
            # Fallback: create alias
            echo "alias paramspider=\"python3 $TOOLS_DIR/paramspider/paramspider.py\"" >> "$HOME/.bashrc"
            ((num_choice++))
          fi
        else
          # Create alias if no setup.py
          echo "alias paramspider=\"python3 $TOOLS_DIR/paramspider/paramspider.py\"" >> "$HOME/.bashrc"
          ((num_choice++))
        fi
      else
        # Create alias if pipx not available
        echo "alias paramspider=\"python3 $TOOLS_DIR/paramspider/paramspider.py\"" >> "$HOME/.bashrc"
        ((num_choice++))
      fi
    else
      echo -e "${red} [!] Failed to clone paramspider repository${reset}"
    fi
  fi
}

install_sqlmap() {
  clear
  echo -e "${yellow} [~] Checking if SQLmap is installed...${reset}"
  if [ -d "$TOOLS_DIR/sqlmap" ] && [ "$(ls -A "$TOOLS_DIR/sqlmap" 2>/dev/null)" ]; then
    echo -e "${red} [-] SQLmap is already installed. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing SQLmap...${reset}"
    if git clone https://github.com/sqlmapproject/sqlmap "$TOOLS_DIR/sqlmap" 2>/dev/null; then
      if [ -f "$TOOLS_DIR/sqlmap/sqlmap.py" ]; then
        if ! grep -qF "sqlmap" "$HOME/.bashrc" 2>/dev/null; then
          echo "alias sqlmap=\"python3 $TOOLS_DIR/sqlmap/sqlmap.py\"" >> "$HOME/.bashrc"
        fi
        ((num_choice++))
      fi
    else
      echo -e "${red} [!] Failed to clone sqlmap repository${reset}"
    fi
  fi
}

install_arjun() {
  clear
  echo -e "${yellow}[~] Checking if arjun is installed...${reset}"
  if command -v arjun >/dev/null 2>&1; then
    echo -e "${red} [-] Arjun already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing Arjun...${reset}"
    if command -v pipx >/dev/null 2>&1; then
      if pipx install arjun 2>/dev/null; then
        ((num_choice++))
      else
        echo -e "${red} [!] Failed to install arjun with pipx. Trying pip...${reset}"
        if pip install arjun 2>/dev/null; then
          ((num_choice++))
        else
          echo -e "${red} [!] Failed to install arjun${reset}"
        fi
      fi
    else
      if pip install arjun 2>/dev/null; then
        ((num_choice++))
      else
        echo -e "${red} [!] Failed to install arjun${reset}"
      fi
    fi
  fi
}

install_uro() {
  clear
  echo -e "${yellow} [~] Checking if uro is installed...${reset}"
  if command -v uro >/dev/null 2>&1; then
    echo -e "${red} [-] Uro is already installed. Skipping...${reset}"
  else
    echo -e "${green}[+] Installing uro...${reset}"
    if command -v pipx >/dev/null 2>&1; then
      if pipx install uro 2>/dev/null; then
        ((num_choice++))
      else
        echo -e "${red} [!] Failed to install uro with pipx. Trying pip...${reset}"
        if pip install uro 2>/dev/null; then
          ((num_choice++))
        else
          echo -e "${red} [!] Failed to install uro${reset}"
        fi
      fi
    else
      if pip install uro 2>/dev/null; then
        ((num_choice++))
      else
        echo -e "${red} [!] Failed to install uro${reset}"
      fi
    fi
  fi
}

install_nikto() {
  clear
  echo -e "${yellow} [~] Checking if nikto is installed...${reset}"
  if [ -d "$TOOLS_DIR/nikto" ] && [ "$(ls -A "$TOOLS_DIR/nikto" 2>/dev/null)" ]; then
    echo -e "${red} [-] Nikto already exists, skipping...${reset}"
  else
    echo -e "${green} [+] Installing nikto...${reset}"
    if git clone https://github.com/sullo/nikto "$TOOLS_DIR/nikto" 2>/dev/null; then
      if [ -f "$TOOLS_DIR/nikto/program/nikto.pl" ]; then
        if ! grep -qF "nikto" "$REAL_HOME/.bashrc" 2>/dev/null; then
          echo "alias nikto=\"perl $TOOLS_DIR/nikto/program/nikto.pl\"" >> "$REAL_HOME/.bashrc"
        fi
        ((num_choice++))
      fi
    else
      echo -e "${red} [!] Failed to clone nikto repository${reset}"
    fi
  fi
}

install_nmap() {
  clear
  echo -e "${yellow} [~] Checking if nmap is installed...${reset}"
  if command -v nmap >/dev/null 2>&1; then
    echo -e "${red} [-] Nmap already exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing nmap...${reset}"
    if sudo apt install -y nmap >/dev/null 2>&1; then
      ((num_choice++))
    else
      echo -e "${red} [!] Failed to install nmap${reset}"
    fi
  fi
}

install_massdns() {
  clear
  echo -e "${yellow} [~] Checking if massdns is installed...${reset}"
  if command -v massdns >/dev/null 2>&1; then
    echo -e "${red} [-] Massdns already exists. Skipping...${reset}"
  else
    echo -e "${yellow} [+] Installing massdns...${reset}"
    if git clone https://github.com/blechschmidt/massdns.git "$TOOLS_DIR/massdns" 2>/dev/null; then
      cd "$TOOLS_DIR/massdns" || return
      if make >/dev/null 2>&1; then
        # Try to install to system or local bin
        if [ -f "bin/massdns" ]; then
          if sudo cp "bin/massdns" /usr/bin/ 2>/dev/null || cp "bin/massdns" "$HOME/.local/bin/" 2>/dev/null; then
            ((num_choice++))
          fi
        fi
      else
        echo -e "${red} [!] Failed to build massdns${reset}"
      fi
      cd "$HOME" || return
    else
      echo -e "${red} [!] Failed to clone massdns repository${reset}"
    fi
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
    if git clone https://github.com/m4ll0k/SecretFinder.git "$TOOLS_DIR/secretfinder" 2>/dev/null; then
      if [ -f "$PYTHON_VENV/secretfinder/bin/activate" ]; then
        # shellcheck source=/dev/null
        source "$PYTHON_VENV/secretfinder/bin/activate"
        if pip install -r "$TOOLS_DIR/secretfinder/requirements.txt" >/dev/null 2>&1; then
          ((num_choice++))
        fi
        deactivate 2>/dev/null || true
      fi
    else
      echo -e "${red} [!] Failed to clone SecretFinder repository${reset}"
    fi
  fi
}

install_masscan() {
  clear
  echo -e "${yellow} [~] Checking if masscan is already installed...${reset}"
  if command -v masscan >/dev/null 2>&1; then
    echo -e "${red} [-] Masscan is installed. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing masscan...${reset}"
    if git clone https://github.com/robertdavidgraham/masscan "$TOOLS_DIR/masscan" 2>/dev/null; then
      cd "$TOOLS_DIR/masscan" || return
      if make >/dev/null 2>&1; then
        if sudo make install >/dev/null 2>&1; then
          ((num_choice++))
        else
          # Fallback: copy to local bin
          if [ -f "masscan" ]; then
            if sudo cp "masscan" /usr/bin/ 2>/dev/null || cp "masscan" "$HOME/.local/bin/" 2>/dev/null; then
              ((num_choice++))
            fi
          fi
        fi
      else
        echo -e "${red} [!] Failed to build masscan${reset}"
      fi
      cd "$REAL_HOME" || return
    else
      echo -e "${red} [!] Failed to clone masscan repository${reset}"
    fi
  fi
}

install_qsreplace() {
  clear
  echo -e "${yellow} [~] Checking if qsreplace is installed...${reset}"
  if command -v qsreplace >/dev/null 2>&1; then
    echo -e "${red} [-] Qsreplace is installed. Skipping...${reset}" 
  else
    echo -e "${green} [+] Installing qsreplace...${reset}"
    if go install -v github.com/tomnomnom/qsreplace@latest 2>/dev/null; then
      if [ -f "$GOBIN/qsreplace" ]; then
        if sudo mv "$GOBIN/qsreplace" /usr/bin/ 2>/dev/null || cp "$GOBIN/qsreplace" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install qsreplace${reset}"
    fi
  fi
}

install_chaos() {
  clear
  echo -e "${yellow} [~] Checking if chaos is installed...${reset}"
  if command -v chaos >/dev/null 2>&1; then
    echo -e "${red} [-] Chaos is installed. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing chaos...${reset}"
    if go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest 2>/dev/null; then
      if [ -f "$GOBIN/chaos" ]; then
        if sudo mv "$GOBIN/chaos" /usr/bin/ 2>/dev/null || cp "$GOBIN/chaos" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install chaos${reset}"
    fi
    echo -e "${yellow} [~] This tool requires an API key to work properly.${reset}"
  fi
}

install_alterx() {
  clear
  echo -e "${yellow} [~] Checking if alterx is installed...${reset}"
  if command -v alterx >/dev/null 2>&1; then
    echo -e "${red} [-] AlterX is installed. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing alterx...${reset}"
    if go install -v github.com/projectdiscovery/alterx/cmd/alterx@latest 2>/dev/null; then
      if [ -f "$GOBIN/alterx" ]; then
        if sudo mv "$GOBIN/alterx" /usr/bin/ 2>/dev/null || cp "$GOBIN/alterx" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install alterx${reset}"
    fi
  fi
}

install_dnsgen() {
  clear
  echo -e "${yellow} [~] Checking if dnsgen VENV exists....${reset}"
  if [ -d "$PYTHON_VENV/dnsgen" ] && [ "$(ls -A "$PYTHON_VENV/dnsgen" 2>/dev/null)" ]; then 
    echo -e "${red} [-] DnsGen VENV exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Creating VENV... ${reset}"
    python3 -m venv "$PYTHON_VENV/dnsgen" 2>/dev/null || {
      echo -e "${red} [!] Failed to create VENV${reset}"
      return
    }
  fi
  echo -e "${yellow} [~] Checking if dnsgen is installed...${reset}"
  if [ -f "$PYTHON_VENV/dnsgen/bin/activate" ]; then
    # shellcheck source=/dev/null
    source "$PYTHON_VENV/dnsgen/bin/activate"
    if command -v dnsgen >/dev/null 2>&1; then
      echo -e "${red} [-] DnsGen exists. Skipping...${reset}"
      deactivate 2>/dev/null || true
    else
      echo -e "${green} [+] Installing DNSgen${reset}"
      if python3 -m pip install dnsgen >/dev/null 2>&1; then
        echo -e "${green}[+] DNSgen installed successfully${reset}"
        ((num_choice++))
      else
        echo -e "${red} [!] Failed to install dnsgen${reset}"
      fi
      deactivate 2>/dev/null || true
    fi
  fi
}

install_gotator() {
  clear
  echo -e "${yellow} [~] Checking if gotator is installed...${reset}"
  if command -v gotator >/dev/null 2>&1; then
    echo -e "${red} [-] Gotator exists. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing Gotator...${reset}"
    if go install -v github.com/Josue87/gotator@latest 2>/dev/null; then
      if [ -f "$GOBIN/gotator" ]; then
        if sudo mv "$GOBIN/gotator" /usr/bin/ 2>/dev/null || cp "$GOBIN/gotator" "$HOME/.local/bin/" 2>/dev/null; then
          ((num_choice++))
        fi
      fi
    else
      echo -e "${red} [!] Failed to install gotator${reset}"
    fi
  fi
}

install_urlscan() {
  clear
  echo -e "${yellow} [~] Checking if urlscan is installed...${reset}"
  if [ -f "$TOOLS_DIR/urlscan.py" ]; then
    echo -e "${red} [-] Urlscan is already installed. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing urlscan...${reset}"
    cd "$TOOLS_DIR" || return
    # Use raw GitHub URL for direct download
    if wget -q "https://raw.githubusercontent.com/coffinxp/scripts/main/urlscan.py" -O "$TOOLS_DIR/urlscan.py" 2>/dev/null || \
       curl -sL "https://raw.githubusercontent.com/coffinxp/scripts/main/urlscan.py" -o "$TOOLS_DIR/urlscan.py" 2>/dev/null; then
      chmod +x "$TOOLS_DIR/urlscan.py" 2>/dev/null || true
      echo -e "${yellow}REMINDER! This tool requires a URLscan API key to function properly. Please add it to urlscan.py. ${reset}"
      ((num_choice++))
    else
      echo -e "${red} [!] Failed to download urlscan.py${reset}"
    fi
    cd "$HOME" || return
  fi
}

install_virustotal_urls() {
  clear
  echo -e "${yellow} [~] Checking if VirusTotal-URLs is installed...${reset}"
  if [ -f "$TOOLS_DIR/virustotal.sh" ]; then
    echo -e "${red} [-] VirusTotal-URLs is installed...${reset}"
  else
    echo -e "${green} [+] Installing VirusTotal-URLs...${reset}"
    cd "$TOOLS_DIR" || return
    # Use raw GitHub URL for direct download
    if wget -q "https://raw.githubusercontent.com/coffinxp/scripts/main/virustotal.sh" -O "$TOOLS_DIR/virustotal.sh" 2>/dev/null || \
       curl -sL "https://raw.githubusercontent.com/coffinxp/scripts/main/virustotal.sh" -o "$TOOLS_DIR/virustotal.sh" 2>/dev/null; then
      chmod +x "$TOOLS_DIR/virustotal.sh" 2>/dev/null || true
      echo -e "${yellow}REMINDER! This tool requires THREE VirusTotal API keys to function properly. Please add them to virustotal.sh.${reset}"
      ((num_choice++))
    else
      echo -e "${red} [!] Failed to download virustotal.sh${reset}"
    fi
    cd "$HOME" || return
  fi
}

install_4_ZERO_3() {
  clear
  echo -e "${yellow} [~] Checking if 4-ZERO-3 is installed...${reset}"
  if [ -f "$TOOLS_DIR/4-ZERO-3/403-bypass.sh" ]; then
    echo -e "${red} [-] 4-ZERO-3 is installed. Skipping...${reset}"
  else
    echo -e "${green} [+] Installing 4-ZERO-3...${reset}"
    if git clone https://github.com/Dheerajmadhukar/4-ZERO-3.git "$TOOLS_DIR/4-ZERO-3" 2>/dev/null; then
      ((num_choice++))
    else
      echo -e "${red} [!] Failed to clone 4-ZERO-3 repository${reset}"
    fi
  fi
}


install_wordlists() {
  clear
  echo -e "${yellow} [+] Downloading wordlists...${reset}"
  local wordlist_count=0
  if [ -d "$WORDLIST_DIR/SecLists" ] && [ "$(ls -A "$WORDLIST_DIR/SecLists" 2>/dev/null)" ]; then
    echo -e "${red} [-] Seclists already exists. Skipping...${reset}"
    ((wordlist_count++))
  else
    echo -e "${green} [+] Downloading SecLists...${reset}"
    if git clone https://github.com/danielmiessler/SecLists.git "$WORDLIST_DIR/SecLists" 2>/dev/null; then
      ((wordlist_count++))
    else
      echo -e "${red} [!] Failed to clone SecLists${reset}"
    fi
  fi
  if [ -d "$WORDLIST_DIR/payloads" ] && [ "$(ls -A "$WORDLIST_DIR/payloads" 2>/dev/null)" ]; then
    echo -e "${red} [-] Coffin's Payloads already exist. Skipping...${reset}"
    ((wordlist_count++))
  else
    echo -e "${green} [+] Downloading Coffin's Payloads...${reset}"
    if git clone https://github.com/coffinxp/payloads.git "$WORDLIST_DIR/payloads" 2>/dev/null; then
      ((wordlist_count++))
    else
      echo -e "${red} [!] Failed to clone payloads${reset}"
    fi
  fi
  if [ -d "$WORDLIST_DIR/fuzzdb" ] && [ "$(ls -A "$WORDLIST_DIR/fuzzdb" 2>/dev/null)" ]; then
    echo -e "${red} [-] FuzzDB already exists. Skipping...${reset}"
    ((wordlist_count++))
  else
    echo -e "${green} [+] Downloading FuzzDB...${reset}"
    if git clone https://github.com/fuzzdb-project/fuzzdb.git "$WORDLIST_DIR/fuzzdb" 2>/dev/null; then
      ((wordlist_count++))
    else
      echo -e "${red} [!] Failed to clone fuzzdb${reset}"
    fi
  fi
  if [ -d "$WORDLIST_DIR/PayloadsAllTheThings" ] && [ "$(ls -A "$WORDLIST_DIR/PayloadsAllTheThings" 2>/dev/null)" ]; then
    echo -e "${red} [-] PayloadsAllTheThings already exists. Skipping...${reset}"
    ((wordlist_count++))
  else
    echo -e "${green} [+] Downloading PayloadsAllTheThings...${reset}"
    if git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git "$WORDLIST_DIR/PayloadsAllTheThings" 2>/dev/null; then
      ((wordlist_count++))
    else
      echo -e "${red} [!] Failed to clone PayloadsAllTheThings${reset}"
    fi
  fi
  if [ -d "$WORDLIST_DIR/OneListForAll" ] && [ "$(ls -A "$WORDLIST_DIR/OneListForAll" 2>/dev/null)" ]; then
    echo -e "${red} [-] OneListForAll already exists. Skipping...${reset}"
    ((wordlist_count++))
  else
    echo -e "${green} [+] Downloading OneListForAll...${reset}"
    if git clone https://github.com/six2dez/OneListForAll "$WORDLIST_DIR/OneListForAll" 2>/dev/null; then
      ((wordlist_count++))
    else
      echo -e "${red} [!] Failed to clone OneListForAll${reset}"
    fi
  fi
  if [ -d "$WORDLIST_DIR/dirb" ] && [ "$(ls -A "$WORDLIST_DIR/dirb" 2>/dev/null)" ]; then
    echo -e "${red} [-] Dirb already exists. Skipping...${reset}"
    ((wordlist_count++))
  else
    echo -e "${green} [+] Downloading Dirb...${reset}"
    if git clone https://github.com/v0re/dirb.git "$WORDLIST_DIR/dirb" 2>/dev/null; then
      ((wordlist_count++))
    else
      echo -e "${red} [!] Failed to clone dirb${reset}"
    fi
  fi
  # Increment main counter once for wordlists option
  if [ $wordlist_count -gt 0 ]; then
    ((num_choice++))
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
