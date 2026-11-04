#!/bin/bash
###############################################################################
# start_https_server.sh - Start HTTPS server with proper certificate setup
###############################################################################

CERT_DIR="/evilgrade/certs/emudhra_authorized"
WORK_CERT="$CERT_DIR/server.pem"
WORK_KEY="$CERT_DIR/server.key"

echo "[*] Starting evilgrade HTTPS server"
echo "[*] Certificate directory: $CERT_DIR"
echo ""

# If working cert doesn't exist, copy one from emudhra
if [ ! -f "$WORK_CERT" ] || [ ! -f "$WORK_KEY" ]; then
    echo "[*] Creating working certificates..."
    # Use the EV cert which is more likely to be valid
    cp "$CERT_DIR/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.pem" "$WORK_CERT"
    cp "$CERT_DIR/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.key" "$WORK_KEY"
fi

echo "[+] Certificate: $WORK_CERT"
echo "[+] Key: $WORK_KEY"
echo ""

# Generate a simple self-signed cert for server if needed
if ! openssl x509 -in "$WORK_CERT" -noout 2>/dev/null | grep -q "Certificate"; then
    echo "[!] Certificate appears invalid, generating new one..."
    openssl req -x509 -newkey rsa:2048 -keyout "$WORK_KEY" -out "$WORK_CERT" \
        -days 365 -nodes -subj "/CN=update.microsoft.com" 2>/dev/null
    echo "[+] New certificate generated"
fi

echo ""
echo "[*] Starting Perl HTTPS server..."
cd /evilgrade

# Simple Perl HTTPS server
perl << 'PERL_SCRIPT'
use strict;
use warnings;
use IO::Socket::SSL qw(SSL_VERIFY_NONE);
use Socket;

my $port = 443;
my $cert = "/evilgrade/certs/emudhra_authorized/server.pem";
my $key = "/evilgrade/certs/emudhra_authorized/server.key";
my $interface = "0.0.0.0";

# Create SSL socket with relaxed certificate validation
my $ssl_socket = IO::Socket::SSL->new(
    LocalHost => $interface,
    LocalPort => $port,
    Listen    => 5,
    SSL_cert_file => $cert,
    SSL_key_file  => $key,
    SSL_verify_mode => SSL_VERIFY_NONE,
) or die "Cannot create SSL socket: $!\n";

print "[+] HTTPS server listening on $interface:$port\n";
print "[+] Press Ctrl+C to stop\n\n";

$SIG{INT} = sub {
    print "\n[*] Stopping server...\n";
    close($ssl_socket);
    exit(0);
};

# Accept connections
while (1) {
    my $client = $ssl_socket->accept() or next;

    my $peer = $client->peerhost();
    print "[+] Connection from $peer\n";

    # Read HTTP request
    my $request = '';
    while (<$client>) {
        $request .= $_;
        last if /^\s*$/;
    }

    my @lines = split /\n/, $request;
    print "    Request: $lines[0]\n" if @lines;

    # Send HTTP response
    my $response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 28\r\nConnection: close\r\n\r\nevilgrade HTTPS Test - OK\n";

    print $client $response;
    close($client);
}
PERL_SCRIPT

