###############
# shellz.pm
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

package isrcore::shellz;

use strict;

#internal modules
use base qw(isrcore::Shell);
use isrcore::webserver;
use isrcore::main;
use isrcore::ASCIITable;
use isrcore::dnsserver;
#external modules
use Data::Dump qw(dump);
require RPC::XML;
require RPC::XML::Client;

#ignore child's process to avoid zombie
$SIG{CHLD} = 'IGNORE';

##########################################################################
# FUNCTION	init
# RECEIVES
# RETURNS
# EXPECTS
# DOES		class initialize
my $ppid=0;
sub init {
    my $self = shift;
    my $webserver = isrcore::webserver->new();
    my $dnsserver = isrcore::dnsserver->new();    
    my $isrmain = isrcore::main->new();
    if( $shellz::ppid == 0 )   
    {
          $shellz::ppid= $$;    
     }
    #Loadmodules
    my $ret = $isrmain->loadmodules();
    if ($ret != 1){ # loadmodules error
	$isrmain->println($ret);
	exit;
    }
    $self->{'dnsserver'}=$dnsserver;    
    $self->{'webserver'}=$webserver;
    $self->{'isrmain'}=$isrmain;
    $self->{'VERSION'}="2.0.1";    
    $self->{'path'}="";
    $self->{'prompt'}="evilgrade";
    $self->{'change'}=0;
}

##########################################################################
# FUNCTION	prompt_str
# RECEIVES
# RETURNS
# EXPECTS
# DOES		return shell's prompt
sub prompt_str {
    my $self =shift;
    my $prompt = $self->{'prompt'};
    if ($self->{'path'}){
	$prompt .= "($self->{'path'})";
    }
    $prompt .= ">";
"$prompt"
} #()


##########################################################################
# SHELLS COMMANDS
##########################################################################

##########################################################################
# FUNCTION	run_show
# RECEIVES	cmd
# RETURNS
# EXPECTS
# DOES		show [object]'s information
sub run_show { 
    my $self = shift;
    my ($cmd) = @_;
    my $mods=0;
    if ($cmd eq "modules"){
	$self->{'isrmain'}->ptitle("List of modules");
	foreach my $module (sort(keys %{$self->{'isrmain'}->{'modules'}})){
	    $self->{'isrmain'}->println("$module\n");
	    $mods++;
	}
	$self->{'isrmain'}->println("- $mods modules available.\n\n");;
	$self->{'isrmain'}->println("\n");

    }elsif ($cmd eq "status"){
	$self->run_status($self);

    }elsif ($cmd eq "version"){
	$self->run_version($self);

    }elsif ($cmd eq "vhosts"){
	$self->run_vhosts($self);

    }elsif ($cmd eq "active"){
	$self->{'isrmain'}->ptitle("List of actived modules");
	foreach my $module (@{$self->{'webserver'}->{'current'}}){
	    $self->{'isrmain'}->println("$module\n");
	    $mods++;
	}
	$self->{'isrmain'}->println("- $mods modules loaded.\n\n");;
	$self->{'isrmain'}->println("\n");	
    }elsif ($cmd eq "options"){
	$self->{'isrmain'}->ptitle("Display options");
	my $object;
	if ($self->{'path'}){
	    $object = $self->{'isrmain'}->{'modules'}->{$self->{'path'}}->{'Base'};
	    $self->{'isrmain'}->println("Name = $object->{'name'}\n");
	    $self->{'isrmain'}->println("Version = $object->{'version'}\n");
	    $self->{'isrmain'}->println("Author = ".dump($object->{'author'})."\n");
	    $self->{'isrmain'}->println("Description = ".dump($object->{'description'})."\n");
	    $self->{'isrmain'}->println("VirtualHost = ".dump($object->{'vh'})."\n\n");
	}else{
	    $object = $self->{'isrmain'}->{'Base'};
	}

	my $t = new isrcore::ASCIITable;
	$t->setCols(['Name','Default','Description']);
	foreach my $module (keys %{$object->{'options'}}){
	    if (!$object->{'options'}->{$module}->{'hidden'}){ #Verify if it's a hidden option
		$t->addRow($module,$object->{'options'}->{$module}->{'val'},$object->{'options'}->{$module}->{'desc'});
	    }
	}
	$self->{'isrmain'}->println($t->draw()."\n");
	
    }
}

