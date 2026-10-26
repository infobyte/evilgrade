###############
# svn_rce.pm
#
# CVE-2018-11782 (RCE, CVSS 7.5, Year 2018)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::svn_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'svn_rce',
    'version' => '1.0',
    'cvss'    => '7.5',
    'type'    => 'RCE',
    'year'    => '2018',
    'cve'     => 'CVE-2018-11782',
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
