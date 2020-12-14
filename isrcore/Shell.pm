###############
# Shell.pm
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
package isrcore::Shell;

use strict;
use warnings;
use Data::Dumper;
use Data::Dump qw(dump);
use Term::ReadLine;

use Time::HiRes qw(usleep);
use Socket;
use IO::Handle;
use IO::Select;
$SIG{CHLD} = 'IGNORE';

#kill zombies
#$SIG{INT} = sub { die "[shellz] - $$ dying\n"; };

our $VERSION = '0.02';

#=============================================================================
# isrcore::Shell API methods
#=============================================================================
sub new {
    my $cls = shift;

    my $o = bless {
        term => eval {

            # Term::ReadKey throws ugliness all over the place if we're not
            # running in a terminal, which we aren't during "make test", at
            # least on FreeBSD. Suppress warnings here.
            local $SIG{__WARN__} = sub { };

            # This env setting fixes FD locks in win32 shell.
            $ENV{TERM} = 'not dumb' if $^O eq 'MSWin32';
            Term::ReadLine->new('shell');
        }
            || undef,
        on_signal => 0,
        },
        ref($cls)
        || $cls;

    # Set up the API hash:
    $o->{command} = {};
    $o->{API}     = {
        args        => \@_,
        case_ignore => ( $^O eq 'MSWin32' ? 1 : 0 ),
        check_idle => 0,                # changing this isn't supported
        class      => $cls,
        command    => $o->{command},
        cmd        => $o->{command},    # shorthand
        match_uniq => 1,
        pager => $ENV{PAGER} || 'internal',
        readline => eval { $o->{term}->ReadLine } || 'none',
        script   => ( caller(0) )[1],
        version  => $VERSION,
    };

    # Note: the rl_completion_function doesn't pass an object as the first
    # argument, so we have to use a closure. This has the unfortunate effect
    # of preventing two instances of Term::ReadLine from coexisting.
    my $completion_handler = sub {
        $o->rl_complete(@_);
    };
    if ( $o->{API}{readline} eq 'Term::ReadLine::Gnu' ) {
        my $attribs = $o->{term}->Attribs;
        $attribs->{completion_function} = $completion_handler;
    }
    elsif ( $o->{API}{readline} eq 'Term::ReadLine::Perl' ) {
        $readline::rl_completion_function = $readline::rl_completion_function
            = $completion_handler;
    }
    $o->find_handlers;
    $o->init;
    $o;
}

sub DESTROY {
    my $o = shift;
    $o->fini;
}

sub cmd {
    my $o = shift;
    $o->{line} = shift;
    if ( $o->line =~ /\S/ ) {
        my ( $cmd, @args ) = $o->line_parsed;
        $o->run( $cmd, @args );
        unless ( $o->{command}{run}{found} ) {
            my @c = sort $o->possible_actions( $cmd, 'run' );
            if ( @c and $o->{API}{match_uniq} ) {
                print $o->msg_ambiguous_cmd( $cmd, @c );
            }
            else {
                print $o->msg_unknown_cmd($cmd);
            }
        }
    }
    else {
        $o->run('');
    }
}

sub stoploop { $_[0]->{stop}++ }

