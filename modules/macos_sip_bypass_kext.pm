###############
# macos_sip_bypass_kext.pm
#
# CVE-2024-44243 (SIP Bypass, CVSS 5.5, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::macos_sip_bypass_kext;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'macos_sip_bypass_kext',
    'version' => '1.0',
    'cvss'    => '5.5',
    'type'    => 'SIP Bypass',
    'year'    => '2024',
    'cve'     => 'CVE-2024-44243',
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
