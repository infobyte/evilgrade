###############
# adobe_reader_update.pm
#
# CVE-2020-9715 (RCE, CVSS 7.8, Year 2020)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::adobe_reader_update;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'adobe_reader_update',
    'version' => '1.0',
    'cvss'    => '7.8',
    'type'    => 'RCE',
    'year'    => '2020',
    'cve'     => 'CVE-2020-9715',
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
