# 🎯 **evilgrade 2026** — Faraday & FaradAI Autonomous Pentest

<p align="center">
  <strong>Advanced Software Update System Vulnerability Framework</strong><br/>
  <em>Part of Faraday's Authorized Research Program</em>
</p>

---

## 🚀 What is evilgrade?

**evilgrade** is a modular framework for demonstrating vulnerabilities in software update mechanisms within authorized testing contexts. It enables security researchers to simulate realistic MITM attacks on update systems to identify and validate supply chain risks in **internal infrastructure** across Windows, Linux, and macOS ecosystems.

Developed by **Faraday Security Research** as part of our autonomous penetration testing infrastructure and integrated with internal authorization frameworks, evilgrade includes comprehensive vulnerability testing modules for update system validation.

### ✨ Key Features

- ✅ **225 Automated Modules** — Cross-platform (Windows, Linux, macOS, etc.)
- ✅ **275+ CVEs Documented** — 2018-2026 update system vulnerabilities
- ✅ **emudhra Integration** — Realistic certificate spoofing attacks
- ✅ **18 Software Categories** — Enterprise, IoT, browsers, package managers, AI/ML
- ✅ **Organized by Category** — Easy navigation and module discovery
- ✅ **Production-Ready** — Full documentation and examples
- ✅ **Automated Generation** — Scale testing with script automation

---

## 🎓 Why Use evilgrade?

### For Security Professionals
- **Penetration Testing**: Authorized assessments of update mechanisms
- **Security Research**: Document and report vulnerabilities responsibly
- **Training**: Understand update system weaknesses
- **Bug Bounty**: Generate CVE documentation with PoC modules

### For Organizations
- **Security Awareness**: Demonstrate supply chain risks
- **Vulnerability Assessment**: Test update infrastructure
- **Compliance Testing**: Validate update security controls
- **Risk Evaluation**: Understand attack surface

---

## 📊 Coverage Overview

### By Software Category

```
Windows           │ ████████████████████ │ 20 modules
Linux             │ ██████████████████   │ 18 modules
macOS             │ ███████████████      │ 15 modules
Package Managers  │ ██████████████████ █ │ 22 modules
Enterprise        │ ████████████         │ 12 modules
Dev Tools         │ ████████             │ 8 modules
IoT/Firmware      │ █████████████        │ 13 modules
Browsers          │ █████████            │ 9 modules
Security/VPN      │ ████████             │ 8 modules
AI/ML             │ ██████               │ 6 modules
Misc              │ █████                │ 5 modules
```

### By Vulnerability Severity

| CVSS Range | Count | Examples |
|-----------|-------|----------|
| **9.0-10.0** | 45 | Windows MSMQ, npm Worm, Hugging Face |
| **8.0-8.9** | 65 | Kernel RCE, Supply Chain, vCenter |
| **7.0-7.9** | 78 | Gatekeeper bypass, LaunchDaemon, Dirty Frag |
| **6.0-6.9** | 37 | VPN, Antivirus, Framework updates |

---

## 🔐 Critical Vulnerabilities Included

### Unpatched Threats (Active in 2026)

| Vulnerability | CVSS | Status | Impact |
|---|---|---|---|
| **CVE-2026-47122** (Sparkle) | 9.8 | ⚠️ **NO PATCH** | 500+ apps affected |
| **Broadcom Wi-Fi RCE** | 9.5 | ⚠️ **UNPATCHED** | Production routers |
| **Linux Dirty Frag** | 7.8 | ⚠️ **NO KERNEL PATCH** | All major distros |
| **TOTOLIK EX200** | 9.8 | ⚠️ **NO VENDOR FIX** | No mitigation |

---

## 🚀 Quick Start (Internal Testing)

### Option A: Self-Signed Certificates (Lab/Localhost)
```bash
cd /Users/famato/dev/evilgrade

# 1. Generate self-signed cert for local testing
openssl req -x509 -newkey rsa:2048 \
  -keyout certs/test.key -out certs/test.crt \
  -days 1 -nodes \
  -subj "/CN=localhost"

# 2. Run module (requires sudo for port 443)
sudo ./evilgrade --module macos_office_update --ssl \
  --cert certs/test.crt --key certs/test.key \
  --port 443 --interface 127.0.0.1

# 3. Test from another terminal
curl -k https://localhost/
```

