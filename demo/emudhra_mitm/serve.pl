#!/usr/bin/perl
# serve.pl - start evilgrade's real webserver non-interactively for the demos.
# Enables the eMudhra MITM modules and binds the given SSL port, without the
# interactive Term::Shell (which needs a TTY). This drives the SAME evilgrade
# webserver + modules + cert path the interactive shell uses.
#
# usage: /usr/bin/perl demo/emudhra_mitm/serve.pl <sslport> <module[:lhost:lport]> [module...]
use lib '.'; use lib './isrcore';
use isrcore::shellz; $|=1;
my $sslport = shift @ARGV or die "usage: serve.pl <sslport> <module[:lhost:lport]>...\n";
my $sh   = isrcore::shellz->new;
my $main = $sh->{'isrmain'};
$main->{'Base'}->{'options'}->{'sslport'}->{'val'}  = $sslport;
$main->{'Base'}->{'options'}->{'port'}->{'val'}     = $sslport + 1;   # http port (unused by demos)
$main->{'Base'}->{'options'}->{'sslcert'}->{'val'}  = 'certs/emudhra_mitm';
$main->{'Base'}->{'options'}->{'DNSEnable'}->{'val'} = 0;
for my $spec (@ARGV) {
    my ($name,$lhost,$lport) = split /:/, $spec;
    my $m = $main->{'modules'}->{$name} or die "module $name not found\n";
    $m->{'Base'}->{'options'}->{'enable'}->{'val'} = 1;
    $m->{'Base'}->{'options'}->{'lhost'}->{'val'} = $lhost if defined $lhost && $m->{'Base'}->{'options'}->{'lhost'};
    $m->{'Base'}->{'options'}->{'lport'}->{'val'} = $lport if defined $lport && $m->{'Base'}->{'options'}->{'lport'};
    print "[serve] enabled module: $name\n";
}
print "[serve] evilgrade webserver starting on :$sslport (sslcert=certs/emudhra_mitm)\n";
$sh->run_start($sh);
$SIG{TERM} = sub { exit 0 };
sleep 100000;
