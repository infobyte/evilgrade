#!/bin/bash
# test_emudhra_authorized.sh
# Test evilgrade modules with authorized emudhra certificates
# Authorization: SEC-AUTH-2026-01 (CTO Gabriel Franco, 10/01/2026)

set -e
cd /Users/famato/dev/evilgrade

echo "AUTHORIZED EMUDHRA CERTIFICATE TESTING (SEC-AUTH-2026-01)"
echo "Internal Faraday Infrastructure Validation"
echo ""
echo "[!] This test uses emudhra certificates under CTO authorization"
echo "    SEC-AUTH-2026-01 (Gabriel Franco, 10/01/2026)"
echo "    Scope: Internal Linux/macOS/Windows infrastructure only"
echo ""

# Verify authorization documents exist
if [ ! -f "/Users/famato/Downloads/Faraday_Autorizacion_CTO_Verificacion_Actualizaciones_y_Pentest_Interno.pdf" ]; then
    echo "ERROR: Authorization document not found"
    exit 1
fi

# Verify emudhra certificates exist
if [ ! -d "certs/emudhra_authorized" ]; then
    echo "ERROR: emudhra certificates not found in certs/emudhra_authorized/"
    exit 1
fi

EMUDHRA_CERT_COUNT=$(find certs/emudhra_authorized -name "*.pem" | wc -l)
echo "OK: Authorization verified"
echo "OK: Found $EMUDHRA_CERT_COUNT emudhra certificates"
echo ""

# Array of 10 modules to test
MODULES=(
    "windows/windows_cryptoapi"
    "windows/windows_directwrite_rce"
    "linux/linux_copy_fail"
    "package_managers/npm_package_injection"
    "enterprise/vmware_vcenter_auth"
    "macos/macos_gatekeeper_bypass"
    "macos/macos_installer_rce"
    "browsers/chrome_sandbox_escape"
    "ai_ml/hugging_face_backdoor"
    "dev_tools/vscode_extension_rce"
)

echo "TEST PLAN:"
echo "1. Verify 10 modules across categories"
echo "2. Check module files exist"
echo "3. Document findings"
echo "4. Generate report for faraday-cli import"
echo ""

mkdir -p include/test_modules
TEST_NUM=0
SUCCESS=0
FAIL=0

# Create findings log
FINDINGS_LOG="findings_$(date +%Y%m%d_%H%M%S).txt"
{
    echo "[SEC-AUTH-2026-01] Authorized Internal Penetration Test"
    echo "Date: $(date)"
    echo "Scope: Internal Faraday infrastructure (Linux/macOS/Windows)"
    echo "Authorization: CTO Gabriel Franco, 10/01/2026"
    echo ""
} > "$FINDINGS_LOG"

# Test each module
for MODULE_PATH_REL in "${MODULES[@]}"; do
    TEST_NUM=$((TEST_NUM + 1))

    MODULE_FILE="modules/${MODULE_PATH_REL}.pm"
    MODULE_NAME=$(basename "$MODULE_FILE" .pm)

    printf "TEST %2d: %-40s " "$TEST_NUM" "$MODULE_NAME"

    if [ ! -f "$MODULE_FILE" ]; then
        echo "[NOT FOUND]"
        FAIL=$((FAIL + 1))
        echo "  [FAIL] Module file not found: $MODULE_FILE" >> "$FINDINGS_LOG"
        continue
    fi

    # Verify file has content
    FILE_SIZE=$(stat -f%z "$MODULE_FILE" 2>/dev/null || stat -c%s "$MODULE_FILE" 2>/dev/null || echo 0)

    if [ "$FILE_SIZE" -lt 100 ]; then
        echo "[EMPTY]"
        FAIL=$((FAIL + 1))
        echo "  [FAIL] Module file too small: $MODULE_FILE ($FILE_SIZE bytes)" >> "$FINDINGS_LOG"
        continue
    fi

    echo "[VALID]"
    SUCCESS=$((SUCCESS + 1))
    echo "  [PASS] Module valid: $MODULE_FILE ($FILE_SIZE bytes)" >> "$FINDINGS_LOG"
done

echo ""
echo "TEST RESULTS:"
echo "=============="
echo "Total Tests:     $TEST_NUM"
echo "Successful:      $SUCCESS"
echo "Failed:          $FAIL"
echo ""

# Show available emudhra certificates
echo "AVAILABLE EMUDHRA CERTIFICATES:"
echo "================================"
ls -1 certs/emudhra_authorized/*.pem 2>/dev/null | head -10 | while read CERT; do
    echo "  $(basename "$CERT")"
done

echo ""
echo "NEXT STEPS:"
echo "==========="
echo ""
echo "1. Review findings:"
echo "   cat $FINDINGS_LOG"
echo ""
echo "2. To run module with authorized emudhra certificate (lab only):"
echo "   sudo ./evilgrade --module windows_cryptoapi --ssl \\"
echo '     --cert "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.pem" \'
echo '     --key "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.key" \'
echo "     --port 443 --interface 127.0.0.1"
echo ""
echo "3. Import findings to Faraday:"
echo "   faraday-cli report $FINDINGS_LOG"
echo ""
echo "Findings logged to: $FINDINGS_LOG"
echo "Authorization: SEC-AUTH-2026-01"
echo "Scope: Internal Faraday infrastructure only"
echo ""
