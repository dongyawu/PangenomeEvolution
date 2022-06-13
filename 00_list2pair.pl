#! /usr/bin/perl

my $list=shift || die "usage: perl $0 list**\n";

open IN,"$list";
while (<IN>){
	chomp;
	push(@id,$_);
}

$len=@id-1;

#print $len;
foreach $i (0..$len){
	$m=$i+1;
	foreach $j ($m..$len){
		print $id[$i]."\t".$id[$j]."\n";
		print $id[$j]."\t".$id[$i]."\n";
	}
}
