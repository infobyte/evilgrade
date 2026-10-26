###############
# macos_pkg_zsh.pm
#
# CVE-2024-27822 (PrivEsc, CVSS 7.8, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::macos_pkg_zsh;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'macos_pkg_zsh',
    'version' => '1.0',
    'cvss'    => '7.8',
    'type'    => 'PrivEsc',
    'year'    => '2024',
    'cve'     => 'CVE-2024-27822',
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
