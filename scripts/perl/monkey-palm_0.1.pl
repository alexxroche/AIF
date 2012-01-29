#!/usr/bin/perl

=head1 name

palm.pl

=head1 SYNOPSIS

A simple cgi daemon for monkey HTTPd (http://monkey-project.com)

=head1 DESCRIPTION

This binds to a port and waits for a monkey to swing by for a high-five

If a monkey swings into this palm's port, the tree will run the code
(after some secutiry checks) and return the html output)

=head1 CONFIG

data that you can change these are just defaults for stand-alone-ish. 
The real strings should be pulled from the database.

=head1 Palm

This is the code that creates the daemon

=cut

package Palm;
use strict;
use base qw(Net::Server);
my $DEBUG=0;

=pod example request

DOCUMENT_ROOT=/home/alexx/monkey-0.20.2/htdocs
SERVER_PORT=2001
SERVER_NAME=127.0.0.1
SERVER_PROTOCOL=HTTP/1.1
SERVER_SIGNATURE=Monkey/0.20.2
HTTP_HOST=127.0.0.1:2001
HTTP_USER_AGENT=Mozilla/5.0 (X11; U; Linux i686; en-gb) AppleWebKit/531.2+ (KHTML, like Gecko) Version/5.0 Safari/531.2+
HTTP_ACCEPT=application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
HTTP_ACCEPT_ENCODING=identity
REMOTE_ADDR=127.0.0.1
REMOTE_PORT=24023
GATEWAY_INTERFACE=CGI/1.1
REQUEST_URI=/sites/www.alexx.net/www/collection/wetch_viewer.pl?day=17&debug=yes
REQUEST_METHOD=GET
SCRIPT_NAME=/sites/www.alexx.net/www/collection/wetch_viewer.pl
SCRIPT_FILENAME=/home/alexx/monkey-0.20.2/htdocs/sites/www.alexx.net/www/collection/wetch_viewer.pl
QUERY_STRING=day=17&debug=yes

# so we need to spool all of these and when we have them set $ENV{$key} = $value and call $SCRIPT_NAME

=cut

$|=1;
my $doc_root = '/var/www';
my $drhc = 0; #Document root hard code (prevent dynamic one from monkey)
my $type ='';
my $log_file = '/var/log/palm.log';

# We should be able to bind to more ports as dynamically type based of script name
my $port = 2011; $type='perl';
#my $port = 2010; $type='php';
#my $port = 2012; $type='python';
#my $port = 2013; $type='ruby';
#my $port = 2014; $type='erlang';
#my $port = 2015; $type='lisp';
#my $port = 2016; $type='bash';
# TODO
#my $port = 2020; $type='all'; # a proper daemon written in c

use Time::HiRes qw( time );

my $start = time;
my $daemon = Palm->new({
    #user	=> 'nobody', group	=> 'nogroup',
    #user	=> 'www-data', group	=> 'www-data',
    user	=> 'root', group	=> 'root',
	proto	=> 'tcp',
	port	=> $port,
	background=>0,
	log_file=> $log_file,
	#log_file=> '/var/log/whois.log',
});

$daemon->run;