##########################################################################
# FUNCTION	run_set
# RECEIVES	cmd,value
# RETURNS
# EXPECTS
# DOES		configure option
sub run_set { 
    my $self = shift;
    my ($cmd,$value) = @_;
    $self->{'isrmain'}->println("set $cmd, $value\n");
    my $object;

    if ($self->{'path'}){
        $object = \$self->{'isrmain'}->{'modules'}->{$self->{'path'}}->{'Base'}->{'options'};
    }else{
        $object = \$self->{'isrmain'}->{'Base'}->{'options'};
    }

    if (!$cmd){
        $self->{'isrmain'}->println("(*) Please specify option name\n");
        return	
    }else{
        if (!exists($$object->{$cmd})){
            $self->{'isrmain'}->println("(*) Option name ($cmd) did not exists\n");
            return
	}else {
	    $self->{'change'}=1;
	    $$object->{$cmd}->{'val'} =$value; #TODO: check exists val
	    #TODO: Message required webserver restart
	}
    }
    
}

##########################################################################
# FUNCTION	run_configure
# RECEIVES	cmd
# RETURNS
# EXPECTS
# DOES		configure modules
sub run_configure { 
    my $self = shift;    
    my ($cmd) = @_;

    if ($cmd){
        if (!exists($self->{'isrmain'}->{'modules'}->{$cmd})){
    	    $self->{'isrmain'}->println("(*) Module name ($cmd) did not exists\n");
	    return
	}
	$self->{'path'}=$cmd
    }else {
	$self->{'path'}="";
    }    
}

##########################################################################
# FUNCTION	run_vhosts
# RECEIVES	cmd
# RETURNS
# EXPECTS
# DOES		display vhosts available
sub run_vhosts{
    my $self = shift;
    my ($cmd) = @_;
    $self->{'isrmain'}->ptitle("Virtual hosts");
    print $self->{'isrmain'}->println(dump($self->{'dnsserver'}->{'Base'}->{'domains'}));
}


##########################################################################
# FUNCTION	run_version
# RECEIVES	cmd
# RETURNS
# EXPECTS
# DOES		display console version
sub run_version{
    my $self = shift;
    my ($cmd) = @_;
    $self->{'isrmain'}->println("version " . $self->{'VERSION'}."\n");
}

##########################################################################
# FUNCTION	run_reload
# RECEIVES
# RETURNS
# EXPECTS
# DOES		reload modules
sub run_reload { 
    my $self = shift;
    $self->{'isrmain'}->println("reload\n");
    $self->{'isrmain'}->loadmodules();
}

##########################################################################
# FUNCTION	run_start
# RECEIVES
# RETURNS
# EXPECTS
# DOES		start servers
sub run_start {
    my $self = shift;
    my ($cmd) = @_;
        
    start_server( $self, "webserver",$cmd);
    start_server( $self, "dnsserver",$cmd) unless ( $self->{'isrmain'}->{'Base'}->{'options'}->{'DNSEnable'}->{'val'} == 0 );
}
                

sub start_server {

    my $self = shift;
    my $server_type = shift;
    my ($cmd) = @_;


    if ($self->{$server_type}->status()  ){
        $self->{'isrmain'}->println("$self->{$server_type}->{'Base'}->{'whoami'} : (pid $self->{$server_type}->{'Base'}->{'child'}) already running\n");
        return;
    }
    my $response = $self->{$server_type}->loadconfig($self->{'isrmain'});
    if ($response != 1){ #error loadconfig
        $self->{'isrmain'}->println($response);
        return;
    }

   if( $server_type == "webserver" ){
    #solo para webserver esto
    $self->{'comm'}->{'parent'} = $self->{'parent'};
    $self->{'comm'}->{'child'} = $self->{'child'};
    }
    my $child;
    my $line;
    # crear el fork para salir

    die "Can't fork: $!" unless defined ($child = fork());
    if ($child==0) {
        my $line;

        $self->{$server_type}->start($self);
        if ($self->{$server_type}->{'Base'}->{'error'}){
            $self->{'isrmain'}->println("\n\nError: $self->{$server_type}->{'Base'}->{'error'}\n");
         }

        exit 0;
   }
 
  $self->{$server_type}->{'Base'}->{'child'} = $child;

}