sub cmdloop {
    my $o = shift;
    $o->{stop} = 0;
    $o->preloop;

    #    while (defined (my $line = $o->readline($o->prompt_str))) {
    #   $o->cmd($line);
    #   last if $o->{stop};
    #    }

    #communication between STDIN thread and prompt thread
    socketpair( CHILD, PARENT, AF_UNIX, SOCK_STREAM, PF_UNSPEC )
        or die "[ERROR] - STDIN socketpair: $!";
    CHILD->autoflush(1);
    PARENT->autoflush(1);

    #communication MSG entities
    socketpair( CHILDM, PARENTM, AF_UNIX, SOCK_STREAM, PF_UNSPEC )
        or die "[ERROR] - MSG socketpair: $!";
    CHILDM->autoflush(1);
    PARENTM->autoflush(1);

    #save MSG
    $o->{child}  = \*CHILDM;
    $o->{parent} = \*PARENTM;
    $|           = 1;

    die "[ERROR] Can't fork STDIN thread: $!"
        unless defined( my $pid = fork() );
    $o->{pid} = $pid;
    if ( $pid == 0 ) {    #STDIN thread (child)
        close CHILD;
        while (1) {       #STDIN loop
            my $line;
            if ( $^O eq 'MSWin32' ) {
                $line = $o->readline( $o->prompt_str );
            }
            else {
                $line = $o->readline('');
            }
            $line = "empty" unless $line;
            if ( $line eq "empty" ) {
                print PARENT "\n";
            }
            else {
                print PARENT $line . "\n";
            }
            exit 0 if $line eq "exit";
        }
    }
    else {    #PROMPT thread (father)
        close PARENT;

        #Select's handlers
        my $hl  = new IO::Select( \*CHILD );
        my $hl2 = new IO::Select( \*CHILDM );

        #Print Prompt
        print "\c[[4m" . $o->prompt_str . "\c[[0m"
            unless ( $^O eq 'MSWin32' );
        while (1) {    #Msg loop
            usleep(10000);

            #sleep(1); #fix loop cpu usage
            my @ready = $hl->can_read(0);
            foreach my $fh (@ready) {
                my $line = <$fh>;
                $o->cmd($line);
                print "\c[[4m" . $o->prompt_str . "\c[[0m"
                    if ( !$o->{stop} && !( $^O eq 'MSWin32' ) );
            }

            my @ready2 = $hl2->can_read(0);

            #TODO: Detect multiple entries
            foreach my $fh (@ready2) {
                my $line = <$fh>;
                if ( $line =~ /^\<acc\>/ ) {
                    $o->console_cmd($line);
                }
                else {
                    print "\n$line";
                    print "\n" . "\c[[4m" . $o->prompt_str . "\c[[0m";
                }
            }
            if ( $o->{stop} ) {

                #TODO: recovery STDIN
                kill HUP => $pid;
                close(STDIN);
                last;
            }
        }
    }
    $o->postloop;
}
*mainloop = \&cmdloop;

sub readline {
    my $o      = shift;
    my $prompt = shift;
    if ( $o->{on_signal} == 1 ) {
        return "exit\n";
    }
    return $o->{term}->readline($prompt)
        if $o->{API}{check_idle} == 0
        or not defined $o->{term}->IN;

    # They've asked for idle-time running of some user command.
    local $Term::ReadLine::toloop = 1;
    local *Tk::fileevent          = sub {
        my $cls = shift;
        my ( $file, $boring, $callback ) = @_;
        $o->{fh} = $file;        # save the filehandle!
        $o->{cb} = $callback;    # save the callback!
    };
    local *Tk::DoOneEvent = sub {

        # We'll totally cheat and do a select() here -- the timeout will be
        # $o->{API}{check_idle}; if the handle is ready, we'll call &$cb;
        # otherwise we'll call $o->idle(), which can do some processing.
        my $timeout = $o->{API}{check_idle};
        use IO::Select;
        if ( IO::Select->new( $o->{fh} )->can_read($timeout) ) {

            # Input is ready: stop the event loop.
            $o->{cb}->();

        }
        else {
            $o->idle;
        }
    };
    $o->{term}->readline($prompt);
}

sub term { $_[0]->{term} }

# These are likely candidates for overriding in subclasses
sub init        { }           # called last in the ctor
sub fini        { }           # called first in the dtor
sub preloop     { }
sub postloop    { }
sub precmd      { }
sub postcmd     { }
sub console_cmd { }           #internal command between THREADs and parents
sub prompt_str  {'shell> '}
sub idle        { }
sub cmd_prefix  {''}
sub cmd_suffix  {''}

