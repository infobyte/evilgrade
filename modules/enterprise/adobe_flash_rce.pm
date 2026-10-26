###############
# adobe_flash_rce.pm
#
# CVE-CUSTOM (RCE, CVSS 9.5, Year 2022)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::adobe_flash_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'adobe_flash_rce',
    'version' => '1.0',
    'cvss'    => '9.5',
    'type'    => 'RCE',
    'year'    => '2022',
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
