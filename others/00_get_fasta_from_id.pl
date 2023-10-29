#! /usr/bin/perl

my $prot = shift || die "USAGE: perl $0 prot_fasta list! \n";
my $list = shift || die "USAGE: perl $0 prot_fasta list! \n";

%hash;
$str;
@array;

open IN,"$prot";
while (<IN>){
	chomp;
	if (/^>/){
		$hash{$array[1]}=$str;
		$str="";
		@array=split(/\>/,$_);
	}
	else {
		$str.=$_;
	}
	$hash{$array[1]}=$str;
}


open IN2,"$list";
open OUT,">$list.fasta";
while (<IN2>){
	chomp;
	print OUT ">".$_."\n";
	print OUT $hash{$_}."\n";
}

