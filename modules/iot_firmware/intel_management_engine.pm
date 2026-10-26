###############
# intel_management_engine.pm
#
# CVE-2018-3987 (PrivEsc, CVSS 7.9, Year 2018)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::intel_management_engine;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'intel_management_engine',
    'version' => '1.0',
    'cvss'    => '7.9',
    'type'    => 'PrivEsc',
    'year'    => '2018',
    'cve'     => 'CVE-2018-3987',
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
