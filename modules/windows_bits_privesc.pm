###############
# windows_bits_privesc.pm
#
# CVE-2023-21816 (PrivEsc, CVSS 9.8, Year 2023)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::windows_bits_privesc;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'windows_bits_privesc',
    'version' => '1.0',
    'cvss'    => '9.8',
    'type'    => 'PrivEsc',
    'year'    => '2023',
    'cve'     => 'CVE-2023-21816',
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
