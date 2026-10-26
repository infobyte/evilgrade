###############
# netgate_pfsense_auth.pm
#
# CVE-2022-41709 (Auth Bypass, CVSS 9.8, Year 2022)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::netgate_pfsense_auth;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'netgate_pfsense_auth',
    'version' => '1.0',
    'cvss'    => '9.8',
    'type'    => 'Auth Bypass',
    'year'    => '2022',
    'cve'     => 'CVE-2022-41709',
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
