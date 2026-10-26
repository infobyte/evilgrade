###############
# qnap_nas_rce.pm
#
# CVE-2022-4507 (RCE, CVSS 9.9, Year 2022)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::qnap_nas_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'qnap_nas_rce',
    'version' => '1.0',
    'cvss'    => '9.9',
    'type'    => 'RCE',
    'year'    => '2022',
    'cve'     => 'CVE-2022-4507',
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
