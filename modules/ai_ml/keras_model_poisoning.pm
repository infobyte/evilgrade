###############
# keras_model_poisoning.pm
#
# CVE-CUSTOM (Poisoning, CVSS 8.5, Year 2024)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::keras_model_poisoning;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'keras_model_poisoning',
    'version' => '1.0',
    'cvss'    => '8.5',
    'type'    => 'Poisoning',
    'year'    => '2024',
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
