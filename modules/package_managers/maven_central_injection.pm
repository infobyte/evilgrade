###############
# maven_central_injection.pm
#
# CVE-2020-27572 (Dependency Poison, CVSS 7.5, Year 2020)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::maven_central_injection;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'maven_central_injection',
    'version' => '1.0',
    'cvss'    => '7.5',
    'type'    => 'Dependency Poison',
    'year'    => '2020',
    'cve'     => 'CVE-2020-27572',
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
