###############
# citrix_netscaler.pm
#
# CVE-CUSTOM (RCE, CVSS 9, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::citrix_netscaler;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'citrix_netscaler',
    'version' => '1.0',
    'cvss'    => '9',
    'type'    => 'RCE',
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
