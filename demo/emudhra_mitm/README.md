# pip install MITM via the compromised eMudhra CA (real evilgrade)

Demonstrates the current macOS exposure from the Oct 2026 eMudhra
intermediate-CA key compromise, against **pip** — the one mainstream package
manager that still delegates integrity to the transport (PyPI does not sign
sdists, and `setup.py` runs at install time).

`pip install evilpkg` fetches a malicious sdist over TLS from evilgrade, which
presents a `pypi.org` leaf signed by the revoked, Apple-blocked eMudhra
intermediate `EM DV TLS CA - G3C` (SHA-256 `62:B7:F9:86…`, in the repo at
`certs/emudhra_authorized/`). The sdist's `setup.py` executes at build time →
code execution as the user.

## The one honest condition

**pip's default is NOT vulnerable.** pip ships its own vendored `certifi`
bundle (Mozilla roots), which does not contain the `AAA Certificate Services`
root the eMudhra intermediate chains to. pip is exploitable **only when it
validates against the system trust store** `/etc/ssl/cert.pem`, i.e. any of:

- `pip install --cert /etc/ssl/cert.pem …`
- `PIP_CERT=/etc/ssl/cert.pem`
- `pip.conf`: `[global] cert = /etc/ssl/cert.pem`
- a distro-/corp-packaged pip/python that uses the OS store instead of certifi

This is common in corporate environments — which are also exactly where an
eMudhra (or corporate) CA would be installed in the first place. The demos
model it with `--cert /etc/ssl/cert.pem`.

By contrast, Homebrew (`brew install`/`update`) is NOT exploitable: it verifies
a JWS-signed formula API and pins each bottle's SHA-256. VLC/OBS similarly sign
their content. pip is the outlier because sdists are unsigned.

## Run (automated, self-contained)

```sh
./demo/emudhra_mitm/run_pip.sh
```

It adds `pypi.org -> 127.0.0.1` to `/etc/hosts` (sudo; reverted on exit — this
is the DNS spoof a real attacker does on the network), starts evilgrade's
webserver with `pypi_update` + the eMudhra cert on a high port, runs a real
`pip install`, prints the proof (`/tmp/OWNED_BY_PIP` + reverse callback), and
shows the control: the same install with pip's default certifi is rejected.

## Run it yourself through evilgrade's shell

See `RUN-EVILGRADE.md` for the step-by-step manual walkthrough (interactive
evilgrade in one console, victim `pip install` in another).

## Files

- `modules/package_managers/pypi_update.pm` — serves the PEP503 index + sdist.
- `include/pip_mitm/` — the malicious sdist (`setup.py` drops `/tmp/OWNED_BY_PIP`
  and calls back to 127.0.0.1:4444) and its PEP503 index (relative href, so the
  sdist is served from the same host).
- `certs/emudhra_mitm/{server.pem,server.key}` — `pypi.org` leaf (SAN also
  covers files.pythonhosted.org, localhost, 127.0.0.1) signed by the
  compromised eMudhra intermediate.
- `demo/emudhra_mitm/` — `run_pip.sh` (automated), `console.sh` +
  `victim_pip.sh` (two-console), `serve.pl` (non-interactive webserver),
  `_lib.sh`, `cleanup.sh`.

## Mitigation (from the field report)

- Point pip back at a trusted bundle without the eMudhra root (pip's default
  certifi is already safe; the risk is an explicit `--cert`/`PIP_CERT`/pip.conf
  pointing at the system store).
- Remove `emSign ECC Root CA - G3` / `AAA Certificate Services` from
  `/etc/ssl/cert.pem` per Apple's guidance (may break legit sites; can be
  reverted by an OS update).

## Ethics / scope

Lab only, loopback only. The sdist is a harmless marker (drops a file +
loopback callback); no real PyPI host is contacted (`/etc/hosts` points the
name at 127.0.0.1). Use only against systems you are authorized to test.
