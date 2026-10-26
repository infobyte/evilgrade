###############
# fortinet_fortigate_auth.pm
#
# CVE-2023-27997 (Auth Bypass, CVSS 8.6, Year 2023)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::fortinet_fortigate_auth;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'fortinet_fortigate_auth',
    'version' => '1.0',
    'cvss'    => '8.6',
    'type'    => 'Auth Bypass',
    'year'    => '2023',
    'cve'     => 'CVE-2023-27997',
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
