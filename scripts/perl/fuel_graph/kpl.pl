#!/usr/bin/perl -T
use strict;
use warnings;
use Data::Dumper;
use DateTime;
my %opt; # It is nice to have them
$|=1;

our $VERSION = 0.02;

# sudo cpanm Chart::Clicker

=head1 NAME

kpl.pl - Graph, using Chart::Clicker, fuel efficiency of a vehicle(kilometers Per Liter), and other things

=head1 SYNOPSIS

Just fill in data.csv and run it.

=head1 DESCRIPTION

By recording just three pieces of data, each time you refuel, we can calculate
the rate of fuel consumption since the last refill.

  * km/litre = ({Odometer at refill}"o" - last_refill("o")) / v(olume)

We can highlight typos/{payment mistakes} if we include the price per volume
 and the cost or refilling, (this is not a philosophical calculation; 
How much were you asked to pay?)

    * is v*p ~ c

So the graph of km/litre should highlight deterioration in performance over time, (or improvement should you use Lord Selby's mixture.)

On the right y-axis we overlay a graph of fuel prices

=head1 NTS

Note To Self  - things to do later

* we can overlay rate of fuel consumption {spikes indicate increased load}

* we can overlay velocity (distance over time) {spikes are long trips}

* we can graph total fuel cost per month and per year

=head1 DATA

This script expects a data file in the form

    * Date of refilling         ([CC]YY-MM-DD|dd.mm.[cc]yy) [2001-01-28|3.12.02]
    * Vehicle Odometer reading (km)         [23145],
    * Volume of Fuel added      (litres)     [27.193],
    * Price per volume unit     (£/l)        [0.891],
    * Cost of refilling         (£)          [50.12]

The last two are optional, but if included this script will check for errors.

It is possible to change the order of the data by predicating with a line
that indicated the order: e.g.

=over

    d,p,v,c,o

=back

Any order is possible, and each line of data can be in a different order from
 the previous using this simple notation. (Not sure why you would want that, 
but it was requested.)

=head1 VARIABLES

=over

    * $outfile    - the name of the file we output to
    * $data       - the name of the data file
    * $data_type  - csv ssv txt ods yaml XML json (only the first has been implemented so far)
    * $opt{redan} - "Take care of the pennies and the pounds will take care of themselves"; Do we round the pennies, or even to the nearest 100 $

=back

=cut

my $outfile = 'kmPerlitre_and_euroPerLitre.png';
my $data = 'data.csv';
$opt{redan} = 1; # granularity to currency to check for. 0.01 (one penny) is the smallest

######################################################
# Unless you are hacking this is the end of the line #
######################################################

my $data_type = 'txt'; # later we can add .ods
if($data=~m/\.csv$/){ $data_type = 'csv'; }
$opt{D}=0; # debug
$opt{V}=0; # verbose

=head1 ARGUMENTS

None are needed, but there are a few options

    * -h help
    * -d debug
    * -v verbosee
    * -data $file
    * -out $file ending in .png or .pdf or .sgf

=cut

# Getopt::Long always seems overkill to me

for(my $args=0;$args<=(@ARGV -1);$args++){
    if ($ARGV[$args]=~m/^-+h/i){ &help; }
    elsif ($ARGV[$args] eq '-d'){ $opt{D}++; }
    elsif ($ARGV[$args] eq '-v'){ $opt{V}++; }
    elsif ($ARGV[$args]=~m/-+out(.+)/){ $outfile = $1; }
    elsif ($ARGV[$args]=~m/-+out/){ $args++; $outfile = $ARGV[$args]; }
    elsif ($ARGV[$args]=~m/-+data(.+)/){ $data = $1; }
    elsif ($ARGV[$args]=~m/-+data/){ $args++; $data = $ARGV[$args]; }
    else{ print "what is this $ARGV[$args] you talk of?\n"; &help; }
}

print "Debug enabled\n" if $opt{D}>= 2;

$opt{data}{1}{name} = 'kilometers per litre';

&_parse_data;
 # If we do not have 2 data points then we can't plot a line. We need THREE rows of data
 # because each data point requires the change in distance between data rows.
if( $opt{data}{1}{values} && @{$opt{data}{1}{values}} >= 2 ){ &_create_graph; }else{ print "Feed me, (more data) now!\n" if $opt{V}>=1; }

sub help {
    if(my $msg = shift){
        print "Err: $msg";
    }else{ warn "perldoc $0 # is what you are looking for\n"; }
    exit;
}

sub _check_price{
    # volume, price, cost (where price is price/volume )
    my ($v,$p,$c) = @_;
    unless( $v=~m/\d+/ &&
            $p=~m/\d+/ &&
            $c=~m/\d+/){ warn "The data in $opt{data_row} of $data is missing or corrupt\n"; }
    #unless( int($v*$p) == int($c) ){ #how closely do we check?
    my $ec = $v * $p; # expected_cost
    my $ev = $c / $p; # expected_cost
    unless( 
            int($ec) <= int($c + $opt{redan}) &&
            int($ec) >= int($c - $opt{redan})
          ){
        #did we pay too much or too little?
        if( ($c-$opt{redan}) > $ec ){
            print "Data-error: Cost:" . int($c) . " is bigger than ($v * $p)=" . int($ec) . " in line $opt{data_row}\n"; 
            my $cd = $c - $ec;
            print STDERR "The cost in line $opt{data_row} of $data seems high by $cd\n" if $opt{V}>=1;
            print STDERR "\t - If the Price is right and the cost is correct then the volume is " . (sprintf('%.2f', $ev)) . " not $v\n ";
        }elsif( ($c+$opt{redan}) < $ec ){
            my $cd = $ec - $c;
            print STDERR "The cost in line $opt{data_row} of $data seem low by $cd\n" if $opt{V}>=1; 
        }else{
            print STDERR "The cost in line $opt{data_row} of $data seem off. c:$c !~ (v:*p:) ". $v*$p . "\n" if $opt{V}>=1;
        }
    }
}


sub _parse_data {
  if(-w $data){
    open(DATA, $data) or warn "Did not open $data";
    my ($count,$last_distance);
    $opt{order}{d} = 0;
    $opt{order}{o} = 1;
    $opt{order}{v} = 2;
    $opt{order}{p} = 3;
    $opt{order}{c} = 4;
    LINE: while(my @line = split(',', <DATA>)){
        $count++;
        $opt{data_row} = $count;
        next LINE if ($line[0]=~m/^\s*#/ || $line[0]=~m/^\s*$/);
        if($line[0]=~m/^\D/){ # we have a non-default order [d,o,v,p,c ]
            for(my $args=0;$args<=(@line -1);$args++){
                my $td = $line[$args]; $td=~s/\s.*[\n]?$//; #type of data
                print "setting $td to $args\n" if $opt{D}>=10;
                $opt{order}{$td} = $args;
            }
            next LINE;
            # this means that the data file can change the order with each entry
            # (if your book keeping is that messy )
        }
        if($line[4]){ 
            $line[4] =~s/\s*#.*$//; #strip comments
            $opt{null} = chomp($line[4]); #strip new line
        }elsif($line[2]){
            $line[2] =~s/\s*#.*$//; #strip comments
            $opt{null} = chomp($line[2]); #strip new line
        }
            
        my($date,$odo,$vol,$prix,$cost) = ( $line[$opt{order}{d}],
                                            $line[$opt{order}{o}],
                                            $line[$opt{order}{v}],
                                            $line[$opt{order}{p}],
                                            $line[$opt{order}{c}]);
        $prix=~s/\s//g;

        # Here we would like to be able to estimate values that are lost or obviously wrong
        # e.g. if the Odo goes down but the date goes up then something is wrong.

        if($odo && $odo!~m/^\d+(\.\d+)?$/){ print "Line $opt{data_row} $odo is not a valid distance.\n" if $opt{V}>=1; next LINE; }
        if($date=~m/\?/){ print "Line $opt{data_row} of $date is not a valid date.\n" if $opt{V}>=1; next LINE; }
        if($date!~m/\d/){ print "Line $opt{data_row} of $date is not a valid date.\n" if $opt{V}>=1; next LINE; }
        if($vol!~m/\d+/){ print "Line $opt{data_row} of $date is not a valid volume.\n" if $opt{V}>=1; next LINE; }
        if($prix && $prix!~m/\d+/){ print "Line $opt{data_row} of $date is not a valid price.\n" if $opt{V}>=1; next LINE; }
        if($cost && $cost!~m/\d+/){ print "Line $opt{data_row} of $date is not a valid cost.\n" if $opt{V}>=1; next LINE; }

        &_check_price($vol,$prix,$cost) if ($vol && $prix && $cost);
        if($last_distance){
            my $d = $odo - $last_distance; 
            #print "$d = $odo - $last_distance\n" if $opt{D}>=1; 
            my $dpl = $d/$vol;
            my ($year,$month,$day);
            if($date=~m/^\d{2,4}-\d{1,2}-\d{1,2}$/){
                ($year,$month,$day) = split('-', $date);
            }elsif($date=~m/^\d{2,4}\/\d{1,2}\/\d{1,2}$/){
                ($year,$month,$day) = split('\/', $date);
            }elsif($date=~m/^(\d{1,2})[\.\/](\d{1,2})[\.\/](\d{2,4})$/){
                ($day,$month,$year) = ($1,$2,$3);
            }else{
                &help("$date in line $count of $data is not a valid date");
            }
            if($year < 1900){ $year += 2000; }
            print "Creating date: year=> $year, month=> $month, day=> $day\n" if $opt{D}>=2;
            my $dt = DateTime->new(year=> $year, month=> $month, day=> $day);
            my $e = $dt->epoch();
            push @{ $opt{data}{1}{values} }, $dpl; # y-axis
            push @{ $opt{data}{1}{keys} }, $e; # x-axis
            if($prix){
                unless($opt{data}{2}){
                    $opt{data}{2}{name} = 'Price Per Liter';
                }
                push @{ $opt{data}{2}{values} }, $prix;
                push @{ $opt{data}{2}{keys} }, $e;
            }

            print "$e : $d\n" if $opt{D}>=2;
        }
        $last_distance = $odo;
        if($opt{D}>=2){
        print "Date $opt{order}{d}: $date, ";
        print "Odo $opt{order}{o}: $odo,  ";
        print "Vol $opt{order}{v}: $vol, ";
        print "Ppl $opt{order}{p}: $prix, Cost $opt{order}{c}: $cost\n" if $opt{D}>=1;
        }
    }
    close(DATA);
 }else{
    &help("Can't find the $data file");
 }
}

sub _create_graph {

use Chart::Clicker; # tested with version 2.88
use Chart::Clicker::Axis::DateTime;
use Chart::Clicker::Data::Series;
use Chart::Clicker::Data::DataSet;
use Chart::Clicker::Renderer::Point;

my $cc = Chart::Clicker->new(width => 1024, height => 768, format => 'png');
$cc->title->text('Checking Vehicular Efficiency');
$cc->title->font->size(20);

my $series1 = Chart::Clicker::Data::Series->new( $opt{data}{1} );
#print "\n" . Dumper($opt{data}{1});
my ($series2,$context2,$ds2);
if($opt{data}{2}){ 
    #print Dumper($opt{data}{2});
    $series2 = Chart::Clicker::Data::Series->new( $opt{data}{2} ); 
}
my $ctx = $cc->get_context('default');
    $ctx->domain_axis(
            Chart::Clicker::Axis::DateTime->new(
                    position        => 'bottom',
                    orientation     => 'horizontal',
                    ticks           => 9 ,
                    format          => "%y-%m-%d"
                    )
            );
my $ds1 = Chart::Clicker::Data::DataSet->new(series => [ $series1 ]);

if($opt{data}{2}{name}){ 
    # create a new context
    $context2 = Chart::Clicker::Context->new( 
    name => 'context2'
    #name => "$opt{data}{2}{name}" 
   ); 

=head1 Optional x-axis at the top

   $context2->domain_axis(
            Chart::Clicker::Axis::DateTime->new(
                    position        => 'top',
                    color     => Graphics::Color::RGB->new(red => .95, green => .24, blue => .32, alpha => .5),
                    label_color     => Graphics::Color::RGB->new(red => .95, green => .24, blue => .32, alpha => .5),
                    #'red => .5, green => .2, blue => .3, alpha => .5',
                    orientation     => 'horizontal',
                    ticks           => 10 ,
                    format          => "%y-%m-%d"
                    )
            );

=cut

    my $ct2_rgb = {red => .8, green => .6, blue => .0, alpha => .9};
    $context2->domain_axis->hidden(1);
    $context2->range_axis->label('£/l');
    #$context2->range_axis->tick_label_color(Graphics::Color::RGB->new(red => .8, green => .6, blue => .0, alpha => .9));
    $context2->range_axis->tick_label_color(Graphics::Color::RGB->new($ct2_rgb));
    $context2->range_axis->label_font->family('Hoefler Text');
    $context2->range_axis->tick_label_angle(0.785398163);
    $context2->range_axis->color(Graphics::Color::RGB->new(red => .8, green => .6, blue => .0, alpha => .9));
    $context2->range_axis->label_color(Graphics::Color::RGB->new(red => .8, green => .6, blue => .0, alpha => .9));
    $context2->range_axis->tick_font->family('Hoefler Text');
    $context2->domain_axis->label('date'); #redundant 
}


#$cc->plot->grid->visible(0);
$cc->legend->visible(1);
$cc->legend->font->family('Hoefler Text');
$ctx->range_axis->label('km/l');
#$ctx->range_axis->show_ticks(0);    #turn off lines from the y-axis
#$ctx->domain_axis->label('Date'); # I like labeled axis but I think it is rather obvious here
# $ctx->domain_axis->tick_label_angle(0.785398163);
$ctx->range_axis->tick_label_color(Graphics::Color::RGB->new(red => .2, green => .0, blue => .4, alpha => .9));
$ctx->range_axis->color(Graphics::Color::RGB->new(red => .2, green => .0, blue => .4, alpha => .9));
$ctx->range_axis->label_color(Graphics::Color::RGB->new(red => .2, green => .0, blue => .4, alpha => .9));
$ctx->range_axis->label_font->family('Hoefler Text');
$ctx->range_axis->tick_font->family('Gentium');
$ctx->domain_axis->tick_font->family('Gentium');
$ctx->domain_axis->label_font->family('Hoefler Text');

$ds1->context('default');
$cc->add_to_datasets($ds1);

if($series2){  #We might not have any price details
    $ds2 = Chart::Clicker::Data::DataSet->new(series => [ $series2 ]);
    #$context2->share_axes_with($ctx); # This we really do NOT want
    #$ds2->context("$opt{data}{2}{name}");
    $ds2->context('context2');
    $cc->add_to_contexts($context2);
    $cc->add_to_datasets($ds2);
}


#$cc->plot->grid->show_domain(0);

$cc->draw;
$cc->write($outfile);

#$cc->write_output($outfile);

}

__END__

=head1 BUGS AND LIMITATIONS

Needs three lines of data to plot the graph.

Dates have to be in one of three fixed formats.

Not all functions have been implemented.

Does not die cleanly if you feed it an invalid output file

Does not check for a reduction of total distance, (which is really easy.)

Different types of journey are probably not the same efficiency, so we need to calculate the type of journey, (where possible) and see if we can graph each category of journey separately.

=head1 Examples

./kpl.pl

./kpl.pl -data data_no_money.csv -out km_per_litre.PDF

./kpl.pl -d -d -d -d -v

=head1 SEE ALSO

L<Chart::Clicker> 

=head1 AUTHOR

Alexx Roche, C<alexx@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2011 Alexx Roche

This program is free software; you can redistribute it and/or modify it
under the following license: Eclipse Public License, Version 1.0
or the Artistic License, Version 2.0;

See http://www.opensource.org/licenses/ for more information.

=cut


