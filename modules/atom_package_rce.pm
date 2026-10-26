###############
# atom_package_rce.pm
#
# CVE-2020-1753 (RCE, CVSS 5.7, Year 2020)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::atom_package_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'atom_package_rce',
    'version' => '1.0',
    'cvss'    => '5.7',
    'type'    => 'RCE',
    'year'    => '2020',
    'cve'     => 'CVE-2020-1753',
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
