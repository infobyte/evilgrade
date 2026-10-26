###############
# windows_task_scheduler.pm
#
# CVE-2019-0150 (PrivEsc, CVSS 6.8, Year 2019)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::windows_task_scheduler;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'windows_task_scheduler',
    'version' => '1.0',
    'cvss'    => '6.8',
    'type'    => 'PrivEsc',
    'year'    => '2019',
    'cve'     => 'CVE-2019-0150',
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
