# evilgrade Testing Guide (SEC-AUTH-2026-01)

This guide explains how to test evilgrade modules under authorized CTO authorization SEC-AUTH-2026-01.

## Quick Start: Validate Modules (No Dependencies)

```bash
cd /Users/famato/dev/evilgrade

# Run module validation suite (requires authorization document)
./test_emudhra_authorized.sh
```

**Output:**
- Verifies 10 modules across Windows, Linux, macOS, and Supply Chain categories
- Generates findings report with authorization timestamp
- Lists available emudhra CA certificates
- No SSL or Perl dependencies required

**What it tests:**
- Module files exist and are valid
- Authorization document (SEC-AUTH-2026-01) is present
- emudhra certificates are available in certs/emudhra_authorized/

---

## Full Testing: Running evilgrade (Requires Dependencies)

### Prerequisites

1. **Perl with SSL Support**
   ```bash
   # Install Perl from Homebrew (includes SSL modules)
   brew install perl openssl
   ```

2. **Required Perl Modules**
   ```bash
   # Install via cpan
   cpan Data::Dump IO::Socket::SSL Net::SSLeay
   ```

3. **System Requirements**
   - Sudo access (for ports < 1024)
   - OpenSSL installed
   - Linux/macOS/BSD with BSD socket support

### Running a Module

**Option 1: Use wrapper script (after setup)**
```bash
cd /Users/famato/dev/evilgrade

# First time: Setup environment
./setup_evilgrade.sh

# Then run modules
sudo ./evilgrade.sh --module windows_cryptoapi --ssl \
  --cert "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.pem" \
  --key "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.key" \
  --port 443 --interface 127.0.0.1
```

**Option 2: Direct Perl (after installing dependencies)**
```bash
export PERL5LIB=/Users/famato/dev/evilgrade:/opt/homebrew/lib/perl5/site_perl/5.44

sudo /opt/homebrew/bin/perl ./evilgrade --module macos_installer_rce --ssl \
  --cert "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.pem" \
  --key "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.key" \
  --port 443 --interface 127.0.0.1
```

---

## Testing Workflow

### 1. Validate Modules (Always Safe)
```bash
./test_emudhra_authorized.sh
```
✅ No sudo needed
✅ No SSL dependencies
✅ Confirms authorization context
✅ Lists available modules and certificates

### 2. Verify emudhra Certificates
```bash
ls -la certs/emudhra_authorized/

# Output example:
# CN=EM DV TLS CA - G3B,O=eMudhra BV,C=NL.pem
# CN=EM DV TLS CA - G3C,O=eMudhra Inc,C=US.pem
# CN=EM EV TLS CA - G3B,O=eMudhra BV,C=NL.pem
# CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.key
# (etc - 8 total certificates)
```

### 3. Review Available Modules
```bash
# Windows modules
ls modules/windows/ | head

# Linux modules  
ls modules/linux/ | head

# macOS modules
ls modules/macos/ | head

# Enterprise infrastructure
ls modules/enterprise/ | head
```

### 4. Import Findings to Faraday
```bash
# After running tests, capture findings
./test_emudhra_authorized.sh > findings_$(date +%Y%m%d_%H%M%S).txt

# Import to Faraday workspace
faraday-cli workspace select <your-workspace>
faraday-cli report findings_*.txt
```

---

## Authorization Context

**Document:** SEC-AUTH-2026-01  
**Issuer:** Gabriel Franco, CTO of Faraday  
**Date:** 10/01/2026  
**Validity:** 12 months from signature  
**Scope:** Internal Faraday infrastructure testing (Linux/macOS/Windows)  

**Location:**
```
/Users/famato/Downloads/Faraday_Autorizacion_CTO_Verificacion_Actualizaciones_y_Pentest_Interno.pdf
```

---

## Available Modules by Category

### Windows (21 modules)
- windows_cryptoapi - CryptoAPI spoofing
- windows_directwrite_rce - DirectWrite code execution
- windows_installer_privesc - Installer privilege escalation
- windows_kernel_eop - Kernel exploitation
- (etc)

### Linux (19 modules)
- linux_copy_fail - Page cache vulnerability
- linux_kernel_ptr - Kernel pointer exposure
- (etc)

### macOS (18 modules)
- macos_installer_rce - Installer RCE
- macos_gatekeeper_bypass - Gatekeeper bypass
- (etc)

### Enterprise (12 modules)
- vmware_vcenter_auth - vCenter authentication
- (etc)

### Package Managers (22 modules)
- npm_package_injection - npm registry poisoning
- pypi_malicious_package - PyPI injection
- (etc)

### Browsers (9 modules)
- chrome_sandbox_escape - Chrome isolation bypass
- (etc)

### More Categories
- AI/ML (6) - Model poisoning
- Dev Tools (8) - IDE vulnerabilities
- IoT/Firmware (13)
- Security/VPN (8)
- Misc (5)

---

## Troubleshooting

### "Can't locate Time::HiRes"
✅ **Resolved** - Fixed in isrcore/Shell.pm with fallback implementation

### "Can't locate IO::Socket::SSL"
**Solution:**
```bash
brew install openssl
cpan IO::Socket::SSL Net::SSLeay
```

### "Permission denied" on port 443
**Solution:** Use sudo
```bash
sudo ./evilgrade.sh --module windows_cryptoapi --port 443 ...
```

### "Module not found"
**Solution:** Verify PERL5LIB includes current directory
```bash
export PERL5LIB=/Users/famato/dev/evilgrade:$PERL5LIB
./evilgrade.sh ...
```

---

## Next Steps

1. ✅ Run `./test_emudhra_authorized.sh` to validate modules
2. ✅ Review findings in generated report
3. ✅ Install Perl dependencies if needed for full testing
4. ✅ Run specific modules with emudhra certificates
5. ✅ Document findings and import to Faraday

For detailed authorization scope, see:
- Authorization document: SEC-AUTH-2026-01
- README.md - Authorized Testing Only section
- EMUDHRA_INTEGRATION_GUIDE.md - Technical integration

---

**Status:** Production Ready  
**Authorization:** CTO SEC-AUTH-2026-01  
**Last Updated:** 2026-10-27
