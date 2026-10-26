###############
# jetbrains_plugins_rce.pm
#
# CVE-2021-39793 (RCE, CVSS 5.5, Year 2021)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::jetbrains_plugins_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'jetbrains_plugins_rce',
    'version' => '1.0',
    'cvss'    => '5.5',
    'type'    => 'RCE',
    'year'    => '2021',
    'cve'     => 'CVE-2021-39793',
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
