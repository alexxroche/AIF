#!/usr/bin/env perl

# Nothing to do with a two way hash-function! 
# (because hash-functions are ONE WAY!)

use Tie::Hash::TwoWay;
use Data::Dumper;
  tie %hash, 'Tie::Hash::TwoWay';

  my %list = (
              Asimov => ['novelist', 'scientist'],
              King => ['novelist', 'horror'],
             );


  foreach (keys %list)                  # these are the primary keys of the hash
  {
   $hash{$_} = $list{$_};
  }

  $hash{White} = 'novelist';
  $hash{White} = 'color';

  # these will all print 'yes'
  print 'yes' if exists $hash{scientist};
  print 'yes' if exists $hash{novelist}->{Asimov};
  print 'yes' if exists $hash{novelist}->{King};
  print 'yes' if exists $hash{novelist}->{White};
  print 'yes' if exists $hash{King}->{novelist};

  my $secondary = scalar %hash;
  print "Secondary keys: ";
  print "$_\n" foreach keys %$secondary;

print "\n";
print Dumper(%hash);
