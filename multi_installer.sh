#!/bin/bash
# === multi_installer.sh - Cleaned Automated installer for security tools and wordlists ===
# Author: Lone Wolf
# Last updated: [17-6-2025]

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
GOBIN=$(go env GOPATH)/bin
export PATH="$PATH:$GOBIN"

mkdir -p "$WORDLIST_DIR" "$TOOLS_DIR" "$PYTHON_VENV"

# === Update System ===
echo -e "${green}Updating and upgrading your OS...${reset}"
sudo apt update -y && sudo apt upgrade -y

# === Install Dependencies ===
echo -e "${green}Installing dependencies...${reset}"
sudo apt install -y python3 python3-pip pipx golang-go git wget unzip perl curl nmap npm nodejs
pipx ensurepath

# === Install broken-link-checker ===
echo -e "${green}Installing broken-link-checker...${reset}"
npm install broken-link-checker -g

# === Install Go Tools ===
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
  [Gxss]="github.com/KathanP19/Gxss@latest"
  [crlfuzz]="github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest"
)

echo -e "${yellow}Installing Go-based tools...${reset}"
for tool in "${!go_tools[@]}"; do
  echo -e "${green}Installing $tool...${reset}"
  go install -v "${go_tools[$tool]}"
  sudo mv -f "$GOBIN/$tool" /usr/bin/ 2>/dev/null || true
done

# === Trufflehog ===
echo -e "${green}Installing Trufflehog...${reset}"
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin

# === gf & patterns ===
echo -e "${green}Installing gf...${reset}"
go install github.com/tomnomnom/gf@latest
mkdir -p $HOME/.gf

echo -e "${green}Downloading gf patterns...${reset}"
git clone https://github.com/1ndianl33t/Gf-Patterns.git "$WORDLIST_DIR/Gf-Patterns"
cp "$WORDLIST_DIR/Gf-Patterns"/*.json $HOME/.gf/
echo 'source $HOME/.gf/gf-completions.bash' >> $HOME/.bashrc

# === Python Tools ===
install_python_tool() {
  TOOL_REPO=$1
  TOOL_DIR_NAME=$2
  ENV_NAME=$3
  echo -e "${green}Installing $TOOL_DIR_NAME...${reset}"
  git clone "$TOOL_REPO" "$TOOLS_DIR/$TOOL_DIR_NAME"
  python3 -m venv "$PYTHON_VENV/$ENV_NAME"
  source "$PYTHON_VENV/$ENV_NAME/bin/activate"
  pip install -r "$TOOLS_DIR/$TOOL_DIR_NAME/requirements.txt" 2>/dev/null || pip install "$TOOLS_DIR/$TOOL_DIR_NAME"
  deactivate
}

install_python_tool https://github.com/s0md3v/XSStrike XSStrike xsstrike
install_python_tool https://github.com/EnableSecurity/wafw00f wafw00f wafw00f
install_python_tool https://github.com/s0md3v/Bolt Bolt csrfscan
install_python_tool https://github.com/swisskyrepo/SSRFmap SSRFmap ssrfmap
install_python_tool https://github.com/maurosoria/dirsearch dirsearch dirsearch
install_python_tool https://github.com/s0md3v/Corsy Corsy corsy

# Wapiti
echo -e "${green}Installing Wapiti...${reset}"
pipx install wapiti3 || echo -e "${red}Wapiti may already be installed.${reset}"

#Dirsearch
cd "$TOOLS_DIR/dirsearch"
python3 setup.py install
rm -rf .git

# === Paramspider ===
echo -e "${yellow}Installing Paramspider...${reset}"
if [ ! -d "$TOOLS_DIR/paramspider" ]; then
  git clone https://github.com/devanshbatham/paramspider "$TOOLS_DIR/paramspider"
  pipx install "$TOOLS_DIR/paramspider"
fi

# === SQLmap ===
echo -e "${yellow}Installing SQLmap...${reset}"
if [ ! -d "$TOOLS_DIR/sqlmap" ]; then
  git clone https://github.com/sqlmapproject/sqlmap "$TOOLS_DIR/sqlmap"
  echo 'alias sqlmap="python3 '$TOOLS_DIR'/sqlmap/sqlmap.py"' >> $HOME/.bashrc
fi

# === Arjun & Uro ===
pipx install arjun || echo -e "${red}Arjun may already be installed.${reset}"
pipx install uro || echo -e "${red}Uro may already be installed.${reset}"

# === Nikto ===
echo -e "${yellow}Installing Nikto...${reset}"
if [ ! -d "$TOOLS_DIR/nikto" ]; then
  git clone https://github.com/sullo/nikto "$TOOLS_DIR/nikto"
  echo 'alias nikto="perl $TOOLS_DIR/nikto/program/nikto.pl"' >> $HOME/.bashrc
else
  echo -e "${red}Nikto already exists, skipping...${reset}"
fi

# === Wordlists ===
echo -e "${yellow}Downloading wordlists...${reset}"
git clone https://github.com/danielmiessler/SecLists.git "$WORDLIST_DIR/SecLists"
git clone https://github.com/coffinxp/payloads.git "$WORDLIST_DIR/payloads"
git clone https://github.com/fuzzdb-project/fuzzdb.git "$WORDLIST_DIR/fuzzdb"
git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git "$WORDLIST_DIR/PayloadsAllTheThings"
git clone https://github.com/six2dez/OneListForAll "$WORDLIST_DIR/OneListForAll"

# === Done ===
echo -e "${green}All tools installed successfully!${reset}"
echo -e "${yellow}Run 'source $HOME/.bashrc' or restart your terminal to use the aliases.${reset}"
