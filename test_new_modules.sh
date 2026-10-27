#!/bin/bash
###############################################################################
# test_new_modules.sh
# Test 10 new automated evilgrade modules
# Run: bash test_new_modules.sh
###############################################################################

set -e
cd /Users/famato/dev/evilgrade

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          TESTING 10 NEW AUTOMATED MODULES                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Array of modules to test
MODULES=(
    "windows_msmq_rce:update.windows.msmq:Windows MSMQ RCE (9.8)"
    "linux_copy_fail:updates.linux.copy:Linux Copy-Fail (7.8)"
    "npm_tanstack_shai_hulud:registry.npmjs.com:npm Shai-Hulud Worm (9.8)"
    "vmware_vcenter_auth:vcenter.local:VMware vCenter Auth (9.8)"
    "broadcom_wifi_wps:router.wifi.local:Broadcom Wi-Fi WPS (9.5)"
    "hugging_face_backdoor:huggingface.co:Hugging Face Backdoor (9.8)"
    "chrome_sandbox_escape:updates.chrome.local:Chrome Sandbox (9.6)"
    "vscode_extensions_rce:vscode.updates.local:VS Code Extensions (5.6)"
    "pypi_litellm:pypi.org:PyPI LiteLLM (9.0)"
    "macos_launchdaemon_privesc:macos.launchd.local:macOS LaunchD (7.5)"
)

echo "[*] Preparing test environment..."
echo ""

# Create payload directory
mkdir -p include/test_modules

# Create test payload (safe)
cat > include/test_modules/payload.txt << 'EOF'
=== TEST PAYLOAD ===
Module Test Suite
Status: SUCCESS
No executable code - safe testing only

Date: 2026-10-26
Test Type: SSL/Certificate Validation
EOF

echo "✅ Test payload created"
echo ""

# Counter
TEST_NUM=0
SUCCESS=0
FAIL=0

# Test each module
for MODULE_INFO in "${MODULES[@]}"; do
    TEST_NUM=$((TEST_NUM + 1))

    IFS=':' read -r MODULE_NAME DOMAIN DESC <<< "$MODULE_INFO"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "TEST $TEST_NUM: $DESC"
    echo "Module: $MODULE_NAME"
    echo "Domain: $DOMAIN"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Check if module exists
    MODULE_PATH=$(find modules -name "${MODULE_NAME}.pm" 2>/dev/null | head -1)

    if [ -z "$MODULE_PATH" ]; then
        echo "❌ Module not found: $MODULE_NAME"
        FAIL=$((FAIL + 1))
        echo ""
        continue
    fi

    echo "✓ Module found: $MODULE_PATH"

    # Create certificate for this domain
    CERT_FILE="certs/test_${MODULE_NAME}.crt"
    KEY_FILE="certs/test_${MODULE_NAME}.key"

    echo "  Generating certificate for $DOMAIN..."
    openssl req -x509 -newkey rsa:2048 \
      -keyout "$KEY_FILE" \
      -out "$CERT_FILE" \
      -days 1 -nodes \
      -subj "/CN=$DOMAIN" \
      -addext "subjectAltName=DNS:$DOMAIN,DNS:localhost,IP:127.0.0.1" \
      2>/dev/null

    echo "  ✓ Certificate created"

    # Add to hosts
    echo "  Adding to /etc/hosts..."
    echo "127.0.0.1 $DOMAIN" | sudo tee -a /etc/hosts > /dev/null 2>&1
    echo "  ✓ /etc/hosts updated"

    # Test module loading
    echo "  Testing module..."

    # Use Perl to test if module loads
    PERL_TEST=$(perl -I./modules -e "require modules::${MODULE_NAME}; print 'OK'" 2>&1)

    if echo "$PERL_TEST" | grep -q "OK"; then
        echo "  ✓ Module loads successfully"
        SUCCESS=$((SUCCESS + 1))

        # Show module metadata
        echo ""
        echo "  Module Metadata:"
        grep -E "cve|cvss|type|year" "$MODULE_PATH" | head -4 | sed 's/^/    /'

    else
        echo "  ❌ Module load failed: $PERL_TEST"
        FAIL=$((FAIL + 1))
    fi

    # Show request patterns
    echo ""
    echo "  Request Patterns:"
    grep -E "'req'" "$MODULE_PATH" | head -3 | sed 's/^/    /'

    echo ""
done

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                      TEST RESULTS                               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Total Tests:     $TEST_NUM"
echo "✅ Successful:    $SUCCESS"
echo "❌ Failed:        $FAIL"
echo ""

# Show installed hosts
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Hosts Configuration:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
grep "test\|msmq\|copy\|npmjs\|vcenter\|wifi\|huggingface\|chrome\|vscode\|pypi\|launchd" /etc/hosts 2>/dev/null | head -10 || echo "(no test entries)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Certificates Generated:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ls -1 certs/test_*.crt 2>/dev/null | wc -l | xargs echo "Total:"
ls -lh certs/test_*.crt 2>/dev/null | tail -5

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  NEXT: Launch evilgrade with any of these modules              ║"
echo "║  Example:                                                       ║"
echo "║  sudo ./evilgrade --module windows_msmq_rce --ssl \\           ║"
echo "║    --cert certs/test_windows_msmq_rce.crt \\                  ║"
echo "║    --key certs/test_windows_msmq_rce.key \\                   ║"
echo "║    --port 443 --interface 127.0.0.1                           ║"
echo "║                                                                 ║"
echo "║  Test with (from another terminal):                           ║"
echo "║  curl -k https://update.windows.msmq/                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Cleanup note
echo "📝 Note: To cleanup /etc/hosts after testing:"
echo "   sudo sed -i '' '/test\\|msmq\\|copy\\|npmjs\\|vcenter\\|wifi\\|huggingface\\|chrome\\|vscode\\|pypi\\|launchd/d' /etc/hosts"
echo ""
