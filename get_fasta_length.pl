#! /usr/bin/perl

use warnings;

my $fasta=shift;
open OUT,">$fasta\_length_temp";
open IN,"$fasta";

while(<IN>){
	chomp;
	if(/^>/){
		$contig=$_;
		$hash{$contig}=0;
		push @array,$contig;
	}
	else{
		$hash{$contig}+=length($_);
	}
}

foreach $i (@array){
	print OUT $i."\t".$hash{$i}."\n";
}

system(qq(cat $fasta\_length_temp | sed "s/\>//g" > $fasta\_length;));
system(qq(rm -f $fasta\_length_temp;));
