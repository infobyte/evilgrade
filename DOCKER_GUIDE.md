# evilgrade Docker Guide (SEC-AUTH-2026-01)

Complete guide for running evilgrade in Docker with proper DNS/MITM configuration.

---

## Quick Start

### 1. Build Docker Image

```bash
cd /Users/famato/dev/evilgrade

# Build the image (first time only, ~5 minutes)
docker build -t evilgrade:latest .
```

### 2. Run Container

**Option A: Using docker-compose (Recommended)**

```bash
# Start container in background
docker-compose up -d

# Get container IP and details
docker-compose ps
docker inspect evilgrade-pentest | grep '"IPAddress"'
```

**Option B: Direct docker run**

```bash
docker run -it --rm \
  --name evilgrade-pentest \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  -p 80:80 -p 443:443 -p 8080:8080 -p 8443:8443 \
  -v $(pwd):/evilgrade \
  -v $(pwd)/findings:/evilgrade/findings \
  evilgrade:latest
```

---

## Getting Container IP Address

### From Host Machine

```bash
# Get the container IP
CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' evilgrade-pentest)
echo "evilgrade container IP: $CONTAINER_IP"

# Example output: 172.20.0.10
```

### From Inside Container

```bash
# Inside the running container
hostname -I
# or
ip addr show | grep inet | grep -v 127.0.0.1
```

### Using docker-compose

```bash
# Get container details
docker-compose exec evilgrade hostname -I

# Get full network info
docker network inspect evilgrade_evilgrade-net
```

---

## DNS/MITM Configuration

### Option 1: Modify /etc/hosts (Single Machine)

```bash
# Get container IP
CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' evilgrade-pentest)

# Add to /etc/hosts (requires sudo)
sudo bash -c "echo '$CONTAINER_IP  update.microsoft.com' >> /etc/hosts"
sudo bash -c "echo '$CONTAINER_IP  swcdn.apple.com' >> /etc/hosts"
sudo bash -c "echo '$CONTAINER_IP  registry.npmjs.com' >> /etc/hosts"
sudo bash -c "echo '$CONTAINER_IP  huggingface.co' >> /etc/hosts"

# Verify
grep "172.20.0.10\|update.microsoft.com" /etc/hosts
```

### Option 2: Use dnsmasq (Inside Container)

```bash
# Inside container, create dnsmasq config
docker-compose exec evilgrade bash

# Inside container:
cat > /etc/dnsmasq.d/evilgrade.conf << 'EOF'
# evilgrade MITM domains
address=/update.microsoft.com/172.20.0.10
address=/officecdn.microsoft.com/172.20.0.10
address=/swcdn.apple.com/172.20.0.10
address=/registry.npmjs.com/172.20.0.10
address=/huggingface.co/172.20.0.10
address=/pypi.org/172.20.0.10
address=/vcenter.local/172.20.0.10
EOF

# Start dnsmasq
dnsmasq

# Test DNS resolution
nslookup update.microsoft.com 127.0.0.1
```

### Option 3: Using systemd-resolved (Linux Host)

```bash
# On host machine, create DNS override
CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' evilgrade-pentest)

# Create systemd-resolved stub file
sudo bash -c "cat > /etc/systemd/resolved.conf.d/evilgrade.conf << EOF
[Resolve]
DNS=$CONTAINER_IP
Domains=~update.microsoft.com ~swcdn.apple.com ~registry.npmjs.com
EOF"

# Restart resolved
sudo systemctl restart systemd-resolved

# Test
nslookup update.microsoft.com
```

---

## Running evilgrade Modules in Docker

### Inside Container

```bash
# Get into the container
docker-compose exec evilgrade bash

# Or if using direct docker run, you're already in the container

# Test modules (no dependencies)
./test_emudhra_authorized.sh

# Run specific module with emudhra certificate
sudo ./evilgrade --module windows_cryptoapi --ssl \
  --cert "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.pem" \
  --key "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.key" \
  --port 443 --interface 0.0.0.0

# Run macOS module
sudo ./evilgrade --module macos_installer_rce --ssl \
  --cert "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.pem" \
  --key "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.key" \
  --port 443 --interface 0.0.0.0
```

### From Host Machine (Docker Exec)

```bash
# Run test from host
docker-compose exec evilgrade ./test_emudhra_authorized.sh

# Run module from host
docker-compose exec evilgrade sudo ./evilgrade \
  --module windows_cryptoapi --ssl \
  --cert "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.pem" \
  --key "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.key" \
  --port 443 --interface 0.0.0.0
```

---

## Testing Against the Container

### From Host Machine

```bash
# Get container IP
CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' evilgrade-pentest)

# Add to /etc/hosts
sudo bash -c "echo '$CONTAINER_IP update.microsoft.com' >> /etc/hosts"

# Test connection
curl -k https://update.microsoft.com/

# Test with specific User-Agent (Windows Update)
curl -k -H "User-Agent: Windows-Update-Agent/10.0" \
  https://update.microsoft.com/

# Test with tcpdump inside container
docker-compose exec evilgrade tcpdump -i eth0 -n port 443
```

### From Another Container (Networked)

```bash
# Create test container on same network
docker run -it --rm \
  --network evilgrade_evilgrade-net \
  curlimages/curl \
  curl -k https://172.20.0.10/

# Or with DNS (if dnsmasq running)
docker run -it --rm \
  --network evilgrade_evilgrade-net \
  --dns 172.20.0.10 \
  curlimages/curl \
  curl -k https://update.microsoft.com/
```

---

## Docker Management Commands

### Container Lifecycle

