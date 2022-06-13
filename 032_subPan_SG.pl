#! /usr/bin/perl

my $sg= shift ||  die "usage: perl $0 SG_base Sub_SG_list.\n";
my $sub=shift || die "";

open IN,"$sg";
while (<IN>){
	chomp;
	($sgID,$sgSeq)=split(/\t/,$_);
	$hash{$sgID}=$sgSeq;
}
close IN;

open IN2,"$sub";
while (<IN2>){
	chomp;
	$newSG=$_;
	if (exists $hash{$newSG}){
		print $newSG."\t".$hash{$newSG}."\n";
	}
	else {
		print "Warning: no $newSG could be found in SG base!\n";
	}
}
close IN2;
