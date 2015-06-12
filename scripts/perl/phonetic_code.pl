#!/usr/bin/perl

use strict;

=head1 DEV 

Based upon Major Beniowski System

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
7 => ['k','g','c'],
8 => ['f','v','ph'],
9 => ['p','b'],
);
my $vowels = '[aeiouy]*';
my $unused = '[hvw]*'; # these could also be used for padding or some other purpose

sub help {
    print "$0 encodes and decodes a phonetic code; between a word and a number\n";
    foreach my $d (sort keys %enc){
        print "$d => $enc{$d}->[0], ";
    } print "\n";
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
    print "grep -iE $match $words\n";
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

=head1 About


THE PHONETIC CODE
Each digit between 0 and 9 is assigned a consonant sound.

Learn the code; practice turning numbers into words and back again.

1 is the t or d sound.  (1 A typewritten t or d has just 1 downstroke.)
2 is the n sound. ( 2 A typewritten n has 2 downstrokes. )
3 is the m sound. ( 3 A typewritten m has 3 downstrokes. )
4 is the r sound. ( 4 The number 4 ends in the letter r. )
5 is the l sound. ( 5 Shape your hand with 4 fingers up and the thumb at 
                     a 90-degree angle—that’s 5 fingers in an L shape. )
6 is the j, ch, or sh sound. ( 6 A J looks sort of like a backward 6. )
7 is the k or hard g sound. ( 7 A K can be drawn by laying two 7s back to back. )
8 is the f or v sound. ( 8 A lowercase f written in cursive looks like an 8. )
9 is the p or b sound. ( 9 The number 9 looks like a backward p or an upside-down b. )
0 is the z or s sound. ( 0 The word zero begins with the letter z. )

unused: ahiouvwy

Possible examples:

1 tie 2 knee 3 emu 4 ear 5 law 6 show 7 cow 8 ivy 9 bee 10 dice 
11 tot 12 tin 13 tomb 14 tire 15 towel 16 dish 17 duck 18 dove 19 tub 
20 nose 21 nut 22 nun 23 name 24 Nero 25 nail 26 notch 27 neck 28 knife 29 knob
30 mouse 31 mat 32 moon 33 mummy 34 mower 35 mule 36 match 37 mug 38 movie 39 map
40 rose 41 rod 42 rain 43 ram 44 rear 45 roll 46 roach 47 rock 48 roof 49 rope
50 lace 51 light 52 lion 53 lamb 54 lure 55 lily 56 leash 57 log 58 leaf 59 lip
60 cheese 61 sheet 62 chain 63 chum 64 cherry 65 jail 66 judge 67 chalk 68 chef 69 ship
70 kiss 71 kite 72 coin 73 comb 74 car 75 coal 76 cage 77 cake 78 cave 79 cap
80 face 81 fight 82 phone 83 foam 84 fire 85 file 86 fish 87 fog 88 fife 89 V.I.P. 
90 bus 91 bat 92 bun 93 bomb 94 bear 95 bell 96 beach 97 book 98 puff 99 puppy 100 daisies

Although a number can usually be converted into many
words, a word can be translated only into a single number.
This is the key to the code. Try turing people's names into numbers and then into new words.