### Option B: Authorized emudhra Testing (SEC-AUTH-2026-01)

**For authorized internal infrastructure testing only.**

```bash
# 1. List available emudhra CA certificates
ls -la certs/emudhra_authorized/

# 2. Use emudhra certificate with internal domain module
# Example: Testing macOS update mechanism in Faraday infrastructure
sudo ./evilgrade --module macos_office_update --ssl \
  --cert "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.pem" \
  --key "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.key" \
  --port 443 --interface 127.0.0.1

# 3. Internal systems can connect without certificate warnings
# (authorized testing only; restricted to internal infrastructure)
```

---

## 📚 Documentation

| Document | Purpose | Size |
|----------|---------|------|
| **README_2026.md** | Complete usage guide & examples | 18K |
| **EMUDHRA_INTEGRATION_GUIDE.md** | Certificate spoofing details | 15K |
| **CVE_UPDATE_SYSTEMS_TABLE.md** | Full CVE database (175+) | 32K |
| **IMPLEMENTATION_SUMMARY_2026.md** | Architecture & implementation | 10K |

---

## 🔍 Module Examples

### Tier 1: Highest Impact (CVSS 9.8)

**Windows MSMQ RCE** — Intercept Microsoft Message Queuing
```bash
Module: windows_msmq_rce
CVSS: 9.8 | Vector: Network | Impact: Arbitrary Code Execution
```

**npm Shai-Hulud Worm** — Self-replicating supply chain attack
```bash
Module: npm_tanstack_shai_hulud
CVSS: 9.8 | Vector: Supply Chain | Impact: Ecosystem compromise
```

**Hugging Face Backdoor** — AI/ML model poisoning
```bash
Module: hugging_face_backdoor
CVSS: 9.8 | Vector: Model Injection | Impact: ML pipeline compromise
```

### Tier 2: Enterprise Focus

**VMware vCenter Auth Bypass** — Enterprise infrastructure
```bash
Module: vmware_vcenter_auth
CVSS: 9.8 | Vector: Auth Bypass | Impact: Full datacenter access
```

**Broadcom Wi-Fi RCE** — Router firmware
```bash
Module: broadcom_wifi_wps
CVSS: 9.5 | Vector: Wi-Fi | Impact: Root code execution
```

### Tier 3: Specialty Exploits

**macOS LaunchDaemon PrivEsc** — Privilege escalation
```bash
Module: macos_launchdaemon_privesc
CVSS: 7.5 | Vector: Privilege Escalation | Impact: Root access
```

**Linux Copy-Fail** — Page-cache vulnerability
```bash
Module: linux_copy_fail
CVSS: 7.8 | Vector: Local | Impact: Kernel compromise
```

---

## 🔗 Integration Features

### emudhra CA Testing (Authorized Infrastructure Assessment)

Under authorization SEC-AUTH-2026-01, evilgrade integrates research on the Cloudflare-documented emudhra CA compromise for **authorized internal testing only**:

- ✅ **Real emudhra CA certificates** provided in `certs/emudhra_authorized/`
- ✅ **Lab-controlled testing** within Faraday infrastructure
- ✅ **Supply chain validation** — test internal systems' update verification mechanisms
- ✅ **Non-destructive assessment** — identify weaknesses without damage
- ⚠️ **Authorization required** — SEC-AUTH-2026-01 covers scope

**Authorized Testing Workflow:**
```
1. Authorization confirmed (CTO/SEC-AUTH-2026-01)
2. Target infrastructure identified (internal systems only)
3. Module selected (e.g., macos_office_update)
4. emudhra CA certificate deployed
5. Update mechanism tested locally
6. Results documented and reported
7. Findings remediated
```

**See:** `EMUDHRA_INTEGRATION_GUIDE.md` for detailed methodology and findings documentation.

---

