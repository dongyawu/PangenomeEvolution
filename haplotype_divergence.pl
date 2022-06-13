#! /usr/bin/perl

my $list = shift || die "usage: perl $0 SG_list pop1_list pop2_list output_prefix\n";
my $pop1 = shift || die "";
my $pop2 = shift || die "";
my $prefix =shift || die "";

#$total_individual=0;

open IN001,"$pop1";
while (<IN001>){
	chomp;
	$sample1{$_}=1;
	$total_individual1+=1;
}
close IN001;

open IN002,"$pop2";
while (<IN002>){
	chomp;
	$sample2{$_}=1;
	$total_individual2+=1;
}
close IN002;

open OUT1,">$prefix.div";
print OUT1 "SG\tPop1\tPop1_Pre\tPop2\tPop2_Pre\tDivergence\n";

open IN0,"$list";
while (<IN0>){
	chomp;
	$align_name=$_;
	print "Calculating $align_name...\n";
	## read all aligned seqs
	%temp={};
	open IN,"hap/$align_name.mafft-gb";
	while (<IN>){
		chomp;
		if (/^>/){
			s/>//;
			$seqID=$_;
		}
		else {
			s/ //g;
			$temp{$seqID}.=$_;
		}
	}
	close IN;
	
	## sub-population aligned seqs
	undef %hash1;
	undef %hash2;
	$sum1=0;
	$sum2=0;
	foreach $seqname (keys %temp){
		($sampleID,)=split(/_/,$seqname);
		if (exists $sample1{$sampleID}){
			$hash1{$seqname}=$temp{$seqname};
			$sum1+=1;
		}
		elsif (exists $sample2{$sampleID}){
			$hash2{$seqname}=$temp{$seqname};
			$sum2+=1;
		}
	}
	
	## counting
	## population1
	%count1={};
	foreach $id1 (keys %hash1){
		$count1{$hash1{$id1}}+=1;
	}
	## gene absence as hap0
	$absence1=$total_individual1-$sum1;
	if ($absence1>0){
		$count1{"absence"}=$absence1;
	}
	
	## population 2
	%count2={};
	foreach $id2 (keys %hash2){
		$count2{$hash2{$id2}}+=1;
	}
	$absence2=$total_individual2-$sum2;
	if ($absence2>0){
		$count2{"absence"}=$absence2;
	}

	## divergence
	$dif=0;
	foreach $i (keys %count1){
		foreach $j (keys %count2){
			if ($i ne $j){
				$dif+=$count1{$i}*$count2{$j};
			}
		}
	}

	$divergence=$dif/($total_individual1*$total_individual2);
	$divergence=sprintf "%.5f",$divergence;
	print OUT1 $align_name."\t".$total_individual1."\t".$sum1."\t".$total_individual2."\t".$sum2."\t".$divergence;

#	foreach my $key ( sort { $count{$b} <=> $count{$a} } keys %count ){
#		print OUT1 "\t".$count{$key};
#	}
	print OUT1 "\n";
}
close IN0;
