###############
# macos_gatekeeper_libarchive.pm
#
# CVE-2024-27853 (Bypass, CVSS 8, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::macos_gatekeeper_libarchive;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'macos_gatekeeper_libarchive',
    'version' => '1.0',
    'cvss'    => '8',
    'type'    => 'Bypass',
    'year'    => '2024',
    'cve'     => 'CVE-2024-27853',
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
