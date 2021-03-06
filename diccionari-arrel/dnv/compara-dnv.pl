#!/bin/perl
use strict;
use warnings;
use autodie;
use utf8;
binmode( STDOUT, ":utf8" );

my $lt_dict="/home/jaume/github/catalan-dict-tools/resultats/lt/diccionari.txt";
my $lt_dict2="/home/jaume/github/catalan-dict-tools/resultats/lt/diccionari-dnv.txt";
my $dnv_dict="/home/jaume/github/catalan-dict-tools/diccionari-arrel/dnv/LemesDNV.csv";
my $mw_dict="/home/jaume/github/languagetool/languagetool-language-modules/ca/src/main/resources/org/languagetool/resource/ca/multiwords.txt";
my $mc_dict="/home/jaume/github/catalan-dict-tools/diccionari-arrel/dnv/mots-classificats.txt";

my %lt;
my %dnv;

open( my $lt_fh,  "<:encoding(UTF-8)", $lt_dict );
while ( my $line = <$lt_fh> ) {
    chomp($line);
    if ($line =~ /(.+) (.+) (.+)/) {
    	my $lemma = $1;
    	if (!exists $lt{$lemma}) {
    		$lt{$lemma}=1;
    	}
    }
}
close $lt_fh;

open( $lt_fh,  "<:encoding(UTF-8)", $lt_dict2 );
while ( my $line = <$lt_fh> ) {
    chomp($line);
    if ($line =~ /(.+) (.+) (.+)/) {
        my $lemma = $1;
        if (!exists $lt{$lemma}) {
            $lt{$lemma}=1;
        }
    }
}
close $lt_fh;

my $locucions="";

open( $lt_fh,  "<:encoding(UTF-8)", $mw_dict );
while ( my $line = <$lt_fh> ) {
    chomp($line);
    if ($line =~ /^(.+)\t(.+)$/) {
    	my $lemma = $1;
    	if (!exists $lt{$lemma}) {
    		$lt{$lemma}=1;
    		$locucions.=" ".$lemma;
    	}
    }
}
close $lt_fh;

#print "LOCUCIONS: $locucions \n";

open( $lt_fh,  "<:encoding(UTF-8)", $mc_dict );
while ( my $line = <$lt_fh> ) {
    chomp($line);
    if ($line =~ /^([^# ;]+)/) {
    	my $lemma = $1;
    	if (!exists $lt{$lemma}) {
    		$lt{$lemma}=1;
    	}
    }
}
close $lt_fh;

#my $size = scalar keys %lt;
#print "El diccionari LT té ". $size . " formes\n";

open( my $dnv_fh,  "<:encoding(UTF-8)", $dnv_dict );
while ( my $line = <$dnv_fh> ) {
    chomp($line);
    if ($line =~ /(.*);(.*);(.*);(.*);(.*);(.*);/) {
    	my $lemma = $1;
    	if (!exists $dnv{$lemma}) {
    		$dnv{$lemma}=1;
    	}
    	$lemma =~ s/^(.+)(-se|'s)$/$1/;
    	if (!exists $lt{$lemma} && $lemma !~ /^-/ && $lemma !~ /-$/ && $locucions !~ /\b$lemma\b/) {
    		print $line . "\n";
    	}
    }
}
close($dnv_fh);

#$size = scalar keys %dnv;
#print "El diccionari DNV té ". $size . " lemes\n";

