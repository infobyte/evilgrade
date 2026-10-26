###############
# linux_kernel_overlayfs.pm
#
# CVE-2023-0386 (PrivEsc, CVSS 8.8, Year 2023)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::linux_kernel_overlayfs;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'linux_kernel_overlayfs',
    'version' => '1.0',
    'cvss'    => '8.8',
    'type'    => 'PrivEsc',
    'year'    => '2023',
    'cve'     => 'CVE-2023-0386',
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