sub process_request {
    my $self = shift;
    my $go = time;
    my $REMOTE_ADDR = '';
    eval {
        local $SIG{'ALRM'} = sub { die "Timed Out!\n" };
        my $timeout = 3; # give the user 30 seconds to type some lines
        my $previous_alarm = alarm($timeout);
        LINE: while (my $query = <STDIN>) {
            last if $query =~ /^\s$/;
            chomp $query;
            if($query=~m/^HTTP_HOST=(.*)/){ 
                $ENV{HTTP_HOST} = $1;
            }elsif($query=~m/^REMOTE_ADDR=(.*)/){ 
                $REMOTE_ADDR = $1; chomp($REMOTE_ADDR);
                $ENV{REMOTE_ADDR} = $REMOTE_ADDR;
            }
            elsif($query=~m/^DOCUMENT_ROOT=(.*)/){ 
                next LINE if $drhc;
                $doc_root = $1;
                $ENV{DOCUMENT_ROOT} = $doc_root;
            }
            elsif($query=~m/REQUEST_URI=([^\?]*)\??(.*)?/){
                my $SCRIPT_NAME = $1;
                my $CGI = $2;
                chomp($SCRIPT_NAME);
                chomp($CGI);
                $ENV{SCRIPT_NAME} = $SCRIPT_NAME;
                $ENV{REQUEST_URI} = $SCRIPT_NAME . '?' . $CGI;
                my @cgi_args = ('# none');
                if(defined $CGI){ 
                       @cgi_args = split(/\&/, $CGI); 
                }else{
                       my $c_args = $query;
                       $c_args =~s/^$SCRIPT_NAME//;
                       @cgi_args = split(/\&/, $c_args); 
                }
                warn "Looking for ${doc_root}$SCRIPT_NAME\n" if $DEBUG>=5;;
                my $script = "${doc_root}";
                chomp($script);
                $script=~s/\s*\r?\n?$//g; #this caught me out for a while
                warn $script if $DEBUG>=4;
                $script .= "$SCRIPT_NAME";
                $script=~s/\s*\r?\n?$//g;
                # The tests should probably be in a better order (and more of them)
                my $this_type = `file -b $script`;
                unless($this_type=~m/$type/){
                    print STDERR "Invalid script type: $script is not written in $type\n";
                    print "Content-Type: text/plain \r\n\r\n";
                    print "Invalid script type: script is not a $type script\r\n";
                    last;
                } 
                #if(-f "${doc_root}$SCRIPT_NAME" && -e "${doc_root}$SCRIPT_NAME"){
                if(-f "$script"){
=pod
                    # not needed, but if your scripts do...
                    my $path = $script;
                    $path = `dirname $path`;
                    chomp($path);
                    if(-d $path){ 
                        warn "warn: moving to $path\n" if $DEBUG>=11;
                        print STDERR "STDERR: moving to $path\n" if $DEBUG>=12;
                        `cd $path`; 
                    }
                    print STDERR "Running ${doc_root}$SCRIPT_NAME @cgi_args\n" if $DEBUG>=8;
                    my $this_cgi = `basename $script`;
=cut
                    my $return = `$script @cgi_args`;
                    warn "Just run ${doc_root}$SCRIPT_NAME\n" if $DEBUG>=40;
                    print STDERR $return . "\n" if $DEBUG>=99;
                    $return =~s/\n\n/\r\n\r\n/; # why monkey? why?
                    print $return . "\r\n\r\n";
                    my $fin = time;
                    my $slow = $fin - $go;  
                    unless(defined $REMOTE_ADDR){ $REMOTE_ADDR = $ENV{REMOTE_ADDR}; }
                    chomp($REMOTE_ADDR);
                    $REMOTE_ADDR=~s/\s*\r?\n?$//g;
                    print STDERR "$REMOTE_ADDR ran $script " . length($return) . " bytes in $slow seconds\n";
                    last;
                }else{
                    warn ("doc_root = $doc_root (not found)");
                    warn "script = $script not found";
                    print STDERR "File not found ${doc_root}$SCRIPT_NAME\n";
                    print "Content-Type: text/plain \r\n\r\n";
                    print "Not Found \r\n";
                    last;
                }         
            }else{
                print STDERR "ERR: $query\n" if $DEBUG>=10;
                next LINE;
            }
            alarm($timeout);
        }
        alarm($previous_alarm);
    	if ($@=~m/timed out/i) { print STDERR "DIED Out.\n"; print STDERR "We have zero bananas today\n"; return; }
    };
    if ($@=~m/timed out/i) { print STDERR "Timed Out.\n"; print STDERR "We have no bananas today\n"; return; }
    elsif ($@) { print STDERR "NB: $@.\n"; return; }
    else{ print STDERR "end of process\n" if $DEBUG>=2; }
}
print STDERR "GOT HERE.. which is the end\n";
1;

__END__

=head1 BUGS AND LIMITATIONS

Probably, and certainly better ways to do the same thing

=head1 SEE ALSO

L<Notice>
L<monkey-project.com>

ps auwxf|grep pal[m]|grep -v vi|awk '{print $2}'|xargs kill
root@bella:/var/www/sites/github/Notice/script# ./palm.pl & tail -f /var/log/palm.log 

=head1 AUTHOR

Alexx Roche, C<notice-dev@alexx.net>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2012 Alexx Roche

This program is free software; you can redistribute it and/or modify it
under the following license: The GNU Lesser General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://www.opensource.org/licenses/ for more information.

=cut

