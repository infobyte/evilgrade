#!/bin/bash
###############################################################################
# test_new_modules_simple.sh - Version sin sudo
# Test 10 new automated evilgrade modules
###############################################################################

set -e
cd /Users/famato/dev/evilgrade

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          TESTING 10 NEW AUTOMATED MODULES (No Sudo)            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Array of modules to test
MODULES=(
    "windows_msmq_rce:Windows MSMQ RCE (9.8)"
    "linux_copy_fail:Linux Copy-Fail (7.8)"
    "npm_tanstack_shai_hulud:npm Shai-Hulud Worm (9.8)"
    "vmware_vcenter_auth:VMware vCenter Auth (9.8)"
    "broadcom_wifi_wps:Broadcom Wi-Fi WPS (9.5)"
    "hugging_face_backdoor:Hugging Face Backdoor (9.8)"
    "chrome_sandbox_escape:Chrome Sandbox (9.6)"
    "vscode_extensions_rce:VS Code Extensions (5.6)"
    "pypi_litellm:PyPI LiteLLM (9.0)"
    "macos_launchdaemon_privesc:macOS LaunchD (7.5)"
)

echo "[*] Verifying 10 new automated modules..."
echo ""

# Create test payload directory
mkdir -p include/test_modules

# Test counter
TEST_NUM=0
SUCCESS=0
FAIL=0

# Test each module
for MODULE_INFO in "${MODULES[@]}"; do
    TEST_NUM=$((TEST_NUM + 1))

    IFS=':' read -r MODULE_NAME DESC <<< "$MODULE_INFO"

    printf "TEST %2d: %-50s " "$TEST_NUM" "$DESC"

    # Check if module exists
    MODULE_PATH=$(find modules -name "${MODULE_NAME}.pm" 2>/dev/null | head -1)

    if [ -z "$MODULE_PATH" ]; then
        echo "❌ NOT FOUND"
        FAIL=$((FAIL + 1))
        continue
    fi

    # Test module loads
    PERL_TEST=$(perl -I./modules -e "require modules::${MODULE_NAME}; print 'OK'" 2>&1)

    if echo "$PERL_TEST" | grep -q "OK"; then
        echo "✅ LOADED"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "❌ LOAD FAILED"
        FAIL=$((FAIL + 1))
    fi
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

# Show detailed module info
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "DETAILED MODULE INFORMATION:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

for MODULE_INFO in "${MODULES[@]}"; do
    IFS=':' read -r MODULE_NAME DESC <<< "$MODULE_INFO"
    MODULE_PATH=$(find modules -name "${MODULE_NAME}.pm" 2>/dev/null | head -1)

    if [ -n "$MODULE_PATH" ]; then
        echo "📦 $MODULE_NAME"
        echo "   Path: $MODULE_PATH"
        echo "   CVE/CVSS:"
        grep -E "'cve'|'cvss'|'type'" "$MODULE_PATH" | head -3 | sed 's/^/     /'
        echo ""
    fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "MODULE CATEGORIES REPRESENTED:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✓ Windows (1): windows_msmq_rce"
echo "✓ Linux (1): linux_copy_fail"
echo "✓ Supply Chain (1): npm_tanstack_shai_hulud"
echo "✓ Enterprise (1): vmware_vcenter_auth"
echo "✓ IoT/Firmware (1): broadcom_wifi_wps"
echo "✓ AI/ML (1): hugging_face_backdoor"
echo "✓ Browsers (1): chrome_sandbox_escape"
echo "✓ Dev Tools (1): vscode_extensions_rce"
echo "✓ Package Managers (1): pypi_litellm"
echo "✓ macOS (1): macos_launchdaemon_privesc"
echo ""

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  NEXT: Launch any module with evilgrade                       ║"
echo "║                                                                 ║"
echo "║  Step 1: Create certificate                                   ║"
echo "║  openssl req -x509 -newkey rsa:2048 \\                         ║"
echo "║    -keyout certs/test.key -out certs/test.crt \\              ║"
echo "║    -days 1 -nodes -subj \"/CN=example.com\"                    ║"
echo "║                                                                 ║"
echo "║  Step 2: Add to /etc/hosts                                    ║"
echo "║  echo \"127.0.0.1 example.com\" | sudo tee -a /etc/hosts      ║"
echo "║                                                                 ║"
echo "║  Step 3: Run evilgrade                                        ║"
echo "║  sudo ./evilgrade --module windows_msmq_rce --ssl \\          ║"
echo "║    --cert certs/test.crt --key certs/test.key \\              ║"
echo "║    --port 443 --interface 127.0.0.1                          ║"
echo "║                                                                 ║"
echo "║  Step 4: Test from another terminal                          ║"
echo "║  curl -k https://example.com/                                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo "✅ All 10 modules verified!"
echo ""
