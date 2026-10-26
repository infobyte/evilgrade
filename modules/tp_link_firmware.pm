###############
# tp_link_firmware.pm
#
# CVE-2020-12446 (RCE, CVSS 8.9, Year 2020)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::tp_link_firmware;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'tp_link_firmware',
    'version' => '1.0',
    'cvss'    => '8.9',
    'type'    => 'RCE',
    'year'    => '2020',
    'cve'     => 'CVE-2020-12446',
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
