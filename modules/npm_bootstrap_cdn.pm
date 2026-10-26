###############
# npm_bootstrap_cdn.pm
#
# CVE-2023-36667 (Supply Chain, CVSS 8.8, Year 2023)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::npm_bootstrap_cdn;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'npm_bootstrap_cdn',
    'version' => '1.0',
    'cvss'    => '8.8',
    'type'    => 'Supply Chain',
    'year'    => '2023',
    'cve'     => 'CVE-2023-36667',
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
