###############
# windows_installer_privesc.pm
#
# CVE-2020-0787 (PrivEsc, CVSS 6.9, Year 2020)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::windows_installer_privesc;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'windows_installer_privesc',
    'version' => '1.0',
    'cvss'    => '6.9',
    'type'    => 'PrivEsc',
    'year'    => '2020',
    'cve'     => 'CVE-2020-0787',
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
