###############
# macos_code_signing_downgrade.pm
#
# CVE-2025-24109 (Downgrade, CVSS 7.8, Year 2025)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::macos_code_signing_downgrade;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'macos_code_signing_downgrade',
    'version' => '1.0',
    'cvss'    => '7.8',
    'type'    => 'Downgrade',
    'year'    => '2025',
    'cve'     => 'CVE-2025-24109',
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
