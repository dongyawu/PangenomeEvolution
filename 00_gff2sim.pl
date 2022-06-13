#! /usr/bin/perl

#use warnings;

my $gff=shift || die "";
open IN,"$gff";
open OUT,">$gff\_sim";
while (<IN>){
	chomp;
	($chr, $tools, $type, $start, $end, $dian, $strand, $other, $info)=split(/\t/,$_);
	if ($type eq "mRNA"){
		$info=~/ID=(.+);/;
		$id=$1;
		print OUT $id."\t".$id."\t".$id."\t".$chr."\t".$start."\t".$end."\n";
	}
}
