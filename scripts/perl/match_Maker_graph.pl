#!/usr/bin/perl
#use strict;
use warnings;
use Data::Dumper;
use DateTime;
my %opt; # It is nice to have them
$|=1;

our $VERSION = 0.02;

=head1 NAME

matchMaker_graph.pl - Graph, using Chart::Clicker, age ranges for match making

=head1 SYNOPSIS

./matchMaker_graph.pl 

=head1 DESCRIPTION

Just fill in the data at the end of this file 

=head1 DATA

The data is space seperated

    * Your age
    * Younger (Couger limit)
    * Older (Sugar limit)
    * mathematically significant lower
    * mathematically significant upper

The last two are optional, but if included this script will graph outer limits.

=head1 VARIABLES

upper - oldest age to graph

lower - youngest age to graph

=cut

my $outfile = 'match_making.png';

######################################################
# Unless you are hacking this is the end of the line #
######################################################

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
    elsif ($ARGV[$args]=~m/-+lower(.+)/){ $opt{lower} = $1; }
    elsif ($ARGV[$args]=~m/-+lower/){ $args++; $opt{lower} = $ARGV[$args]; }
    elsif ($ARGV[$args]=~m/-+upper(.+)/){ $opt{upper} = $1; }
    elsif ($ARGV[$args]=~m/-+upper/){ $args++; $opt{upper} = $ARGV[$args]; }
    elsif ($ARGV[$args]=~m/-+out(.+)/){ $outfile = $1; }
    elsif ($ARGV[$args]=~m/-+out/){ $args++; $outfile = $ARGV[$args]; }
    elsif ($ARGV[$args]=~m/-+data(.+)/){ $opt{data} = $1; }
    elsif ($ARGV[$args]=~m/-+data/){ $args++; $opt{data} = $ARGV[$args]; }
    else{ print "what is this $ARGV[$args] you talk of?\n"; &help; }
}

print "Debug enabled\n" if $opt{D}>= 2;

$opt{upper} = 70; # Keep on trucking - don't let me set your limits! (Just keep it safe.)
$opt{lower} = 14; # below 14 does not work mathmatically. I'm not suggesting 14 years-olds should be dating anyone at all!

$outfile = $opt{lower} . '_to_' . $opt{upper} .'_'. $outfile;

$opt{data}{0}{name} = '------------------------- ZERO NAME';
$opt{data}{1}{name} = 'Your age';
$opt{data}{2}{name} = 'Younger (Couger limit)';
$opt{data}{3}{name} = 'Older (Sugar limit)';
$opt{data}{4}{name} = 'mathematically significant lower';
$opt{data}{5}{name} = 'mathematically significant upper';

print " a " if $opt{D}>=1;
&_parse_data;
print " b " if $opt{D}>=1;
 # If we do not have 2 data points then we can't plot a line. We need THREE rows of data
 # because each data point requires the change in distance between data rows.
#if( $opt{data}{1}{values} && @{$opt{data}{1}{values}} >= 2 ){ &_create_graph; }else{ 
if( $opt{data}{1}{values} ){ 
    &_create_graph; 
}else{ 
    unless($opt{data}{1}{values}){
        print Dumper($opt{data}{1}{values});
    };
    #print "We need values: " . $opt{data}{1}{values} . "\n";
    #print "We need more than 2 : " . @{ $opt{data}{1}{values} } . "\n";
print "Feed me, (more data) now!\n" if $opt{D}>=1; 
}

print " c " if $opt{D}>=1;
sub help {
    if(my $msg = shift){
        print "Err: $msg";
    }else{ warn "perldoc $0 # is what you are looking for\n"; }
print " F " if $opt{D}>=1;
    exit;
}

