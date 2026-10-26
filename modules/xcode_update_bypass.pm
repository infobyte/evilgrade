###############
# xcode_update_bypass.pm
#
# CVE-2021-30758 (Update Bypass, CVSS 5.5, Year 2021)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::xcode_update_bypass;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'xcode_update_bypass',
    'version' => '1.0',
    'cvss'    => '5.5',
    'type'    => 'Update Bypass',
    'year'    => '2021',
    'cve'     => 'CVE-2021-30758',
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
