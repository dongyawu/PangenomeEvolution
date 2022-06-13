#! /usr/bin/perl
use List::Util;

my $list = shift || die "usage: perl $0 list sublist_number random_rep_times.\n";
my $sub_num = shift || die "";
my $rep = shift || die "";

open IN,"$list";
while (<IN>){
	chomp;
	push(@genomes,$_);
}
close IN;

#print @genomes."\n";

foreach $j (1..$rep){
	$file=$list."-$sub_num.".$j;
	open OUT,">$file";
	@random=(List::Util::shuffle @genomes);
	print @genomes."\n";
	foreach $i (1..$sub_num){
		$label=${i}-1;
		$geno=$random[$label];
		print $geno."\t";
		print OUT $geno."\n";
	}
	print "\n";
	close OUT;
}
print "\n";
