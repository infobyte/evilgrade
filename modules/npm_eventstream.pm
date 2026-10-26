###############
# npm_eventstream.pm
#
# CVE-2018-16487 (Supply Chain, CVSS 8.8, Year 2018)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::npm_eventstream;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'npm_eventstream',
    'version' => '1.0',
    'cvss'    => '8.8',
    'type'    => 'Supply Chain',
    'year'    => '2018',
    'cve'     => 'CVE-2018-16487',
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
