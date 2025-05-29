#!/bin/bash

PYTHON_VENV=~/Python-Environments
TOOL_DIR=~/tools


OUTPUT=~/recon
mkdir -p "$OUTPUT"

read -p "Enter domain or URL: " DOMAIN
CLEAN_DOMAIN=$(echo "$DOMAIN" | sed -E 's~https?://~~' | sed 's~/.*~~')
DOMAIN_DIR="$OUTPUT/$CLEAN_DOMAIN"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
mkdir -p "$DOMAIN_DIR"

echo "[+] Running subfinder..."
subfinder -d "$CLEAN_DOMAIN" -silent -o "$DOMAIN_DIR/subfinder.txt" > /dev/null 2>&1

echo "[+] Running assetfinder..."
assetfinder --subs-only "$CLEAN_DOMAIN" > "$DOMAIN_DIR/assetfinder.txt" 2>/dev/null

echo "[+] Combining and deduplicating..."
cat "$DOMAIN_DIR"/subfinder.txt "$DOMAIN_DIR"/assetfinder.txt | sort -u > "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt"

SUBDOMAIN_COUNT=$(wc -l < "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt")
echo "[+] Found $SUBDOMAIN_COUNT unique subdomains."

echo "[+] Probing for alive domains..."
httpx -l "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" -sc -td -ip -o "$DOMAIN_DIR/alive_$TIMESTAMP.txt" > /dev/null 2>&1
awk '{print $1}' > "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt"

echo "[+] Filtering 403s for fuzzing..."
grep -v " 403 " "$DOMAIN_DIR/alive_$TIMESTAMP.txt" | awk '{print $1}' > $DOMAIN_DIR/fuzz_targets.txt

echo "[+] Extracting IPs for port scanning..."
grep -oP '\[\K[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$DOMAIN_DIR/alive_$TIMESTAMP.txt" | sort -u > "$DOMAIN_DIR/ip_targets.txt"

echo "[+] Port scanning extracted IPs with nmap..."
nmap -iL $DOMAIN_DIR/ip_targets.txt -sV -sC -A -T2

echo "[+] Filtering domains running IIS..."
grep -i "iis" "$DOMAIN_DIR/alive_$TIMESTAMP.txt" | awk '{print $1}' > "$DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt"
IIS_COUNT=$(wc -l < "$DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt")
echo "[+] Found $IIS_COUNT IIS hosts. Saved to $DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt"

echo "[+] Performing basic vulnerability scanning 1/2..."
for SUB in "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt"
do
    echo "[+] Starting vulnerability scanning on $SUB"
    nikto -host $SUB | tee "$DOMAIN_DIR/nikto_results_$TIMESTAMP.txt"
done

echo '[+] Performing basic vulnerability scanning 2/2...'
nuclei -l $DOMAIN_DIR/subdomains_$TIMESTAMP.txt -o "$DOMAIN_DIR/nuclei_results_$TIMESTAMP.txt"

echo "[+] Scanning for subdomain takeover 1/2..."
subzy run --targets $DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt --verify_ssl --hide_fails | tee subzy_$TIMESTAMP.txt



ALIVE_COUNT=$(wc -l < "$DOMAIN_DIR/alive_$TIMESTAMP.txt")
echo "[+] Found $ALIVE_COUNT alive hosts"

echo "[✓] Finished! Results in $DOMAIN_DIR"
