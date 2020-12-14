###############
# main.pm
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
package isrcore::main;

use strict;

#external modules
use Data::Dump qw(dump);

my $options = {
    'port'  => { 'val' => 80, 'desc' => 'Webserver listening port'},
    'sslport'  => { 'val' => 443, 'desc' => 'Webserver SSL listening port'},
    'RPCfaraday'  => { 'val' => "http://127.0.0.1:9876/", 'desc' => 'Faraday RPC Server'},
    'faraday'  => { 'val' => 0, 'desc' => 'Enable RPC Faraday connection'},
    'debug'  => { 'val' => 1, 'desc' => 'Debug mode'},    
    'DNSPort'  => { 'val' => 53, 'desc' => 'Listen Name Server port'},
    'DNSEnable'  => { 'val' => 1, 'desc' => 'Enable DNS Server ( handle virtual request on modules )'},
    'DNSAnswerIp'  => { 'val' => "127.0.0.1", 'desc' => 'Resolve VHost to ip  )'},
                
};
my $base = {
    'path' => 'modules',
    'pwd'	 => './',
    'options' => $options
};
    
##########################################################################
# FUNCTION	new
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
# FUNCTION	loadmodules
# RECEIVES
# RETURNS
# EXPECTS
# DOES		module's loader
sub loadmodules{

    my $self = shift;
    my @modules;

    my $path = $self->{'Base'}->{'pwd'}.$self->{'Base'}->{'path'};

    local *DIR;
    if (!opendir(DIR,"$path")){
	return "[LOADMODULES] - (*) No such file or directory ($path)";
    }
    my @files = grep(!/(^\.\.?$|^\.svn$)/,readdir(DIR));
    closedir(DIR);
    
    my $modules;
    my $mods=0;
    foreach my $f (@files)
    {
	my $base = $self->{'Base'}->{'path'}."/".$f;
	my ($name) = $f =~ m/([^\.]+)\.pm/;

	delete $INC{$self->{'Base'}->{'path'}."/".$name};

	$self->printd("Loading module: $base\n");
    	my $result = do($base);
			
	if ($@) {
	    $self->println('Error: Loading module ($base):' . $@);
	    delete $INC{$self->{'Base'}->{'path'}."/".$name};
	    next;
	}
	if (!$result){
	    $self->println("Error: module ($base) did not return true\n");
	    next;
	}
	my $object = "$self->{'Base'}->{'path'}::$name";
	my $module;
	if (eval { $module = $object->new()}){ #Verify object's creation
	    $mods++;
	    $module = $object->new();
	    $modules->{$name} = $module;
	}else{
	    $self->println("Error: module ($base): $@\n");
	}

    }
    

$self->println("            _ _                     _      \n");
$self->println("           (_) |                   | |     \n");
$self->println("  _____   ___| | __ _ _ __ __ _  __| | ___ \n");
$self->println(" / _ \\ \\ / / | |/ _` | '__/ _` |/ _` |/ _ \\ \n");
$self->println("|  __/\\ V /| | | (_| | | | (_| | (_| |  __/ \n");
$self->println(" \\___| \\_/ |_|_|\\__, |_|  \\__,_|\\__,_|\\___| \n");
$self->println("                __/ |                      \n");
$self->println("                |___/ \n");
$self->println("-------------------------------------------\n");
$self->println("---------------------  www.faradaysec.com \n");

    $self->println("- $mods modules available.\n\n");
    
    delete $self->{'modules'};
    $self->{'modules'} = $modules;
    return 1;
}

##########################################################################
# FUNCTION	println
# RECEIVES	msg
# RETURNS	
# EXPECTS
# DOES		print console msg
sub println{
    my $self = shift;
    my ($msg) = @_;
    printf $msg;
}

##########################################################################
# FUNCTION	printd
# RECEIVES	msg
# RETURNS
# EXPECTS
# DOES		print console debug msg
sub printd{
    my $self = shift;
    my ($msg) = @_;
#    print dump($self);
    printf "[DEBUG] - " . $msg if ($self->{'Base'}->{'options'}->{'debug'}->{'val'});
}

##########################################################################
# FUNCTION	ptitle
# RECEIVES	msg
# RETURNS
# EXPECTS
# DOES		print console debug msg
sub ptitle{
    my $self = shift;
    my ($msg) = @_;
    printf "\n$msg:\n";
    printf "="x length($msg);
    printf "\n\n";
}

1;
