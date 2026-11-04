# eMudhra CA MITM demos (brew / pip / git) via real evilgrade

Demonstrates the **current** macOS exposure from the Oct 2026 eMudhra
intermediate-CA key compromise: tools that validate TLS against
`/etc/ssl/cert.pem` still trust the revoked, Apple-blocked intermediate
`EM DV TLS CA - G3C`, so an on-path attacker with a leaf signed by it (the repo
ships the real compromised intermediate + key) MITMs their HTTPS and gets
code execution through package/installer flows.

All three demos drive **evilgrade's own webserver** (via `serve.pl`) with the
eMudhra cert set (`certs/emudhra_mitm`, SAN = the GitHub + PyPI hosts).

| Demo | Victim command | Vulnerable binary | Result |
|---|---|---|---|
| `run_brew.sh` | `bash -c "$(curl -fsSL …/install.sh)"` | `/usr/bin/curl` | **one-shot RCE** |
| `run_pip.sh` | `python3 -m pip install …` | system `/usr/bin/python3` | **RCE** (setup.py at install) |
| `run_git.sh` | `git clone https://github.com/…` | OpenSSL-backed git | transport tampering (RCE is a 2nd step) |

Not affected (honest limits, verified on this host):
- **Homebrew's** `python3` — uses its own cert bundle (no `AAA` root) → pip via it rejects.
- **Apple `/usr/bin/git`** default backend (Secure Transport) → rejects; its
  `openssl` backend accepts.
- Anything on **Apple frameworks** (Secure Transport) → Apple's block list catches it.

## Run

```sh
./demo/emudhra_mitm/run_brew.sh
./demo/emudhra_mitm/run_pip.sh
./demo/emudhra_mitm/run_git.sh
```

Each starts evilgrade's webserver on a free port, models the DNS spoof with
`curl --resolve` (in a real run evilgrade's DNS server does this), and prints
the proof (`/tmp/OWNED_BY_BREW` / `/tmp/OWNED_BY_PIP` + reverse callback).

## Run it yourself through evilgrade's shell

See `RUN-EVILGRADE.md` for the interactive `set sslcert / configure / start`
walkthrough.

## evilgrade modules added

- `modules/macos/homebrew_update.pm` — serves a malicious `install.sh`.
- `modules/package_managers/pypi_update.pm` — serves a PEP503 index + malicious sdist.
- Cert set: `certs/emudhra_mitm/{server.pem,server.key}` (leaf for the GitHub/PyPI
  hosts, signed by the compromised eMudhra intermediate).

## Mitigation (from the field report)

- One-off: `CURL_SSL_BACKEND=secure-transport curl …` (rejects the chain).
- Remove `emSign ECC Root CA - G3` (and optionally `AAA Certificate Services`)
  from `/etc/ssl/cert.pem` per Apple's guidance; may break legit sites and can
  be reverted by an OS update.
- Don't assume a macOS point update silently fixes `cert.pem`.

## Ethics / scope

Lab only, loopback only. No real Homebrew/PyPI/GitHub host is contacted
(`--resolve` points the names at `127.0.0.1`), nothing is really installed.
Use only against systems you are authorized to test.
