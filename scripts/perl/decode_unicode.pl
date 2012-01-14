#!/usr/bin/env perl

use strict;

=head1 NAME

decode_unicode.pl - Some examples of dealing with unicode

=head1 VERSION

0.01 - 20120114

=cut

our $VERSION = 0.01;

=head1 ABSTRACT

While dealing with i18n I needed to be able to search unicode with UTF-8

=head1 DESCRIPTION

See ABSTRACT

=head1 OPTIONS

%opt stores the global variables
$opt{D} is the debug level

=cut

use utf8;
use Text::Unidecode;
my %opt=(D=>0); #It is nice to have options;

=head2 ARGS

=over 8

=item B<> String 

=back

=head3 other arguments and flags that are valid

-d increment debug level

-s enable the slowness (this is an example of what NOT to do... unless you have to)

=cut

unless ($ARGV[0]){
  print "\x{5317}\x{4EB0} is " . unidecode(
    "\x{5317}\x{4EB0}\n"
     # those are the Chinese characters for Beijing
  );
  # That prints: Bei Jing 

 while(<DATA>){ #see the end of this file
    print unidecode( $_ );
 }

}

=head1 Example Data

Some eample data in both PERLQQ "\x{5317}\x{4EB0}"
and UTF-8 Céline
Note that baz is in two {dec} to show that, (unless you sort) you can't be sure which hash-key will come first.

=cut

my %list = (
"\x{5317}\x{4EB0}" => { location => 'China', noun => 'it is in', dec => ['Bei Jing', 'beijing', 'peking'] },
"中国" => { location => 'China', noun => 'it is', dec => ['China', 'Our Land', 'Zhong Guo'] },
"Céline" => { location => 'France', noun => 'she is in', dec => ['celine', 'Celine', 'CA~Xline', 'C(O)eline'] },
"examples" => { location => 'Internet', noun => 'they are in the', dec => ['foo', 'bar', 'baz', 'foobar'] },
"2polaapc" => { location => 'television', noun => 'they are on', dec => ['baz', 'gaz', 'jonny', 'barry', 'donna', 'janet', 'louise', 'alison'] },
);


for(my $args=0;$args<=(@ARGV -1);$args++){
      print "Here we have $ARGV[$args]" if $opt{D}>=10;
      if ($ARGV[$args] eq '-d'){ $opt{D}++; delete($ARGV[$args]);}
      elsif (-f $ARGV[$args]){ $opt{FILE}= $ARGV[$args], delete($ARGV[$args]);}
      elsif ($ARGV[$args] eq '-s'){ $opt{slow}++; delete($ARGV[$args]);}
      print " and now it is $ARGV[$args]\n" if $opt{D}>=10;
}

if(-f $opt{FILE}){
    my(@lines);
    open(FILE,"$opt{FILE}");
    while(my $line = <FILE>){ 
        push @lines, $line; 
        chomp($line);
        print "$line is " . unidecode($line) . "\n";
    }
    close(FILE);

}elsif(@ARGV >=1){

    # Obviously we don't want to search through all of the $list{$key}{dec}[]
    # though that might be a last resort for odd name changes like Peking -> Beijing

    my (@search);

    use Encode qw(decode encode PERLQQ XMLCREF);
    use Encode::Detect::Detector;

    my $s;
    print "You are looking for " if $opt{D}>=1;
    for(my $args=0;$args<=(@ARGV);$args++){
      if($ARGV[$args] ne ''){
        if(Encode::Detect::Detector::detect($ARGV[$args]) eq 'UTF-8'){
            print "$ARGV[$args] (in UTF-8)\n" if $opt{D}>=1;
        }else{
            my $detect = Encode::Detect::Detector::detect($ARGV[$args]);
            if($detect ne ''){
                print "(is that encoded $detect?)";
                print decode($detect, $ARGV[$args]) . "\n";
            }
        }
        $s = decode( 'utf8', $ARGV[$args] );
        $s = unidecode( "$s" );
        # use an array as there may be more than one way to decode (e.g. Taoism Daoism)
        push @search, $s;
      }
    }
    if($opt{slow}){
        push @search, "@search";
    }
        print "\"@search\" \n" if $opt{D}>=1;

    foreach my $key (keys %list){
        my $k = unidecode($key);
        foreach my $lock (@search){
            if ("$key" eq "$lock" || "$k" eq "$lock" || lc($lock) eq lc($k)){
                
                $k=~s/\s$//g;
                print "You are looking for $k and I think that $list{$key}{'noun'} " . 
                    $list{$key}{'location'} . "\n";
                exit;
            }
        }

    }
    if($opt{slow}){
        LIST: foreach my $key (keys %list){
            DEC: foreach my $dec (@{ $list{$key}{dec} }){
               SEARCH: foreach my $lock (@search){
                    my $lcl = lc($lock);
                    my $lcd = lc($dec);
                    my $cl = $lcl; $cl=~s/\s//g;
                    my $cd = $lcd; $cd=~s/\s//g;
                    if ("$dec" eq "$lock" || $lcd eq $lcl || $cl eq $cd){
                        if ("$dec" eq "$lock"){
                            print qq |Match was i. "$dec" eq "$lock"\n| if $opt{D}>=4;
                        }elsif($lcd eq $lcl){
                            print qq |Match was ii. $lcd eq $lcl\n| if $opt{D}>=4;
                        }elsif($cl eq $cd){
                            print qq |Match was iii. $cl eq $cd\n| if $opt{D}>=4;
                        }
                            
                        my $l = $lock; $l=~s/\s$//g;
                        if($opt{and}){
                            print "$opt{and} ";
                        } else{
                            print "You are looking for $search[@search -1] and I think that ";
                        }
                            print "$list{$key}{'noun'} " .
                            $list{$key}{'location'} . "\n";
                        exit unless $opt{D}>=2;
                        $opt{and} = 'and';
                        next DEC;
                    }
                }
            }
        } 
    }
    else
    {
        print "I can not locate @search\n";
    }

}

=head1 BUGS AND LIMITATIONS

There are no known problems with this script.

Please report any bugs or feature requests

=head1 SEE ALSO

#L<https://github.com/alexxroche/AIF/>

=head1 MAINTAINER

is the AUTHOR

=head1 AUTHOR

Alexx Roche, C<alexx at cpan dot org>

=head1 LICENSE AND COPYRIGHT

Copyright 2011-2012 Alexx Roche, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of either: Eclipse Public License, Version 1.0 ; 
 the GNU Lesser General Public License as published 
by the Free Software Foundation; or the Artistic License.

See http://www.opensource.org/licenses/ for more information.

=cut

__DATA__

# Because `echo "Céline"|./decode_unicode.pl`; might be munged by the shell
# we can use this data at the end of this script for testing, 
# (notice how the first one does not work in this format)

\x{5317}\x{4EB0}
中国
Céline
