###############
# dnsserver.pm
#
# Copyright 2010 Francisco Amato
#
# This file is part of isr-evilgrade, www.faradaysec.com .
#
# isr-evilgrade is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 2 of the License.
#
# isr-evilgrade is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with isr-evilgrade; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
# '''
##
package isrcore::dnsserver;

use strict;

#external modules
use IO::Socket;
use isrcore::utils;
use POSIX ":sys_wait_h";
use Data::Dump qw(dump);

use FindBin;
use lib "$FindBin::Bin";
use IO::Socket;
use Sys::Hostname;
use isrcore::Stanford::DNS;
use isrcore::Stanford::DNSserver;



$SIG{INT} = sub { die "$$ dying\n" };

sub catch_zap {
    my $signame = shift;
    return 1;
}

$SIG{HUP} = \&catch_zap;  # best strategy

my $base=
{
    'port' => 53,
    'whoami' => "DNSSERVER",
    'error' => "",
    'enable' => 0,
    'resolve_to' => "127.0.0.1",
    'domains' => (),
};

##########################################################################
# FUNCTION      new
# RECEIVES      
# RETURNS
# EXPECTS
# DOES		class's constructor
sub new {
    my $class = shift;
    my $self = {'Base' => $base, @_ };
    return bless $self, $class;
}	    

##########################################################################
# FUNCTION      start
# RECEIVES      [shellzobj]
# RETURNS
# EXPECTS
# DOES		start webserver
sub start {	    
    my $self = shift;
    my $shellz = shift;

    #ignore child process avoid zombies.
    $SIG{CHLD} = 'IGNORE';

    #create socket
    if ( $self->{'Base'}->{'enable'} == 0 ){
       return;
    }
    my $nserver = new isrcore::Stanford::DNSserver (
	               listen_on => ["0.0.0.0"],
		       port      =>   $self->{'Base'}->{'port'},
		       daemon    =>  "no",
		       logfunc	 => sub { $shellz->printshell("[$self->{'Base'}->{'whoami'}] - $_[0]\n",1) },
		       debug 	 => 1,
#		       loopfunc  => sub { $shellz->printshell("[$self->{'Base'}->{'whoami'}] - ".dump(@_)."DNS Server Ready. Waiting for Connections\n");     },
		      );

    if( !$nserver )
      {
	$self->{'Base'}->{'error'} = "[$self->{'Base'}->{'whoami'}] - Cant't create a listening socket: $@";
	return;
     }else{
        $shellz->printshell("[$self->{'Base'}->{'whoami'}] - DNS Server Ready. Waiting for Connections ...\n");
     }

    my $resolve_ip = unpack('N',inet_aton($self->{'Base'}->{'resolve_to'})  );
    my $vhost;
    foreach $vhost ( @{$self->{'Base'}->{'domains'}} ){
	$nserver->add_static($vhost, T_A, rr_A($resolve_ip));
	$nserver->add_static($vhost, T_AAAA, rr_A($resolve_ip));
    }
    
   while(1) { 
        if( $nserver->answer_queries() == 0 ){
	    $self->{'Base'}->{'error'} = "[$self->{'Base'}->{'whoami'}] - Error Initiating DNS Server";
	    return 0;
	    }
     }
   
 
}

##########################################################################
# FUNCTION      loadconfig
# RECEIVES      
# RETURNS
# EXPECTS
# DOES		load dns server configuration
sub loadconfig{
    my $self=shift;
    my $config=shift;
    my $vhosts;
    my @domains = ();
    $self->{'Base'}->{'port'}=$config->{'Base'}->{'options'}->{'DNSPort'}->{'val'};
    $self->{'Base'}->{'enable'}=$config->{'Base'}->{'options'}->{'DNSEnable'}->{'val'};
    $self->{'Base'}->{'resolve_to'}=$config->{'Base'}->{'options'}->{'DNSAnswerIp'}->{'val'};
    
    # load VHOSTS
     
     foreach my $name (keys %{$config->{'modules'}}){
	         my $module = $config->{'modules'}->{$name};
	         if ($module->{'Base'}->{'options'}->{'enable'}->{'val'} == 1) {
		     $vhosts = $module->{'Base'}->{'vh'};
		     $vhosts =~ s/\(|\)//g;
		     push(@domains,split(/\|/,$vhosts));
		     
		  
		 }
	     }
    $self->{'Base'}->{'domains'} = \@domains;
    return 1;
    
}


##########################################################################
# FUNCTION      stop
# RECEIVES      
# RETURNS
# EXPECTS
# DOES		stop dns server
sub stop{
    my $self=shift;

# hup x kill
    kill  KILL   => $self->{'Base'}->{'child'};
    $self->{'Base'}->{'child'}=0;
  
    return;
}

##########################################################################
# FUNCTION      status
# RECEIVES      
# RETURNS
# EXPECTS
# DOES		dns status
sub status{
    my $self = shift;
 
    if ($self->{'Base'}->{'child'} && waitpid($self->{'Base'}->{'child'},WNOHANG) != -1){
	return 1;
    } else { 
	$self->{'Base'}->{'child'}=0;
	return 0;
    }
}

1;
