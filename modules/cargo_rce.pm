###############
# cargo_rce.pm
#
# CVE-2023-40030 (RCE, CVSS 6.5, Year 2023)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::cargo_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'cargo_rce',
    'version' => '1.0',
    'cvss'    => '6.5',
    'type'    => 'RCE',
    'year'    => '2023',
    'cve'     => 'CVE-2023-40030',
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