```bash
# Start container
docker-compose up -d

# Stop container
docker-compose stop

# Stop and remove
docker-compose down

# View logs
docker-compose logs -f evilgrade

# Get container stats
docker stats evilgrade-pentest

# Interactive shell
docker-compose exec evilgrade bash
```

### Network Inspection

```bash
# List networks
docker network ls

# Inspect evilgrade network
docker network inspect evilgrade_evilgrade-net

# Get all container IPs
docker inspect evilgrade-pentest \
  | grep -A 10 NetworkSettings
```

### Cleanup

```bash
# Remove stopped containers
docker-compose down -v

# Remove image
docker rmi evilgrade:latest

# Clean up unused images/volumes
docker system prune -a

# Remove all evilgrade artifacts
docker-compose down -v && docker rmi evilgrade:latest
```

---

## Complete Workflow Example

### 1. Start Infrastructure

```bash
cd /Users/famato/dev/evilgrade

# Build and start
docker-compose up -d

# Verify running
docker-compose ps
```

### 2. Get Container IP

```bash
CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' evilgrade-pentest)
echo "Container IP: $CONTAINER_IP"
# Output: Container IP: 172.20.0.10
```

### 3. Configure DNS (Host)

```bash
# Add test domains to /etc/hosts
sudo bash << EOF
echo "$CONTAINER_IP update.microsoft.com" >> /etc/hosts
echo "$CONTAINER_IP swcdn.apple.com" >> /etc/hosts
echo "$CONTAINER_IP registry.npmjs.com" >> /etc/hosts
EOF

# Verify
grep "172.20.0.10" /etc/hosts
```

### 4. Start Module in Container

```bash
# Terminal 1: Start evilgrade module
docker-compose exec evilgrade sudo ./evilgrade \
  --module windows_cryptoapi --ssl \
  --cert "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.pem" \
  --key "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.key" \
  --port 443 --interface 0.0.0.0

# Output:
# [*] Loading module windows_cryptoapi
# [*] Starting HTTPS server on 0.0.0.0:443
# [*] Waiting for connections...
```

### 5. Test from Host

```bash
# Terminal 2: Test connectivity
curl -k https://update.microsoft.com/

# Or with User-Agent
curl -k -H "User-Agent: Windows-Update-Agent" https://update.microsoft.com/

# Monitor in container
docker-compose exec evilgrade tcpdump -i eth0 -n port 443
```

### 6. View Findings

```bash
# Container findings are mounted to host
ls -la findings/

# Or inside container
docker-compose exec evilgrade ls -la findings/
```

### 7. Cleanup

```bash
# Stop container
docker-compose down

# Remove hosts file entries
sudo sed -i '' '/172.20.0.10/d' /etc/hosts
```

---

## Troubleshooting

### "Cannot connect to Docker daemon"

```bash
# Make sure Docker is running
docker ps

# If not running, start Docker Desktop (on macOS)
```

### "Address already in use"

```bash
# Find what's using port 443
sudo lsof -i :443

# Kill the process or change port in docker-compose.yml
# Change: "443:443" to "8443:443"
```

### "Permission denied" for /etc/hosts

```bash
# Use sudo for host file modifications
sudo bash -c "echo '172.20.0.10 update.microsoft.com' >> /etc/hosts"
```

### "Module not found" inside container

```bash
# Make sure volumes are properly mounted
docker-compose exec evilgrade ls -la /evilgrade/modules/

# Check PERL5LIB
docker-compose exec evilgrade echo $PERL5LIB
```

### DNS not resolving

```bash
# Inside container, check DNS
docker-compose exec evilgrade nslookup update.microsoft.com

# If not resolving, use container IP directly
curl -k -H "Host: update.microsoft.com" https://172.20.0.10/
```

### Container crashes on startup

```bash
# Check logs
docker-compose logs evilgrade

# Try interactive shell to debug
docker-compose run --rm evilgrade bash

# Check Perl modules
docker-compose exec evilgrade perl -e 'use IO::Socket::SSL; print "OK\n"'
```

---

## Network Architecture

```
Host Machine                Docker Network
==================         ==================
127.0.0.1                  
|                          172.20.0.0/16
|-- /etc/hosts      -----> 172.20.0.10 (evilgrade container)
|   update.microsoft.com       |
|   swcdn.apple.com            |-- Port 443 (HTTPS)
|   registry.npmjs.com         |-- Port 80 (HTTP)
|   huggingface.co             |-- Port 53 (DNS, optional)
|                          
|-- curl/request    -----> evilgrade MITM server
|   (to 172.20.0.10)      returns emudhra certificates
|
|-- tcpdump/monitor <---- packet capture from container
```

---

## Authorization Context

**Document:** SEC-AUTH-2026-01  
**Scope:** Internal Faraday infrastructure testing (Linux/macOS/Windows)  
**Docker Usage:** Authorized for lab-controlled testing and isolated MITM scenarios  

---

## Quick Reference

### Essential Commands

```bash
# Build & start
docker-compose up -d

# Get container IP
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' evilgrade-pentest

# Run module
docker-compose exec evilgrade sudo ./evilgrade --module <MODULE> --port 443 --interface 0.0.0.0

# Test modules
docker-compose exec evilgrade ./test_emudhra_authorized.sh

# Interactive shell
docker-compose exec evilgrade bash

# View logs
docker-compose logs -f evilgrade

# Stop & cleanup
docker-compose down -v
```

---

**Status:** Production Ready  
**Authorization:** CTO SEC-AUTH-2026-01  
**Last Updated:** 2026-10-27
