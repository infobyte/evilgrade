###############
# office_excel_rce.pm
#
# CVE-2024-49029 (RCE, CVSS 9.2, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::office_excel_rce;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'office_excel_rce',
    'version' => '1.0',
    'cvss'    => '9.2',
    'type'    => 'RCE',
    'year'    => '2024',
    'cve'     => 'CVE-2024-49029',
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
