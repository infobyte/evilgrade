###############
# wireguard_buffer_overflow.pm
#
# CVE-2023-38545 (Buffer Overflow, CVSS 5.3, Year 2023)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::wireguard_buffer_overflow;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'wireguard_buffer_overflow',
    'version' => '1.0',
    'cvss'    => '5.3',
    'type'    => 'Buffer Overflow',
    'year'    => '2023',
    'cve'     => 'CVE-2023-38545',
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
