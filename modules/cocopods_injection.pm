###############
# cocopods_injection.pm
#
# CVE-2021-33618 (Injection, CVSS 6.5, Year 2021)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::cocopods_injection;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'cocopods_injection',
    'version' => '1.0',
    'cvss'    => '6.5',
    'type'    => 'Injection',
    'year'    => '2021',
    'cve'     => 'CVE-2021-33618',
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