##########################################################################
# FUNCTION	run_status
# RECEIVES
# RETURNS
# EXPECTS
# DOES		display servers status
sub get_status {
    my $self = shift;
    my $server_type = shift;

    if ($self->{$server_type}->status()){
        $self->{'isrmain'}->println("$self->{$server_type}->{'Base'}->{'whoami'} :  (pid $self->{$server_type}->{'Base'}->{'child'}) already running\n");
    }
    else{
        $self->{'isrmain'}->println("$self->{$server_type}->{'Base'}->{'whoami'} :  stopped.\n");
    }

}
sub run_status{
    my $self = shift;

    get_status($self,"webserver");
    get_status($self,"dnsserver") unless ( $self->{'isrmain'}->{'Base'}->{'options'}->{'DNSEnable'}->{'val'} == 0 );

    my $j=0;
    $self->{'isrmain'}->ptitle("Users status");

    my $t = new isrcore::ASCIITable;
    $t->setCols(['Client','Module','Status','Md5,SHA256,Cmd,File']);
    foreach my $ip (keys %{$self->{'webserver'}->{'users'}}){
        foreach my $module (keys %{$self->{'webserver'}->{'users'}->{$ip}}){
            my ($obj,$file) = $self->{'webserver'}->{'users'}->{$ip}->{$module};
            $file = $obj->{'file'} if ($obj->{'file'});
            $t->addRow($ip,$module,$obj->{'status'},$file);
        }
        $j++;
    }

    if ($j){ #object found
        $self->{'isrmain'}->println($t->draw()."\n");
    }else{
        $self->{'isrmain'}->println("[*] Waiting users..\n")
    }

}

##########################################################################
# FUNCTION	run_stop
# RECEIVES
# RETURNS
# EXPECTS
# DOES		stop servers
sub stop_server {
    my $self = shift;
    my $server_type = shift;
        
    if ($self->{$server_type}->status()){
        $self->{$server_type}->stop();
	$self->{'isrmain'}->println("Stopping $self->{$server_type}->{'Base'}->{'whoami'}  [OK]\n");
	
    }
    else{
        $self->{'isrmain'}->println("$self->{$server_type}->{'Base'}->{'whoami'} : stopped\n");
    }
}
sub run_stop {
    my $self = shift;

    stop_server($self,"webserver");
    stop_server($self,"dnsserver")  unless ( $self->{'isrmain'}->{'Base'}->{'options'}->{'DNSEnable'}->{'val'} == 0 );
                                                            
}
                                                            
##########################################################################
# FUNCTION	run_restart
# RECEIVES
# RETURNS
# EXPECTS
# DOES		restart servers
sub run_restart {
    my $self = shift;
    $self->run_stop();
    $self->run_start();
}

##########################################################################
# FUNCTION	run_exit
# RECEIVES
# RETURNS
# EXPECTS
# DOES		exit console
sub run_exit {
  
    my $self = shift;
   if( $$ == $shellz::ppid ){
    $self->run_stop();
    kill KILL   => $self->{pid};
    $self->{on_signal}=1;
    $self->stoploop();
    $self->SUPER::DESTROY;
    system("reset");
    }
#    $self->SUPER::DESTROY;
#    require Term::Screen;
#    my $terminal = new Term::Screen;
#    $terminal->clrscr();
#    $terminal::DESTROY;
#    sleep 2;
    exit 0;
}

