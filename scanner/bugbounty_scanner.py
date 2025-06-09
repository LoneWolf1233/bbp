#!/usr/bin/env python3
"""
Bug Bounty Scanner – first‑pass prototype

Features implemented
--------------------
1. **Nmap scan** – Top‑100 ports with service/version detection.  
2. **HTTP header probe** – Grabs response headers for every discovered HTTP(S) service.  
3. **XML parsing** – Parses the Nmap XML and prints a structured table.  
4. **NVD API lookup** – Queries the National Vulnerability Database for CVEs that match
   each service+version combo. (Requires an API key via env var `NVD_API_KEY`).  
5. **Nuclei integration** – Optionally launches [projectdiscovery/​nuclei] against
   discovered web services, writing results to `nuclei_results.txt`.

This is a *single‑file* proof of concept so you can run it quickly, inspect the flow,
then decide which parts to refactor or parallelise.

Usage
-----
```bash
python bugbounty_scanner.py -t target.com 192.168.1.1 --top 100 --xml out.xml --nuclei
```

Requirements
------------
* Python 3.8+
* External tools: **nmap**, **nuclei** (optional)
* Python libs: `requests`, `lxml` (install with `pip install requests lxml`)

Notes
-----
* The script currently runs subprocess calls *serially*. You can speed it up with
  asyncio/threadpool later.
* CVE querying is rate‑limited by NVD (max 5 reqs per 30 s w/out key). Use an API key!
* Error handling is minimal right now; plenty of TODOs marked.
"""

import argparse
import os
import subprocess
import sys
import tempfile
import time
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import requests
from lxml import etree

# ---------------------------------------------------------------------------
# Utility functions
# ---------------------------------------------------------------------------


def run_command(cmd: List[str], capture_output: bool = False) -> subprocess.CompletedProcess:
    """Run a shell command and return the CompletedProcess."""
    try:
        return subprocess.run(
            cmd,
            check=True,
            text=True,
            capture_output=capture_output,
        )
    except subprocess.CalledProcessError as exc:
        print(f"[!] Command failed: {' '.join(cmd)}", file=sys.stderr)
        print(exc.stderr, file=sys.stderr)
        raise


# ---------------------------------------------------------------------------
# Step 1 – Nmap scan
# ---------------------------------------------------------------------------


def nmap_scan(targets: List[str], top_ports: int, xml_path: Path) -> None:
    """Run nmap ‑sV scan and save XML to *xml_path*."""
    cmd = [
        "nmap",
        "-sV",
        f"--top-ports",
        str(top_ports),
        "-oX",
        str(xml_path),
    ] + targets
    print(f"[+] Running Nmap: {' '.join(cmd)}")
    run_command(cmd)
    print(f"[+] Nmap results saved to {xml_path}")


# ---------------------------------------------------------------------------
# Step 2 – Parse Nmap XML
# ---------------------------------------------------------------------------

def parse_nmap_xml(xml_path: Path) -> List[Dict[str, str]]:
    """Return a list of dicts with host, port, service, product, version."""
    result = []
    ns = {
        "nmap": "http://www.nmap.org/xsd/1.0",  # Nmap XML namespace
    }
    tree = etree.parse(str(xml_path))
    for host in tree.xpath("/nmap:nmaprun/nmap:host", namespaces=ns):
        addr_elem = host.find("nmap:address", namespaces=ns)
        if addr_elem is None:
            continue
        ip = addr_elem.get("addr")
        for port in host.xpath(".//nmap:port", namespaces=ns):
            portid = port.get("portid")
            service = port.find("nmap:service", namespaces=ns)
            if service is None:
                continue
            name = service.get("name") or ""
            product = service.get("product") or ""
            version = service.get("version") or ""
            result.append({
                "ip": ip,
                "port": portid,
                "service": name,
                "product": product,
                "version": version,
            })
    return result


# ---------------------------------------------------------------------------
# Step 3 – HTTP header probe
# ---------------------------------------------------------------------------

def probe_http_headers(host: str, port: str, ssl: bool = False) -> Dict[str, str]:
    """Return response headers for http(s)://host:port."""
    scheme = "https" if ssl or port == "443" else "http"
    url = f"{scheme}://{host}:{port}/"
    try:
        r = requests.get(url, timeout=5, verify=False, allow_redirects=True)
        print(f"[+] {url} -> {r.status_code}")
        return dict(r.headers)
    except requests.RequestException as e:
        print(f"[!] {url} error: {e}")
        return {}


