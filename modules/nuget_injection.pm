###############
# nuget_injection.pm
#
# CVE-2021-27569 (Supply Chain, CVSS 8.6, Year 2021)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::nuget_injection;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'nuget_injection',
    'version' => '1.0',
    'cvss'    => '8.6',
    'type'    => 'Supply Chain',
    'year'    => '2021',
    'cve'     => 'CVE-2021-27569',
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
