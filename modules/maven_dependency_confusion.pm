###############
# maven_dependency_confusion.pm
#
# CVE-CUSTOM (Supply Chain, CVSS 8, Year 2021)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::maven_dependency_confusion;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'maven_dependency_confusion',
    'version' => '1.0',
    'cvss'    => '8',
    'type'    => 'Supply Chain',
    'year'    => '2021',
    'cve'     => 'CVE-CUSTOM',
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
