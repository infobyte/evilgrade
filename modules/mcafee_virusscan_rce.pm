###############
# mcafee_virusscan_rce.pm
#
# CVE-2023-32315 (RCE, CVSS 7.6, Year 2023)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::mcafee_virusscan_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'mcafee_virusscan_rce',
    'version' => '1.0',
    'cvss'    => '7.6',
    'type'    => 'RCE',
    'year'    => '2023',
    'cve'     => 'CVE-2023-32315',
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
