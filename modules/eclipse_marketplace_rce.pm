###############
# eclipse_marketplace_rce.pm
#
# CVE-2021-34429 (RCE, CVSS 5.5, Year 2021)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::eclipse_marketplace_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'eclipse_marketplace_rce',
    'version' => '1.0',
    'cvss'    => '5.5',
    'type'    => 'RCE',
    'year'    => '2021',
    'cve'     => 'CVE-2021-34429',
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
