###############
# windows_uac_bypass.pm
#
# CVE-2019-0604 (PrivEsc, CVSS 8.8, Year 2019)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::windows_uac_bypass;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'windows_uac_bypass',
    'version' => '1.0',
    'cvss'    => '8.8',
    'type'    => 'PrivEsc',
    'year'    => '2019',
    'cve'     => 'CVE-2019-0604',
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
