#! /usr/bin/perl

my $align = shift || die "usage: perl $0 alighment K Pop_info\n";
# K: haplotype cluster number
my $K= shift || die ""; ## dominant, sub-dominant and others
#$K=5;

#for plots using different colors representing haplotypes
my $pop= shift || die "";

# Dominant haplotype in tmp: HapTmp
# If dominant hap in XI1A not equal HapTmp, sub-dominant XI1A

open IN0,"$pop";
while (<IN0>){
	chomp;
	($acc, $pop)=split(/\t/,$_);
	$popass{$acc}=$pop;
}
close IN0;

# Read alignment
open IN,"$align";
while (<IN>){
	chomp;
	if (/^>/){
		s/>//;
		$seqID=$_;
	}
	else {
		$hash{$seqID}.=$_;
	}
}
close IN;

### count haplotype frequency
foreach $id (keys %hash){
#	print $id."\t".$count{$hash{$id}}."\n";
	$count{$hash{$id}}+=1;
}

#assign dominant, sub-dominant... haplotypes
$m=1;
foreach my $key ( sort { $count{$b} <=> $count{$a} } keys %count ){
	if ($m<$K){
		if ($count{$key}>=3){
		$hap="hap".$m;
		}
		else {
		$hap="hapOther";
		}
	}
	else {
		$hap="hapOther";
		}
	$hapID{$key}=$hap;
	$m+=1;
}

open OUT,">$align\_K$K.hap";
foreach $seq (keys %hash){
	$seqhap=$hapID{$hash{$seq}};
	print OUT $seq."\t".$seqhap."\n";
}

foreach $j (keys %hash){
	($assID,)=split(/_/,$j);
	if ($hapID{$hash{$j}} ne "hapOther"){
#		print $popass{$assID}."\n";
		if ($popass{$assID} eq "tmp"){
			$tmpCount{$hapID{$hash{$j}}}+=1;
		}
		if ($popass{$assID} eq "XI1A"){
			$XI1ACount{$hapID{$hash{$j}}}+=1;
		}
		if ($popass{$assID} eq "XI1B"){
			$XI1BCount{$hapID{$hash{$j}}}+=1;
		}
		if ($popass{$assID} eq "aus"){
			$ausCount{$hapID{$hash{$j}}}+=1;
		}
		if ($popass{$assID} eq "XI3"){
			$XI3Count{$hapID{$hash{$j}}}+=1;
		}
	}
}

$mm=1;
foreach my $hapkey ( sort { $tmpCount{$b} <=> $tmpCount{$a} } keys %tmpCount ){
	if ($mm==1){
		$tmpdom=$hapkey;
		$hapRA{$hapkey}="hapI";
		print "tmp: ".$hapkey."\t".$tmpCount{$hapkey}."\n";
	}
	else {
		last;
	}
	$mm+=1;
}

$mn=1;
foreach my $hapkey ( sort { $XI1ACount{$b} <=> $XI1ACount{$a} } keys %XI1ACount ){
	if ($mn==1){
		if (($hapkey ne $tmpdom)&&($XI1ACount{$hapkey}>2)){
			$XI1Adom=$hapkey;
			$hapRA{$hapkey}="hapII";
		}
		print "XI1A: ".$hapkey."\t".$XI1ACount{$hapkey}."\n";
	}	
	else {
		last;
	}
	$mn+=1;
}

$nm=1;
foreach my $hapkey ( sort { $XI1BCount{$b} <=> $XI1BCount{$a} } keys %XI1BCount ){
	if ($nm==1){
		if (($hapkey ne $tmpdom)&&($hapkey ne $XI1Adom)&&($XI1BCount{$hapkey}>3)){
			$XI1Bdom=$hapkey;
			$hapRA{$hapkey}="hapIII";
		}
		print "XI1B: ".$hapkey."\t".$XI1BCount{$hapkey}."\n";
	}
	else {
		last;
	}
	$nm+=1;
}

$nn=1;
foreach my $hapkey ( sort { $ausCount{$b} <=> $ausCount{$a} } keys %ausCount ){
	if ($nn==1){
		if (($hapkey ne $tmpdom)&&($hapkey ne $XI1Adom)&&($hapkey ne $XI1Bdom)&&($ausCount{$hapkey}>2)){
			$ausdom=$hapkey;
			$hapRA{$hapkey}="hapIV";
		}
		print "aus: ".$hapkey."\t".$ausCount{$hapkey}."\n";
	}
	else {
		last;
	}
	$nn+=1;
}


$nnm=1;
foreach my $hapkey ( sort { $XI3Count{$b} <=> $XI3Count{$a} } keys %XI3Count ){
	if ($nnm==1){
		if (($hapkey ne $tmpdom)&&($hapkey ne $XI1Adom)&&($hapkey ne $XI1Bdom)&&($hapkey ne $ausdom)&&($XI3Count{$hapkey}>2)){
			$XI3dom=$hapkey;
			$hapRA{$hapkey}="hapV";
		}
		print "XI3: ".$hapkey."\t".$XI3Count{$hapkey}."\n";
	}
	else {
		last;
	}
	$nnm+=1;
}


open OUT,">$align\_K$K.hap";
foreach $seq (keys %hash){
	$seqhap=$hapID{$hash{$seq}};
	if (exists $hapRA{$seqhap}){
		print OUT $seq."\t".$hapRA{$seqhap}."\n";
	}
	else {
		print OUT $seq."\thapR\n";
	}
}

