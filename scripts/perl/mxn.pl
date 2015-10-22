#!/usr/bin/env perl

=head1 

Matrix rotation

These are some less efficient ways to rotate an M x N 2d matrix

using an array of arrays

=cut

use strict;
use Data::Dumper;

my @a = (
         [1,2,3], 
         [4,5,6], 
         [7,8,9] 
    );
my $m = \@a;
   my $n = [
         [1,2,3,4,5], 
         [6,7,8,9,0], 
         ['a','b','c','d','e'] 
    ];
my $r = [
         [1,2], 
         [3,4], 
         [5,6], 
    ];

my $h = ( $#{$m} +1 );
my $w = ( $#{$m->[0]} +1 );
my $s = $h * $w;

sub show {
    my @m = shift;
    my $max = $h>$w? $h:$w;
    for ( my  $i=0; $i < ( $#{$m} +1 ); $i++ ){
      for ( my $j=0; $j < ( $#{$m->[0]} +1 ); $j++ ){
            print "$m->[$i][$j] ";
        }
        print "\n";
    }
}

sub turnR {
    my @m = shift;
    my @turned;
    my $max = $h>$w? $h:$w;

    for ( my  $i=0; $i < $max; $i++ ){
      for ( my $j=0; $j < $max; $j++ ){
        my $off = $w - $i;
        $turned[$j][$off] = $m->[$i][$j];
      }
    }

    # strip all of the undef from the left (chomp_left(@matrix) )
    foreach my $row (@turned){
      @{ $row } = grep defined, @{ $row };
    }


    # splice out the empty arrays from the end (chomp_bottom(@matrix) )
    for ( my $index = $#turned; $index >= 0; --$index )
    {
        my $s = $turned[$index];
        splice @turned, $index, 1
        unless @{ $s };
    }
    #print Dumper(\@turned);
    $m = \@turned;
}

if ( $ARGV[0] eq '-t'){
    &show($m);
    print "Start: " . `date +%c` . "\n";
    for(my $loop=0;$loop<=1000000;$loop++){
        &turnR($m);
        #print ".";
    }
    print "End: ". `date +%c` . "\n";
    &show($m);

=pre

1 2 3 
4 5 6 
7 8 9 
Start: Thu 22 Oct 2015 00:12:33 CEST

End: 
7 4 1 
8 5 2 
9 6 3 

real    0m38.260s
user    0m38.078s
sys     0m0.080s

=cut

}else{

    print "Before: ";
    print "the width is: " .  ( $#{ $m->[0] } +1 ) . " and the hight is " .  ( $#{$m} +1 ) . "\n";
    &show($m);
    &turnR($m);
    print "After: ";
    print "the width is: " . ( $#{$m->[0]} +1 ) . " and the hight is " . ( $#{$m} +1 ) . "\n";
    &show($m);
    #print Dumper($m->[0]);
}










