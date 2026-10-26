###############
# f5_bigip_auth.pm
#
# CVE-2020-5410 (Auth Bypass, CVSS 8.9, Year 2020)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::f5_bigip_auth;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'f5_bigip_auth',
    'version' => '1.0',
    'cvss'    => '8.9',
    'type'    => 'Auth Bypass',
    'year'    => '2020',
    'cve'     => 'CVE-2020-5410',
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
