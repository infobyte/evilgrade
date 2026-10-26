###############
# vscode_liveserver_rce.pm
#
# CVE-CUSTOM (RCE, CVSS 8.5, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::vscode_liveserver_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'vscode_liveserver_rce',
    'version' => '1.0',
    'cvss'    => '8.5',
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
