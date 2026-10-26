###############
# npm_leftpad.pm
#
# CVE-2016-3714 (Supply Chain, CVSS 7.8, Year 2016)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::npm_leftpad;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'npm_leftpad',
    'version' => '1.0',
    'cvss'    => '7.8',
    'type'    => 'Supply Chain',
    'year'    => '2016',
    'cve'     => 'CVE-2016-3714',
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
