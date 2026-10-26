###############
# gnupg_signature_bypass.pm
#
# CVE-2022-34903 (Sig Bypass, CVSS 8.1, Year 2022)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::gnupg_signature_bypass;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'gnupg_signature_bypass',
    'version' => '1.0',
    'cvss'    => '8.1',
    'type'    => 'Sig Bypass',
    'year'    => '2022',
    'cve'     => 'CVE-2022-34903',
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
