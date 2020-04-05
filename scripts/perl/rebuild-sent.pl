#!/usr/bin/perl -w

#
# written by Mauro Cettolo (FBK) - 2011
#

use strict;
use warnings;

use Getopt::Long "GetOptions";

my $maxLen=100;

my ($help,$srcf,$tgtf)=();

$help=1 unless
&GetOptions(
        'file-l1=s' => \$srcf,
        'file-l2=s' => \$tgtf,
        'maxLen=i' => \$maxLen,
        'help' => \$help);

if ($help || !$srcf || !$tgtf){
        print "\nrebuild-sent.pl\n",
        "\t--file-l1 <filename> sentence fragments in language 1\n",
        "\t--file-l2 <filename> sentence fragments in language 2\n",
        "\t--maxLen  <integer> (about) max length of output sentence [optional; default: 100]\n",
        "\t--help               print this screen\n\n";
        exit(1);
}

open(IS, "<$srcf") || die $!;
open(IT, "<$tgtf") || die $!;

my($srcof,$tgtof,$src,$tgt,$dot,$tmps,$tmpt);

$srcof=$srcf.".sent";
$tgtof=$tgtf.".sent";
$tmps=$tmpt="";

open(OS, ">$srcof") || die $!;
open(OT, ">$tgtof") || die $!;

while ($src=<IS>, $tgt=<IT>) {
    chop($src); chop($tgt);

    if ($tgt=~/^[ \t]*<.*>[ \t]*$/) { # look for metadata lines

	if (!($src=~/^[ \t]*<.*>[ \t]*$/)) {
	    printf "Error: source and target metadata not aligned\n";
	    printf "\tsrc=<%s>\n", $src;
	    printf "\ttgt=<%s>\n", $tgt;
	    printf "Exit\n";
	    exit(0);
	}

	# print previous parallel sentence (if not empty)
	if (!($tmps=~/^[ \t]*$/) || !($tmpt=~/^[ \t]*$/)) {
	    printf OS "%s\n", $tmps;
	    printf OT "%s\n", $tmpt;
	}
	$dot="yes";
	$tmps=$tmpt="";

	# print current metadata:
	printf OS "%s\n", $src;
	printf OT "%s\n", $tgt;

    } else {
	# join current segment to previous sentence
	$tmps.=$src." ";
	$tmpt.=$tgt." ";

	# print if target side ends with strong punctuation
	if ($tgt=~/[\.\!\?][ \t]*$/ || $tgt=~/[\.\!\?]\"[ \t]*$/|| &segLen($tmps)>$maxLen || &segLen($tmpt)>$maxLen) {
#	    if (!($tmps=~/^[ \t]*$/) && !($tmpt=~/^[ \t]*$/)) {
		printf OS "%s\n", $tmps;
		printf OT "%s\n", $tmpt;
#	    }
	    $dot="yes";
	    $tmps=$tmpt="";
	} else {
	    $dot="no";
	}
    }
}

# print last parallel sentence if not printed yet
if ($dot eq "no") {
    if (!($tmps=~/^[ \t]*$/) && !($tmpt=~/^[ \t]*$/)) {
	printf OS "%s\n", $tmps;
	printf OT "%s\n", $tmpt;
    }
}

close(OS);
close(OT);
close(IS);
close(IT);

sub segLen {
    my($text) = @_;
    my $num=0; 
    $num++ while $text =~ /\S+/g;     #/
    $num
}
