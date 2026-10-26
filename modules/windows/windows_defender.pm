###############
# windows_defender.pm
#
# CVE-2021-34527 (RCE, CVSS 7.8, Year 2021)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::windows_defender;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'windows_defender',
    'version' => '1.0',
    'cvss'    => '7.8',
    'type'    => 'RCE',
    'year'    => '2021',
    'cve'     => 'CVE-2021-34527',
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
