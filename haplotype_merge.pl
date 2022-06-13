#! /usr/bin/perl

my $SGlist=shift || die "usage: perl $0 SG_list Sample_list K Output_file\n";
my $SampleList=shift || die "";
my $K=shift || die "";
my $outfile= shift || die "";

open OUT,">$outfile";
print OUT "SG\t";

open IN0,"$SampleList";
while (<IN0>){
	chomp;
	$Cuid=$_;
	push @splist,$Cuid;
	print OUT $Cuid."\t";
}
print OUT "\n";
close IN0;

open IN,"$SGlist";
while (<IN>){
	chomp;
	$sgID=$_;
	$hapfile="$sgID.mafft-gb_K$K.hap";
	if (-e $hapfile){
		open IN1,"$hapfile";
		%hash={};
		while (<IN1>){
			chomp;
			s/_/\t/;
			($sample,$gene,$haptype)=split(/\t/,$_);
			if (exists $hash{$sample}){
				$hash{$sample}.=",".$haptype;
			}
			else {
				$hash{$sample}=$haptype;
			}
		}
		print OUT $sgID."\t";
		foreach $i (@splist){
			if (not exists $hash{$i}){
				print OUT "hap0\t";
			}
			else {
				print OUT $hash{$i}."\t";
			}
		}
		print OUT "\n";
	}
	else {
		print "Warning: ".$sgID."haplotype assignment could not be found...";
	}
}
