###############
# firefox_sandbox_escape.pm
#
# CVE-2022-26381 (Sandbox Escape, CVSS 7.3, Year 2022)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::firefox_sandbox_escape;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'firefox_sandbox_escape',
    'version' => '1.0',
    'cvss'    => '7.3',
    'type'    => 'Sandbox Escape',
    'year'    => '2022',
    'cve'     => 'CVE-2022-26381',
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
