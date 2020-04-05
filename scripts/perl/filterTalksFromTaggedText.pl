#use strict;
use warnings;


use Getopt::Long "GetOptions";

$err_msg="Error";

my ($talk_ids,$tag_file,%tid)=();

$help=1 unless
&GetOptions(
        'talkids=s' => \$talk_ids,
        'tag-file=s' => \$tag_file);

if ($help || !$talk_ids || !$tag_file){
        print "\nfilter-talks.pl\n",
        "\t--talkids  <filename> file with talk ids to be extracted\n",
        "\t--tag-file <filename> tagged corpus\n\n";
        exit(1);
}

open (FH,$talk_ids)|| die $!;
chop(@talks=<FH>);
close(FH);
for ($i=0; $i<=$#talks; $i++) {
    $tmp=$talks[$i];
    $tmp=~s/talk[0]+|\.txt//g;
    $tid{"$tmp"}=1;
}

$print=0;
open(FH, "<$tag_file") || die $err_msg;
while ($in=<FH>) {
    chop($in);
    if ($in=~/<talkid>/) {
	$tn=$in;
        $tn=~s/<talkid>|<\/talkid>//g; $tn=~s/[ \t]+//g;
	if (defined $tid{"$tn"}) {
	    $print=1;
	    printf "%s\n", $ostring; # print keywords and speaker
	    printf "%s\n", $in;      # print talkid
	}
    } else {
	if ($in=~/<url>/) {
	    $print=0;
	    $ostring=$in;
	} elsif ($in=~/<(keywords|speaker)>/) {
	    $ostring.="\n".$in;      # storing keywords and speaker
	} elsif ($print) {
	    printf "%s\n", $in;      # print title/description segments reviewer/translator
	}
    }
}
