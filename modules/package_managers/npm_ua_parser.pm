###############
# npm_ua_parser.pm
#
# CVE-2021-23358 (Supply Chain, CVSS 9.8, Year 2021)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::npm_ua_parser;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'npm_ua_parser',
    'version' => '1.0',
    'cvss'    => '9.8',
    'type'    => 'Supply Chain',
    'year'    => '2021',
    'cve'     => 'CVE-2021-23358',
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
