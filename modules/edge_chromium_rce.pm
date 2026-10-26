###############
# edge_chromium_rce.pm
#
# CVE-2023-36811 (RCE, CVSS 9.6, Year 2023)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::edge_chromium_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'edge_chromium_rce',
    'version' => '1.0',
    'cvss'    => '9.6',
    'type'    => 'RCE',
    'year'    => '2023',
    'cve'     => 'CVE-2023-36811',
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
