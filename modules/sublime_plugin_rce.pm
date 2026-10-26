###############
# sublime_plugin_rce.pm
#
# CVE-2021-21224 (RCE, CVSS 5.3, Year 2021)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::sublime_plugin_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'sublime_plugin_rce',
    'version' => '1.0',
    'cvss'    => '5.3',
    'type'    => 'RCE',
    'year'    => '2021',
    'cve'     => 'CVE-2021-21224',
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
