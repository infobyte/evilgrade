###############
# openssh_enum.pm
#
# CVE-2018-15473 (Info Disc, CVSS 6.5, Year 2018)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::openssh_enum;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'openssh_enum',
    'version' => '1.0',
    'cvss'    => '6.5',
    'type'    => 'Info Disc',
    'year'    => '2018',
    'cve'     => 'CVE-2018-15473',
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
