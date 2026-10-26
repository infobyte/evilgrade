###############
# brave_update_mitm.pm
#
# CVE-CUSTOM (MITM, CVSS 8, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::brave_update_mitm;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'brave_update_mitm',
    'version' => '1.0',
    'cvss'    => '8',
    'type'    => 'MITM',
    'year'    => '2024',
    'cve'     => 'CVE-CUSTOM',
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
