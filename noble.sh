#!/usr/bin/env bash

# Bug Bounty Reconnaissance Script
# Improved version with proper structure, error handling, and options

set -euo pipefail
IFS=$'\n\t'

# === Colors ===
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RESET='\033[0m'

# === Global Variables ===
TARGET=""
VERBOSE=false
SKIP_TOOLS_CHECK=false
NUCLEI_RESULTS=""

# === Functions ===

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Bug Bounty Reconnaissance Script

OPTIONS:
    -u, --url URL          Target domain/URL to scan
    -v, --verbose          Enable verbose output
    -s, --skip-check       Skip tool availability check
    -h, --help             Show this help message

EXAMPLES:
    $0 -u example.com
    $0 --url example.com --verbose

ENVIRONMENT VARIABLES:
    VT_API_KEY             VirusTotal API key (optional)
    COLLABORATOR_LINK      Collaborator link for XSS testing (optional)

CONFIG FILE:
    Loads config.env from script directory if available
EOF
}

log_info() {
    echo -e "${BLUE}[+]${RESET} $*"
}

log_warn() {
    echo -e "${YELLOW}[!]${RESET} $*" >&2
}

log_error() {
    echo -e "${RED}[!]${RESET} $*" >&2
}

log_success() {
    echo -e "${GREEN}[✓]${RESET} $*"
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${YELLOW}[~]${RESET} $*"
    fi
}

# Load config (script-dir or ~/.config/bugbounty/config.env)
load_config() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local config_file="$script_dir/config.env"
    
    if [ -f "$config_file" ]; then
        log_verbose "Loading config from: $config_file"
        # shellcheck source=/dev/null
        source "$config_file"
    else
        log_verbose "Config file not found: $config_file"
    fi
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -u|--url)
                TARGET="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -s|--skip-check)
                SKIP_TOOLS_CHECK=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown argument: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Check if required tools are available
check_tools() {
    if [ "$SKIP_TOOLS_CHECK" = true ]; then
        log_warn "Skipping tool availability check"
        return 0
    fi
    
    local missing_tools=()
    local required_tools=(
        "subfinder" "assetfinder" "curl" "jq" "httpx" "gau" "waybackurls"
        "nmap" "nikto" "nuclei" "grep" "sed" "sort" "awk" "ffuf" "chaos" "alterx"
    )
    
    log_info "Checking required tools..."
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_warn "Install missing tools or use --skip-check to continue anyway"
        return 1
    fi
    
    log_success "All required tools are available"
    return 0
}

