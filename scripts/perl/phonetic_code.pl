#!/usr/bin/perl

use strict;

=head1 DEV 

76545 => not_found
but
76 => Gush
545 => Laurel

so we should not only search $int for *k*j and *k*ch and *g*sh*
but also split it into its component integers and search for
the smallest number of word(s) that do cover $int, (even if that
is a phrase, or a book). 

=head1 BUG

nephew should be 28 but upholster, Haphazard and flophouse should not
(need something like Lingua::EN or Text::Phonetic::English)

=cut

my $verb=0; # if you want _all_ words for a given string then =1
my %enc = (
0 => ['s','z'],
1 => ['t','d'],
2 => ['n'],
3 => ['m'],
4 => ['r'],
5 => ['l'],
6 => ['j','sh','ch'],
7 => ['k','g'],
8 => ['f','v','ph'],
9 => ['p','b'],
);
my $vowels = '[aeiouy]*';
my $unused = '[hvw]*'; # these could also be used for padding or some other purpose

sub help {
    print "$0 encodes and decodes a phonetic code; between a word and a number\n";
    exit;
}

sub decode {
   # Common leet
   my $string = shift;
    &help unless $string;
   print "$string => ";
   $string =~s/(sh|ch)/6/ig;
   $string =~s/(ph)/8/ig;
   my @letters = split "", lc($string); # does not match 'sh', 'ch'
   LETTER: foreach my $l (@letters){
        if ($l == 6 || $l == 8){ 
            print $l;
            next LETTER;
        }
        foreach my $k (keys %enc){
            foreach my $r (@ { $enc{$k}}){
                print $k if $l eq $r;
            }
        }
    }
    print "\n";
}

sub encode {
    my $int = shift;
    my @digits = split "", $int;
    my $match = '^' . $vowels;
    my @letters;
    foreach my $d (@digits){
        my $rnd = int(rand( @{ $enc{$d} }));
        push @letters, $enc{$d}[$rnd];
        # for now we just pick a random letter
        # but later we will create all possible letter combinations
     }
     $match .= join "$vowels", @letters;
     $match .= "$vowels\$";
    return $match;
}

# not sure that String::Nysiis; helps us
# but Text::MultiPhone  might give us some clues
# as could Text::Phonetic::VideoGame  and DBIx::Class::PhoneticSearch 
sub nysiis
{
  my($string) = @_;
  $string =~ s/PH/F/g;
  return $string;
}

if($ARGV[0]=~m/^(\d+)$/){
    my $words = "/usr/share/dict/words";
    my $match = encode($ARGV[0]);
    print "Searching $words for $match\n";
    my @words = `grep -iE "$match" $words`;
    foreach my $wc (@words){
        my $cw = nysiis($wc);
        if($cw ne $wc){
            print "$cw ne $wc\n";
        }   
    }
            
    if(@words){

        printf "$ARGV[0] phonetically is => %s", ucfirst($_),
            for @words;
    }else{
        #$match=~s/\[$vowels\]\*//g;
        $match=~s/$vowels//g;
        $match=~s/\W//g;
        printf "$ARGV[0] phonetically are => %s\n", ucfirst($match);
    }
}else{
    decode($ARGV[0]);
}

__END__
