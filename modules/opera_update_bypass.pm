###############
# opera_update_bypass.pm
#
# CVE-CUSTOM (Update Bypass, CVSS 7.5, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::opera_update_bypass;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'opera_update_bypass',
    'version' => '1.0',
    'cvss'    => '7.5',
    'type'    => 'Update Bypass',
    'year'    => '2024',
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