# ---------------------------------------------------------------------------
# Step 4 – NVD CVE lookup
# ---------------------------------------------------------------------------

def query_nvd(product: str, version: str, api_key: Optional[str]) -> List[Dict[str, str]]:
    """Query NVD API for CVEs matching product and version. Returns list of CVEs."""
    if not product:
        return []
    base_url = "https://services.nvd.nist.gov/rest/json/cves/2.0"
    params = {"keywordSearch": f"{product} {version}"}
    headers = {"User-Agent": "BugBountyScanner/1.0"}
    if api_key:
        headers["apiKey"] = api_key
    try:
        r = requests.get(base_url, params=params, headers=headers, timeout=15)
        r.raise_for_status()
        data = r.json()
        return data.get("vulnerabilities", [])
    except requests.RequestException as e:
        print(f"[!] NVD query error for {product} {version}: {e}")
        return []


# ---------------------------------------------------------------------------
# Step 5 – Nuclei integration
# ---------------------------------------------------------------------------

def run_nuclei(urls: List[str], output_file: Path) -> None:
    """Run nuclei with default template set against *urls*."""
    cmd = ["nuclei", "-o", str(output_file)]
    print(f"[+] Launching nuclei scan -> {output_file}")
    p = subprocess.Popen(cmd, stdin=subprocess.PIPE, text=True)
    try:
        for url in urls:
            p.stdin.write(url + "\n")
        p.stdin.close()
        p.communicate()
    except KeyboardInterrupt:
        p.kill()
        print("[!] Nuclei scan interrupted")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_cli() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Bug Bounty enumeration helper")
    parser.add_argument("-t", "--targets", nargs="+", required=True, help="Target hosts or CIDR ranges")
    parser.add_argument("--top", type=int, default=100, help="Top N ports to scan (default 100)")
    parser.add_argument("--xml", default="scan.xml", help="Path to save Nmap XML")
    parser.add_argument("--nuclei", action="store_true", help="Run nuclei on discovered web services")
    return parser


# ---------------------------------------------------------------------------
# Main flow
# ---------------------------------------------------------------------------

def main():
    args = build_cli().parse_args()
    xml_path = Path(args.xml).expanduser()

    # 1. Nmap scan
    nmap_scan(args.targets, args.top, xml_path)

    # 2. Parse XML
    services = parse_nmap_xml(xml_path)
    if not services:
        print("[!] No services found – exiting")
        sys.exit(1)

    # 3. Prepare web service list for nuclei and header probing
    web_services = [s for s in services if "http" in s["service"]]

    # 4. Display table & probe headers
    print("\n=== Discovered Services ===")
    for s in services:
        print(f"{s['ip']}:{s['port']}\t{s['product']} {s['version']}")

    header_store: Dict[Tuple[str, str], Dict[str, str]] = {}
    for ws in web_services:
        headers = probe_http_headers(ws["ip"], ws["port"], ssl="https" in ws["service"])
        header_store[(ws["ip"], ws["port"])] = headers

    # 5. NVD lookups (dedup by product/version)
    api_key = os.getenv("NVD_API_KEY")
    cve_cache: Dict[Tuple[str, str], List[Dict[str, str]]] = {}
    for svc in services:
        key = (svc["product"], svc["version"])
        if key not in cve_cache:
            time.sleep(1)  # simple rate limit
            cve_cache[key] = query_nvd(*key, api_key)

    print("\n=== Vulnerability Summary ===")
    for (product, version), cves in cve_cache.items():
        if not product:
            continue
        print(f"{product} {version}: {len(cves)} CVEs found")
        for cve in cves[:5]:  # show first 5 only
            cve_id = cve.get("cve", {}).get("id")
            cve_score = cve.get("cve", {}).get("metrics", {}).get("cvssMetricV31", [{}])[0].get("cvssData", {}).get("baseScore")
            print(f"  • {cve_id} (score: {cve_score})")

    # 6. Nuclei optional
    if args.nuclei and web_services:
        urls = [f"http{'s' if 'https' in ws['service'] else ''}://{ws['ip']}:{ws['port']}" for ws in web_services]
        run_nuclei(urls, Path("nuclei_results.txt"))

    print("\n[+] Scan complete.")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n[!] Interrupted by user")
