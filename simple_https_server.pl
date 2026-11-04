#!/usr/bin/perl
###############################################################################
# simple_https_server.pl - Minimal HTTPS server for testing evilgrade modules
# Uses emudhra certificates, no external dependencies
###############################################################################

use strict;
use warnings;
use IO::Socket::SSL;
use IO::Select;
use Socket;

my $port = $ARGV[0] || 443;
my $cert = $ARGV[1] || "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.pem";
my $key = $ARGV[2] || "certs/emudhra_authorized/CN=EM EV TLS CA - G3C,O=eMudhra Inc,C=US.key";
my $interface = $ARGV[3] || "0.0.0.0";

print "[*] Starting HTTPS server\n";
print "[*] Port: $port\n";
print "[*] Interface: $interface\n";
print "[*] Certificate: $cert\n";
print "[*] Key: $key\n";

# Check files exist
if (!-f $cert) {
    die "[!] Certificate not found: $cert\n";
}
if (!-f $key) {
    die "[!] Key not found: $key\n";
}

# Create SSL socket
my $ssl_socket = IO::Socket::SSL->new(
    LocalHost => $interface,
    LocalPort => $port,
    Listen    => 5,
    SSL_cert_file => $cert,
    SSL_key_file  => $key,
    SSL_version   => 'TLSv1_2:!SSLv2:!SSLv3',
) or die "Cannot create SSL socket: $@\n";

print "[+] HTTPS server listening on $interface:$port\n";
print "[+] Press Ctrl+C to stop\n\n";

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

    print "    Request: " . (split /\n/, $request)[0] . "\n";

    # Send HTTP response
    my $response = <<'EOF';
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 28
Connection: close

evilgrade HTTPS Test - OK
EOF

    print $client $response;
    close($client);
}

close($ssl_socket);
