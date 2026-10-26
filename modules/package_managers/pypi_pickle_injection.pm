###############
# pypi_pickle_injection.pm
#
# CVE-2018-7489 (Injection, CVSS 7.5, Year 2018)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::pypi_pickle_injection;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'pypi_pickle_injection',
    'version' => '1.0',
    'cvss'    => '7.5',
    'type'    => 'Injection',
    'year'    => '2018',
    'cve'     => 'CVE-2018-7489',
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
