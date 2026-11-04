# _lib.sh - shared helpers for the eMudhra MITM demo runners (sourced).

# pick_port VARNAME : set VARNAME to the first free TCP port from the list
pick_port() {
    local __var="$1"; shift
    local p
    for p in "$@"; do
        lsof -nP -iTCP:"$p" -sTCP:LISTEN >/dev/null 2>&1 || { printf -v "$__var" '%s' "$p"; return 0; }
    done
    printf -v "$__var" '%s' "$1"   # fallback: first
    return 0
}

# start_evilgrade <port> <logfile> <module-spec...>
# Starts serve.pl, polls up to 20s for the SSL port to bind.
# Sets global EG_PID. Returns 0 on success, 1 on failure (and prints the log).
start_evilgrade() {
    local port="$1" logf="$2"; shift 2
    pkill -f 'demo/emudhra_mitm/serve.pl' >/dev/null 2>&1; sleep 0.5
    /usr/bin/perl demo/emudhra_mitm/serve.pl "$port" "$@" > "$logf" 2>&1 &
    EG_PID=$!
    local i
    for i in $(seq 1 20); do
        if lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
            echo "   evilgrade listening on :$port (after ${i}s)"
            return 0
        fi
        # bail early if serve.pl died
        kill -0 "$EG_PID" 2>/dev/null || { echo "   serve.pl exited early"; break; }
        sleep 1
    done
    echo "   FAILED to bind :$port"
    echo "   ---- serve.pl log (tail) ----"
    grep -ivE 'Loading module' "$logf" | tail -15 | sed 's/^/   /'
    kill "$EG_PID" >/dev/null 2>&1
    return 1
}
