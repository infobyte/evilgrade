###############
# synology_nas_rce.pm
#
# CVE-2023-26885 (RCE, CVSS 9.9, Year 2023)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::synology_nas_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'synology_nas_rce',
    'version' => '1.0',
    'cvss'    => '9.9',
    'type'    => 'RCE',
    'year'    => '2023',
    'cve'     => 'CVE-2023-26885',
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
