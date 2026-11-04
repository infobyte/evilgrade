#!/bin/bash
###############################################################################
# cleanup.sh - stop any evilgrade/demo processes and free the demo ports.
#
# Run this between PoC runs, or whenever a runner reports "FAILED to bind" or
# the victim gets HTTP 000 / "Empty reply" (a stale forked webserver is still
# holding the port).
###############################################################################
echo "[cleanup] killing serve.pl, evilgrade shells, and forked webservers..."
# the webserver is a fork of the perl process; match both the launcher and the
# project lib path so forked children are caught too.
pkill -9 -f 'demo/emudhra_mitm/serve.pl' 2>/dev/null
pkill -9 -f 'perl ./evilgrade'           2>/dev/null
pkill -9 -f 'isrcore'                     2>/dev/null
pkill    -f 'nc -l 4444'                  2>/dev/null
sleep 1

echo "[cleanup] checking demo ports..."
STILL=0
for p in 443 4444 9443 9444 9543 9544 12443 12444 18443 18444; do
    if lsof -nP -iTCP:$p -sTCP:LISTEN >/dev/null 2>&1; then
        lsof -nP -iTCP:$p -sTCP:LISTEN 2>/dev/null | sed -n 2p | awk -v P=$p '{print "   port "P" still held by "$1" (pid "$2")"}'
        STILL=1
    fi
done
[ "$STILL" = 0 ] && echo "   all demo ports free."

echo "[cleanup] removing proof/temp files..."
rm -f /tmp/OWNED_BY_PIP /tmp/pip_cb.log /tmp/eg_pip.log /tmp/evilpkg.tgz
rm -rf /tmp/pip_rce
echo "[cleanup] done."
