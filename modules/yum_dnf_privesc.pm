###############
# yum_dnf_privesc.pm
#
# CVE-2019-3877 (PrivEsc, CVSS 5.5, Year 2019)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::yum_dnf_privesc;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'yum_dnf_privesc',
    'version' => '1.0',
    'cvss'    => '5.5',
    'type'    => 'PrivEsc',
    'year'    => '2019',
    'cve'     => 'CVE-2019-3877',
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
