###############
# discord_electron_rce.pm
#
# CVE-CUSTOM (RCE, CVSS 8.8, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::discord_electron_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'discord_electron_rce',
    'version' => '1.0',
    'cvss'    => '8.8',
    'type'    => 'RCE',
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