# Validate target domain
validate_target() {
    if [ -z "$TARGET" ]; then
        read -rp "Enter target domain: " TARGET
    fi
    
    if [ -z "$TARGET" ]; then
        log_error "Target domain cannot be empty"
        exit 1
    fi
    
    # Basic domain validation
    if ! [[ "$TARGET" =~ ^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        log_warn "Target '$TARGET' may not be a valid domain format"
    fi
    
    log_info "Target: $TARGET"
}

# Initialize directories and variables
init_directories() {
    local clean_domain="$TARGET"
    REAL_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6 2>/dev/null || echo "$HOME")
    export HOME="$REAL_HOME"
    PYTHON_VENV="$HOME/Python-Environments"
    TOOLS_DIR="$HOME/tools"
    WORDLIST_DIR="$TOOLS_DIR/wordlists"
    OUTPUT="$HOME/recon"
    DOMAIN_DIR="$OUTPUT/$clean_domain"
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    NUCLEI_RESULTS="$DOMAIN_DIR/nuclei_dast_$TIMESTAMP.txt"
    
    mkdir -p "$DOMAIN_DIR"
    log_info "Output directory: $DOMAIN_DIR"
}

# === Subdomain Enumeration Functions ===

run_subfinder() {
    log_info "Running subfinder..."
    if command -v subfinder >/dev/null 2>&1; then
        subfinder -d "$TARGET" -silent -o "$DOMAIN_DIR/subfinder.txt" >/dev/null 2>&1 || true
    else
        log_warn "subfinder not found, skipping"
    fi
}

run_chaos() {
    log_info "Running chaos..."
    if command -v chaos >/dev/null 2>&1 && command -v alterx >/dev/null 2>&1 && command -v dnsx >/dev/null 2>&1; then
        chaos -d "$TARGET" 2>/dev/null | alterx -enrich 2>/dev/null | dnsx 2>/dev/null | tee "$DOMAIN_DIR/chaos.txt" >/dev/null 2>&1 || true
    else
        log_warn "chaos, alterx, or dnsx not found, or chaos' API key is not configured, skipping"
    fi
}

run_alterx() {
    log_info "Running alterX..."
    if command -v alterx >/dev/null 2>&1 && command -v dnsx >/dev/null 2>&1; then
        local wordlist="${WORDLIST_DIR}/SecLists/Discovery/DNS/subdomains-top1million-5000.txt"
        if [ ! -f "$wordlist" ]; then
            log_warn "Wordlist not found: $wordlist"
            return
        fi
        echo "$TARGET" | alterx -pp word="$wordlist" 2>/dev/null | dnsx 2>/dev/null | tee "$DOMAIN_DIR/alterX.txt" >/dev/null 2>&1 || true
    else
        log_warn "alterX or dnsx not found, skipping"
    fi
}

run_assetfinder() {
    log_info "Running assetfinder..."
    if command -v assetfinder >/dev/null 2>&1; then
        assetfinder --subs-only "$TARGET" > "$DOMAIN_DIR/assetfinder.txt" 2>/dev/null || true
    else
        log_warn "assetfinder not found, skipping"
    fi
}

run_crtsh() {
    log_info "Collecting subdomains from crt.sh..."
    local tmp_json
    tmp_json=$(mktemp "$DOMAIN_DIR/crtsh.XXXXXX.json" 2>/dev/null || echo "/tmp/crtsh.$$.json")
    
    if curl -s "https://crt.sh/?q=$TARGET&output=json" -o "$tmp_json" 2>/dev/null; then
        if command -v jq >/dev/null 2>&1; then
            jq -r '.[].name_value' "$tmp_json" 2>/dev/null \
                | sed 's/^\*\.//' \
                | sort -u > "$DOMAIN_DIR/crtsh.txt" || true
        else
            log_warn "jq not found, cannot parse crt.sh results"
        fi
    else
        log_warn "Failed to fetch crt.sh data"
    fi
    
    rm -f "$tmp_json"
}

run_alienvault() {
    log_info "Starting Alienvault URL scrape..."
    local page=1
    local max_retries=3
    local retry_count=0
    local tmp_json
    tmp_json=$(mktemp "$DOMAIN_DIR/alienvault.XXXXXX.json" 2>/dev/null || echo "/tmp/alienvault.$$.json")
    
    set +e
    
    while true; do
        local http_code curl_exit
        http_code=$(curl -s -w "%{http_code}" -o "$tmp_json" \
            "https://otx.alienvault.com/api/v1/indicators/hostname/$TARGET/url_list?limit=500&page=$page" 2>/dev/null)
        curl_exit=$?
        
        if [ $curl_exit -ne 0 ]; then
            retry_count=$((retry_count + 1))
            if [ $retry_count -ge $max_retries ]; then
                log_warn "curl failed after $max_retries retries on page $page"
                break
            fi
            log_warn "curl failed with exit $curl_exit on page $page — retrying after 30s"
            sleep 30
            continue
        fi
        
        retry_count=0
        
        if [ "$http_code" -eq 429 ]; then
            log_warn "Rate limit hit — waiting 60 seconds..."
            sleep 60
            continue
        fi
        
        if [ "$http_code" -ne 200 ]; then
            log_verbose "Received HTTP $http_code on page $page — stopping AlienVault scrape"
            break
        fi
        
        local urls
        urls=$(jq -r '.url_list[]?.url' "$tmp_json" 2>/dev/null || true)
        
        if [ -z "$urls" ] || [ "$urls" = "null" ]; then
            log_verbose "No more URLs found on page $page"
            break
        fi
        
        echo "$urls" | sed 's/^\*\.//' | sort -u >> "$DOMAIN_DIR/alienvault.txt"
        
        ((page++))
        sleep 1
    done
    
    set -e
    rm -f "$tmp_json"
}


    


run_ffuf() {
    log_info "Collecting subdomains using FFUF..."
    if ! command -v ffuf >/dev/null 2>&1; then
        log_warn "ffuf not found, skipping"
        return
    fi
    
    local ffuf_wordlist="${WORDLIST_DIR}/SecLists/Discovery/DNS/subdomains-top1million-5000.txt"
    if [ ! -f "$ffuf_wordlist" ]; then
        log_warn "FFUF wordlist missing: $ffuf_wordlist"
        return
    fi
    
    if ffuf -u "https://FUZZ.$TARGET" \
         -w "$ffuf_wordlist" \
         -mc 200,204,301,302,307,401,403 \
         -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0" \
         -t 60 --rate 100 -c -o "$DOMAIN_DIR/ffuf.json" -of json >/dev/null 2>&1; then
        
        if [ -f "$DOMAIN_DIR/ffuf.json" ] && command -v jq >/dev/null 2>&1; then
            jq -r '.results[].input | capture("FUZZ\\.(?<host>.*)"; "g").host? // .results[].input' "$DOMAIN_DIR/ffuf.json" 2>/dev/null \
                | sed 's#https\?://##' | sort -u > "$DOMAIN_DIR/ffuf.txt" || true
        fi
    else
        log_warn "FFUF enumeration failed"
    fi
}

run_wayback() {
    log_info "Collecting subdomains from Web Archive..."
    if curl -s "http://web.archive.org/cdx/search/cdx?url=*.$TARGET/*&output=text&fl=original&collapse=urlkey" \
        | sed -E 's_https?://__' \
        | sed -E 's#/.*##; s/:.*//; s/^www\.//' \
        | sort -u > "$DOMAIN_DIR/wayback.txt" 2>/dev/null; then
        log_verbose "Wayback machine enumeration completed"
    else
        log_warn "Wayback machine enumeration failed"
    fi
}

run_virustotal() {
    log_info "Collecting subdomains from VirusTotal (v3)..."

    if [ -z "${VT_API_KEY:-}" ]; then
        log_warn "VT_API_KEY not set; skipping VirusTotal"
        return
    fi

    # Normalize domain for VT: strip scheme and path
    local domain="$TARGET"
    domain="${domain#http://}"
    domain="${domain#https://}"
    domain="${domain%%/*}"

    if [ -z "$domain" ]; then
        log_warn "Could not normalize domain for VirusTotal from target '$TARGET'"
        return
    fi

    local page_size=40   # VT often uses 40 as a standard page size
    local tmp_json
    tmp_json=$(mktemp "$DOMAIN_DIR/virustotal.XXXXXX.json" 2>/dev/null || echo "/tmp/virustotal.$$.json")

    # Clear previous results if any
    : > "$DOMAIN_DIR/virustotal.txt"

    # First page URL
    local url="https://www.virustotal.com/api/v3/domains/$domain/subdomains?limit=$page_size"

    while :; do
        # Get JSON + HTTP code
        local http_code
        http_code=$(curl -s -w "%{http_code}" \
            -H "x-apikey: $VT_API_KEY" \
            -H "Accept: application/json" \
            -o "$tmp_json" \
            "$url")

        if [ "$http_code" -eq 401 ] || [ "$http_code" -eq 403 ]; then
            log_warn "VirusTotal API auth error (HTTP $http_code). Check VT_API_KEY and quota."
            break
        fi

        if [ "$http_code" -eq 429 ]; then
            log_warn "VirusTotal rate limit hit (HTTP 429). Waiting 60 seconds..."
            sleep 60
            continue
        fi

        if [ "$http_code" -eq 400 ]; then
            # Helpful debug: log part of the response body
            local snippet
            snippet=$(head -c 200 "$tmp_json" 2>/dev/null | tr '\n' ' ')
            log_warn "VirusTotal HTTP 400 for domain '$domain'. Response snippet: $snippet"
            break
        fi

        if [ "$http_code" -ne 200 ]; then
            log_warn "VirusTotal HTTP $http_code for $domain; skipping further requests."
            break
        fi

        if command -v jq >/dev/null 2>&1; then
            # Append subdomains if present
            jq -r '.data[]?.id // empty' "$tmp_json" 2>/dev/null >> "$DOMAIN_DIR/virustotal.txt" || true

            # Next page URL (VT v3 uses a full URL in links.next)
            local next
            next=$(jq -r '.links.next // empty' "$tmp_json" 2>/dev/null)
            if [ -z "$next" ] || [ "$next" = "null" ]; then
                break
            fi
            url="$next"
        else
            log_warn "jq not found; cannot parse VirusTotal response."
            break
        fi
    done

    rm -f "$tmp_json"

    if [ -s "$DOMAIN_DIR/virustotal.txt" ]; then
        sort -u "$DOMAIN_DIR/virustotal.txt" -o "$DOMAIN_DIR/virustotal.txt" 2>/dev/null || true
        log_verbose "VirusTotal enumeration completed (saved to virustotal.txt)"
    else
        log_warn "VirusTotal returned no subdomains."
    fi
}

combine_subdomains() {
    log_info "Combining and deduplicating subdomains..."
    local cat_files=()
    local files=("subfinder.txt" "assetfinder.txt" "crtsh.txt" "ffuf.txt" "wayback.txt" "virustotal.txt" "alienvault.txt" "chaos.txt" "alterX.txt")
    
    for f in "${files[@]}"; do
        if [ -f "$DOMAIN_DIR/$f" ]; then
            cat_files+=("$DOMAIN_DIR/$f")
        fi
    done
    
    if [ ${#cat_files[@]} -gt 0 ]; then
        cat "${cat_files[@]}" | sed 's/^\s*//; s/\s*$//' | sort -u > "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt"
        local subdomain_count
        subdomain_count=$(wc -l < "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" 2>/dev/null || echo 0)
        log_success "Found $subdomain_count unique subdomains"
    else
        log_warn "No enumeration output to combine"
        touch "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt"
    fi
}

probe_alive_domains() {
    log_info "Probing for alive domains..."
    if [ ! -s "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" ]; then
        log_warn "No subdomains to probe"
        touch "$DOMAIN_DIR/alive_$TIMESTAMP.txt"
        touch "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt"
        return
    fi
    
    if httpx -l "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" -sc -td -ip -o "$DOMAIN_DIR/alive_$TIMESTAMP.txt" >/dev/null 2>&1; then
        if [ -f "$DOMAIN_DIR/alive_$TIMESTAMP.txt" ]; then
            awk '{print $1}' "$DOMAIN_DIR/alive_$TIMESTAMP.txt" | sort -u > "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt"
            local alive_count
            alive_count=$(wc -l < "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" 2>/dev/null || echo 0)
            log_success "Found $alive_count alive hosts"
        fi
    else
        log_warn "httpx probing failed"
        touch "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt"
    fi
}

spider_domains() {
    log_info "Spidering alive domains..."
    if [ ! -s "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" ]; then
        log_warn "No alive domains to spider"
        touch "$DOMAIN_DIR/gausubs_$TIMESTAMP.txt"
        touch "$DOMAIN_DIR/waybacksubs_$TIMESTAMP.txt"
        touch "$DOMAIN_DIR/katana_subs_$TIMESTAMP.txt"
        touch "$DOMAIN_DIR/allurls_$TIMESTAMP.txt"
        return
    fi
    
    if command -v gau >/dev/null 2>&1; then
        log_verbose "Running gau..."
        cat "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" | gau > "$DOMAIN_DIR/gausubs_$TIMESTAMP.txt" 2>/dev/null || true
    else
        log_warn "gau not found; skipping"
        touch "$DOMAIN_DIR/gausubs_$TIMESTAMP.txt"
    fi
    
    if command -v waybackurls >/dev/null 2>&1; then
        log_verbose "Running waybackurls..."
        cat "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" | waybackurls > "$DOMAIN_DIR/waybacksubs_$TIMESTAMP.txt" 2>/dev/null || true
    else
        log_warn "waybackurls not found; skipping"
        touch "$DOMAIN_DIR/waybacksubs_$TIMESTAMP.txt"
    fi
    
    if command -v katana >/dev/null 2>&1; then
        log_verbose "Running katana..."
        katana -u "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" -d 5 -fx -ef woff,css,png,svg,jpg,woff2,jpeg,gif -o "$DOMAIN_DIR/katana_subs_$TIMESTAMP.txt" 2>/dev/null || true
    else
        log_warn "katana not found; skipping"
        touch "$DOMAIN_DIR/katana_subs_$TIMESTAMP.txt"
    fi
    
    log_info "Combining spidered URLs..."
    cat "$DOMAIN_DIR/gausubs_$TIMESTAMP.txt" "$DOMAIN_DIR/waybacksubs_$TIMESTAMP.txt" "$DOMAIN_DIR/katana_subs_$TIMESTAMP.txt" 2>/dev/null \
        | sort -u > "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" || true
}

filter_live_urls() {
    log_info "Searching for live URLs..."
    if [ ! -s "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" ]; then
        log_warn "No URLs to filter"
        touch "$DOMAIN_DIR/filtered_urls_$TIMESTAMP.txt"
        return
    fi
    
    if httpx -l "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" -mc 200 -o "$DOMAIN_DIR/filtered_urls_$TIMESTAMP.txt" >/dev/null 2>&1; then
        log_verbose "URL filtering completed"
    else
        log_warn "httpx URL filtering failed"
        touch "$DOMAIN_DIR/filtered_urls_$TIMESTAMP.txt"
    fi
}

collect_parameters() {
    log_info "Collecting parameters..."
    
    # XSS parameters
    if [ -s "$DOMAIN_DIR/filtered_urls_$TIMESTAMP.txt" ] && command -v gf >/dev/null 2>&1; then
        log_verbose "Collecting XSS parameters with gf..."
        cat "$DOMAIN_DIR/filtered_urls_$TIMESTAMP.txt" | gf xss 2>/dev/null | sort -u > "$DOMAIN_DIR/xss_params_$TIMESTAMP.txt" || true
    else
        touch "$DOMAIN_DIR/xss_params_$TIMESTAMP.txt"
    fi
    
    # Arjun parameter discovery
    if [ -s "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" ] && command -v arjun >/dev/null 2>&1; then
        log_verbose "Running arjun..."
        arjun -i "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" > "$DOMAIN_DIR/arjun-param_$TIMESTAMP.txt" 2>/dev/null || true
    else
        touch "$DOMAIN_DIR/arjun-param_$TIMESTAMP.txt"
    fi
    
    # Paramspider
    if [ -s "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" ] && command -v paramspider >/dev/null 2>&1; then
        log_verbose "Running paramspider..."
        if paramspider -d "$TARGET" -o "$DOMAIN_DIR/paramspider_results" >/dev/null 2>&1; then
            if [ -d "$DOMAIN_DIR/paramspider_results" ]; then
                find "$DOMAIN_DIR/paramspider_results" -type f -name "*.txt" -exec cat {} + 2>/dev/null \
                    | sort -u > "$DOMAIN_DIR/paramspider_all_urls_$TIMESTAMP.txt" || true
            fi
        fi
    else
        touch "$DOMAIN_DIR/paramspider_all_urls_$TIMESTAMP.txt"
    fi
    
    # Extract parameters from URLs
    if [ -s "$DOMAIN_DIR/filtered_urls_$TIMESTAMP.txt" ]; then
        grep -E '\?[^=]+=.+$' "$DOMAIN_DIR/filtered_urls_$TIMESTAMP.txt" 2>/dev/null \
            | sort -u > "$DOMAIN_DIR/params_$TIMESTAMP.txt" || true
    else
        touch "$DOMAIN_DIR/params_$TIMESTAMP.txt"
    fi
    
    # Combine and filter parameters
    log_info "Searching for live URLs with parameters..."
    cat "$DOMAIN_DIR/arjun-param_$TIMESTAMP.txt" "$DOMAIN_DIR/paramspider_all_urls_$TIMESTAMP.txt" "$DOMAIN_DIR/params_$TIMESTAMP.txt" 2>/dev/null \
        | sort -u | httpx -mc 200 -o "$DOMAIN_DIR/allparams.txt" >/dev/null 2>&1 || true
    
    # DAST scan
    if [ -s "$DOMAIN_DIR/allparams.txt" ] && command -v nuclei >/dev/null 2>&1; then
        log_info "Starting DAST scan on URLs with parameters..."
        nuclei -dast -retries 2 -silent -o "$NUCLEI_RESULTS" < "$DOMAIN_DIR/allparams.txt" 2>/dev/null || true
    fi
}

analyze_js_files() {
    log_info "Extracting JS files..."
    if [ -s "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" ]; then
        grep -E "\.js($|\?)" "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" 2>/dev/null \
            | sed 's/?.*$//' | sort -u > "$DOMAIN_DIR/js_$TIMESTAMP.txt" || true
    else
        touch "$DOMAIN_DIR/js_$TIMESTAMP.txt"
    fi
    
    log_info "Filtering alive JS files..."
    if [ -s "$DOMAIN_DIR/js_$TIMESTAMP.txt" ]; then
        httpx -l "$DOMAIN_DIR/js_$TIMESTAMP.txt" -mc 200 -o "$DOMAIN_DIR/js_alive_$TIMESTAMP.txt" >/dev/null 2>&1 || true
    else
        touch "$DOMAIN_DIR/js_alive_$TIMESTAMP.txt"
    fi
    
    log_info "Scanning for sensitive info (nuclei exposures)..."
    if [ -s "$DOMAIN_DIR/js_alive_$TIMESTAMP.txt" ] && command -v nuclei >/dev/null 2>&1; then
        local nuclei_exposures="$HOME/nuclei-templates/http/exposures"
        if [ -d "$nuclei_exposures" ]; then
            nuclei -l "$DOMAIN_DIR/js_alive_$TIMESTAMP.txt" -t "$nuclei_exposures" \
                -o "$DOMAIN_DIR/potential_secrets_$TIMESTAMP.txt" >/dev/null 2>&1 || true
        else
            log_warn "Nuclei exposures templates not found at $nuclei_exposures"
        fi
    fi
    
    log_info "Scanning for sensitive file extensions..."
    if [ -s "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" ]; then
        grep -E "\.(txt|log|cache|secret|db|backup|yml|json|gz|rar|zip|config)$" "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" 2>/dev/null \
            | sort -u > "$DOMAIN_DIR/sensitive_file_extensions.txt" || true
    else
        touch "$DOMAIN_DIR/sensitive_file_extensions.txt"
    fi
}

fuzz_targets() {
    log_info "Filtering 403s for fuzzing..."
    if [ -f "$DOMAIN_DIR/alive_$TIMESTAMP.txt" ]; then
        grep -v " 403 " "$DOMAIN_DIR/alive_$TIMESTAMP.txt" 2>/dev/null \
            | awk '{print $1}' | sort -u > "$DOMAIN_DIR/fuzz_targets_$TIMESTAMP.txt" || true
    else
        touch "$DOMAIN_DIR/fuzz_targets_$TIMESTAMP.txt"
    fi
    
    # Normalize targets: ensure trailing slash on URLs for better directory fuzzing
    if [ -s "$DOMAIN_DIR/fuzz_targets_$TIMESTAMP.txt" ]; then
        sed -E -i 's#^(https?://[^/]+)$#\1/#' "$DOMAIN_DIR/fuzz_targets_$TIMESTAMP.txt" 2>/dev/null || true
    fi

    log_info "Fuzzing targets & IPs with dirsearch..."
    if [ ! -s "$DOMAIN_DIR/fuzz_targets_$TIMESTAMP.txt" ]; then
        log_warn "No targets for fuzzing"
        return
    fi
    
    local dirsearch_script="$TOOLS_DIR/dirsearch/dirsearch.py"
    local wordlist="$WORDLIST_DIR/SecLists/Discovery/Web-Content/common.txt"
    
    if [ ! -f "$dirsearch_script" ]; then
        log_warn "dirsearch not found at $dirsearch_script"
        return
    fi
    
    if [ ! -f "$wordlist" ]; then
        log_warn "Wordlist not found: $wordlist"
        return
    fi
    
    local venv_activated=false
    if [ -d "$PYTHON_VENV/dirsearch" ]; then
        # shellcheck source=/dev/null
        source "$PYTHON_VENV/dirsearch/bin/activate" 2>/dev/null && venv_activated=true || true
    fi

    log_info "Preparing IPs for fuzzing..."
    
    if [ -f "$DOMAIN_DIR/alive_$TIMESTAMP.txt" ]; then
        grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' "$DOMAIN_DIR/alive_$TIMESTAMP.txt" 2>/dev/null \
            | sort -u > "$DOMAIN_DIR/ip_targets.txt" || true
    else
        touch "$DOMAIN_DIR/ip_targets.txt"
    fi
   
    
    while IFS= read -r sub; do
        [ -z "$sub" ] && continue
        log_verbose "dirsearch: $sub"
        python3 "$dirsearch_script" -u "$sub" -w "$wordlist" \
            -x 301,429,404,500,501,502,503 \
            -o "$DOMAIN_DIR/domain_fuzz_output_$TIMESTAMP.txt" \
            -e xml,json,sql,db,log,yml,yaml,bak,txt,tar.gz,zip,js,pdf,env,cgi \
            -recursive >/dev/null 2>&1 || true
    done < "$DOMAIN_DIR/fuzz_targets_$TIMESTAMP.txt"
    
    # Fuzz IP targets as http://IP/
    while IFS= read -r ip; do
        [ -z "$ip" ] && continue
        local ip_url="http://$ip/"
        log_verbose "dirsearch (IP): $ip_url"
        python3 "$dirsearch_script" -u "$ip_url" -w "$wordlist" \
            -x 301,429,404,500,501,502,503 \
            -o "$DOMAIN_DIR/ip_fuzz_output_$TIMESTAMP.txt" \
            -e xml,json,sql,db,log,yml,yaml,bak,txt,tar.gz,zip,js,pdf,env,cgi \
            -recursive >/dev/null 2>&1 || true
    done < "$DOMAIN_DIR/ip_targets.txt"


    if [ "$venv_activated" = true ]; then
        deactivate 2>/dev/null || true
    fi
}

port_scanning() {
    

    
    
    log_info "Port scanning extracted IPs with nmap..."
    if [ -s "$DOMAIN_DIR/ip_targets.txt" ] && command -v nmap >/dev/null 2>&1; then
        nmap -iL "$DOMAIN_DIR/ip_targets.txt" -sV -sC -A -T5 -oA "$DOMAIN_DIR/nmap_scan_$TIMESTAMP" >/dev/null 2>&1 || true
    else
        log_warn "No IPs to scan or nmap not found"
    fi

    log_info "Checking IPs for vulnerabilities..."
    if [ -s "$DOMAIN_DIR/ip_targets.txt" ] && command -v nmap >/dev/null 2>&1; then
        nmap -iL "$DOMAIN_DIR/ip_targets.txt" --script vuln -oA -T5 "$DOMAIN_DIR/nmap_vuln_scan_$TIMESTAMP" >/dev/null 2>&1 || true
    else
        log_warn "No IPs to scan or nmap not found"
    fi
}

scan_iis_hosts() {
    log_info "Filtering domains running IIS..."
    if [ -f "$DOMAIN_DIR/alive_$TIMESTAMP.txt" ]; then
        grep -i "iis" "$DOMAIN_DIR/alive_$TIMESTAMP.txt" 2>/dev/null \
            | awk '{print $1}' | sort -u > "$DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt" || true
    else
        touch "$DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt"
    fi
    
    local iis_count
    iis_count=$(wc -l < "$DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt" 2>/dev/null || echo 0)
    log_info "Found $iis_count IIS hosts"
    
    if [ -s "$DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt" ] && command -v shortscan >/dev/null 2>&1; then
        log_info "Attacking IIS hosts with shortscan..."
        while IFS= read -r sub; do
            [ -z "$sub" ] && continue
            log_verbose "shortscan $sub"
            $sub >> "$DOMAIN_DIR/shortscan_output_${TIMESTAMP}.txt"
            shortscan "$sub" >> "$DOMAIN_DIR/shortscan_output_${TIMESTAMP}.txt" >/dev/null 2>&1 || true
        done < "$DOMAIN_DIR/iis_hosts_$TIMESTAMP.txt"
    fi
}

vulnerability_scanning() {
    log_info "Performing basic vulnerability scanning (nuclei)..."
    if [ ! -s "$DOMAIN_DIR/subdomains_$TIMESTAMP.txt" ]; then
        log_warn "No subdomains for vulnerability scanning"
        return
    fi
    
    
    if command -v nuclei >/dev/null 2>&1; then
        log_verbose "Running nuclei on subdomains..."
        nuclei -l "$DOMAIN_DIR/fuzz_targets_$TIMESTAMP.txt" -o "$DOMAIN_DIR/nuclei_results_$TIMESTAMP.txt" >/dev/null 2>&1 || true
    else
        log_warn "nuclei not found; skipping"
    fi
}

subdomain_takeover_scan() {
    log_info "Scanning for subdomain takeover 1/3 (subzy)..."
    if [ -s "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" ] && command -v subzy >/dev/null 2>&1; then
        subzy run --targets "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" --verify_ssl --hide_fails \
            > "$DOMAIN_DIR/subzy_$TIMESTAMP.txt" 2>/dev/null || true
    else
        log_warn "No input detected or subzy not found"
    fi
    
    log_info "Scanning for subdomain takeover 2/3 (dnsx)..."
    if [ -s "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" ] && command -v dnsx >/dev/null 2>&1; then
        cat "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" | dnsx -cname -ns -o "$DOMAIN_DIR/cnamenssub.txt" >/dev/null 2>&1 || true
    else
        log_warn "No input detected or dnsx not found"
    fi
    
    log_info "Scanning for subdomain takeover 3/3 (nuclei)..."
    if [ -s "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" ] && command -v nuclei >/dev/null 2>&1; then
        local nuclei_takeovers="$HOME/nuclei-templates/http/takeovers"
        if [ -d "$nuclei_takeovers" ]; then
            nuclei -l "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" -t "$nuclei_takeovers" \
                -o "$DOMAIN_DIR/nuclei_takeover_$TIMESTAMP.txt" >/dev/null 2>&1 || true
        else
            log_warn "Nuclei takeover templates not found at $nuclei_takeovers"
        fi
    else
        log_warn "No input detected or nuclei not found"
    fi
}

scan_lfi() {
    log_info "Scanning for Local File Inclusion..."
    if [ -s "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" ] && command -v nuclei >/dev/null 2>&1; then
        local lfi_template="$HOME/nuclei-templates/http/vulnerabilities/generic/generic-linux-lfi.yaml"
        if [ -f "$lfi_template" ]; then
            nuclei -l "$DOMAIN_DIR/filtered_domains_$TIMESTAMP.txt" -t "$lfi_template" -c 30 \
                -o "$DOMAIN_DIR/lfi_$TIMESTAMP.txt" >/dev/null 2>&1 || true
        else
            log_warn "LFI template not found at $lfi_template"
        fi
    else
        log_warn "No input detected or nuclei not found"
    fi
}

scan_xss() {
    log_info "Scanning for Cross Site Scripting 1/3 (gxss/kxss)..."
    if [ -s "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" ]; then
        local has_gxss=false has_kxss=false
        
        if command -v gxss >/dev/null 2>&1; then
            has_gxss=true
        fi
        if command -v kxss >/dev/null 2>&1; then
            has_kxss=true
        fi
        
        if [ "$has_gxss" = true ] || [ "$has_kxss" = true ]; then
            local xss_output="$DOMAIN_DIR/1_xss_$TIMESTAMP.txt"
            if [ "$has_gxss" = true ] && [ "$has_kxss" = true ]; then
                cat "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" | gxss 2>/dev/null | kxss 2>/dev/null > "$xss_output" || true
            elif [ "$has_gxss" = true ]; then
                cat "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" | gxss 2>/dev/null > "$xss_output" || true
            elif [ "$has_kxss" = true ]; then
                cat "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" | kxss 2>/dev/null > "$xss_output" || true
            fi
        else
            log_warn "gxss/kxss not found; skipping"
        fi
    else
        log_warn "No input detected"
    fi
    
    log_info "Scanning for Cross Site Scripting 2/3 (dalfox)..."
    if [ -z "${COLLABORATOR_LINK:-}" ]; then
        log_warn "COLLABORATOR_LINK not set. Skipping dalfox scan..."
    elif [ -s "$DOMAIN_DIR/xss_params_$TIMESTAMP.txt" ] && command -v dalfox >/dev/null 2>&1; then
        cat "$DOMAIN_DIR/xss_params_$TIMESTAMP.txt" | dalfox pipe --blind "$COLLABORATOR_LINK" --waf-bypass --silence \
            > "$DOMAIN_DIR/2_xss_$TIMESTAMP.txt" 2>/dev/null || true
    else
        log_warn "No input detected or dalfox not found"
    fi
    
    log_info "Scanning for Cross Site Scripting 3/3 (DOM XSS)..."
    if [ -s "$DOMAIN_DIR/js_alive_$TIMESTAMP.txt" ] && command -v gxss >/dev/null 2>&1 && command -v dalfox >/dev/null 2>&1; then
        cat "$DOMAIN_DIR/js_alive_$TIMESTAMP.txt" | gxss -c 100 2>/dev/null | sort -u \
            | dalfox pipe -o "$DOMAIN_DIR/dom_xss_results_$TIMESTAMP.txt" >/dev/null 2>&1 || true
    else
        log_warn "No input detected or required tools not found"
    fi
}

scan_cors() {
    log_info "Scanning for Cross Origin Resource Sharing..."
    if [ ! -s "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" ]; then
        log_warn "No input detected"
        return
    fi
    
    local corsy_script="$TOOLS_DIR/Corsy/corsy.py"
    if [ ! -f "$corsy_script" ]; then
        log_warn "Corsy not found at $corsy_script"
        return
    fi
    
    local venv_activated=false
    if [ -d "$PYTHON_VENV/corsy" ]; then
        # shellcheck source=/dev/null
        source "$PYTHON_VENV/corsy/bin/activate" 2>/dev/null && venv_activated=true || true
    fi
    
    awk -F/ '{print $1"//"$3}' "$DOMAIN_DIR/allurls_$TIMESTAMP.txt" 2>/dev/null | sort -u \
        | python3 "$corsy_script" -i /dev/stdin -t 10 \
          --headers "User-Agent: GoogleBot\nCookie: SESSION=Hacked" >/dev/null 2>&1 || true
    
    if [ "$venv_activated" = true ]; then
        deactivate 2>/dev/null || true
    fi
}

# === Main Execution ===
main() {
    # Show banner
    cat << "EOF"

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

EOF

    # Load configuration
    load_config
    
    # Parse arguments
    parse_args "$@"
    
    # Validate target
    validate_target
    
    # Check tools
    if ! check_tools; then
        log_error "Tool check failed. Use --skip-check to continue anyway"
        exit 1
    fi
    
    # Initialize directories
    init_directories
    
    # Subdomain enumeration
    run_subfinder
    run_chaos
    run_alterx
    run_assetfinder
    run_crtsh
    run_alienvault
    run_ffuf
    run_wayback
    run_virustotal
    combine_subdomains
    
    # Probing
    probe_alive_domains
    
    # Spidering
    spider_domains
    filter_live_urls
    
    # Parameter and JS analysis
    collect_parameters
    analyze_js_files
    
    # Fuzzing
    fuzz_targets
    
    # Port scanning and IIS
    port_scanning
    scan_iis_hosts
    
    # Vulnerability scanning
    vulnerability_scanning
    subdomain_takeover_scan
    scan_lfi
    scan_xss
    scan_cors
    
    log_success "Finished! Results in $DOMAIN_DIR"
}

# Run main function
main "$@"
