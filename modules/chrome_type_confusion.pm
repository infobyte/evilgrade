###############
# chrome_type_confusion.pm
#
# CVE-CUSTOM (RCE, CVSS 8.5, Year 2026)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::chrome_type_confusion;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'chrome_type_confusion',
    'version' => '1.0',
    'cvss'    => '8.5',
    'type'    => 'RCE',
    'year'    => '2026',
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
