###############
# macos_applefileintegrity.pm
#
# CVE-2025-43245 (Sig Bypass, CVSS 8, Year 2025)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::macos_applefileintegrity;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'macos_applefileintegrity',
    'version' => '1.0',
    'cvss'    => '8',
    'type'    => 'Sig Bypass',
    'year'    => '2025',
    'cve'     => 'CVE-2025-43245',
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
