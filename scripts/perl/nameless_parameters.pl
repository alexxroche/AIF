#!/usr/bin/perl -wl
use strict;
use warnings;
use PadWalker qw/var_name/;

our $VERSION = 0.01;

use Data::Dumper;

{
  no strict 'refs';
  *{'main:::'} = sub {
    my $ret;
    my @params;

    foreach  (@_) {
      my $var_name = var_name(1,\$_);
      do { $ret->{substr $var_name, 1} = $_; next } if $var_name;
      push @params, $_;
    }
    return $ret, @params;
  };
}

sub foo {
  print Dumper(\@_);
}

my $a = 123;
my $b = 'abc';
my $c = { foo => 'bar' };

foo(&:($a, $b, $c, '456', '567'));

__END__

http://my.opera.com/nicomen/blog/using-named-parameters-without-names-when-calling-functions-in-perl
