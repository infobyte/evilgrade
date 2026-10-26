###############
# safari_rce.pm
#
# CVE-2024-27853 (RCE, CVSS 8.8, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::safari_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'safari_rce',
    'version' => '1.0',
    'cvss'    => '8.8',
    'type'    => 'RCE',
    'year'    => '2024',
    'cve'     => 'CVE-2024-27853',
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
