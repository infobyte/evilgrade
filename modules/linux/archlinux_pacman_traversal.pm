###############
# archlinux_pacman_traversal.pm
#
# CVE-2019-9686 (Dir Traversal, CVSS 8.8, Year 2019)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::archlinux_pacman_traversal;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'archlinux_pacman_traversal',
    'version' => '1.0',
    'cvss'    => '8.8',
    'type'    => 'Dir Traversal',
    'year'    => '2019',
    'cve'     => 'CVE-2019-9686',
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
