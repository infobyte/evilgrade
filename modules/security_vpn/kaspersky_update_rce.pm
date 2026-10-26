###############
# kaspersky_update_rce.pm
#
# CVE-2021-32621 (RCE, CVSS 7.2, Year 2021)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::kaspersky_update_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'kaspersky_update_rce',
    'version' => '1.0',
    'cvss'    => '7.2',
    'type'    => 'RCE',
    'year'    => '2021',
    'cve'     => 'CVE-2021-32621',
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
