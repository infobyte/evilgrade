###############
# openconnect_buffer.pm
#
# CVE-2021-3807 (Buffer Overflow, CVSS 5.5, Year 2021)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::openconnect_buffer;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'openconnect_buffer',
    'version' => '1.0',
    'cvss'    => '5.5',
    'type'    => 'Buffer Overflow',
    'year'    => '2021',
    'cve'     => 'CVE-2021-3807',
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