sub _parse_data {
  if(ref($opt{data}) ne 'HASH' && exists $opt{data} && -w $opt{data}){
    open(DATA, $opt{data}) or warn "Did not open $opt{data}";
  }elsif(ref($opt{data}) ne 'HASH' && exists $opt{data} && defined $opt{data} && $opt{data} ne '' && length($opt{data}) >= 1){
    print ref($opt{data}) . length($opt{data}) . ' ';
    &help("Can't find the $opt{data} file");
  }
  #LINE: while(my @line = split(' ', <DATA>)){
  LINE: while(<DATA>){
        my @line = split(' ', $_);
        next LINE unless ( @line == 2 || @line == 5 );
        #$count++;
        #$opt{data_row} = $count;
        next LINE if (!$line[0] || $line[0]=~m/^\s*#/ || $line[0]=~m/^\s*$/);
        
        next LINE if ($opt{upper} && $line[0] > $opt{upper});
        next LINE if ($opt{lower} && $line[0] < $opt{lower});
            
            print "U: $line[0] < $line[3] line[1] $line[2] $line[4]\n" if $opt{D}>=2;
            push @{ $opt{data}{1}{values} }, $line[0]; # y-axis
            push @{ $opt{data}{1}{keys} }, $line[0]; # x-axis

            push @{ $opt{data}{2}{values} }, $line[1]; # y-axis
            push @{ $opt{data}{2}{keys} }, $line[0]; # x-axis

            push @{ $opt{data}{3}{values} }, $line[2];
            push @{ $opt{data}{3}{keys} }, $line[0];

            push @{ $opt{data}{4}{values} }, $line[3];
            push @{ $opt{data}{4}{keys} }, $line[0];

            push @{ $opt{data}{5}{values} }, $line[4];
            push @{ $opt{data}{5}{keys} }, $line[0];

        }
  if($opt{data} && -w $opt{data}){
    close(DATA);
  }
}


sub _create_graph {

use Chart::Clicker;
use Chart::Clicker::Data::Series;
use Chart::Clicker::Data::DataSet;
use Chart::Clicker::Renderer::Point;
use Chart::Clicker::Data::Range;

my $cc = Chart::Clicker->new(width => 1024, height => 768, format => 'png');
#my $cc = Chart::Clicker->new(width => 1024, height => 768, format => 'png', lower => $opt{lower}, upper => $opt{upper});


$cc->title->text('Match-Making Age Limits');
$cc->title->font->size(20);


my $series1 = Chart::Clicker::Data::Series->new( $opt{data}{1} );
my ($series2,$context2,$ds2);
my ($series3,$context3,$ds3);
my ($series4,$context4,$ds4);
my ($series5,$context5,$ds5);
if($opt{data}{2}){ $series2 = Chart::Clicker::Data::Series->new( $opt{data}{2} ); }
if($opt{data}{3}){ $series3 = Chart::Clicker::Data::Series->new( $opt{data}{3} ); }
if($opt{data}{4}){ $series4 = Chart::Clicker::Data::Series->new( $opt{data}{4} ); }
if($opt{data}{5}){ $series5 = Chart::Clicker::Data::Series->new( $opt{data}{5} ); }
my $ctx = $cc->get_context('default');
my $ds1 = Chart::Clicker::Data::DataSet->new(series => [ $series1 ]);

if($opt{data}{2}{name}){ 
    # create a new context
    $context2 = Chart::Clicker::Context->new( 
    name => "$opt{data}{2}{name}" 
   ); 

    my $ct2_rgb = {red => .8, green => .6, blue => .0, alpha => .9};
    #$context2->domain_axis->hidden(1);
    $context2->range_axis->label('Age');
    $context2->range_axis->format('%s');
    $context2->range_axis->tick_label_color(Graphics::Color::RGB->new($ct2_rgb));
    $context2->range_axis->label_font->family('Hoefler Text');
    $context2->range_axis->tick_label_angle(0.785398163);
    $context2->range_axis->color(Graphics::Color::RGB->new(red => .8, green => .6, blue => .0, alpha => .9));
    $context2->range_axis->label_color(Graphics::Color::RGB->new(red => .8, green => .6, blue => .0, alpha => .9));
    $context2->range_axis->tick_font->family('Hoefler Text');
    $context2->domain_axis->label('Years of Age'); #redundant 
}
if($opt{data}{3}{name}){ $context3 = Chart::Clicker::Context->new( name => "$opt{data}{3}{name}" ); }
if($opt{data}{4}{name}){ $context4 = Chart::Clicker::Context->new( name => "$opt{data}{4}{name}" ); }
if($opt{data}{5}{name}){ $context5 = Chart::Clicker::Context->new( name => "$opt{data}{5}{name}" ); }


#$cc->plot->grid->visible(0);
$cc->legend->visible(1);
$cc->legend->font->family('Hoefler Text');
$ctx->range_axis->label('Years');
$ctx->range_axis->format('%.0f');
$ctx->domain_axis->format('%.0f');
#$ctx->range_axis->show_ticks(0);    #turn off lines from the y-axis
my $ticks = int( ($opt{upper} - $opt{lower}) / 2);    #turn off lines from the y-axis
$ctx->range_axis->ticks($ticks); 
$ctx->domain_axis->ticks($ticks); 
$ctx->domain_axis->label('Age in years');
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
    $context2->share_axes_with($ctx); # This we really do NOT want
    $context2->range_axis->range( Chart::Clicker::Data::Range->new( lower => $opt{lower}, upper => $opt{upper} ));
    $ds2->context("$opt{data}{2}{name}");
    $cc->add_to_contexts($context2);
    $cc->add_to_datasets($ds2);
}


if($series3){
    $ds3 = Chart::Clicker::Data::DataSet->new(series => [ $series3 ]);
    $context3->share_axes_with($ctx); # This we really do NOT want
    $context3->range_axis->range( Chart::Clicker::Data::Range->new( lower => $opt{lower}, upper => $opt{upper} ));
    $ds3->context("$opt{data}{3}{name}");
    $cc->add_to_contexts($context3);
    $cc->add_to_datasets($ds3);
}

if($series4){
    $ds4 = Chart::Clicker::Data::DataSet->new(series => [ $series4 ]);
    $context4->share_axes_with($ctx); # This we really do NOT want
    $context4->range_axis->range( Chart::Clicker::Data::Range->new( lower => $opt{lower}, upper => $opt{upper} ));
    $ds4->context("$opt{data}{4}{name}");
    $cc->add_to_contexts($context4);
    $cc->add_to_datasets($ds4);
}

if($series5){
    $ds5 = Chart::Clicker::Data::DataSet->new(series => [ $series5 ]);
    $context5->share_axes_with($ctx); # This we really do NOT want
    $ds5->context("$opt{data}{5}{name}");
    $cc->add_to_contexts($context5);
    $cc->add_to_datasets($ds5);
}

#$cc->plot->grid->show_domain(0);

#$cc = Chart::Clicker::Data::Range->new({ lower => 16, upper => 70, });

$cc->draw;
$cc->write($outfile);

}
=head1 BUGS AND LIMITATIONS

