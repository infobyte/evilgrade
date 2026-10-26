###############
# chrome_sandbox_escape.pm
#
# CVE-2023-36811 (Sandbox Escape, CVSS 9.6, Year 2023)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::chrome_sandbox_escape;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'chrome_sandbox_escape',
    'version' => '1.0',
    'cvss'    => '9.6',
    'type'    => 'Sandbox Escape',
    'year'    => '2023',
    'cve'     => 'CVE-2023-36811',
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
