#!/bin/bash

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║     TESTING 10 NEW MODULES WITH SSL CERTIFICATES                 ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

MODULES=(
    "windows_msmq_rce:update.windows.msmq.test"
    "linux_copy_fail:updates.linux.test"
    "npm_tanstack_shai_hulud:registry.npm.test"
    "vmware_vcenter_auth:vcenter.test"
    "broadcom_wifi_wps:wifi.router.test"
    "hugging_face_backdoor:huggingface.test"
    "chrome_sandbox_escape:chrome.updates.test"
    "vscode_extensions_rce:vscode.updates.test"
    "pypi_litellm:pypi.test"
    "macos_launchdaemon_privesc:macos.test"
)

mkdir -p include/test_ssl certs/test_ssl

echo "[*] Generating SSL certificates for 10 modules..."
echo ""

for MOD_INFO in "${MODULES[@]}"; do
    IFS=':' read -r MOD_NAME DOMAIN <<< "$MOD_INFO"
    
    # Find full path
    MOD_PATH=$(find modules -name "${MOD_NAME}.pm" -type f)
    
    if [ -z "$MOD_PATH" ]; then
        echo "❌ $MOD_NAME not found"
        continue
    fi
    
    echo "Generating: $DOMAIN"
    
    # Create self-signed certificate
    openssl req -x509 -newkey rsa:2048 \
      -keyout "certs/test_ssl/${MOD_NAME}.key" \
      -out "certs/test_ssl/${MOD_NAME}.crt" \
      -days 1 -nodes \
      -subj "/CN=$DOMAIN" \
      -addext "subjectAltName=DNS:$DOMAIN,DNS:localhost,IP:127.0.0.1" \
      2>/dev/null
    
    echo "  ✓ Cert: certs/test_ssl/${MOD_NAME}.crt"
done

echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                   CERTIFICATES READY                              ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

ls -lh certs/test_ssl/ | tail -12

echo ""
echo "📋 READY TO RUN ANY MODULE. Examples:"
echo ""
echo "1️⃣  WINDOWS MSMQ RCE (CVSS 9.8):"
echo "   sudo ./evilgrade --module windows_msmq_rce --ssl \\"
echo "     --cert certs/test_ssl/windows_msmq_rce.crt \\"
echo "     --key certs/test_ssl/windows_msmq_rce.key \\"
echo "     --port 443 --interface 127.0.0.1"
echo ""
echo "2️⃣  NPM SHAI-HULUD WORM (CVSS 9.8):"
echo "   sudo ./evilgrade --module npm_tanstack_shai_hulud --ssl \\"
echo "     --cert certs/test_ssl/npm_tanstack_shai_hulud.crt \\"
echo "     --key certs/test_ssl/npm_tanstack_shai_hulud.key \\"
echo "     --port 443 --interface 127.0.0.1"
echo ""
echo "3️⃣  HUGGING FACE BACKDOOR (CVSS 9.8):"
echo "   sudo ./evilgrade --module hugging_face_backdoor --ssl \\"
echo "     --cert certs/test_ssl/hugging_face_backdoor.crt \\"
echo "     --key certs/test_ssl/hugging_face_backdoor.key \\"
echo "     --port 443 --interface 127.0.0.1"
echo ""
echo "Then from another terminal test with:"
echo "   curl -k https://[domain]/"
echo ""
