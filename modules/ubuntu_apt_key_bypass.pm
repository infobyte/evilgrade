###############
# ubuntu_apt_key_bypass.pm
#
# CVE-2022-3634 (Sig Bypass, CVSS 9.8, Year 2022)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::ubuntu_apt_key_bypass;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'ubuntu_apt_key_bypass',
    'version' => '1.0',
    'cvss'    => '9.8',
    'type'    => 'Sig Bypass',
    'year'    => '2022',
    'cve'     => 'CVE-2022-3634',
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
