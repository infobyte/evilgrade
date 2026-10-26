###############
# windows_codec.pm
#
# CVE-2020-0674 (RCE, CVSS 7.5, Year 2020)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::windows_codec;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'windows_codec',
    'version' => '1.0',
    'cvss'    => '7.5',
    'type'    => 'RCE',
    'year'    => '2020',
    'cve'     => 'CVE-2020-0674',
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
