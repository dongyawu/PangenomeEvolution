#! /usr/bin/perl

use warnings;

my $gff=shift || die "usage: perl $0 GFF_file \n";

open IN,"$gff";
open OUT,">$gff\_sim";
while (<IN>){
	chomp;
	($chr, $tools, $type, $start, $end, $dian, $strand, $other, $info)=split(/\t/,$_);
	if ($type eq "mRNA"){
		$info=~/ID=(.+);/;
		$id=$1;
		### DAGchainer required format
		print OUT $id."\t".$id."\t".$id."\t".$chr."\t".$start."\t".$end."\n";
	}
}
