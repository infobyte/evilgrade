###############
# amd_ryzen_agesa.pm
#
# CVE-2023-20914 (PrivEsc, CVSS 7.5, Year 2023)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::amd_ryzen_agesa;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'amd_ryzen_agesa',
    'version' => '1.0',
    'cvss'    => '7.5',
    'type'    => 'PrivEsc',
    'year'    => '2023',
    'cve'     => 'CVE-2023-20914',
    'vh'      => '(.*)',
    'request' => [{
        'req'   => '/.*',
        'type'  => 'string',
        'string' => 'HTTP/1.1 200 OK',
    }],
};

sub new {
    my $class = shift;
    bless($base, $class);
}

1;