Needs three lines of data to plot the graph.

Dates have to be in one of three fixed formats.

Not all functions have been implemented.

Does not die cleanly if you feed it an invalid output file

Does not check for a reduction of total distance, (which is really easy.)

Different types of journey are probably not the same efficiency, so we need to calculate the type of journey, (where possible) and see if we can graph each category of journey separately.

=head1 Examples

./matchMaker_graph.pl

./matchMaker_graph.pl -data data.csv -out image_name.PDF

./matchMaker_graph.pl -d -d -d -d -v

=head1 SEE ALSO

L<Chart::Clicker> 

=head1 AUTHOR

Alexx Roche, C<alexx@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2012 Alexx Roche

This program is free software; you can redistribute it and/or modify it
under the following license: Eclipse Public License, Version 1.0
or the Artistic License, Version 2.0;

See http://www.opensource.org/licenses/ for more information.

=cut

# Data created using
# for i in `seq 150`; do echo -n $(./match_maker $i $i)|sed -e 's/[a-z\(\)]//ig' -e 's/\s\s*/ /g' -e 's/^\s*//g' >> match; done

__DATA__
9 1 10 11 21
10 2 11 12 22
11 3 12 12 23
12 3 13 13 26
13 3 14 13 27
14 4 14 14 28
15 5 16 14 29
16 6 18 15 30
17 7 20 15 31
18 6 22 16 34
19 7 24 16 35
20 8 26 17 36
21 9 28 17 37
22 10 30 18 38
23 11 32 18 39
24 11 34 19 42
25 11 36 19 43
26 12 38 20 44
27 13 40 20 45
28 14 42 21 46
29 15 44 21 47
30 16 46 22 48
31 17 48 22 49
32 16 50 23 52
33 17 52 23 53
34 18 54 24 54
35 19 56 24 55
36 20 58 25 56
37 21 60 25 57
38 22 62 26 58
39 23 64 26 59
40 23 66 27 62
41 23 68 27 63
42 24 70 28 64
43 25 72 28 65
44 26 74 29 66
45 27 76 29 67
46 28 78 30 68
47 29 80 30 69
48 30 82 31 70
49 31 84 31 71
50 30 86 32 74
51 31 88 32 75
52 32 90 33 76
53 33 92 33 77
54 34 94 34 78
55 35 96 34 79
56 36 98 35 80
57 37 100 35 81
58 38 102 36 82
59 39 104 36 83
60 39 106 37 86
61 39 108 37 87
62 40 110 38 88
63 41 112 38 89
64 42 114 39 90
65 43 116 39 91
66 44 118 40 92
67 45 120 40 93
68 46 122 41 94
69 47 124 41 95
70 48 126 42 96
71 49 128 42 97
72 48 130 43 100
73 49 132 43 101
74 50 134 44 102
75 51 136 44 103
76 52 138 45 104
77 53 140 45 105
78 54 142 46 106
79 55 144 46 107
80 56 146 47 108
81 57 148 47 109
82 58 150 48 110
83 59 152 48 111
84 59 154 49 114
85 59 156 49 115
86 60 158 50 116
87 61 160 50 117
88 62 162 51 118
89 63 164 51 119
90 64 166 52 120
91 65 168 52 121
92 66 170 53 122
93 67 172 53 123
94 68 174 54 124
95 69 176 54 125
96 70 178 55 126
97 71 180 55 127
98 70 182 56 130
99 71 184 56 131
100 72 186 57 132
101 73 188 57 133
102 74 190 58 134
103 75 192 58 135
104 76 194 59 136
105 77 196 59 137
106 78 198 60 138
107 79 200 60 139
108 80 202 61 140
109 81 204 61 141
110 82 206 62 142
111 83 208 62 143
112 83 210 63 146
113 83 212 63 147
114 84 214 64 148
115 85 216 64 149
116 86 218 65 150
117 87 220 65 151
118 88 222 66 152
119 89 224 66 153
120 90 226 67 154
121 91 228 67 155
122 92 230 68 156
123 93 232 68 157
124 94 234 69 158
125 95 236 69 159
126 96 238 70 160
127 97 240 70 161
128 96 242 71 164
129 97 244 71 165
130 98 246 72 166
131 99 248 72 167
132 100 250 73 168
133 101 252 73 169
134 102 254 74 170
135 103 256 74 171
136 104 258 75 172
137 105 260 75 173
138 106 262 76 174
139 107 264 76 175
140 108 266 77 176
141 109 268 77 177
142 110 270 78 178
143 111 272 78 179
144 111 274 79 182
145 111 276 79 183
146 112 278 80 184
147 113 280 80 185
148 114 282 81 186
149 115 284 81 187
150 116 286 82 188
