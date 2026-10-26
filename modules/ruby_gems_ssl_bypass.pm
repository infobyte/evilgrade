###############
# ruby_gems_ssl_bypass.pm
#
# CVE-2013-0256 (SSL Bypass, CVSS 8.8, Year 2013)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::ruby_gems_ssl_bypass;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'ruby_gems_ssl_bypass',
    'version' => '1.0',
    'cvss'    => '8.8',
    'type'    => 'SSL Bypass',
    'year'    => '2013',
    'cve'     => 'CVE-2013-0256',
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
