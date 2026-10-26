###############
# vmware_tools_privesc.pm
#
# CVE-CUSTOM (PrivEsc, CVSS 8.5, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::vmware_tools_privesc;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'vmware_tools_privesc',
    'version' => '1.0',
    'cvss'    => '8.5',
    'type'    => 'PrivEsc',
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
