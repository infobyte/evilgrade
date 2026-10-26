###############
# windows_print_spooler.pm
#
# CVE-2020-1048 (PrivEsc, CVSS 6.8, Year 2020)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::windows_print_spooler;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'windows_print_spooler',
    'version' => '1.0',
    'cvss'    => '6.8',
    'type'    => 'PrivEsc',
    'year'    => '2020',
    'cve'     => 'CVE-2020-1048',
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
