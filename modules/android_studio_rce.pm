###############
# android_studio_rce.pm
#
# CVE-2022-22963 (RCE, CVSS 5.7, Year 2022)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::android_studio_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'android_studio_rce',
    'version' => '1.0',
    'cvss'    => '5.7',
    'type'    => 'RCE',
    'year'    => '2022',
    'cve'     => 'CVE-2022-22963',
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
