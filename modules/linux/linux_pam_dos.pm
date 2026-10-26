###############
# linux_pam_dos.pm
#
# CVE-2020-14343 (DoS, CVSS 6.8, Year 2020)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::linux_pam_dos;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'linux_pam_dos',
    'version' => '1.0',
    'cvss'    => '6.8',
    'type'    => 'DoS',
    'year'    => '2020',
    'cve'     => 'CVE-2020-14343',
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
