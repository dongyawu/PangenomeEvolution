#! usr/bin/perl

#use warnings;
use List::Util qw(sum);
use POSIX;

my $file = shift || die "usage: perl $0 file cutoff\n";
##ID+value
my $cutoff0=shift || die "";

$cutoff=1-$cutoff0;

open IN0,"/public2/wudy/weedy_Rice/Pangen/SG_seq/SOG_pos_IRGSP.txt";
while (<IN0>){
	chomp;
	($SOG,$chr,$s,$e)=split(/\t/,$_);
	$chromosome{$SOG}=$chr;
	$startPos{$SOG}=$s;
	$endPos{$SOG}=$e;
}
close IN0;

$m=0;
#$ave=0;
#$sum=0;
$Chr0="";

open IN,"$file";
while (<IN>){
	chomp;
	($SG, $Value0)=split(/\t/,$_);
	$Value=1-$Value0;
	if (exists $chromosome{$SG}){
	$Chr=$chromosome{$SG};
	if (($Chr ne $Chr0) && ($Value>$cutoff)){
		$Chr0=$Chr;
#		$ave=$Value;
#		$sum=$Value;
		$count=1;
		$start=$SG;
		$end=$SG;
		@array=($Value);
	}
	if ($Chr eq $Chr0) {
#		$count+=1;
#		$sum+=$Value;
#		$ave=$sum/$count;
#		if ($ave > $cutoff){
#			$end=$SG;
#			if ($count==1){
#				$start=$SG;
#			}
#		}
#		else {
#			if ($count>=5){
#				$m+=1;
#				$block="Block".$m;
#				print $block."\t".$Chr0."\t".$start."\t".$end."\n";
#			}
#			$start=0;
#			$end=0;
#			$count=0;
#			$sum=0;
#		}
		push(@array,$Value);
		if (@array>5){
			@array2=@array[-5..-1];
			$med=median(@array2);
		}
		else {
			$med=median(@array)-0.1;
		}
		if ($med > $cutoff){
			$end=$SG;
			$count+=1;
			if ($count==1){
				$start=$SG;
			}
		}
		else {
			if ($count>=10){
				$m+=1;
				$block="#Block".$m;
				print $block."\t".$Chr0."\t".$start."\t".$end."\t".$startPos{$start}."\t".$endPos{$end}."\t".($endPos{$end}-$startPos{$start})."\t".$count."\n";
			}
			$start=0;
			$end=0;
			$count=0;
			@array=();
		}
	}
	}
}

sub median {
	sum((sort { $a <=> $b } @_ )[int($#_/2),ceil($#_/2)])/2;
}