##########################################################################
# FUNCTION	console_cmd
# RECEIVES	xml cmd command
# RETURNS
# EXPECTS
# DOES		communication commands between thread and parent (called from Shell)
sub console_cmd {
    my $self = shift;
    my ($cmd) = @_;

    my ($action,$module,$ip,$file);
    #TODO: Move to object
    my $action =$1 if $cmd =~ /\<action\>([\w]+)\<\/action\>/;
    my $module =$1 if $cmd =~ /\<module\>([\w\:\_\-]+)\<\/module\>/;
    my $ip =$1 if $cmd =~ /\<ip\>([\d\.]+)\<\/ip\>/;
    my $file =$1 if $cmd =~ /<file\>([\w\W]+)\<\/file\>/;
    my $md5 =$1 if $cmd =~ /<md5\>([\w\W]+)\<\/md5\>/;
    my $sha256 =$1 if $cmd =~ /<sha256\>([\w\W]+)\<\/sha256\>/;        
    my $cwd =$1 if $cmd =~ /<cmd\>([\w\W]+)\<\/cmd\>/;        
    my $tfile=$self->{'webserver'}->{'users'}->{$ip}->{$module}->{'file'};

    $self->{'webserver'}->{'users'}->{$ip}->{$module}->{'status'}=$action if ($action);
    if ($file) {
	$self->{'webserver'}->{'users'}->{$ip}->{$module}->{'file'}=($tfile) ? "$tfile\n$md5,$sha256,'$cwd',$file" :"$md5,$sha256,'$cwd',$file";
    }

    #RPC faraday connection
    if ($self->{'isrmain'}->{'Base'}->{'options'}->{'faraday'}->{'val'} == 1){
        eval {
            my $cli = RPC::XML::Client->new($self->{'isrmain'}->{'Base'}->{'options'}->{'RPCfaraday'}->{'val'});
            my $resp = $cli->send_request('devlog','Importing evilgrade information');
            my $h_id = $cli->send_request('createAndAddHost',$ip,"unknown");
            
            my $var = RPC::XML::array->new("URL-http://github.com/infobyte/evilgrade/");
            my $v_id = $cli->send_request('createAndAddVulnToHost',$h_id->value,"Evilgrade injection -".$module,"This ip is interacted with evilgrade framework see the notes inside the host for more information",$var,"HIGH");
            #add note host id, note, value
            my $n_id = $cli->send_request('createAndAddNoteToHost',$h_id->value,"Evilgrade -".$module,$action) if ($action);
            my $n_id2 = $cli->send_request('createAndAddNoteToHost',$h_id->value,"Evilgrade file -".$module,($tfile) ? "$tfile\n$md5,$sha256,'$cwd',$file" :"$md5,$sha256,'$cwd',$file");

        }
    }
    
}
##########################################################################
## HELP
##########################################################################
sub smry_show {"Display information of <object>."}
sub smry_version {"Display framework version."}
sub smry_set {"Configure variables"}
sub smry_configure {"Configure <module-name>"}
sub smry_reload {"Reload to update all the modules"}
sub smry_start {"Start webserver"}
sub smry_status {"Get webserver status"}
sub smry_stop {"Stop webserverR"}
sub smry_restart {"Restart webserver"}
sub smry_vhosts {"Show vhosts enable"}

sub help_show {
    my ($o,$cmd) = @_;
    <<'END';
Display information of <object>
END
}

##########################################################################
## AUTOCOMPLETE
##########################################################################

##########################################################################
# FUNCTION      comp_show
# RECEIVES      
# RETURNS
# EXPECTS
# DOES		autocomplete command show
sub comp_show{
    my ($o, $word, $line, $start) = @_;
    my @comp = ('modules','active','options','status','version','vhosts');
    @comp = sort @comp;
    @comp;
}

##########################################################################
# FUNCTION      comp_configure
# RECEIVES      
# RETURNS
# EXPECTS
# DOES		autocomplete command configure
sub comp_configure {
    my ($o, $word, $line, $start) = @_;
    my @comp = keys %{$o->{'isrmain'}->{'modules'}};
    @comp = sort @comp;
    @comp;		    
}


##########################################################################
# FUNCTION      gtime
# RECEIVES
# RETURNS       parsed time string
# EXPECTS
# DOES          get parsed localtime
sub gtime{
    my @t = localtime(time);
    return "[".$t[3]."/".(int($t[4])+1)."/".(int($t[5])+1900).":".$t[2].":".$t[1].":".$t[0]."] - ";
}
	
##########################################################################
## PUBLIC FUNCTIONS
##########################################################################

##########################################################################
# FUNCTION      printshell
# RECEIVES      msg
# RETURNS
# EXPECTS	message,debug,time
# DOES		print information to the console thread
sub printshell{
    my $self = shift;
    my ($msg,$debug,$time) = @_;
    #return if 
    return if ($debug && $self->{'isrmain'}->{'Base'}->{'options'}->{'debug'}->{'val'} == 0);
    local *PARENT = $self->{'comm'}->{'parent'};

    my $data;
    $data=$self->gtime if (!$time);
    $data .= "[DEBUG] - " if ($debug);
    $data .=$msg;
    print PARENT $data;
    sleep 1;
}

##########################################################################
# FUNCTION      sendcommand
# RECEIVES      msg
# RETURNS
# EXPECTS	
# DOES		send internal command between child and parent
sub sendcommand{
    my $self = shift;
    my ($msg) = @_;
    local *PARENT = $self->{'comm'}->{'parent'};
    print PARENT $msg;
}
1;