#=============================================================================
# The pager
#=============================================================================
sub page {
    my $o        = shift;
    my $text     = shift;
    my $maxlines = shift || $o->termsize->{rows};
    my $pager    = $o->{API}{pager};

    # First, count the number of lines in the text:
    my $lines = ( $text =~ tr/\n// );

    # If there are fewer lines than the page-lines, just print it.
    if ( $lines < $maxlines or $maxlines == 0 or $pager eq 'none' ) {
        print $text;
    }

    # If there are more, page it, either using the external pager...
    elsif ( $pager and $pager ne 'internal' ) {
        require File::Temp;
        my ( $handle, $name ) = File::Temp::tempfile();
        select( ( select($handle), $| = 1 )[0] );
        print $handle $text;
        close $handle;
        system( $pager, $name ) == 0
            or print <<END;
Warning: can not run external pager '$pager': $!.
END
        unlink $name;
    }

    # ... or the internal one
    else {
        my $togo  = $lines;
        my $line  = 0;
        my @lines = split '^', $text;
        while ( $togo > 0 ) {
            my @text = @lines[ $line .. $#lines ];
            my $ret = $o->page_internal( \@text, $maxlines, $togo, $line );
            last if $ret == -1;
            $line += $ret;
            $togo -= $ret;
        }
        return $line;
    }
    return $lines;
}

sub page_internal {
    my $o        = shift;
    my $lines    = shift;
    my $maxlines = shift;
    my $togo     = shift;
    my $start    = shift;

    my $line = 1;
    while ( $_ = shift @$lines ) {
        print;
        last if $line >= ( $maxlines - 1 );    # leave room for the prompt
        $line++;
    }
    my $lines_left   = $togo - $line;
    my $current_line = $start + $line;
    my $total_lines  = $togo + $start;

    my $instructions;
    if ( $o->have_readkey ) {
        $instructions = "any key for more, or q to quit";
    }
    else {
        $instructions = "enter for more, or q to quit";
    }

    if ( $lines_left > 0 ) {
        local $| = 1;
        my $l = "---line $current_line/$total_lines ($instructions)---";
        my $b = ' ' x length($l);
        print $l;
        my $ans = $o->readkey;
        print "\r$b\r" if $o->have_readkey;
        print "\n" if $ans =~ /q/i or not $o->have_readkey;
        $line = -1 if $ans =~ /q/i;
    }
    $line;
}

#=============================================================================
# Run actions
#=============================================================================
sub run {
    my $o      = shift;
    my $action = shift;
    my @args   = @_;
    $o->do_action( $action, \@args, 'run' );
}

sub complete {
    my $o      = shift;
    my $action = shift;
    my @args   = @_;
    my @compls = $o->do_action( $action, \@args, 'comp' );
    return () unless $o->{command}{comp}{found};
    return @compls;
}

sub help {
    my $o         = shift;
    my $topic     = shift;
    my @subtopics = @_;
    $o->do_action( $topic, \@subtopics, 'help' );
}

sub summary {
    my $o     = shift;
    my $topic = shift;
    $o->do_action( $topic, [], 'smry' );
}

#=============================================================================
# Manually add & remove handlers
#=============================================================================
sub add_handlers {
    my $o = shift;
    for my $hnd (@_) {
        next unless $hnd =~ /^(run|help|smry|comp|catch|alias)_/o;
        my $t = $1;
        my $a = substr( $hnd, length($t) + 1 );

        # Add on the prefix and suffix if the command is defined
        if ( length $a ) {
            substr( $a, 0, 0 ) = $o->cmd_prefix;
            $a .= $o->cmd_suffix;
        }
        $o->{handlers}{$a}{$t} = $hnd;
        if ( $o->has_aliases($a) ) {
            my @a = $o->get_aliases($a);
            for my $alias (@a) {
                substr( $alias, 0, 0 ) = $o->cmd_prefix;
                $alias .= $o->cmd_suffix;
                $o->{handlers}{$alias}{$t} = $hnd;
            }
        }
    }
}

sub add_commands {
    my $o = shift;
    while (@_) {
        my ( $cmd, $hnd ) = ( shift, shift );
        $o->{handlers}{$cmd} = $hnd;
    }
}

sub remove_handlers {
    my $o = shift;
    for my $hnd (@_) {
        next unless $hnd =~ /^(run|help|smry|comp|catch|alias)_/o;
        my $t = $1;
        my $a = substr( $hnd, length($t) + 1 );

        # Add on the prefix and suffix if the command is defined
        if ( length $a ) {
            substr( $a, 0, 0 ) = $o->cmd_prefix;
            $a .= $o->cmd_suffix;
        }
        delete $o->{handlers}{$a}{$t};
    }
}

sub remove_commands {
    my $o = shift;
    for my $name (@_) {
        delete $o->{handlers}{$name};
    }
}

*add_handler    = \&add_handlers;
*add_command    = \&add_commands;
*remove_handler = \&remove_handlers;
*remove_command = \&remove_commands;

#=============================================================================
# Utility methods
#=============================================================================
sub termsize {
    my $o = shift;
    my ( $rows, $cols ) = ( 24, 78 );

    # Try several ways to get the terminal size
TERMSIZE:
    {
        my $TERM = $o->{term};
        last TERMSIZE unless $TERM;

        my $OUT = $TERM->OUT;

        if ( $TERM and $o->{API}{readline} eq 'Term::ReadLine::Gnu' ) {
            ( $rows, $cols ) = $TERM->get_screen_size;
            last TERMSIZE;
        }

        if ( $^O eq 'MSWin32' and eval { require Win32::Console } ) {
            Win32::Console->import;

          # Win32::Console's DESTROY does a CloseHandle(), so save the object:
            $o->{win32_stdout} ||= Win32::Console->new( STD_OUTPUT_HANDLE() );
            my @info = $o->{win32_stdout}->Info;
            $cols = $info[7] - $info[5] + 1;    # right - left + 1
            $rows = $info[8] - $info[6] + 1;    # bottom - top + 1
            last TERMSIZE;
        }

        if ( eval { require Term::Size } ) {
            my @x = Term::Size::chars($OUT);
            if ( @x == 2 and $x[0] ) {
                ( $cols, $rows ) = @x;
                last TERMSIZE;
            }
        }

        if ( eval { require Term::Screen } ) {
            my $screen = Term::Screen->new;
            ( $rows, $cols ) = @$screen{qw(ROWS COLS)};
            last TERMSIZE;
        }

        if ( eval { require Term::ReadKey } ) {
            ( $cols, $rows ) = eval {
                local $SIG{__WARN__} = sub { };
                Term::ReadKey::GetTerminalSize($OUT);
            };
            last TERMSIZE unless $@;
        }

        if ( $ENV{LINES} or $ENV{ROWS} or $ENV{COLUMNS} ) {
            $rows = $ENV{LINES} || $ENV{ROWS} || $rows;
            $cols = $ENV{COLUMNS} || $cols;
            last TERMSIZE;
        }

        {
            local $^W;
            local *STTY;
            if ( open( STTY, "stty size |" ) ) {
                my $l = <STTY>;
                ( $rows, $cols ) = split /\s+/, $l;
                close STTY;
            }
        }
    }

    return { rows => $rows, cols => $cols };
}

sub readkey {
    my $o = shift;
    $o->have_readkey unless $o->{readkey};
    $o->{readkey}->();
}

sub have_readkey {
    my $o = shift;
    return 1 if $o->{have_readkey};
    my $IN = $o->{term}->IN;
    if ( eval { require Term::InKey } ) {
        $o->{readkey} = \&Term::InKey::ReadKey;
    }
    elsif ( $^O eq 'MSWin32' and eval { require Win32::Console } ) {
        $o->{readkey} = sub {
            my $c;

            # from Term::InKey:
            eval {
                # Win32::Console's DESTROY does a CloseHandle(), so save it:
                Win32::Console->import;
                $o->{win32_stdin}
                    ||= Win32::Console->new( STD_INPUT_HANDLE() );
                my $mode = my $orig = $o->{win32_stdin}->Mode or die $^E;
                $mode &= ~( ENABLE_LINE_INPUT() | ENABLE_ECHO_INPUT() );
                $o->{win32_stdin}->Mode($mode) or die $^E;

                $o->{win32_stdin}->Flush or die $^E;
                $c = $o->{win32_stdin}->InputChar(1);
                die $^E unless defined $c;
                $o->{win32_stdin}->Mode($orig) or die $^E;
            };
            die "Not implemented on $^O: $@" if $@;
            $c;
        };
    }
    elsif ( eval { require Term::ReadKey } ) {
        $o->{readkey} = sub {
            Term::ReadKey::ReadMode( 4, $IN );
            my $c = getc($IN);
            Term::ReadKey::ReadMode( 0, $IN );
            $c;
        };
    }
    else {
        $o->{readkey} = sub { scalar <$IN> };
        return $o->{have_readkey} = 0;
    }
    return $o->{have_readkey} = 1;
}
*has_readkey = \&have_readkey;

sub prompt {
    my $o = shift;
    my ( $prompt, $default, $completions, $casei ) = @_;
    my $term = $o->{term};

    # A closure to read the line.
    my $line;
    my $readline = sub {
        my ( $sh, $gh ) = @{ $term->Features }{qw(setHistory getHistory)};
        my @history = $term->GetHistory if $gh;
        $term->SetHistory() if $sh;
        $line = $o->readline($prompt);
        $line = $default
            if ( ( not defined $line or $line =~ /^\s*$/ )
            and defined $default );

        # Restore the history
        $term->SetHistory(@history) if $sh;
        $line;
    };

    # A closure to complete the line.
    my $complete = sub {
        my ( $word, $line, $start ) = @_;
        return $o->completions( $word, $completions, $casei );
    };

    if ( $term and $term->ReadLine eq 'Term::ReadLine::Gnu' ) {
        my $attribs = $term->Attribs;
        local $attribs->{completion_function} = $complete;
        &$readline;
    }
    elsif ( $term and $term->ReadLine eq 'Term::ReadLine::Perl' ) {
        local $readline::rl_completion_function = $complete;
        &$readline;
    }
    else {
        &$readline;
    }
    print $line;
    $line;
}

sub format_pairs {
    my $o    = shift;
    my @keys = @{ shift(@_) };
    my @vals = @{ shift(@_) };
    my $sep  = shift || ": ";
    my $left = shift || 0;
    my $ind  = shift || "";
    my $len  = shift || 0;
    my $wrap = shift || 0;
    if ($wrap) {
        eval {
            require Text::Autoformat;
            Text::Autoformat->import(qw(autoformat));
        };
        if ($@) {
            warn(
                "isrcore::Shell::format_pairs(): Text::Autoformat is required "
                    . "for wrapping. Wrapping disabled" )
                if $^W;
            $wrap = 0;
        }
    }
    my $cols = shift || $o->termsize->{cols};
    $len < length($_) and $len = length($_) for @keys;
    my @text;
    for my $i ( 0 .. $#keys ) {
        next unless defined $vals[$i];
        my $sz   = ( $len - length( $keys[$i] ) );
        my $lpad = $left ? "" : " " x $sz;
        my $rpad = $left ? " " x $sz : "";
        my $l    = "$ind$lpad$keys[$i]$rpad$sep";
        my $wrap = $wrap & ( $vals[$i] =~ /\s/ and $vals[$i] !~ /^\d/ );
        my $form = (
            $wrap
            ? autoformat(
                "$vals[$i]",    # force stringification
                { left => length($l) + 1, right => $cols, all => 1 },
                )
            : "$l$vals[$i]\n"
        );
        substr( $form, 0, length($l), $l );
        push @text, $form;
    }
    my $text = join '', @text;
    return wantarray ? ( $text, $len ) : $text;
}

sub print_pairs {
    my $o = shift;
    my ( $text, $len ) = $o->format_pairs(@_);
    $o->page($text);
    return $len;
}

# Handle backslash translation; doesn't do anything complicated yet.
sub process_esc {
    my $o = shift;
    my $c = shift;
    my $q = shift;
    my $n;
    return '\\' if $c eq '\\';
    return $q   if $c eq $q;
    return "\\$c";
}

# Parse a quoted string
sub parse_quoted {
    my $o      = shift;
    my $raw    = shift;
    my $quote  = shift;
    my $i      = 1;
    my $string = '';
    my $c;
    while ( $i <= length($raw) and ( $c = substr( $raw, $i, 1 ) ) ne $quote )
    {
        if ( $c eq '\\' ) {
            $string .= $o->process_esc( substr( $raw, $i + 1, 1 ), $quote );
            $i++;
        }
        else {
            $string .= substr( $raw, $i, 1 );
        }
        $i++;
    }
    return ( $string, $i );
}

sub line {
    my $o = shift;
    $o->{line};
}

sub line_args {
    my $o = shift;
    my $line = shift || $o->line;
    $o->line_parsed($line);
    $o->{line_args} || '';
}

sub line_parsed {
    my $o = shift;
    my $args = shift || $o->line || return ();
    my @args;

    # Parse an array of arguments. Whitespace separates, unless quoted.
    my $arg = undef;
    $o->{line_args} = undef;
    for ( my $i = 0; $i < length($args); $i++ ) {
        my $c = substr( $args, $i, 1 );
        if ( $c =~ /\S/ and @args == 1 ) {
            $o->{line_args} ||= substr( $args, $i );
        }
        if ( $c =~ /['"]/ ) {
            my ( $str, $n ) = $o->parse_quoted( substr( $args, $i ), $c );
            $i += $n;
            $arg = ( defined($arg) ? $arg : '' ) . $str;
        }

        # We do not parse outside of strings
        #   elsif ($c eq '\\') {
        #       $arg = (defined($arg) ? $arg : '')
        #         . $o->process_esc(substr($args,$i+1,1));
        #       $i++;
        #   }
        elsif ( $c =~ /\s/ ) {
            push @args, $arg if defined $arg;
            $arg = undef;
        }
        else {
            $arg .= substr( $args, $i, 1 );
        }
    }
    push @args, $arg if defined($arg);
    return @args;
}

sub handler {
    my $o = shift;
    my ( $command, $type, $args, $preserve_args ) = @_;

    # First try finding the standard handler, then fallback to the
    # catch_$type method. The columns represent "action", "type", and "push",
    # which control whether the name of the command should be pushed onto the
    # args.
    my @tries = (
        [ $command,                                $type,   0 ],
        [ $o->cmd_prefix . $type . $o->cmd_suffix, 'catch', 1 ],
    );

    # The user can control whether or not to search for "unique" matches,
    # which means calling $o->possible_actions(). We always look for exact
    # matches.
    my @matches = qw(exact_action);
    push @matches, qw(possible_actions) if $o->{API}{match_uniq};

    for my $try (@tries) {
        my ( $cmd, $type, $add_cmd_name ) = @$try;
        for my $match (@matches) {
            my @handlers = $o->$match( $cmd, $type );
            next unless @handlers == 1;
            unshift @$args, $command
                if $add_cmd_name and not $preserve_args;
            return $o->unalias( $handlers[0], $type );
        }
    }
    return undef;
}

sub completions {
    my $o      = shift;
    my $action = shift;
    my $compls = shift || [];
    my $casei  = shift;
    $casei = $o->{API}{case_ignore} unless defined $casei;
    $casei = $casei ? '(?i)' : '';
    return grep { $_ =~ /$casei^\Q$action\E/ } @$compls;
}

#=============================================================================
# isrcore::Shell error messages
#=============================================================================
sub msg_ambiguous_cmd {
    my ( $o, $cmd, @c ) = @_;
    local $" = "\n\t";
    <<END;
Ambiguous command '$cmd': possible commands:
    @c
END
}

sub msg_unknown_cmd {
    my ( $o, $cmd ) = @_;
    <<END;
Unknown command '$cmd'; type 'help' for a list of commands.
END
}

#=============================================================================
# isrcore::Shell private methods
#=============================================================================
sub do_action {
    my $o    = shift;
    my $cmd  = shift;
    my $args = shift || [];
    my $type = shift || 'run';
    my ( $fullname, $cmdname, $handler ) = $o->handler( $cmd, $type, $args );
    $o->{command}{$type} = {
        cmd  => $cmd,
        name => $cmd,
        found => defined $handler ? 1 : 0,
        cmdfull => $fullname,
        cmdreal => $cmdname,
        handler => $handler,
    };
    if ( defined $handler ) {

        # We've found a handler. Set up a value which will call the postcmd()
        # action as the subroutine leaves. Then call the precmd(), then return
        # the result of running the handler.
        $o->precmd( \$handler, \$cmd, $args );
        my $postcmd = isrcore::Shell::OnScopeLeave->new(
            sub {
                $o->postcmd( \$handler, \$cmd, $args );
            }
        );
        return $o->$handler(@$args);
    }
}

sub uniq {
    my $o = shift;
    my %seen;
    $seen{$_}++ for @_;
    my @ret;
    for (@_) { push @ret, $_ if $seen{$_}-- == 1 }
    @ret;
}

sub possible_actions {
    my $o      = shift;
    my $action = shift;
    my $type   = shift;
    my $casei  = $o->{API}{case_ignore} ? '(?i)' : '';
    my @keys   = grep { $_ =~ /$casei^\Q$action\E/ }
        grep { exists $o->{handlers}{$_}{$type} }
        keys %{ $o->{handlers} };
    return @keys;
}

sub exact_action {
    my $o      = shift;
    my $action = shift;
    my $type   = shift;
    my $casei  = $o->{API}{case_ignore} ? '(?i)' : '';
    my @key    = grep { $action =~ /$casei^\Q$_\E$/ }
        grep { exists $o->{handlers}{$_}{$type} }
        keys %{ $o->{handlers} };
    return () unless @key == 1;
    return $key[0];
}

sub is_alias {
    my $o      = shift;
    my $action = shift;
    exists $o->{handlers}{$action}{alias} ? 1 : 0;
}

sub has_aliases {
    my $o      = shift;
    my $action = shift;
    my @a      = $o->get_aliases($action);
    @a ? 1 : 0;
}

sub get_aliases {
    my $o      = shift;
    my $action = shift;
    my @a      = eval {
        my $hndlr = $o->{handlers}{$action}{alias};
        return () unless $hndlr;
        $o->$hndlr();
    };
    $o->{aliases}{$_} = $action for @a;
    @a;
}

sub unalias {
    my $o    = shift;
    my $cmd  = shift;    # i.e 'foozle'
    my $type = shift;    # i.e 'run'
    return () unless $type;
    return ( $cmd, $cmd, $o->{handlers}{$cmd}{$type} )
        unless exists $o->{aliases}{$cmd};
    my $alias = $o->{aliases}{$cmd};

    # I'm allowing aliases to call handlers which have been removed. This
    # means I can set up an alias of '!' for 'shell', then delete the 'shell'
    # command, so that you can only access it through '!'. That's why I'm
    # checking the {handlers} entry _and_ building a string.
    my $handler = $o->{handlers}{$alias}{$type} || "${type}_${alias}";
    return ( $cmd, $alias, $handler );
}

sub find_handlers {
    my $o = shift;
    my $pkg = shift || $o->{API}{class};

    # Find the handlers in the given namespace:
    my %handlers;
    {
        no strict 'refs';
        my @r = keys %{ $pkg . "::" };
        $o->add_handlers(@r);
    }

    # Find handlers in its base classes.
    {
        no strict 'refs';
        my @isa = @{ $pkg . "::ISA" };
        for my $pkg (@isa) {
            $o->find_handlers($pkg);
        }
    }
}

sub rl_complete {
    my $o = shift;
    my ( $word, $line, $start ) = @_;

    # If it's a command, complete 'run_':
    if ( $start == 0 or substr( $line, 0, $start ) =~ /^\s*$/ ) {
        my @compls = $o->complete( '', $word, $line, $start );
        return @compls if $o->{command}{comp}{found};
    }

    # If it's a subcommand, send it to any custom completion function for the
    # function:
    else {
        my $command = ( $o->line_parsed($line) )[0];
        my @compls = $o->complete( $command, $word, $line, $start );
        return @compls if $o->{command}{comp}{found};
    }

    ();
}

#=============================================================================
# Two action handlers provided by default: help and exit.
#=============================================================================
sub smry_exit {"exits the program"}

sub help_exit {
    <<'END';
Exits the program.
END
}

sub run_exit {
    my $o = shift;
    $o->stoploop;
}

sub smry_help {"prints this screen, or help on 'command'"}

sub help_help {
    <<'END'
Provides help on commands...
END
}

sub comp_help {
    my ( $o, $word, $line, $start ) = @_;
    my @words = $o->line_parsed($line);

    return
        if ( @words > 2 or @words == 2 and $start == length($line) );
    sort $o->possible_actions( $word, 'help' );
}

sub run_help {
    my $o   = shift;
    my $cmd = shift;
    if ($cmd) {
        my $txt = $o->help( $cmd, @_ );
        if ( $o->{command}{help}{found} ) {
            $o->page($txt);
        }
        else {
            my @c = sort $o->possible_actions( $cmd, 'help' );
            if ( @c and $o->{API}{match_uniq} ) {
                local $" = "\n\t";
                print <<END;
Ambiguous help topic '$cmd': possible help topics:
    @c
END
            }
            else {
                print <<END;
Unknown help topic '$cmd'; type 'help' for a list of help topics.
END
            }
        }
    }
    else {
        print "Type 'help command' for more detailed help on a command.\n";
        my ( %cmds, %docs );
        my %done;
        my %handlers;
        for my $h ( keys %{ $o->{handlers} } ) {
            next unless length($h);
            next
                unless grep { defined $o->{handlers}{$h}{$_} }
                qw(run smry help);
            my $dest = exists $o->{handlers}{$h}{run} ? \%cmds : \%docs;
            my $smry
                = do { my $x = $o->summary($h); $x ? $x : "undocumented" };
            my $help
                = exists $o->{handlers}{$h}{help}
                ? (
                exists $o->{handlers}{$h}{smry}
                ? ""
                : " - but help available"
                )
                : " - no help available";
            $dest->{"    $h"} = "$smry$help";
        }
        my @t;
        push @t, "  Commands:\n" if %cmds;
        push @t,
            scalar $o->format_pairs(
            [ sort keys %cmds ],
            [ map { $cmds{$_} } sort keys %cmds ],
            ' - ', 1
            );
        push @t, "  Extra Help Topics: (not commands)\n" if %docs;
        push @t,
            scalar $o->format_pairs(
            [ sort keys %docs ],
            [ map { $docs{$_} } sort keys %docs ],
            ' - ', 1
            );
        $o->page( join '', @t );
    }
}

sub run_ { }

sub comp_ {
    my ( $o, $word, $line, $start ) = @_;
    my @comp = grep { length($_) } sort $o->possible_actions( $word, 'run' );
    return @comp;
}

package isrcore::Shell::OnScopeLeave;

sub new {
    return bless [ @_[ 1 .. $#_ ] ], ref( $_[0] ) || $_[0];
}

sub DESTROY {
    my $o = shift;
    for my $c (@$o) {
        &$c;
    }
}

1;
