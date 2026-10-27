#!/bin/bash
###############################################################################
# setup_evilgrade.sh - Setup evilgrade with proper Perl environment
# Resolves Time::HiRes version mismatch on macOS
###############################################################################

echo "Setting up evilgrade..."
echo ""

cd "$(dirname "$0")" || exit 1

# Check if Perl from Homebrew is available
if [ -x /usr/local/bin/perl ]; then
    echo "✅ Using Perl from Homebrew"
    PERL_BIN="/usr/local/bin/perl"
elif [ -x /opt/homebrew/bin/perl ]; then
    echo "✅ Using Perl from Homebrew (ARM)"
    PERL_BIN="/opt/homebrew/bin/perl"
else
    echo "⚠️  Homebrew Perl not found, installing..."
    if ! command -v brew &> /dev/null; then
        echo "ERROR: Homebrew not installed. Please install Homebrew first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi

    echo "Installing Perl via Homebrew (this may take a few minutes)..."
    brew install perl

    # Find the newly installed Perl
    if [ -x /usr/local/bin/perl ]; then
        PERL_BIN="/usr/local/bin/perl"
    elif [ -x /opt/homebrew/bin/perl ]; then
        PERL_BIN="/opt/homebrew/bin/perl"
    else
        echo "ERROR: Failed to install Perl"
        exit 1
    fi
fi

echo "✅ Perl path: $PERL_BIN"
echo ""

# Create wrapper script
cat > evilgrade.sh <<'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PERL5LIB="$SCRIPT_DIR:$SCRIPT_DIR/isrcore:$PERL5LIB"

# Use Homebrew Perl if available
if [ -x /opt/homebrew/bin/perl ]; then
    exec /opt/homebrew/bin/perl "$SCRIPT_DIR/evilgrade" "$@"
elif [ -x /usr/local/bin/perl ]; then
    exec /usr/local/bin/perl "$SCRIPT_DIR/evilgrade" "$@"
else
    exec perl "$SCRIPT_DIR/evilgrade" "$@"
fi
EOF

chmod +x evilgrade.sh

echo "Setup complete!"
echo ""
echo "Usage:"
echo "  ./evilgrade.sh --help"
echo "  ./evilgrade.sh --module windows_cryptoapi --ssl \\"
echo "    --cert certs/emudhra_authorized/cert.pem \\"
echo "    --key certs/emudhra_authorized/cert.key \\"
echo "    --port 443 --interface 127.0.0.1"
echo ""
echo "Or run tests:"
echo "  ./test_emudhra_authorized.sh"
echo ""
