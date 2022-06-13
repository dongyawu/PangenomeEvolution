#! /usr/bin/perl

use warnings;

my $file=shift || die "no input!";
my $sog_chr="SOG_pos_IRGSP.txt";

open IN,"$sog_chr";
while (<IN>){
	chomp;
	($sogID, $chrID,)=split(/\t/,$_);
	$pair{$sogID}=$chrID;
}

open IN0,"$file";
while (<IN0>){
	chomp;
	$line=$_;
	($sog,)=split(/\t/,$_);
	$sep{$pair{$sog}}.=$line."\n" if (exists $pair{$sog});
}

foreach (keys %sep){
	open OUT,">$file\_$_";
	print OUT $sep{$_};
	close OUT;
}
