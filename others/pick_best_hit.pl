#! /usr/bin/perl

#use warnings;

my $blast=shift || die "usage: perl $0 blast\n" ;
open IN,"$blast";
open OUT,">$blast\_best_hit";
while (<IN>){
	chomp;
	@gene1=split(/\t/,$_);
	foreach $i (@gene1){
		print OUT $i."\t";}
	print OUT "\n";
	while (<IN>){
		chomp;
		@gene2=split(/\t/,$_);
		if($gene1[0] eq $gene2[0]){
			next;
		}
		else{
			foreach $i (@gene2){
			print OUT $i."\t";}
			print OUT "\n";
			@gene1=@gene2;
		}
	}
}
