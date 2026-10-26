###############
# gradle_injection.pm
#
# CVE-2022-22978 (Injection, CVSS 7.2, Year 2022)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::gradle_injection;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'gradle_injection',
    'version' => '1.0',
    'cvss'    => '7.2',
    'type'    => 'Injection',
    'year'    => '2022',
    'cve'     => 'CVE-2022-22978',
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
