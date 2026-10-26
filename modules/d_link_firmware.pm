###############
# d_link_firmware.pm
#
# CVE-2020-10987 (RCE, CVSS 8.8, Year 2020)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::d_link_firmware;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'd_link_firmware',
    'version' => '1.0',
    'cvss'    => '8.8',
    'type'    => 'RCE',
    'year'    => '2020',
    'cve'     => 'CVE-2020-10987',
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
