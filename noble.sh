#!/usr/bin/env bash

### CONFIGURE LOSTSEC'S GF PATTERNS
set -euo pipefail
IFS=$'\n\t'
echo "
             _     _
                                             ███╗   ██╗ ██████╗ ██████╗ ██╗     ███████╗                                                          
                                            ████╗  ██║██╔═══██╗██╔══██╗██║     ██╔════╝                                                          
                                            ██╔██╗ ██║██║   ██║██████╔╝██║     █████╗                                                            
                                            ██║╚██╗██║██║   ██║██╔══██╗██║     ██╔══╝                                                            
                                            ██║ ╚████║╚██████╔╝██████╔╝███████╗███████╗                                                          
                                            ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝                                                          
                                                                                                                                                 
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

# Load config (script-dir or ~/.config/bugbounty/config.env)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.env"
CONFIG_FILE="$(dirname "$0")/config.env"
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

TARGET=""
# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --url|-u)
            TARGET="$2"
            shift 2
            ;;
        *)
            echo "[!] Unknown argument: $1"
            exit 1
            ;;
    esac
done

# If no target provided, prompt for it
if [ -z "$TARGET" ]; then
    read -rp "Enter target domain: " TARGET
fi

CLEAN_DOMAIN="$TARGET"
# Directories and timestamps
REAL_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6 || echo "$HOME")
export HOME="$REAL_HOME"
PYTHON_VENV="$HOME/Python-Environments"
TOOLS_DIR="$HOME/tools"
WORDLIST_DIR="$TOOLS_DIR/wordlists"
OUTPUT="$HOME/recon"
DOMAIN_DIR="$OUTPUT/$CLEAN_DOMAIN"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p "$DOMAIN_DIR"

# === Subdomain enumeration ===
echo "[+] Running subfinder..."
subfinder -d "$CLEAN_DOMAIN" -silent -o "$DOMAIN_DIR/subfinder.txt" >/dev/null 2>&1 || true

echo "[+] Running assetfinder..."
assetfinder --subs-only "$CLEAN_DOMAIN" > "$DOMAIN_DIR/assetfinder.txt" 2>/dev/null || true

echo "[+] Collecting subdomains from crt.sh..."
curl -s "https://crt.sh/?q=$CLEAN_DOMAIN&output=json" \
  | jq -r '.[].name_value' 2>/dev/null \
  | sed 's/^\*\.//' \
  | sort -u > "$DOMAIN_DIR/crtsh.txt" || true

# === Alienvault scrape ===
echo "[+] Starting Alienvault url scrape..."
page=1
tmpjson=$(mktemp "$DOMAIN_DIR/alienvault.XXXXXX.json")

# Turn off errexit just for this block so we can explicitly handle failures
set +e

while true; do
    # run curl; allow it to fail without killing the whole script
    http_code=$(curl -s -w "%{http_code}" -o "$tmpjson" \
      "https://otx.alienvault.com/api/v1/indicators/hostname/$CLEAN_DOMAIN/url_list?limit=500&page=$page")
    curl_exit=$?

    # If curl itself failed (network, DNS, etc)
    if [ $curl_exit -ne 0 ]; then
        echo "[!] curl failed with exit $curl_exit on page $page — retrying after 30s"
        sleep 30
        # you can implement retry count here; using continue to retry
        continue
    fi

    # If rate limited
    if [ "$http_code" -eq 429 ]; then
        echo "Rate limit hit — waiting 60 seconds..."
        sleep 60
        continue
    fi

    # If other HTTP error
    if [ "$http_code" -ne 200 ]; then
        echo "Error: received HTTP $http_code on page $page — stopping AlienVault block."
        break
    fi

    # Extract URLs safely — don't let jq non-zero kill the script
    urls=$(jq -r '.url_list[]?.url' "$tmpjson" 2>/dev/null || true)

    # Stop if no URLs found
    if [ -z "$urls" ] || [ "$urls" = "null" ]; then
        echo "No more URLs found"
        break
    fi

    echo "$urls" | sed 's/^\*\.//' | sort -u >> "$DOMAIN_DIR/alienvault.txt"

    ((page++))
    sleep 1  # polite delay between requests
done

# restore errexit
set -e

rm -f "$tmpjson"


    


