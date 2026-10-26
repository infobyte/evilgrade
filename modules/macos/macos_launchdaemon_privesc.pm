###############
# macos_launchdaemon_privesc.pm
#
# CVE-2025-24085 (PrivEsc, CVSS 7.5, Year 2025)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::macos_launchdaemon_privesc;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'macos_launchdaemon_privesc',
    'version' => '1.0',
    'cvss'    => '7.5',
    'type'    => 'PrivEsc',
    'year'    => '2025',
    'cve'     => 'CVE-2025-24085',
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
