###############
# windows_ntlm_relay.pm
#
# CVE-2019-1040 (MITM, CVSS 8.8, Year 2019)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::windows_ntlm_relay;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'windows_ntlm_relay',
    'version' => '1.0',
    'cvss'    => '8.8',
    'type'    => 'MITM',
    'year'    => '2019',
    'cve'     => 'CVE-2019-1040',
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