echo "[+] Collecting subdomains using FFUF..."
# Ensure wordlist path correctness
FFUF_WORDLIST="${WORDLIST_DIR}/SecLists/Discovery/DNS/subdomains-top1million-5000.txt"
if [ -f "$FFUF_WORDLIST" ]; then
    ffuf -u "https://FUZZ.$CLEAN_DOMAIN" \
         -w "$FFUF_WORDLIST" \
         -mc 200,204,301,302,307,401,403 \
         -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0" \
         -t 60 --rate 100 -c -o "$DOMAIN_DIR/ffuf.json" -of json || true

    if [ -f "$DOMAIN_DIR/ffuf.json" ]; then
        jq -r '.results[].input | capture("FUZZ\\.(?<host>.*)"; "g").host? // .results[].input' "$DOMAIN_DIR/ffuf.json" 2>/dev/null \
            | sed 's#https\?://##' | sort -u > "$DOMAIN_DIR/ffuf.txt" || true
    fi
else
    echo "[!] FFUF wordlist missing: $FFUF_WORDLIST"
fi

echo "[+] Collecting subdomains from Web Archive..."
curl -s "http://web.archive.org/cdx/search/cdx?url=*.$CLEAN_DOMAIN/*&output=text&fl=original&collapse=urlkey" \
  | sed -E 's_https?://__' \
  | sed -E 's#/.*##; s/:.*//; s/^www\.//' \
  | sort -u > "$DOMAIN_DIR/wayback.txt" || true

echo "[+] Collecting subdomains from VirusTotal (v3)"
if [ -n "${VT_API_KEY:-}" ]; then
    curl -s --request GET \
      --url "https://www.virustotal.com/api/v3/domains/$CLEAN_DOMAIN/subdomains?limit=100" \
      --header "x-apikey: $VT_API_KEY" \
    | jq -r '.data[].id' 2>/dev/null | sort -u > "$DOMAIN_DIR/virustotal.txt" || true
else
    echo "[!] VT_API_KEY not set; skipping VirusTotal."
fi

echo "[+] Combining and deduplicating..."
# Only cat files that exist
cat_files=()
for f in subfinder.txt assetfinder.txt crtsh.txt ffuf.txt wayback.txt virustotal.txt; do
    if [ -f "$DOMAIN_DIR/$f" ]; then
        cat_files+=("$DOMAIN_DIR/$f")
    fi
done

if [ "${#cat_files[@]}" -gt 0 ]; then
    cat "${cat_files[@]}" | sed 's/^\s*//; s/\s*$//' | sort -u > "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt"
else
    echo "[!] No enumeration output to combine."
fi

SUBDOMAIN_COUNT=$(wc -l < "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" || echo 0)
echo "[+] Found $SUBDOMAIN_COUNT unique subdomains."

# === Probing for alive domains ===
echo "[+] Probing for alive domains..."
httpx -l "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" -sc -td -ip -o "$DOMAIN_DIR/alive_$TIMESTAMP.txt" || true

# httpx output: domain status title ip -> filter domain column robustly
if [ -f "$DOMAIN_DIR/alive_$TIMESTAMP.txt" ]; then
    awk '{print $1}' "$DOMAIN_DIR/alive_$TIMESTAMP.txt" | sort -u > "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt"
fi

ALIVE_COUNT=$(wc -l < "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" || echo 0)
echo "[+] Found $ALIVE_COUNT alive hosts"

# === Spidering ===
echo "[+] Spidering alive domains (gau)..."
if [ -s "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" ]; then
    cat "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" | gau > "$DOMAIN_DIR/gausubs_$TIMESTAMP.txt" || true
    cat "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" | waybackurls > "$DOMAIN_DIR/waybacksubs_$TIMESTAMP.txt" 2>/dev/null || true

    if command -v katana >/dev/null 2>&1; then
        katana -u "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" -d 5 -kf -jc -fx -ef woff,css,png,svg,jpg,woff2,jpeg,gif -o "$DOMAIN_DIR/katana_subs_$TIMESTAMP.txt" 2>/dev/null || true
    else
        echo "[!] katana not found; skipping."
    fi
fi

echo "[+] Combining spidered URLs..."
cat "$DOMAIN_DIR/gausubs_$TIMESTAMP.txt" "$DOMAIN_DIR/waybacksubs_$TIMESTAMP.txt" "$DOMAIN_DIR/katana_subs_$TIMESTAMP.txt" \
  | sort -u | tee "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" >/dev/null || true

# === Collect urls with 200 OK status code ===
echo "[+] Searching for live URLs..."
httpx -l "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" -mc 200 -o "$DOMAIN_DIR/filtered_urls_$TIMESTAMP.txt"

