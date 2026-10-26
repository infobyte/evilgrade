###############
# eset_nod32_privesc.pm
#
# CVE-2023-33062 (PrivEsc, CVSS 7.5, Year 2023)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::eset_nod32_privesc;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'eset_nod32_privesc',
    'version' => '1.0',
    'cvss'    => '7.5',
    'type'    => 'PrivEsc',
    'year'    => '2023',
    'cve'     => 'CVE-2023-33062',
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
