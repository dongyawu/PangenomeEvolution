#! /usr/bin/perl
use List::Util;

my $list = shift || die "usage: perl $0 list random_rep_times.\n";
my $rep = shift || die "";

open IN,"$list";
while (<IN>){
	chomp;
	push(@genomes,$_);
}
close IN;

foreach $j (1..$rep){
	$file=$list.".".$j;
	open OUT,">$file";
	foreach $i (List::Util::shuffle @genomes){
		chomp;
		print $i."\t";
		print OUT $i."\n";
	}
	print "\n";
	close OUT;
}
print "\n";