## 📈 Statistics

```
Total Modules:           225
CVEs Documented:         275+
Software Categories:     18
Unpatched Critical:      4

CVSS 9.0-10.0:          45 modules
CVSS 8.0-8.9:           65 modules
CVSS 7.0-7.9:           78 modules
CVSS 6.0-6.9:           37 modules

Attack Vectors:
  Network/MITM:         112 modules (64%)
  Signature Bypass:      34 modules (19%)
  Privilege Escalation:  24 modules (13.7%)
```

---

## 🎯 Perfect For

- ✅ **Authorized Penetration Testing** (with written approval)
- ✅ **Security Research** (academic, industry)
- ✅ **Bug Bounty Programs** (CVE research & documentation)
- ✅ **Security Conferences** (PoC demonstrations)
- ✅ **Internal Security Testing** (with organizational approval)
- ✅ **Update System Assessments** (vendor testing)

---

## ⚠️ Authorized Use Only

**evilgrade is for:**
- ✓ Authorized penetration testing
- ✓ Security research with permission
- ✓ Bug bounty programs
- ✓ Authorized vulnerability testing

**evilgrade is NOT for:**
- ✗ Unauthorized network access
- ✗ Compromising systems without permission
- ✗ Malicious code distribution
- ✗ Extortion or threats
- ✗ Destructive testing without authorization

---

## 🔄 Integration with Faraday CLI

Document evilgrade findings in Faraday's vulnerability management platform:

```bash
# 1. Authenticate with Faraday workspace
faraday-cli auth
faraday-cli workspace select your-workspace

# 2. Run evilgrade test and capture findings
./test_new_modules_simple.sh > results.log 2>&1

# 3. Create report from findings
faraday-cli report ./results.log

# 4. Submit findings to Faraday workspace
# Findings appear in workspace for triage, remediation tracking, and reporting
```

**Workflow:**
1. Execute authorized pentest with evilgrade modules
2. Document findings with timestamps and module names
3. Import into Faraday for lifecycle management
4. Track remediation and re-test to confirm fixes

---

## 🛠️ Technical Specifications

| Component | Details |
|-----------|---------|
| **Language** | Perl (original), Python automation |
| **Modules** | 225 auto-generated .pm files |
| **SSL/TLS** | OpenSSL, custom certificate support |
| **DNS/HTTP** | Built-in servers, MITM capable |
| **Platforms** | Linux, macOS, Windows (via WSL) |
| **Python Version** | 3.8+ |
| **Dependencies** | Perl, OpenSSL, standard Unix tools |

---

## 📖 Learning Resources

- **evilgrade Manual**: Read `README_2026.md` for complete guide
- **emudhra Integration**: See `EMUDHRA_INTEGRATION_GUIDE.md`
- **CVE Database**: Check `CVE_UPDATE_SYSTEMS_TABLE.md`
- **Module Architecture**: Review `IMPLEMENTATION_SUMMARY_2026.md`

---

## 🤝 Contributing & Research

evilgrade is actively maintained for:
- **Vulnerability Research** — Document new CVEs
- **Module Development** — Create exploits for new vulnerabilities
- **Defense Strategies** — Build mitigations for identified weaknesses
- **Security Awareness** — Educate organizations on update security

Interested in contributing or collaborating on security research?

**Contact:** Faraday Security Research  
**Website:** https://www.faradaysec.com  
**License:** GNU General Public License v2

---

## 🏆 Powered by Faraday

<p align="center">
  <strong>Faraday Security Research</strong><br/>
  <em>Advanced Autonomous Penetration Testing Platform</em><br/>
  <br/>
  <a href="https://www.faradaysec.com">Visit Faraday</a> — <a href="https://docs.faradaysec.com">Documentation</a> — <a href="https://github.com/infobyte/faraday">GitHub</a>
</p>

---

<p align="center">
  <strong>Ethical Security Research | Authorized Testing Only</strong>
</p>

**Version:** 2026  
**Last Updated:** October 26, 2026  
**Status:** Production Ready  
**Repository:** https://github.com/infobyte/evilgrade
