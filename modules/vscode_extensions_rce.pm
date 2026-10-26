###############
# vscode_extensions_rce.pm
#
# CVE-2023-36667 (RCE, CVSS 5.6, Year 2023)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::vscode_extensions_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'vscode_extensions_rce',
    'version' => '1.0',
    'cvss'    => '5.6',
    'type'    => 'RCE',
    'year'    => '2023',
    'cve'     => 'CVE-2023-36667',
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
