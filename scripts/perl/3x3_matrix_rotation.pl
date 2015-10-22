#!/usr/bin/env perl

=head1 Description 

Matrix rotation

These are some less efficient ways to rotate an M x N 2d matrix

using an array of arrays


=head1 usage

 -t (to turn in all 8 orientations
 -test to test the speed of turning (for comparison with the general code in mxn.pl
 -h just perldoc this file

=cut

use strict;
use Data::Dumper;

my @a = (
         [1,2,3], 
         [4,5,6], 
         [7,8,9] 
    );
my $m = \@a;

my $h = 3;
my $w = 3;
my $s = 9;

=head2 show

Display the current matrix

=cut

sub show {
    my @m = shift;
    for ( my  $i=0; $i < $h; $i++ ){
      for ( my $j=0; $j < $w; $j++ ){
            print "$m->[$i][$j] ";
        }
        print "\n";
    }
}

=head2 transpose

This reflects the matrix along the top-left..bottom-right diagonal;
this lets us see, (with rotation) all 8 rotations and reflections.

Now we need a way to eliminate them all for [1,1,1,1,0,1,1,1,1]
where some (or in this case all) rotations and reflections are duplicates.

=cut

sub transpose {
    my $m = shift;
    my $tmp = $m->[0][1];
    $m->[0][1] = $m->[1][0];
    $m->[1][0] = $tmp;
    $tmp = $m->[0][2];
    $m->[0][2] = $m->[2][0];
    $m->[2][0] = $tmp;
    $tmp = $m->[1][2];
    $m->[1][2] = $m->[2][1];
    $m->[2][1] = $tmp;

}

=head2 turnR

The manual turning of a 3x3 matrix 90 degrees clockwise

=cut

sub turnR {
    my $m = shift;
    # move the corners;
    #print Dumper($m);
    my $tmp = $m->[0][0];
    $m->[0][0] = $m->[2][0];
    $m->[2][0] = $m->[2][2];
    $m->[2][2] = $m->[0][2];
    $m->[0][2] = $tmp;
    # move edges
    $tmp = $m->[0][1];
    $m->[0][1] = $m->[1][0];
    $m->[1][0] = $m->[2][1];
    $m->[2][1] = $m->[1][2];
    $m->[1][2] = $tmp;
    #print Dumper($m);
}

if ( $ARGV[0] eq '-test'){
    &show($m);
    print "Start: " . `date +%c` . "\n";
    for(my $loop=0;$loop<=1000000;$loop++){
        &turnR($m);
        #print ".";
    }
    print "End: ". `date+%c` . "\n";
    &show($m);

=pod

1 2 3 
4 5 6 
7 8 9 
Start: Thu 22 Oct 2015 00:09:14 CEST

End: 
7 4 1 
8 5 2 
9 6 3 

real    0m8.217s ( the general code took:  0m38.260s [more then 4.5 times as long]
user    0m8.189s
sys     0m0.012s

 0m38.260s

=cut

}elsif ( $ARGV[0] eq '-t'){
&show($m);
print "\n";
&turnR($m);
&show($m);
print "\n";
&turnR($m);
&show($m);
print "\n";
&turnR($m);
&show($m);
print "\n";
&transpose($m);
&show($m);
print "\n";
&turnR($m);
&show($m);
print "\n";
&turnR($m);
&show($m);
print "\n";
&turnR($m);
&show($m);
print "\n";

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

=head3 About

Author: Alexx Roche
Created: about 20151020
Licence: MIT

=cut