# === Parameter / JS / XSS reconnaissance ===
echo "[+] Collecting Cross Site scripting parameters..."
if [ -f "$DOMAIN_DIR/filtered_urls_$TIMESTAMP.txt" ]; then
    cat "$DOMAIN_DIR/filtered_urls_$TIMESTAMP.txt" | gf xss | sort -u | tee "$DOMAIN_DIR/xss_params_$TIMESTAMP.txt" >/dev/null || true
fi

echo "[+] Collecting parameters..."
arjun -i "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" > "$DOMAIN_DIR/arjun-param_$TIMESTAMP.txt" 2>/dev/null || true

sudo paramspider -d "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" 2>/dev/null || true
if [ -d results ]; then
    find results -type f -name "*.txt" -exec cat {} + | sort -u > "$DOMAIN_DIR/paramspider_all_urls_$TIMESTAMP.txt"
    mv results "$DOMAIN_DIR/" || true
fi

grep -E '\?[^=]+=.+$' "$DOMAIN_DIR/filtered_urls_$TIMESTAMP.txt" | sort -u > "$DOMAIN_DIR/params_$TIMESTAMP.txt"

echo "[+] Searching for live URLs and merging..."
cat "$DOMAIN_DIR/arjun-param_$TIMESTAMP.txt" "$DOMAIN_DIR/paramspider_all_urls_$TIMESTAMP.txt" "$DOMAIN_DIR/params_$TIMESTAMP.txt" | sort -u | httpx -mc 200 > "$DOMAIN_DIR/allparams.txt"

echo "[+] Starting DAST scan on URLs with parameters..."
nuclei -dast -retries 2 -silent -o "$NUCLEI_RESULTS" < "$DOMAIN_DIR/allparams.txt"

echo "[+] Extracting js files..."
grep -E "\.js($|\?)" "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" | sed 's/?.*$//' | sort -u > "$DOMAIN_DIR/js_$TIMESTAMP.txt" 2>/dev/null || true

echo "[+] Filtering alive js files..."
if [ -s "$DOMAIN_DIR/js_$TIMESTAMP.txt" ]; then
    httpx -l "$DOMAIN_DIR/js_$TIMESTAMP.txt" -mc 200 -o "$DOMAIN_DIR/js_alive_$TIMESTAMP.txt" || true
fi

echo "[+] Scanning for sensitive info (nuclei exposures)..."
if [ -s "$DOMAIN_DIR/js_alive_$TIMESTAMP.txt" ]; then
    nuclei -l "$DOMAIN_DIR/js_alive_$TIMESTAMP.txt" -t "$HOME/nuclei-templates/http/exposures" -o "$DOMAIN_DIR/potential_secrets_$TIMESTAMP.txt" || true
fi

echo "[+] Scanning for sensitive file extensions..."
grep -E "\.(txt|log|cache|secret|db|backup|yml|json|gz|rar|zip|config)$" "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" | sort -u | tee "$DOMAIN_DIR/sensitive_file_extensions.txt" >/dev/null || true

# === Fuzzing targets (exclude 403s) ===
echo "[+] Filtering 403s for fuzzing..."
if [ -f "$DOMAIN_DIR/alive_$TIMESTAMP.txt" ]; then
    grep -v " 403 " "$DOMAIN_DIR/alive_$TIMESTAMP.txt" | awk '{print $1}' | sort -u > "$DOMAIN_DIR/fuzz_targets_$TIMESTAMP.txt"
fi

echo "[+] FUZZING targets with dirsearch..."
if [ -s "$DOMAIN_DIR/fuzz_targets_$TIMESTAMP.txt" ]; then
    if [ -d "$PYTHON_VENV/dirsearch" ]; then
        source "$PYTHON_VENV/dirsearch/bin/activate" || true
    fi
    while IFS= read -r SUB; do
        echo "[~] dirsearch: $SUB"
        python3 "$TOOLS_DIR/dirsearch/dirsearch.py" -u "$SUB" -w "$WORDLIST_DIR/SecLists/Discovery/Web-Content/common.txt" \
            -x 403,301,429,302,404,500,501,502,503 -e xml,json,sql,db,log,yml,yaml,bak,txt,tar.gz,zip,js,pdf,env,cgi -recursive || true
    done < "$DOMAIN_DIR/fuzz_targets_$TIMESTAMP.txt"
    deactivate || true
fi

echo "[+] Extracting IPs for port scanning..."
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' "$DOMAIN_DIR/alive_$TIMESTAMP.txt" | sort -u > "$DOMAIN_DIR/ip_targets.txt" || true

