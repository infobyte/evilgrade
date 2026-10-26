###############
# composer_rce.pm
#
# CVE-2021-41116 (RCE, CVSS 7.3, Year 2021)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::composer_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'composer_rce',
    'version' => '1.0',
    'cvss'    => '7.3',
    'type'    => 'RCE',
    'year'    => '2021',
    'cve'     => 'CVE-2021-41116',
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
