###############
# norton_antivirus_privesc.pm
#
# CVE-2016-3291 (PrivEsc, CVSS 7.5, Year 2016)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::norton_antivirus_privesc;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'norton_antivirus_privesc',
    'version' => '1.0',
    'cvss'    => '7.5',
    'type'    => 'PrivEsc',
    'year'    => '2016',
    'cve'     => 'CVE-2016-3291',
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
