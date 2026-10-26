###############
# firefox_sig_bypass.pm
#
# CVE-CUSTOM (Sig Bypass, CVSS 7.8, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::firefox_sig_bypass;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'firefox_sig_bypass',
    'version' => '1.0',
    'cvss'    => '7.8',
    'type'    => 'Sig Bypass',
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
