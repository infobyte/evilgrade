#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PERL5LIB="$SCRIPT_DIR:$SCRIPT_DIR/isrcore:$PERL5LIB"

# Use Homebrew Perl if available
if [ -x /opt/homebrew/bin/perl ]; then
    exec /opt/homebrew/bin/perl "$SCRIPT_DIR/evilgrade" "$@"
elif [ -x /usr/local/bin/perl ]; then
    exec /usr/local/bin/perl "$SCRIPT_DIR/evilgrade" "$@"
else
    exec perl "$SCRIPT_DIR/evilgrade" "$@"
fi
