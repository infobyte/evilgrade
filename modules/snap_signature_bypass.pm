###############
# snap_signature_bypass.pm
#
# CVE-2023-24980 (Sig Bypass, CVSS 7.5, Year 2023)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::snap_signature_bypass;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'snap_signature_bypass',
    'version' => '1.0',
    'cvss'    => '7.5',
    'type'    => 'Sig Bypass',
    'year'    => '2023',
    'cve'     => 'CVE-2023-24980',
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