echo "[+] Port scanning extracted IPs with nmap..."
if [ -s "$DOMAIN_DIR/ip_targets.txt" ]; then
    nmap -iL "$DOMAIN_DIR/ip_targets.txt" -sV -sC -A -T2 -oA "$DOMAIN_DIR/nmap_scan_$TIMESTAMP" || true
fi

echo "[+] Filtering domains running IIS..."
grep -i "iis" "$DOMAIN_DIR/alive_$TIMESTAMP.txt" | awk '{print $1}' | sort -u > "$DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt" || true
IIS_COUNT=$(wc -l < "$DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt" || echo 0)
echo "[+] Found $IIS_COUNT IIS hosts. Saved to $DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt"

echo "[+] Attacking IIS hosts with shortscan..."
if [ -s "$DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt" ]; then
    while IFS= read -r SUB; do
        echo "[~] shortscan $SUB"
        shortscan "$SUB" || true
    done < "$DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt"
fi

echo "[+] Performing basic vulnerability scanning (nikto/nuclei)..."
if [ -s "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" ]; then
    while IFS= read -r SUB; do
        echo "[~] nikto on $SUB"
        nikto -host "$SUB" | tee -a "$DOMAIN_DIR/nikto_$SUB_$TIMESTAMP.txt" || true
    done < "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt"

    nuclei -l "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" -o "$DOMAIN_DIR/nuclei_results_$TIMESTAMP.txt" || true
fi

echo "[+] Scanning for subdomain takeover 1/3..."
if [ -s "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" ]; then
    subzy run --targets "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" --verify_ssl --hide_fails | tee "$DOMAIN_DIR/subzy_$TIMESTAMP.txt" || true
else
    echo "[-] No input detected"
fi

echo "[+] Scanning for subdomain takeover 2/3..."
if [ -s "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" ]; then
    cat "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" | dnsx -cname -ns -o "$DOMAIN_DIR/cnamenssub.txt" || true
else
    echo "[-] No input detected"
fi

echo "[+] Scanning for subdomain takeover 3/3..."
if [ -s "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" ]; then
    nuclei -l "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" -t "$HOME/nuclei-templates/http/takeovers" -o "$DOMAIN_DIR/nuclei_takeover_$TIMESTAMP.txt" || true
else
    echo "[-] No input detected"
fi

echo "[+] Scanning for Local File Inclusion..."
if [ -s "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" ]; then
    nuclei -l "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" -t "$HOME/nuclei-templates/http/vulnerabilities/generic/generic-linux-lfi.yaml" -c 30 -o "$DOMAIN_DIR/lfi_$TIMESTAMP.txt" || true
else
    echo "[-] No input detected"
fi

echo "[+] Scanning for Cross Site Scripting 1/3..."
if [ -s "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" ]; then
    cat "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" | gxss | kxss | tee "$DOMAIN_DIR/1_xss_$TIMESTAMP.txt" || true
else
    echo "[-] No input detected"
fi

echo "[+] Scanning for Cross Site Scripting 2/3..."
if [ -s "$DOMAIN_DIR/xss_params_$TIMESTAMP.txt" ]; then
    cat "$DOMAIN_DIR/xss_params_$TIMESTAMP.txt" | dalfox pipe --blind $COLLABORATOR_LINK --waf-bypass --silence | tee "$DOMAIN_DIR/2_xss_$TIMESTAMP.txt" || true
else
    echo "[-] No input detected"
fi

echo "[+] Scanning for Cross Site Scripting 3/3..."
if [ -s "$DOMAIN_DIR/js_alive_$TIMESTAMP.txt" ]; then
    cat "$DOMAIN_DIR/js_alive_$TIMESTAMP.txt" | gxss -c 100 | sort -u | dalfox pipe -o "$DOMAIN_DIR/dom_xss_results_$TIMESTAMP.txt"
else
    echo "[-] No input detected"
fi

echo "[+] Scanning for Cross Origin Resource Sharing..."
if [ -s "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" ]; then
    source "$PYTHON_VENV/corsy/bin/activate"
    awk -F/ '{print $1"//"$3}' "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" | sort -u \
        | python3 "$TOOLS_DIR/Corsy/corsy.py" -i /dev/stdin -t 10 \
          --headers "User-Agent: GoogleBot\nCookie: SESSION=Hacked"
    deactivate
else
    echo "[-] No input detected"
fi


echo "[✓] Finished! Results in $DOMAIN_DIR"
