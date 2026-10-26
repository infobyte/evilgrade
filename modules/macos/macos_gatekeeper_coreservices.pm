###############
# macos_gatekeeper_coreservices.pm
#
# CVE-2026-28899 (Security Bypass, CVSS 7.4, Year 2026)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::macos_gatekeeper_coreservices;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'macos_gatekeeper_coreservices',
    'version' => '1.0',
    'cvss'    => '7.4',
    'type'    => 'Security Bypass',
    'year'    => '2026',
    'cve'     => 'CVE-2026-28899',
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
