#! /usr/bin/perl

#*****************************************************************************
# Copyright (C) 2012 FBK Trento, Italy
#******************************************************************************

use strict;
use Getopt::Long "GetOptions";


my ($help,$x,$out,$verbose,$N)=();
my ($rev,$trans);

$N=0;
$help=1 unless
&GetOptions('xml=s' => \$x,
            'out=s' => \$out,
            'help'        => \$help,
            'verbose'     => \$verbose);

if ($help || !$x || !$out){
    print "\nted-extract-par.pl\n",
    "\t--xml    <filename>  specify xml file with talks to be extracted\n",
    "\t--out    <filename>  specify file where storing extracted text\n",
    "\t--help               print these instructions (optional)\n\n";    

    exit(1);
}


#load data
my (@text,%index)=();
&load($x,\@text,\%index);


my $title;


#Print output documents and filter out outliners

printf STDERR "opening for writing $out\n";
open(OUT,"> $out");

for $title (keys %index){
    if (defined($index{$title}[0])) {
	my $n=$index{$title}[1]-$index{$title}[0]; 
	for (my $i=0;$i<=$n;$i++){
	    my $s=$text[$index{$title}[0]+$i];

	    if (!($s=~/^[ \t]*</)) {
		$N++;
		print(OUT clean($s),"\n");
	    }
	}
    }
}

close(OUT);

printf("Collected %d (non tags) sentences \n",$N);

##########################

sub load{
    my ($filename,$text,$idx)=@_;

    printf STDERR "opening for reading $filename\n";
    open(DATA,"cat $filename |") ||	die "cannot open $filename";
    my $title="";

    while(<DATA>){
	chop; 	
	if (/<url>.*www\.ted\.com\.*\/(.*)<\/url>/ || /<url>.*=(.*)<\/url>/){
	    $title=$1;
	    push (@$text,$_);
	    $idx->{$title}[0]=$#{$text}; #start position inside text array
        # to revert add %
	    next;
	}
	push (@$text,  $_),next  if (/<keywords>/);	  
	push (@$text,  $_),next  if (/<speaker>/); 
	push (@$text,  $_),next  if (/<description>/);
	push (@$text,  $_),next,  if (/<title>/);
	push (@$text,  $_),next,  if (/<talkid>/);

        if (/<reviewer /) {
            push (@$text,  $_); $rev=1; next;
        }
        if (/<translator /) {
            push (@$text,  $_); $trans=1; next;
        }

	if (/<transcription>/){
	    $_=<DATA>;
	    chop; 	
	    while(!($_=~/<\/transcription>/)) {
		if ($_=~/<seekvideo[ \t]*id=\"[0-9]+\"[ \t]*>/) {
		    ~s/\<seekvideo[^>]+\>//;
		    ~s/\<\/seekvideo\>//;
		    push (@$text, $_);
		}
		$_=<DATA>;
		chop; 	
	    };
	}

	if (/<\/file>/) {
	    push (@$text,  "<reviewer></reviewer>") if (!$rev);
            push (@$text,  "<translator></translator>") if (!$trans);
            $rev=$trans=0;

	    $idx->{$title}[1]=$#{$text}; #last position inside text array	
        # to revert: add another $
	}
    }

    close(DATA);

}

#######################
sub clean{
    my ($txt)=@_;
    $txt=~s/^ +//;
    $txt=~s/$ +//;
    $txt=~s/ +/ /g;	
    return $txt;
}

#######################
