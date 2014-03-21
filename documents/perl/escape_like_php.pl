#!/usr/bin/env perl

use String::ShellQuote;  # This is MUCH better - but if you want to risk it...
use String::Escape qw( escape );  # This is MUCH better - but if you want to risk it...

my $return_quoted = 1;
my $quoted = 1;

sub php_escapeshellarg {
    my $str = @_ ? shift : $_;
    $str =~ s/((?:^|[^\\])(?:\\\\)*)'/$1\\'/g;
    if($return_quoted){ $quoted = 1; return "'$str'"; }
    else{ return $str; }
}

sub cgi_escape {
    my $str = @_ ? shift : $_;
    $str =~ s/([;<>\*\|`&\$!#\(\)\[\]\{\}:'"])/\\$1/g;
    if($return_quoted && $quoted != 1){ return "'$str'"; }
    else{ return $str; }
}

sub all_escape {
    my $str = @_ ? shift : $_;
    $str =~ s/([\s|;<>\*\|`&\$!#\(\)\[\]\{\}:'"])/\\$1/g;
    if($return_quoted && $quoted != 1){ return "'$str'"; }
    else{ return $str; }
}

print "PHP escape: " . php_escapeshellarg("@ARGV") . "\n";
print "cgi_escape: ";
print cgi_escape(php_escapeshellarg("@ARGV")) . "\n";

my $sq = shell_quote @ARGV;
print "ShellQuote: " . $sq . "\n";

print "Str Escape: " . escape('qprintable' , "@ARGV") . "\n";

my $s = $ARGV[0];

for(my $args=1;$args<=(@ARGV -1);$args++){
    $s .= " $ARGV[$args]";
    #if ($args >= 1){ $s .= " $ARGV[$args]"; }
    #else{ $s = $ARGV[$args]; }
}


print "Escape all: ";
print all_escape(php_escapeshellarg($s)) . "\n";
__END__
