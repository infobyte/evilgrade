###############
# vlc_plugin_rce.pm
#
# CVE-CUSTOM (RCE, CVSS 7.8, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::vlc_plugin_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'vlc_plugin_rce',
    'version' => '1.0',
    'cvss'    => '7.8',
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
