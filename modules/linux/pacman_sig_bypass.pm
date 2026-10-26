###############
# pacman_sig_bypass.pm
#
# CVE-2021-28649 (Sig Bypass, CVSS 5.8, Year 2021)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::pacman_sig_bypass;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'pacman_sig_bypass',
    'version' => '1.0',
    'cvss'    => '5.8',
    'type'    => 'Sig Bypass',
    'year'    => '2021',
    'cve'     => 'CVE-2021-28649',
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
