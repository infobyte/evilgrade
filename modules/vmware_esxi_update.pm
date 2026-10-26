###############
# vmware_esxi_update.pm
#
# CVE-CUSTOM (Update Bypass, CVSS 9, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::vmware_esxi_update;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'vmware_esxi_update',
    'version' => '1.0',
    'cvss'    => '9',
    'type'    => 'Update Bypass',
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
