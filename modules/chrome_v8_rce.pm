###############
# chrome_v8_rce.pm
#
# CVE-2021-30573 (RCE, CVSS 7.5, Year 2021)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::chrome_v8_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'chrome_v8_rce',
    'version' => '1.0',
    'cvss'    => '7.5',
    'type'    => 'RCE',
    'year'    => '2021',
    'cve'     => 'CVE-2021-30573',
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
