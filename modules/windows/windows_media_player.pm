###############
# windows_media_player.pm
#
# CVE-2018-8305 (RCE, CVSS 7.8, Year 2018)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::windows_media_player;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'windows_media_player',
    'version' => '1.0',
    'cvss'    => '7.8',
    'type'    => 'RCE',
    'year'    => '2018',
    'cve'     => 'CVE-2018-8305',
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
