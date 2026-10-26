###############
# macos_sparkle_auth.pm
#
# CVE-2026-47122 (Auth Bypass, CVSS 9.8, Year 2026)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::macos_sparkle_auth;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'macos_sparkle_auth',
    'version' => '1.0',
    'cvss'    => '9.8',
    'type'    => 'Auth Bypass',
    'year'    => '2026',
    'cve'     => 'CVE-2026-47122',
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
