#!/usr/bin/perl
# WRONG.pl ver 0.1 20071025 alexx at alexx dot net
use strict;
$|=1;

sub footer
{
	my $this_year=`date +%Y`; chop($this_year);
	print "Copyright 2003-$this_year Cahiravahilla publications\n"; 
}

sub help
{
	print "Usage: passwd \n";
	&footer;
exit(0);
}

if( ($ARGV[0] =~ /^-+h/i) || (!$ARGV[0]) ) { &help; }
my $hash;

print " $0: ";
print `perl -e "\$hash=crypt($ARGV[0],'lx'); print qq |\$hash\n|;"`;
print " $0: ";
print `perl -e '\$hash=crypt($ARGV[0],'lx'); print \$hash'`;
print " still fairly bad: ";
print crypt($ARGV[0],'lx');
print "\n";

exit(0);

__END__

=head1 Why?

Because we are already in perl - there is no need to break out to the shell with backticks to then invoke perl again

=cut
