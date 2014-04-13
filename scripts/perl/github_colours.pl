#!/usr/bin/env perl
# Copyright 2014 Alexx Roche, MIT Licence

# Some ways to sort Hex RGB colours using HSL
# It would be nice to have a minimum saturation level, (sort all of the grey-scale in their own group)
# and to sort within colours by level, (?Where do we slice the circle?).
# and set the font to a complimentary colour

my %rgb = ( # from the github languages colors
    "Black" => "#000000",
    "333333" => "#333333",
    "666666" => "#666666",
    "999999" => "#999999",
    "cccccc" => "#cccccc",
    "White" => "#ffffff",
    "Arduino" => "#bd79d1",
    "Java" => "#b07219",
    "VHDL" => "#543978",
    "Scala" => "#7dd3b0",
    "Emacs Lisp" => "#c065db",
    "Delphi" => "#b0ce4e",
    "Ada" => "#02f88c",
    "VimL" => "#199c4b",
    "Perl" => "#0298c3",
    "Lua" => "#fa1fa1",
    "Rebol" => "#358a5b",
    "Verilog" => "#848bf3",
    "Factor" => "#636746",
    "Ioke" => "#078193",
    "R" => "#198ce7",
    "Erlang" => "#949e0e",
    "Nu" => "#c9df40",
    "AutoHotkey" => "#6594b9",
    "Clojure" => "#db5855",
    "Shell" => "#5861ce",
    "Assembly" => "#a67219",
    "Parrot" => "#f3ca0a",
    "C#" => "#5a25a2",
    "Turing" => "#45f715",
    "AppleScript" => "#3581ba",
    "Eiffel" => "#946d57",
    "Common Lisp" => "#3fb68b",
    "Dart" => "#cccccc",
    "SuperCollider" => "#46390b",
    "CoffeeScript" => "#244776",
    "XQuery" => "#2700e2",
    "Haskell" => "#29b544",
    "Racket" => "#ae17ff",
    "Elixir" => "#6e4a7e",
    "HaXe" => "#346d51",
    "Ruby" => "#701516",
    "Self" => "#0579aa",
    "Fantom" => "#dbded5",
    "Groovy" => "#e69f56",
    "C" => "#555",
    "JavaScript" => "#f15501",
    "D" => "#fcd46d",
    "ooc" => "#b0b77e",
    "C++" => "#f34b7d",
    "Dylan" => "#3ebc27",
    "Nimrod" => "#37775b",
    "Standard ML" => "#dc566d",
    "Objective-C" => "#f15501",
    "Nemerle" => "#0d3c6e",
    "Mirah" => "#c7a938",
    "Boo" => "#d4bec1",
    "Objective-J" => "#ff0c5a",
    "Rust" => "#dea584",
    "Prolog" => "#74283c",
    "Ecl" => "#8a1267",
    "Gosu" => "#82937f",
    "FORTRAN" => "#4d41b1",
    "ColdFusion" => "#ed2cd6",
    "OCaml" => "#3be133",
    "Fancy" => "#7b9db4",
    "Pure Data" => "#f15501",
    "Python" => "#3581ba",
    "Tcl" => "#e4cc98",
    "Arc" => "#ca2afe",
    "Puppet" => "#cc5555",
    "Io" => "#a9188d",
    "Max" => "#ce279c",
    "Go" => "#8d04eb",
    "ASP" => "#6a40fd",
    "Visual Basic" => "#945db7",
    "PHP" => "#6e03c1",
    "Scheme" => "#1e4aec",
    "Vala" => "#3581ba",
    "Smalltalk" => "#596706",
    "Matlab" => "#bb92ac",
    "C#" => "#bb92af"
 );

use Graphics::Color::RGB;
use Graphics::Color::HSL;
#my %hsl = %h;
my %hsl;
foreach my $l ( keys %rgb ){
    #$hsl{$l} = Graphics::Color::RGB->from_hex_string($rgb{$l})->to_hsl->as_string;
    @{ $hsl{$l} } = Graphics::Color::RGB->from_hex_string($rgb{$l})->to_hsl->as_array;
}

sub these_hash_keys {
     if ($hsl{$a}=~m/^\d/){
            ( $hsl{$a} cmp $hsl{$b} )
            ,( $hsl{$a} <=> $hsl{$b} )
     }else{
            ( $hsl{$a}[1] <=> $hsl{$b}[1] ) # sort by saturation 
            ,( $hsl{$a}[0] <=> $hsl{$b}[0] ) # sort by hue (colour)
            ,( $hsl{$a}[2] <=> $hsl{$b}[2] ) # sort by level (brightness)
     }
}

