###############
# office_powerpoint_rce.pm
#
# CVE-2024-49030 (RCE, CVSS 9, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::office_powerpoint_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'office_powerpoint_rce',
    'version' => '1.0',
    'cvss'    => '9',
    'type'    => 'RCE',
    'year'    => '2024',
    'cve'     => 'CVE-2024-49030',
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
