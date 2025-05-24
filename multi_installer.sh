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
GOBIN=$(go env GOPATH)/bin
mkdir -p "$TOOLS_DIR"

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
)

echo -e "${yellow}Installing Go-based tools...${reset}"
for tool in "${!go_tools[@]}"; do
  echo -e "${green}Installing $tool...${reset}"
  go install "${go_tools[$tool]}"
  sudo mv -f "$GOBIN/$tool" /usr/bin/
done

# === Python-based Tools ===

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

# === Final Output ===
echo -e "${green}All tools installed successfully!${reset}"
echo -e "${yellow}Run 'source ~/.bashrc' or restart your terminal to use the aliases.${reset}"