sub by_s {
    if ($hsl{$a}[0] == $hsl{$b}[0]){
       ( $hsl{$a}[2] <=> $hsl{$b}[2] ) # sort by saturation 
    }else{
        ( $hsl{$a}[1] <=> $hsl{$b}[1] )
    }
}
sub by_h {
    if ($hsl{$a}[0] == $hsl{$b}[0]){
       ( $hsl{$a}[2] <=> $hsl{$b}[2] ) # sort by saturation 
    }else{
        ( $hsl{$a}[0] <=> $hsl{$b}[0] )
    }
}
my $rows=14;
print qq{<html><head><meta http-equiv="content-type" content="text/html; charset=UTF-8"></head><body>\n};
print "#RGB (HEX) - this has a strange mix of greens and blues and some don't look sorted <br />";
foreach my $k (sort { $rgb{$a} cmp $rgb{$b} } keys %rgb ){
    $cols++;
    print "<span style=\"background-color: $rgb{$k} ";
    if($hsl{$k}[2] <= 0.3 ){ print "; color: #cccccc"; }
    print "\" title=\"" . Dumper($hsl{$k}) . qq{">$k</span>};
    if($cols >= $rows){ $cols=0; print "<br />\n"; }
}
print "<br />Luminance - this clearly goes from dark to light<br />";
my $cols =0;
use Data::Dumper;
foreach my $k (sort these_hash_keys keys %hsl ){
    $cols++;
    print "<span style=\"background-color: $rgb{$k} ";
    if($hsl{$k}[2] <= 0.35 ){ print "; color: #cccccc"; }
    print "\" title=\"" . Dumper($hsl{$k}) . qq{">$k</span>};
    if($cols >= $rows){ $cols=0; print "<br />\n"; }
}
$cols =0;
print "<br />Saturation - this goes from dull to colourful <br />";
foreach my $k (sort by_s keys %hsl ){
    $cols++;
    print "<span style=\"background-color: $rgb{$k} ";
    if($hsl{$k}[2] <= 0.1 ){ print "; color: #cccccc"; }
    print "\" title=\"" . Dumper($hsl{$k}) . qq{">$k</span>};
    if($cols >= $rows){ $cols=0; print "<br />\n"; }
}
$cols =0;
print "<br />Hue (colour) - !THIS goes round the colour wheel from Red to Green to Blue, (which is what I was after.)<br />";
foreach my $k (sort by_h keys %hsl ){
    $cols++;
    print "<span style=\"background-color: $rgb{$k} ";
    if($hsl{$k}[2] <= 0.2 ){ print "; color: #cccccc"; }
    print "\" title=\"" . Dumper($hsl{$k}) . qq{">$k</span>};
    if($cols >= $rows){ $cols=0; print "<br />\n"; }
}
print "</body></html>";


=head2 Remove the dependencies 

http://www.perlmonks.org/index.pl?node_id=139486

=cut

use POSIX;
use strict;

sub hsv2rgb {
    my ( $h, $s, $v ) = @_;

    if ( $s == 0 ) {
        return $v, $v, $v;
    }

    $h /= 60;
    my $i = floor( $h );
    my $f = $h - $i;
    my $p = $v * ( 1 - $s );
    my $q = $v * ( 1 - $s * $f );
    my $t = $v * ( 1 - $s * ( 1 - $f ) );

    if ( $i == 0 ) {
        return $v, $t, $p;
    }
    elsif ( $i == 1 ) {
        return $q, $v, $t;
    }
    elsif ( $i == 2 ) {
        return $p, $v, $t;
    }
    elsif ( $i == 3 ) {
        return $p, $q, $v;
    }
    elsif ( $i == 4 ) {
        return $t, $p, $v;
    }
    else {
        return $v, $p, $q;
    }
}

=head2 rgb2hsv

to be written based upon
http://www.cs.rit.edu/~ncs/color/t_convert.html

// r,g,b values are from 0 to 1
// h = [0,360], s = [0,1], v = [0,1]
//      if s == 0, then h = -1 (undefined)

void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v )
{
    float min, max, delta;

    min = MIN( r, g, b );
    max = MAX( r, g, b );
    *v = max;               // v

    delta = max - min;

    if( max != 0 )
        *s = delta / max;       // s
    else {
        // r = g = b = 0        // s = 0, v is undefined
        *s = 0;
        *h = -1;
        return;
    }

    if( r == max )
        *h = ( g - b ) / delta;     // between yellow & magenta
    else if( g == max )
        *h = 2 + ( b - r ) / delta; // between cyan & yellow
    else
        *h = 4 + ( r - g ) / delta; // between magenta & cyan

    *h *= 60;               // degrees
    if( *h < 0 )
        *h += 360;

}

=cut

sub rgb2hsv {
}

=head2 ALSO SEE 
  http://www.perlmonks.org/bare/?node_id=204824
=cut
