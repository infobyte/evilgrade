###############
# pypi_typosquatting.pm
#
# CVE-CUSTOM (Supply Chain, CVSS 8.5, Year 2025)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::pypi_typosquatting;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'pypi_typosquatting',
    'version' => '1.0',
    'cvss'    => '8.5',
    'type'    => 'Supply Chain',
    'year'    => '2025',
    'cve'     => 'CVE-CUSTOM',
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
