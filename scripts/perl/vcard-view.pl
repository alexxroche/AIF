#!/usr/bin/perl
# Copyright (C) 2008, Steven Allen
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see .

# This program parses vCards and displays their contents in a
# human readable form.

# Import libtext-vcard-perl library
use Text::vCard::Addressbook;
use Text::vCard::Node;
use Text::vCard;

# Get card name
my $card_file = $ARGV[0];
if( ( ! $ARGV[0] || !-f "$card_file" ) && -f "var/v4.vcard"){
    $card_file = 'var/v4.vcard';
}

# Create Addressbook
my $address_book = Text::vCard::Addressbook->new({
 'source_file' => $card_file,
});

#Loop through Addressbook
foreach my $vcard ($address_book->vcards()) {
 print "=" . ( "=" x 59 ) . "\n";
 
 # Name/Email
 print "Name:\n " . $vcard->fullname();
 $count = 0;
 my $emails = $vcard->get({ 'node_type' => 'EMAIL' });
 foreach my $email (@{$emails}) {
  if ($count == 0) {
   $space = " ";
  } else {
   $space = "  " . ( " " x length ($vcard->fullname()) ); 
  }
  if($email->is_type('home')) {
   print $space . "<" . $email->value() . "> (Home)\n";
  } elsif ($email->is_type('work')) {
   print $space . "<" . $email->value() . "> (Work)\n";
  } else {
   print $space . "<" . $email->value() . ">\n";
  }
  $count++;
 }
 
 # Address
 my $addresses = $vcard->get({ 'node_type' => 'addresses' });
 print "\nAddresses:\n";
 foreach my $address (@{$addresses}) {
  if($address->is_type('home')) {
   print " --------------------------------\n";
   print "\t" . $address->street() . "\n";
   print " Home:\t" . $address->city() . ", " . $address->region() . "\n";
   print "\t" . $address->post_code() . ", " . $address->country() . "\n";
   print " --------------------------------\n";
  } elsif ($address->is_type('work')) {
   print " --------------------------------\n";
   print "\t" . $address->street() . "\n";
   print " Work:\t" . $address->city() . ", " . $address->region() . "\n";
   print "\t" . $address->post_code() . ", " . $address->country() . "\n";
   print " --------------------------------\n";
  } else {
   print " --------------------------------\n";
   print "\t" . $address->street() . "\n";
   print " Other:\t" . $address->city() . ", " . $address->region() . "\n";
   print "\t" . $address->post_code() . ", " . $address->country() . "\n";
   print " --------------------------------\n";
  }
 }
 # Phones
 print "Phones:\n";
 my $tels = $vcard->get({ 'node_type' => 'tel' });
 foreach my $tel (@{$tels}) {
  if($tel->is_type('home')) {
   print " Home:\t" . $tel->value() . "\n";
  } elsif ($tel->is_type('cell')) {
   print " Cell:\t" . $tel->value() . "\n";
  } elsif ($tel->is_type('work')) {
   print " Work:\t" . $tel->value() . "\n";
  } else {
   print " Other:\t" . $tel->value() . "\n";
  }
 }
 # URL
 my $urls = $vcard->get({ 'node_type' => 'URL' });
 foreach my $url (@{$urls}) {
  print "Web:\t" . $url->value() . "\n";
 }
 print "=" . ( "=" x 59 ) . "\n";
}
