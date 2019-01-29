#!/usr/bin/env perl

use strict;
use utf8;
use warnings;

binmode STDIN, ":encoding(utf8)";
binmode STDOUT, ":encoding(utf8)";

while (<>) {
  my @sent = split;
  print STDOUT safe_join(@sent) . "\n";
}

sub safe_join {
  my $out = "";
  my $previous_word = "";
  for my $word (@_) {
    if (($previous_word =~ /(\pN|\pL)$/ and $word =~ /^(\pN|\pL)/)) {
      $out .= " ";
    }
    $out .= $word;
    $previous_word = $word;
  }
  return $out;
}
