#!/usr/bin/perl
# Synthetic Sparkle updater client (HTTP and HTTPS).
#
# Emulates the real Sparkle auto-update flow closely enough to validate the
# evilgrade macos_sparkle_bypass module end to end, including the TLS layer:
#
#   1. GET the appcast feed (http:// or https://).
#   2. Parse the newest <item>: sparkle:version + <enclosure url=.. length=..>.
#   3. Compare against the installed version; update if newer.
#   4. Download the enclosure from the URL in the appcast (same scheme).
#   5. Verify the advertised length (Sparkle's size check).
#   6. "Install": unpack the container and run the bundle executable.
#
# For https:// the client validates the server certificate. The trust anchor
# is controlled by env SPARKLE_CAFILE:
#   - set to a CA pem  -> verify the chain against it (realistic: the victim
#                         trusts that CA, e.g. a corporate/eMudhra CA).
#   - unset            -> verify against the system trust store (default).
#   - set to "NONE"    -> disable verification (insecure; for contrast only).
#
# Usage: perl sparkle_client.pl <appcast-url> [installed-version]
use strict;
use warnings;
use IO::Socket::INET;

my $appcast_url = $ARGV[0] or die "usage: $0 <appcast-url> [installed-version]\n";
my $installed   = $ARGV[1] // '1.0';
my $cafile      = $ENV{SPARKLE_CAFILE};

sub http_get {
    my ($url) = @_;
    my ($scheme, $host, $port, $path) =
        $url =~ m{^(https?)://([^/:]+)(?::(\d+))?(/\S*)?$}
        or die "[client] bad url: $url\n";
    $path ||= '/';
    my $sock;
    if ($scheme eq 'https') {
        $port ||= 443;
        require IO::Socket::SSL;
        my %tls = (PeerAddr => $host, PeerPort => $port, Timeout => 10,
                   SSL_hostname => $host);          # SNI
        if (defined $cafile && $cafile eq 'NONE') {
            $tls{SSL_verify_mode} = IO::Socket::SSL::SSL_VERIFY_NONE();
            print "[tls] verification DISABLED (insecure)\n";
        } else {
            $tls{SSL_verify_mode} = IO::Socket::SSL::SSL_VERIFY_PEER();
            if (defined $cafile) {
                $tls{SSL_ca_file} = $cafile;
                print "[tls] verifying against CA: $cafile\n";
            } else {
                print "[tls] verifying against system trust store\n";
            }
        }
        $sock = IO::Socket::SSL->new(%tls)
            or die "[client] TLS to $host:$port FAILED: $IO::Socket::SSL::SSL_ERROR\n";
        my $cn = $sock->peer_certificate('commonName') // '?';
        my $iss = $sock->peer_certificate('issuer') // '?';
        print "[tls] connected; server cert CN=$cn\n[tls]   issuer: $iss\n";
    } else {
        $port ||= 80;
        $sock = IO::Socket::INET->new(PeerAddr => $host, PeerPort => $port, Timeout => 10)
            or die "[client] cannot connect to $host:$port: $!\n";
    }
    print $sock "GET $path HTTP/1.0\r\nHost: $host\r\nUser-Agent: Sparkle/1.5\r\nAccept: */*\r\n\r\n";
    local $/; my $resp = <$sock>; close $sock;
    my ($hdr, $body) = split /\r\n\r\n/, $resp, 2;
    return ($hdr, $body // '');
}

print "=== Synthetic Sparkle updater ===\n";
print "[client] installed version: $installed\n";
print "[client] 1. fetching appcast: $appcast_url\n";
my ($h, $appcast) = http_get($appcast_url);
my ($code) = $h =~ m{^HTTP/\S+\s+(\d+)};
die "[client] appcast fetch failed (HTTP $code)\n" unless $code && $code == 200;
print "[client]    got appcast (" . length($appcast) . " bytes, HTTP $code)\n";

my ($ver) = $appcast =~ /sparkle:version>?["']?\s*([\d.]+)/;
my ($encl_url, $encl_len) = $appcast =~ /<enclosure\b[^>]*\burl="([^"]+)"[^>]*\blength="(\d+)"/s;
unless ($encl_url) {
    ($encl_len, $encl_url) = $appcast =~ /<enclosure\b[^>]*\blength="(\d+)"[^>]*\burl="([^"]+)"/s;
}
die "[client] could not parse enclosure\n" unless $encl_url && defined $ver;
print "[client] 2. parsed item: version=$ver enclosure=$encl_url (length=$encl_len)\n";

sub vnum { my @p = split /\./, shift; $p[0]*1000 + ($p[1]//0) }
if (vnum($ver) <= vnum($installed)) { print "[client]    up to date; no update.\n"; exit 0; }
print "[client] 3. remote $ver > installed $installed -> updating\n";

print "[client] 4. downloading enclosure...\n";
my ($dh, $dmg) = http_get($encl_url);
my ($dcode) = $dh =~ m{^HTTP/\S+\s+(\d+)};
die "[client] enclosure download failed (HTTP $dcode)\n" unless $dcode && $dcode == 200;
print "[client]    downloaded " . length($dmg) . " bytes (HTTP $dcode)\n";

if (length($dmg) != $encl_len) {
    die "[client] 5. length mismatch: got ".length($dmg)." expected $encl_len (Sparkle aborts)\n";
}
print "[client] 5. length check OK ($encl_len bytes)\n";

my $dir = "/tmp/sparkle_dl"; system("rm -rf $dir; mkdir -p $dir");
open(my $f, '>', "$dir/update.dmg") or die $!; binmode $f; print $f $dmg; close $f;
print "[client] 6. mounting/unpacking update + launching bundle...\n";
my $rc = system("tar xzf $dir/update.dmg -C $dir 2>/dev/null");
if ($rc == 0 && -x "$dir/Update.app/Contents/MacOS/install.sh") {
    system("$dir/Update.app/Contents/MacOS/install.sh");
    print "[client]    bundle executable ran.\n";
} else {
    print "[client]    (container not in expected synthetic format; raw dmg at $dir/update.dmg)\n";
}
print "=== update flow complete ===\n";
