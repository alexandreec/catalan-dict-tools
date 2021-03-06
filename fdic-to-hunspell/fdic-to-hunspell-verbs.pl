#!/bin/perl
use strict;
use warnings;
use autodie;
use utf8;
no locale;
use Encode qw(decode);
require "libs/Flexio.pm";

binmode( STDOUT, ":utf8" );

my $f1   = $ARGV[0]; #"diccionari-arrel/verbs-fdic.txt";
my $out  = $ARGV[1]; #"verbs-hunspell.dic";
my $modelsdir = $ARGV[2]."/"; #"diccionari-arrel/models-verbals/";

my @files = glob($modelsdir."*.model");
@files = sort(@files);
my $modelscount = 0;
my %sufixos = ();
#llegeix nom dels models i assigna sufix hexadeximal 01..9B
foreach my $file (@files) {
    next if ($file !~ /\.model$/);
    $modelscount++;
    my $sufix= sprintf ("%02X", $modelscount);
    my $infinitiu=decode("utf8",$file);
    $infinitiu =~ s/$modelsdir(.*)\.model/$1/;
    $sufixos{$infinitiu} = $sufix;
}

open( my $fh,  "<:encoding(UTF-8)", $f1 );
open( my $ofh, ">:encoding(UTF-8)", $out );
my %formes = ();
while (my $line = <$fh>) {
    chomp($line);
    if ($line =~ /^([^#]+)(er|re|ir|ar|r)=categories:(.+?);model:(.+?);/) { 
	my $infinitiu = $1.$2;
	my $terminacio = $2;
	my $categoria = $3;
	my $model = $4;

	#infinitiu amb el seu model
	#my $apostrofainfinitiu = "";
	#if ( Flexio::apostrofa_masculi($infinitiu) ) {
	#    $apostrofainfinitiu = "_V";
	#}
	if ($model =~ /^cantar$/ && !Flexio::apostrofa_masculi($infinitiu)) {
	    print $ofh "$infinitiu/00\n"; # model especial sense apostrofació: cantar, iodar, halar, etc.
	    # NO SERVEIX PER A HACKEJAR, perquè no és del model "cantar" sinó "envejar"
	} else {
	    print $ofh "$infinitiu/$sufixos{$model}\n"; #$apostrofainfinitiu\n";
	}
	
        # participi femení singular amb l'
	if ($infinitiu =~ /^h?[aeo]/) {
	    open( my $modelfh,  "<:encoding(UTF-8)", $modelsdir.$model.".model" );
	    while (my $modelline = <$modelfh>) {
		if ($modelline =~ /^(.+) (.+) (.+) (.+) #.*$/) {
		    my $forma = $infinitiu;
		    my $trau = $1;
		    my $afegeix = $2;
		    my $postag = $4;
		    if ($forma =~ /^(.*)$trau$/) {
			$forma = $1;
		    }
		    else {
			print $ofh "!!!!ERROR en $forma\n";
		    }
		    if ($afegeix !~ /^0$/) {
			$forma .= $afegeix;
		    }
		    if ($postag =~ /^V.P..SF.$/ && Flexio::apostrofa_femeni($forma) && $forma !~/espesa/) {
			print $ofh "$forma/_V\n"
		    }
		}
	    }
	    close ($modelfh);
	}
    }
}
close ($ofh);
close ($fh);
