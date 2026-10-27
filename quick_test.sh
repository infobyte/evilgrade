#!/bin/bash

echo "Testing 10 new automated modules..."
echo ""

MODULES=(
    "windows/windows_msmq_rce"
    "linux/linux_copy_fail"
    "package_managers/npm_tanstack_shai_hulud"
    "enterprise/vmware_vcenter_auth"
    "iot_firmware/broadcom_wifi_wps"
    "ai_ml/hugging_face_backdoor"
    "browsers/chrome_sandbox_escape"
    "dev_tools/vscode_extensions_rce"
    "package_managers/pypi_litellm"
    "macos/macos_launchdaemon_privesc"
)

COUNT=0
for mod in "${MODULES[@]}"; do
    COUNT=$((COUNT+1))
    if [ -f "modules/${mod}.pm" ]; then
        CVSS=$(grep "cvss" "modules/${mod}.pm" | head -1 | grep -o "[0-9.]*")
        printf "%2d. %-40s CVSS: %s ✅\n" $COUNT "${mod##*/}" "$CVSS"
    else
        printf "%2d. %-40s ❌ NOT FOUND\n" $COUNT "${mod##*/}"
    fi
done
